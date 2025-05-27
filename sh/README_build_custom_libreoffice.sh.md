# Custom LibreOffice Build Script for Manjaro/Arch Linux

This script automates the process of downloading, patching, configuring, and compiling LibreOffice from source on Manjaro Linux (or other Arch-based distributions). It's designed to apply a custom patch to change the default `Ctrl+V` behavior to "Paste Unformatted Text".

## Features

*   **Automated Dependency Installation:** Installs necessary build tools and LibreOffice dependencies using `pacman`.
*   **Source Code Management:**
    *   Clones the LibreOffice `core` repository if it doesn't exist.
    *   Updates an existing repository by stashing local changes, cleaning the workspace, and pulling the latest from `master` (or a configured branch/tag).
*   **Custom Patch Application:** Applies a user-provided `.patch` file.
*   **Interactive Parallel Job Selection:** Detects available CPU cores, suggests an optimal number for compilation, and allows the user to confirm or specify the number of parallel `make` jobs.
*   **Configurable Build:** Uses `autogen.sh` with common flags for a release build (customizable).
*   **Logging:** Provides informative output with timestamps.
*   **`ccache` Support:** Installs `ccache` and the build process will utilize it if `ccache` is correctly configured in your system's `PATH` (e.g., `export PATH="/usr/lib/ccache/bin:$PATH"` in your shell profile). This significantly speeds up subsequent rebuilds.

## Prerequisites

1.  **Manjaro/Arch Linux:** This script is tailored for `pacman`-based systems.
2.  **Sudo Access:** Needed to install dependencies.
3.  **Git:** For cloning and managing the source code.
4.  **Patch Utility:** For applying the custom patch.
5.  **Sufficient Disk Space:** LibreOffice source code and build artifacts require a significant amount of disk space (tens of gigabytes).
6.  **Time:** The initial full compilation will take a considerable amount of time (potentially several hours depending on your hardware).

## Setup

1.  **Clone this Repository (or download the files):**
    If this script is part of a Git repository:
    ```bash
    git clone repository
    cd repository
    ```
    Otherwise, download `build_custom_libreoffice.sh` and your patch file into the same directory.

2.  **Create Your Patch File:**
    This script expects a patch file that modifies LibreOffice's source code to change the `Ctrl+V` behavior.
    *   Manually edit the necessary `.xcu` files in a clone of the `libreoffice-core` repository (typically under `officecfg/registry/data/org/openoffice/Office/Accelerators/`).
    *   Change occurrences of `.uno:Paste` associated with `Ctrl+V` (often represented as `V_MOD1`) to `.uno:PasteUnformatted`.
    *   Once your modifications are made and you are in the root of your `libreoffice-core` source directory, generate the patch file:
        ```bash
        git diff > libreoffice-ctrl-v-unformatted.patch
        ```
    *   Place this `libreoffice-ctrl-v-unformatted.patch` file in the **same directory** as the `build_custom_libreoffice.sh` script.

3.  **Review Script Configuration (Optional):**
    Open `build_custom_libreoffice.sh` in a text editor. At the top, you can customize:
    *   `LO_SOURCE_DIR`: Where the LibreOffice source code will be cloned/stored (default: `~/libreoffice-dev/libreoffice-core`).
    *   `PATCH_FILE_NAME`: The name of your patch file (default: `libreoffice-ctrl-v-unformatted.patch`).
    *   `AUTOGEN_FLAGS`: Flags passed to `./autogen.sh` for configuring the build.

4.  **Make the Build Script Executable:**
    ```bash
    chmod +x build_custom_libreoffice.sh
    ```

## Usage

1.  **Run the Script:**
    Navigate to the directory containing `build_custom_libreoffice.sh` and your patch file, then execute:
    ```bash
    ./build_custom_libreoffice.sh
    ```

2.  **Follow Prompts:**
    *   The script will ask for your `sudo` password to install dependencies.
    *   It will then prompt you to confirm or specify the number of parallel jobs (`make -jN`) to use for compilation, based on your detected CPU cores.

3.  **Wait:**
    The cloning/updating, patching, configuring, and especially the compiling steps will take time.

4.  **After Successful Compilation:**
    The script will output messages indicating success. You can then run your custom LibreOffice build. The executable is typically found at:
    *   `[LO_SOURCE_DIR]/instdir/program/soffice`
    *   or `[LO_SOURCE_DIR]/install/program/soffice`

    For example, if `LO_SOURCE_DIR` is `~/libreoffice-dev/libreoffice-core`:
    ```bash
    ~/libreoffice-dev/libreoffice-core/instdir/program/soffice
    ```

## Updating and Rebuilding

To build a newer version of LibreOffice with your patch:

1.  Simply re-run the script: `./build_custom_libreoffice.sh`
2.  The script will:
    *   Update the local LibreOffice source code repository.
    *   Attempt to re-apply your patch.
        *   **Important:** If the LibreOffice source code has changed significantly in the areas your patch touches, the patch might fail to apply. In this case, you will need to:
            1.  Manually update your patch:
                *   Go into the `LO_SOURCE_DIR`.
                *   Resolve the conflicts or manually re-do your changes against the new source.
                *   Re-generate your patch file (`git diff > ../libreoffice-ctrl-v-unformatted.patch` assuming your script and patch are one level up).
            2.  Re-run the build script.
    *   Recompile LibreOffice.

## Troubleshooting

*   **Dependency Errors:** If `./autogen.sh` fails due to missing dependencies not covered by the script, note the missing package and install it manually using `sudo pacman -S <package-name>`. Then, re-run the build script.
*   **Patch Application Fails:** As mentioned above, this usually means your patch is outdated relative to the current LibreOffice source. You'll need to update the patch.
*   **Build Failures (`make` errors):** These can be complex. The error messages from `make` are key. They might indicate issues with the source code, toolchain problems, or insufficient system resources (though less common with this script's setup). Searching for the specific error message online with "LibreOffice build" can often provide clues.
*   **`ccache` Setup:** For `ccache` to be effective, ensure `/usr/lib/ccache/bin` is at the beginning of your `PATH` environment variable. You can add `export PATH="/usr/lib/ccache/bin:$PATH"` to your `~/.bashrc`, `~/.zshrc`, or other shell profile file.

## Disclaimer

Building large projects like LibreOffice from source can be complex and time-consuming. This script aims to simplify the process but may require adjustments based on changes in LibreOffice's build system or dependencies. Always refer to the official LibreOffice developer documentation for the most authoritative build instructions.

## Contributing to this Script

If you have improvements or bug fixes for this build script, feel free make your changes and maybe let me know. ty.



