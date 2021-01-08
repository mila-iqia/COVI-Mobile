import 'dart:convert';
import 'dart:typed_data';

import 'package:covi/services/bluetooth_gatt_service.dart';
import 'package:covi/utils/encrypt.dart';
import 'package:covi/utils/models/encounter.dart';
import 'package:covi/utils/models/BluetoothToken.dart';
import 'package:covi/utils/models/mailboxMessage.dart';
import 'package:covi/utils/settings.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:logger/logger.dart';

/**
 * the most important file of the project : registers encounters
 */
class BluetoothTokenStorageService {
  static String _getFileName() => "dh_keys";

  /**
   * Should be executed every 15 minutes or so,
   * generate a new bluetooth token to share
   */
  static Future<BluetoothToken> generateNewKeys() async {
    final secretKey = await ScalarMult.generateSecretKey();
    final publicKey = await ScalarMult.computePublicKey(secretKey);
    BluetoothToken bluetoothToken =
        new BluetoothToken(DateTime.now(), secretKey, publicKey);

    List<BluetoothToken> bluetoothTokensHistory = await fetchBluetoothTokens();

    Logger().v(
        "[Bluetooth_Token_Storage_Service] Generate new bluetooth token keys...");

    bluetoothTokensHistory.add(bluetoothToken);
    String bluetoothTokensJson = json.encode(bluetoothTokensHistory);

    // Generate an IV for encryption
    IV encryptionIV = await CryptUtils.getIV();

    // Encrypt the settings
    String encryptedTokens =
        await CryptUtils.encryptString(bluetoothTokensJson, iv: encryptionIV);

    FlutterSecureStorage secureStorage = new FlutterSecureStorage();
    await secureStorage.write(key: _getFileName(), value: encryptedTokens);
    await secureStorage.write(
        key: _getFileName() + "-IV", value: encryptionIV.base64);

    BluetoothGattService.changeBluetoothTokenPublicKey(publicKey);

    return bluetoothToken;
  }

  /**
   * return the list of bluetooth tokens
   */
  static Future<List<BluetoothToken>> fetchBluetoothTokens() async {
    FlutterSecureStorage secureStorage = new FlutterSecureStorage();
    String encryptedKeys = await secureStorage.read(key: _getFileName());
    String ivBase64 = await secureStorage.read(key: _getFileName() + "-IV");

    IV iv = ivBase64 != null ? IV.fromBase64(ivBase64) : null;

    // Check if we have settings saved already
    if (encryptedKeys != null) {
      String keysJson;

      // Always use the new key, otherwise try the old key
      try {
        keysJson = await CryptUtils.decryptString(encryptedKeys, iv: iv);
      } catch (e) {
        keysJson =
            await CryptUtils.decryptStringWithOldKey(encryptedKeys, iv: iv);
      }

      // Convert the JSON into a list of BluetoothTokens
      if (keysJson != null) {
        List<dynamic> locs = json.decode(keysJson);
        return locs.map((loc) => BluetoothToken.fromJson(loc)).toList();
      }
    }

    return [];
  }

  /**
   * Add a shared key when two cellphone communicates
   */
  static Future<void> createSharedKey(
      BluetoothToken localKey, Uint8List clientPublicKey) async {
    final Uint8List sharedKey = await ScalarMult.computeSharedSecret(
        localKey.privateKey, clientPublicKey);

    Logger().v('''[Bluetooth_Token_Storage_Service]
    local private key ${localKey.privateKey}
    local public key ${localKey.publicKey}
    client public key ${clientPublicKey}
    shared key ${sharedKey}
    ''');

    // add the shared key to the good local place
    List<BluetoothToken> bluetoothTokensHistory = await fetchBluetoothTokens();
    int bluetoothTokenIndex = bluetoothTokensHistory.indexWhere((element) =>
        new String.fromCharCodes(element.publicKey) ==
        new String.fromCharCodes(localKey.publicKey));

    SettingsManager settingsManager = new SettingsManager();
    await settingsManager.loadSettings();

    bluetoothTokensHistory[bluetoothTokenIndex].encounters.add(new Encounter(
        sharedKey,
        new MailboxMessage(
                1,
                0,
                0,
                settingsManager.settings.user_data.newSymptomaticRisk,
                settingsManager.settings.user_data.oldSymptomaticRisk)
            .getData(),
        DateTime.parse("1970-01-01")));

    String bluetoothTokensHistoryJson = json.encode(bluetoothTokensHistory);

    // Encrypt the settings
    String encryptedTokens =
        await CryptUtils.encryptString(bluetoothTokensHistoryJson);

    // Save it
    FlutterSecureStorage secureStorage = new FlutterSecureStorage();
    await secureStorage.write(key: _getFileName(), value: encryptedTokens);
  }

  /**
   * override bluetooth tokens with new ones. Should probable only be used for testing purpose.
   */
  static Future<void> addMultiple(List<BluetoothToken> encountersToAdd) async {
    String encountersJson = jsonEncode(encountersToAdd);
    // Encrypt the settings
    String encryptedTokens = await CryptUtils.encryptString(encountersJson);

    // Save it
    FlutterSecureStorage secureStorage = new FlutterSecureStorage();
    await secureStorage.write(key: _getFileName(), value: encryptedTokens);
  }

  /**
   * read all keys, find the encounter to update and save back the json file
   */
  static Future<void> updateEncouter(Encounter encounterToUpdate) async {
    List<BluetoothToken> bluetoothTokensHistory = await fetchBluetoothTokens();

    for (BluetoothToken bluetoothToken in bluetoothTokensHistory) {
      for (Encounter encounter in bluetoothToken.encounters) {
        if (encounter.sharedKey == encounterToUpdate.sharedKey) {
          encounter = encounterToUpdate;
        }
      }
    }

    // save it
    String bluetoothTokensHistoryJson = json.encode(bluetoothTokensHistory);
    String encryptedTokens =
        await CryptUtils.encryptString(bluetoothTokensHistoryJson);

    FlutterSecureStorage secureStorage = new FlutterSecureStorage();
    await secureStorage.write(key: _getFileName(), value: encryptedTokens);
  }

  /**
   * Update all encounters risk factors
   */
  static Future<void> updateEncountersRiskFactor() async {
    List<BluetoothToken> bluetoothTokensHistory = await fetchBluetoothTokens();
    SettingsManager settingsManager = new SettingsManager();
    await settingsManager.loadSettings();

    for (BluetoothToken bluetoothToken in bluetoothTokensHistory) {
      for (Encounter encounter in bluetoothToken.encounters) {
        encounter.mailboxMessage = new MailboxMessage(
            1,
            0,
            0,
            settingsManager.settings.user_data.newSymptomaticRisk,
            settingsManager.settings.user_data.oldSymptomaticRisk);
      }
    }

    // save it
    String bluetoothTokensHistoryJson = json.encode(bluetoothTokensHistory);
    String encryptedTokens =
        await CryptUtils.encryptString(bluetoothTokensHistoryJson);

    FlutterSecureStorage secureStorage = new FlutterSecureStorage();
    await secureStorage.write(key: _getFileName(), value: encryptedTokens);
  }

  /**
   * Clear encounters, used when reseting the app
   */
  static Future<void> clear() async {
    Logger().v(
        "[Bluetooth_Token_Storage_Service] Clear bluetooth tokens history...");

    List<BluetoothToken> bluetoothTokensHistory = [];

    // save it
    String bluetoothTokensHistoryJson = json.encode(bluetoothTokensHistory);
    String encryptedTokens =
        await CryptUtils.encryptString(bluetoothTokensHistoryJson);

    FlutterSecureStorage secureStorage = new FlutterSecureStorage();
    await secureStorage.write(key: _getFileName(), value: encryptedTokens);

    return;
  }
}
