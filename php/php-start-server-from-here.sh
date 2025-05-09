#!/bin/bash

#################################################
# PHP Start Server From Here
#
# This script starts a PHP development server from
# the current directory on port 8000
#
# Usage: ./php-start-server-from-here.sh [port]
#################################################

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Error handling function
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    error_exit "PHP is not installed. Please install PHP before running this script."
fi

# Get the port from arguments or use default
PORT=${1:-8000}
HOST="127.0.0.1"

# Validate that port is a number
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    error_exit "Port must be a number. Usage: ./php-start-server-from-here.sh [port]"
fi

# Check if port is already in use
if netstat -tuln | grep -q ":$PORT "; then
    error_exit "Port $PORT is already in use. Try a different port."
fi

# Get current directory
CURRENT_DIR=$(pwd)
echo -e "${GREEN}Starting PHP server in directory: ${YELLOW}$CURRENT_DIR${NC}"

# Start the PHP server
echo -e "${GREEN}Starting PHP development server at ${YELLOW}http://$HOST:$PORT${NC}"
echo -e "${GREEN}Press Ctrl+C to stop the server${NC}"
echo ""

php -S "$HOST:$PORT" || error_exit "Failed to start PHP server"

# Note: The script will not reach here unless the server is terminated
echo -e "${GREEN}Server stopped${NC}"
