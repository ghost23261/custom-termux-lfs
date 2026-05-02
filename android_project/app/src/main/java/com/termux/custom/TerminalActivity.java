package com.termux.custom;

import android.app.Activity;
import android.os.Bundle;

public class TerminalActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Create terminal view
        TerminalView terminalView = new TerminalView(this);
        setContentView(terminalView);
        
        // Start shell
        terminalView.startShell("/system/bin/sh", "-c", "exec /data/data/com.termux.custom/files/usr/bin/termux-launcher");
    }
}
