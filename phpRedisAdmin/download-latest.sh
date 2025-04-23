#!/bin/bash

# Script to download or update phpRedisAdmin from GitHub

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo "Error: git is required but not installed. Please install it and try again."
    exit 1
fi

# Repository URL and target directory
REPO_URL="https://github.com/erikdubbelboer/phpRedisAdmin.git"
TARGET_DIR="phpRedisAdmin"

# Check if the directory already exists
if [ -d "$TARGET_DIR" ]; then
    echo "phpRedisAdmin is already installed. Updating to the latest version..."
    
    # Change to the directory
    cd "$TARGET_DIR" || exit 1
    
    # Check if it's actually a git repository
    if [ ! -d ".git" ]; then
        echo "Error: $TARGET_DIR exists but is not a git repository."
        exit 1
    fi
    
    # Fetch the latest changes
    echo "Fetching latest changes..."
    git fetch
    
    # Get current branch
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
    
    # Pull the latest changes
    echo "Pulling latest changes from $CURRENT_BRANCH branch..."
    git pull origin "$CURRENT_BRANCH"
    
    if [ $? -eq 0 ]; then
        echo "Successfully updated phpRedisAdmin to the latest version."
    else
        echo "Error: Failed to update phpRedisAdmin."
        exit 1
    fi
else
    echo "phpRedisAdmin is not installed. Cloning the repository..."
    
    # Clone the repository
    git clone "$REPO_URL" "$TARGET_DIR"
    
    if [ $? -eq 0 ]; then
        echo "Successfully cloned phpRedisAdmin."
        
        # Initialize submodules if any
        cd "$TARGET_DIR" || exit 1
        git submodule update --init --recursive
        
        echo "Successfully initialized phpRedisAdmin."
    else
        echo "Error: Failed to clone phpRedisAdmin."
        exit 1
    fi
fi

echo "Done! phpRedisAdmin is now available in: $TARGET_DIR"