# Build Checklist & Verification

## Prerequisites ✓

- [ ] **Java/JDK Installed**
  ```bash
  java -version
  ```
  - Requires: Java 11 or higher
  - Recommended: OpenJDK 17+

- [ ] **Git Installed**
  ```bash
  git --version
  ```

- [ ] **Enough Disk Space**
  ```bash
  df -h /
  ```
  - Requires: 10GB minimum for build
  - Recommended: 20GB for full LFS build

- [ ] **Internet Connection**
  - Gradle will download dependencies (~500MB)
  - Android SDK components needed

## Configuration ✓

- [ ] **Set Base Path**
  ```bash
  export LFS="/path/to/custom-termux-lfs"
  ```
  - Or script auto-detects from repository root

- [ ] **Optional: Android SDK**
  ```bash
  export ANDROID_SDK_ROOT="/path/to/android-sdk"
  export ANDROID_NDK_ROOT="/path/to/android-ndk"
  ```

## Build Steps ✓

### Quick Build (Recommended)

```bash
# Navigate to repository
cd custom-termux-lfs

# Run unified build script
bash scripts/build.sh
```

**Expected Duration**: 5-10 minutes (first run may take longer for dependencies)

### Manual Build Steps

```bash
# Step 1: Setup directories
mkdir -p android_project/{app/src/main,gradle/wrapper}

# Step 2: Setup Gradle
bash scripts/setup_gradle_wrapper.sh

# Step 3: Build APK
cd android_project
./gradlew assembleDebug

# Step 4: Package
mkdir -p ../output/distribution
cp app/build/outputs/apk/debug/app-debug.apk ../output/distribution/custom-termux.apk
```

## Verification ✓

### APK Built Successfully

- [ ] **Check APK Exists**
  ```bash
  ls -lh output/distribution/custom-termux.apk
  ```
  - Should be 1-5MB in size

- [ ] **Verify APK Integrity**
  ```bash
  unzip -t output/distribution/custom-termux.apk
  ```
  - Should show "No errors detected"

### AndroidManifest.xml

- [ ] **Package Name Correct**
  ```bash
  unzip -p output/distribution/custom-termux.apk AndroidManifest.xml | strings | grep com.termux.custom
  ```

- [ ] **API Levels Set**
  - minSdkVersion: 24 (Android 7.0)
  - targetSdkVersion: 34 (Android 14)

### Test on Device (Optional)

```bash
# Connect device with USB debugging enabled
adb devices

# Install APK
adb install output/distribution/custom-termux.apk

# Verify installation
adb shell pm list packages | grep com.termux.custom

# Launch app
adb shell am start -n com.termux.custom/.MainActivity

# View logcat
adb logcat | grep "termux.custom"
```

## Common Issues & Fixes

### Issue: "Command not found: java"

**Solution:**
```bash
# Install Java
sudo apt install -y default-jdk

# Or set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

### Issue: "Gradle build failed"

**Solution:**
```bash
# Check build.log
cat android_project/build.log

# Clean and retry
cd android_project
./gradlew clean
./gradlew assembleDebug
```

### Issue: "APK not found after build"

**Solution:**
```bash
# Check expected location
find android_project -name "*.apk" -type f

# Check for build errors
cd android_project
./gradlew --info assembleDebug 2>&1 | grep -i error
```

### Issue: "Permission denied: gradlew"

**Solution:**
```bash
# Make executable
chmod +x android_project/gradlew

# Run again
./android_project/gradlew assembleDebug
```

## Deployment Verification ✓

### F-Droid Deployment

```bash
# Test F-Droid deployment
bash scripts/deploy_fdroid.sh

# Verify repository
ls -la /var/www/fdroid/repo/custom-termux.apk
```

### Play Store Deployment

```bash
# Test Play Store build
export PLAYSTORE_KEYSTORE_FILE="path/to/keystore.jks"
export PLAYSTORE_KEYSTORE_PASSWORD="your-password"
export PLAYSTORE_KEY_ALIAS="custom-termux"
export PLAYSTORE_KEY_PASSWORD="your-password"

bash scripts/deploy_playstore.sh
```

## Final Checklist ✓

Before Distribution:

- [ ] APK signed (if distributing outside F-Droid)
- [ ] Version number correct
- [ ] Target API levels verified
- [ ] Permissions in manifest correct
- [ ] App icon present
- [ ] App launches without crashes
- [ ] README updated with version info
- [ ] Change log documented

## Success Criteria ✓

**Build Successful When:**

✓ APK file exists: `output/distribution/custom-termux.apk`  
✓ APK size reasonable: 1-5 MB  
✓ APK verifies without errors: `unzip -t`  
✓ Can install on test device  
✓ App launches without immediate crash  
✓ Main activity displays  

## Support

**Issues?** Check:
1. `BUILD_CHECKLIST.md` (this file)
2. `README.md` (main documentation)
3. `android_project/build.log` (build output)
4. GitHub Issues: https://github.com/ghost23261/custom-termux-lfs/issues

---

**Happy building!** 🚀
