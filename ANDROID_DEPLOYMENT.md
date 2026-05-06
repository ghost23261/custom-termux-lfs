# Slackware LFS Android Deployment Guide

## Overview

This guide explains how to deploy your custom Slackware LFS rootfs to an Android app using proot, enabling a full Linux environment on Android without requiring root access.

## Architecture

The deployment follows this process:

1. **Compression**: Compress your Slackware LFS into `slackware_full_suite.tar.gz`
2. **Bundling**: Place the archive in `android_project/app/src/main/assets/`
3. **Extraction**: On app startup, extract to app's internal storage (`/data/data/com.termux.custom/files/rootfs/`)
4. **Execution**: Use proot to launch a shell inside the extracted rootfs

## Key Components

### AssetExtractor.java
Extracts tar.gz files from Android assets to the app's internal storage. Handles:
- GZIP decompression
- TAR archive extraction
- File permission preservation
- Progress callbacks for UI updates

### RootfsInitializer.java
Manages rootfs initialization:
- Checks if rootfs needs extraction
- Orchestrates the extraction process
- Creates necessary system directories
- Calculates rootfs size

### ProotLauncher.java
Launches and manages proot shell:
- Builds proot commands with proper arguments
- Sets up environment variables
- Captures process output
- Handles process lifecycle

### MainActivity.java
App entry point:
- Checks if rootfs needs initialization on first launch
- Shows extraction progress to user
- Enables launch button once ready
- Starts TermuxService and TerminalActivity

## Step-by-Step Deployment

### 1. Compress Your Rootfs

```bash
cd /path/to/slackware/rootfs
tar -czvf slackware_full_suite.tar.gz .
```

Or use the provided script:

```bash
./scripts/compress_rootfs.sh /path/to/.slackware_full_suite slackware_full_suite.tar.gz
```

This script will:
- Validate the source directory
- Compress with gzip
- Calculate compression ratio
- Optionally copy to Android assets

### 2. Place Archive in Assets

```bash
cp slackware_full_suite.tar.gz android_project/app/src/main/assets/
```

### 3. Build the APK

```bash
cd android_project
./gradlew clean assembleRelease
```

Or use the VS Code task: "Build Android Play Store APK"

### 4. Install and Run

```bash
adb install -r app/build/outputs/apk/release/app-release-unsigned.apk
adb shell am start -n com.termux.custom/.MainActivity
```

## First Launch Behavior

When users first launch the app:

1. MainActivity checks if rootfs exists
2. If empty: Shows "Initializing environment..."
3. Displays extraction progress with entry names and total size
4. Once complete: Shows "Ready to launch Termux"
5. User taps "Launch Termux" to open terminal

## Performance Considerations

### Extraction Time
- Depends on archive size and device storage speed
- Typical extraction: 1-5 minutes for full Slackware suite
- Only happens once, on first launch

### Compression Ratio
Use `compress_rootfs.sh` to check your specific ratio:
- Full Slackware: ~40-60% compression
- Custom toolset: ~50-70% compression

### APK Size
The archive will increase your APK size significantly:
- For ~500 MB uncompressed: ~150-250 MB compressed
- Consider splitting into multiple architectures if needed

## File Locations

**On Device (Internal Storage):**
```
/data/data/com.termux.custom/files/
├── rootfs/              # Extracted rootfs
│   ├── bin/
│   ├── usr/
│   ├── etc/
│   └── ...
└── (other app data)
```

**In Project:**
```
android_project/
└── app/
    └── src/
        └── main/
            ├── assets/
            │   └── slackware_full_suite.tar.gz
            └── java/
                └── com/termux/custom/
```

## Troubleshooting

### Extraction Fails
- Check device storage space
- Verify archive integrity: `tar -tzf slackware_full_suite.tar.gz`
- Check logcat: `adb logcat | grep AssetExtractor`

### App Crashes on Launch
- Verify assets directory exists and archive is present
- Check Android version (minimum API 24)
- Verify permissions in AndroidManifest.xml

### Rootfs Not Extracted
- Delete app data: `adb shell pm clear com.termux.custom`
- Reinstall app to retry extraction

### Proot Not Found
- Ensure proot binary is included in your Slackware build
- Verify binary location matches ProotLauncher path

## Logs and Debugging

View logs during extraction:
```bash
adb logcat | grep "Extraction\|Initialization\|MainActivity"
```

Common log entries:
```
[RootfsInitializer] Initializing rootfs from asset archive
[AssetExtractor] Extracted: /bin/bash (1234 entries)
[MainActivity] Initialization completed successfully
```

## Security Considerations

1. **Asset Size**: Consider app size distribution limits
2. **Permissions**: App only needs internal storage, no root
3. **Process Isolation**: proot doesn't provide true isolation
4. **Data Privacy**: All data stays within app's private directory

## Future Enhancements

- Lazy extraction (only extract needed components)
- Multi-archive splitting for modular rootfs
- Incremental updates instead of full re-extraction
- Integrated package manager within the app

## References

- proot documentation: https://proot-me.github.io/
- Apache Commons Compress: https://commons.apache.org/proper/commons-compress/
- Android AssetManager: https://developer.android.com/reference/android/content/res/AssetManager
- tar.gz format: https://www.gnu.org/software/tar/
