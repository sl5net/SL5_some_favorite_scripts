#!/usr/bin/env bash

# chmod +x build_custom_libreoffice.sh
# ./build_custom_libreoffice.sh


# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipes fail on first error.
set -o pipefail

# --- Configuration ---
# Directory where LibreOffice source will be cloned/updated
LO_SOURCE_DIR="${HOME}/libreoffice-dev/libreoffice-core"
# Name of your patch file (expected to be in the same directory as this script, or provide full path)
PATCH_FILE_NAME="libreoffice-ctrl-v-unformatted.patch"
# Git repository URL
LO_GIT_REPO="https://gerrit.libreoffice.org/core"
# Flags for autogen.sh
AUTOGEN_FLAGS="--with-lang=\"de en-US\" --without-java --disable-pdfimport --enable-release-build --without-help --with-parallelism=$(nproc)"
# Number of CPU cores for 'make'
NUM_CORES=$(nproc)

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

# --- Main Script ---

# 0. Check essential commands
check_command "git"
check_command "pacman"
check_command "patch"

# 1. Install Dependencies
install_dependencies() {
    log_info "Checking and installing dependencies..."
    # Critical build tools
    sudo pacman -Syu --needed --noconfirm base-devel git patch gperf nasm ccache

    # Long list of LibreOffice dependencies (adapt if you have a more precise list)
    # This list is representative from previous discussions and common LO build needs on Arch/Manjaro.
    # It's often best to refer to the official LibreOffice wiki for the most current list.
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

# 2. Get or Update LibreOffice Source Code
get_or_update_source() {
    log_info "Getting or updating LibreOffice source code..."
    if [ ! -d "$LO_SOURCE_DIR" ]; then
        log_info "Cloning LibreOffice core repository to $LO_SOURCE_DIR..."
        mkdir -p "$(dirname "$LO_SOURCE_DIR")"
        git clone "$LO_GIT_REPO" "$LO_SOURCE_DIR"
    else
        log_info "Updating existing LibreOffice repository in $LO_SOURCE_DIR..."
        cd "$LO_SOURCE_DIR"
        # Stash any local changes, clean thoroughly, then pull
        # This ensures a clean state before patching and building
        if ! git diff --quiet || ! git diff --cached --quiet; then
            log_info "Stashing existing local changes..."
            git stash push -u -m "Build script auto-stash" || true # Allow if nothing to stash
        fi
        log_info "Resetting repository to a clean state..."
        git reset --hard HEAD # Discard any uncommitted changes to tracked files
        git clean -fdx       # Remove untracked files and directories, including those in .gitignore
        log_info "Fetching latest changes..."
        git fetch origin
        log_info "Checking out master (or your preferred branch/tag)..."
        # You might want to checkout a specific stable tag here instead of master for more stability
        # For example: git checkout libreoffice-7.6.4.1
        git checkout master # Or your desired branch/tag
        git pull origin master # Or your desired branch/tag
        cd - > /dev/null # Go back to previous directory
    fi
    log_info "Source code is ready."
}

# 3. Apply Custom Patch
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
    # Test patch application first (dry-run)
    if patch -p1 --dry-run < "$actual_patch_file"; then
        patch -p1 < "$actual_patch_file"
    else
        log_error "Patch application would fail. Please check the patch file and the repository state."
        log_info "It's possible the patch is already applied or conflicts with recent changes."
        log_info "You might need to regenerate the patch against the current source."
        # Optionally, try to reverse apply if it seems already applied, then re-apply
        # Or just exit with an error, which is safer.
        exit 1
    fi
    cd - > /dev/null
    log_info "Patch applied successfully."
}

# 4. Configure and Build
configure_and_build() {
    log_info "Starting LibreOffice configuration and build process..."
    cd "$LO_SOURCE_DIR"

    log_info "Running autogen.sh with flags: ${AUTOGEN_FLAGS}"
    # shellcheck disable=SC2086 # We want word splitting for AUTOGEN_FLAGS
    ./autogen.sh ${AUTOGEN_FLAGS}

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
