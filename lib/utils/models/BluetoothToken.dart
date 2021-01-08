import 'dart:typed_data';

import 'encounter.dart';

class BluetoothToken {
  DateTime _timestamp;
  Uint8List _privateKey;
  Uint8List _publicKey;
  List<Encounter> _encounters =
      new List<Encounter>(); // commonly called bluetooth tokens

  BluetoothToken(
    this._timestamp,
    this._privateKey,
    this._publicKey, {
    List<Encounter> encounters = const [],
  }) {
    if (encounters.isNotEmpty) this._encounters = encounters;
  }

  DateTime get timestamp => _timestamp;
  Uint8List get privateKey => _privateKey;
  Uint8List get publicKey => _publicKey;
  List<Encounter> get encounters => _encounters;

  BluetoothToken.fromJson(Map<String, dynamic> _json) {
    if (_json != null) {
      _timestamp = DateTime.parse(_json['timestamp']);
      _privateKey = Uint8List.fromList(_json['private_key'].cast<int>());
      _publicKey = Uint8List.fromList(_json['public_key'].cast<int>());
      if (_json['encounters'] != null) {
        _json['encounters'].forEach((e) {
          _encounters.add(new Encounter.fromJson(e));
        });
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'timestamp': _timestamp.toIso8601String(),
        'private_key': _privateKey,
        'public_key': _publicKey,
        'encounters': _encounters.map((v) => v.toJson()).toList(),
      };
}
