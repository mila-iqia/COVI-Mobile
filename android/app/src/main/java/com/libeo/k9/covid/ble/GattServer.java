package com.covi.app.ble;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattServer;
import android.bluetooth.BluetoothGattServerCallback;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.util.Log;

import static android.bluetooth.BluetoothGattCharacteristic.PERMISSION_READ;
import static android.bluetooth.BluetoothGattCharacteristic.PERMISSION_WRITE;
import static android.bluetooth.BluetoothGattCharacteristic.PROPERTY_NOTIFY;
import static android.bluetooth.BluetoothGattCharacteristic.PROPERTY_READ;
import static android.bluetooth.BluetoothGattCharacteristic.PROPERTY_WRITE;
import static android.bluetooth.BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE;

public class GattServer {
    private final String TAG = "GATTSERVER";

    private Context context;
    private BluetoothManager bluetoothManager;
    private BluetoothGattServer bluetoothGattServer;
    private GattWrapper gattWrapper;
    private ServerThread serverThread = new ServerThread();

    private BluetoothGattCharacteristic identityCharacteristic;
    private BluetoothGattCharacteristic keepAliveCharacteristic;

    GattServer(Context context) {
        this.context = context;
        bluetoothManager = (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
    }

    void start() {
        serverThread.start();
        Log.d(TAG, "Start gatt server thread");
    }

    /**
     * Create our Gatt Service
     */
    private BluetoothGattService getGattService() {
        BluetoothGattService service = new BluetoothGattService(Ble.SONAR_SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY);

        identityCharacteristic = new BluetoothGattCharacteristic(
            Ble.SONAR_IDENTITY_CHARACTERISTIC_UUID,
            PROPERTY_READ,
            PERMISSION_READ
        );

        keepAliveCharacteristic = new BluetoothGattCharacteristic(
            Ble.SONAR_KEEPALIVE_CHARACTERISTIC_UUID,
            PROPERTY_READ + PROPERTY_WRITE + PROPERTY_WRITE_NO_RESPONSE + PROPERTY_NOTIFY,
            PERMISSION_READ + PERMISSION_WRITE
        );

        keepAliveCharacteristic.addDescriptor(new BluetoothGattDescriptor(
            Ble.NOTIFY_DESCRIPTOR_UUID,
            PERMISSION_READ + PERMISSION_WRITE
        ));

        service.addCharacteristic(identityCharacteristic);
        service.addCharacteristic(keepAliveCharacteristic);

        return service;
    }

    private class ServerThread extends Thread {
        public void run() {
            /**
             * Callback for the GattServer
             */
            BluetoothGattServerCallback gattCallback = new BluetoothGattServerCallback() {
                @Override
                public void onConnectionStateChange(BluetoothDevice device, int status, int newState) {
                    super.onConnectionStateChange(device, status, newState);

                    if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                        gattWrapper.deviceDisconnected(device);
                    }
                }

                @Override
                public void onServiceAdded(int status, BluetoothGattService service) {
                    super.onServiceAdded(status, service);

                    Log.d(TAG, "BLE service added successfully");
                }

                @Override
                public void onCharacteristicReadRequest(BluetoothDevice device, int requestId, int offset, BluetoothGattCharacteristic characteristic) {
                    super.onCharacteristicReadRequest(device, requestId, offset, characteristic);

                    gattWrapper.respondToCharacteristicRead(device, requestId, offset, characteristic);
                }

                @Override
                public void onCharacteristicWriteRequest(BluetoothDevice device, int requestId, BluetoothGattCharacteristic characteristic, boolean preparedWrite, boolean responseNeeded, int offset, byte[] value) {
                    super.onCharacteristicWriteRequest(device, requestId, characteristic, preparedWrite, responseNeeded, offset, value);
                }

                @Override
                public void onDescriptorWriteRequest(BluetoothDevice device, int requestId, BluetoothGattDescriptor descriptor, boolean preparedWrite, boolean responseNeeded, int offset, byte[] value) {
                    super.onDescriptorWriteRequest(device, requestId, descriptor, preparedWrite, responseNeeded, offset, value);

                    gattWrapper.responseToDescriptorWrite(device, descriptor, responseNeeded, requestId);
                }

                @Override
                public void onDescriptorReadRequest(BluetoothDevice device, int requestId, int offset, BluetoothGattDescriptor descriptor) {
                    super.onDescriptorReadRequest(device, requestId, offset, descriptor);
                }

                @Override
                public void onNotificationSent(BluetoothDevice device, int status) {
                    super.onNotificationSent(device, status);
                }

                @Override
                public void onMtuChanged(BluetoothDevice device, int mtu) {
                    super.onMtuChanged(device, mtu);
                }

                @Override
                public void onExecuteWrite(BluetoothDevice device, int requestId, boolean execute) {
                    super.onExecuteWrite(device, requestId, execute);
                }
            };

            bluetoothGattServer = bluetoothManager.openGattServer(context, gattCallback);
            bluetoothGattServer.addService(getGattService());

            gattWrapper = new GattWrapper(bluetoothGattServer, bluetoothManager, keepAliveCharacteristic);
        }
    }
}
