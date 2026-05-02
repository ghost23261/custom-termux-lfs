#!/bin/bash

# Download Slackware packages for LFS build
# This script downloads essential Slackware packages for our custom Termux environment

set -e

LFS="/mnt/samsung_ssd"
SOURCES="$LFS/sources"
SLACKWARE_VERSION="current"
MIRROR="https://mirrors.slackware.com/slackware/slackware64-$SLACKWARE_VERSION/slackware64"

echo "Downloading Slackware $SLACKWARE_VERSION packages..."

# Essential packages for LFS build (using current versions)
PACKAGES=(
    "a/bash-*.txz"
    "a/binutils-*.txz"
    "a/bzip2-*.txz"
    "a/coreutils-*.txz"
    "a/diffutils-*.txz"
    "a/file-*.txz"
    "a/findutils-*.txz"
    "a/gawk-*.txz"
    "a/grep-*.txz"
    "a/gzip-*.txz"
    "a/make-*.txz"
    "a/patch-*.txz"
    "a/sed-*.txz"
    "a/tar-*.txz"
    "a/xz-*.txz"
    "d/gcc-*.txz"
    "d/glibc-*.txz"
    "d/linux-headers-*.txz"
    "d/m4-*.txz"
    "d/ncurses-*.txz"
    "l/gmp-*.txz"
    "l/libffi-*.txz"
    "l/mpfr-*.txz"
    "l/openssl-*.txz"
    "l/zlib-*.txz"
)

cd "$SOURCES"

# Download packages
for package in "${PACKAGES[@]}"; do
    if [ ! -f "$(basename "$package")" ]; then
        echo "Downloading $package..."
        wget "$MIRROR/$package"
    else
        echo "Already have $(basename "$package")"
    fi
done

echo "Slackware packages download complete!"
echo "Next: Extract and prepare packages for LFS build"
