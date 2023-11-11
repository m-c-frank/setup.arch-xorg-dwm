#!/bin/zsh

# Welcome Message
echo "Welcome to the Arch Linux Installation Helper!"
echo "This script will guide you through identifying, partitioning, formatting, and mounting your drive."

# List all drives
echo "Listing all drives:"
lsblk

# Checking for EFI or BIOS system
if [[ -d /sys/firmware/efi/efivars ]]; then
    echo "EFI system detected."
    is_efi=true
else
    echo "BIOS system detected."
    is_efi=false
fi

# Ask user to identify the target drive
read "target_drive?Please enter the device name of the target drive (e.g., sda, sdb): "
echo "You have selected /dev/$target_drive"

# Warning message
echo "WARNING: All data on /dev/$target_drive will be lost! Proceed with caution."

# Confirmation
read "confirmation?Are you sure you want to continue? (yes/no): "
if [[ "$confirmation" != "yes" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Partitioning Instructions
if $is_efi; then
    echo "You will now enter 'fdisk' to partition your drive for an EFI system."
    echo "Follow these steps inside fdisk:"
    echo "  1. Type 'g' to create a new empty GPT partition table."
    echo "  2. Type 'n' to add a new partition. For the EFI system partition, select defaults and set size to +550M."
    echo "  3. Type 'n' again to add your root partition. Select defaults and assign the remaining space or the size you prefer."
    echo "  4. Type 't' to change the partition type. Select partition 1 and set type to 'EFI System'."
    echo "  5. Type 'w' to write the changes and exit fdisk."
else
    echo "You will now enter 'fdisk' to partition your drive for a BIOS system."
    echo "Follow these steps inside fdisk:"
    echo "  1. Type 'o' to create a new empty DOS partition table."
    echo "  2. Type 'n' to add a new partition. Select defaults for a primary partition and assign the size you prefer."
    echo "  3. Type 'w' to write the changes and exit fdisk."
fi

# Start fdisk
echo "Starting fdisk for /dev/$target_drive"
fdisk /dev/$target_drive

# Formatting the partitions
echo "Formatting the partitions..."
if $is_efi; then
    echo "Formatting the EFI system partition as FAT32..."
    mkfs.fat -F32 /dev/${target_drive}1
    echo "Formatting the root partition as ext4..."
    mkfs.ext4 /dev/${target_drive}2
    root_partition="/dev/${target_drive}2"
    efi_partition="/dev/${target_drive}1"
else
    echo "Formatting the root partition as ext4..."
    mkfs.ext4 /dev/${target_drive}1
    root_partition="/dev/${target_drive}1"
fi

# Mount the root partition
echo "Mounting the root partition..."
mount $root_partition /mnt

# Mount the EFI partition (if EFI system)
if $is_efi; then
    echo "Mounting the EFI system partition..."
    mkdir -p /mnt/boot/EFI
    mount $efi_partition /mnt/boot/EFI
fi

# Base system installation
echo "Installing the base system..."
pacstrap /mnt base linux linux-firmware

# Generating fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# Ready to chroot
echo "You are now ready to chroot into your new system."
echo "Type 'arch-chroot /mnt' to switch into the new system environment."
echo "Installation Helper Complete!"

# End of the script

