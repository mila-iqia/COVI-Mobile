import 'dart:typed_data';

import 'package:covi/services/bluetooth_token_storage_service.dart';
import 'package:covi/utils/models/BluetoothToken.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../utils/constants.dart' as Constants;

/**
 * Classe used for communication with native code
 */
class BluetoothGattService {
  static const platform = const MethodChannel("com.covi.app/ble");

  static Future<int> startService() async {
    print("Starting service.");
    if (!Constants.isBluetoothServiceStarted) {
      bool bluetoothExists = await platform.invokeMethod("bluetooth_exists");

      if (bluetoothExists)
        await platform.invokeMethod("start_bluetooth_service");
      else {
        Logger().e("COULD NOT START BLUETOOTH SERVICE, IS BLUETOOTH ENABLED?");
        return -1;
      }
    }

    Constants.isBluetoothServiceStarted = true;
    return 0;
  }

  static void changeBluetoothTokenPublicKey(Uint8List newKey) {
    Logger().d("Changing DH key for new one $newKey");
    platform.invokeMethod("change_dh_key", newKey);
  }

  static void stopService() async {
    print("Stopping service.");
    if (Constants.isBluetoothServiceStarted) {
      await platform.invokeMethod("stop_bluetooth_service");
    }

    Constants.isBluetoothServiceStarted = false;
  }

  static Future<List<Uint8List>> pullSaveSharedKeysAndChangePublicKey() async {
    List<Uint8List> sharedKeys = await pullAndGetSharedKeys();
    BluetoothTokenStorageService.generateNewKeys();
    return sharedKeys;
  }

  static Future<List<Uint8List>> pullAndGetSharedKeys() async {
    List<Uint8List> receivedDHKeys =
        await platform.invokeListMethod("get_received_dh_keys");
    List<BluetoothToken> bluetoothTokens =
        await BluetoothTokenStorageService.fetchBluetoothTokens();

    for (var i = 0; i < receivedDHKeys.length; i++) {
      await BluetoothTokenStorageService.createSharedKey(
          bluetoothTokens.last, receivedDHKeys[i]);
    }

    return new List<Uint8List>();
  }
}
