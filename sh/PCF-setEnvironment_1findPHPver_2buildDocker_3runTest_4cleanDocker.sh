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
    echo "  bcp              Build Cache Prune: Prunes ONLY the Docker build cache."
    echo "                   Useful to ensure the next build is fresh."
    echo "                   Equivalent to 'docker builder prune -af'."
    echo "  s                Status: Shows current Docker disk usage (docker system df)."
    echo "                   Tip: Run before 'c' or 'bcp' to see the potential effect."
    echo "  stop (oder k)    Stops running containers associated with this project (based on image name pattern)."
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
            if command -v systemctl &> /dev/null; then
                 # Auf systemd-Systemen ist 'start docker.service' der Standard.
                 # Wir schlagen es vor, auch wenn die list-units-Prüfung fehlschlug,
                 # da es oft trotzdem funktioniert, wenn Docker installiert ist.
                 echo "  To start Docker for this session, try:" >&2
                 echo "sudo systemctl start docker"
                 # Optional: Füge einen Hinweis hinzu, falls der Benutzer weiß, dass es anders ist
                 echo "  (This is the standard command on most systemd systems like Manjaro.)" >&2
            elif command -v service &> /dev/null; then # Fallback für ältere Systeme
                echo "  To start Docker for this session, try:" >&2
                 echo "  (For older systems using 'service')" >&2
                echo "sudo service docker start"
            else
                 # Wenn weder systemctl noch service gefunden wurden (sehr unwahrscheinlich)
                 echo "  Cannot determine standard service manager (systemctl or service)." >&2
                 echo "  Please check your OS documentation on how to start the Docker service manually." >&2
            fi
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

build_image() {
    local build_op_modifier="$1"

    if [[ "$build_op_modifier" == "p" || "$build_op_modifier" == "prune" ]]; then
        echo "INFO: Build with cache prune requested." >&2 # English Info
        prune_build_cache
    elif [[ -n "$build_op_modifier" ]]; then
        echo "WARNING: Unknown build modifier '$build_op_modifier'. Performing normal build." >&2 # English Warning
    fi

    if ! check_docker_running; then
        return 1
    fi

    local image_name
    local actual_php_version

    echo "--- PHP Version Detection (Output to STDERR) ---" >&2 # English Header
    actual_php_version=$(get_target_php_version)
    echo "----------------------------------------------" >&2 # English Footer
    echo
    echo "Current Git state in project '$PROJECT_ROOT': $(git rev-parse --short HEAD) on ref: $(git symbolic-ref -q --short HEAD || git rev-parse HEAD)" # English Info

    if [[ "$actual_php_version" == "unknown" || -z "$actual_php_version" ]]; then
        echo "ERROR: PHP version is 'unknown'. Aborting build." >&2 # English Error
        return 1
    fi

    echo "Using PHP version for image tag: $actual_php_version" # English Info
    image_name="sl5-preg-contentfinder-php${actual_php_version}-dev:latest"
    echo "Building Docker image as: $image_name (from context: $PROJECT_ROOT)" # English Info

    if docker build -t "$image_name" . ; then
        echo "Image $image_name built successfully." # English Success
    else
        echo "Error building image $image_name." >&2 # English Error
        return 1
    fi
}

run_tests() {
    # $1 ist jetzt der optionale Modifikator ODER ein spezifischer Testpfad
    local modifier_or_testpath="$1"
    local test_command_args="" # Argumente für phpunit

    if ! check_docker_running; then
        return 1
    fi

    local image_name
    local actual_php_version

    echo "--- PHP Version Detection (Output to STDERR) ---" >&2
    actual_php_version=$(get_target_php_version)
    echo "----------------------------------------------" >&2

    if [[ "$actual_php_version" == "unknown" || -z "$actual_php_version" ]]; then
        echo "ERROR: PHP version is 'unknown'. Aborting tests." >&2
        return 1
    fi




    image_name="sl5-preg-contentfinder-php${actual_php_version}-dev:latest"
    echo "Using PHP version $actual_php_version for tests with image $image_name."

    echo "INFO: Ensuring autoloader is up-to-date for the current codebase (using 'composer dump-autoload -o')..." >&2
    # -w /app setzt das Arbeitsverzeichnis für den composer-Befehl
    if ! docker run --rm -v "${PROJECT_ROOT}:/app" -w /app "$image_name" composer dump-autoload -o; then
        echo "ERROR: Failed to dump autoloader. Aborting tests." >&2
        return 1
    fi
    echo # Leerzeile






    # Standardmäßig den kleinsten Test suchen, es sei denn, ein spezifischer Pfad oder "all" wird angegeben
    if [[ -z "$modifier_or_testpath" ]]; then # KEIN Argument übergeben -> Standard: kleinsten suchen
        local find_smallest_test_command="find /app/tests/PHPUnit -type f -name '*Test.php' -print0 | xargs -0 du -b | sort -n | head -n 1 | awk '{print \$2}'"
        local smallest_test_file_path
        smallest_test_file_path=$(docker run --rm -v "${PROJECT_ROOT}:/app" "$image_name" bash -c "$find_smallest_test_command")

        if [[ -n "$smallest_test_file_path" && "$smallest_test_file_path" != *"No such file or directory"* ]]; then
            test_command_args="$smallest_test_file_path" # Der gefundene Pfad wird als Argument verwendet
            echo "INFO: Smallest test file found: $test_command_args" >&2
        else
            echo "ERROR: Could not find smallest test file. Aborting." >&2
            return 1
        fi
    elif [[ "$(echo "$modifier_or_testpath" | tr '[:upper:]' '[:lower:]')" == "all" ]]; then # Argument ist "all"
        echo "INFO: 'all' tests requested. Running PHPUnit without specific file (will use configured suite)." >&2
        test_command_args="" # Kein spezifisches Argument, PHPUnit entscheidet
    elif [[ "$modifier_or_testpath" == /* || "$modifier_or_testpath" == tests/* || "$modifier_or_testpath" == *.php ]]; then # Argument sieht wie ein Pfad aus
        echo "INFO: Specific test path provided: $modifier_or_testpath" >&2
        # Wichtig: Sicherstellen, dass der Pfad relativ zu /app ist, wenn er nicht absolut ist
        if [[ "$modifier_or_testpath" != /* ]]; then
           # Annahme: relative Pfade sind relativ zum Projekt-Root /app
           test_command_args="/app/$modifier_or_testpath"
        else
           test_command_args="$modifier_or_testpath" # Ist bereits absolut
        fi
        # Hier könnte man noch prüfen, ob die Datei im Container existiert
    else # Unbekannter Modifikator
         echo "WARNING: Unknown test modifier or invalid path '$modifier_or_testpath'. Trying to run smallest test..." >&2
         # Fallback zum Standard (kleinsten suchen) oder Abbruch? Hier Fallback:
         local find_smallest_test_command="find /app/tests/PHPUnit -type f -name '*Test.php' -print0 | xargs -0 du -b | sort -n | head -n 1 | awk '{print \$2}'"
         local smallest_test_file_path
         smallest_test_file_path=$(docker run --rm -v "${PROJECT_ROOT}:/app" "$image_name" bash -c "$find_smallest_test_command")
         if [[ -n "$smallest_test_file_path" && "$smallest_test_file_path" != *"No such file or directory"* ]]; then
             test_command_args="$smallest_test_file_path"
             echo "INFO: Fallback successful: Smallest test file found: $test_command_args" >&2
         else
             echo "ERROR: Could not find smallest test file (fallback failed). Aborting." >&2
             return 1
         fi
    fi

    # 4. HINWEIS vor der Ausführung
    echo "" >&2 # Leerzeile davor
    echo "--------------------------------------------------------------------" >&2
    echo "NOTICE: The following test command will run inside the Docker" >&2
    echo "        container '$image_name', using the PHP $actual_php_version defined" >&2
    echo "        within that specific image." >&2
    echo "" >&2
    echo "        Running 'vendor/bin/phpunit ...' directly on your host machine" >&2
    echo "        would use your host's installed PHP version and environment," >&2
    echo "        which might lead to different results or errors." >&2
    echo "--------------------------------------------------------------------" >&2
    echo "" >&2 # Leerzeile danach

    echo "Running tests from project '$PROJECT_ROOT'..."
    echo "Executing in container: php /app/vendor/bin/phpunit $test_command_args" >&2

    # Führe PHPUnit aus. $test_command_args kann leer sein (für 'all') oder einen Pfad enthalten.
    docker run --rm -v "${PROJECT_ROOT}:/app" "$image_name" php /app/vendor/bin/phpunit $test_command_args

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
        echo "INFO: Docker not started, cleanup not possible or not needed." >&2 # English Info
        return 1
    fi

   echo "INFO: Checking for running project-related containers before full cleanup..." >&2
    # Versuche, projektbezogene Container zu stoppen.
    # Wenn der User "nein" sagt, gibt stop_project_containers 0 zurück.
    # Wenn ein Fehler beim Stoppen auftritt, gibt es 1 zurück.
    if ! stop_project_containers; then
        echo "WARNUNG: Could not stop all project-related containers or an error occurred. Cleanup might be incomplete for running containers." >&2
        # Wir könnten hier entscheiden, abzubrechen, oder fortzufahren.
        # 'docker system prune' löscht eh nur gestoppte.
        # return 1 # Optional: Hier abbrechen, wenn Stoppen fehlschlug
    fi
    # Wenn wir hier sind, hat der User entweder "ja" oder "nein" gesagt, oder es gab keine.
    # Fehler beim Stoppen wurden oben behandelt.


    echo "INFO: Starting comprehensive Docker cleanup (docker system prune -af)..." >&2 # English Info
    echo "      This will delete: " >&2
    echo "        - All stopped containers" >&2
    echo "        - All unused networks" >&2
    echo "        - All unused (dangling and untagged) images" >&2
    echo "        - The entire build cache" >&2
    echo "      Running containers and tagged images that are still in use (e.g., as a base for others)" >&2
    echo "      should NOT be removed." >&2
    echo "" >&2
    echo "Current Docker disk usage (before cleanup):" >&2 # English Info
    docker system df
    echo "" >&2

    if docker system prune -af; then
        echo "INFO: Docker system successfully pruned." >&2 # English Info
    else
        echo "WARNING: Problem pruning the Docker system." >&2 # English Warning
    fi
    echo "" >&2
    echo "Docker disk usage after cleanup:" >&2 # English Info
    docker system df
}


# ====================================================================
# --- SCRIPT LOGIC STARTS HERE (AFTER ALL FUNCTION DEFINITIONS) ---
# ====================================================================

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
