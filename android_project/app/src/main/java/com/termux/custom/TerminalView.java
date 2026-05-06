package com.termux.custom;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.view.*;
import android.widget.*;
import java.io.*;

public class TerminalView extends LinearLayout {
    private TextView output;
    private EditText input;
    private ScrollView scroll;
    private PrintWriter writer;

    // LFS Slackware rootfs path (inside app private storage)
    private static final String APP_FILES   = "/data/data/com.termux.custom/files";
    private static final String LFS_ROOT    = APP_FILES + "/rootfs";
    private static final String TERMUX_PRE  = "/data/data/com.termux/files/usr";
    private static final String TERMUX_HOME = "/data/data/com.termux/files/home";

    public TerminalView(Context ctx) {
        super(ctx);
        setOrientation(VERTICAL);
        setBackgroundColor(Color.BLACK);

        scroll = new ScrollView(ctx);
        output = new TextView(ctx);
        output.setTextColor(Color.GREEN);
        output.setTypeface(Typeface.MONOSPACE);
        output.setTextSize(13);
        output.setPadding(16, 16, 16, 16);
        scroll.addView(output);

        input = new EditText(ctx);
        input.setTextColor(Color.GREEN);
        input.setBackgroundColor(Color.parseColor("#111111"));
        input.setTypeface(Typeface.MONOSPACE);
        input.setHint("$ enter command");
        input.setHintTextColor(Color.DKGRAY);
        input.setPadding(16, 8, 16, 8);

        addView(scroll, new LayoutParams(
            LayoutParams.MATCH_PARENT, 0, 1f));
        addView(input, new LayoutParams(
            LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));

        startShell();

        input.setOnEditorActionListener((v, id, event) -> {
            String cmd = input.getText().toString().trim();
            if (!cmd.isEmpty()) {
                append("$ " + cmd + "\n");
                writer.println(cmd);
                writer.flush();
                input.setText("");
                scroll.post(() -> scroll.fullScroll(View.FOCUS_DOWN));
            }
            return true;
        });
    }

    private void startShell() {
        try {
            // Use proot to chroot into LFS Slackware rootfs if available
            // Falls back to Termux bash, then system sh
            String[] cmd;
            boolean hasLFS    = new File(LFS_ROOT + "/bin/bash").exists();
            boolean hasProot  = new File(TERMUX_PRE + "/bin/proot").exists();
            boolean hasTermux = new File(TERMUX_PRE + "/bin/bash").exists();

            if (hasLFS && hasProot) {
                // Boot into full LFS Slackware environment via proot
                cmd = new String[]{
                    TERMUX_PRE + "/bin/proot",
                    "--rootfs=" + LFS_ROOT,
                    "-0",                          // fake root
                    "-w", "/root",
                    "-b", "/dev", "-b", "/proc", "-b", "/sys",
                    "-b", "/sdcard",
                    "/bin/bash", "--login"
                };
                append("Booting LFS Slackware rootfs...\n");
            } else if (hasTermux) {
                // Fall back to Termux bash with full env
                cmd = new String[]{TERMUX_PRE + "/bin/bash", "--login"};
                append("LFS rootfs not found. Using Termux environment.\n");
                append("Run install-termux.sh to set up LFS.\n\n");
            } else {
                cmd = new String[]{"/system/bin/sh"};
                append("Minimal shell mode.\n\n");
            }

            ProcessBuilder pb = new ProcessBuilder(cmd);
            pb.redirectErrorStream(true);
            pb.environment().put("TERM", "xterm-256color");
            pb.environment().put("HOME",
                hasLFS ? "/root" : TERMUX_HOME);
            pb.environment().put("PREFIX", TERMUX_PRE);
            pb.environment().put("PATH",
                (hasLFS ? "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:" : "") +
                TERMUX_PRE + "/bin:/system/bin");
            pb.environment().put("LD_LIBRARY_PATH",
                (hasLFS ? LFS_ROOT + "/lib:" + LFS_ROOT + "/usr/lib:" : "") +
                TERMUX_PRE + "/lib");
            pb.environment().put("TERMUX_VERSION", "1.0.0-lfs");
            pb.environment().put("LFS_ROOT", LFS_ROOT);

            Process proc = pb.start();
            writer = new PrintWriter(new BufferedWriter(
                new OutputStreamWriter(proc.getOutputStream())));

            append("Custom Termux LFS v1.0.0 | ARM64\n");
            append("================================\n\n");

            new Thread(() -> {
                try {
                    BufferedReader r = new BufferedReader(
                        new InputStreamReader(proc.getInputStream()));
                    String line;
                    while ((line = r.readLine()) != null) {
                        final String out = line + "\n";
                        post(() -> append(out));
                    }
                } catch (IOException e) {
                    post(() -> append("\n[session ended]\n"));
                }
            }).start();

        } catch (IOException e) {
            append("[Error: " + e.getMessage() + "]\n");
        }
    }

    private void append(String text) {
        output.append(text);
        scroll.post(() -> scroll.fullScroll(View.FOCUS_DOWN));
    }

    public void startShell(String... ignored) {}
}
