package com.covi.app.ble;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import com.covi.app.R;

public class BluetoothService extends Service {

    final private int NOTIFICATION_ID = 1337;
    final private String CHANNEL_ID = "";

    private Scanner bleScanner;
    private boolean isScanRunning = false;

    private GattServer gattServer;
    private Advertise advertise = new Advertise();
    private boolean areGattAndAdvertiseRunning = false;

    /**
     * Bindings, allows our plugin to communicate with the service
     */
    private IBinder binder = new LocalBinder();

    public class LocalBinder extends Binder {
        BluetoothService getService() {
            return BluetoothService.this;
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    private void startGattAndAdvertise() {
        if (!areGattAndAdvertiseRunning) {
            areGattAndAdvertiseRunning = true;
            gattServer = new GattServer(this);
            gattServer.start();
            advertise.start();
        }
    }

    private void startScanner() {
        if (!isScanRunning) {
            isScanRunning = true;
            bleScanner = new Scanner(this);
            bleScanner.start();
        }
    }

    /**
     * OnCreate
     */
    @Override
    public void onCreate() {
        startGattAndAdvertise();
        startScanner();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        return START_STICKY;
    }
}
