import 'dart:convert';

import 'dart:math';

import 'package:covi/services/bluetooth_gatt_service.dart';
import 'package:covi/services/bluetooth_token_storage_service.dart';
import 'package:covi/utils/backgroundWorker.dart';
import 'package:covi/utils/models/covicfg.dart';
import 'package:covi/utils/models/encounter.dart';
import 'package:covi/utils/models/BluetoothToken.dart';
import 'package:covi/utils/heuristicTracingCalculator.dart';
import 'package:covi/utils/models/mailboxMessage.dart';
import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool isFileLoaded = false;

  @override
  Widget build(BuildContext context) {
    SettingsManager settingsManager = Provider.of<SettingsManager>(context);

    return LogConsoleOnShake(
        child: MaterialApp(
            home: Scaffold(
      appBar: AppBar(
        title: Text('Écran de test ultra secrète'),
      ),
      body: Center(
        child: ListView(children: <Widget>[
          textCentered("current risk factor: " +
              settingsManager.settings.user_data.newSymptomaticRisk
                  .toRadixString(16)),
          RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/pre-dashboard');
              },
              child: Text("Go to Loading Page")),
          RaisedButton(
              onPressed: () {
                Covicfg.update();
              },
              child: Text("Update covicfg file")),
          RaisedButton(
              onPressed: () async {
                await BluetoothGattService
                    .pullSaveSharedKeysAndChangePublicKey();
              },
              child: Text("Fetch shared keys from native")),
          RaisedButton(
              onPressed: () async {
                List<BluetoothToken> tokensHistory =
                    await BluetoothTokenStorageService.fetchBluetoothTokens();

                List<Encounter> encounters = new List<Encounter>();
                tokensHistory.forEach((element) {
                  encounters.addAll(element.encounters);
                });

                Logger().v(
                    "Found ${encounters.length} encounters in secure storage");
              },
              child: Text("Count number of encounters")),
          RaisedButton(
              onPressed: () async {
                BackgroundWorker backgroundWorker = new BackgroundWorker();
                backgroundWorker.startBackgroundWorker();

                await settingsManager.loadSettings();
                DateTime _now = DateTime.now().add(Duration(seconds: 5));
                settingsManager.settings.pushingNextTime = _now;
                settingsManager.settings.lastSyncAt = _now;
                await settingsManager.saveSettings();
              },
              child: Text("Start syncing encounters task")),
          RaisedButton(
              onPressed: () async {
                BackgroundWorker backgroundWorker = new BackgroundWorker();
                backgroundWorker.publishToMailboxWork();
              },
              child: Text("Push encounters to server")),
          RaisedButton(
              onPressed: () async {
                // clear keys and restart

                // todo : read encounters_test.json and override everything with these keys
                String bluetoothTokensJson = await rootBundle
                    .loadString("assets/data/encounters_test.json");

                List<dynamic> locs = json.decode(bluetoothTokensJson);
                List<BluetoothToken> bluetoothTokens =
                    locs.map((loc) => BluetoothToken.fromJson(loc)).toList();

                BluetoothTokenStorageService.addMultiple(bluetoothTokens);
                Logger().d("added 50 encounters");
              },
              child: Text("Generate 50 encouters")),
          RaisedButton(
              onPressed: () async {
                BluetoothTokenStorageService.clear();
              },
              child: Text("Delete encounters")),
          RaisedButton(
              onPressed: () async {
                List<MailboxMessage> randomMailboxMessages =
                    new List<MailboxMessage>();

                Random rdm = new Random();
                for (int i = 0; i < 100; i++) {
                  int randomInfected = rdm.nextInt(100);
                  if (randomInfected > 90) {
                    randomMailboxMessages.add(
                        new MailboxMessage(1, 0, 0, rdm.nextInt(1) + 14, 1));
                  } else {
                    randomMailboxMessages
                        .add(new MailboxMessage(1, 0, 0, 1, 1));
                  }
                }

                int infectedCount = randomMailboxMessages
                    .where((element) => element.newSymptomaticRiskFactor >= 14)
                    .length;

                Logger().d(infectedCount);

                SettingsManager settingsManager =
                    Provider.of<SettingsManager>(context, listen: false);
                randomMailboxMessages.forEach((element) {
                  HeuristicTracingCalculator tracingCalculator =
                      new HeuristicTracingCalculator(
                          settingsManager.settings.user_data);
                  tracingCalculator.heuristicTracingAlgo(element.getData());

                  settingsManager.settings.user_data =
                      tracingCalculator.userData;

                  settingsManager.saveSettings();
                });

                Logger().d(
                    "Done updating risk factor, new risk factor : ${settingsManager.settings.user_data.newSymptomaticRisk}");
              },
              child: Text("Test risk factor update")),
          RaisedButton(
            onPressed: () async {
              String mailboxResults = "000F0309030407000000000000000000";
              SettingsManager settingsManager =
                  Provider.of<SettingsManager>(context, listen: false);

              HeuristicTracingCalculator tracingCalculator =
                  new HeuristicTracingCalculator(
                      settingsManager.settings.user_data);
              tracingCalculator.heuristicTracingAlgo(mailboxResults);

              settingsManager.settings.user_data = tracingCalculator.userData;
            },
            child: Text("Update risk factor"),
          ),
        ]),
      ),
    )));
  }

  Widget textCentered(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }
}
