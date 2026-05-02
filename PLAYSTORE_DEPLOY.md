# Google Play Store Deployment Guide

## 💰 Pricing: $1.99 USD

---

## 📋 Prerequisites

- Google Play Developer Account ($25 one-time fee)
- Signed release APK
- Privacy policy
- App screenshots (phone + tablet)
- Feature graphic (1024x500)
- App icon (512x512)

---

## 🚀 Deployment Steps

### 1. Prepare Release APK

```bash
cd android_project

# Generate signing key for Play Store if you do not already have one
keytool -genkey -v -keystore custom-termux-release.keystore \
    -alias custom-termux -keyalg RSA -keysize 2048 -validity 10000

# Configure signing properties for Gradle or export them in your shell
export PLAYSTORE_KEYSTORE_FILE="$(pwd)/custom-termux-release.keystore"
export PLAYSTORE_KEYSTORE_PASSWORD="your-keystore-password"
export PLAYSTORE_KEY_ALIAS="custom-termux"
export PLAYSTORE_KEY_PASSWORD="your-key-password"

# Build release APK
./gradlew clean assembleRelease

# Align APK for Play Store
zipalign -v 4 \
    app/build/outputs/apk/release/app-release-unsigned.apk \
    custom-termux-v1.0.0-release.apk

# Sign aligned APK if it is still unsigned
apksigner sign --ks "$PLAYSTORE_KEYSTORE_FILE" \
    --ks-pass pass:"$PLAYSTORE_KEYSTORE_PASSWORD" \
    --key-pass pass:"$PLAYSTORE_KEY_PASSWORD" \
    --out custom-termux-v1.0.0-playstore.apk \
    custom-termux-v1.0.0-release.apk
```

> Tip: from the repository root, you can also use `scripts/deploy_playstore.sh` after exporting the same signing variables.

### 2. Play Console Setup

```
1. Go to https://play.google.com/console
2. Click "Create App"
3. Fill in app details:
   - App Name: Custom Termux
   - Default Language: English
   - App or Game: App
   - Free or Paid: PAID
   - Price: $1.99 USD
   - Category: Tools
   - Email: your-email@example.com
```

### 3. Store Listing

**Title:** Custom Termux - LFS Linux Terminal

**Short Description:**
```
Premium terminal emulator with LFS Slackware Linux base. Full Unix environment on Android.
```

**Full Description:**
```
Custom Termux brings a complete Linux From Scratch (LFS) environment to your Android device, built on the legendary Slackware Linux distribution.

✨ FEATURES:
• Full Unix toolchain (bash, grep, sed, awk, tar, gzip)
• GCC 14.2.0 compiler suite for development
• NCurses 6.5 + Readline 8.2 for advanced terminal
• OpenSSL 3.3.2 for secure connections
• ARM64 optimized with Android NDK r26b
• Professional terminal emulator interface

🛠️ PERFECT FOR:
• Developers needing full Linux environment
• System administrators on the go
• Students learning Unix/Linux
• Power users who need command-line tools
• Security researchers and pentesters

💻 WHAT YOU GET:
• Complete LFS Slackware Linux base system
• Bash 5.3.009 shell
• Coreutils 9.5 (full GNU utilities)
• GCC compiler for C/C++ development
• Automatic OTA updates via built-in updater
• Professional support and documentation

🔒 SECURITY:
• Signed with Play Store certificate
• Regular security updates
• Privacy-focused (no data collection)
• Local processing only

📱 REQUIREMENTS:
• Android 7.0+ (API 24)
• ARM64 device (most modern phones)
• 500MB storage space

⚠️ IMPORTANT:
This is a premium, professional-grade terminal emulator. For free alternatives, consider the official Termux app on F-Droid.

---

Why pay $1.99?
• LFS Slackware base (not Android Bionic libc)
• Full GCC compiler suite included
• Professional support
• Regular updates
• No ads, no tracking
• Supports independent development

Questions? Contact: support@customtermux.example.com
```

### 4. Content Rating

```
Category: Reference, Books, Tools
Age Rating: 18+ (unrestricted internet, shell access)
```

### 5. Pricing & Distribution

```
Pricing Template: $1.99 USD
Countries: All countries
Primary Category: Tools
Secondary Category: Productivity
Contains Ads: No
In-app purchases: No
```

### 6. Required Assets

**Screenshots (Required):**
- Phone: 2-8 screenshots (PNG/JPEG, 16:9 or 9:16)
- 7-inch tablet: 2-8 screenshots
- 10-inch tablet: 2-8 screenshots

**Graphics:**
- App Icon: 512x512 PNG
- Feature Graphic: 1024x500 PNG
- Promo Graphic: 180x120 PNG (optional)

### 7. Privacy Policy

Create `PRIVACY_POLICY.md`:

```markdown
# Privacy Policy - Custom Termux

**Effective Date:** 2026-05-02

## Data Collection

Custom Termux does NOT collect any personal data:
- No user accounts required
- No data transmitted to our servers
- No analytics or tracking
- No advertising ID usage
- No crash reporting without consent

## Local Processing

All operations are performed locally on your device:
- Commands execute on device only
- Files stored locally
- Network connections initiated by user only

## Permissions

Required permissions:
- Storage: For file operations
- Internet: For package downloads (user-initiated)

## Contact

Questions: support@customtermux.example.com
```

---

## 🔄 Release Checklist

- [ ] APK signed and aligned
- [ ] VersionCode incremented
- [ ] Screenshots uploaded
- [ ] Store listing complete
- [ ] Privacy policy linked
- [ ] Content rating completed
- [ ] Pricing set to $1.99
- [ ] Countries selected
- [ ] Beta testing (optional)
- [ ] "Publish" clicked

---

## 📊 Expected Timeline

| Phase | Duration |
|-------|----------|
| Review | 3-7 days |
| Publish | Immediate after approval |
| First Sales | 24-48 hours |

---

## 💵 Revenue Projection

At $1.99 with 70% revenue share:

| Downloads | Gross Revenue | Your Earnings |
|-----------|--------------|---------------|
| 100 | $199 | ~$139 |
| 500 | $995 | ~$697 |
| 1000 | $1,990 | ~$1,393 |
| 5000 | $9,950 | ~$6,965 |

---

## 🎯 Marketing Tips

1. **Reddit:** Post to r/termux, r/linux, r/androiddev
2. **YouTube:** Create demo video showing gcc compilation
3. **Blog:** Write about LFS on Android
4. **XDA Forums:** Post in Android development sections
5. **GitHub:** Keep repo public for credibility

---

## 🚀 Play Store Alternative: Internal Testing

For faster deployment to your network:

```
Play Console → Testing → Internal Testing
→ Create Track → Upload APK
→ Add Testers (email list)
→ Share link with your network
```

**Benefits:**
- Immediate deployment (no review)
- Private distribution
- Update testing
- $1.99 still applies

---

## 📱 Play Store Link Format

After publishing:
```
https://play.google.com/store/apps/details?id=com.termux.custom
```

QR Code for easy sharing:
```bash
qrencode -o playstore-qr.png \
    "https://play.google.com/store/apps/details?id=com.termux.custom"
```

---

## ⚡ Quick Deploy Script

```bash
#!/bin/bash
# Play Store Deploy Helper

echo "Custom Termux - Play Store Deploy"
echo "=================================="

# Build release
cd /mnt/samsung_ssd/android_project
./gradlew assembleRelease

# Sign
jarsigner -keystore ../custom-termux-release.keystore \
    app/build/outputs/apk/release/app-release-unsigned.apk \
    custom-termux

# Align
zipalign -v 4 \
    app/build/outputs/apk/release/app-release-unsigned.apk \
    ../custom-termux-v1.0.0-playstore.apk

echo "Ready for upload: custom-termux-v1.0.0-playstore.apk"
echo "Go to: https://play.google.com/console"
```

---

**Ready to sell on Play Store for $1.99!** 🚀
