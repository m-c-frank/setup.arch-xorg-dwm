#!/bin/bash

echo "Enter the path to the Arch ISO file:"
read -e iso_path

echo "Enter the USB device path (e.g., /dev/sdx):"
read -e usb_device

# Additional check to confirm the device selection
echo "You have selected $usb_device. Are you sure? (yes/no)"
read confirmation
if [[ $confirmation != "yes" ]]; then
    echo "Script aborted by user."
    exit 1
fi

# Unmount the device in case it is mounted
umount ${usb_device}* 2> /dev/null

# Wipe the USB drive and create a new partition table
sudo wipefs --all $usb_device
sudo parted $usb_device mklabel msdos

# Format the USB drive to FAT32
sudo parted -a optimal $usb_device mkpart primary fat32 0% 100%
sudo mkfs.fat -F32 ${usb_device}1

# Mount the USB drive to copy the script
sudo mount ${usb_device}1 /mnt

# Check if the 1-first-boot.sh script exists in the current directory
if [ -f "1-first-boot.sh" ]; then
    # Copy the script to the USB drive
    sudo cp 1-first-boot.sh /mnt/
else
    echo "1-first-boot.sh not found in the current directory."
fi

# Unmount the USB drive
sudo umount /mnt

# Create a bootable drive
sudo dd bs=4M if="$iso_path" of="$usb_device" status=progress oflag=sync
echo "USB drive is ready. You can now boot from it to install Arch Linux."

