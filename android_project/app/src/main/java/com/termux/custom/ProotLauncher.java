package com.termux.custom;

import android.os.Build;
import android.util.Log;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Utility class to launch and manage proot-based shell environment
 */
public class ProotLauncher {
    private static final String TAG = "ProotLauncher";
    
    private final String rootfsPath;
    private final File proootBinary;
    private Process processs;
    
    /**
     * Initialize proot launcher with rootfs path
     * @param rootfsPath Absolute path to the extracted rootfs
     * @param prorotPath Absolute path to the proot binary
     */
    public ProotLauncher(String rootfsPath, String prorotPath) {
        this.rootfsPath = rootfsPath;
        this.proootBinary = new File(prorotPath);
    }
    
    /**
     * Launch proot shell with given command or interactive shell
     * @param enableDefaultCommand If true, uses /bin/bash; if false, uses /bin/sh
     * @return Process object, or null if failed to launch
     */
    public Process launchShell(boolean enableDefaultCommand) {
        try {
            List<String> command = buildProotCommand(enableDefaultCommand);
            
            ProcessBuilder pb = new ProcessBuilder(command);
            
            // Inherit parent environment and modify as needed
            pb.environment().put("HOME", "/root");
            pb.environment().put("PATH", "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin");
            pb.environment().put("TERM", "xterm");
            pb.environment().put("LANG", "en_US.UTF-8");
            
            // Redirect stderr into stdout for API levels below 26
            pb.redirectErrorStream(true);
            
            processs = pb.start();
            Log.i(TAG, "Proot shell launched successfully");
            
            return processs;
            
        } catch (IOException e) {
            Log.e(TAG, "Failed to launch proot shell", e);
            return null;
        }
    }
    
    /**
     * Launch proot and execute a specific command
     * @param command Command to execute inside proot
     * @return Process object, or null if failed to launch
     */
    public Process executeCommand(String... command) {
        try {
            List<String> fullCommand = buildProotCommand(false);
            fullCommand.add("-c");
            
            // Join command arguments
            StringBuilder cmdBuilder = new StringBuilder();
            for (String part : command) {
                if (cmdBuilder.length() > 0) {
                    cmdBuilder.append(" ");
                }
                cmdBuilder.append(part);
            }
            fullCommand.add(cmdBuilder.toString());
            
            ProcessBuilder pb = new ProcessBuilder(fullCommand);
            
            // Set environment
            pb.environment().put("HOME", "/root");
            pb.environment().put("PATH", "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin");
            pb.environment().put("TERM", "xterm");
            
            processs = pb.start();
            Log.i(TAG, "Command executed: " + cmdBuilder.toString());
            
            return processs;
            
        } catch (IOException e) {
            Log.e(TAG, "Failed to execute command in proot", e);
            return null;
        }
    }
    
    /**
     * Build the proot command with proper arguments
     * @param enableDefaultCommand If true, uses /bin/bash; if false, uses /bin/sh
     * @return List of command parts for ProcessBuilder
     */
    private List<String> buildProotCommand(boolean enableDefaultCommand) {
        List<String> command = new ArrayList<>();
        
        // Add proot binary
        command.add(proootBinary.getAbsolutePath());
        
        // Key proot options:
        // -r: Set the root filesystem
        // -w: Set the working directory
        // -b: Bind mount (can be used to access external storage if needed)
        // -L: Disable symlink translation (useful for some apps)
        // -p: Enable PTRACE (required for some debugging)
        
        command.add("-r");
        command.add(rootfsPath);
        
        command.add("-w");
        command.add("/root");
        
        // Optional: bind mount /system to access Android system libraries if needed
        // command.add("-b");
        // command.add("/system");
        
        // Optional: bind mount /data to access app data
        // command.add("-b");
        // command.add("/data");
        
        command.add("-0");  // Fake root (uid 0)
        
        // Add shell command
        if (enableDefaultCommand) {
            command.add("/bin/bash");
        } else {
            command.add("/bin/sh");
        }
        
        return command;
    }
    
    /**
     * Terminate the current proot process
     */
    public void terminate() {
        if (processs != null && isProcessAlive(processs)) {
            processs.destroy();
            Log.i(TAG, "Proot process terminated");
        }
    }
    
    /**
     * Force terminate the proot process
     */
    public void forceTerminate() {
        if (processs != null && isProcessAlive(processs)) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                processs.destroyForcibly();
                Log.i(TAG, "Proot process force terminated");
            } else {
                processs.destroy();
                Log.i(TAG, "Proot process terminated with destroy() on older API");
            }
        }
    }

    private boolean isProcessAlive(Process process) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return process.isAlive();
        }
        try {
            process.exitValue();
            return false;
        } catch (IllegalThreadStateException e) {
            return true;
        }
    }
    
    /**
     * Check if proot binary exists and is executable
     * @return true if proot binary is accessible
     */
    public boolean isProotAvailable() {
        return proootBinary.exists() && proootBinary.canExecute();
    }
}
