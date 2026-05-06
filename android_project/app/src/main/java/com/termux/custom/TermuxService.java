package com.termux.custom;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import java.io.File;

public class TermuxService extends Service {
    private final IBinder binder = new LocalBinder();

    public class LocalBinder extends Binder {
        TermuxService getService() { return TermuxService.this; }
    }

    @Override
    public IBinder onBind(Intent intent) { return binder; }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        setupDirs();
        return START_STICKY;
    }

    private void setupDirs() {
        String base = "/data/data/com.termux.custom/files";
        for (String dir : new String[]{
            base+"/home", base+"/usr/bin",
            base+"/usr/lib", base+"/usr/etc"}) {
            new File(dir).mkdirs();
        }
    }
}
