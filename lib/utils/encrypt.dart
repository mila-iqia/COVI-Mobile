import 'dart:math';
import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models/covicfg.dart';

class CryptUtils {
  /// Generate a Key
  static String generateKey() {
    // Generate a Random secure value
    final Random random = Random.secure();
    final List<int> values = List<int>.generate(32, (i) => random.nextInt(256));

    return base64Encode(values);
  }

  /// Retrieve our key for the SecureStorage
  static Future<Key> getKey() async {
    // Access to the Secure Storage
    FlutterSecureStorage storage = new FlutterSecureStorage();

    // Try to get the encryption key
    String key = await storage.read(
        key: "key",
        iOptions: IOSOptions(
            accessibility: IOSAccessibility.first_unlock_this_device));

    // If the value is null, generate a key
    if (key == null) {
      key = generateKey();

      // Save the created key to storage
      await storage.write(
          key: "key",
          value: key,
          iOptions: IOSOptions(
              accessibility: IOSAccessibility.first_unlock_this_device));
    }

    return Key.fromBase64(key);
  }

  /// Encrypt a string
  static Future<String> encryptString(String string, {IV iv}) async {
    Key key = await getKey();

    IV _iv = iv == null ? await getIV() : iv;

    // Our encrypter
    Encrypter encrypter = Encrypter(AES(key));

    // Encrypt the string
    Encrypted encryptedString = encrypter.encrypt(string, iv: _iv);

    // Return the encrypted string
    return encryptedString.base64;
  }

  /// Decrypt a string
  static Future<String> decryptString(String string, {IV iv}) async {
    Key key = await getKey();

    IV _iv = iv == null ? await getIV() : iv;

    // Our encrypter
    Encrypter encrypter = Encrypter(AES(key));

    // Get an "encrypted" version of our String
    Encrypted encryptedString = Encrypted.fromBase64(string);

    // Return the decrypted String
    return encrypter.decrypt(encryptedString, iv: _iv);
  }

  /// Decrypt a string using the old encryption key
  static Future<String> decryptStringWithOldKey(String string, {IV iv}) async {
    Covicfg _covicfg = new Covicfg();
    final Key key = Key.fromBase64(_covicfg.oldEncryptionKey);

    IV _iv = iv == null ? await getIV() : iv;

    // Our encrypter
    Encrypter encrypter = Encrypter(AES(key));

    // Get an "encrypted" version of our String
    Encrypted encryptedString = Encrypted.fromBase64(string);

    // Return the decrypted String
    return encrypter.decrypt(encryptedString, iv: _iv);
  }

  static Future<IV> getIV({String key}) async {
    if (key == null) return IV.fromLength(16);

    // Access to the Secure Storage
    FlutterSecureStorage storage = new FlutterSecureStorage();

    // Try to get the encryption key
    String _iv = await storage.read(
        key: "$key-IV",
        iOptions: IOSOptions(
            accessibility: IOSAccessibility.first_unlock_this_device));

    if (_iv == null) {
      return IV.fromLength(16);
    }
    return IV.fromBase64(_iv);
  }
}
