#!/bin/bash

# Script to download the latest version of phpMyAdmin

# Check for required tools
for cmd in curl wget; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required but not installed. Please install it and try again."
        exit 1
    fi
done

# URL for the latest phpMyAdmin
URL="https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz"

echo "Getting information about the latest phpMyAdmin version..."

# Get the redirect URL to determine actual filename
REDIRECT_URL=$(curl -s -L -I -o /dev/null -w '%{url_effective}' "$URL")

if [ -z "$REDIRECT_URL" ]; then
    echo "Error: Failed to get redirect URL. Check your internet connection."
    exit 1
fi

# Extract filename from the redirect URL
FILENAME=$(basename "$REDIRECT_URL")
echo "Latest version: $FILENAME"

# Check if the file already exists
if [ -f "$FILENAME" ]; then
    echo "File $FILENAME already exists. Skipping download."
else
    echo "Downloading $FILENAME..."
    wget -O "$FILENAME" "$URL"
    
    if [ $? -eq 0 ]; then
        echo "Download complete!"
    else
        echo "Download failed!"
        exit 1
    fi
fi

echo "Done! Latest phpMyAdmin is available as: $FILENAME"