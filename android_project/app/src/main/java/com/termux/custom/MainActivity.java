package com.termux.custom;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button launchButton = findViewById(R.id.launch_button);
        launchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Start Termux service
                Intent serviceIntent = new Intent(MainActivity.this, TermuxService.class);
                startService(serviceIntent);
                
                // Launch terminal activity
                Intent terminalIntent = new Intent(MainActivity.this, TerminalActivity.class);
                startActivity(terminalIntent);
            }
        });
    }
}
