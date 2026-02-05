#!/bin/bash
# filepath: /home/stephen/Projects/Linux Know-How/Git Repositories/useful-bash-scripts/linux/write-iso-to-flash-drive.sh

# ------------------------------------------------------------------------------
# ISO to USB Flash Drive Writer
# ------------------------------------------------------------------------------
# This script safely writes an ISO file to a USB flash drive.
# 
# Features:
# - Verifies that the target device is actually a USB drive
# - Confirms with the user before writing
# - Shows progress during writing
# - Syncs filesystem to ensure all data is written
# 
# Usage: 
#   ./write-iso-to-flash-drive.sh [iso-file] [device]
#
# Example:
#   ./write-iso-to-flash-drive.sh debian-12.11.0-amd64-netinst.iso /dev/sdb
# ------------------------------------------------------------------------------

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling function
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Function to check if script is run as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error_exit "This script must be run as root (use sudo)"
    fi
}

# Function to check if a device is a USB drive
is_usb_drive() {
    local device=$1
    local dev_name=$(basename "$device")
    
    # Check if the device exists
    if [ ! -b "$device" ]; then
        return 1
    fi
    
    # Check if it's removable (most USB drives are removable)
    if [ ! -f "/sys/block/$dev_name/removable" ] || [ "$(cat "/sys/block/$dev_name/removable")" != "1" ]; then
        return 1
    fi
    
    # Additional check: Try to find if it's a USB device
    if [ -d "/sys/block/$dev_name/device/driver" ]; then
        local driver=$(readlink "/sys/block/$dev_name/device/driver")
        driver=$(basename "$driver")
        if [[ "$driver" == *"usb"* ]]; then
            return 0
        fi
    fi
    
    # Check if it's in the USB bus
    if [ -d "/sys/block/$dev_name/device" ]; then
        if udevadm info --query=all --name="$device" | grep -q "ID_BUS=usb"; then
            return 0
        fi
    fi
    
    return 1
}

# Function to display device info
show_device_info() {
    local device=$1
    local dev_name=$(basename "$device")
    
    echo -e "${BLUE}Device information:${NC}"
    echo -e "  ${YELLOW}Device:${NC} $device"
    
    # Get device size
    local size=$(lsblk -b -d -n -o SIZE "$device" 2>/dev/null)
    if [ -n "$size" ]; then
        # Convert to human readable format
        local size_hr=$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null)
        echo -e "  ${YELLOW}Size:${NC} $size_hr"
    fi
    
    # Get device model if available
    local model=$(lsblk -d -n -o MODEL "$device" 2>/dev/null)
    if [ -n "$model" ]; then
        echo -e "  ${YELLOW}Model:${NC} $model"
    fi
    
    # Get mounted partitions if any
    local mounted_parts=$(lsblk -n -o MOUNTPOINT "$device" | grep -v "^$" 2>/dev/null)
    if [ -n "$mounted_parts" ]; then
        echo -e "  ${RED}WARNING: Device has mounted partitions:${NC}"
        echo "$mounted_parts" | sed 's/^/    /'
    fi
}

# Main script starts here
check_root

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${BLUE}Usage:${NC} $0 <iso-file> <device>"
    echo -e "${BLUE}Example:${NC} $0 debian-12.11.0-amd64-netinst.iso /dev/sdb"
    exit 1
fi

ISO_FILE="$1"
DEVICE="$2"

# Validate ISO file existence
if [ ! -f "$ISO_FILE" ]; then
    error_exit "ISO file not found: $ISO_FILE"
fi

# Make sure the ISO file has .iso extension
if [[ "$ISO_FILE" != *.iso ]]; then
    echo -e "${YELLOW}Warning: The file '$ISO_FILE' doesn't have an .iso extension.${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if device exists and is a block device
if [ ! -b "$DEVICE" ]; then
    error_exit "Device not found or not a block device: $DEVICE"
fi

# Check if device is a USB drive
if ! is_usb_drive "$DEVICE"; then
    echo -e "${RED}WARNING: $DEVICE does not appear to be a USB drive!${NC}"
    echo -e "${RED}Writing to non-USB devices can lead to catastrophic data loss.${NC}"
    echo
    read -p "Are you ABSOLUTELY SURE you want to continue? (Type 'YES' in uppercase): " confirm
    if [ "$confirm" != "YES" ]; then
        echo "Operation cancelled."
        exit 1
    fi
else
    echo -e "${GREEN}$DEVICE is confirmed as a USB drive.${NC}"
fi

# Show device info
show_device_info "$DEVICE"

# Unmount any mounted partitions from the device
mounted_parts=$(lsblk -n -o MOUNTPOINT "$DEVICE"* 2>/dev/null | grep -v "^$")
if [ -n "$mounted_parts" ]; then
    echo -e "${YELLOW}Unmounting partitions from $DEVICE...${NC}"
    for part in $(lsblk -n -o NAME "$DEVICE" | grep -v "^$(basename "$DEVICE")$"); do
        umount "/dev/$part" 2>/dev/null
    done
fi

# Final warning and confirmation
echo
echo -e "${RED}WARNING: All data on $DEVICE will be DESTROYED!${NC}"
echo -e "${YELLOW}ISO file:${NC} $ISO_FILE ($(du -h "$ISO_FILE" | cut -f1))"
echo -e "${YELLOW}Target device:${NC} $DEVICE"
echo
read -p "Continue with writing? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

echo -e "${YELLOW}Writing ISO to device. This may take several minutes...${NC}"

# Use dd with progress to write the ISO
if dd if="$ISO_FILE" of="$DEVICE" bs=4M status=progress conv=fsync; then
    # Ensure all data is written
    sync
    echo -e "${GREEN}ISO successfully written to $DEVICE${NC}"
    echo -e "${GREEN}It is now safe to eject the device.${NC}"
else
    error_exit "Failed to write ISO to device. Check error message above."
fi

exit 0
