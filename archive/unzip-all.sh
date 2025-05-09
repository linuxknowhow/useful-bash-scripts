#!/bin/bash

# Makes sure that if no *.zip files exist, the for‐loop just skips instead of literally iterating over *.zip.
shopt -s nullglob

for file in *.zip *.ZIP; do
    # Strip off the .zip extension
    dir="${file%.zip}"
    echo "Processing '$file' into directory '$dir/'…"
    mkdir -p "$dir"
    # -q and -o means be quite and overwrite.
    # I don't care if it's going to overwrite files, most likely a duplicate
    # I don't want any scripts to get stuck because of interactivity
    unzip -q -o "$file" -d "$dir"
done

