package com.covi.app.ble;

import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Locale;
import java.util.UUID;

class Ble {
    final static UUID NOTIFY_DESCRIPTOR_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");
    final static UUID SONAR_SERVICE_UUID = UUID.fromString("6637c77b-7efd-4476-a4bf-f81d08cd67e4");
    final static UUID SONAR_KEEPALIVE_CHARACTERISTIC_UUID = UUID.fromString("D802C645-5C7B-40DD-985A-9FBEE05FE85C");
    final static UUID SONAR_IDENTITY_CHARACTERISTIC_UUID = UUID.fromString("85BF337C-5B64-48EB-A5F7-A9FED135C972");

    private static byte[] DH_Key = "".getBytes();
    private static ArrayList<byte[]> receivedDHKeys = new ArrayList<>();

    static boolean isDeviceIdentifier(BluetoothGattCharacteristic characteristic) {
        return characteristic.getUuid() == SONAR_IDENTITY_CHARACTERISTIC_UUID;
    }

    static boolean isKeepAlive(BluetoothGattCharacteristic characteristic) {
        return characteristic.getUuid() == SONAR_KEEPALIVE_CHARACTERISTIC_UUID;
    }

    static boolean isNotifyDescriptor(BluetoothGattDescriptor descriptor) {
        return descriptor.getUuid() == NOTIFY_DESCRIPTOR_UUID;
    }

    public static byte[] getDH_Key() {
        return DH_Key;
    }

    public static void setDH_Key(byte[] DH_Descriptor) {
        Ble.DH_Key = DH_Descriptor;
    }

    public static String getNotificationServiceRunningTitle() {
        if (Locale.getDefault().getLanguage().equalsIgnoreCase("fr"))
            return "Covi";

        return "Covi";
    }

    public static String getNotificationServiceRunningBody() {
        if (Locale.getDefault().getLanguage().equalsIgnoreCase("fr"))
            return "Service bluetooth en opération.";

        return "Bluetooth service is running.";
    }

    public static ArrayList<byte[]> getReceivedDHKeys() {
        return receivedDHKeys;
    }

    public static void addToReceivedDhKeys(byte[] toAdd) {
        // don't add the key if its already contained in the array
        for (byte[] keys : receivedDHKeys) {
            if (Arrays.equals(keys, toAdd))
                return;
        }

        Log.d("BLE_PLUGIN", "Public DH key received " + Arrays.toString(toAdd));
        receivedDHKeys.add(toAdd);
    }

    public static void resetReceivedDHKeys() {
        Ble.receivedDHKeys = new ArrayList<byte[]>();
    }
}