#!/bin/bash

##############################################################################
# Slackware LFS to Android APK Deployment Script
# 
# This script compresses the Slackware LFS/custom toolset into a tar.gz file
# suitable for bundling into an Android app's assets directory.
#
# Usage: ./compress_rootfs.sh [source_directory] [output_file]
#        Default: ./compress_rootfs.sh .slackware_full_suite slackware_full_suite.tar.gz
##############################################################################

set -e

# Configuration
SOURCE_DIR="${1:-.slackware_full_suite}"
OUTPUT_FILE="${2:-slackware_full_suite.tar.gz}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

function log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

function log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

function log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

function check_requirements() {
    log_info "Checking requirements..."
    
    if ! command -v tar &> /dev/null; then
        log_error "tar is not installed"
        return 1
    fi
    
    if ! command -v gzip &> /dev/null; then
        log_error "gzip is not installed"
        return 1
    fi
    
    log_success "All requirements met"
}

function validate_source() {
    if [ ! -d "$SOURCE_DIR" ]; then
        log_error "Source directory not found: $SOURCE_DIR"
        return 1
    fi
    
    local file_count=$(find "$SOURCE_DIR" -type f | wc -l)
    local dir_count=$(find "$SOURCE_DIR" -type d | wc -l)
    
    log_info "Source directory: $SOURCE_DIR"
    log_info "Files: $file_count, Directories: $dir_count"
    
    if [ "$file_count" -eq 0 ]; then
        log_warning "Source directory appears to be empty"
    fi
}

function calculate_size() {
    local path="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        du -sh "$path" | cut -f1
    else
        # Linux
        du -sh "$path" | cut -f1
    fi
}

function compress_rootfs() {
    log_info "Starting compression..."
    log_info "Source: $SOURCE_DIR"
    log_info "Output: $OUTPUT_FILE"
    
    local source_size=$(calculate_size "$SOURCE_DIR")
    log_info "Source size: $source_size"
    
    # Create tar.gz with compression
    # -C: Change to directory before compression
    # -z: Compress with gzip
    # -v: Verbose output
    # -f: Output file
    
    log_info "Compressing... (this may take a while for large filesystems)"
    
    tar -C "$(dirname "$SOURCE_DIR")" \
        -czf "$OUTPUT_FILE" \
        "$(basename "$SOURCE_DIR")"
    
    if [ $? -eq 0 ]; then
        local output_size=$(calculate_size "$OUTPUT_FILE")
        log_success "Compression completed"
        log_info "Output file: $OUTPUT_FILE"
        log_info "Compressed size: $output_size"
        
        # Calculate compression ratio
        local source_bytes=$(du -sb "$(dirname "$SOURCE_DIR")/$(basename "$SOURCE_DIR")" | cut -f1)
        local output_bytes=$(du -sb "$OUTPUT_FILE" | cut -f1)
        local ratio=$(echo "scale=2; ($output_bytes * 100) / $source_bytes" | bc)
        
        log_info "Compression ratio: ${ratio}%"
    else
        log_error "Compression failed"
        return 1
    fi
}

function copy_to_android_project() {
    # Try to find the Android project
    local android_project="${SCRIPT_DIR}/../android_project"
    local assets_dir="${android_project}/app/src/main/assets"
    
    if [ -d "$assets_dir" ]; then
        log_info "Found Android project at: $android_project"
        log_info "Copying to assets..."
        
        if cp "$OUTPUT_FILE" "$assets_dir/"; then
            log_success "Copied to: $assets_dir/$OUTPUT_FILE"
            log_info "The archive is now ready to be included in the APK"
        else
            log_error "Failed to copy to assets directory"
            return 1
        fi
    else
        log_warning "Android project not found at: $android_project"
        log_info "You can manually copy the archive to: android_project/app/src/main/assets/"
    fi
}

function main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Slackware to Android Compression${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    check_requirements || return 1
    echo
    
    validate_source || return 1
    echo
    
    log_info "Proceeding with compression..."
    echo
    
    compress_rootfs || return 1
    echo
    
    log_info "Attempting to copy to Android assets..."
    copy_to_android_project
    echo
    
    log_success "Compression process completed!"
    echo
    log_info "Next steps:"
    log_info "1. Verify the output file: $OUTPUT_FILE"
    log_info "2. Ensure it's in: android_project/app/src/main/assets/"
    log_info "3. Run 'gradle clean assembleRelease' to build the APK"
    echo
}

# Run main function
main "$@"
