#!/bin/bash

# Create Android APK Project
# This script creates an Android project to package our custom Termux

set -e

LFS="/mnt/samsung_ssd"
ANDROID_PROJECT="$LFS/android_project"
TERMUX_ROOT="$LFS/termux"

echo "Creating Android APK project..."

cd "$ANDROID_PROJECT"

# Create build.gradle (project level)
cat > build.gradle << 'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.2'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

# Create settings.gradle
cat > settings.gradle << 'EOF'
include ':app'
EOF

# Create gradle.properties
cat > gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
EOF

# Create app/build.gradle
cat > app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.termux.custom'
    compileSdk 34

    defaultConfig {
        applicationId "com.termux.custom"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.10.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
EOF

# Create AndroidManifest.xml
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.TermuxCustom"
        tools:targetApi="31">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.AppCompat.Light.NoActionBar">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".TermuxService"
            android:exported="false" />

    </application>

</manifest>
EOF

# Create MainActivity.java
cat > app/src/main/java/com/termux/custom/MainActivity.java << 'EOF'
package com.termux.custom;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class MainActivity extends Activity {

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
EOF

# Create TerminalActivity.java
cat > app/src/main/java/com/termux/custom/TerminalActivity.java << 'EOF'
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
EOF

# Create TermuxService.java
cat > app/src/main/java/com/termux/custom/TermuxService.java << 'EOF'
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
EOF

# Create TerminalView.java
cat > app/src/main/java/com/termux/custom/TerminalView.java << 'EOF'
package com.termux.custom;

import android.content.Context;
import android.view.View;
import android.widget.ScrollView;
import android.widget.LinearLayout;
import android.widget.EditText;
import android.graphics.Color;
import android.util.TypedValue;

public class TerminalView extends ScrollView {
    
    private LinearLayout layout;
    private EditText output;
    private EditText input;
    
    public TerminalView(Context context) {
        super(context);
        
        layout = new LinearLayout(context);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setBackgroundColor(Color.BLACK);
        
        output = new EditText(context);
        output.setBackgroundColor(Color.BLACK);
        output.setTextColor(Color.GREEN);
        output.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        output.setFocusable(false);
        output.setClickable(false);
        
        input = new EditText(context);
        input.setBackgroundColor(Color.BLACK);
        input.setTextColor(Color.GREEN);
        input.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        input.setHint(">");
        input.setHintTextColor(Color.GRAY);
        
        layout.addView(output);
        layout.addView(input);
        
        addView(layout);
    }
    
    public void startShell(String... command) {
        // Shell implementation would go here
        output.append("Custom Termux Shell Started\n");
        output.append("$ ");
    }
}
EOF

# Create activity_main.xml
cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp"
    android:background="#000000">

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="@string/app_name"
        android:textColor="#00FF00"
        android:textSize="24sp"
        android:gravity="center"
        android:layout_marginBottom="32dp" />

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Custom Termux Terminal"
        android:textColor="#00FF00"
        android:textSize="18sp"
        android:gravity="center"
        android:layout_marginBottom="32dp" />

    <Button
        android:id="@+id/launch_button"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Launch Terminal"
        android:textSize="18sp"
        android:layout_marginTop="32dp" />

</LinearLayout>
EOF

# Create strings.xml
mkdir -p app/src/main/res/values
cat > app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">Custom Termux</string>
</resources>
EOF

# Create resource files
mkdir -p app/src/main/res/xml
cat > app/src/main/res/xml/backup_rules.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="sharedpref" path="device_prefs.xml"/>
</full-backup-content>
EOF

cat > app/src/main/res/xml/data_extraction_rules.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="sharedpref" path="device_prefs.xml"/>
    </cloud-backup>
</data-extraction-rules>
EOF

# Create gradle wrapper
mkdir -p gradle/wrapper
cat > gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

echo "Android APK project created successfully!"
echo "Next: Build the APK"
