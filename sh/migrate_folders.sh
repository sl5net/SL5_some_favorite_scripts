#!/bin/bash

# --- Configuration: German -> English Folder Pairs ---
# Add or remove pairs as needed
declare -A FOLDER_PAIRS
FOLDER_PAIRS=(
    ["Dokumente"]="Documents"
    ["Bilder"]="Pictures"
    ["Musik"]="Music"
    ["Öffentlich"]="Public"
    ["Vorlagen"]="Templates"
    ["Schreibtisch"]="Desktop"
)
# --- End Configuration ---

echo "Starting migration from German to English user folder names..."
echo "Will copy contents and prepare for symlinking."
echo "IMPORTANT: Older files in the English folder *will be overwritten* if a newer version exists in the German folder."
echo "No files will be deleted by this script."
echo "--------------------------------------------------"

PROCESSED_GERMAN_FOLDERS=()
SYMLINK_COMMANDS=()

# Ensure we are working relative to the user's home directory
cd "$HOME" || exit 1

for german_name in "${!FOLDER_PAIRS[@]}"; do
    english_name="${FOLDER_PAIRS[$german_name]}"
    german_dir="$HOME/$german_name"
    english_dir="$HOME/$english_name"

    echo -n "Processing '$german_name' -> '$english_name': "

    # --- NEW CHECK: Prevent processing if names are identical ---
    if [ "$german_dir" == "$english_dir" ]; then
        echo "  Source ('$german_name') and Destination ('$english_name') names are the same. Skipping this pair entirely."
        echo "--------------------------------------------------"
        continue # Move to the next pair in the loop
    fi
    # --- End NEW CHECK ---

    # Check if the German source directory exists and is actually a directory
    if [ -d "$german_dir" ] && [ ! -L "$german_dir" ]; then
        echo "" # Newline after the "Processing..." message
        echo "  Source '$german_dir' found."

        # Ensure the English target directory exists
        if [ ! -d "$english_dir" ]; then
            echo "  Destination '$english_dir' not found. Creating..."
            mkdir -p "$english_dir"
            if [ $? -ne 0 ]; then
                echo "  ERROR: Failed to create '$english_dir'. Skipping this pair."
                echo "--------------------------------------------------"
                continue
            fi
        else
             echo "  Destination '$english_dir' already exists."
        fi

        # Copy/Merge contents using rsync
        # -a: archive mode (recursive, preserves permissions, times, symlinks, etc.)
        # -u: update mode (skip files that are newer in the destination)
        # -v: verbose (show files being transferred)
        # --progress: show progress during transfer
        # Source directory needs trailing slash to copy *contents*
        echo "  Copying contents from '$german_dir/' to '$english_dir/' (updating older files)..."
        rsync -auv --progress "$german_dir/" "$english_dir/"

        if [ $? -eq 0 ]; then
            echo "  Copy/Merge for '$german_name' completed successfully."
            PROCESSED_GERMAN_FOLDERS+=("$german_dir")
            # Prepare the command to create the symlink later
            SYMLINK_COMMANDS+=("ln -sfn \"$english_dir\" \"$german_dir\"")
        else
            echo "  ERROR: rsync command failed for '$german_name'. Please check output above."
        fi
    elif [ -L "$german_dir" ]; then
         echo "Already a symlink. Skipping."
    else
        echo "Source '$german_dir' not found or not a directory. Skipping."
    fi
    echo "--------------------------------------------------"
done

echo "Script finished."
echo ""

if [ ${#PROCESSED_GERMAN_FOLDERS[@]} -gt 0 ]; then
    echo "=== IMPORTANT MANUAL STEPS REQUIRED ==="
    echo "1. PLEASE VERIFY that the contents from the German folders listed below have been correctly copied to their English counterparts."
    echo ""
    echo "   Processed German folders (check their contents have been merged):"
    for dir in "${PROCESSED_GERMAN_FOLDERS[@]}"; do
        echo "     - $dir"
    done
    echo ""
    echo "2. If everything looks correct, MANUALLY DELETE the original German folders."
    echo "   Example commands (USE WITH CAUTION! Ensure data is safe first!):"
    for dir in "${PROCESSED_GERMAN_FOLDERS[@]}"; do
        echo "     rm -rf \"$dir\""
    done
    echo ""
    echo "3. AFTER you have verified the copy AND deleted the German folders, run the following commands"
    echo "   in your terminal to create symbolic links for compatibility (optional but recommended):"
    for cmd in "${SYMLINK_COMMANDS[@]}"; do
        echo "     $cmd"
    done
    echo ""
    echo "4. Consider updating your system's default directory settings:"
    echo "   Run: LANG=C xdg-user-dirs-update --force"
    echo "   (This tells applications the standard English names are now the default)"

else
    echo "No German folders matching the configuration were found or processed."
    echo "You might want to check the FOLDER_PAIRS configuration at the top of the script."
fi

echo "========================================="

# Go back to original directory if needed (though unlikely necessary here)
# cd - > /dev/null
