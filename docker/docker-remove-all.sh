#!/bin/bash

# ------------------------------------------------------------------------------
# Docker Complete Cleanup Script
# ------------------------------------------------------------------------------
# This script stops all running Docker containers and then performs a complete
# system prune, removing:
# - All stopped containers
# - All networks not used by at least one container
# - All dangling and unused images
# - All build cache
# ------------------------------------------------------------------------------

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

echo "Stopping all running Docker containers..."
running_containers=$(docker ps -q)

if [ -n "$running_containers" ]; then
    if ! docker stop $running_containers; then
        echo "Warning: Failed to stop some containers"
    else
        echo "Successfully stopped all running containers"
    fi
else
    echo "No running containers found"
fi

echo "Performing complete Docker system cleanup..."
if ! docker system prune -a -f; then
    echo "Error: Docker system prune failed"
    exit 1
fi

echo "Docker cleanup completed successfully"
