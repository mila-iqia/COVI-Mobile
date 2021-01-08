import 'dart:async';
import 'dart:isolate';

import 'package:logger/logger.dart';

import 'dns_resolver.dart';
import 'models/covicfg.dart';
import 'models/encryptedMessage.dart';
import 'models/mailboxAddress.dart';

class MailboxReader {
  final StreamController<EncryptedMessage> _controller =
      StreamController<EncryptedMessage>();
  Stream<EncryptedMessage> _encryptedMailsStream;
  SendPort _sendPort;

  Covicfg _covicfg;
  int _numberOfMailboxesToRead;

  DnsResolver _dnsResolver;
  Duration _pullingFrequency;

  List<MailboxAddress> _mailboxAddresses;

  MailboxReader(SendPort sendPort, List<MailboxAddress> mailboxAddresses) {
    _sendPort = sendPort;

    _sendPort.send({'action': 'wasLastMessage', 'data': false});

    _covicfg = new Covicfg();
    _dnsResolver = new DnsResolver();

    _pullingFrequency =
        Duration(milliseconds: _covicfg.mailboxRequestFrequencyInMilliseconds);

    _mailboxAddresses = mailboxAddresses;
    _numberOfMailboxesToRead = mailboxAddresses.length;
  }

  Stream<EncryptedMessage> get stream => _controller.stream;

  /**
   * Start the reader to periodically pull from mailboxes one page at the time
   */
  void Start() async {
    bool isDnsServerReachable = await _dnsResolver.init();

    if (!isDnsServerReachable) {
      return;
    }

    _encryptedMailsStream = _fetchMailboxPage(0, 0);

    _encryptedMailsStream.listen((encryptedMail) {
      _controller.sink.add(encryptedMail);
    }, onDone: () {
      _controller.close();
    });
  }

  /**
   * Stream all encrypted mails from the specific mailbox page
   */
  Stream<EncryptedMessage> _fetchMailboxPage(
      int mailboxIndex, int mailboxPage) async* {
    if (_mailboxAddresses.isEmpty) return;

    MailboxAddress mailbox = _mailboxAddresses[mailboxIndex];
    String dnsRequest = "${mailboxPage}.${mailbox.address}";
    int resultIndex = 0;
    List<String> txtRecords;

    _sendPort.send({
      'action': 'print',
      'data':
          'Reading ${mailboxIndex + 1} / ${_numberOfMailboxesToRead} from ${dnsRequest}'
    });

    try {
      txtRecords = await Future.delayed(_pullingFrequency, () {
        return _dnsResolver.resolve(dnsRequest);
      });

      // Read all txtRecords up to the maximum number of txtRecords we want to read per request
      while (resultIndex < txtRecords.length &&
          resultIndex < _covicfg.maxanswerperdnsV1) {
        yield EncryptedMessage(txtRecords[resultIndex], mailbox.encryptionKey);
        resultIndex++;

        if (resultIndex == txtRecords.length &&
            resultIndex < _covicfg.maxanswerperdnsV1) {
          if (mailboxIndex + 1 == _mailboxAddresses.length) {
            Logger().wtf("Readed last mailbox");
            _sendPort.send({'action': 'wasLastMessage', 'data': true});
            return;
          }

          //return;
        }
      }

      yield* _fetchMailboxPage(mailboxIndex, ++mailboxPage);
    } on TimeoutException catch (err) {
      _sendPort
          .send({'action': 'print', 'data': 'Error reading from dns: ${err}'});

      // Moving to the next mailbox
      if (mailboxIndex + 1 < _numberOfMailboxesToRead) {
        yield* _fetchMailboxPage(++mailboxIndex, 0);
      } else {
        Logger().wtf("Readed last mailbox");
        _sendPort.send({'action': 'wasLastMessage', 'data': true});
        return;
      }
    }
  }
}
