import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:covi/utils/models/encounter.dart';
import 'package:covi/utils/models/encounterHash.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

class MailboxMessage {
  int _dataType;
  int _newOfficialRiskFactor;
  int _oldOfficialRiskFactor;
  int _newSymptomaticRisk;
  int _oldSymptomaticRisk;
  int _tbd; // to be determined
  int _dayOfMonthOfUpdate;
  int _versionOfQuestionsSymptoms;
  List<dynamic> _publicKey;

  int get dataType => _dataType;
  int get newOfficialRiskFactor => _newOfficialRiskFactor;
  int get oldOfficialRiskFactor => _oldOfficialRiskFactor;
  int get newSymptomaticRiskFactor => _newSymptomaticRisk;
  int get oldSymptomaticRiskFactor => _oldSymptomaticRisk;
  int get tbd => tbd;
  int get dayOfMonthOfUpdate => _dayOfMonthOfUpdate;
  int get versionOfQuestionsSymptoms => _versionOfQuestionsSymptoms;

  MailboxMessage(int dataType, int newOfficialRiskFactor,
      int oldOfficielRiskFactor, int newSymptomaticRisk, int oldSymptomaticRisk,
      {Encounter encounter}) {
    _dataType = dataType;
    _newOfficialRiskFactor = newOfficialRiskFactor;
    _oldOfficialRiskFactor = oldOfficielRiskFactor;
    _newSymptomaticRisk = newSymptomaticRisk;
    _oldSymptomaticRisk = oldSymptomaticRisk;
    _tbd = 0;
    _dayOfMonthOfUpdate = DateTime.now().month;
    _versionOfQuestionsSymptoms = 0;
    if (encounter != null) _publicKey = new EncounterHash(encounter).getKey();
  }

  void set publicKey(Encounter encounter) {
    _publicKey = new EncounterHash(encounter).getKey();
  }

  Uint8List getMessage() => Uint8List.fromList([
        _dataType,
        _newOfficialRiskFactor,
        _oldOfficialRiskFactor,
        _newSymptomaticRisk,
        _oldSymptomaticRisk,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00
      ]);

  String getData() =>
      _dataType.toRadixString(16).padLeft(2, "0") +
      _newOfficialRiskFactor.toRadixString(16).padLeft(2, "0") +
      _oldOfficialRiskFactor.toRadixString(16).padLeft(2, "0") +
      _newSymptomaticRisk.toRadixString(16).padLeft(2, "0") +
      _oldSymptomaticRisk.toRadixString(16).padLeft(2, "0") +
      _tbd.toRadixString(16).padLeft(2, "0") +
      _dayOfMonthOfUpdate.toRadixString(16).padLeft(2, "0") +
      _versionOfQuestionsSymptoms.toRadixString(16).padLeft(2, "0");

  // Can only be done on the main thread
  Future<String> encrypt() async {
    final Random random = Random.secure();

    final String fourBytesNonce =
        random.nextInt(4294967296).toRadixString(16).padLeft(8, '0');
    final Uint8List nonce =
        Uint8List.fromList(fourBytesNonce.padRight(24, '0').codeUnits);
    final Uint8List message = getMessage();

    final Uint8List encryptedMessageInBytes = await Sodium.cryptoSecretboxEasy(
        message, nonce, _publicKey,
        useBackgroundThread: true);
    final String encryptedMessageInHex = hex.encode(encryptedMessageInBytes);
    final String encryptedMessage = fourBytesNonce + encryptedMessageInHex;

    return encryptedMessage;
  }

  MailboxMessage.fromJson(Map<String, dynamic> json) {
    _dataType = json['data_type'];
    _newOfficialRiskFactor = json['new_official_risk_factor'];
    _oldOfficialRiskFactor = json['old_official_risk_factor'];
    _newSymptomaticRisk = json['new_symptomatic_risk'];
    _oldSymptomaticRisk = json['old_symptomatic_risk'];
    _tbd = json['tbd'];
    _dayOfMonthOfUpdate = json['day_of_month_of_update'];
    _versionOfQuestionsSymptoms = json['version_of_questions_symptoms'];
    _publicKey = json['public_key'];
  }

  /**
   * Create a mailbox message from the hexadecimal risk factor
   */
  MailboxMessage.fromString(String text) {
    _dataType = int.tryParse(text.substring(0, 1));
    _newOfficialRiskFactor = int.tryParse(text.substring(2, 3));
    _oldOfficialRiskFactor = int.tryParse(text.substring(4, 5));
    _newSymptomaticRisk = int.tryParse(text.substring(6, 7));
    _oldSymptomaticRisk = int.tryParse(text.substring(8, 9));
    _tbd = int.tryParse(text.substring(10, 11));
    _dayOfMonthOfUpdate = int.tryParse(text.substring(12, 13));
    _versionOfQuestionsSymptoms = int.tryParse(text.substring(14, 15));
  }

  Map<String, dynamic> toJson() => {
        'data_type': _dataType,
        'new_official_risk_factor': _newOfficialRiskFactor,
        'old_official_risk_factor': _oldOfficialRiskFactor,
        'new_symptomatic_risk': _newSymptomaticRisk,
        'old_symptomatic_risk': _oldSymptomaticRisk,
        'tbd': _tbd,
        'day_of_month_of_update': _dayOfMonthOfUpdate,
        'version_of_questions_symptoms': _versionOfQuestionsSymptoms,
        'public_key': _publicKey
      };
}
