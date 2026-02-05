#!/bin/bash
# filepath: /home/stephen/Projects/Linux Know-How/Git Repositories/useful-bash-scripts/linux/get-debian.sh

# ------------------------------------------------------------------------------
# Debian Stable Netinst ISO Downloader
# ------------------------------------------------------------------------------
# This script downloads the latest Debian stable netinst ISO for amd64
# architecture and verifies its checksum.
#
# The script:
# - Retrieves the filename of the latest Debian stable netinst ISO
# - Downloads the ISO file (approximately 700MB)
# - Downloads the SHA256SUMS file
# - Verifies the ISO's integrity using the checksum
# ------------------------------------------------------------------------------

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Base URL for Debian stable ISO downloads
BASE_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd"

# Error handling function
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    # Clean up partial downloads on error
    if [ -n "$2" ] && [ -f "$2" ]; then
        echo -e "${YELLOW}Cleaning up partial download: $2${NC}"
        rm -f "$2"
    fi
    exit 1
}

# Check required dependencies
for cmd in wget grep cut sha256sum df; do
    if ! command -v $cmd &> /dev/null; then
        error_exit "$cmd is not installed. Please install it and try again."
    fi
done

echo -e "${YELLOW}Retrieving information about the latest Debian stable netinst ISO...${NC}"

# Create a temporary file for the directory listing
TEMP_HTML=$(mktemp)
wget -qO "$TEMP_HTML" "$BASE_URL/" || error_exit "Failed to retrieve directory listing" "$TEMP_HTML"

# Get the filename of the netinst ISO (specifically the standard netinst, not edu or mac)
ISO_FILENAME=$(grep -o 'debian-[0-9.]\+-amd64-netinst\.iso' "$TEMP_HTML" | 
               grep -v 'edu\|mac' |
               sort -V | tail -n1)

# Clean up the temporary file
rm -f "$TEMP_HTML"

if [ -z "$ISO_FILENAME" ]; then
    error_exit "Failed to retrieve the latest Debian netinst ISO filename."
fi

echo -e "${GREEN}Found latest Debian stable netinst ISO: ${YELLOW}$ISO_FILENAME${NC}"

# Function to verify checksum
verify_checksum() {
    local iso_file=$1
    local sums_file="SHA256SUMS"
    
    # Download SHA256SUMS file if it doesn't exist or if downloading a new ISO
    echo -e "${YELLOW}Downloading checksums file...${NC}"
    wget -q "$BASE_URL/$sums_file" -O "$sums_file" || 
        error_exit "Failed to download the $sums_file file."
    
    # Verify the checksum
    echo -e "${YELLOW}Verifying ISO integrity...${NC}"
    local iso_checksum=$(grep "$iso_file" "$sums_file" | cut -d' ' -f1)
    
    if [ -z "$iso_checksum" ]; then
        rm -f "$sums_file"
        error_exit "Could not find checksum for $iso_file in the $sums_file file."
    fi
    
    local computed_checksum=$(sha256sum "$iso_file" | cut -d' ' -f1)
    
    if [ "$iso_checksum" != "$computed_checksum" ]; then
        echo -e "${RED}Checksum verification failed!${NC}"
        echo -e "${YELLOW}Expected: $iso_checksum${NC}"
        echo -e "${YELLOW}Actual:   $computed_checksum${NC}"
        return 1
    fi
    
    return 0
}

# Check available disk space (ISO file is approximately 700MB)
REQUIRED_SPACE=800 # MB
AVAILABLE_SPACE=$(df -m . | awk 'NR==2 {print $4}')

if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    error_exit "Not enough disk space. You need at least ${REQUIRED_SPACE}MB available."
fi

# Check if the ISO already exists and has valid checksum
if [ -f "$ISO_FILENAME" ]; then
    echo -e "${YELLOW}ISO file already exists. Verifying integrity...${NC}"
    if verify_checksum "$ISO_FILENAME"; then
        echo -e "${GREEN}Existing ISO file is valid.${NC}"
        echo -e "${GREEN}Successfully verified ${YELLOW}$ISO_FILENAME${GREEN} in the current directory.${NC}"
        # Cleanup
        rm -f SHA256SUMS
        exit 0
    else
        echo -e "${YELLOW}Existing ISO file is invalid or corrupted. Redownloading...${NC}"
    fi
fi

# Download the ISO file
echo -e "${YELLOW}Downloading $ISO_FILENAME...${NC}"
wget --progress=bar:force -c "$BASE_URL/$ISO_FILENAME" -O "$ISO_FILENAME" || 
    error_exit "Failed to download the ISO file." "$ISO_FILENAME"

# Verify the downloaded ISO
if verify_checksum "$ISO_FILENAME"; then
    echo -e "${GREEN}Checksum verification passed!${NC}"
    echo -e "${GREEN}Successfully downloaded ${YELLOW}$ISO_FILENAME${GREEN} to the current directory.${NC}"
    echo -e "${GREEN}You can now use this ISO to install Debian.${NC}"
    
    # Cleanup
    rm -f SHA256SUMS
else
    error_exit "Checksum verification failed! The downloaded ISO might be corrupted." "$ISO_FILENAME"
fi
