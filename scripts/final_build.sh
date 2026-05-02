#!/bin/bash

# Final Build Script for Custom Termux APK
# This script completes the APK build process using available tools

set -e

LFS="/mnt/samsung_ssd"
ANDROID_PROJECT="$LFS/android_project"
OUTPUT_DIR="$LFS/output"

echo "Starting final build process..."

# Install required packages
echo "Installing required build tools..."
sudo apt update
sudo apt install -y default-jdk openjdk-17-jdk gradle

cd "$ANDROID_PROJECT"

# Create gradlew wrapper script
cat > gradlew << 'EOF'
#!/bin/sh

# Gradle wrapper script
GRADLE_APP_HOME="$(dirname "$(readlink -f "$0")")"
exec gradle "$@"
EOF

chmod +x gradlew

# Build APK using system gradle
echo "Building APK..."
if command -v gradle &> /dev/null; then
    gradle assembleDebug
else
    echo "Using local gradle installation..."
    ./gradlew assembleDebug
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Copy APK if build succeeded
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    cp app/build/outputs/apk/debug/app-debug.apk "$OUTPUT_DIR/custom-termux.apk"
    echo "APK built successfully: $OUTPUT_DIR/custom-termux.apk"
else
    echo "APK build failed - checking for alternative locations..."
    find . -name "*.apk" -type f -exec cp {} "$OUTPUT_DIR/" \;
fi

# Create simple signing setup (without keytool)
echo "Creating distribution package..."
mkdir -p "$OUTPUT_DIR/distribution"

# Copy APK to distribution
if [ -f "$OUTPUT_DIR/custom-termux.apk" ]; then
    cp "$OUTPUT_DIR/custom-termux.apk" "$OUTPUT_DIR/distribution/"
    echo "APK copied to distribution directory"
fi

# Create installation instructions
cat > "$OUTPUT_DIR/distribution/INSTALL.md" << 'EOF'
# Custom Termux Installation

## Prerequisites
- Android device with API 24+ (Android 7.0+)
- "Install from unknown sources" enabled

## Installation Steps

### Option 1: Direct Installation
1. Transfer `custom-termux.apk` to your Android device
2. Open the file and follow installation prompts
3. Grant necessary permissions when requested

### Option 2: ADB Installation
1. Install Android SDK Platform Tools
2. Enable USB Debugging on your device
3. Connect device via USB and authorize
4. Run: `adb install custom-termux.apk`

## Features
- Custom LFS Slackware Linux base
- Essential Unix tools pre-installed
- Private distribution ready
- No Google Play dependencies

## Security
This APK is built for private network distribution only.
Do not redistribute outside your authorized network.

## Support
Contact your network administrator for support.
EOF

# Create version info
cat > "$OUTPUT_DIR/distribution/VERSION.txt" << EOF
Custom Termux v1.0.0
Build Date: $(date)
Target Android: API 24-34
Base System: LFS Slackware Linux
Distribution: Private Network Only
EOF

echo "Build process completed!"
echo "Distribution files available in: $OUTPUT_DIR/distribution"
echo "Main APK: $OUTPUT_DIR/custom-termux.apk"
