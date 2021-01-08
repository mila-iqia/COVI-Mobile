import 'dart:math';
import 'dart:typed_data';

import 'package:covi/utils/models/encounterHash.dart';

import 'covicfg.dart';

class MailboxAddress {
  Covicfg _covicfg;
  int _setId;
  String _mailboxId;
  Uint8List _hash;
  Uint8List _encryptionKey;

  MailboxAddress(EncounterHash encounterHash) {
    _covicfg = new Covicfg();
    _setId = Random().nextInt(_covicfg.prefix_max_sets + 1);
    _mailboxId = encounterHash.getMailboxAddressSet(_setId);
    _hash = encounterHash.getHash();
    _encryptionKey = encounterHash.getKey();
  }

  String get address =>
      "${_mailboxId}.${_setId + 1}.${_covicfg.mailboxCoviAppDomain}";

  Uint8List get hash => _hash;

  Uint8List get encryptionKey => _encryptionKey;
}
