# <span style="color: #CC0000;">🛡️ Custom Termux</span>

<span style="color: #CC0000;">**Red Hat Inspired - Enterprise Linux Terminal for Android**</span>

[![Red Hat](https://img.shields.io/badge/Powered%20by-Red%20Hat-CC0000?style=for-the-badge&logo=redhat)](https://redhat.com)

A custom Android application that provides an enterprise-grade terminal interface, inspired by Red Hat's reliability and security standards.

## <span style="color: #CC0000;">🔥 Overview</span>

This project builds a custom Android APK featuring a robust terminal emulator with Red Hat-inspired design and functionality.

**Status:** <span style="color: green;">✅ Production Ready</span> | **Version:** v1.0.0 | **API:** 24+ (Android 7.0+)

## <span style="color: #CC0000;">🚀 Features</span>

```
┌─────────────────────────────────────────────────────────────────┐
│  [🔴] Enterprise-Grade Terminal Interface                       │
│  [🔴] Red Hat Inspired UI/UX Design                             │
│  [🔴] Secure Service Architecture                               │
│  [🔴] Android Native Development Kit Integration               │
│  [🔴] ARM64 Architecture Support                                │
│  [🔴] Private Repository Deployment                             │
│  [🔴] Automated Build System                                    │
│  [🔴] Enterprise Distribution Ready                             │
└─────────────────────────────────────────────────────────────────┘
```

## <span style="color: #CC0000;">📦 Installation</span>

### <span style="color: #CC0000;">Method 1: APK Installation (Recommended)</span>

```bash
# Transfer APK to Android device
adb push output/custom-termux.apk /sdcard/Download/

# Install via ADB
adb install /sdcard/Download/custom-termux.apk
```

### <span style="color: #CC0000;">Method 2: Enterprise Deployment</span>

```bash
# For enterprise environments
# Deploy via MDM (Mobile Device Management)
# Or private app store
```

## <span style="color: #CC0000;">🏗️ Build Instructions</span>

```bash
# Build the enterprise APK
bash scripts/complete_build.sh

# Verify build integrity
ls -la output/custom-termux.apk
```

## <span style="color: #CC0000;">🚢 Deployment</span>

### <span style="color: #CC0000;">F-Droid Repository</span>

```bash
# Deploy to private F-Droid repository
bash scripts/deploy_fdroid.sh
```

### <span style="color: #CC0000;">Play Store</span>

Follow the instructions in `PLAYSTORE_DEPLOY.md` for enterprise Play Store deployment.

## <span style="color: #CC0000;">🏛️ Project Structure</span>

```
custom-termux-lfs/
├── android_project/     # 📱 Android application source
├── scripts/            # 🔧 Build & deployment scripts
├── termux/             # 🐧 Termux environment files
├── pkgs/               # 📦 Package repository
└── README.md           # 📖 This file
```

## <span style="color: #CC0000;">⚙️ Requirements</span>

- <span style="color: #CC0000;">Android Studio</span> or Gradle 8.1+
- <span style="color: #CC0000;">Android SDK 34</span>
- <span style="color: #CC0000;">Android NDK r26b</span> (for native components)
- <span style="color: #CC0000;">Java 11+</span>

## <span style="color: #CC0000;">🔒 Security</span>

This application follows Red Hat's security principles:
- Minimal attack surface
- Secure service architecture
- No unnecessary permissions
- Enterprise-ready deployment

## <span style="color: #CC0000;">📞 Support</span>

For enterprise support and custom deployments, contact the development team.

---

<span style="color: #CC0000;">**Built with ❤️ and Red Hat inspiration**</span>

# 2. Grant permissions
#    - Storage access
#    - Internet (for updates)
#    - Foreground service

# 3. Launch app
#    - Find "Custom Termux" in app drawer
#    - Open to initialize environment
```

---

## 📂 DIRECTORY STRUCTURE

```
/mnt/samsung_ssd/
├── 📁 scripts/                 # Build automation scripts
│   ├── setup_lfs_environment.sh
│   ├── download_packages_simple.sh
│   ├── build_lfs_base.sh
│   ├── build_custom_termux.sh
│   ├── create_android_apk.sh
│   └── complete_build.sh
├── 📁 sources/                 # Downloaded Slackware packages
├── 📁 build_tools/             # Android NDK r26b
│   └── android-ndk-r26b/
├── 📁 termux/                  # Termux environment
│   ├── bin/termux-launcher
│   ├── bin/termux-setup
│   ├── etc/termux.properties
│   └── build-scripts/          # [SUBMODULE] termux-packages
├── 📁 rootfs/                  # LFS Slackware root filesystem
├── 📁 android_project/         # Android APK project
│   ├── app/src/main/
│   ├── gradle/
│   └── build.gradle
└── 📁 output/                  # Final distribution files
    ├── distribution/
    └── custom-termux-v1.0.0.tar.gz
```

---

## 🔧 BUILD FROM SOURCE

### Prerequisites

```bash
# System Requirements:
# - Linux x86_64
# - 50GB free space (SSD recommended)
# - 8GB+ RAM
# - Internet connection

# Install dependencies:
sudo apt update
sudo apt install -y \
    git wget curl \
    build-essential \
    default-jdk \
    gradle \
    unzip \
    tar
```

### Quick Build

```bash
# Clone repository
git clone https://github.com/ghost23261/custom-termux-lfs.git
cd custom-termux-lfs

# Initialize submodule
git submodule update --init --recursive

# Run complete build (takes 30-60 minutes)
sudo ./scripts/complete_build.sh

# Output: output/custom-termux-v1.0.0.tar.gz
```

### Step-by-Step Build

```bash
# Step 1: Setup LFS environment
sudo ./scripts/setup_lfs_environment.sh

# Step 2: Download Slackware packages (run as lfs user)
sudo -u lfs ./scripts/download_packages_simple.sh

# Step 3: Setup Termux environment
sudo ./scripts/setup_termux_environment.sh

# Step 4: Build custom Termux components
sudo -u lfs ./scripts/build_custom_termux.sh

# Step 5: Create Android APK project
sudo ./scripts/create_android_apk.sh

# Step 6: Complete build and package
sudo ./scripts/complete_build.sh
```

---

## 📦 F-DROID DEPLOYMENT

### Setup Private F-Droid Repository

```bash
# Install F-Droid server tools
sudo apt install -y fdroidserver

# Initialize F-Droid repository
mkdir -p /var/www/fdroid
cd /var/www/fdroid
fdroid init

# Configure repository
cat > config.yml << 'EOF'
repo_url: https://your-private-server/fdroid
repo_name: Custom Termux Private Repo
repo_description: Private F-Droid repository for Custom Termux
archive_older: 3
EOF

# Copy your APK to repo
mkdir -p /var/www/fdroid/repo
cp /mnt/samsung_ssd/output/distribution/custom-termux.apk /var/www/fdroid/repo/

# Update F-Droid index
fdroid update

# Sign repository
fdroid signindex

# Generate QR code for easy repo adding
fdroid qr --repo-url https://your-private-server/fdroid/repo
```

### F-Droid Client Setup

```bash
# On Android devices:
# 1. Install F-Droid from https://f-droid.org
# 2. Open F-Droid app
# 3. Go to Settings → Repositories
# 4. Click "+" to add new repository
# 5. Enter: https://your-private-server/fdroid/repo
# 6. Scan QR code or enter fingerprint manually
# 7. Custom Termux will appear in app list
```

### Automatic Updates via F-Droid

```bash
# F-Droid will automatically:
# - Check for updates daily
# - Download updates when available
# - Notify users of new versions
# - Handle signature verification
# - Allow one-tap updates
```

---

## 🎮 USAGE

### Launch Terminal

```bash
# From Android app drawer:
# 1. Tap "Custom Termux" icon
# 2. Grant storage permission
# 3. Terminal loads automatically
```

### Basic Commands

```bash
# Check environment
termux-info

# List installed packages
pkg list-installed

# Update package list
pkg update

# Install additional packages
pkg install vim python git

# Access storage
termux-setup-storage
ls ~/storage/shared
```

### Development Environment

```bash
# Setup development workspace
mkdir -p ~/workspace
cd ~/workspace

# Example: Compile C program
cat > hello.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello from Custom Termux!\n");
    return 0;
}
EOF

# Compile with GCC (if available)
gcc hello.c -o hello
./hello
```

---

## 🔐 SECURITY NOTES

```
╔══════════════════════════════════════════════════════════════════╗
║  ⚠️  PRIVATE NETWORK DISTRIBUTION ONLY                           ║
║                                                                  ║
║  - Do not redistribute outside authorized network                ║
║  - Signed with private keys (not Play Store)                     ║
║  - Requires "Unknown Sources" installation                       ║
║  - Contact network admin for support                             ║
╚══════════════════════════════════════════════════════════════════╝
```

### File Integrity

```bash
# Verify SHA256 checksum
sha256sum custom-termux-v1.0.0.tar.gz

# Compare with manifest in distribution/update_manifest.json
```

---

## 🐛 TROUBLESHOOTING

### Issue: "App not installed"

```bash
# Solution 1: Enable unknown sources
Settings > Security > Unknown Sources > Enable

# Solution 2: Uninstall conflicting version
adb uninstall com.termux.custom
adb install custom-termux.apk
```

### Issue: "Bootstrap extraction failed"

```bash
# Free up storage space
df -h /data

# Clear cache
rm -rf /data/data/com.termux.custom/cache/*

# Re-run installer
./install-termux.sh
```

### Issue: "Permission denied"

```bash
# Grant permissions manually
adb shell pm grant com.termux.custom android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.termux.custom android.permission.WRITE_EXTERNAL_STORAGE
```

### Issue: "Command not found"

```bash
# Source environment
source $PREFIX/etc/profile

# Check PATH
echo $PATH
```

---

## 📞 SUPPORT

**Network:** Private Distribution  
**Repository:** `https://github.com/ghost23261/custom-termux-lfs`  
**Issues:** Contact your network administrator  
**Build Date:** 2026-05-02  
**Maintainer:** Custom Termux Dev Team  

---

## 📜 LICENSE & DISCLAIMER

```
This software is provided for private network use only.
Not for public distribution or commercial use.
Built on LFS Slackware Linux and Termux open-source components.
Use at your own risk.
```

---

## 🚀 QUICK START CHEAT SHEET

```bash
# Install (30 seconds)
adb install custom-termux.apk

# Launch
# Tap app icon → Grant permissions → Done

# Verify
echo $SHELL          # Should show bash
which gcc            # Should show compiler path
termux-info          # Display environment info
```

---

```
╔══════════════════════════════════════════════════════════════════╗
║               CUSTOM TERMUX - LFS SLACKWARE BUILD               ║
║                       [PRIVATE DISTRIBUTION]                       ║
╚══════════════════════════════════════════════════════════════════╝
```

**Happy Hacking! ⚡**
