import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:logger/logger.dart';

class EncryptedMessage {
  String _mailboxAddressInHex;
  String _encryptedMessageInHex;
  String _nonceInHex;
  Uint8List _encryptionKey;

  String get from => _mailboxAddressInHex;

  String get message => _encryptedMessageInHex;

  Uint8List get key => _encryptionKey;

  EncryptedMessage(String message, Uint8List encryptionKey) {
    _mailboxAddressInHex = message.substring(0, 32);
    _nonceInHex = message.substring(32, 40).padRight(24, '0');
    _encryptedMessageInHex = message.substring(40, 104);
    _encryptionKey = encryptionKey;
  }

  // Can only be done on the main thread
  Future<String> decrypt() async {
    Uint8List nonceInBytes = Uint8List.fromList(_nonceInHex.codeUnits);
    Uint8List encryptedMessageInBytes =
        Uint8List.fromList(hex.decode(_encryptedMessageInHex));

    try {
      Uint8List decryptedMessageInBytes = await Sodium.cryptoSecretboxOpenEasy(
          encryptedMessageInBytes, nonceInBytes, _encryptionKey,
          useBackgroundThread: true);

      String decryptedMessage = hex.encode(decryptedMessageInBytes);

      Logger().i(
          "Mailbox address : ${hex.decode(_mailboxAddressInHex)}\r\nDecrypted message : ${decryptedMessage}");

      return decryptedMessage;
    } catch (err) {
      return Future.error(
          "Unable to decrypt message '${_encryptedMessageInHex}' from ${_mailboxAddressInHex} with key ${hex.encode(_encryptionKey)}");
    }
  }

  EncryptedMessage.fromJson(Map<String, dynamic> json) {
    _mailboxAddressInHex = json['mailboxAddressInHex'];
    _encryptedMessageInHex = json['encryptedMessageInHex'];
    _nonceInHex = json['nonceInHex'];
    _encryptionKey = json['encryptionKey'];
  }

  Map<String, dynamic> toJson() => {
        'mailboxAddressInHex': _mailboxAddressInHex,
        'encryptedMessageInHex': _encryptedMessageInHex,
        'nonceInHex': _nonceInHex,
        'encryptionKey': _encryptionKey,
      };
}
