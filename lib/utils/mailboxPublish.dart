import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import 'models/covicfg.dart';

class MailboxPublish {
  Covicfg _covicfg;
  SendPort _sendPort;

  Duration _pushingFrequency;
  Timer _timer;

  bool _hasMoreMessageToCome;

  Queue<String> _encryptedMessages;

  MailboxPublish(SendPort sendPort) {
    _sendPort = sendPort;

    _covicfg = new Covicfg();
    _pushingFrequency =
        Duration(milliseconds: _covicfg.mailboxRequestFrequencyInMilliseconds);

    _encryptedMessages = new Queue<String>();

    _hasMoreMessageToCome = true;
  }

  /**
   * Add the message to the queue
   */
  void addMessage(String message) {
    _encryptedMessages.add(message);
  }

  void start() {
    _timer = Timer.periodic(_pushingFrequency, (_) => _sendDataToMailbox());
  }

  void _sendDataToMailbox() {
    // If all messages have been processed and there is no more message coming
    if (!_hasMoreMessageToCome && _encryptedMessages.isEmpty) {
      // Stop the publisher
      _timer.cancel();
      _sendPort.send({'action': 'publishMailboxesDone'});
      return;
    } else if (_encryptedMessages.isEmpty) {
      return;
    }

    String encryptedMessage = _encryptedMessages.first;

    String url = _covicfg.mixnetUrl;
    String body = jsonEncode({
      'msgs': [encryptedMessage]
    });

    Map<String, String> headers = {"Content-type": "application/json"};

    _sendPort.send({
      'action': 'print',
      'data': 'URL ${url}\r\nPosting message ${encryptedMessage}'
    });

    http.post(url, headers: headers, body: body).then((http.Response response) {
      if (response.statusCode != 202) {
        print(
            "[MailboxPublisher] Error posting to mixnet: [${response.statusCode}]${response.body}");
      } else {
        print(
            "[MailboxPublisher] Posting to mixnet sucessfull : [${response.statusCode}]${response.body}");
      }
    }).catchError((onError) =>
        {print("[MailboxPublisher] Error posting to mixnet: ${onError}")});

    _encryptedMessages.removeFirst();

    // If all messages have been processed and there is no more message coming
    if (!_hasMoreMessageToCome && _encryptedMessages.isEmpty) {
      // Stop the publisher
      _timer.cancel();
      _sendPort.send({'action': 'publishMailboxesDone'});
      return;
    }
  }

  void dispose() {
    _hasMoreMessageToCome = false;
  }
}
