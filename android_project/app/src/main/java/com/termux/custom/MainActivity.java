package com.termux.custom;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.LinearLayout;
import android.graphics.Color;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        LinearLayout layout = new LinearLayout(this);
        layout.setBackgroundColor(Color.BLACK);
        
        TextView tv = new TextView(this);
        tv.setTextColor(Color.GREEN);
        tv.setTextSize(16);
        tv.setText("Custom Termux LFS\n$ Ready");
        tv.setPadding(20, 20, 20, 20);
        
        layout.addView(tv);
        setContentView(layout);
    }
}
