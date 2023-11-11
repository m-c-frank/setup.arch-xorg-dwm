#!/bin/bash

# Arch Linux Installation - Part 1

# Update the system clock
timedatectl set-ntp true
echo "System clock updated."

# List available disks
echo "Available disks:"
lsblk

# Ask for the root partition
read -p "Enter the root partition (e.g., /dev/sda2): " root_partition
while [[ ! -b "$root_partition" ]]; do
    echo "Partition does not exist. Please try again."
    read -p "Enter the root partition (e.g., /dev/sda2): " root_partition
done

# Ask for the EFI partition
read -p "Enter the EFI partition (e.g., /dev/sda1): " efi_partition
while [[ ! -b "$efi_partition" ]]; do
    echo "Partition does not exist. Please try again."
    read -p "Enter the EFI partition (e.g., /dev/sda1): " efi_partition
done

# Mount the partitions
echo "Mounting $root_partition to /mnt..."
mount "$root_partition" /mnt
mkdir -p /mnt/boot
echo "Mounting $efi_partition to /mnt/boot..."
mount "$efi_partition" /mnt/boot

# Install essential packages
echo "Installing essential packages..."
pacstrap /mnt base linux linux-firmware

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
echo "fstab generated."

echo "Base installation complete. Please run the second script after arch-chroot."

curl -LO https://raw.githubusercontent.com/mcfrank/setup.arch-xorg-dwm/main/2-after-arch-chroot

mv 2-after-arch-chroot.sh /mnt/minimalinstall

echo "run arch-chroot /mnt
