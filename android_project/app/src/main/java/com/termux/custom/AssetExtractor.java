package com.termux.custom;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.GZIPInputStream;

import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;

/**
 * Utility class to extract tar.gz files from Android assets to app's internal storage
 */
public class AssetExtractor {
    private static final String TAG = "AssetExtractor";
    private static final int BUFFER_SIZE = 8192;
    
    /**
     * Extract a tar.gz file from assets to the destination directory
     * 
     * @param context Android context
     * @param assetFileName Name of the tar.gz file in assets directory
     * @param destinationDir Destination directory to extract to
     * @param onProgressUpdate Callback for progress updates (optional)
     * @return true if extraction successful, false otherwise
     */
    public static boolean extractTarGzFromAssets(
            Context context,
            String assetFileName,
            File destinationDir,
            ProgressCallback onProgressUpdate) {
        
        if (!destinationDir.exists()) {
            destinationDir.mkdirs();
        }
        
        AssetManager assetManager = context.getAssets();
        
        try (InputStream inputStream = assetManager.open(assetFileName)) {
            return extractTarGz(inputStream, destinationDir, onProgressUpdate);
        } catch (IOException e) {
            Log.e(TAG, "Error extracting asset: " + assetFileName, e);
            return false;
        }
    }
    
    /**
     * Extract a tar.gz file from InputStream
     * 
     * @param inputStream Input stream containing tar.gz data
     * @param destinationDir Destination directory to extract to
     * @param onProgressUpdate Callback for progress updates (optional)
     * @return true if extraction successful, false otherwise
     */
    public static boolean extractTarGz(
            InputStream inputStream,
            File destinationDir,
            ProgressCallback onProgressUpdate) {
        
        if (!destinationDir.exists()) {
            destinationDir.mkdirs();
        }
        
        try (BufferedInputStream bufferedInput = new BufferedInputStream(inputStream);
             GZIPInputStream gzipInput = new GZIPInputStream(bufferedInput);
             TarArchiveInputStream tarInput = new TarArchiveInputStream(gzipInput)) {
            
            TarArchiveEntry entry;
            long extractedCount = 0;
            
            while ((entry = tarInput.getNextTarEntry()) != null) {
                File file = new File(destinationDir, entry.getName());
                
                if (entry.isDirectory()) {
                    file.mkdirs();
                } else {
                    // Create parent directories if needed
                    File parent = file.getParentFile();
                    if (parent != null && !parent.exists()) {
                        parent.mkdirs();
                    }
                    
                    try (BufferedOutputStream out = new BufferedOutputStream(
                            new FileOutputStream(file))) {
                        byte[] buffer = new byte[BUFFER_SIZE];
                        int bytesRead;
                        while ((bytesRead = tarInput.read(buffer)) != -1) {
                            out.write(buffer, 0, bytesRead);
                        }
                    }
                    
                    // Set file permissions
                    file.setExecutable((entry.getMode() & 0111) != 0);
                }
                
                extractedCount++;
                
                if (onProgressUpdate != null) {
                    onProgressUpdate.onProgress(entry.getName(), extractedCount);
                }
                
                Log.d(TAG, "Extracted: " + entry.getName());
            }
            
            Log.i(TAG, "Successfully extracted " + extractedCount + " entries to " + 
                  destinationDir.getAbsolutePath());
            return true;
            
        } catch (IOException e) {
            Log.e(TAG, "Error extracting tar.gz file", e);
            return false;
        }
    }
    
    /**
     * Callback interface for extraction progress updates
     */
    public interface ProgressCallback {
        void onProgress(String entryName, long entriesExtracted);
    }
}
