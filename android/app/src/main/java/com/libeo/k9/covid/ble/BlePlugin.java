package com.covi.app.ble;

import android.bluetooth.BluetoothAdapter;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;

import android.os.IBinder;
import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONArray;

import java.util.ArrayList;
import java.util.Arrays;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class BlePlugin implements MethodChannel.MethodCallHandler {
    /**
     * Flutter Channel Name and MethodChannel
     */
    private final String channel_name = "com.covi.app/ble";
    private MethodChannel channel;

    private Boolean bound = false;
    private BluetoothService service;

    private Context context;

    // Register our MethodChannel and MethodCallHandler
    public BlePlugin(FlutterEngine flutterEngine, Context context) {
        this.context = context;

        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), channel_name);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equalsIgnoreCase("start_bluetooth_service") && !
                bound) {
            context.bindService(new Intent(context, BluetoothService.class), bluetoothServiceConnection, Context.BIND_AUTO_CREATE);
            result.success(null);
        }

        if (call.method.equalsIgnoreCase("change_dh_key") &&
                bound) {
            byte[] dhKey = call.arguments();
            Log.d("BLE_PLUGIN", "Public DH key " + Arrays.toString(dhKey));
            Ble.setDH_Key(dhKey);
            result.success(null);
        }

        if (call.method.equalsIgnoreCase("stop_service") &&
                bound) {
            context.unbindService(bluetoothServiceConnection);
            result.success(null);
        }

        if (call.method.equalsIgnoreCase("get_received_dh_keys")) {
            ArrayList<byte[]> receivedDHKeys = Ble.getReceivedDHKeys();
            Ble.resetReceivedDHKeys();
            result.success(receivedDHKeys);
        }

        if (call.method.equalsIgnoreCase("bluetooth_exists")) {
            BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            boolean exists = true;

            if (bluetoothAdapter == null)
                exists = false;
            else if (!bluetoothAdapter.isEnabled())
                exists = false;

            result.success(exists);
        }
    }

    private ServiceConnection bluetoothServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            BluetoothService.LocalBinder binder = (BluetoothService.LocalBinder) iBinder;
            service = binder.getService();
            bound = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            bound = false;
        }
    };
}
