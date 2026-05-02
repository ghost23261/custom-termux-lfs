#!/bin/bash

# Download Slackware packages for LFS build - Fixed version
# This script downloads essential Slackware packages for our custom Termux environment

set -e

LFS="/mnt/samsung_ssd"
SOURCES="$LFS/sources"
MIRROR="https://mirrors.slackware.com/slackware/slackware64-current/slackware64"

echo "Downloading Slackware current packages..."

cd "$SOURCES"

# Function to download package with wildcard handling
download_package() {
    local category=$1
    local package_name=$2
    
    echo "Looking for $package_name in $category..."
    
    # Get the directory listing and find the package
    local package_url=$(curl -s "$MIRROR/$category/" | grep -o "$package_name-[0-9].*\.txz" | head -1)
    
    if [ -n "$package_url" ]; then
        if [ ! -f "$package_url" ]; then
            echo "Downloading $package_url..."
            wget "$MIRROR/$category/$package_url"
        else
            echo "Already have $package_url"
        fi
    else
        echo "Warning: Could not find $package_name in $category"
    fi
}

# Download essential packages
download_package "a" "bash"
download_package "a" "binutils"
download_package "a" "bzip2"
download_package "a" "coreutils"
download_package "a" "diffutils"
download_package "a" "file"
download_package "a" "findutils"
download_package "a" "gawk"
download_package "a" "grep"
download_package "a" "gzip"
download_package "a" "make"
download_package "a" "patch"
download_package "a" "sed"
download_package "a" "tar"
download_package "a" "xz"

download_package "d" "gcc"
download_package "d" "glibc"
download_package "d" "linux-headers"
download_package "d" "m4"
download_package "d" "ncurses"

download_package "l" "gmp"
download_package "l" "libffi"
download_package "l" "mpfr"
download_package "l" "openssl"
download_package "l" "zlib"

echo "Slackware packages download complete!"
echo "Next: Extract and prepare packages for LFS build"
