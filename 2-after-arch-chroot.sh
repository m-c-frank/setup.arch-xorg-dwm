#!/bin/bash

# Arch Linux Installation - Part 2

# Set time zone
read -p "Enter your time zone (e.g., Europe/Berlin): " timezone
ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
hwclock --systohc
echo "Time zone set to $timezone."

# Localization
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Network configuration
read -p "Enter hostname: " hostname
echo "$hostname" > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$hostname.localdomain\t$hostname" > /etc/hosts

# Set root password
echo "Please set the root password."
passwd

# Determine if UEFI or Legacy BIOS
if [ -d /sys/firmware/efi ]; then
    is_efi=true
else
    is_efi=false
fi

# Bootloader Installation
if [ "$is_efi" = true ]; then
    echo "UEFI system detected. Installing systemd-boot..."
    bootctl --path=/boot install
    root_part_uuid=$(blkid -s PARTUUID -o value "$root_partition")
    echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=PARTUUID=$root_part_uuid rw" > /boot/loader/entries/arch.conf
    echo -e "default arch\ntimeout 3\neditor 0" > /boot/loader/loader.conf
else
    echo "Legacy BIOS system detected. Installing GRUB..."
    pacman -S grub
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "Bootloader installed and configured."

echo "Installation part 2 complete. Reboot and log in as root."

