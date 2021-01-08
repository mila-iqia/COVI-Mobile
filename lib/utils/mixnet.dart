import 'dart:convert';
import 'dart:typed_data';

import 'package:covi/utils/models/covicfg.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:convert/convert.dart';

class Mixnet {
  Future<String> encryptRiskFactorWithEachMixnetPublicKey(
      String secretBoxRiskFactor) async {
    // Initialize the secretbox risk factor to be encrypted by each mixnet
    Uint8List encryptedRiskFactorInBytes =
        Uint8List.fromList(hex.decode(secretBoxRiskFactor));

    String base64RiskFactor;

    Covicfg covicfg = new Covicfg();

    for (int i = 0; i < covicfg.seqmixnet.length; i++) {
      // Retrieve each mixnet's public key from the config
      String mixnetPublicKeyInHex =
          covicfg.unverifiedmixnet[covicfg.seqmixnet[i]];
      Uint8List mixnetPublicKeyInBytes = base64Decode(mixnetPublicKeyInHex);

      // Encrypt the risk factor with the each public key
      encryptedRiskFactorInBytes = await Sodium.cryptoBoxSeal(
          encryptedRiskFactorInBytes, mixnetPublicKeyInBytes,
          useBackgroundThread: true);

      // Convert the encrypted array of bytes to base64
      base64RiskFactor = base64Encode(encryptedRiskFactorInBytes);
    }

    return Future.value(base64RiskFactor);
  }
}
