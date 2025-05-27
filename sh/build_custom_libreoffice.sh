#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipes fail on first error.
set -o pipefail

# --- Configuration ---
LO_SOURCE_DIR="${HOME}/libreoffice-dev/libreoffice-core"
PATCH_FILE_NAME="libreoffice-ctrl-v-unformatted.patch"
LO_GIT_REPO="https://gerrit.libreoffice.org/core"
# Parallelism for autogen internal tasks if supported. $(nproc) here is fine as it's for configure.
AUTOGEN_FLAGS="--with-lang=\"de en-US\" --without-java --disable-pdfimport --enable-release-build --without-help --with-parallelism=$(nproc)"

# NUM_CORES will be determined interactively later

# --- Helper Functions ---
log_info() {
    echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Command '$1' not found. Please install it."
        exit 1
    fi
}

get_cpu_cores() {
    local detected_cores=1 # Default to 1 if detection fails
    if command -v nproc &> /dev/null; then
        detected_cores=$(nproc)
    elif [ -f /proc/cpuinfo ]; then
        detected_cores=$(grep -c ^processor /proc/cpuinfo)
    fi
    # Ensure it's a number and at least 1
    if ! [[ "$detected_cores" =~ ^[0-9]+$ ]] || [ "$detected_cores" -lt 1 ]; then
        detected_cores=1
    fi
    echo "$detected_cores"
}

# --- Main Script ---

# 0. Check essential commands
check_command "git"
check_command "pacman"
check_command "patch"
check_command "nproc" # nproc is now more critical for recommendation

# 1. Install Dependencies (function remains the same as before)
install_dependencies() {
    log_info "Checking and installing dependencies..."
    # Critical build tools
    sudo pacman -Syu --needed --noconfirm base-devel git patch gperf nasm ccache

    # Long list of LibreOffice dependencies
    sudo pacman -Syu --needed --noconfirm \
        ant apr beanshell bluez-libs cairo clucene coin-or-mp cppunit curl \
        dbus-glib desktop-file-utils doxygen eigen enchant expat fontconfig \
        freetype2 gcc glew gmime gpgme gst-plugins-base-libs gtk3 harfbuzz-icu \
        hicolor-icon-theme hunspell icu junit krb5 lcms2 libabw libatomic_ops \
        libcdr libcmis libe-book libepubgen libetonyek libexttextcat libfreehand \
        libgl libice libjpeg-turbo liblangtag libldap libmspub libmwaw libmythes \
        libnumbertext libodfgen liborcus libpagemaker librsvg libsm libstaroffice \
        libtiff libvisio libwpd libwpg libwps libx11 libxaw libxcomposite \
        libxdamage libxext libxfixes libxinerama libxkbfile libxml2 libxrandr \
        libxrender libxslt libxt libxtst libxxf86vm mariadb-libs mdds mesa \
        openjpeg2 openssl pango perl-archive-zip poppler poppler-glib \
        postgresql-libs python python-lxml redland serf subversion unixodbc \
        vala vigra zlib
    log_info "Dependency check complete."
}


# 2. Get or Update LibreOffice Source Code (function remains the same)
get_or_update_source() {
    log_info "Getting or updating LibreOffice source code..."
    if [ ! -d "$LO_SOURCE_DIR" ]; then
        log_info "Cloning LibreOffice core repository to $LO_SOURCE_DIR..."
        mkdir -p "$(dirname "$LO_SOURCE_DIR")"
        git clone "$LO_GIT_REPO" "$LO_SOURCE_DIR"
    else
        log_info "Updating existing LibreOffice repository in $LO_SOURCE_DIR..."
        cd "$LO_SOURCE_DIR"
        if ! git diff --quiet || ! git diff --cached --quiet; then
            log_info "Stashing existing local changes..."
            git stash push -u -m "Build script auto-stash" || true
        fi
        log_info "Resetting repository to a clean state..."
        git reset --hard HEAD
        git clean -fdx
        log_info "Fetching latest changes..."
        git fetch origin
        log_info "Checking out master (or your preferred branch/tag)..."
        git checkout master # Or your desired branch/tag
        git pull origin master # Or your desired branch/tag
        cd - > /dev/null
    fi
    log_info "Source code is ready."
}

# 3. Apply Custom Patch (function remains the same)
apply_custom_patch() {
    local script_dir
    script_dir=$(dirname "$(readlink -f "$0")")
    local actual_patch_file="${script_dir}/${PATCH_FILE_NAME}"

    if [ ! -f "$actual_patch_file" ]; then
        log_error "Patch file '$actual_patch_file' not found. Please create it and place it in the script's directory."
        log_error "To create the patch: cd ${LO_SOURCE_DIR}; git diff > ${actual_patch_file}"
        exit 1
    fi

    log_info "Applying patch: $actual_patch_file"
    cd "$LO_SOURCE_DIR"
    if patch -p1 --dry-run < "$actual_patch_file"; then
        patch -p1 < "$actual_patch_file"
    else
        log_error "Patch application would fail. Please check the patch file and the repository state."
        exit 1
    fi
    cd - > /dev/null
    log_info "Patch applied successfully."
}

# 4. Configure and Build
configure_and_build() {
    log_info "Starting LibreOffice configuration and build process..."
    cd "$LO_SOURCE_DIR"

    # Determine number of cores for make
    local total_cores
    total_cores=$(get_cpu_cores)
    local suggested_cores=$total_cores

    if [ "$total_cores" -gt 4 ]; then # If more than 4 cores, suggest n-1 or n-2
        suggested_cores=$((total_cores - 1))
        # Or even more conservative for very high core counts:
        # if [ "$total_cores" -gt 8 ]; then suggested_cores=$((total_cores - 2)); fi
    elif [ "$total_cores" -le 1 ]; then # Ensure at least 1 for suggestion
        suggested_cores=1
    fi

    local user_cores
    while true; do
        read -r -p "You have ${total_cores} CPU cores. Recommended parallel jobs for 'make': ${suggested_cores}. How many to use? [${suggested_cores}]: " user_cores
        user_cores=${user_cores:-$suggested_cores} # Default to suggested if empty input

        if [[ "$user_cores" =~ ^[0-9]+$ ]] && [ "$user_cores" -ge 1 ] && [ "$user_cores" -le "$total_cores" ]; then
            if [ "$user_cores" -gt $((total_cores * 2)) ]; then # Warning for excessive jobs
                 read -r -p "Warning: Using ${user_cores} jobs on ${total_cores} cores might be excessive and slow down your system. Continue? (y/N): " confirm_excess
                 if [[ "$confirm_excess" =~ ^[Yy]$ ]]; then
                    break
                 fi
            else
                break
            fi
        else
            echo "Invalid input. Please enter a number between 1 and ${total_cores} (your total cores)."
        fi
    done
    NUM_CORES=$user_cores


    log_info "Running autogen.sh with flags: ${AUTOGEN_FLAGS}"
    # shellcheck disable=SC2086 # We want word splitting for AUTOGEN_FLAGS
    ./autogen.sh ${AUTOGEN_FLAGS}

    log_info "Will use ${NUM_CORES} parallel jobs for 'make'."
    log_info "Running make (this will take a long time)..."
    make -j"${NUM_CORES}"

    log_info "Build completed!"
    cd - > /dev/null
}

# --- Execution ---
main() {
    log_info "Custom LibreOffice Build Script started."

    install_dependencies
    get_or_update_source
    apply_custom_patch
    configure_and_build

    log_info "Custom LibreOffice build process finished successfully."
    log_info "You can try running your custom build from: ${LO_SOURCE_DIR}/instdir/program/soffice"
    log_info "Or: ${LO_SOURCE_DIR}/install/program/soffice (path may vary slightly)"
    log_info "If you want to install it system-wide, you can run 'sudo make install' from '${LO_SOURCE_DIR}'"
    log_info "(Warning: 'sudo make install' might conflict with system packages. Consider creating a Manjaro package instead.)"
}

# Run the main function
main
