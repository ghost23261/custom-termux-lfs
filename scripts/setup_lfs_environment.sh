#!/bin/bash

# LFS Slackware Linux Setup Script for Custom Termux APK
# This script sets up the Linux From Scratch environment

set -e

LFS="/mnt/samsung_ssd"
LFS_TGT="x86_64-lfs-linux-gnu"
LFS_ROOT="$LFS/rootfs"
LFS_TOOLS="$LFS/tools"
LFS_SOURCES="$LFS/sources"

echo "Setting up LFS environment on Samsung SSD..."

# Create necessary directories
mkdir -p "$LFS_ROOT"
mkdir -p "$LFS_TOOLS"
mkdir -p "$LFS_SOURCES"
mkdir -p "$LFS/build_tools"

# Set permissions
chmod -v a+wt "$LFS_SOURCES"
chmod -v a+wt "$LFS_TOOLS"

# Create LFS user if it doesn't exist
if ! id "lfs" &>/dev/null; then
    groupadd lfs
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    echo "Created lfs user"
fi

# Set ownership
chown -v lfs "$LFS_TOOLS"
chown -v lfs "$LFS_SOURCES"

# Create lfs user environment setup
cat > /home/lfs/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > /home/lfs/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/samsung_ssd
LC_ALL=POSIX
LFS_TGT=x86_64-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF

chown -v lfs:lfs /home/lfs/.bash_profile
chown -v lfs:lfs /home/lfs/.bashrc

echo "LFS environment setup complete!"
echo "Next: Switch to lfs user and download Slackware packages"
