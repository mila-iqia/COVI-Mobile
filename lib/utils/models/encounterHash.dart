import 'dart:core';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:pointycastle/digests/blake2b.dart';

import 'encounter.dart';
import 'covicfg.dart';

class EncounterHash {
  Uint8List _hash;
  Uint8List _key;
  List<String> _mailboxAddressSets;
  Uint8List _mailboxAddress;

  int _prefixLength;
  int _maxSets;

  EncounterHash(Encounter encounter) {
    final blake2b = Blake2bDigest(digestSize: 64);

    // Read config
    Covicfg covicfg = new Covicfg();

    _prefixLength = covicfg.dns_prefix_length;
    _maxSets = covicfg.prefix_max_sets;

    // Generate encounter hash from bluetooth token
    _hash = blake2b.process(encounter.sharedKey);

    // Retrieve the full mailbox address in bytes
    _mailboxAddress = _retrieveMailboxAddressFromHash(_hash);

    // Split the full mailbox address in specific set
    _mailboxAddressSets = _retrieveMailboxAddressSets(_mailboxAddress);

    // Retrieve the encryption key to be used for risk factor encryption from the second set of 32 bytes of the full hash
    _key = Uint8List.fromList(_hash.getRange(32, 64).toList());
  }

  Uint8List _retrieveMailboxAddressFromHash(Uint8List _hash) {
    // Retrieve mailbox address from the first 16 bytes of the full hash
    List<int> mailboxAddressInBytes =
        Uint8List.fromList(_hash.getRange(0, 16).toList());

    return mailboxAddressInBytes;
  }

  List<String> _retrieveMailboxAddressSets(Uint8List mailboxAddressInBytes) {
    // Convert hash to binary to identify each set based on the covi config
    String hashInBinary = "";
    mailboxAddressInBytes.toList().forEach((byte) =>
        hashInBinary = hashInBinary + byte.toRadixString(2).padLeft(8, '0'));

    // Init list
    List<String> mailboxAddressSets = new List<String>();

    int startIndex = 0;
    int endIndex = startIndex + _prefixLength;

    for (int i = 0; i <= _maxSets; i++) {
      // Get each set from full binary
      String setInBinary = hashInBinary.substring(startIndex, endIndex);

      // Convert back the binary to integer
      int setInBytes = int.parse(setInBinary, radix: 2);

      // Convert the integer to hex and add it to the list of sets
      mailboxAddressSets.add(setInBytes.toRadixString(_prefixLength));

      // Increment to the next set
      startIndex += _prefixLength;
      endIndex += _prefixLength;
    }

    return mailboxAddressSets;
  }

  Uint8List getHash() => _hash;

  Uint8List getKey() => _key;

  String getMailboxAddress() => hex.encode(_mailboxAddress);

  String getMailboxAddressSet(int setIndex) {
    if (setIndex < 0 || setIndex > _maxSets) {
      RangeError.range(setIndex, 0, _maxSets + 1, "setToGet", "Invalid value");
    }

    return _mailboxAddressSets[setIndex];
  }
}
