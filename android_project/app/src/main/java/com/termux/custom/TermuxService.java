package com.termux.custom;

import android.app.Service;
import android.content.Intent;
import android.os.*;
import java.io.*;

public class TermuxService extends Service {
    private final IBinder binder = new LocalBinder();

    public class LocalBinder extends Binder {
        TermuxService getService() { return TermuxService.this; }
    }

    @Override public IBinder onBind(Intent i) { return binder; }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        new Thread(this::setupEnvironment).start();
        return START_STICKY;
    }

    private void setupEnvironment() {
        String base = "/data/data/com.termux.custom/files";
        // Create required dirs
        for (String d : new String[]{
            base+"/home", base+"/rootfs",
            base+"/usr/bin", base+"/usr/lib",
            base+"/usr/etc", base+"/usr/tmp"}) {
            new File(d).mkdirs();
        }
        // Run install script if rootfs not yet set up
        File installScript = new File(base + "/install-termux.sh");
        File rootfs = new File(base + "/rootfs/bin/bash");
        if (installScript.exists() && !rootfs.exists()) {
            try {
                new ProcessBuilder(
                    "/data/data/com.termux/files/usr/bin/bash",
                    installScript.getAbsolutePath())
                    .redirectErrorStream(true)
                    .start();
            } catch (IOException ignored) {}
        }
    }
}
