#!/bin/bash

# ------------------------------------------------------------------------------
# unrar-all.sh
# ------------------------------------------------------------------------------
# Extract every RAR archive in the current directory into its own sub-directory.
# The script is intentionally non-interactive so that batch jobs never block
# waiting for confirmation.
# ------------------------------------------------------------------------------

set -euo pipefail

if ! command -v unrar >/dev/null 2>&1; then
    echo "Error: 'unrar' is not installed or not in PATH." >&2
    exit 1
fi

# Makes sure that if no *.rar files exist, the for-loop just skips instead of
# literally iterating over the string "*.rar".
shopt -s nullglob

archives=( *.rar *.RAR )

if [ ${#archives[@]} -eq 0 ]; then
    echo "No RAR archives found in $(pwd)."
    exit 0
fi

for file in "${archives[@]}"; do
    # Strip off the .rar/.RAR extension
    dir="${file%.[Rr][Aa][Rr]}"
    echo "Processing '$file' into directory '$dir/'..."
    mkdir -p "$dir"
    # x: extract with full paths
    # -o+: overwrite files without prompting
    # -idq: keep output quiet (errors still surface)
    unrar x -o+ -idq "$file" "$dir/"
done
