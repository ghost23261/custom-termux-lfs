package com.termux.custom;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.os.Binder;
import android.util.Log;

public class TermuxService extends Service {
    private static final String TAG = "TermuxService";
    private final IBinder binder = new LocalBinder();
    private RootfsInitializer rootfsInitializer;

    public class LocalBinder extends Binder {
        TermuxService getService() { return TermuxService.this; }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        rootfsInitializer = new RootfsInitializer(this);
        Log.i(TAG, "TermuxService created");
    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "TermuxService starting");

        // Initialize environment if not already done
        if (rootfsInitializer.isRootfsEmpty()) {
            Log.w(TAG, "Rootfs not initialized, attempting extraction");
            rootfsInitializer.initialize(null);
        }

        // Get rootfs path for use by terminal
        String rootfsPath = rootfsInitializer.getRootfsPath();
        Log.i(TAG, "Rootfs path: " + rootfsPath);

        return START_STICKY;
    }

    /**
     * Get the rootfs path for terminal access
     */
    public String getRootfsPath() {
        if (rootfsInitializer != null) {
            return rootfsInitializer.getRootfsPath();
        }
        return null;
    }

    /**
     * Get the RootfsInitializer instance
     */
    public RootfsInitializer getRootfsInitializer() {
        return rootfsInitializer;
    }
}

