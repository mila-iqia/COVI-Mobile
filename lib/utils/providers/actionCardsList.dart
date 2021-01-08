import 'package:flutter/material.dart';
import 'package:covi/utils/settings.dart';

enum ActionType { regular, alert }

class ActionData {
  int weight;
  String url;
  String icon;
  DateTime lastUpdate;

  ActionData(this.weight, this.url, this.icon, {this.lastUpdate});
}

class ActionsManager extends ChangeNotifier {
  Map<String, int> _lastActionsWeight = new Map();
  Map<String, ActionData> _actions = {
    "AC001": new ActionData(30, "/actions/self-diagnostic", "action-hand.svg"),
    "AC002": new ActionData(10, "/actions/test-result", "action-check.svg"),
    "AC003": new ActionData(0, "/profile", "action-setup.svg"),
    "AC004": new ActionData(0, "/profile", "action-setup.svg"),
    "AC005": new ActionData(
        45, "/actions/additionnal-questions", "action-check.svg"),
    "AC006": new ActionData(0, "/actions/health-check", "action-health.svg"),
    // "AC007": new ActionData(85, "", "action-check.svg"),
    "AC008": new ActionData(0, "/profile", "action-health.svg"),
    "AC009": new ActionData(0, "/actions/get-tested", "action-health.svg")
  };

  Map<String, int> get lastActionsWeight => _lastActionsWeight;
  Map<String, ActionData> get actions => _actions;

  /// This is to keep a copy of old actions weight before it change
  ///
  /// Used to make comparison with the new one for notifications
  copyActionWeight() {
    this.actions.forEach((key, action) {
      this.lastActionsWeight[key] = action.weight;
    });
  }

  List<String> getActionsFromUserData(
      SettingsData settings, ActionType actionType) {
    List<String> actionsList = [];
    UserData data = settings.user_data;

    copyActionWeight();

    DateTime now = new DateTime.now();
    final bool hasSelfAssessed = data.symptomsUpdateDate != null;
    final bool hasPassATest = data.testUpdateDate != null;
    final bool hasHealthChecked = data.healthCheckUpdateDate != null;
    final bool hasFilledAdditionalQuestions =
        data.additionalQuestionsUpdateDate != null;
    final bool hasSymptoms =
        data.hasSymptoms != null ? data.hasSymptoms : false;
    final bool hasMildOrModerateSymptoms =
        data.hasDifficultyBreathing != null &&
            data.hasDifficultyBreathing &&
            data.breathingDifficultySeverity != "heavy";
    final bool hasSymptomsDuringHealthCheck = hasSymptoms && !hasSelfAssessed;
    final bool hasSymptomsAnd3DaysSinceLastAssessment = hasSymptoms &&
        hasSelfAssessed &&
        now.difference(data.symptomsUpdateDate).inDays >= 3;
    final bool noSymptomsAnd7DaysSinceOnboarding = !hasSymptoms &&
            (hasSelfAssessed &&
                now.difference(data.symptomsUpdateDate).inDays >= 7) ||
        (hasHealthChecked &&
            now.difference(data.healthCheckUpdateDate).inDays >= 7);

    final bool receivePushNotifications =
        settings.receivePushNotifications != null
            ? settings.receivePushNotifications
            : false;

    final bool days14SinceLastHealthCheck = hasHealthChecked &&
        now.difference(data.healthCheckUpdateDate).inDays >= 14;

    final bool hasCompleteProfile = data.age != null;

    // Manage actions weight
    if (hasSelfAssessed) {
      actions['AC001'].lastUpdate = data.symptomsUpdateDate;
    }

    actions['AC001'].weight = 30;

    if (hasSymptomsDuringHealthCheck) {
      actions['AC001'].weight = 90;
    } else if (hasSymptomsAnd3DaysSinceLastAssessment) {
      actions['AC001'].weight = 60;
    } else if (noSymptomsAnd7DaysSinceOnboarding) {
      actions['AC001'].weight = 40;
    }

    if (hasPassATest) {
      actions['AC002'].lastUpdate = data.testUpdateDate;
    }

    actions['AC003'].weight = 0;
    if (!receivePushNotifications) {
      actions['AC003'].weight = 55;
    }

    if (hasFilledAdditionalQuestions) {
      actions['AC005'].lastUpdate = data.additionalQuestionsUpdateDate;
    }

    if (hasHealthChecked) {
      actions['AC006'].lastUpdate = data.healthCheckUpdateDate;
    }

    actions['AC006'].weight = 0;
    if (!hasHealthChecked) {
      actions['AC006'].weight = 80;
    } else if (days14SinceLastHealthCheck) {
      actions['AC006'].weight = 54;
    }

    actions['AC008'].weight = 0;
    if (!hasCompleteProfile) {
      actions['AC008'].weight = 83;
    }

    actions['AC009'].weight = 0;
    if (hasMildOrModerateSymptoms) {
      actions['AC009'].weight = 90;
    }

    if (actionType == ActionType.alert) {
      actions.forEach((k, v) {
        if (v.weight >= 50) {
          actionsList.add(k);
        }
      });
    } else {
      actions.forEach((k, v) {
        if (v.weight < 50 && v.weight > 0) {
          actionsList.add(k);
        }
      });
    }

    actionsList.sort((a, b) {
      return actions[b].weight.compareTo(actions[a].weight);
    });

    return actionsList;
  }
}
