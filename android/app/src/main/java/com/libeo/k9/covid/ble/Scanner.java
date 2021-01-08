package com.covi.app.ble;

import android.content.Context;
import android.os.Build;
import android.os.ParcelUuid;
import android.util.Base64;
import android.util.Log;
import android.util.Pair;

import androidx.annotation.RequiresApi;

import com.polidea.rxandroidble2.scan.ScanFilter;
import com.polidea.rxandroidble2.RxBleClient;
import com.polidea.rxandroidble2.RxBleConnection;
import com.polidea.rxandroidble2.scan.ScanResult;
import com.polidea.rxandroidble2.scan.ScanSettings;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.UUID;
import java.util.stream.Collectors;

import io.reactivex.Single;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.BiFunction;

public class Scanner {
    private final String TAG = "SCANNER";

    private Context context;
    private ScanThread scanThread;

    /**
     * RxBle configuration
     */
    private RxBleClient rxBleClient;

    private int appleManufacturerId = 76;
    private byte[] encodedBackgroundIosServiceUuid = Base64.decode("AQAAAAAAAAAAAEAAAAAAAAA=", Base64.DEFAULT);

    private ScanSettings settings = getSettings();
    private ScanFilter serviceFilter = getServiceFilter();
    private ScanFilter sonarIphoneFilter = getIphoneFilter();
    private ScanThread scanTread = new ScanThread();

    private int scanIntervalLength = 2;
    private Disposable scanDisposable = null;

    /**
     * Devices & connections
     */
    private ArrayList<Pair<ScanResult, Integer>> devices = new ArrayList<>();
    private ArrayList<Disposable> connections = new ArrayList<>();

    /**
     * Create our Scanner and initialize the RxBleClient
     */
    Scanner(Context context) {
        this.context = context;
        rxBleClient = RxBleClient.create(context);
    }

    void start() {
        scanTread.start();
        Log.d(TAG, "Start listener thread");
    }

    private class ScanThread extends Thread {
        @RequiresApi(api = Build.VERSION_CODES.N)
        public void run() {
            while (isAlive()) {
                synchronized (devices) {
                    try {
                        scanDisposable = scan();
                        int attemps = 0;

                        Log.d(TAG, "Starting");
                        while (attemps++ < 10 && devices.isEmpty()) {
                            if (!isAlive()) return;
                            sleep(scanIntervalLength * 1_000);
                        }

                        // stop scanning
                        Log.d(TAG, "Stopping");
                        scanDisposable.dispose();
                        scanDisposable = null;

                        // Some devices are unable to connect while a scan is running
                        // or just after it finished
                        sleep(1000);

                        Log.d(TAG, "Found " + devices.size() + " devices");
                        devices.stream().distinct().collect(Collectors.toList()).forEach(i -> {
                            Log.d(TAG, "info on " + i.first.getBleDevice().getMacAddress() + ", RSSI : " + i.second);
                            connectToDevice(i.first, i.second);
                        });

                        // connections.clear();
                        devices.clear();

                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    private void connectToDevice(ScanResult scanResult, int txPowerAdvertising) {
        String macAdress = scanResult.getBleDevice().getMacAddress();

        UUID characteristicUUID = null;
        scanResult
                .getBleDevice()
                .establishConnection(false)
                .flatMapSingle(connection ->
                        read(connection, txPowerAdvertising)
                )
                .doOnSubscribe( connection ->
                        connections.add(connection)
                )
                .take(1)
                .blockingSubscribe(
                        event -> {
                            // send event.identifier
                            // to flutter.
                        },
                        throwable -> {
                            // Handle an error here.
                        }
                );
    }

    /*private Single<RxBleConnection> negotiateMTU(RxBleConnection connection) {
        // the overhead appears to be 2 bytes
        return connection.requestMtu(2 + BluetoothIdentifier.SIZE)
                .ignoreElement()
                .andThen(Single.just(connection));

    }*/

    private Single<ContactEvent> read(RxBleConnection connection, int txPower) {
        return Single.zip(
            connection.readCharacteristic(Ble.SONAR_IDENTITY_CHARACTERISTIC_UUID),
            connection.readRssi(),
            new BiFunction<byte[], Integer, ContactEvent>() {
                @Override
                public ContactEvent apply(byte[] characteristicValue, Integer rssi) throws Exception {
                    // https://iotandelectronics.wordpress.com/2016/10/07/how-to-calculate-distance-from-the-rssi-value-of-the-ble-beacon
                    // evaluate how far is the encounter in meters
                    float estimatedTxPower = -70;
                    int constantN = 2;
                    double distance = Math.pow(10, (estimatedTxPower - rssi)/(10 * constantN));

                    Log.v(TAG, "Encounter is at " + distance + " meters");

                    if (distance < 5) {
                        Ble.addToReceivedDhKeys(characteristicValue);
                    }
                    return new ContactEvent(characteristicValue, rssi, txPower, Calendar.getInstance().getTime());
                }
            }
        );
    }

    ScanFilter getIphoneFilter() {
        return new ScanFilter.Builder()
                .setServiceUuid(null)
                .setManufacturerData(
                        appleManufacturerId,
                        encodedBackgroundIosServiceUuid
                ).build();
    }

    ScanFilter getServiceFilter() {
        return new ScanFilter.Builder()
                .setServiceUuid(new ParcelUuid(Ble.SONAR_SERVICE_UUID))
                .build();
    }

    ScanSettings getSettings() {
        return new ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_POWER)
                .build();
    }

    Disposable scan() {
        return rxBleClient.scanBleDevices(
                settings,
                sonarIphoneFilter,
                serviceFilter
        ).subscribe(
                scanResult -> {
                    devices.add(new Pair<>(scanResult, scanResult.getScanRecord().getTxPowerLevel()));
                },
                throwable -> {
                    Log.d(TAG, "Error when scanning : " + throwable.getMessage());
                }
        );
    }

    private static class ContactEvent {
        public byte[] identifier;
        public int rssi;
        public int txPower;
        public Date timestamp;

        ContactEvent(byte[] identifier, int rssi, int txPower, Date timestamp) {
            this.identifier = identifier;
            this.rssi = rssi;
            this.txPower = txPower;
            this.timestamp = timestamp;
        }
    }
}
