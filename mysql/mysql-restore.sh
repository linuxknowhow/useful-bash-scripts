#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

function create_database {
    mysql -e "CREATE DATABASE \`$DATABASE\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    local result=$?
    if [[ "$result" -eq 1 ]]; then
        echo -e "${RED}$(date +%T) Error: cannot create database!${NC}"
        exit 1
    else
        echo "$(date +%T) Database \"$DATABASE\" was successfully created."
    fi
}

function delete_database {
    mysql -e "DROP DATABASE IF EXISTS \`$DATABASE\`"
    local result=$?
    if [[ "$result" -eq 1 ]]; then
        echo -e "${RED}$(date +%T) Error: cannot delete database!${NC}"
        exit 1
    else
        echo "$(date +%T) Database \"$DATABASE\" was successfully deleted."
    fi
}

echo "$(date +%T) Processing file $1"

if test -f "$1"; then
    DATABASE="${1%.*}"
    echo "$(date +%T) Database name was identified as \"$DATABASE\"".

    DATABASE_EXISTS=$(mysql -s -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$DATABASE'");

    if [ -z "$DATABASE_EXISTS" ]; then
        echo "$(date +%T) Database \"$DATABASE\" does not exist."
        create_database
    else
        read -p "$(date +%T) Database \"$DATABASE\" already exists. Delete it? (y/n) " yn

        case $yn in 
                [yY] ) echo "$(date +%T) You've chosen to delete the existing database.";;
                [nN] ) echo Exiting.;
                        exit;;
                * ) echo Invalid response.;
                        exit 1;;
        esac

        delete_database
        create_database
    fi

    echo "$(date +%T) Restoring data..."

    mysql "$DATABASE" < $1

    echo "$(date +%T) Data restore completed."
else 
    echo "File \"$1\" does not exist."

    exit 1
fi