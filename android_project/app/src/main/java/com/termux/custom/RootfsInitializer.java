package com.termux.custom;

import android.content.Context;
import android.util.Log;

import java.io.File;
import java.util.Objects;

/**
 * Manages the initialization and setup of the root filesystem for the Termux environment
 */
public class RootfsInitializer {
    private static final String TAG = "RootfsInitializer";
    private static final String ROOTFS_DIR_NAME = "rootfs";
    private static final String ARCHIVE_FILE_NAME = "slackware_full_suite.tar.gz";
    
    private final Context context;
    private final File rootfsDir;
    private final File filesDir;
    
    public RootfsInitializer(Context context) {
        this.context = context;
        this.filesDir = context.getFilesDir();
        this.rootfsDir = new File(filesDir, ROOTFS_DIR_NAME);
    }
    
    /**
     * Check if the rootfs needs to be initialized
     * @return true if rootfs is empty and needs initialization
     */
    public boolean isRootfsEmpty() {
        if (!rootfsDir.exists()) {
            return true;
        }
        
        File[] files = rootfsDir.listFiles();
        return files == null || files.length == 0;
    }
    
    /**
     * Initialize the rootfs by extracting the archive if needed
     * @param onProgressUpdate Optional callback for progress updates
     * @return true if initialization successful or already exists
     */
    public boolean initialize(AssetExtractor.ProgressCallback onProgressUpdate) {
        if (!isRootfsEmpty()) {
            Log.i(TAG, "Rootfs already initialized");
            return true;
        }
        
        Log.i(TAG, "Initializing rootfs from asset archive");
        
        // Create rootfs directory
        if (!rootfsDir.exists() && !rootfsDir.mkdirs()) {
            Log.e(TAG, "Failed to create rootfs directory: " + rootfsDir.getAbsolutePath());
            return false;
        }
        
        // Extract tar.gz from assets
        boolean success = AssetExtractor.extractTarGzFromAssets(
                context,
                ARCHIVE_FILE_NAME,
                rootfsDir,
                onProgressUpdate
        );
        
        if (success) {
            Log.i(TAG, "Rootfs initialization successful");
            // Create necessary directories if they don't exist
            createSystemDirectories();
        } else {
            Log.e(TAG, "Rootfs initialization failed");
        }
        
        return success;
    }
    
    /**
     * Create necessary system directories within the rootfs
     */
    private void createSystemDirectories() {
        String[] dirs = {
                "bin", "sbin", "usr/bin", "usr/sbin", "usr/local/bin",
                "lib", "lib64", "usr/lib", "usr/lib64",
                "dev", "proc", "sys", "tmp", "var", "var/tmp", "var/log",
                "home", "root", "etc", "opt"
        };
        
        for (String dir : dirs) {
            File d = new File(rootfsDir, dir);
            if (!d.exists()) {
                if (d.mkdirs()) {
                    Log.d(TAG, "Created directory: " + dir);
                }
            }
        }
    }
    
    /**
     * Get the path to the rootfs directory
     * @return absolute path to rootfs directory
     */
    public String getRootfsPath() {
        return rootfsDir.getAbsolutePath();
    }
    
    /**
     * Get the rootfs directory File object
     * @return File object representing rootfs directory
     */
    public File getRootfsDir() {
        return rootfsDir;
    }
    
    /**
     * Get the size of the rootfs in bytes
     * @return size in bytes, or 0 if error
     */
    public long getRootfsSize() {
        return getDirectorySize(rootfsDir);
    }
    
    /**
     * Recursively calculate directory size
     * @param dir Directory to calculate size for
     * @return size in bytes
     */
    private long getDirectorySize(File dir) {
        long size = 0;
        if (dir.isDirectory()) {
            File[] files = dir.listFiles();
            if (files != null) {
                for (File file : files) {
                    size += getDirectorySize(file);
                }
            }
        } else {
            size = dir.length();
        }
        return size;
    }
    
    /**
     * Format bytes to human-readable format
     * @param bytes Size in bytes
     * @return Human-readable size string
     */
    public static String formatSize(long bytes) {
        if (bytes <= 0) return "0 B";
        final String[] units = new String[]{"B", "KB", "MB", "GB", "TB"};
        int digitGroups = (int) (Math.log10(bytes) / Math.log10(1024));
        return String.format("%.1f %s", bytes / Math.pow(1024, digitGroups), 
                units[digitGroups]);
    }
}
