package com.covi.app;

import androidx.annotation.NonNull;

import com.covi.app.ble.BlePlugin;
import com.covi.app.ble.BluetoothService;
import com.covi.app.AppRetrain;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new BlePlugin(flutterEngine, getApplicationContext());
    new AppRetrain(flutterEngine, getApplicationContext(), this);
  }
}