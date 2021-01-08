package com.covi.app;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * App retrain is used to keep the application opened when user press the back button
 */
public class AppRetrain implements MethodChannel.MethodCallHandler {
  private final String channel_name = "com.covi.app/app_retain";
  private MethodChannel channel;
  private Context context;
  private Activity activity;


  // Register our MethodChannel and MethodCallHandler
  public AppRetrain(FlutterEngine flutterEngine, Context context, Activity activity) {
    this.context = context;
    this.activity = activity;

    channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), channel_name);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if (call.method.equalsIgnoreCase("sendToBackground")) {
      activity.moveTaskToBack(true);
      result.success(null);
    }
  }
}