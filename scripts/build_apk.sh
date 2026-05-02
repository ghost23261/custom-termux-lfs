#!/bin/bash

# Build APK
# This script builds the final APK for our custom Termux

set -e

LFS="/workspaces/custom-termux-lfs"
ANDROID_PROJECT="$LFS/android_project"

echo "Building APK..."

cd "$ANDROID_PROJECT"

# Download gradle wrapper if needed
if [ ! -f "gradlew" ]; then
    echo "Downloading gradle wrapper..."
    wget https://services.gradle.org/distributions/gradle-8.4-bin.zip
    unzip gradle-8.4-bin.zip
    mv gradle-8.4/* .
    rm -rf gradle-8.4
    rm gradle-8.4-bin.zip
fi

# Make gradlew executable
chmod +x gradlew

# Build debug APK
echo "Building debug APK..."
./gradlew assembleDebug

# Copy APK to output directory
mkdir -p "$LFS/output"
cp app/build/outputs/apk/debug/app-debug.apk "$LFS/output/custom-termux.apk"

echo "APK built successfully: $LFS/output/custom-termux.apk"
