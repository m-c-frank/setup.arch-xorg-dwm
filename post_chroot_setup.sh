#!/bin/bash

# Timezone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

# Localization
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Network configuration
echo "myhostname" > /etc/hostname
{
    echo "127.0.0.1   localhost"
    echo "::1         localhost"
    echo "127.0.1.1   myhostname.localdomain myhostname"
} >> /etc/hosts

# Set root password
echo "Set root password:"
passwd

# Install and configure bootloader (for UEFI systems)
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Create a new user
useradd -m -G wheel -s /bin/bash username
echo "Set password for new user 'username':"
passwd username

# Install sudo and give wheel group sudo privileges
pacman -S sudo --noconfirm
sed -i '/%wheel ALL=(ALL) ALL/s/^# //g' /etc/sudoers

