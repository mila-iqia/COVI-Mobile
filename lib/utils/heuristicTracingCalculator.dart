// 000F030F03040700$$$$$$$$$$$$$$$$
// [type de donné(1)]
// [nouveau niveau de risque officiel(1)]
// [ancien niveau de risque officiel(1)]
// [nouveau niveau de risque symptomatique(1)] : R'
// [ancien niveau de risque symptomatique(1)] : old R'
// [dailyrollingid (1)]
// [dayofmonthofupdate(1)]
// [versionofquestionssymptoms(1)]
// [padding(8)] : $ -> 0

import 'dart:math';

import 'package:covi/utils/settings.dart';
import 'package:logger/logger.dart';

class HeuristicTracingCalculator {
  // user's declaration
  bool _isTestedPositive;
  int _usersRiskFactor;
  int _recommandationLevel;
  DateTime _covidTestResultDate;
  bool _hasBeenTested;
  bool _hasSymptoms;
  DateTime _hasSymptomsSince;
  UserData _userData;

  UserData get userData => _userData;

  HeuristicTracingCalculator(UserData userData) {
    _userData = userData;

    _usersRiskFactor = _userData.newSymptomaticRisk; // risk factor: R
    _recommandationLevel =
        _userData.recommandationLevel; // recommandation level : L
    _hasBeenTested = _userData.covidTestResultIsPositive == null ? false : true;
    _isTestedPositive =
        _hasBeenTested ? _userData.covidTestResultIsPositive : false;
    _covidTestResultDate = _userData.covidTestResultDate;
    _hasSymptoms = _userData.hasSymptoms ?? false;
    _hasSymptomsSince = _userData.hasSymptomsSince;
  }

  /**
   * Heuristic tracing algorithm 
   */
  void heuristicTracingAlgo(String mailboxData) {
    // contact risk factor: R'
    int contactRisk = int.parse(mailboxData.substring(6, 8), radix: 16);

    int diffDiagnosticDays = _covidTestResultDate != null
        ? compareDateWithToday(_covidTestResultDate)
        : -15;
    int diffSymptomsDays = _hasSymptomsSince != null
        ? compareDateWithToday(_hasSymptomsSince)
        : -1;

    _validateDiagnostic(diffDiagnosticDays);
    _validateSymptome(diffSymptomsDays);
    _validateContactRisk(contactRisk, diffDiagnosticDays);

    Logger().d("User risk factor : " + _userData.newSymptomaticRisk.toString());
    Logger().d("User recommandation level : " +
        _userData.recommandationLevel.toString());
  }

  /**
   * validate the risk and recommandation level based on the diagnostic
   */
  void _validateDiagnostic(int diffDiagnosticDays) {
    if (!_hasBeenTested) {
      return;
    }

    // gestion du laps de temps ?
    if (diffDiagnosticDays >= -14 && _isTestedPositive) {
      updateRisksAndRecommandation(15, 3); // set R=15 (0x0F) & L=3
      return;
    }

    if (!_isTestedPositive &&
        ((_hasSymptoms && _hasSymptomsSince.isBefore(_covidTestResultDate)) ||
            !_hasSymptoms)) {
      updateRisksAndRecommandation(1, 0); // set R=1 & l=0
      return;
    }
  }

  /**
   * validate the risk and recommandation level based on the symptome list
   */
  void _validateSymptome(int diffSymptomsDays) {
    if (_hasBeenTested &&
        (_hasSymptoms && _hasSymptomsSince.isBefore(_covidTestResultDate))) {
      return;
    }

    if (_hasSymptoms && diffSymptomsDays < 7) {
      String symptomsSeverity = getSymptomsSeverity();

      switch (symptomsSeverity) {
        case "severe":
          updateRisksAndRecommandation(12, 3); // R=12 & L=3
          return;
        case "intermediate":
          updateRisksAndRecommandation(10, 3); // R=10 & L=3
          return;
        case "light":
          updateRisksAndRecommandation(7, 2); // R=7 & L=2
          return;
      }
    }
  }

  // tested : works
  /**
   * validate the risk and recommandation level based on the contacts encountered
   */
  void _validateContactRisk(int contactRisk, int diffDiagnosticDays) {
    if (_hasSymptoms || (_hasBeenTested && diffDiagnosticDays >= -14)) {
      return;
    }

    if (contactRisk <= 6) {
      int maxRisk = max(contactRisk - 5, _usersRiskFactor);
      int recommandation = max(0, _recommandationLevel);
      updateRisksAndRecommandation(maxRisk, recommandation); // R=0 & L=0
      return;
    }

    if (contactRisk > 6 && contactRisk < 10) {
      int maxRisk = max(contactRisk - 5, _usersRiskFactor);
      int recommandation = max(1, _recommandationLevel);
      updateRisksAndRecommandation(
          maxRisk, recommandation); // R=max(contactRisk -5, usersRisk) & L=1
      return;
    }

    if (contactRisk >= 10 && contactRisk < 12) {
      int maxRisk = max(contactRisk - 5, _usersRiskFactor);
      int recommandation = max(2, _recommandationLevel);
      updateRisksAndRecommandation(
          maxRisk, recommandation); // R=max(contactRisk -5, usersRisk) & L=2
      return;
    }

    if (contactRisk >= 12) {
      int maxRisk = max(contactRisk - 5, _usersRiskFactor);
      int recommandation = max(3, _recommandationLevel);
      updateRisksAndRecommandation(
          maxRisk, recommandation); // R=max(contactRisk -5, usersRisk) &  L=3
      return;
    }
  }

  /**
   * updates user's new and old risk factors
   * optionally updates the recommandation level too
   */
  void updateRisksAndRecommandation(int newRisk, [int recommandation]) {
    _userData.oldSymptomaticRisk = _usersRiskFactor;
    _userData.newSymptomaticRisk = _usersRiskFactor = newRisk;

    if (recommandation != null) {
      _userData.recommandationLevel = recommandation;
    }
  }

  /**
   * returns the number of days between two dates
   */
  int compareDateWithToday(DateTime date) {
    DateTime today = new DateTime.now();
    int difference = date.difference(today).inDays;

    return difference;
  }

  /**
   * returns user's symptoms severity
   */
  String getSymptomsSeverity() {
    final bool hasSevereSymptoms = ((_userData.hasDifficultyBreathing &&
            _userData.breathingDifficultySeverity == 'heavy') ||
        _userData.severeChestPain ||
        _userData.hardTimeWakingUp ||
        _userData.feelingConfused ||
        _userData.lostConsciousness);

    final bool hasModerateSymptoms = (_userData.hasDifficultyBreathing &&
        _userData.breathingDifficultySeverity == 'moderate');

    final bool hasLightSymptoms = ((_userData.hasDifficultyBreathing &&
            _userData.breathingDifficultySeverity == 'light') ||
        _userData.sneezing ||
        _userData.fever ||
        _userData.cough ||
        _userData.muscleAches ||
        _userData.fatigue ||
        _userData.headaches ||
        _userData.soreThroat ||
        _userData.runnyNose ||
        _userData.nausea ||
        _userData.diarrhea ||
        _userData.chills ||
        _userData.lossOfSmell ||
        _userData.lossOfAppetite);

    String severity = hasSevereSymptoms
        ? "severe"
        : hasModerateSymptoms
            ? "intermediate"
            : hasLightSymptoms ? "light" : "asymptomatic";
    return severity;
  }
}
