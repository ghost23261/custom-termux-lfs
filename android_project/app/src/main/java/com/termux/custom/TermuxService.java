package com.termux.custom;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.os.Binder;

public class TermuxService extends Service {
    private final IBinder binder = new LocalBinder();

    public class LocalBinder extends Binder {
        TermuxService getService() {
            return TermuxService.this;
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Initialize Termux environment
        return START_STICKY;
    }
}
