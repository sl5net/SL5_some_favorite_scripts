#!/bin/bash

# Set the size threshold in bytes (50KB = 50 * 1024 bytes)
SIZE_THRESHOLD=$((50 * 1024))

# Function to check if a directory is smaller than the threshold
is_directory_small() {
  local dir="$1"
  local total_size=0

  # Calculate the total size of files within the directory
  total_size=$(du -sb "$dir" | awk '{print $1}')

  # Check if the directory is smaller than the threshold
  if [[ "$total_size" -lt "$SIZE_THRESHOLD" ]]; then
    return 0  # Directory is smaller than the threshold
  else
    return 1  # Directory is larger than or equal to the threshold
  fi
}

# Function to delete the directory and its contents
delete_directory() {
  local dir="$1"

  echo "Deleting directory: $dir"
  rm -rf "$dir"
}

# Find directories and process them
find . -type d -print0 | while IFS= read -r -d $'\0' dir; do
  # Skip the current directory (.)
  if [[ "$dir" == "." ]]; then
    continue
  fi

  # Check if the directory is smaller than the threshold
  if is_directory_small "$dir"; then
    # Delete the directory
    delete_directory "$dir"
  fi
done

echo "Finished processing directories."
