package com.covi.app.ble;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.os.ParcelUuid;
import android.util.Log;

public class Advertise {
    static String TAG = "ADVERTISE";

    BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

//    NHS VERSION
    AdvertiseData advertiseData = new AdvertiseData.Builder()
            .addServiceUuid(new ParcelUuid(Ble.SONAR_SERVICE_UUID))
            .setIncludeDeviceName(false)
            .setIncludeTxPowerLevel(true)
            .build();

    AdvertiseSettings settings = new AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_POWER)
            .setConnectable(true)
            .setTimeout(0)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .build();

    void start() {
        Log.d(TAG, "start bluetooth advertising");

        BluetoothLeAdvertiser bluetoothLeAdvertiser = mBluetoothAdapter.getBluetoothLeAdvertiser();

        // real
        bluetoothLeAdvertiser.startAdvertising(settings, advertiseData, callback);
    }

    void stop() {
        Log.d(TAG, "stop bluetooth advertising");
        BluetoothLeAdvertiser bluetoothLeAdvertiser = mBluetoothAdapter.getBluetoothLeAdvertiser();
        bluetoothLeAdvertiser.stopAdvertising(callback);
    }

    private AdvertiseCallback callback = new AdvertiseCallback() {
        @Override
        public void onStartSuccess(AdvertiseSettings settingsInEffect) {
            Log.d(TAG, "BLE advertisement added successfully");
        }

        @Override
        public void onStartFailure(int errorCode) {
            Log.e(TAG, "Failed to add BLE advertisement, reason: " + errorCode);
        }
    };
}
