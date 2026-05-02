#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_PROJECT="$PROJECT_ROOT/android_project"

cd "$ANDROID_PROJECT"

if [ -z "${PLAYSTORE_KEYSTORE_FILE:-}" ] || [ -z "${PLAYSTORE_KEYSTORE_PASSWORD:-}" ] || [ -z "${PLAYSTORE_KEY_ALIAS:-}" ] || [ -z "${PLAYSTORE_KEY_PASSWORD:-}" ]; then
  echo "ERROR: please set PLAYSTORE_KEYSTORE_FILE, PLAYSTORE_KEYSTORE_PASSWORD, PLAYSTORE_KEY_ALIAS, and PLAYSTORE_KEY_PASSWORD"
  exit 1
fi

echo "Building release APK..."
./gradlew clean assembleRelease

UNSIGNED_APK="app/build/outputs/apk/release/app-release-unsigned.apk"
ALIGNED_APK="custom-termux-v1.0.0-release.apk"
SIGNED_APK="custom-termux-v1.0.0-playstore.apk"

if [ ! -f "$UNSIGNED_APK" ]; then
  echo "ERROR: unsigned APK not found: $UNSIGNED_APK"
  exit 1
fi

if ! command -v zipalign >/dev/null 2>&1; then
  echo "ERROR: zipalign not found in PATH"
  exit 1
fi

if ! command -v apksigner >/dev/null 2>&1; then
  echo "ERROR: apksigner not found in PATH"
  exit 1
fi

zipalign -v 4 "$UNSIGNED_APK" "$ALIGNED_APK"

apksigner sign --ks "$PLAYSTORE_KEYSTORE_FILE" \
    --ks-pass pass:"$PLAYSTORE_KEYSTORE_PASSWORD" \
    --key-pass pass:"$PLAYSTORE_KEY_PASSWORD" \
    --out "$SIGNED_APK" "$ALIGNED_APK"

echo "Play Store APK ready: $ANDROID_PROJECT/$SIGNED_APK"
