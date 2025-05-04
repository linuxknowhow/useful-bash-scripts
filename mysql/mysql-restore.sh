#!/bin/bash
# ------------------------------------------------------------------------------
# MySQL Database Restore Script
# ------------------------------------------------------------------------------
# This script restores a MySQL database from a SQL dump file.
# 
# Usage: ./mysql-restore.sh [dump_file.sql]
#
# Features:
# - Automatically creates the database if it doesn't exist
# - Prompts before overwriting existing databases
# - Uses UTF8MB4 character set and unicode collation
# - Displays progress with timestamps
#
# Note: This script assumes MySQL credentials are configured in ~/.my.cnf
# or via environment variables.
# ------------------------------------------------------------------------------

# Color definitions
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if mysql client is installed
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}Error: MySQL client is not installed or not in PATH${NC}"
    exit 1
fi

# Check if an argument was provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No SQL dump file specified${NC}"
    echo "Usage: $0 [dump_file.sql]"
    exit 1
fi

function create_database {
    echo "$(date +%T) Creating database \"$DATABASE\"..."
    mysql -e "CREATE DATABASE \`$DATABASE\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    local result=$?
    if [[ "$result" -eq 1 ]]; then
        echo -e "${RED}$(date +%T) Error: Cannot create database! Check MySQL permissions.${NC}"
        exit 1
    else
        echo -e "${GREEN}$(date +%T) Database \"$DATABASE\" was successfully created.${NC}"
    fi
}

function delete_database {
    echo "$(date +%T) Deleting database \"$DATABASE\"..."
    mysql -e "DROP DATABASE IF EXISTS \`$DATABASE\`"
    local result=$?
    if [[ "$result" -eq 1 ]]; then
        echo -e "${RED}$(date +%T) Error: Cannot delete database! Check MySQL permissions.${NC}"
        exit 1
    else
        echo -e "${GREEN}$(date +%T) Database \"$DATABASE\" was successfully deleted.${NC}"
    fi
}

echo "$(date +%T) Processing file $1"

# Check if file exists
if ! test -f "$1"; then
    echo -e "${RED}Error: File \"$1\" does not exist.${NC}"
    exit 1
fi

# Check if file is readable
if ! test -r "$1"; then
    echo -e "${RED}Error: File \"$1\" is not readable.${NC}"
    exit 1
fi

# Extract database name from filename
DATABASE="${1%.*}"
echo "$(date +%T) Database name was identified as \"$DATABASE\"."

# Test MySQL connection
if ! mysql -e "SELECT 1" &>/dev/null; then
    echo -e "${RED}Error: Cannot connect to MySQL server. Check credentials and connection.${NC}"
    exit 1
fi

# Check if database already exists
DATABASE_EXISTS=$(mysql -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$DATABASE'");

if [ -z "$DATABASE_EXISTS" ]; then
    echo "$(date +%T) Database \"$DATABASE\" does not exist."
    create_database
else
    echo -e "${YELLOW}$(date +%T) Database \"$DATABASE\" already exists.${NC}"
    read -p "$(date +%T) Delete existing database? (y/n) " yn

    case $yn in 
            [yY] ) echo "$(date +%T) You've chosen to delete the existing database.";;
            [nN] ) echo "Exiting without changes.";
                    exit;;
            * ) echo -e "${RED}Invalid response.${NC}";
                    exit 1;;
    esac

    delete_database
    create_database
fi

echo "$(date +%T) Restoring data from $1..."

# Get file size for progress reporting
FILE_SIZE=$(du -h "$1" | cut -f1)
echo "$(date +%T) File size: $FILE_SIZE"

# Perform the actual restore
if mysql "$DATABASE" < "$1"; then
    echo -e "${GREEN}$(date +%T) Data restore completed successfully.${NC}"
else
    echo -e "${RED}$(date +%T) Error during data restore! Database may be incomplete.${NC}"
    exit 1
fi
