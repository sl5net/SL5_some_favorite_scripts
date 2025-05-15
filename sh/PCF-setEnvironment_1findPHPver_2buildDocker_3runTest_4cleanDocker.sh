#!/bin/bash

clear

# --- Configuration ---
RELATIVE_PROJECT_PATH="projects/php/SL5_preg_contentFinder"
TARGET_PROJECT_DIR="$HOME/$RELATIVE_PROJECT_PATH"
# Path to the repository containing this script, relative to $HOME
# IMPORTANT: Adjust this path to your structure if necessary!
PATH_TO_SCRIPT_REPO_FROM_HOME="projects/SL5_some_favorite_scripts/sh"
SCRIPT_FULL_PATH="$0"
SCRIPT_NAME=$(basename "$0")
SCRIPT_ARGS_STRING="$*"
FLAG_FILE_PATH="/tmp/pcf_status_shown_on_boot.flag" # Unique name for the flag file

CORE_PROJECT_IMAGE_PATTERN="sl5-preg-contentfinder"

PROJECT_IMAGE_PREFIX="sl5-preg-contentfinder-php" # Wird auch in stop_project_containers und show_help verwendet

# --- Globale Variablen für den Modus ---
RUNNING_IN_VSCODE_CONTAINER_ID="" # Wird gesetzt, wenn ein VS Code Container gefunden wird
EFFECTIVE_WORKING_DIR="/app"      # Standard-Arbeitsverzeichnis im Container
EFFECTIVE_USER_SPEC=""            # Für docker run: -u ... / Für docker exec: -u <user_im_vscode_container> (optional)


# Prepare tilde version for display
display_target_dir=$(echo "$TARGET_PROJECT_DIR" | sed "s|^$HOME|~|")



# Check if the target project directory exists
if [ ! -d "$TARGET_PROJECT_DIR" ]; then
    echo "ERROR: Target project directory '$display_target_dir' not found." >&2
    echo "Please check the path in the script (RELATIVE_PROJECT_PATH) or create the directory." >&2
    exit 1
fi

# Logic for directory change and restart hint
if [ "$(pwd)" != "$TARGET_PROJECT_DIR" ]; then
    echo "HINT: To change your shell's directory and restart the script in the project context:" >&2 # English Hint
    echo "cd $display_target_dir ; ~/$PATH_TO_SCRIPT_REPO_FROM_HOME/$SCRIPT_NAME $SCRIPT_ARGS_STRING" >&2
    echo "" >&2

    cd "$TARGET_PROJECT_DIR" || { echo "ERROR: Could not change to directory '$display_target_dir'."; exit 1; }
fi

PROJECT_ROOT=$(pwd)

# ====================================================================
# --- FUNCTION DEFINITIONS ---
# ====================================================================

show_help() {
    local script_call_path_for_function="\$HOME/$PATH_TO_SCRIPT_REPO_FROM_HOME/$SCRIPT_NAME"

    echo "Usage: $SCRIPT_NAME {b|t|c|bcp|s|n|p|h} [modifier]" # English Usage
    echo ""
    echo "This script manages the Docker environment for the project:" # English Description
    echo "  $display_target_dir"
    echo ""
    echo "Actions (first letter or specific acronym usually suffices):" # English Actions Intro
    echo "  b [p|prune]      Build the Docker image. Optionally use 'p' or 'prune' as a"
    echo "                   second argument to prune the Docker build cache beforehand."

    echo "  t [all|path]     Test: Runs PHPUnit. Default is to find and run the smallest test file." # NEU
    echo "                   Use 'all' as the second argument to run the default suite (all tests)."
    echo "                   Alternatively, provide a specific path (e.g., tests/MyTest.php) relative to"
    echo "                   the project root or an absolute path within the container."

    echo "  c                Cleanup (Full): Prunes ALL unused Docker resources."
    echo "                   (stopped containers, unused networks, unused images, build cache)."
    echo "                   Equivalent to 'docker system prune -af'."
    echo "    If you know the name(e.g. vscode), maybe use:   docker volume rm vscode "
    echo "  bcp              Build Cache Prune: Prunes ONLY the Docker build cache."
    echo "                   Useful to ensure the next build is fresh."
    echo "                   Equivalent to 'docker builder prune -af'."
    echo "  s                Status: Shows current Docker disk usage (docker system df)."
    echo "                   Tip: Run before 'c' or 'bcp' to see the potential effect."
    echo "  stop (oder k)    Stops running containers associated with this project (based on image name pattern)."
    echo "  i                Interactive shell: Opens a bash shell inside the Docker container"
    echo "                   for the current project state (with live mount and correct user)."
    echo "  n                Name: Displays the determined Docker image name."
    echo "  p                PHP version: Displays the determined PHP version."
    echo "  h                Help: Displays this help overview."
    echo ""
    echo "Notes on Docker Prune Commands:" # English Prune Notes
    echo "  - 'docker system prune -af' (action 'c'): Is very thorough. It removes everything Docker"
    echo "    considers 'unused'. This is usually safe but can sometimes remove images you might"
    echo "    have wanted to keep for a quick switch if they are not currently used by any container."
    echo "  - 'docker builder prune -af' (action 'bcp' or part of 'b p'): Focuses only on the"
    echo "    build cache. This is often useful for resolving build issues or freeing up space"
    echo "    occupied by the cache without affecting other Docker resources."
    echo "  - RECOMMENDATION: Use 's' (status) to see what could be pruned."
    echo "    If facing disk space issues, perhaps start with 'bcp' and only use 'c' if necessary."
    echo ""
    echo "The script ensures it operates within the context of the target project directory." # English Context Note
    echo ""
    echo "TIP: For more convenient usage, you can set up a function 'pcf'." # English Alias Tip
    echo "      The script will still internally change to the project directory '$display_target_dir'."
    echo ""
    echo "  For Bash (add to ~/.bashrc or ~/.bash_profile):" # English Bash Alias
    echo "    pcf() { \"${script_call_path_for_function}\" \"\$@\"; }"
    echo "    # Then run 'source ~/.bashrc' (or .bash_profile) or open a new terminal."
    echo ""
    echo "  For Zsh (add to ~/.zshrc):" # English Zsh Alias
    echo "    pcf() { \"${script_call_path_for_function}\" \"\$@\"; }"
    echo "    # Then run 'source ~/.zshrc' or open a new terminal."
    echo ""
    echo "  For Fish Shell (add to ~/.config/fish/config.fish):" # English Fish Alias
    echo "    function pcf"
    echo "        \"${script_call_path_for_function}\" \$argv"
    echo "    end"
    echo "    # Optionally, run 'funcsave pcf' in the terminal to save the function permanently."
    echo "    # Then open a new terminal or reload the configuration."
    echo ""
    echo "  After setup, you can call: pcf b, pcf t, etc." # English Example
}

check_docker_running() {
    if ! docker ps > /dev/null 2>&1; then
        echo "ERROR: Docker does not seem to be running or is not reachable." >&2
        echo

        if command -v docker &> /dev/null; then # Docker ist installiert
            # Versuche, die wahrscheinlichste Startmethode vorzuschlagen

            command_to_copy="sudo systemctl start docker"
            echo "$command_to_copy"
            if [ -n "$DISPLAY" ] && command -v xclip >/dev/null 2>&1; then
                echo -n "$command_to_copy" | xclip -selection clipboard
                echo "  INFO: $command_to_copy copied to clipboard." >&2
            elif command -v xclip >/dev/null 2>&1; then
                    echo "  INFO: xclip is installed, but no graphical display is available to copy to clipboard." >&2
            else
                    echo "  INFO: 'xclip' utility not found. To enable copy-to-clipboard functionality," >&2
                    echo "        please install it (e.g., 'sudo apt install xclip' or 'sudo pacman -S xclip')." >&2
                fi
            else
                    echo "  Cannot determine standard service manager (systemctl or service)." >&2
            fi

            if command -v systemctl &> /dev/null; then
                 # Auf systemd-Systemen ist 'start docker.service' der Standard.
                 echo "  To start Docker for this session, try:" >&2
                 echo "sudo systemctl start docker"
                 # Optional: Füge einen Hinweis hinzu, falls der Benutzer weiß, dass es anders ist
                 echo "  (This is the standard command on most systemd systems like Manjaro.)" >&2
            elif command -v service &> /dev/null; then # Fallback für ältere Systeme
                echo "  To start Docker for this session, try:" >&2
                echo "  (For older systems using 'service')" >&2

        else # Docker ist nicht installiert
            echo "  Docker command not found. Docker might not be installed." >&2
            echo "  On Manjaro/Arch Linux, you can install Docker with:" >&2
            echo "sudo pacman -Syu docker"
            echo
            echo "  After installation, start the service for the current session with:" >&2
            echo "sudo systemctl start docker"
            echo "  (Note: To enable Docker to start automatically on boot, you would use 'sudo systemctl enable docker')" >&2
            echo
            echo "  And add your user to the 'docker' group (requires logout/login to take effect):" >&2
            echo "sudo usermod -aG docker \$USER"
        fi
        echo "--------------------------------------------------------------------" >&2
        echo "" >&2
        return 1
    fi
    return 0
}


get_php_version_from_dockerfile() {
    local dockerfile_path="./Dockerfile"
    local php_version_raw=""
    local php_version_tag_format=""

    if [ ! -f "$dockerfile_path" ]; then
        # echo "DEBUG: Dockerfile not found at $(pwd)/$dockerfile_path" >&2
        return 1
    fi

    php_version_raw=$(head -n 20 "$dockerfile_path" | grep -i -E '^[[:space:]]*FROM[[:space:]]+php:[0-9]+\.[0-9]+' | \
                      sed -n -E 's/^[[:space:]]*FROM[[:space:]]+php:([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/pI' | \
                      head -n 1)

    if [ -n "$php_version_raw" ]; then
        local major_version=$(echo "$php_version_raw" | cut -d. -f1)
        local minor_version=$(echo "$php_version_raw" | cut -d. -f2)

        if [[ -n "$major_version" && -n "$minor_version" ]]; then
            php_version_tag_format="${major_version}${minor_version}"
            echo "$php_version_tag_format"
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

get_target_php_version() {
    local php_version_from_df
    local final_php_version_for_tag="unknown"

    php_version_from_df=$(get_php_version_from_dockerfile)
    if [ $? -eq 0 ] && [ -n "$php_version_from_df" ]; then
        echo "INFO: PHP version extracted from Dockerfile: $php_version_from_df" >&2 # English Info
        final_php_version_for_tag="$php_version_from_df"
        echo "$final_php_version_for_tag"
        return 0
    else
        echo "INFO: Could not extract PHP version from Dockerfile. Attempting Git-based detection..." >&2 # English Info
    fi

    local current_ref
    current_ref=$(git rev-parse --abbrev-ref HEAD)

    if [[ "$current_ref" != "HEAD" ]]; then
        if [[ "$current_ref" == *php*compat ]]; then
            final_php_version_for_tag=$(echo "$current_ref" | grep -oP 'php\K[0-9]+(?=-compat)')
        elif [[ "$current_ref" == *php[0-9]* ]]; then
             final_php_version_for_tag=$(echo "$current_ref" | grep -oP 'php\K[0-9]+')
        fi
    else
        echo "INFO: HEAD is detached. Attempting to determine PHP version from branches containing this commit..." >&2 # English Info
        local branches_containing_commit
        branches_containing_commit=$(git branch -a --contains HEAD)

        final_php_version_for_tag=$(echo "$branches_containing_commit" | grep -oP 'php\K[0-9]+(?=-compat)' | head -n 1)

        if [[ -z "$final_php_version_for_tag" ]]; then
            final_php_version_for_tag=$(echo "$branches_containing_commit" | grep -oP '/php\K[0-9]+' | head -n 1)
        fi
    fi

    if [[ -n "$final_php_version_for_tag" && "$final_php_version_for_tag" != "unknown" ]]; then
        echo "INFO: PHP version determined from Git context (branch/commit): $final_php_version_for_tag" >&2 # English Info
        echo "$final_php_version_for_tag" | sed 's/\.//g'
    else
        echo "WARNING: Could not determine PHP version from Dockerfile or Git context." >&2 # English Warning
        if [[ "$current_ref" == "HEAD" ]]; then
             echo "Branches containing this commit (Detached HEAD):" >&2 # English Info
             echo "$branches_containing_commit" >&2
        fi
        echo "unknown"
    fi
}



get_vscode_dev_container_id_for_project() {
    docker ps -q --filter "status=running" --filter "label=devcontainer.local_folder=${PROJECT_ROOT}" | head -n 1
}

# Funktion, um zu bestimmen, ob wir 'docker run' oder 'docker exec' verwenden
# und um den Basis-Image-Namen (für 'docker run') zu bekommen
initialize_execution_mode_and_image() {
    RUNNING_IN_VSCODE_CONTAINER_ID=$(get_vscode_dev_container_id_for_project)

    if [ -n "$RUNNING_IN_VSCODE_CONTAINER_ID" ]; then
        echo "INFO: Active VS Code Dev Container found (ID: $RUNNING_IN_VSCODE_CONTAINER_ID). Operations will target this container." >&2
        # Den Benutzer des VS Code Containers ermitteln (optional, wenn man ihn braucht)
        # local vscode_container_user=$(docker inspect --format='{{.Config.User}}' "$RUNNING_IN_VSCODE_CONTAINER_ID")
        # if [ -z "$vscode_container_user" ]; then vscode_container_user="root"; fi # Fallback
        # EFFECTIVE_USER_SPEC="-u $vscode_container_user" # Für docker exec
        # Für die meisten Befehle in einem laufenden Dev Container ist kein explizites -u bei exec nötig.
    else
        echo "INFO: No active VS Code Dev Container found. Operations will use 'pcf b'-built images and new containers." >&2


        command_to_copy="pcf b"
        echo "$command_to_copy"
        if [ -n "$DISPLAY" ] && command -v xclip >/dev/null 2>&1; then
            echo -n "$command_to_copy" | xclip -selection clipboard
            echo "  INFO: $command_to_copy copied to clipboard." >&2
        elif command -v xclip >/dev/null 2>&1; then
                echo "  INFO: xclip is installed, but no graphical display is available to copy to clipboard." >&2
        else
                echo "  INFO: 'xclip' utility not found. To enable copy-to-clipboard functionality," >&2
                echo "        please install it (e.g., 'sudo apt install xclip' or 'sudo pacman -S xclip')." >&2
        fi


        # Ermittle das pcf-Image (wie bisher)
        local actual_php_version
        actual_php_version=$(get_target_php_version)
        if [[ "$actual_php_version" == "unknown" || -z "$actual_php_version" ]]; then
            echo "ERROR: PHP version is 'unknown'. Cannot determine image for operations." >&2
            return 1 # Fehler
        fi
        PCF_IMAGE_NAME="${PROJECT_IMAGE_PREFIX}${actual_php_version}-dev:latest"
        EFFECTIVE_USER_SPEC="-u $(id -u):$(id -g)" # Für docker run
    fi
    return 0
}

check_for_duplicate_project_containers() {
    if ! check_docker_running; then
        return 1 # Docker läuft nicht, keine Prüfung möglich
    fi

    # CORE_PROJECT_IMAGE_PATTERN ist global definiert, z.B. "sl5-preg-contentfinder"
    echo "INFO: Checking for running containers related to project pattern '*${CORE_PROJECT_IMAGE_PATTERN}*'..." >&2

    # Finde alle laufenden Container, deren Image-Name das Kernmuster enthält.
    # Wir müssen hier vorsichtig sein, um false positives zu vermeiden, aber für deinen Fall sollte es passen.
    local running_project_related_container_info
    # Das Leerzeichen vor dem Muster in grep hilft, den Anfang des Image-Namens im Format-Output zu treffen
    running_project_related_container_info=$(docker ps --filter "status=running" --format "{{.ID}}\t{{.Image}}\t{{.Names}}" | grep -E "[[:space:]](vsc-)?${CORE_PROJECT_IMAGE_PATTERN}")

    local running_container_count
    if [ -n "$running_project_related_container_info" ]; then
        running_container_count=$(echo "$running_project_related_container_info" | wc -l)
    else
        running_container_count=0
    fi

    # Toleranz: Wie viele laufende Container, die dieses Muster matchen, sind "okay"?
    # 1 für einen potenziellen VS Code Dev Container
    # + 0 für temporäre pcf-Skript-Container (da diese --rm haben sollten)
    # Wenn pcf i oder pcf t gerade läuft, könnte es kurzzeitig 2 sein.
    # Wir setzen die Schwelle für eine Warnung vielleicht auf > 1.
    # Oder wir sind strenger und sagen, wenn pcf nicht aktiv einen temporären Container nutzt, sollte nur der VS Code Container laufen (falls überhaupt).
    local allowed_running_count=1
    # Wenn du erwartest, dass auch der VS Code Container normalerweise nicht läuft, setze auf 0.
    # Wenn du oft pcf i parallel zum VS Code Dev Container nutzt, vielleicht 2.

    if [ "$running_container_count" -gt "$allowed_running_count" ]; then
        echo "" >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "WARNING: Found $running_container_count running containers related to project pattern '*${CORE_PROJECT_IMAGE_PATTERN}*'." >&2
        echo "         Expected a maximum of $allowed_running_count (e.g., one VS Code Dev Container)." >&2
        echo "         This could waste resources or lead to unexpected behavior." >&2
        echo "Running project-related containers found:" >&2
        echo "$running_project_related_container_info" | awk 'BEGIN {FS="\t"; printf "  %-15s %-70s %s\n", "CONTAINER ID", "IMAGE", "NAMES"} {printf "  %-15s %-70s %s\n", $1, $2, $3}' >&2
        echo "" >&2
        echo "Recommendation:" >&2
        echo "  - Review running containers with 'docker ps'." >&2
        echo "  - Stop unneeded containers with 'docker stop <CONTAINER_ID_or_NAME>'." >&2
        echo "  - Action 'pcf stop' (or 'k') attempts to stop containers matching the pcf-specific image prefix." >&2
        echo "  - Action 'pcf c' (cleanup) removes stopped containers." >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "" >&2
    elif [ "$running_container_count" -eq 0 ]; then
         echo "INFO: No running containers found matching project pattern '*${CORE_PROJECT_IMAGE_PATTERN}*'." >&2
    else
        echo "INFO: $running_container_count container(s) running matching project pattern '*${CORE_PROJECT_IMAGE_PATTERN}*' (within tolerance of $allowed_running_count)." >&2
        # Optional: Liste sie trotzdem auf, damit der User sie sieht.
        if [ "$running_container_count" -gt 0 ]; then # Nur wenn wirklich welche laufen
             echo "Currently running project-related container(s):" >&2
             echo "$running_project_related_container_info" | awk 'BEGIN {FS="\t"; printf "  %-15s %-70s %s\n", "CONTAINER ID", "IMAGE", "NAMES"} {printf "  %-15s %-70s %s\n", $1, $2, $3}' >&2
        fi
    fi
    echo "" >&2
}









run_composer_dump_autoload() {
    if ! check_docker_running; then return 1; fi

    echo "INFO: Ensuring autoloader is up-to-date..." >&2

    # Der Befehl, der von bash -c IM CONTAINER ausgeführt werden soll:
    # Wichtig: $EFFECTIVE_WORKING_DIR hier direkt einsetzen, da es von der äußeren Shell expandiert wird.
    # Die inneren Anführungszeichen sind hier nicht nötig, da der String für bash -c als EIN Argument übergeben wird.
    local inner_command="git config --global --add safe.directory ${EFFECTIVE_WORKING_DIR} && composer dump-autoload -o"

    if [ -n "$RUNNING_IN_VSCODE_CONTAINER_ID" ]; then
        # Übergebe 'bash', '-c', und den 'inner_command' als separate Argumente an docker exec

        docker_cmd_display="docker exec -w \"${EFFECTIVE_WORKING_DIR}\" \"$RUNNING_IN_VSCODE_CONTAINER_ID\" bash -c \"$inner_command\""
        echo "$docker_cmd_display" >&2

        if ! docker exec -w "${EFFECTIVE_WORKING_DIR}" "$RUNNING_IN_VSCODE_CONTAINER_ID" bash -c "$inner_command"; then
            echo "ERROR: Failed to dump autoloader in VS Code container." >&2; return 1;
        fi
    else # Starte neuen Container
        if [ -z "$PCF_IMAGE_NAME" ]; then echo "ERROR: PCF_IMAGE_NAME not set for dump-autoload."; return 1; fi
        # Hier ist es ähnlich, der $inner_command wird an die bash im neuen Container übergeben
        if ! docker run --rm \
            -v "${PROJECT_ROOT}:${EFFECTIVE_WORKING_DIR}" \
            -w "${EFFECTIVE_WORKING_DIR}" \
            $EFFECTIVE_USER_SPEC \
            "$PCF_IMAGE_NAME" \
            bash -c "$inner_command"; then # "$inner_command" als ein Argument für -c
            echo "ERROR: Failed to dump autoloader in new container." >&2; return 1;
        fi
    fi
    echo "INFO: Autoloader updated." >&2
    return 0 # Erfolg signalisieren
}


prune_build_cache() {
    if ! check_docker_running; then
        return 1
    fi
    echo "INFO: Pruning Docker build cache (docker builder prune -af)..." >&2 # English Info
    echo "      This removes all unused build cache layers." >&2
    echo "      Useful for fresh builds or to free up disk space used by the cache." >&2
    if docker builder prune -af; then
        echo "INFO: Docker build cache successfully pruned." >&2 # English Info
    else
        echo "WARNING: Problem pruning the Docker build cache." >&2 # English Warning
    fi
}


run_tests() {
    # $1 ist der optionale Modifikator ODER ein spezifischer Testpfad
    local modifier_or_testpath="$1"
    local test_command_args=""

    if ! check_docker_running; then return 1; fi # Wird am Anfang von initialize_execution_mode_and_image geprüft

    # initialize_execution_mode_and_image() MUSS am Anfang des Skripts oder der Aktion aufgerufen werden,
    # um RUNNING_IN_VSCODE_CONTAINER_ID und PCF_IMAGE_NAME zu setzen.
    # Annahme: Das ist schon passiert.

    if [ -n "$RUNNING_IN_VSCODE_CONTAINER_ID" ]; then
        echo "INFO: Running tests inside active VS Code Dev Container (ID: $RUNNING_IN_VSCODE_CONTAINER_ID)..." >&2
    else
        if [ -z "$PCF_IMAGE_NAME" ]; then echo "ERROR: PCF_IMAGE_NAME not set for tests (run 'pcf b' or ensure Git context provides PHP version)."; return 1; fi
        echo "INFO: Running tests in a new temporary container using image '$PCF_IMAGE_NAME'..." >&2
    fi

    # Logik zur Ermittlung von test_command_args (kleinster, all, spezifisch)
    # ... (Deine Logik, die ggf. auch docker exec/run für find_smallest_cmd verwendet) ...
    # Achte darauf, dass diese internen docker exec/run Aufrufe für find_smallest_cmd
    # auch das korrigierte Quoting für bash -c verwenden, falls sie es nutzen.
    # Beispiel:
    if [[ -z "$modifier_or_testpath" ]]; then
        local find_smallest_cmd="find tests/PHPUnit -maxdepth 2 -type f -name '*Test.php' -print | sort | head -n 1"
        if [ -n "$RUNNING_IN_VSCODE_CONTAINER_ID" ]; then
            test_command_args=$(docker exec -w "$EFFECTIVE_WORKING_DIR" "$RUNNING_IN_VSCODE_CONTAINER_ID" bash -c "$find_smallest_cmd")
        else
            test_command_args=$(docker run --rm -v "${PROJECT_ROOT}:${EFFECTIVE_WORKING_DIR}" -w "$EFFECTIVE_WORKING_DIR" $EFFECTIVE_USER_SPEC "$PCF_IMAGE_NAME" bash -c "$find_smallest_cmd")
        fi
        if [[ -z "$test_command_args" || "$test_command_args" == *"No such file or directory"* || "$test_command_args" == *"find: "* ]]; then
             echo "ERROR: No smallest test found or error during search." >&2; return 1;
        fi
        echo "INFO: Will run smallest test: $test_command_args" >&2
    elif [[ "$(echo "$modifier_or_testpath" | tr '[:upper:]' '[:lower:]')" == "all" ]]; then
        test_command_args=""
        echo "INFO: Will run all tests." >&2
    else # Annahme: spezifischer Pfad
        test_command_args="$modifier_or_testpath"
        echo "INFO: Will run specific test(s): $test_command_args" >&2
    fi

    # Führe Autoloader Dump aus
    if ! run_composer_dump_autoload; then # Ruft die korrigierte Funktion auf
        # Fehlermeldung kommt schon von run_composer_dump_autoload
        return 1;
    fi

    echo "Executing in container : php vendor/bin/phpunit $test_command_args (working dir: ${EFFECTIVE_WORKING_DIR})" >&2

    local phpunit_cmd="php vendor/bin/phpunit $test_command_args"

    if [ -n "$RUNNING_IN_VSCODE_CONTAINER_ID" ]; then

        if ! docker exec -w "${EFFECTIVE_WORKING_DIR}" "$RUNNING_IN_VSCODE_CONTAINER_ID" $phpunit_cmd; then
            echo "ERROR: PHPUnit execution failed in VS Code container." >&2; return 1;
        fi
        echo "CONTAINER_ID: $RUNNING_IN_VSCODE_CONTAINER_ID " >&2;
    else
        if ! docker run --rm -v "${PROJECT_ROOT}:${EFFECTIVE_WORKING_DIR}" -w "${EFFECTIVE_WORKING_DIR}" $EFFECTIVE_USER_SPEC "$PCF_IMAGE_NAME" $phpunit_cmd; then
            echo "ERROR: PHPUnit execution failed in new container." >&2; return 1;
        fi
    fi
    return 0 # Erfolg
}


build_image() {
    # $1 ist der optionale Modifikator (z.B. "p" oder "prune")
    local build_op_modifier="$1"

    # Zuerst die Warnung, falls ein VS Code Dev Container läuft
    if [ -n "$RUNNING_IN_VSCODE_CONTAINER_ID" ]; then # RUNNING_IN_VSCODE_CONTAINER_ID wird global gesetzt
        echo "WARNING: An active VS Code Dev Container is running (ID: $RUNNING_IN_VSCODE_CONTAINER_ID)." >&2
        echo "         'pcf b' will build/update the pcf-managed image (e.g., ${PROJECT_IMAGE_PREFIX}XX-dev:latest)." >&2
        echo "         This does NOT directly rebuild the image used by the *currently running* VS Code Dev Container." >&2
        echo "         To update the VS Code Dev Container's image (if it's based on what 'pcf b' produces" >&2
        echo "         and 'devcontainer.json' points to it), you'll need to use 'Dev Containers: Rebuild Container' in VS Code AFTER this script finishes." >&2
        echo "" >&2
    fi

    # Verarbeitung des Modifikators für Cache Prune
    if [[ "$build_op_modifier" == "p" || "$build_op_modifier" == "prune" ]]; then
        echo "INFO: Build with cache prune requested." >&2
        prune_build_cache # Diese Funktion muss definiert sein
    elif [[ -n "$build_op_modifier" ]]; then
        echo "WARNING: Unknown build modifier '$build_op_modifier'. Performing normal build." >&2
    fi

    # Sicherstellen, dass Docker läuft
    if ! check_docker_running; then # check_docker_running muss definiert sein
        return 1
    fi

    # PHP-Version und Image-Namen ermitteln
    local pcf_image_to_build # Name des Images, das wir bauen wollen
    local actual_php_version

    echo "--- PHP Version Detection (Output to STDERR) ---" >&2
    actual_php_version=$(get_target_php_version) # get_target_php_version muss definiert sein
    echo "----------------------------------------------" >&2
    echo
    echo "Current Git state in project '$PROJECT_ROOT': $(git rev-parse --short HEAD) on ref: $(git symbolic-ref -q --short HEAD || git rev-parse HEAD)"

    if [[ "$actual_php_version" == "unknown" || -z "$actual_php_version" ]]; then
        echo "ERROR: PHP version is 'unknown'. Aborting build." >&2
        return 1
    fi

    echo "Using PHP version for image tag: $actual_php_version" >&2
    # PROJECT_IMAGE_PREFIX ist eine globale Variable, z.B. "sl5-preg-contentfinder-php"
    pcf_image_to_build="${PROJECT_IMAGE_PREFIX}${actual_php_version}-dev:latest"
    echo "Building PCF Docker image as: $pcf_image_to_build (from context: $PROJECT_ROOT)" >&2

    # Docker Build ausführen
    # Die Build-Args für USER_ID/GROUP_ID sind wichtig, damit der 'appuser' im Image die richtige UID/GID hat,
    # falls VS Code ('remoteUser: "appuser"') diesen User später verwenden soll.
    if docker build \
        --build-arg USER_ID="$(id -u)" \
        --build-arg GROUP_ID="$(id -g)" \
        -t "$pcf_image_to_build" . ; then  # '.' als Build-Kontext (PROJECT_ROOT)
        echo "Image $pcf_image_to_build built successfully." >&2

        # --- devcontainer.json aktualisieren ---
        local devcontainer_json_path="./.devcontainer/devcontainer.json" # Relativ zum PROJECT_ROOT
        if [ -f "$devcontainer_json_path" ]; then
            if command -v jq &> /dev/null; then
                echo "INFO: Updating 'image' field in $devcontainer_json_path to '$pcf_image_to_build'..." >&2
                tmp_json_file=$(mktemp)
                if jq --arg imageName "$pcf_image_to_build" \
                   '.image = $imageName | del(.dockerFile?) | del(.context?) | del(.build?)' \
                   "$devcontainer_json_path" > "$tmp_json_file"; then
                    mv "$tmp_json_file" "$devcontainer_json_path"
                    echo "INFO: $devcontainer_json_path updated successfully." >&2
                    echo "      VS Code might need a 'Dev Containers: Rebuild Container' to use this new image." >&2
                else
                    echo "WARNING: Failed to update $devcontainer_json_path with jq. jq command failed." >&2
                    rm -f "$tmp_json_file"
                fi
            else
                echo "WARNING: 'jq' command not found. Cannot automatically update $devcontainer_json_path." >&2
                echo "         Please set 'image': '$pcf_image_to_build' in $devcontainer_json_path manually if needed." >&2
            fi
        else
            echo "INFO: $devcontainer_json_path not found, skipping update of VS Code Dev Container config." >&2
        fi
        # --- ENDE devcontainer.json aktualisieren ---
    else
        echo "Error building image $pcf_image_to_build." >&2
        return 1
    fi
    return 0 # Erfolg
}


stop_project_containers() {
    if ! check_docker_running; then
        return 1
    fi

    # Definiere das Präfix deiner Projekt-Images
    local project_image_prefix="sl5-preg-contentfinder-php"

    echo "INFO: Searching for running containers based on images starting with '${project_image_prefix}'..." >&2

    # Hole IDs und Namen der laufenden Container, deren Image mit dem Präfix beginnt
    # Das Leerzeichen vor dem Präfix im grep stellt sicher, dass wir den Anfang des Image-Namens erwischen
    # (da das Format "{{.ID}} {{.Image}}" ist)
    local running_project_containers_info
    running_project_containers_info=$(docker ps --filter "status=running" --format "{{.ID}}\t{{.Image}}\t{{.Names}}" | grep -E "[[:space:]]$project_image_prefix")

    if [ -z "$running_project_containers_info" ]; then
        echo "INFO: No running containers found with image prefix '${project_image_prefix}'." >&2
        return 0
    fi

    echo "WARNING: The following running project-related containers were found:" >&2
    # Formatiere die Ausgabe etwas schöner
    echo "$running_project_containers_info" | awk 'BEGIN {FS="\t"; printf "  %-15s %-50s %s\n", "CONTAINER ID", "IMAGE", "NAMES"} {printf "  %-15s %-50s %s\n", $1, $2, $3}' >&2
    echo "" >&2

    # --- BEGINN ÄNDERUNG WEGEN KEINE BESTÄTIGUNG ---
    echo "INFO: Proceeding to stop these containers WITHOUT further confirmation..." >&2
    # read -r -p "Do you want to stop these containers? (yes/NO): " confirmation
    # if [[ "$(echo "$confirmation" | tr '[:upper:]' '[:lower:]')" == "yes" ]]; then
        local container_ids_to_stop
        container_ids_to_stop=$(echo "$running_project_containers_info" | awk '{print $1}')

        if [ -z "$container_ids_to_stop" ]; then # Sollte nicht passieren, wenn running_project_containers_info nicht leer war
            echo "ERROR: Could not extract container IDs to stop." >&2
            return 1
        fi

        echo "INFO: Stopping identified containers: $container_ids_to_stop" >&2
        # Verwende xargs, um sicherzustellen, dass die IDs korrekt übergeben werden,
        # besonders wenn es viele sind oder Sonderzeichen enthalten (unwahrscheinlich für IDs).
        # Und um zu verhindern, dass 'docker stop' ohne Argumente aufgerufen wird, falls $container_ids_to_stop leer ist.
        echo "$container_ids_to_stop" | xargs docker stop

        if [ $? -eq 0 ]; then # Prüfe den Exit-Status des letzten Befehls (docker stop via xargs)
            echo "INFO: Containers stopped successfully." >&2
            return 0
        else
            echo "ERROR: Failed to stop one or more containers. Check Docker logs for details." >&2
            return 1
        fi
}

cleanup_docker() {
    if ! check_docker_running; then
        echo "INFO: Docker not started, cleanup not possible or not needed." >&2
        return 1
    fi

    # Zuerst ggf. laufende projektbezogene Container stoppen (mit Benutzerbestätigung oder automatisch, je nach deiner stop_project_containers Logik)
    echo "INFO: Checking for running project-related containers before full cleanup..." >&2
    if ! stop_project_containers; then # stop_project_containers muss definiert sein und gibt 0 zurück, wenn User "nein" sagt oder keine da sind
        echo "WARNUNG: Could not stop all project-related containers or an error occurred. Cleanup might be incomplete for running containers." >&2
        # Hier entscheiden, ob man abbricht oder weitermacht.
        # Da system prune eh nur gestoppte Container entfernt, ist weitermachen oft okay.
    fi
    if ! stop_project_containers; then # stop_project_containers muss definiert sein und gibt 0 zurück, wenn User "nein" sagt oder keine da sind
        echo "WARNUNG: Could not stop all project-related containers or an error occurred. Cleanup might be incomplete for running containers." >&2
        # Hier entscheiden, ob man abbricht oder weitermacht.
        # Da system prune eh nur gestoppte Container entfernt, ist weitermachen oft okay.
    fi
    echo "Line 616: docker volume rm vscode" >&2
docker volume rm vscode
    echo "INFO: Starting comprehensive Docker Cleanup (docker system prune -af --volumes)..." >&2 # --volumes hinzugefügt
    echo "      This will delete: " >&2
    echo "        - All stopped containers" >&2
    echo "        - All unused networks" >&2
    echo "        - All unused (dangling and not tagged) images" >&2
    echo "        - The entire build cache" >&2
    echo "        - ALL UNUSED VOLUMES (including named ones like 'vscode' if not in use)" >&2 # Wichtiger Hinweis
    echo "      Running containers and tagged images that are still in use (e.g., as a base for others)," >&2
    echo "      and VOLUMES USED BY ANY (even stopped) CONTAINER, should NOT be removed." >&2
    echo "" >&2
    echo "Current Docker disk usage (before cleanup):" >&2
    docker system df
    echo "" >&2

    echo "docker system prune -af --volumes (Aktion 'c'): it doppelte ALL volumes"
    echo "If you know the name(e.g. vscode), maybe use:   docker volume rm vscode "
    # docker system prune -af (löscht keine benannten, ungenutzten Volumes).

    # Der entscheidende Befehl mit --volumes
    if docker system prune -af --volumes; then # -a (all unused images), -f (force), --volumes (all unused volumes)
        echo "INFO: Docker successfully pruned (including unused volumes)." >&2
    else
        echo "WARNUNG: Problem pruning the Docker System." >&2
    fi
    echo "" >&2
    echo "Docker disk usage after cleanup:" >&2
    docker system df
}


interactive_shell() { # Die 'pcf i' Aktion
    if ! check_docker_running; then return 1; fi

    if [ -n "$RUNNING_IN_VSCODE_CONTAINER_ID" ]; then
        # VS Code Dev Container gefunden!
        local container_name=$(docker inspect --format="{{.Name}}" "$RUNNING_IN_VSCODE_CONTAINER_ID" | sed 's,^/,,' )
        echo "INFO: Connecting to active VS Code Dev Container: $container_name (ID: $RUNNING_IN_VSCODE_CONTAINER_ID)." >&2
        echo "      Working directory and user will be as configured by VS Code." >&2
        echo "Type 'exit' to leave." >&2; echo
        if ! (docker exec -it "$RUNNING_IN_VSCODE_CONTAINER_ID" /bin/bash || docker exec -it "$RUNNING_IN_VSCODE_CONTAINER_ID" /bin/sh); then
             echo "ERROR: Could not start a shell in VS Code Dev Container." >&2; return 1;
        fi
    else
        # Kein VS Code Dev Container, starte neuen temporären
        if [ -z "$PCF_IMAGE_NAME" ]; then echo "ERROR: PCF_IMAGE_NAME not set for interactive shell."; return 1; fi
        echo "INFO: No active VS Code Dev Container. Starting new temporary shell in '$PCF_IMAGE_NAME'..." >&2
        echo "      Project mounted to '${EFFECTIVE_WORKING_DIR}', running as UID/GID of host user." >&2
        echo "Type 'exit' to leave; container will be removed." >&2; echo
        if ! docker run --rm -it \
            -v "${PROJECT_ROOT}:${EFFECTIVE_WORKING_DIR}" \
            -w "${EFFECTIVE_WORKING_DIR}" \
            $EFFECTIVE_USER_SPEC \
            "$PCF_IMAGE_NAME" \
            /bin/bash; then
            echo "ERROR: Failed to start new temporary interactive shell." >&2; return 1;
        fi
    fi
    echo "Exited container shell." >&2
}



# Funktion, um nach mehrfach laufenden Projekt-Containern zu suchen und zu warnen
check_for_duplicate_project_containers() {
    if ! check_docker_running; then
        return 1 # Docker läuft nicht, keine Prüfung möglich
    fi

    # Ermittle das aktuell relevante Projekt-Image
    # Wir brauchen hier nur den Namen, um danach zu filtern.
    # Die get_target_php_version gibt nur die Versionsnummer, wir bauen den Namen selbst.
    local current_php_version_for_tag
    current_php_version_for_tag=$(get_target_php_version) # Holt reine Versionsnummer oder "unknown"

    if [[ "$current_php_version_for_tag" == "unknown" || -z "$current_php_version_for_tag" ]]; then
        echo "WARNUNG: PHP-Version für Duplikat-Prüfung nicht bestimmbar. Überspringe Prüfung." >&2
        return 0 # Kein Fehler, aber keine Prüfung möglich
    fi

    # Das ist das Image-Muster/Name, nach dem wir suchen
    local target_image_name_pattern="sl5-preg-contentfinder-php${current_php_version_for_tag}-dev"
    # Wir verwenden hier bewusst nicht den :latest Tag, um flexibler zu sein, falls mal andere Tags existieren,
    # aber für die Zählung ist der genaue Name mit Tag oft besser.
    local target_image_fullname="${target_image_name_pattern}:latest"

    echo "INFO: Checking for multiple running containers of image '$target_image_fullname'..." >&2

    # Zähle laufende Container, die exakt dieses Image verwenden
    # --filter "ancestor=..." ist gut, da es auch auf Basisimages prüft, falls das Tag mal anders ist aber vom selben Build stammt.
    # Sicherer ist aber, direkt nach dem exakten Image-Namen und Tag zu filtern.
    local running_container_count
    running_container_count=$(docker ps --filter "status=running" --filter "ancestor=${target_image_fullname}" --format "{{.ID}}" | wc -l)

    # Alternativ, wenn man nur nach dem Image-Namen (ohne Tag) filtern will:
    # local running_container_info
    # running_container_info=$(docker ps --filter "status=running" --format "{{.ID}}\t{{.Image}}" | grep -E "[[:space:]]$target_image_name_pattern")
    # running_container_count=$(echo "$running_container_info" | wc -l)


    # Toleranz: Wie viele laufende Container dieses Typs sind "okay"?
    # Wenn VS Code einen Dev Container dieses Images verwendet, ist 1 okay.
    # Wenn das Skript selbst temporäre Container startet, sollte danach 0 sein (wegen --rm).
    # Setzen wir die Toleranz mal auf 1 (z.B. für einen laufenden VS Code Dev Container).
    # Wenn du aber erwartest, dass NIE einer läuft, setze es auf 0.
    local allowed_running_count=1

    if [ "$running_container_count" -gt "$allowed_running_count" ]; then
        echo "" >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "WARNUNG: Es laufen $running_container_count Container des Images '$target_image_fullname'." >&2
        echo "         Erwartet wurden maximal $allowed_running_count." >&2
        echo "         Dies könnte Ressourcen verschwenden oder zu unerwartetem Verhalten führen." >&2
        echo "Laufende Container dieses Images:" >&2
        docker ps --filter "status=running" --filter "ancestor=${target_image_fullname}" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}" >&2
        echo "" >&2
        echo "Empfehlung:" >&2
        echo "  - Überprüfen Sie die laufenden Container mit 'docker ps'." >&2
        echo "  - Stoppen Sie nicht benötigte Container mit 'docker stop <CONTAINER_ID_oder_NAME>'." >&2
        echo "  - Sie können die Aktion 'pcf stop' (oder 'pcf k') verwenden, um zu versuchen," >&2
        echo "    projektbezogene Container (basierend auf dem Image-Präfix) zu stoppen." >&2
        echo "  - Die Aktion 'pcf c' (cleanup) entfernt gestoppte Container." >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "" >&2
        # Hier KEIN automatisches Stoppen, nur eine Warnung. Der User soll entscheiden.
        # Ein automatisches Stoppen wäre zu riskant ohne genaue Identifikation des "richtigen" Containers.
    elif [ "$running_container_count" -eq 0 ] && [ "$allowed_running_count" -ge 1 ]; then
         echo "INFO: Kein Container des Images '$target_image_fullname' läuft aktuell (was oft normal ist) (docker ps -a)." >&2
    else
        echo "INFO: $running_container_count Container des Images '$target_image_fullname' laufen (innerhalb der Toleranz von $allowed_running_count)." >&2
    fi
    echo "" >&2
}

# ====================================================================
# --- SCRIPT LOGIC STARTS HERE (AFTER ALL FUNCTION DEFINITIONS) ---
# ====================================================================

# --- Prüfung auf doppelte Projekt-Container ---
check_for_duplicate_project_containers # Aufruf der neuen Funktion




# 1. Docker-Modus initialisieren (prüft auf laufenden VS Code Dev Container)
if ! initialize_execution_mode_and_image; then
    # Fehler bei der Initialisierung (z.B. PHP Version für PCF-Image nicht gefunden)
    exit 1
fi








# 1. Prüfen, ob überhaupt Argumente da sind
if [ $# -eq 0 ]; then
    echo "Error: No action specified." >&2
    show_help
    exit 1
fi

# 2. Argumente parsen
action=$(echo "$1" | tr '[:upper:]' '[:lower:]')
modifier=$(echo "$2" | tr '[:upper:]' '[:lower:]')

# 3. Prüfen, ob Docker benötigt wird und läuft (für die meisten Aktionen)
docker_needed=1 # Standardmäßig annehmen, dass Docker gebraucht wird
case "$action" in
    h|help|-h|--help|n|name|p|php_version|phpversion) # Aktionen, die KEIN Docker brauchen
        docker_needed=0
        ;;
esac


docker_is_running=0
if [ $docker_needed -eq 1 ]; then
    if check_docker_running; then # check_docker_running prüft UND gibt Fehlermeldung aus, wenn nicht
        docker_is_running=1
    else
        # Docker läuft nicht, check_docker_running hat bereits informiert.
        # Skript hier beenden, da die Aktion nicht ausgeführt werden kann.
        exit 1
    fi
fi

# --- Wenn wir hier sind, läuft Docker (falls benötigt) oder wird nicht benötigt ---

# 4. Einmalige Docker-Statusanzeige nach Systemstart (nur wenn Docker gebraucht wird UND läuft)
if [ $docker_needed -eq 1 ] && [ $docker_is_running -eq 1 ] && [ ! -f "$FLAG_FILE_PATH" ]; then
    echo "--- Docker Disk Usage (displayed once after system boot) ---" >&2
    if docker system df; then # Direkter Aufruf
        touch "$FLAG_FILE_PATH"
        echo "INFO: Docker status displayed. Will not be shown automatically again this session." >&2
    else
        echo "ERROR: 'docker system df' could not be executed successfully." >&2
    fi
    echo "----------------------------------------------------------------------" >&2
    echo

    echo "- Next: composer update --- /( its sometimes forgotten )--------------" >&2
    composer update

fi



# --- Einmalige Docker-Statusanzeige nach Systemstart ---
if [ ! -f "$FLAG_FILE_PATH" ]; then
    echo "--- Docker Speicherstatus (wird einmalig nach Systemstart angezeigt) ---" >&2
    # Prüfe ZUERST, ob Docker läuft
    if check_docker_running; then
        # Nur wenn Docker läuft, versuche den Status zu zeigen
        if docker system df; then # Direkter Aufruf von docker system df
             touch "$FLAG_FILE_PATH"
             echo "INFO: Docker-Status wurde angezeigt. Für diese Sitzung nicht erneut automatisch." >&2
        else
             echo "FEHLER: 'docker system df' konnte nicht erfolgreich ausgeführt werden, obwohl Docker läuft." >&2
             # Flag nicht setzen, damit es beim nächsten Mal erneut versucht wird? Oder doch? Diskutabel.
             # Für den Moment setzen wir das Flag nicht.
        fi
    else
        # Fehlermeldung kommt schon von check_docker_running
        echo "INFO: Docker-Status kann nicht angezeigt werden, da Docker nicht aktiv ist." >&2
        # Flag wird nicht gesetzt.
    fi
    echo "----------------------------------------------------------------------" >&2
    echo
fi



# 5. Aktionen ausführen (Docker-Prüfung ist schon erfolgt, wenn nötig)
case "$action" in
    b|build)
        # Docker läuft garantiert, wenn wir hier sind
        build_image "$modifier"
        ;;
    t|test)
        # Docker läuft garantiert
        run_tests "$modifier"
        ;;
    c|cleanup)
        # Docker läuft garantiert
        cleanup_docker
        ;;
    bcp|"buildcacheprune")
        # Docker läuft garantiert
        prune_build_cache
        ;;
    stop|k)
        stop_project_containers
        ;;
    s|status)
        # Docker läuft garantiert
        echo "Current Docker disk usage:" >&2
        docker system df # Direkter Aufruf
        echo
        echo "Tip: Use 'c' (cleanup) to free up unused resources." >&2
        ;;
    i)
        interactive_shell
        ;;
    n|name)
        # Docker wird nicht benötigt, läuft hier direkt
        img_name=$(get_target_php_version)
        if [[ "$img_name" != "unknown" && -n "$img_name" ]]; then
            echo "sl5-preg-contentfinder-php${img_name}-dev:latest"
        else
            echo "Error determining image name (PHP version 'unknown')." >&2; exit 1
        fi
        ;;
    p|php_version|phpversion)
         # Docker wird nicht benötigt
        php_ver=$(get_target_php_version)
        if [[ "$php_ver" != "unknown" && -n "$php_ver" ]]; then
            echo "$php_ver"
        else
            echo "Error determining PHP version ('unknown')." >&2; exit 1
        fi
        ;;
    h|help|-h|--help)
         # Docker wird nicht benötigt
        show_help
        exit 0
        ;;
    *)
        # Wurde eigentlich schon durch die Prüfung oben abgefangen, aber sicherheitshalber
        echo "Error: Invalid action '$1'." >&2
        show_help
        exit 1
        ;;
esac




