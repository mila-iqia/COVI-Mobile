import 'dart:collection';
import 'dart:convert';

import 'package:covi/services/bluetooth_token_storage_service.dart';
import 'package:covi/utils/covid_stats.dart';
import 'package:covi/utils/providers/pollsProvider.dart';
import 'package:covi/utils/user_regions.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:covi/utils/encrypt.dart';

class SettingsManager extends ChangeNotifier {
  bool _isReady = false;
  bool get isReady => _isReady;

  // Access to SharedPreferences
  SharedPreferences _prefs;

  /// Our settings
  SettingsData _settings;

  SettingsData get settings => _settings;

  /// Localstorage access
  static final String _fileName = "settings.json";
  static final String _itemKey = "settings";
  static final LocalStorage _storage = new LocalStorage(_fileName);

  /// Settings constructor
  SettingsManager() {
    _settings = new SettingsData();

    Future.wait([
      loadSharedPreferences(),
      loadSettings(),
    ]).then((ready) {
      _changeReadyStatus(true);
    });
  }

  void _changeReadyStatus(bool status) {
    this._isReady = status;
    notifyListeners();
  }

  Future<void> loadSharedPreferences() async {
    // Load the instance of SharedPreferences
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// Set the lang
  void setLang(String lang) async {
    await loadSharedPreferences();

    _prefs.setString("selected_locale", lang);
  }

  /// Get the lang
  Future<String> getLang() async {
    await loadSharedPreferences();

    String lang = await _prefs.getString("selected_locale");
    if (lang == null) {
      String deviceLocale = await Devicelocale.currentLocale;
      if (deviceLocale.indexOf('_') >= 0) {
        lang = deviceLocale.split('_').first;
      } else if (deviceLocale.indexOf('-') >= 0) {
        lang = deviceLocale.split('-').first;
      } else if (deviceLocale != null && !deviceLocale.isEmpty) {
        lang = deviceLocale;
      } else {
        lang = 'en';
      }
    }
    return lang;
  }

  /// Load the lang
  void loadLang(BuildContext context) async {
    String lang = await getLang();
    await Jiffy.locale(lang);
    await FlutterI18n.refresh(context, new Locale(lang));
  }

  /// Load the settings from localstorage
  Future<void> loadSettings() async {
    Logger().v("[SettingsManager] Loading settings...");

    await loadSharedPreferences();

    //Wait for the storage to be ready
    await _storage.ready;
    // Load the settings json
    String encryptedSettings = _storage.getItem(_itemKey) ?? null;

    // Check if we have settings saved already
    if (encryptedSettings != null) {
      String settingsJson;

      // Always use the new key, otherwise try the old key
      try {
        settingsJson = await CryptUtils.decryptString(encryptedSettings);
      } catch (e) {
        settingsJson =
            await CryptUtils.decryptStringWithOldKey(encryptedSettings);
      }

      _settings = SettingsData.fromJson(json.decode(settingsJson));
    }

    notifyListeners();
  }

  void clearSettings() async {
    Logger().v("[SettingsManager] Clearing settings...");

    // Reset the settings locally
    _settings = new SettingsData();

    // Delete the settings in storage
    _storage.deleteItem("data");

    // Reset the setup
    await _prefs.remove("setup_complete");

    // Overwrite with new settings
    await saveSettings();
  }

  static void clear() async {
    await _storage.deleteItem(_itemKey);
    return;
  }

  static Future<void> resetApp(BuildContext context, {rebirth = true}) async {
    await SettingsManager.clear();
    await CovidStatsManager.clear();
    await UserRegionsManager.clear();
    await BluetoothTokenStorageService.clear();

    await PollsProvider.clear();
    Provider.of<PollsProvider>(context, listen: false).activePollAwnser = null;
    Provider.of<PollsProvider>(context, listen: false).activePoll = null;

    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove("setup_complete");
    if (rebirth) {
      Phoenix.rebirth(context);
    }

    return;
  }

  /// Save the settings to the localstorage
  void saveSettings() async {
    Logger().v("[SettingsManager] Saving settings...");

    await loadSharedPreferences();

    String settingsJson = json.encode(_settings);

    // Encrypt the settings
    String encryptedSettings = await CryptUtils.encryptString(settingsJson);

    // Save it
    await _storage.setItem(_itemKey, encryptedSettings);

    notifyListeners();
  }

  /// Is the setup complete?
  Future<bool> isSetupComplete() async {
    await loadSharedPreferences();

    bool isComplete = _prefs.getBool("setup_complete") ?? false;

    if (this.settings.user_data.recommendationUpdateDate == null) {
      this.settings.user_data.recommendationUpdateDate = new DateTime.now();
      await this.saveSettings();
    }

    return isComplete;
  }

  /// Set the setup as completed
  Future<void> setSetupCompleted(bool completed) async {
    // Load the instance of SharedPreferences
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    // Set the setting in the SharedPreferences and in the settings provider
    await _prefs.setBool("setup_complete", completed);

    notifyListeners();
  }
}

/// Holds our Settings data in a class
class SettingsData {
  UserData user_data = new UserData(
      null, null, null, new LinkedHashMap<String, dynamic>(),
      recommendationUpdateDate: DateTime.now()); // User's setting

  // Other settings
  bool receivePushNotifications = false;
  bool allowLocationServices = true;
  bool anonymousMILADataShare = false;
  bool shareCovidTestResult = false;
  DateTime pushingNextTime = null;
  DateTime lastGPSNotificationAt = DateTime.parse("1970-01-01");
  DateTime lastSyncAt = DateTime.parse("1970-01-01");

  SettingsData(
      {receivePushNotifications = false,
      allowLocationServices = true,
      anonymousMILADataShare = false,
      shareCovidTestResult = false});

  SettingsData.fromJson(Map<String, dynamic> _json) {
    this.user_data = UserData.fromJson(json.decode(_json['user_data']));

    this.receivePushNotifications = _json['push_notifications'];
    this.allowLocationServices = _json['location_service'];
    this.anonymousMILADataShare = _json['sharing_mila'];
    this.shareCovidTestResult = _json['share_covid_test_result'];
    this.lastSyncAt = _json['last_sync_at'] != null
        ? DateTime.parse(_json['last_sync_at'])
        : DateTime.parse("1970-01-01");
    this.lastGPSNotificationAt = _json['last_GPS_notification_at'] != null
        ? DateTime.parse(_json['last_GPS_notification_at'])
        : DateTime.parse("1970-01-01");
    if (_json['pushing_next_time'] == null) {
      this.pushingNextTime = null;
    } else {
      try {
        this.pushingNextTime = DateTime.parse(_json['pushing_next_time']);
      } catch (error) {
        this.pushingNextTime = null;
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'user_data': json.encode(this.user_data),
        'push_notifications': this.receivePushNotifications,
        'location_service': this.allowLocationServices,
        'sharing_mila': this.anonymousMILADataShare,
        'share_covid_test_result': this.shareCovidTestResult,
        'last_sync_at': this.lastSyncAt.toIso8601String(),
        'last_GPS_notification_at':
            this.lastGPSNotificationAt.toIso8601String(),
        'pushing_next_time': this.pushingNextTime == null
            ? null
            : this.pushingNextTime.toIso8601String(),
      };
}

/// Holds our user's data in a class
class UserData {
  int age; // User's age
  String gender; // User's gender
  String household;
  DateTime onboardingDate;
  LinkedHashMap<String, dynamic> rollingIds;

  String recommendationId;
  DateTime recommendationUpdateDate;
  DateTime settingsUpdateDate;
  DateTime testUpdateDate;
  DateTime symptomsUpdateDate;
  DateTime healthCheckUpdateDate;
  DateTime additionalQuestionsUpdateDate;

  bool consentForTeen; // Teen has adult consent
  bool hasChronicHealthCondition;
  bool isSmoker;
  bool hasDiabetes;
  bool isImmunosuppressed;
  bool hasCancer;
  bool hasHeartDisease;
  bool hasHypertension;
  bool hasChronicLungCondition;
  bool hadStroke;

  bool hasSymptoms;
  DateTime hasSymptomsSince;
  bool closeToInfected;
  bool hasTraveledOutsideCanada;
  bool hasCloseContactToOutsideTraveler;

  bool isHealthcareWorker;
  bool workWithInfected;

  bool covidTestResultIsPositive;
  DateTime covidTestSymptomsStartedDate;
  DateTime covidTestResultDate;

  int newSymptomaticRisk;
  int oldSymptomaticRisk;

  int recommandationLevel;

  //Symptoms
  bool hasDifficultyBreathing;
  String breathingDifficultySeverity;
  bool severeChestPain;
  bool hardTimeWakingUp;
  bool feelingConfused;
  bool lostConsciousness;
  bool lossOfSmell;
  bool lossOfAppetite;
  bool sneezing;
  bool fever;
  bool cough;
  bool muscleAches;
  bool fatigue;
  bool headaches;
  bool soreThroat;
  bool runnyNose;
  bool nausea;
  bool diarrhea;
  bool chills;

  // Additionnal questions
  bool hasHouseholdContact;
  bool hasFewPeopleContact;
  bool hasManyPeopleContact;
  bool wearMaskAtWork;
  bool workWithProtectiveScreen;
  bool washingHandsOutside;
  bool washHandsReturningHome;
  bool takePublicTransportation;
  DateTime lastPublicTransportationDate;
  String typeOfPublicTransportation;
  int timesUsingPublicTransit;

  // Poll
  bool maskPollAnswer;

  UserData(this.age, this.gender, this.household, this.rollingIds,
      {this.onboardingDate,
      this.recommendationId,
      this.recommendationUpdateDate,
      this.settingsUpdateDate,
      this.testUpdateDate,
      this.symptomsUpdateDate,
      this.healthCheckUpdateDate,
      this.additionalQuestionsUpdateDate,
      this.consentForTeen = false,
      this.hasChronicHealthCondition,
      this.isSmoker,
      this.hasDiabetes,
      this.isImmunosuppressed,
      this.hasCancer,
      this.hasHeartDisease,
      this.hasHypertension,
      this.hasChronicLungCondition,
      this.hadStroke,
      this.hasSymptoms,
      this.hasSymptomsSince,
      this.closeToInfected,
      this.hasTraveledOutsideCanada,
      this.hasCloseContactToOutsideTraveler,
      this.isHealthcareWorker,
      this.workWithInfected,
      this.covidTestResultIsPositive,
      this.covidTestSymptomsStartedDate,
      this.covidTestResultDate,
      this.newSymptomaticRisk = 0x03,
      this.oldSymptomaticRisk = 0x03,
      this.hasDifficultyBreathing = false,
      this.breathingDifficultySeverity,
      this.severeChestPain = false,
      this.hardTimeWakingUp = false,
      this.feelingConfused = false,
      this.lostConsciousness = false,
      this.lossOfSmell = false,
      this.lossOfAppetite = false,
      this.sneezing = false,
      this.fever = false,
      this.cough = false,
      this.muscleAches = false,
      this.fatigue = false,
      this.headaches = false,
      this.soreThroat = false,
      this.runnyNose = false,
      this.nausea = false,
      this.diarrhea = false,
      this.chills = false,
      this.hasHouseholdContact,
      this.hasFewPeopleContact,
      this.hasManyPeopleContact,
      this.wearMaskAtWork,
      this.workWithProtectiveScreen,
      this.washingHandsOutside,
      this.washHandsReturningHome,
      this.takePublicTransportation,
      this.lastPublicTransportationDate,
      this.typeOfPublicTransportation,
      this.timesUsingPublicTransit,
      this.maskPollAnswer});

  dynamic _getKeyFromJson(
      Map<String, dynamic> json, String key, dynamic defaultValue) {
    if (json[key] == null) {
      return defaultValue;
    }
    return json[key];
  }

  DateTime _getDateKeyFromJson(
      Map<String, dynamic> json, String key, DateTime defaultValue) {
    if (json[key] == null) {
      return defaultValue;
    }
    try {
      return DateTime.parse(json[key]);
    } catch (error) {
      return defaultValue;
    }
  }

  Map<String, dynamic> _fixJsonMigrations(Map<String, dynamic> json) {
    //Fix household: was an int at first, must be converted to string if value exists.
    if (json.containsKey('household') && json['household'] is int) {
      json['household'] = null;
    }
    return json;
  }

  UserData.fromJson(Map<String, dynamic> json) {
    //Here we apply changed to what might be breaking cases because of incorrect values.
    Map<String, dynamic> cleanedJson = _fixJsonMigrations(json);

    this.age = _getKeyFromJson(cleanedJson, 'age', null);
    this.gender = _getKeyFromJson(cleanedJson, 'gender', null);
    this.household = _getKeyFromJson(cleanedJson, 'household', null);
    this.onboardingDate =
        _getDateKeyFromJson(cleanedJson, 'onboarding_date', DateTime.now());
    this.rollingIds = _getKeyFromJson(
        json, 'rollingIds', new LinkedHashMap<String, dynamic>());
    this.recommendationId =
        _getKeyFromJson(cleanedJson, 'recommendation_id', null);
    this.recommendationUpdateDate = _getDateKeyFromJson(
        cleanedJson, 'recommendation_update_date', DateTime.now());
    this.settingsUpdateDate =
        _getDateKeyFromJson(cleanedJson, 'settings_update_date', null);
    this.testUpdateDate =
        _getDateKeyFromJson(cleanedJson, 'test_update_date', null);
    this.symptomsUpdateDate =
        _getDateKeyFromJson(cleanedJson, 'symptoms_update_date', null);
    this.healthCheckUpdateDate =
        _getDateKeyFromJson(cleanedJson, 'health_check_update_date', null);
    this.additionalQuestionsUpdateDate = _getDateKeyFromJson(
        cleanedJson, 'additional_questions_update_date', null);
    this.consentForTeen =
        _getKeyFromJson(cleanedJson, 'consent_for_teen', false);
    this.hasChronicHealthCondition =
        _getKeyFromJson(cleanedJson, 'chronic_health_condition', null);
    this.isSmoker = _getKeyFromJson(cleanedJson, 'smoker', null);
    this.hasDiabetes = _getKeyFromJson(cleanedJson, 'diabetes', null);
    this.isImmunosuppressed =
        _getKeyFromJson(cleanedJson, 'immunosuppressed', null);
    this.hasCancer = _getKeyFromJson(cleanedJson, 'cancer', null);
    this.hasHeartDisease = _getKeyFromJson(cleanedJson, 'heart_disease', null);
    this.hasHypertension = _getKeyFromJson(cleanedJson, 'hypertension', null);
    this.hasChronicLungCondition =
        _getKeyFromJson(cleanedJson, 'chronic_lung_condition', null);
    this.hadStroke = _getKeyFromJson(cleanedJson, 'stroke', null);

    this.hasSymptoms = _getKeyFromJson(cleanedJson, 'symptoms', null);
    this.hasSymptomsSince =
        _getDateKeyFromJson(cleanedJson, 'symptoms_since', null);
    this.closeToInfected = _getKeyFromJson(cleanedJson, 'close_person', null);
    this.hasTraveledOutsideCanada =
        _getKeyFromJson(cleanedJson, 'traveled_outside', null);
    this.hasCloseContactToOutsideTraveler =
        _getKeyFromJson(cleanedJson, 'outside_contact', null);

    this.isHealthcareWorker =
        _getKeyFromJson(cleanedJson, 'healthcare_worker', null);
    this.workWithInfected = _getKeyFromJson(cleanedJson, 'work_infected', null);
    this.newSymptomaticRisk =
        _getKeyFromJson(cleanedJson, 'new_symptomatic_risk', 0x03);
    this.oldSymptomaticRisk =
        _getKeyFromJson(cleanedJson, 'old_symptomatic_risk', 0x03);
    this.recommandationLevel =
        _getKeyFromJson(cleanedJson, 'recommandation_level', 0);

    this.covidTestResultIsPositive =
        _getKeyFromJson(cleanedJson, 'covid_test_result_is_positive', null);
    this.covidTestSymptomsStartedDate = _getDateKeyFromJson(
        cleanedJson, 'covid_test_symptoms_started_date', null);
    this.covidTestResultDate =
        _getDateKeyFromJson(cleanedJson, 'covid_test_result_date', null);

    this.hasDifficultyBreathing =
        _getKeyFromJson(cleanedJson, 'difficulty_breathing', false);
    this.breathingDifficultySeverity =
        _getKeyFromJson(cleanedJson, 'difficulty_breathing_severity', null);
    this.severeChestPain =
        _getKeyFromJson(cleanedJson, 'severe_chest_pain', false);
    this.hardTimeWakingUp =
        _getKeyFromJson(cleanedJson, 'hard_time_waking_up', false);
    this.feelingConfused =
        _getKeyFromJson(cleanedJson, 'feeling_confused', false);
    this.lostConsciousness =
        _getKeyFromJson(cleanedJson, 'lost_consciousness', false);
    this.lossOfSmell = _getKeyFromJson(cleanedJson, 'loss_of_smell', false);
    this.lossOfAppetite =
        _getKeyFromJson(cleanedJson, 'loss_of_appetite', false);
    this.sneezing = _getKeyFromJson(cleanedJson, 'sneezing', false);
    this.fever = _getKeyFromJson(cleanedJson, 'fever', false);
    this.cough = _getKeyFromJson(cleanedJson, 'cough', false);
    this.muscleAches = _getKeyFromJson(cleanedJson, 'muscle_aches', false);
    this.fatigue = _getKeyFromJson(cleanedJson, 'fatigue', false);
    this.headaches = _getKeyFromJson(cleanedJson, 'headaches', false);
    this.soreThroat = _getKeyFromJson(cleanedJson, 'sore_throat', false);
    this.runnyNose = _getKeyFromJson(cleanedJson, 'runny_nose', false);
    this.nausea = _getKeyFromJson(cleanedJson, 'nausea', false);
    this.diarrhea = _getKeyFromJson(cleanedJson, 'diarrhea', false);
    this.chills = _getKeyFromJson(cleanedJson, 'chills', false);

    this.hasHouseholdContact =
        _getKeyFromJson(cleanedJson, 'has_household_contact', null);
    this.hasFewPeopleContact =
        _getKeyFromJson(cleanedJson, 'has_few_people_contact', null);
    this.hasManyPeopleContact =
        _getKeyFromJson(cleanedJson, 'has_many_people_contact', null);
    this.wearMaskAtWork =
        _getKeyFromJson(cleanedJson, 'wear_mask_at_work', null);
    this.workWithProtectiveScreen =
        _getKeyFromJson(cleanedJson, 'work_with_protective_screen', null);
    this.washingHandsOutside =
        _getKeyFromJson(cleanedJson, 'washing_hands_outside', null);
    this.washHandsReturningHome =
        _getKeyFromJson(cleanedJson, 'wash_hands_returning_home', null);
    this.takePublicTransportation =
        _getKeyFromJson(cleanedJson, 'take_public_transportation', null);
    this.lastPublicTransportationDate = _getDateKeyFromJson(
        cleanedJson, 'last_public_transportation_date', null);
    this.typeOfPublicTransportation =
        _getKeyFromJson(cleanedJson, 'type_of_public_transportation', null);
    this.timesUsingPublicTransit =
        _getKeyFromJson(cleanedJson, 'times_using_public_transit', null);

    this.maskPollAnswer =
        _getKeyFromJson(cleanedJson, 'mask_poll_answer', null);
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'household': household,
        'onboarding_date':
            onboardingDate == null ? null : onboardingDate.toIso8601String(),
        'rollingIds': rollingIds,
        'recommendation_id': recommendationId,
        'recommendation_update_date': recommendationUpdateDate == null
            ? null
            : recommendationUpdateDate.toIso8601String(),
        'settings_update_date': settingsUpdateDate == null
            ? null
            : settingsUpdateDate.toIso8601String(),
        'test_update_date':
            testUpdateDate == null ? null : testUpdateDate.toIso8601String(),
        'symptoms_update_date': symptomsUpdateDate == null
            ? null
            : symptomsUpdateDate.toIso8601String(),
        'health_check_update_date': healthCheckUpdateDate == null
            ? null
            : healthCheckUpdateDate.toIso8601String(),
        'additional_questions_update_date':
            additionalQuestionsUpdateDate == null
                ? null
                : additionalQuestionsUpdateDate.toIso8601String(),
        'consent_for_teen': consentForTeen,
        'chronic_health_condition': hasChronicHealthCondition,
        'smoker': isSmoker,
        'diabetes': hasDiabetes,
        'immunosuppressed': isImmunosuppressed,
        'cancer': hasCancer,
        'heart_disease': hasHeartDisease,
        'hypertension': hasHypertension,
        'chronic_lung_condition': hasChronicLungCondition,
        'stroke': hadStroke,
        'symptoms': hasSymptoms,
        'symptoms_since': hasSymptomsSince == null
            ? null
            : hasSymptomsSince.toIso8601String(),
        'close_person': closeToInfected,
        'traveled_outside': hasTraveledOutsideCanada,
        'outside_contact': hasCloseContactToOutsideTraveler,
        'healthcare_worker': isHealthcareWorker,
        'work_infected': workWithInfected,
        'covid_test_result_is_positive': covidTestResultIsPositive,
        'covid_test_symptoms_started_date': covidTestSymptomsStartedDate == null
            ? null
            : covidTestSymptomsStartedDate.toIso8601String(),
        'covid_test_result_date': covidTestResultDate == null
            ? null
            : covidTestResultDate.toIso8601String(),
        'new_symptomatic_risk': newSymptomaticRisk,
        'old_symptomatic_risk': oldSymptomaticRisk,
        'difficulty_breathing': hasDifficultyBreathing,
        'difficulty_breathing_severity': breathingDifficultySeverity,
        'severe_chest_pain': severeChestPain,
        'hard_time_waking_up': hardTimeWakingUp,
        'feeling_confused': feelingConfused,
        'lost_consciousness': lostConsciousness,
        'loss_of_smell': lossOfSmell,
        'loss_of_appetite': lossOfAppetite,
        'sneezing': sneezing,
        'fever': fever,
        'cough': cough,
        'muscle_aches': muscleAches,
        'fatigue': fatigue,
        'headaches': headaches,
        'sore_throat': soreThroat,
        'runny_nose': runnyNose,
        'nausea': nausea,
        'diarrhea': diarrhea,
        'chills': chills,
        'has_household_contact': hasHouseholdContact,
        'has_few_people_contact': hasFewPeopleContact,
        'has_many_people_contact': hasManyPeopleContact,
        'wear_mask_at_work': wearMaskAtWork,
        'work_with_protective_screen': workWithProtectiveScreen,
        'washing_hands_outside': washingHandsOutside,
        'wash_hands_returning_home': washHandsReturningHome,
        'take_public_transportation': takePublicTransportation,
        'last_public_transportation_date': lastPublicTransportationDate == null
            ? null
            : lastPublicTransportationDate.toIso8601String(),
        'type_of_public_transportation': typeOfPublicTransportation,
        'times_using_public_transit': timesUsingPublicTransit,
        'mask_poll_answer': maskPollAnswer,
        'recommandation_level': recommandationLevel
      };

  String toString() {
    return "[User] age: $age, gender: $gender";
  }
}
