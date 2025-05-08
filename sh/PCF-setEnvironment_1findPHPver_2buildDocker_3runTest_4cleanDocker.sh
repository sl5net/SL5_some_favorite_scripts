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
    echo "  t                Test: Runs PHPUnit tests inside the Docker container."
    echo "  c                Cleanup (Full): Prunes ALL unused Docker resources."
    echo "                   (stopped containers, unused networks, unused images, build cache)."
    echo "                   Equivalent to 'docker system prune -af'."
    echo "  bcp              Build Cache Prune: Prunes ONLY the Docker build cache."
    echo "                   Useful to ensure the next build is fresh."
    echo "                   Equivalent to 'docker builder prune -af'."
    echo "  s                Status: Shows current Docker disk usage (docker system df)."
    echo "                   Tip: Run before 'c' or 'bcp' to see the potential effect."
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
        echo "ERROR: Docker does not seem to be running or is not reachable." >&2 # English Error
        echo # Empty line for readability
        if command -v docker &> /dev/null; then
            echo "  To start Docker for this session, try one of the following:" >&2 # English Start Hint
            if command -v systemctl &> /dev/null && systemctl list-units --full -all | grep -q 'docker.service'; then
                echo "  (For systemd systems like Manjaro)" >&2
                echo "sudo systemctl start docker"
            elif command -v service &> /dev/null && (service docker status > /dev/null 2>&1 || service --status-all | grep -q docker); then
                echo "  (For older systems using 'service')" >&2
                echo "sudo service docker start"
            else
                echo "  Docker seems installed, but its service management isn't standard (systemctl/service)." >&2
                echo "  Please check your OS documentation on how to start the Docker service manually." >&2
            fi
        else
            echo "  Docker command not found. Docker might not be installed." >&2 # English Not Installed
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

show_docker_storage_status() {
    if ! check_docker_running; then
        return 1
    fi
    if docker system df; then
        return 0
    else
        echo "ERROR: 'docker system df' could not be executed successfully." >&2 # English Error
        return 1
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
    if ! check_docker_running; then
        return 1
    fi

    local image_name
    local actual_php_version

    echo "--- PHP Version Detection (Output to STDERR) ---" >&2 # English Header
    actual_php_version=$(get_target_php_version)
    echo "----------------------------------------------" >&2 # English Footer

    if [[ "$actual_php_version" == "unknown" || -z "$actual_php_version" ]]; then
        echo "ERROR: PHP version is 'unknown'. Aborting tests." >&2 # English Error
        return 1
    fi

    image_name="sl5-preg-contentfinder-php${actual_php_version}-dev:latest"
    echo "Using PHP version $actual_php_version for tests with image $image_name." # English Info
    echo "Running tests from project '$PROJECT_ROOT'..." # English Info

    docker run --rm -v "${PROJECT_ROOT}:/app" "$image_name" php /app/vendor/bin/phpunit /app/tests/PHPUnit/Callback_Emty_Test.php
}

cleanup_docker() {
    if ! check_docker_running; then
        echo "INFO: Docker not started, cleanup not possible or not needed." >&2 # English Info
        return 1
    fi
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

# --- One-time Docker status display after system boot ---
if [ ! -f "$FLAG_FILE_PATH" ]; then
    echo "--- Docker Disk Usage (displayed once after system boot) ---" >&2 # English Header
    if show_docker_storage_status; then
        touch "$FLAG_FILE_PATH"
        echo "INFO: Docker status displayed. Will not be shown automatically again this session." >&2 # English Info
    else
        echo "INFO: Docker status could not be displayed (Docker might not be active or 'docker system df' failed)." >&2 # English Info
    fi
    echo "----------------------------------------------------------------------" >&2 # English Footer
    echo
fi

# --- Main script logic (Argument Parsing) ---
if [ $# -eq 0 ]; then
    echo "Error: No action specified." >&2 # English Error
    show_help
    exit 1
fi

action=$(echo "$1" | tr '[:upper:]' '[:lower:]')
modifier=$(echo "$2" | tr '[:upper:]' '[:lower:]')

case "$action" in
    b|build)
        build_image "$modifier"
        ;;
    t|test)
        run_tests
        ;;
    c|cleanup)
        cleanup_docker
        ;;
    bcp|"buildcacheprune")
        prune_build_cache
        ;;
    s|status)
        echo "Current Docker disk usage:" >&2 # English Info
        if ! show_docker_storage_status; then
            echo "INFO: Ensure the Docker service is running." >&2 # English Info
        fi
        echo
        echo "Tip: Use 'c' (cleanup) to free up unused resources." >&2 # English Tip
        ;;
    n|name)
        img_name=$(get_target_php_version)
        if [[ "$img_name" != "unknown" && -n "$img_name" ]]; then
            echo "sl5-preg-contentfinder-php${img_name}-dev:latest"
        else
            echo "Error determining image name (PHP version 'unknown')." >&2; exit 1 # English Error
        fi
        ;;
    p|php_version|phpversion)
        php_ver=$(get_target_php_version)
        if [[ "$php_ver" != "unknown" && -n "$php_ver" ]]; then
            echo "$php_ver"
        else
            echo "Error determining PHP version ('unknown')." >&2; exit 1 # English Error
        fi
        ;;
    h|help|-h|--help)
        show_help
        exit 0
        ;;
    *)
        echo "Error: Invalid action '$1'." >&2 # English Error
        show_help
        exit 1
        ;;
esac
