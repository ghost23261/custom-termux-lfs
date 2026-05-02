#!/bin/bash

# Setup Private Network Distribution
# This script configures the APK for private network distribution

set -e

LFS="/mnt/samsung_ssd"
OUTPUT_DIR="$LFS/output"
APK_FILE="$OUTPUT_DIR/custom-termux.apk"

echo "Setting up private network distribution..."

# Create distribution directory
mkdir -p "$OUTPUT_DIR/distribution"

# Generate signing keys for private distribution
if [ ! -f "$OUTPUT_DIR/keystore.jks" ]; then
    echo "Generating signing keys..."
    keytool -genkey -v -keystore "$OUTPUT_DIR/keystore.jks" \
        -alias termux-custom \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=Custom Termux, OU=Private, O=Custom, L=Network, ST=Private, C=US" \
        -storepass "customtermux" \
        -keypass "customtermux"
fi

# Sign the APK
if [ -f "$APK_FILE" ]; then
    echo "Signing APK..."
    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
        -keystore "$OUTPUT_DIR/keystore.jks" \
        -storepass "customtermux" \
        -keypass "customtermux" \
        "$APK_FILE" termux-custom
    
    # Create signed APK copy
    cp "$APK_FILE" "$OUTPUT_DIR/distribution/custom-termux-signed.apk"
fi

# Create update manifest
cat > "$OUTPUT_DIR/distribution/update_manifest.json" << 'EOF'
{
    "version": "1.0.0",
    "version_code": 1,
    "apk_url": "custom-termux-signed.apk",
    "apk_sha256": "",
    "changelog": "Initial release of custom Termux with LFS Slackware base",
    "release_date": "2026-05-02",
    "min_android_version": 24,
    "target_android_version": 34
}
EOF

# Calculate APK SHA256
if [ -f "$OUTPUT_DIR/distribution/custom-termux-signed.apk" ]; then
    SHA256=$(sha256sum "$OUTPUT_DIR/distribution/custom-termux-signed.apk" | cut -d' ' -f1)
    sed -i "s/\"apk_sha256\": \"\"/\"apk_sha256\": \"$SHA256\"/" "$OUTPUT_DIR/distribution/update_manifest.json"
fi

# Create installation script
cat > "$OUTPUT_DIR/distribution/install.sh" << 'EOF'
#!/bin/bash
# Custom Termux Installation Script

echo "Installing Custom Termux..."

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo "Error: ADB not found. Please install Android SDK platform-tools."
    exit 1
fi

# Enable USB debugging on device
echo "Please ensure USB debugging is enabled on your Android device"
echo "Connect your device via USB and authorize this computer"

# Wait for device
echo "Waiting for device..."
adb wait-for-device

# Install APK
echo "Installing APK..."
adb install custom-termux-signed.apk

echo "Installation complete!"
echo "You can now launch Custom Termux from your app drawer"
EOF

chmod +x "$OUTPUT_DIR/distribution/install.sh"

# Create README for distribution
cat > "$OUTPUT_DIR/distribution/README.md" << 'EOF'
# Custom Termux Distribution

## Overview
This is a custom Termux application built with LFS Slackware Linux base for private network distribution.

## Installation

### Method 1: Using ADB (Recommended)
1. Install Android SDK platform-tools
2. Enable USB debugging on your Android device
3. Run: `./install.sh`

### Method 2: Manual Installation
1. Transfer `custom-termux-signed.apk` to your Android device
2. Enable "Install from unknown sources" in settings
3. Open the APK file to install

## Features
- Custom LFS Slackware Linux base
- Essential Unix tools (bash, coreutils, grep, sed, awk, etc.)
- Private network distribution ready
- Signed for security

## Security
- APK is signed with private keys
- SHA256 checksum verification
- Private distribution only

## Support
This is a private distribution. Contact your network administrator for support.
EOF

echo "Private distribution setup complete!"
echo "Distribution files available in: $OUTPUT_DIR/distribution"
echo "Signed APK: $OUTPUT_DIR/distribution/custom-termux-signed.apk"
