package com.termux.custom;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class TerminalActivity extends AppCompatActivity {

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
