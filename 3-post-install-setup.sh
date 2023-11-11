#!/bin/bash

# Update system
sudo pacman -Syu

# Install necessary packages
sudo pacman -S base-devel xorg xorg-xinit git sudo

# Setup user (replace 'your_username' with your desired username)
sudo useradd -m -G wheel -s /bin/bash your_username
echo "Set password for new user:"
sudo passwd your_username

# Setup sudo access
echo "%wheel ALL=(ALL) ALL" | sudo EDITOR='tee -a' visudo

# Install DWM
git clone https://git.suckless.org/dwm
cd dwm
sudo make clean install

# Create .xinitrc
echo "exec dwm" > ~/.xinitrc

