package com.termux.custom;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.SpannableStringBuilder;
import android.view.*;
import android.widget.*;
import java.io.*;

public class TerminalView extends LinearLayout {
    private TextView output;
    private EditText input;
    private ScrollView scroll;
    private Process shell;
    private PrintWriter writer;
    private SpannableStringBuilder buffer = new SpannableStringBuilder();

    public TerminalView(Context ctx) {
        super(ctx);
        setOrientation(VERTICAL);
        setBackgroundColor(Color.BLACK);

        scroll = new ScrollView(ctx);
        output = new TextView(ctx);
        output.setTextColor(Color.GREEN);
        output.setTypeface(Typeface.MONOSPACE);
        output.setTextSize(13);
        output.setPadding(8,8,8,8);
        output.setText("Custom Termux LFS\n$ ");
        scroll.addView(output);

        input = new EditText(ctx);
        input.setTextColor(Color.GREEN);
        input.setBackgroundColor(Color.BLACK);
        input.setTypeface(Typeface.MONOSPACE);
        input.setHint("type command...");
        input.setHintTextColor(Color.DKGRAY);

        addView(scroll, new LayoutParams(
            LayoutParams.MATCH_PARENT, 0, 1f));
        addView(input, new LayoutParams(
            LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));

        startShell();

        input.setOnEditorActionListener((v, actionId, event) -> {
            String cmd = input.getText().toString().trim();
            if (!cmd.isEmpty()) {
                append("$ " + cmd + "\n");
                writer.println(cmd);
                writer.flush();
                input.setText("");
            }
            return true;
        });
    }

    private void startShell() {
        try {
            ProcessBuilder pb = new ProcessBuilder("/system/bin/sh");
            pb.redirectErrorStream(true);
            pb.environment().put("TERM", "xterm");
            pb.environment().put("HOME", "/data/data/com.termux.custom/files/home");
            pb.environment().put("PREFIX", "/data/data/com.termux.custom/files/usr");
            pb.environment().put("PATH",
                "/data/data/com.termux.custom/files/usr/bin:" +
                "/data/data/com.termux.custom/files/usr/bin/applets:" +
                "/system/bin");
            shell = pb.start();
            writer = new PrintWriter(
                new BufferedWriter(
                    new OutputStreamWriter(shell.getOutputStream())));

            new Thread(() -> {
                try {
                    BufferedReader reader = new BufferedReader(
                        new InputStreamReader(shell.getInputStream()));
                    String line;
                    while ((line = reader.readLine()) != null) {
                        final String out = line + "\n";
                        post(() -> append(out));
                    }
                } catch (IOException e) {
                    post(() -> append("[shell exited]\n"));
                }
            }).start();
        } catch (IOException e) {
            append("[error starting shell: " + e.getMessage() + "]\n");
        }
    }

    private void append(String text) {
        output.append(text);
        scroll.post(() -> scroll.fullScroll(View.FOCUS_DOWN));
    }

    public void startShell(String... cmd) { startShell(); }
}
