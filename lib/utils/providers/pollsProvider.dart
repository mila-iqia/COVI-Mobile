import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logger/logger.dart';

class PollChoice {
  int id;
  Map<String, dynamic> label;
  int awnsers;

  PollChoice(this.id, this.label, this.awnsers);

  factory PollChoice.fromJson(Map<String, dynamic> parsedJson, int awnsers) {
    return PollChoice(parsedJson['id'],
        new Map<String, dynamic>.from(parsedJson['label']), awnsers);
  }
}

class Poll {
  int id;
  Map<String, dynamic> question;
  List<PollChoice> choices;
  int total;

  Poll(this.id, this.question, this.choices, this.total);

  factory Poll.fromJson(Map<String, dynamic> parsedJson) {
    Map<String, dynamic> awnsers =
        new Map<String, dynamic>.from(parsedJson['results']['awnsers']);
    List<dynamic> choicesBasic = parsedJson['choices'];
    List<PollChoice> choices = choicesBasic.map((choice) {
      return PollChoice.fromJson(choice, awnsers[choice['id'].toString()]);
    }).toList();
    return Poll(
        parsedJson['id'],
        new Map<String, dynamic>.from(parsedJson['question']),
        choices,
        parsedJson['results']['total']);
  }
}

class PollsProvider with ChangeNotifier {
  static final String _fileName = "covidpoll.json";
  static final LocalStorage _storage = new LocalStorage(_fileName);

  bool _isReady = false;
  bool get isReady => _isReady;
  void set isReady(bool isReady) {
    _isReady = isReady;
    notifyListeners();
  }

  int _activePollAwnser;
  int get activePollAwnser => _activePollAwnser;
  void set activePollAwnser(int activePollAwnser) {
    _activePollAwnser = activePollAwnser;
    notifyListeners();
  }

  Poll _activePoll;
  Poll get activePoll => _activePoll;
  void set activePoll(Poll poll) {
    _activePoll = poll;
    notifyListeners();
  }

  PollsProvider() {
    this.loadActivePoll().then((value) {
      this.isReady = true;
    });
  }

  Future<void> loadActivePoll() async {
    try {
      await DefaultCacheManager()
          .removeFile('${Constants.apiUrl}/app/active-poll');
      var file = await DefaultCacheManager()
          .getSingleFile('${Constants.apiUrl}/app/active-poll');
      String contents = await file.readAsString();
      final data = json.decode(contents);
      this.activePoll = Poll.fromJson(data['data']);
      await _storage.ready;
      this.activePollAwnser =
          _storage.getItem('poll_awnser_${this.activePoll.id}') ?? null;
    } on HttpException {
      Logger().v('[PollsProvider] Could not load active poll.');
    } catch (e) {
      Logger().e('[PollsProvider] ${e.toString()}');
    }
  }

  Future<void> postActivePollAwnser(int choiceId) async {
    if (this.activePoll != null) {
      await _storage.ready;
      http.Response response = await http.post(
        '${Constants.apiUrl}/app/polls/${this.activePoll.id}',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'choice': choiceId,
        }),
      );
      if (response.statusCode == 201) {
        _storage.setItem('poll_awnser_${this.activePoll.id}', choiceId);
        final data = json.decode(response.body);
        this.activePoll = Poll.fromJson(data);
        this.activePollAwnser = choiceId;
      } else {
        Logger().e(
            '[PollsProvider] Could not post vote to poll ${this.activePoll.id} with choice ${choiceId}');
      }
    }
  }

  static Future<void> clear() async {
    await _storage.clear();
    return;
  }
}
