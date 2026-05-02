#!/bin/bash

# Simple Slackware package downloader
# Download essential packages directly

set -e

LFS="/mnt/samsung_ssd"
SOURCES="$LFS/sources"

echo "Downloading essential packages using wget..."

cd "$SOURCES"

# Download essential packages directly
PACKAGES=(
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/a/bash-5.3.009-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/a/coreutils-9.5-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/a/grep-3.11-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/a/sed-4.9-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/a/tar-1.35-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/a/make-4.4.1-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/a/findutils-4.9.0-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/a/gzip-1.13-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/a/xz-5.4.6-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/d/gcc-14.2.0-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/d/glibc-2.42-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/d/ncurses-6.5-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/l/zlib-1.3.1-x86_64-1.txz"
    "https://mirrors.slackware.com/slackware/slackware64-current/slackware64/l/openssl-3.3.2-x86_64-1.txz"
)

for package_url in "${PACKAGES[@]}"; do
    package_name=$(basename "$package_url")
    if [ ! -f "$package_name" ]; then
        echo "Downloading $package_name..."
        wget "$package_url"
    else
        echo "Already have $package_name"
    fi
done

echo "Package download complete!"
