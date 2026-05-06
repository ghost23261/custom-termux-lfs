package com.termux.custom;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.util.Log;
import androidx.appcompat.app.AppCompatActivity;

/**
 * Main activity that handles the initialization and launch of the Termux environment
 */
public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";
    
    private Button launchButton;
    private ProgressBar progressBar;
    private TextView statusText;
    private RootfsInitializer rootfsInitializer;
    private boolean initialized = false;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        launchButton = findViewById(R.id.launch_button);
        progressBar = findViewById(R.id.progress_bar);
        statusText = findViewById(R.id.status_text);
        
        // Initialize rootfs initializer
        rootfsInitializer = new RootfsInitializer(this);
        
        // Check if initialization is needed
        if (rootfsInitializer.isRootfsEmpty()) {
            Log.i(TAG, "Rootfs not found, starting initialization");
            initializeRootfs();
        } else {
            Log.i(TAG, "Rootfs already exists, skipping extraction");
            setInitializationComplete();
        }
        
        launchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!initialized) {
                    showStatus("System still initializing...");
                    return;
                }
                
                // Start Termux service
                Intent serviceIntent = new Intent(MainActivity.this, TermuxService.class);
                startService(serviceIntent);
                
                // Launch terminal activity
                Intent terminalIntent = new Intent(MainActivity.this, TerminalActivity.class);
                startActivity(terminalIntent);
            }
        });
    }
    
    /**
     * Initialize the rootfs by extracting the archive
     */
    private void initializeRootfs() {
        launchButton.setEnabled(false);
        progressBar.setVisibility(View.VISIBLE);
        showStatus("Initializing environment...");
        
        // Run extraction in background thread
        new Thread(() -> {
            try {
                // Create progress callback
                AssetExtractor.ProgressCallback progressCallback = new AssetExtractor.ProgressCallback() {
                    @Override
                    public void onProgress(String entryName, long entriesExtracted) {
                        // Update UI on main thread
                        runOnUiThread(() -> {
                            String size = RootfsInitializer.formatSize(rootfsInitializer.getRootfsSize());
                            showStatus("Extracted: " + entryName + 
                                     "\nTotal size: " + size + 
                                     "\nEntries: " + entriesExtracted);
                        });
                    }
                };
                
                // Initialize rootfs
                boolean success = rootfsInitializer.initialize(progressCallback);
                
                // Update UI on main thread
                runOnUiThread(() -> {
                    if (success) {
                        Log.i(TAG, "Initialization completed successfully");
                        long sizeBytes = rootfsInitializer.getRootfsSize();
                        String size = RootfsInitializer.formatSize(sizeBytes);
                        showStatus("Initialization complete!\nRootfs size: " + size);
                        setInitializationComplete();
                    } else {
                        Log.e(TAG, "Initialization failed");
                        showStatus("Initialization failed. Check logs for details.");
                        progressBar.setVisibility(View.GONE);
                        launchButton.setEnabled(true);
                    }
                });
                
            } catch (Exception e) {
                Log.e(TAG, "Error during initialization", e);
                runOnUiThread(() -> {
                    showStatus("Error: " + e.getMessage());
                    progressBar.setVisibility(View.GONE);
                    launchButton.setEnabled(true);
                });
            }
        }).start();
    }
    
    /**
     * Update status text on UI
     */
    private void showStatus(String message) {
        if (statusText != null) {
            statusText.setText(message);
        }
    }
    
    /**
     * Mark initialization as complete and enable UI
     */
    private void setInitializationComplete() {
        initialized = true;
        progressBar.setVisibility(View.GONE);
        launchButton.setEnabled(true);
        showStatus("Ready to launch Termux");
    }
}
