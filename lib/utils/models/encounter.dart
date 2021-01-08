import 'dart:typed_data';

import 'mailboxMessage.dart';

class Encounter {
  Uint8List _sharedKey;
  String _mailboxMessage;
  String _lastSyncAt;

  Encounter(this._sharedKey, this._mailboxMessage, DateTime lastSyncAt) {
    this._lastSyncAt = lastSyncAt.toIso8601String();
  }

  Uint8List get sharedKey => _sharedKey;

  MailboxMessage get mailboxMessage =>
      MailboxMessage.fromString(_mailboxMessage);
  void set mailboxMessage(MailboxMessage mailboxMessage) {
    _mailboxMessage = mailboxMessage.getData();
  }

  DateTime get lastSyncAt => DateTime.parse(_lastSyncAt);
  void set lastSyncAt(DateTime lastSyncAt) {
    _lastSyncAt = lastSyncAt.toIso8601String();
  }

  Encounter.fromJson(Map<String, dynamic> _json) {
    if (_json != null) {
      _sharedKey = Uint8List.fromList(_json['shared_key'].cast<int>());
      _mailboxMessage = _json['mailbox_message'];
      _lastSyncAt = _json['last_sync_at'];
    }
  }

  Map<String, dynamic> toJson() => {
        'shared_key': _sharedKey,
        'mailbox_message': _mailboxMessage,
        'last_sync_at': _lastSyncAt
      };
}
