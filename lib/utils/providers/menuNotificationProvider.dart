import 'actionCardsList.dart';

import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

enum NotificationType { dot, urgent, all }
enum NotificationsName { health, tips }

class MenuNotificationProvider extends ChangeNotifier {
  static MenuNotificationProvider _instance;
  bool isFirstRun = true;
  MainRecommendation oldRecommendation;

  RecommendationsProvider recommendationsManager;
  SettingsManager settingsManager;
  ActionsManager actionsManager;

  /// Keys -> health, tips
  /// values -> health, tips
  Map<String, dynamic> notifications = {
    "health": {"dot": false, "911": false},
    "tips": {"dot": false, "911": false},
  };

  MenuNotificationProvider(BuildContext context) {
    Logger().v("[MenuNotificationProvider] Constructor...");

    recommendationsManager =
        Provider.of<RecommendationsProvider>(context, listen: false);
    settingsManager = Provider.of<SettingsManager>(context, listen: false);
    actionsManager = Provider.of<ActionsManager>(context, listen: false);

    MenuNotificationProvider._instance = this;
  }

  String checkNotifications(NotificationsName notification) {
    String notif;

    switch (notification) {
      case NotificationsName.health:
        notif = "health";
        break;
      case NotificationsName.tips:
        notif = "tips";
        break;
      default:
        notif = "health";
    }

    return notif;
  }

  String checkNotificationType(NotificationType notificationType) {
    String type;

    switch (notificationType) {
      case NotificationType.dot:
        type = "dot";
        break;
      case NotificationType.urgent:
        type = "911";
        break;
      case NotificationType.all:
        type = "all";
        break;
      default:
        type = "all";
    }

    return type;
  }

  /// Enter a key of notifications to turn it off.
  void turnNotificationOff(NotificationsName notification, bool shouldNotify,
      {NotificationType notificationType}) {
    String notif = checkNotifications(notification);
    String type = checkNotificationType(notificationType);

    if (type == "all")
      notifications[notif].forEach((a, b) {
        notifications[notif][a] = false;
      });
    else
      notifications[notif][type] = false;

    if (shouldNotify) {
      notifyListeners();
    }
  }

  /// Enter a key of notifications to turn it on.
  void turnNotificationOn(NotificationsName notification,
      NotificationType notificationType, bool shouldNotify) {
    String notif = checkNotifications(notification);
    String type = checkNotificationType(notificationType);

    notifications[notif][type] = true;
    if (shouldNotify) {
      notifyListeners();
    }
  }

  /// Check if tip change
  void checkRecommendationChange(shouldNotify) {
    MainRecommendation currentRecommendation =
        recommendationsManager.mainRecommendation;

    if (oldRecommendation == null) {
      oldRecommendation = currentRecommendation;
      return;
    }
    ;

    if (oldRecommendation.category != currentRecommendation.category) {
      oldRecommendation = currentRecommendation;
      turnNotificationOn(
          NotificationsName.tips, NotificationType.dot, shouldNotify);
    }
  }

  /// Check if user need to call 911 (Keep notification active until user dont need anymore)
  void check911(shouldNotify) {
    if (recommendationsManager.mainRecommendation?.id == "BB_C001") {
      turnNotificationOn(
          NotificationsName.tips, NotificationType.urgent, shouldNotify);
    } else {
      turnNotificationOff(NotificationsName.tips, shouldNotify,
          notificationType: NotificationType.urgent);
    }
  }

  /// Check if health weight change
  void checkWeight(shouldNotify) {
    bool shouldTriggerNotification = false;
    Map<String, ActionData> actions = actionsManager.actions;

    // Update weight states to check notifications
    if (settingsManager != null) {
      actionsManager.getActionsFromUserData(
          settingsManager.settings, ActionType.alert);
    }

    Map<String, int> lastActionsWeight = actionsManager.lastActionsWeight;

    actions.forEach((key, action) {
      if (lastActionsWeight[key] != action.weight && action.weight != 0) {
        shouldTriggerNotification = true;
      }
    });

    if (shouldTriggerNotification)
      turnNotificationOn(
          NotificationsName.health, NotificationType.dot, shouldNotify);
  }

  /// Combine all menu notification check (To show dot or not)
  ///
  /// checkWeight() && checkRecommendationChange() && check911()
  static void checkAll({shouldNotify: true}) {
    MenuNotificationProvider._instance.checkWeight(shouldNotify);
    MenuNotificationProvider._instance.checkRecommendationChange(shouldNotify);
    MenuNotificationProvider._instance.check911(shouldNotify);
  }
}
