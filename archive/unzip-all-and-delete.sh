#!/bin/bash

# ------------------------------------------------------------------------------
# unzip-all-and-delete.sh
# ------------------------------------------------------------------------------
# Extract every ZIP archive in the current directory into its own sub-directory
# and delete each archive after a successful extraction. The script is
# intentionally non-interactive so batch jobs never block waiting for user
# confirmation.
# ------------------------------------------------------------------------------

set -euo pipefail

if ! command -v unzip >/dev/null 2>&1; then
    echo "Error: 'unzip' is not installed or not in PATH." >&2
    exit 1
fi

# Makes sure that if no *.zip files exist, the for-loop just skips instead of
# literally iterating over the string "*.zip".
shopt -s nullglob

archives=( *.zip *.ZIP )

if [ ${#archives[@]} -eq 0 ]; then
    echo "No ZIP archives found in $(pwd)."
    exit 0
fi

for file in "${archives[@]}"; do
    # Strip off the .zip/.ZIP extension
    dir="${file%.[Zz][Ii][Pp]}"
    echo "Processing '$file' into directory '$dir/'..."
    mkdir -p "$dir"
    # -q: quiet, -o: overwrite existing files without prompting
    unzip -q -o "$file" -d "$dir"
    rm -f "$file"
    echo "Deleted '$file'."
done

