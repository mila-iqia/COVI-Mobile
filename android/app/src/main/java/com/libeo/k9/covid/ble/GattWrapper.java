package com.covi.app.ble;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattServer;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

class GattWrapper {
    private BluetoothGattServer bluetoothGattServer;
    private Byte keepAliveValue = 0x00;
    private ArrayList<BluetoothDevice> subscribedDevices = new ArrayList<>();
    private BluetoothManager bluetoothManager;
    private BluetoothGattCharacteristic keepAliveCharacteristic;
    private NotifyKeepAliveSubscribersPeriodically notifyKeepAliveThread;

    private static String TAG = "GATTWRAPPER";

    GattWrapper(BluetoothGattServer bluetoothGattServer, BluetoothManager bluetoothManager, BluetoothGattCharacteristic keepAliveCharacteristic) {
        this.bluetoothGattServer = bluetoothGattServer;
        //this.keepAliveCharacteristic = keepAliveCharacteristic;
        this.bluetoothManager = bluetoothManager;

        //this.notifyKeepAliveThread = new NotifyKeepAliveSubscribersPeriodically();
    }

    private class NotifyKeepAliveSubscribersPeriodically extends Thread {
        public void run() {
            while (notifyKeepAliveThread.isAlive()) {
                synchronized (subscribedDevices) {
                    try {
                        sleep(8_000);
                        List<BluetoothDevice> connectedDevices = bluetoothManager.getConnectedDevices(BluetoothProfile.GATT);
                        ArrayList<BluetoothDevice> connectedSubscribers = new ArrayList<>();

                        for (BluetoothDevice device : connectedDevices) {
                            if (subscribedDevices.contains(device)) {
                                connectedSubscribers.add(device);
                            }
                        }

                        keepAliveValue++;
                        keepAliveCharacteristic.setValue(new byte[]{keepAliveValue});

                        for (BluetoothDevice device : connectedSubscribers) {
                            bluetoothGattServer.notifyCharacteristicChanged(device, keepAliveCharacteristic, false);
                        }
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    void respondToCharacteristicRead(BluetoothDevice device, int requestId, int offset, BluetoothGattCharacteristic characteristic) {
        if (Ble.isKeepAlive(characteristic)) {
            bluetoothGattServer.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, new byte[]{});
            return;
        }

        if (Ble.isDeviceIdentifier(characteristic)) {
            byte[] sharedKey = Ble.getDH_Key();
            sharedKey = Arrays.copyOfRange(sharedKey,offset, sharedKey.length);

            bluetoothGattServer.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, sharedKey);
        } else {
            bluetoothGattServer.sendResponse(device, requestId, BluetoothGatt.GATT_FAILURE, 0, new byte[]{});
        }
    }

    void responseToDescriptorWrite(BluetoothDevice device, BluetoothGattDescriptor descriptor, Boolean responseNeeded, int requestId) {
        // Verify if device sent a correct descriptor write
        Log.d(TAG, "Answer descriptor write with request");

        if (device == null || descriptor == null || !Ble.isNotifyDescriptor(descriptor) || !Ble.isKeepAlive(descriptor.getCharacteristic())) {
            Log.d(TAG, "Device could not subscribe to keep alive.");
            if (responseNeeded) {
                bluetoothGattServer.sendResponse(device, requestId, BluetoothGatt.GATT_FAILURE, 0, new byte[]{});
            }

            return;
        }

//        Log.d(TAG, "Device has subscribed to keep alive.");
        //  start  notifyKeepAliveSubscribersPeriodically coroutine if devices array was empty
//        if (subscribedDevices.isEmpty()) {
//            notifyKeepAliveThread = new NotifyKeepAliveSubscribersPeriodically();
//            notifyKeepAliveThread.start();
//        }

//        subscribedDevices.add(device);
    }

    void deviceDisconnected(BluetoothDevice device) {
        if (device == null) return;

        if (subscribedDevices.isEmpty()) {
            return;
        }

        subscribedDevices.remove(device);

        if (subscribedDevices.isEmpty()) {
            // stop the thread
            notifyKeepAliveThread = null;
        }
    }
}
