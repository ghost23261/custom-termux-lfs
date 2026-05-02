#!/bin/bash

# F-Droid Private Repository Deployment Script
# This script sets up a private F-Droid repository for Custom Termux

set -e

LFS="/mnt/samsung_ssd"
OUTPUT_DIR="$LFS/output"
FDROID_DIR="/var/www/fdroid"
APK_FILE="$OUTPUT_DIR/distribution/custom-termux.apk"

echo "═══════════════════════════════════════════════════════════════"
echo "       F-DROID PRIVATE REPOSITORY DEPLOYMENT"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if APK exists
if [ ! -f "$APK_FILE" ]; then
    echo "❌ ERROR: APK not found at $APK_FILE"
    echo "Please build the project first: ./scripts/complete_build.sh"
    exit 1
fi

echo "✓ APK found: $APK_FILE"

# Install F-Droid server if not present
if ! command -v fdroid &> /dev/null; then
    echo "📦 Installing F-Droid server tools..."
    sudo apt update
    sudo apt install -y fdroidserver
fi

echo "✓ F-Droid server tools installed"

# Setup F-Droid directory
if [ ! -d "$FDROID_DIR" ]; then
    echo "📁 Creating F-Droid repository directory..."
    sudo mkdir -p "$FDROID_DIR"
    sudo chown -R $USER:$USER "$FDROID_DIR"
    cd "$FDROID_DIR"
    fdroid init
fi

echo "✓ F-Droid repository initialized"

# Configure repository
echo "⚙️  Configuring repository..."
cd "$FDROID_DIR"

cat > config.yml << EOF
repo_url: https://your-server.com/fdroid/repo/
repo_name: Custom Termux Private Repo
repo_description: Private F-Droid repository for Custom Termux LFS Build
repo_icon: icon.png
archive_older: 3
keystore: /var/www/fdroid/keystore.jks
repo_keyalias: termux-custom
EOF

# Create keystore if it doesn't exist
if [ ! -f "$FDROID_DIR/keystore.jks" ]; then
    echo "🔐 Creating signing keystore..."
    keytool -genkey -v -keystore "$FDROID_DIR/keystore.jks" \
        -alias termux-custom -keyalg RSA -keysize 2048 -validity 10000 \
        -dname "CN=Custom Termux, OU=Private, O=Custom, L=Network, ST=Private, C=US" \
        -storepass "customtermux" -keypass "customtermux"
fi

# Copy APK to repository
echo "📋 Copying APK to repository..."
mkdir -p "$FDROID_DIR/repo"
cp "$APK_FILE" "$FDROID_DIR/repo/"

# Create metadata for the app
mkdir -p "$FDROID_DIR/metadata/com.termux.custom"
cat > "$FDROID_DIR/metadata/com.termux.custom.yml" << 'EOF'
Categories:
  - System
  - Terminal
License: GPL-3.0
SourceCode: https://github.com/ghost23261/custom-termux-lfs
IssueTracker: https://github.com/ghost23261/custom-termux-lfs/issues

Summary: Custom Termux with LFS Slackware Linux
Description: |
  Custom Termux terminal emulator built on Linux From Scratch
  with Slackware Linux packages. Features a complete Unix
  environment with bash, coreutils, gcc, and more.

  This is a private distribution for authorized network users only.

RepoType: git
Repo: https://github.com/ghost23261/custom-termux-lfs.git

Builds:
  - versionName: 1.0.0
    versionCode: 1
    commit: main
    output: custom-termux.apk

AutoUpdateMode: None
UpdateCheckMode: None
EOF

# Update F-Droid index
echo "🔄 Updating F-Droid index..."
cd "$FDROID_DIR"
fdroid update --create-metadata

# Sign the repository
echo "✍️  Signing repository..."
fdroid signindex

# Set permissions
sudo chown -R www-data:www-data "$FDROID_DIR"
sudo chmod -R 755 "$FDROID_DIR"

# Generate QR code
echo "📱 Generating QR code for easy setup..."
fdroid qr --repo-url https://your-server.com/fdroid/repo > "$OUTPUT_DIR/fdroid-qr-code.txt" 2>/dev/null || echo "QR code generation requires fdroidserver with qr support"

# Create installation guide
cat > "$OUTPUT_DIR/FDROID_SETUP.md" << 'EOF'
# F-Droid Private Repository Setup

## Server Setup Complete!

Your F-Droid repository is ready at: `/var/www/fdroid`

## Client Setup Instructions

### Method 1: QR Code (Easiest)
1. Open F-Droid app on Android
2. Tap "+" button or go to Settings → Repositories
3. Scan the QR code generated
4. Repository will be added automatically

### Method 2: Manual URL Entry
1. Open F-Droid app
2. Go to Settings → Repositories
3. Tap "+" to add new repository
4. Enter URL: `https://your-server.com/fdroid/repo`
5. Enter fingerprint from below
6. Tap "Add"

### Method 3: Direct Link
Share this link with users:
```
https://your-server.com/fdroid/repo?fingerprint=[FINGERPRINT]
```

## Repository Fingerprint
```
[Will be displayed after first signindex]
```

## For Users
Once repository is added:
1. Open F-Droid app
2. Search for "Custom Termux"
3. Tap "Install"
4. Updates will be automatic via F-Droid

## Maintenance
```bash
# Update repository after new APK build
cd /var/www/fdroid
fdroid update
fdroid signindex

# View repository info
fdroid readmeta
```
EOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ F-DROID DEPLOYMENT COMPLETE!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Repository location: $FDROID_DIR"
echo "APK location: $FDROID_DIR/repo/"
echo "Setup guide: $OUTPUT_DIR/FDROID_SETUP.md"
echo ""
echo "Next steps:"
echo "  1. Configure web server (nginx/apache) to serve /var/www/fdroid"
echo "  2. Set up SSL certificate (Let's Encrypt recommended)"
echo "  3. Update repo_url in $FDROID_DIR/config.yml"
echo "  4. Re-run: fdroid update && fdroid signindex"
echo "  5. Share repository URL with your network users"
echo ""
echo "F-Droid repository ready for private network distribution!"
