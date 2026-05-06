#!/bin/bash

################################################################################
# UNIFIED BUILD SCRIPT FOR CUSTOM TERMUX APK
# 
# This script handles the complete build process:
# - Prerequisite verification
# - Directory setup
# - Gradle wrapper configuration
# - APK compilation
# - Distribution packaging
#
# Usage: bash scripts/build.sh [--clean] [--skip-gradle] [--fdroid]
################################################################################

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ANDROID_PROJECT="$PROJECT_ROOT/android_project"
OUTPUT_DIR="$PROJECT_ROOT/output"
BUILD_LOG="$OUTPUT_DIR/build.log"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build flags
CLEAN_BUILD=false
SKIP_GRADLE=false
FDROID_MODE=false

# ============================================================================
# FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_header() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  $1"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --skip-gradle)
                SKIP_GRADLE=true
                shift
                ;;
            --fdroid)
                FDROID_MODE=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# ============================================================================
# PREREQUISITE CHECKS
# ============================================================================

check_prerequisites() {
    print_header "CHECKING PREREQUISITES"

    local missing_tools=()

    # Check Java
    if command_exists java; then
        JAVA_VERSION=$(java -version 2>&1 | grep "version" | head -1)
        log_success "Java found: $JAVA_VERSION"
    else
        log_error "Java not found"
        missing_tools+=("java")
    fi

    # Check Git
    if command_exists git; then
        log_success "Git found"
    else
        log_error "Git not found"
        missing_tools+=("git")
    fi

    # Check if gradle wrapper exists or gradle is available
    if [ -f "$ANDROID_PROJECT/gradlew" ] || command_exists gradle; then
        log_success "Gradle found"
    else
        log_warning "Gradle not found locally, will be set up"
    fi

    # Check disk space
    AVAILABLE_SPACE=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
    if [ "$AVAILABLE_SPACE" -lt 5242880 ]; then  # 5GB in KB
        log_error "Insufficient disk space (need 5GB+, have $(numfmt --to=iec $((AVAILABLE_SPACE * 1024))) )"
        exit 1
    fi
    log_success "Disk space adequate: $(numfmt --to=iec $((AVAILABLE_SPACE * 1024)))"

    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        echo ""
        echo "Install missing tools with:"
        echo "  sudo apt update && sudo apt install -y default-jdk git"
        exit 1
    fi

    log_success "All prerequisites met"
}

# ============================================================================
# DIRECTORY SETUP
# ============================================================================

setup_directories() {
    print_header "SETTING UP DIRECTORIES"

    # Create main directories
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$ANDROID_PROJECT/app/src/main/java/com/termux/custom"
    mkdir -p "$ANDROID_PROJECT/app/src/main/res/layout"
    mkdir -p "$ANDROID_PROJECT/app/src/main/res/values"
    mkdir -p "$ANDROID_PROJECT/app/src/main/res/xml"
    mkdir -p "$ANDROID_PROJECT/gradle/wrapper"
    
    log_success "Directory structure created"
}

# ============================================================================
# GRADLE WRAPPER SETUP
# ============================================================================

setup_gradle_wrapper() {
    print_header "SETTING UP GRADLE WRAPPER"

    cd "$ANDROID_PROJECT"

    # Check if gradlew already exists
    if [ -f "gradlew" ]; then
        log_success "Gradle wrapper already exists"
        return 0
    fi

    log_info "Downloading Gradle wrapper..."

    # Download gradle wrapper files
    mkdir -p gradle/wrapper

    # Download gradle-wrapper.jar
    if command_exists wget; then
        wget -q https://raw.githubusercontent.com/gradle/gradle/v8.4.0/gradle/wrapper/gradle-wrapper.jar \
            -O gradle/wrapper/gradle-wrapper.jar
    elif command_exists curl; then
        curl -s -o gradle/wrapper/gradle-wrapper.jar \
            https://raw.githubusercontent.com/gradle/gradle/v8.4.0/gradle/wrapper/gradle-wrapper.jar
    else
        log_error "Neither wget nor curl found"
        return 1
    fi

    # Create gradlew script
    cat > gradlew << 'GRADLE_SCRIPT'
#!/bin/sh

##############################################################################
## Gradle start up script for UN*X
##############################################################################

PRG="$0"
while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done

SAVED="`pwd`"
cd "`dirname \"$PRG\"`/" >/dev/null
APP_HOME="`pwd -P`"
cd "$SAVED" >/dev/null

APP_NAME="Gradle"
APP_BASE_NAME=`basename "$0"`

DEFAULT_JVM_OPTS="-Xmx64m -Xms64m"

CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar

exec java $DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS \
    "-Dorg.gradle.appname=$APP_BASE_NAME" \
    -classpath "$CLASSPATH" \
    org.gradle.wrapper.GradleWrapperMain "$@"
GRADLE_SCRIPT

    chmod +x gradlew

    # Create gradle-wrapper.properties
    cat > gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

    log_success "Gradle wrapper configured"
}

# ============================================================================
# BUILD APK
# ============================================================================

build_apk() {
    print_header "BUILDING APK"

    cd "$ANDROID_PROJECT"

    if [ "$CLEAN_BUILD" = true ]; then
        log_info "Performing clean build..."
        ./gradlew clean 2>&1 | tee -a "$BUILD_LOG"
    fi

    if [ "$SKIP_GRADLE" = true ]; then
        log_warning "Skipping Gradle build (--skip-gradle flag set)"
        return 0
    fi

    log_info "Compiling APK (this may take several minutes)..."
    
    if ./gradlew assembleDebug 2>&1 | tee -a "$BUILD_LOG"; then
        log_success "APK build completed successfully"
        return 0
    else
        log_error "APK build failed - check build.log for details"
        return 1
    fi
}

# ============================================================================
# VERIFY APK
# ============================================================================

verify_apk() {
    print_header "VERIFYING APK"

    APK_FILE="$ANDROID_PROJECT/app/build/outputs/apk/debug/app-debug.apk"

    if [ ! -f "$APK_FILE" ]; then
        log_error "APK not found at: $APK_FILE"
        return 1
    fi

    # Check file size
    APK_SIZE=$(du -h "$APK_FILE" | cut -f1)
    log_success "APK size: $APK_SIZE"

    # Verify APK structure
    if command_exists unzip; then
        if unzip -t "$APK_FILE" > /dev/null 2>&1; then
            log_success "APK structure valid"
        else
            log_error "APK structure invalid"
            return 1
        fi
    fi

    # Check for AndroidManifest.xml
    if unzip -l "$APK_FILE" | grep -q "AndroidManifest.xml"; then
        log_success "AndroidManifest.xml found"
    else
        log_error "AndroidManifest.xml not found in APK"
        return 1
    fi

    # Check for classes.dex
    if unzip -l "$APK_FILE" | grep -q "classes.dex"; then
        log_success "Compiled classes found (classes.dex)"
    else
        log_warning "classes.dex not found (may be OK for minimal APK)"
    fi

    return 0
}

# ============================================================================
# PACKAGE FOR DISTRIBUTION
# ============================================================================

package_distribution() {
    print_header "PACKAGING FOR DISTRIBUTION"

    APK_FILE="$ANDROID_PROJECT/app/build/outputs/apk/debug/app-debug.apk"
    DIST_DIR="$OUTPUT_DIR/distribution"
    DIST_APK="$DIST_DIR/custom-termux.apk"

    mkdir -p "$DIST_DIR"

    # Copy APK to distribution folder
    if [ -f "$APK_FILE" ]; then
        cp "$APK_FILE" "$DIST_APK"
        log_success "APK copied to distribution: $DIST_APK"
    else
        log_error "Source APK not found"
        return 1
    fi

    # Create version info
    cat > "$DIST_DIR/VERSION.txt" << EOF
Custom Termux v1.0.0
Build Date: $(date '+%Y-%m-%d %H:%M:%S')
Target Android: API 24-34 (Android 7.0-14)
Build Status: ✓ Success
CommitOID: $(cd "$PROJECT_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")
EOF

    log_success "Version info created"

    # Create installation guide
    if [ ! -f "$DIST_DIR/INSTALL.md" ]; then
        cat > "$DIST_DIR/INSTALL.md" << 'EOF'
# Installation Guide

## Method 1: Direct APK Installation

1. Transfer APK to Android device
2. Enable "Install from unknown sources" in Settings
3. Open file and install

## Method 2: ADB Installation

```bash
adb install custom-termux.apk
```

## Method 3: F-Droid

See FDROID_SETUP.md for private F-Droid repository setup

## Verification

After installation, the app should appear in your app drawer as "Custom Termux"
EOF
        log_success "Installation guide created"
    fi

    # Create README for distribution
    if [ ! -f "$DIST_DIR/README.txt" ]; then
        cat > "$DIST_DIR/README.txt" << EOF
CUSTOM TERMUX v1.0.0
====================

Build Status: ✓ Complete
Build Date: $(date)

CONTENTS:
- custom-termux.apk: Main application
- VERSION.txt: Version information
- INSTALL.md: Installation instructions

QUICK START:
1. Install APK on Android device (API 24+)
2. Grant storage permissions when prompted
3. Launch app from app drawer

For full documentation, see README.md in project root.
EOF
        log_success "Distribution README created"
    fi

    return 0
}

# ============================================================================
# F-DROID DEPLOYMENT (OPTIONAL)
# ============================================================================

deploy_fdroid() {
    if [ "$FDROID_MODE" = false ]; then
        return 0
    fi

    print_header "F-DROID DEPLOYMENT MODE"

    if ! command_exists fdroid; then
        log_warning "F-Droid server tools not installed"
        log_info "Install with: sudo apt install -y fdroidserver"
        return 0
    fi

    DIST_APK="$OUTPUT_DIR/distribution/custom-termux.apk"
    FDROID_DIR="${FDROID_REPO_DIR:-/var/www/fdroid}"

    if [ ! -f "$DIST_APK" ]; then
        log_error "Distribution APK not found"
        return 1
    fi

    log_info "Preparing F-Droid repository..."
    mkdir -p "$FDROID_DIR/repo"
    cp "$DIST_APK" "$FDROID_DIR/repo/"

    log_success "APK prepared for F-Droid at: $FDROID_DIR/repo/"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    parse_args "$@"

    print_header "CUSTOM TERMUX APK BUILD SYSTEM"

    check_prerequisites
    setup_directories
    setup_gradle_wrapper
    
    if ! build_apk; then
        log_error "Build failed"
        exit 1
    fi

    if ! verify_apk; then
        log_error "APK verification failed"
        exit 1
    fi

    if ! package_distribution; then
        log_error "Distribution packaging failed"
        exit 1
    fi

    deploy_fdroid

    print_header "BUILD COMPLETE ✓"
    echo ""
    echo "Output files:"
    echo "  APK: $OUTPUT_DIR/distribution/custom-termux.apk"
    echo "  Build log: $BUILD_LOG"
    echo ""
    echo "Next steps:"
    echo "  1. Transfer APK to Android device"
    echo "  2. Enable 'Unknown sources' in settings"
    echo "  3. Install and launch the app"
    echo ""
    echo "Or deploy to F-Droid:"
    echo "  bash scripts/build.sh --fdroid"
    echo ""
}

# Execute main function
main "$@"
