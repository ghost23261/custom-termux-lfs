#!/bin/bash

# Build LFS Base System for Custom Termux
# This script builds the basic LFS system from Slackware packages

set -e

LFS="/mnt/samsung_ssd"
LFS_ROOT="$LFS/rootfs"
LFS_TOOLS="$LFS/tools"
SOURCES="$LFS/sources"

echo "Building LFS base system..."

# Ensure we're running as lfs user
if [ "$USER" != "lfs" ]; then
    echo "This script must be run as the lfs user"
    echo "Run: su - lfs"
    exit 1
fi

# Create basic directory structure
mkdir -p "$LFS_ROOT"/{bin,boot,dev,etc,home,lib,lib64,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}
mkdir -p "$LFS_ROOT"/usr/{bin,include,lib,lib64,local,sbin,share,src}
mkdir -p "$LFS_ROOT"/usr/share/{doc,info,locale,man}
mkdir -p "$LFS_ROOT"/var/{cache,lib,local,log,mail,opt,spool,tmp}

# Create essential symlinks
ln -sv lib "$LFS_ROOT/lib64"
ln -sv /run "$LFS_ROOT/var/run"
ln -sv /proc/self/mounts "$LFS_ROOT/etc/mtab"

# Extract essential packages in order
echo "Extracting essential packages..."

# Extract bash first (essential for scripts)
cd "$LFS_ROOT"
tar -xvf "$SOURCES"/bash-*.txz --strip-components=1 -C "$LFS_ROOT/bin" bin/bash

# Extract core utilities
for pkg in coreutils findutils grep sed awk gnu tar gzip; do
    echo "Extracting $pkg..."
    tar -xvf "$SOURCES"/*${pkg}*.txz --strip-components=1 -C "$LFS_ROOT"
done

# Extract development tools
for pkg in gcc make binutils; do
    echo "Extracting $pkg..."
    tar -xvf "$SOURCES"/*${pkg}*.txz --strip-components=1 -C "$LFS_ROOT"
done

# Extract essential libraries
for pkg in glibc ncurses zlib openssl; do
    echo "Extracting $pkg libraries..."
    tar -xvf "$SOURCES"/*${pkg}*.txz --strip-components=1 -C "$LFS_ROOT"
done

# Create basic device nodes
mkdir -p "$LFS_ROOT/dev"
mknod -m 600 "$LFS_ROOT/dev/console" c 5 1
mknod -m 666 "$LFS_ROOT/dev/null" c 1 3

# Create basic configuration files
cat > "$LFS_ROOT/etc/passwd" << "EOF"
root:x:0:0:root:/root:/bin/bash
nobody:x:65534:65534:nobody:/nonexistent:/usr/bin/nologin
EOF

cat > "$LFS_ROOT/etc/group" << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
wheel:x:10:
nogroup:x:65534:
EOF

cat > "$LFS_ROOT/etc/hostname" << "EOF"
termux-lfs
EOF

echo "LFS base system build complete!"
echo "Next: Configure Termux environment"
