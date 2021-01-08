import 'package:covi/utils/providers/contentManagerProvider.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/settings.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class RecommendationsProvider extends ChangeNotifier {
  bool _isReady = false;
  bool get isReady => _isReady;
  void set isReady(bool isReady) {
    _isReady = isReady;
    notifyListeners();
  }

  DateTime _exceptionExpirationDate;
  DateTime get exceptionExpirationDate => _exceptionExpirationDate;
  void set exceptionExpirationDate(DateTime date) {
    _exceptionExpirationDate = date;
    notifyListeners();
  }

  MainRecommendation get mainRecommendation =>
      this._getMainRecommendationFromRiskLevel();
  List<Recommendation> get wellnessRecommendations =>
      this._getWellnessSingularRecommendationsFromRiskLevel();
  List<Recommendation> get healthRecommendations =>
      this._getHealthSingularRecommendationsFromRiskLevel();

  SettingsManager settingsManager;
  ContentManagerProvider contentManagerProvider;
  static final String _fileName = "recommendations.json";
  static final LocalStorage _storage = new LocalStorage(_fileName);

  RecommendationsProvider(BuildContext context) {
    settingsManager = Provider.of<SettingsManager>(context, listen: false);
    contentManagerProvider =
        Provider.of<ContentManagerProvider>(context, listen: false);
    this.loadStorageData().then((value) {
      this.isReady = true;
    });
  }

  Future<void> loadStorageData() async {
    await _storage.ready;
    String date = _storage.getItem('exceptionExpirationDate') ?? null;
    if (date != null) {
      this.exceptionExpirationDate = DateTime.parse(date);
    }
  }

  Future<void> updateExceptionExpirationDate() async {
    UserData data = settingsManager.settings.user_data;
    DateTime now = DateTime.now();
    final bool hasSevereSymptoms = ((data.hasDifficultyBreathing &&
            data.breathingDifficultySeverity == 'heavy') ||
        data.severeChestPain ||
        data.hardTimeWakingUp ||
        data.feelingConfused ||
        data.lostConsciousness);

    final bool hasModerateSymptoms = (data.hasDifficultyBreathing &&
        data.breathingDifficultySeverity == 'moderate');
    await _storage.ready;

    if (hasSevereSymptoms) {
      this.exceptionExpirationDate = now.add(new Duration(days: 1));
      _storage.setItem('exceptionExpirationDate',
          this.exceptionExpirationDate.toIso8601String());
    } else if (hasModerateSymptoms ||
        (data.recommandationLevel > 0 &&
            (data.covidTestResultIsPositive == null ||
                data.covidTestResultIsPositive))) {
      this.exceptionExpirationDate = now.add(new Duration(days: 3));
      _storage.setItem('exceptionExpirationDate',
          this.exceptionExpirationDate.toIso8601String());
    } else {
      this.exceptionExpirationDate = null;
      _storage.deleteItem('exceptionExpirationDate');
    }
  }

  MainRecommendation _getMainRecommendationFromRiskLevel() {
    assert(contentManagerProvider.isReady);

    DateTime now = DateTime.now();
    int exceptionExpirationDaysDiff = this.exceptionExpirationDate != null
        ? now.difference(this.exceptionExpirationDate).inDays
        : null;
    UserData data = settingsManager.settings.user_data;
    Map<String, dynamic> mainRecommendations =
        contentManagerProvider.mainRecommendations;

    if (mainRecommendations == null) {
      return null;
    }

    final bool hasSevereSymptoms = ((data.hasDifficultyBreathing &&
            data.breathingDifficultySeverity == 'heavy') ||
        data.severeChestPain ||
        data.hardTimeWakingUp ||
        data.feelingConfused ||
        data.lostConsciousness);

    final bool hasModerateSymptoms = (data.hasDifficultyBreathing &&
        data.breathingDifficultySeverity == 'moderate');

    if (hasSevereSymptoms &&
        exceptionExpirationDaysDiff != null &&
        exceptionExpirationDaysDiff < 1) {
      int recommendationIndex =
          mainRecommendations['BB'].indexWhere((bb) => bb["id"] == 'BB_C001');
      return MainRecommendation.fromJson(
          mainRecommendations['BB'][recommendationIndex], 'BB_C001');
    } else if (hasModerateSymptoms &&
        exceptionExpirationDaysDiff != null &&
        exceptionExpirationDaysDiff < 3) {
      int recommendationIndex =
          mainRecommendations['BB'].indexWhere((bb) => bb["id"] == 'BB_C002');
      return MainRecommendation.fromJson(
          mainRecommendations['BB'][recommendationIndex], 'BB_C002');
    } else if (data.recommandationLevel != null &&
        data.recommandationLevel > 0 &&
        (data.covidTestResultIsPositive == null ||
            (data.covidTestResultIsPositive &&
                exceptionExpirationDaysDiff != null &&
                exceptionExpirationDaysDiff >= 3))) {
      int recommendationIndex =
          mainRecommendations['BB'].indexWhere((bb) => bb["id"] == 'BB_C003');
      return MainRecommendation.fromJson(
          mainRecommendations['BB'][recommendationIndex], 'BB_C003');
    } else if (data.recommandationLevel != null &&
        data.recommandationLevel > 0) {
      return MainRecommendation.fromJson(
          (mainRecommendations['BR']
                  .where((br) => br["riskLevel"] == data.recommandationLevel)
                  .toList()
                    ..shuffle())
              .first(),
          'BR_${data.recommandationLevel}');
    } else {
      List<dynamic> titles = mainRecommendations['BB0']
          .where((bb0) => bb0["type"] == "title")
          .toList()
            ..shuffle();
      List<dynamic> subtitles = mainRecommendations['BB0']
          .where((bb0) => bb0["type"] == "subtitle")
          .toList()
            ..shuffle();
      return MainRecommendation.fromSeparateTitleSubtitleJson(
          titles.first, subtitles.first, 'BB0');
    }
  }

  List<Recommendation> _getHealthSingularRecommendationsFromRiskLevel() {
    UserData data = settingsManager.settings.user_data;
    List<dynamic> healthRecommendationsParsedJson = contentManagerProvider
        .recommendations
        .where((recommendation) =>
            recommendation["type"] == "health" &&
            data.recommandationLevel == recommendation["riskLevel"])
        .toList();
    return healthRecommendationsParsedJson
        .map(
            (recommendationJson) => Recommendation.fromJson(recommendationJson))
        .toList();
  }

  List<Recommendation> _getWellnessSingularRecommendationsFromRiskLevel() {
    List<dynamic> wellnessRecommendationsParsedJson = [];
    List<dynamic> shufledRecommendations =
        contentManagerProvider.recommendations.toList()..shuffle();
    shufledRecommendations.forEach((recommendation) {
      if (recommendation["type"] == "wellness" &&
          wellnessRecommendationsParsedJson.indexWhere((element) =>
                  element['subject'] == recommendation['subject']) ==
              -1) {
        wellnessRecommendationsParsedJson.add(recommendation);
      }
    });

    return wellnessRecommendationsParsedJson
        .map(
            (recommendationJson) => Recommendation.fromJson(recommendationJson))
        .toList();
  }
}

class MainRecommendation {
  String _id;
  String _category;
  Map<String, dynamic> _title;
  Map<String, dynamic> _subtitle;

  String get id => _id;
  String get category => _category;
  Map<String, dynamic> get title => _title;
  Map<String, dynamic> get subtitle => _subtitle;

  MainRecommendation(
    this._id,
    this._category,
    this._title,
    this._subtitle,
  );

  factory MainRecommendation.fromJson(dynamic parsedJson, String category) {
    return MainRecommendation(parsedJson["id"], category, parsedJson["title"],
        parsedJson["subtitle"]);
  }
  factory MainRecommendation.fromSeparateTitleSubtitleJson(
      dynamic titleParsedJson, dynamic subtitleParsedJson, String category) {
    return MainRecommendation(
        '${titleParsedJson["id"]}-${subtitleParsedJson["id"]}',
        category,
        titleParsedJson["content"],
        subtitleParsedJson["content"]);
  }
}

class Recommendation {
  String _id;
  Map<String, dynamic> _title;
  Map<String, dynamic> _content;

  String get id => _id;
  Map<String, dynamic> get title => _title;
  Map<String, dynamic> get content => _content;

  Recommendation(this._id, this._title, this._content);

  factory Recommendation.fromJson(parsedJson) {
    return Recommendation(
        parsedJson["id"], parsedJson["title"], parsedJson["content"]);
  }
}
