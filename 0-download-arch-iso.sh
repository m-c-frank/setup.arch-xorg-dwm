#!/bin/bash

# Set the URL for the download
BASE_URL="https://mirror.informatik.tu-freiberg.de/arch/iso/2023.11.01"
ISO_FILE="archlinux-2023.11.01-x86_64.iso"
B2SUMS_FILE="b2sums.txt"
SIGNATURE_FILE="$ISO_FILE.sig"

# Function to check if a command exists
command_exists() {
    type "$1" &> /dev/null ;
}

# Check for wget and install if not exists
if ! command_exists wget ; then
    echo "wget not found. Installing wget..."
    sudo pacman -Sy wget
fi

# Check for b2sum and install if not exists
if ! command_exists b2sum ; then
    echo "b2sum not found. Installing b2sum..."
    sudo pacman -Sy b2sum
fi

# Check for sq and install if not exists
if ! command_exists sq ; then
    echo "sq not found. Installing sq..."
    sudo pacman -Sy sequoia-sq
fi

# Download the ISO, checksum, and signature files
if [ ! -f "$ISO_FILE" ]; then
    wget "$BASE_URL/$ISO_FILE"
else
    echo "$ISO_FILE already downloaded."
fi

if [ ! -f "$B2SUMS_FILE" ]; then
    wget "$BASE_URL/$B2SUMS_FILE"
else
    echo "$B2SUMS_FILE already downloaded."
fi

if [ ! -f "$SIGNATURE_FILE" ]; then
    wget "$BASE_URL/$SIGNATURE_FILE"
else
    echo "$SIGNATURE_FILE already downloaded."
fi

# Extract the specific checksum line for the ISO file from b2sums.txt
CHECKSUM_LINE=$(grep "$ISO_FILE" $B2SUMS_FILE)

# Write the specific checksum line to a temporary file
echo $CHECKSUM_LINE > temp_checksum.txt

# Verify the BLAKE2b checksum
b2sum -c temp_checksum.txt

# Remove the temporary checksum file
rm temp_checksum.txt

# Check if release-key.pgp exists
if [ -f "release-key.pgp" ]; then
    echo "release-key.pgp already exists. Skipping download."
else
    # Download the release signing key
    sq wkd get pierre@archlinux.org -o release-key.pgp
fi

# Verify the ISO signature
sq verify --signer-file release-key.pgp --detached $SIGNATURE_FILE $ISO_FILE

