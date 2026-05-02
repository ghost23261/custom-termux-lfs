#!/bin/bash

# Setup Termux Build Environment
# This script configures the environment for building custom Termux APK

set -e

LFS="/mnt/samsung_ssd"
TERMUX_ROOT="$LFS/termux"
ANDROID_NDK_VERSION="r26b"
ANDROID_NDK="$LFS/build_tools/android-ndk-$ANDROID_NDK_VERSION"

echo "Setting up Termux build environment..."

# Create Termux directory structure
mkdir -p "$TERMUX_ROOT"/{bin,etc,lib,libexec,share,tmp,usr}
mkdir -p "$TERMUX_ROOT/usr"/{bin,include,lib,share}
mkdir -p "$LFS/build_tools"

# Download Android NDK
if [ ! -d "$ANDROID_NDK" ]; then
    echo "Downloading Android NDK $ANDROID_NDK_VERSION..."
    cd "$LFS/build_tools"
    wget "https://dl.google.com/android/repository/android-ndk-$ANDROID_NDK_VERSION-linux.zip"
    unzip "android-ndk-$ANDROID_NDK_VERSION-linux.zip"
    rm "android-ndk-$ANDROID_NDK_VERSION-linux.zip"
fi

# Download Termux build scripts
if [ ! -d "$TERMUX_ROOT/build-scripts" ]; then
    echo "Cloning Termux build scripts..."
    cd "$TERMUX_ROOT"
    git clone https://github.com/termux/termux-packages.git build-scripts
fi

# Setup Termux configuration
cat > "$TERMUX_ROOT/etc/termux-info" << "EOF"
TERMUX_VERSION=0.118.0
TERMUX_APP_PACKAGE=com.termux.custom
TERMUX_APP_VERSION=1.0
TERMUX_IS_DEBUGGABLE_BUILD=true
EOF

# Create Termux environment setup script
cat > "$TERMUX_ROOT/bin/termux-setup" << "EOF"
#!/bin/bash
# Termux environment setup script

export TERMUX_PREFIX=/data/data/com.termux.custom/files/usr
export TERMUX_HOME=/data/data/com.termux.custom/files/home
export PATH=$TERMUX_PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$TERMUX_PREFIX/lib:$LD_LIBRARY_PATH

# Create basic directories
mkdir -p "$TERMUX_HOME"/{bin,etc,tmp,usr}
mkdir -p "$TERMUX_PREFIX"/{bin,etc,lib,share}

echo "Custom Termux environment initialized"
EOF

chmod +x "$TERMUX_ROOT/bin/termux-setup"

# Create Android project structure
mkdir -p "$LFS/android_project"/{app/src/main,gradle/wrapper}
mkdir -p "$LFS/android_project/app/src/main"/{java/com/termux/custom,res}

echo "Termux build environment setup complete!"
echo "Next: Configure Android project for APK generation"
