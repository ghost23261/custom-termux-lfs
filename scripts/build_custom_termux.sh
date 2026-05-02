#!/bin/bash

# Build Custom Termux Components
# This script builds custom Termux binaries using the LFS environment and Android NDK

set -e

LFS="/mnt/samsung_ssd"
TERMUX_ROOT="$LFS/termux"
ANDROID_NDK="$LFS/build_tools/android-ndk-r26b"
TERMUX_BUILD="$TERMUX_ROOT/build-scripts"

export ANDROID_NDK_ROOT="$ANDROID_NDK"
export NDK="$ANDROID_NDK"
export TERMUX_PREFIX="/data/data/com.termux.custom/files/usr"
export TERMUX_ANDROID_HOME="/data/data/com.termux.custom/files/home"

# Setup build environment
export PATH="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export CC="aarch64-linux-android24-clang"
export CXX="aarch64-linux-android24-clang++"
export AR="llvm-ar"
export STRIP="llvm-strip"

echo "Building custom Termux components..."

# Create build directory
mkdir -p "$TERMUX_ROOT/build"
cd "$TERMUX_ROOT/build"

# Build essential Termux packages
PACKAGES=(
    "libandroid-support"
    "libiconv" 
    "ncurses"
    "readline"
    "bash"
    "coreutils"
    "procps"
    "grep"
    "sed"
    "awk"
    "tar"
    "gzip"
    "findutils"
)

# Function to build a package
build_package() {
    local package=$1
    echo "Building $package..."
    
    if [ -d "$TERMUX_BUILD/packages/$package" ]; then
        cd "$TERMUX_BUILD/packages/$package"
        
        # Setup Termux build environment
        export TERMUX_PKG_VERSION="1.0.0"
        export TERMUX_PKG_REVISION="1"
        export TERMUX_PKG_SHA256=""
        
        # Run build script if it exists
        if [ -f "build.sh" ]; then
            bash build.sh
        else
            echo "No build script found for $package, skipping..."
        fi
        
        echo "Built $package"
    else
        echo "Package $package not found, skipping..."
    fi
}

# Build each package
for package in "${PACKAGES[@]}"; do
    build_package "$package"
done

# Create custom Termux launcher
cat > "$TERMUX_ROOT/bin/termux-launcher" << 'EOF'
#!/system/bin/sh
# Custom Termux launcher

export TERMUX_PREFIX="/data/data/com.termux.custom/files/usr"
export TERMUX_HOME="/data/data/com.termux.custom/files/home"
export PATH="$TERMUX_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$TERMUX_PREFIX/lib:$LD_LIBRARY_PATH"

# Start bash shell
exec "$TERMUX_PREFIX/bin/bash" --login
EOF

chmod +x "$TERMUX_ROOT/bin/termux-launcher"

# Create Termux properties
cat > "$TERMUX_ROOT/etc/termux.properties" << 'EOF'
# Custom Termux properties
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
EOF

echo "Custom Termux components build complete!"
echo "Next: Create Android APK project"
