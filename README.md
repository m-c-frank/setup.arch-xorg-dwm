# Arch Linux ISO Downloader and Verifier

This script automates the process of downloading the latest Arch Linux ISO, along with its checksum and signature files, and then verifies both the checksum and the signature to ensure the integrity and authenticity of the downloaded ISO.

## How it Works

The script performs the following actions:

1. **Downloads** the Arch Linux ISO, BLAKE2b checksum (`b2sums.txt`), and the PGP signature file.
2. **Verifies** the downloaded ISO against the BLAKE2b checksum.
3. **Downloads** the release signing PGP key.
4. **Verifies** the ISO's PGP signature against the downloaded key.

## Requirements

- Linux environment.
- `wget`, `b2sum`, `sq`, and `gpg` installed.

## Usage

1. Save the script in a file, e.g., `download_arch.sh`.
2. Make the script executable:
   ```
   chmod +x download_arch.sh
   ```
3. Run the script:
   ```
   ./download_arch.sh
   ```

## Script

```bash
#!/bin/bash

# Set the URL for the download
BASE_URL="https://mirror.informatik.tu-freiberg.de/arch/iso/2023.11.01"
ISO_FILE="archlinux-2023.11.01-x86_64.iso"
B2SUMS_FILE="b2sums.txt"
SIGNATURE_FILE="$ISO_FILE.sig"

# Download the ISO, checksum, and signature files
wget "$BASE_URL/$ISO_FILE"
wget "$BASE_URL/$B2SUMS_FILE"
wget "$BASE_URL/$SIGNATURE_FILE"

# Verify the BLAKE2b checksum
b2sum -c $B2SUMS_FILE

# Download the release signing key
sq wkd get pierre@archlinux.org -o release-key.pgp

# Verify the ISO signature
sq verify --signer-file release-key.pgp --detached $SIGNATURE_FILE $ISO_FILE
```

## Note

- Ensure an active internet connection.
- If verification fails at any step, do not use the downloaded ISO.

