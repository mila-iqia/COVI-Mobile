import 'dart:async';
import 'dart:isolate';

import 'package:covi/services/bluetooth_token_storage_service.dart';
import 'package:covi/utils/mailboxPublish.dart';
import 'package:covi/utils/models/BluetoothToken.dart';
import 'package:covi/utils/models/encounterHash.dart';
import 'package:covi/utils/models/mailboxAddress.dart';
import 'package:covi/utils/settings.dart';
import 'package:logger/logger.dart';

import 'heuristicTracingCalculator.dart';
import 'mailboxReader.dart';
import 'mixnet.dart';
import 'models/encounter.dart';
import 'models/encryptedMessage.dart';
import 'models/covicfg.dart';
import 'models/mailboxMessage.dart';

class BackgroundWorker {
  Isolate _isolate;
  SendPort _sendToIsolatedProcessPort;

  Completer _isolateReady;
  Completer _encountersReceived;
  Completer _processDone;
  Completer _coviCfgReceived;
  Completer _readMailboxesCompleted;

  static bool _wasLastMessage = false;

  Map<String, Encounter> _encounters = new Map<String, Encounter>();

  static void syncWithMailboxes() async {
    SettingsManager settingsManager = new SettingsManager();
    await settingsManager.loadSettings();

    if (DateTime.now().difference(settingsManager.settings.lastSyncAt).inHours >
        20) {
      BackgroundWorker backgroundWorker = new BackgroundWorker();
      backgroundWorker.startBackgroundWorker();

      settingsManager.settings.lastSyncAt = DateTime.now();
      ;
      await settingsManager.saveSettings();
    }
  }

  void startBackgroundWorker() async {
    Covicfg.load();
    List<BluetoothToken> bluetoothTokens =
        await BluetoothTokenStorageService.fetchBluetoothTokens();

    List<Encounter> encounters = new List<Encounter>();
    bluetoothTokens.forEach((element) {
      encounters.addAll(element.encounters);
    });

    Logger().d("Number of encounters to sync : ${encounters.length}");

    await init();
    await fetchCoviConfig(Covicfg.toJson());
    await fetchEncounters(encounters);
    await readMailboxes();
    await publishMailboxes();
    dispose();

    return;
  }

  void publishToMailboxWork() async {
    Covicfg.load();
    List<BluetoothToken> bluetoothTokens =
        await BluetoothTokenStorageService.fetchBluetoothTokens();

    List<Encounter> encounters = new List<Encounter>();
    bluetoothTokens.forEach((element) {
      encounters.addAll(element.encounters);
    });

    Logger().d("Number of encounters to push : ${encounters.length}");

    await init();
    await fetchCoviConfig(Covicfg.toJson());
    await fetchEncounters(encounters);
    await publishMailboxes();
    dispose();

    return;
  }

  /**
   * Initialize the background worker
   */
  Future<void> init() async {
    Logger().d("BACKGROUND WORKER - init");

    ReceivePort processPort = new ReceivePort();

    _isolate =
        await Isolate.spawn(_backgroundWorkerEntry, processPort.sendPort);

    // Start listening on the processPort channel
    processPort.listen(_handleMessage, onError: _handleError);

    _isolateReady = Completer<void>();

    return _isolateReady.future;
  }

  /**
   * Fetch coviCfg from main thread to the background worker
   */
  Future<List<String>> fetchCoviConfig(Map<String, dynamic> coviCfg) {
    Logger().d("BACKGROUND WORKER - Fetch covi config");

    _sendToIsolatedProcessPort
        .send({"action": "fetchCoviConfig", "data": coviCfg});

    _coviCfgReceived = Completer<List<String>>();

    return _coviCfgReceived.future;
  }

  /**
   * Fetch encounters from main thread to the background worker
   */
  Future<List<String>> fetchEncounters(List<Encounter> encounters) {
    Logger().d("BACKGROUND WORKER - Fetch encounters");

    for (Encounter encounter in encounters) {
      String mailboxAdress = new EncounterHash(encounter).getMailboxAddress();
      _encounters[mailboxAdress] = encounter;
    }

    // Convert to primitive to send to isolate
    List<Map<String, dynamic>> encountersData =
        encounters.map((l) => l.toJson()).toList();

    // Send the action and data to the isolate
    _sendToIsolatedProcessPort
        .send({"action": "fetchEncounters", "data": encountersData});

    _encountersReceived = Completer<List<String>>();

    return _encountersReceived.future;
  }

  /**
   * Start reading all mailboxes based on shared keys
   */
  Future<void> readMailboxes() {
    Logger().d("BACKGROUND WORKER - Read mailboxes");

    _sendToIsolatedProcessPort.send({"action": "readMailboxes"});

    _readMailboxesCompleted = Completer<void>();

    return _readMailboxesCompleted.future;
  }

  /**
   *
   */
  Future<void> publishMailboxes() async {
    Logger().d("BACKGROUND WORKER - Publish to mailbox");

    Mixnet mixnet = new Mixnet();
    SettingsManager settingsManager = SettingsManager();
    await settingsManager.loadSettings();

    Covicfg config = new Covicfg();

    int riskFactorThreshold = config.riskFactorThreshold;
    bool shareTestResult = settingsManager.settings.shareCovidTestResult;
    int newSymptomaticRisk =
        settingsManager.settings.user_data.newSymptomaticRisk;

    // if user doesn't conscent or if user doesn't seem to be infected
    // do not share result to mixnet
    if (!shareTestResult || newSymptomaticRisk < riskFactorThreshold) {
      Logger().w(
          "Nothing to send to mailboxes\r\nshare test result : ${shareTestResult}\r\ncurrent risk factor : ${newSymptomaticRisk} / ${riskFactorThreshold}");
      _sendToIsolatedProcessPort.send({"action": "publishMailboxCompleted"});
      _processDone = Completer<void>();
      return _processDone.future;
    }

    List<Encounter> encountersToSend = _encounters.values.toList();

    for (Encounter encounter in encountersToSend) {
      EncounterHash encounterHash = new EncounterHash(encounter);
      String mailboxAddress = encounterHash.getMailboxAddress();

      MailboxMessage message = encounter.mailboxMessage;
      message.publicKey = encounter;

      String secretBoxRiskFactor = await message.encrypt();
      // This is the 128 hex character string sent to mixnet
      String fullMessage = mailboxAddress + secretBoxRiskFactor;

      // Logger().d("message to send \r\nmailboxAddress : " + mailboxAddress + "\r\nsecret box risk factor :  " + secretBoxRiskFactor);

      String encryptedMessage =
          await mixnet.encryptRiskFactorWithEachMixnetPublicKey(fullMessage);

      _sendToIsolatedProcessPort
          .send({"action": "publishMailbox", "data": encryptedMessage});
    }

    // Send completion to isolate
    _sendToIsolatedProcessPort.send({"action": "publishMailboxCompleted"});
    _processDone = Completer<void>();
    return _processDone.future;
  }

  /**
   * Dispose the background worker
   */
  void dispose() {
    _isolate.kill();
  }

  /**
   * Background worker entry point
   */
  static void _backgroundWorkerEntry(dynamic message) {
    final ReceivePort receivePort = ReceivePort();

    SendPort sendPort;
    List<Encounter> encounters = new List<Encounter>();
    MailboxPublish publisher;

    // Start listening in our isolated process
    receivePort.listen((dynamic message) async {
      try {
        if (message['action'] == 'fetchCoviConfig') {
          // Convert back the coviConfig to Map
          Map<String, dynamic> jsonCoviConfig = message['data'];

          // init the coviConfig in the background thread
          Covicfg.fromJson(jsonCoviConfig);

          // Acknowledge reception
          sendPort.send({'action': 'fetchCoviConfigReceived'});
          return;
        }

        if (message['action'] == 'fetchEncounters') {
          List<Map<String, dynamic>> encountersData = message['data'];
          encounters = encountersData
              .map((encounter) => Encounter.fromJson(encounter))
              .toList();

          // Acknowledge reception
          sendPort.send({'action': 'fetchEncountersReceived'});
          return;
        }

        if (message['action'] == 'readMailboxes') {
          _readMailboxes(sendPort, encounters);
          return;
        }

        if (message['action'] == 'publishMailbox') {
          String encryptedMessage = message['data'];

          publisher.addMessage(encryptedMessage);
          return;
        }

        if (message['action'] == 'publishMailboxCompleted') {
          publisher.dispose();
          return;
        }
      } catch (err) {
        sendPort.send(err);
      }
    });

    // Return back the sendPort for two ways communication
    if (message is SendPort) {
      sendPort = message;
      sendPort.send(receivePort.sendPort);

      publisher = MailboxPublish(sendPort);
      publisher.start();
      return;
    }
  }

  /**
   * Message receiver running on main thread
   */
  void _handleMessage(dynamic message) async {
    if (message is SendPort) {
      _sendToIsolatedProcessPort = message;
      _isolateReady.complete();
      return;
    }

    try {
      if (message['action'] == 'fetchCoviConfigReceived') {
        _coviCfgReceived.complete();
        return;
      }

      if (message['action'] == 'fetchEncountersReceived') {
        _encountersReceived.complete();
        return;
      }

      if (message['action'] == 'wasLastMessage') {
        _wasLastMessage = message['data'];
      }

      if (message['action'] == 'encryptedMessage') {
        Map<String, dynamic> jsonEncryptedMessage = message['data'];
        EncryptedMessage encryptedMessage =
            EncryptedMessage.fromJson(jsonEncryptedMessage);

        String error = "";
        String decryptedMessage =
            await encryptedMessage.decrypt().catchError((onError) {
          error = onError;
        });

        if (error != "") {
          // if we get there it's often because tge decryption failed
          Logger().w(error);
          return;
        }

        Encounter encounter = _encounters[encryptedMessage.from];

        MailboxMessage mailboxMessage =
            MailboxMessage.fromString(decryptedMessage);

        SettingsManager settingsManager = new SettingsManager();

        HeuristicTracingCalculator tracingCalculator =
            new HeuristicTracingCalculator(settingsManager.settings.user_data);
        tracingCalculator.heuristicTracingAlgo(mailboxMessage.getData());

        settingsManager.settings.user_data = tracingCalculator.userData;

        encounter.mailboxMessage = mailboxMessage;
        encounter.lastSyncAt = DateTime.now();

        BluetoothTokenStorageService.updateEncouter(encounter);

        Logger().d("${decryptedMessage} from ${encryptedMessage.from}");

        return;
      }

      if (message['action'] == 'print') {
        Logger().d(message['data']);
        return;
      }

      if (message['action'] == 'readMailboxesDone') {
        Logger().v('readMailboxesDone');
        _readMailboxesCompleted.complete();
        return;
      }

      if (message['action'] == 'DHKeysSynced') {
        Encounter encounter = message['data'];

        encounter.lastSyncAt = DateTime.now();

        Logger().d(encounter.lastSyncAt.toIso8601String());

        return;
      }

      if (message['action'] == 'publishMailboxesDone') {
        Logger().v('publishMailboxesDone');
        _processDone.complete();
        return;
      }
    } catch (err) {
      Logger().e(err);
    }
  }

  /**
   * Error message receiver running on main thread
   */
  void _handleError(err) =>
      Logger().e("Error received from background worker: ${err}");

  /**
   * Read each mailbox from all bluetooth token in a stream
   */
  static void _readMailboxes(
      SendPort sendPort, List<Encounter> encounters) async {
    try {
      List<EncounterHash> encounterHashes =
          await _getEncountersHashes(encounters);

      List<MailboxAddress> mailboxAddresses =
          await _getMailboxAddresses(encounterHashes);

      // Create a stream of encryptedMail to hook to
      MailboxReader reader = MailboxReader(sendPort, mailboxAddresses);

      Stream<EncryptedMessage> encryptedMailReader = reader.stream;

      encryptedMailReader.listen((encryptedMessage) {
        sendPort.send(
            {'action': 'encryptedMessage', 'data': encryptedMessage.toJson()});
      }, onDone: () {
        sendPort.send({'action': 'readMailboxesDone'});
      });

      reader.Start();
    } catch (err) {
      sendPort.send(err);
    }
  }

  static Future<List<EncounterHash>> _getEncountersHashes(
          List<Encounter> encounters) async =>
      await encounters
          .map((encounter) => new EncounterHash(encounter))
          .toList();

  static Future<List<MailboxAddress>> _getMailboxAddresses(
          List<EncounterHash> encounterHashes) async =>
      encounterHashes
          .map((encounterHash) => new MailboxAddress(encounterHash))
          .toList();
}
