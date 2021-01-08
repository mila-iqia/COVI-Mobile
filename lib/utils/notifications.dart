import 'dart:convert';
import 'dart:io' show Platform;

import 'package:covi/utils/settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Backgroud handler for firebase
Future<dynamic> firebaseBackgroundHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    // final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    // final dynamic notification = message['notification'];
  }

  return null;
}

class Notifications {
  /// Prepare local notifications
  static Future<void> prepareNotifications() async {
    Logger().v("[NotificationsManager] Preparing notifications...");

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Prepare Android for notifications
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_name');

    // Prepare iOS for notifications
    IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            // We don't want the plugin to request the permissions since we'll do it later on in the app
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
            onDidReceiveLocalNotification:
                (int id, String title, String body, String payload) async {
              // Yee haw
            });

    // Prepare notifications
    InitializationSettings initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) => handlePayload(payload));
  }

  /// Prepare firebase notifications
  static Future<void> prepareFirebaseNotifications() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    // Setup Firebase callbacks
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {},
      onBackgroundMessage: Platform.isAndroid
          ? firebaseBackgroundHandler
          : null, //Platform.isAndroid ? firebaseBackgroundHandler : null,
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
    );

    _firebaseMessaging.getToken().then((token) {
      Logger().v(token);
    });
  }

  /// Payloads handler
  static Future<void> handlePayload(String payload) async {
    Logger().v(payload);

    return;
  }

  /// Create a notification
  static Future<void> createNotification(
      String title, String body, String payload,
      {int notificationID = 0, Duration when, RepeatInterval interval}) async {
    // if user doesn't want to receive notifications, don't show him any!
    SettingsManager settingsManager = SettingsManager();
    await settingsManager.loadSettings();
    if (!settingsManager.settings.receivePushNotifications) return;

    if (when == null) {
      Logger().v("[NotificationsManager] Creating a notification...");
    } else {
      Logger().v("[NotificationsManager] Scheduling a notification...");
    }

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Prepare the notification for Android
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('com.covi.app', 'Covi', 'Covi alerts',
            importance: Importance.Max,
            priority: Priority.High,
            ticker: 'ticker');

    // Prepare the notification for iOS
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();

    // Finalize the notification
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    // Show/schedule the notification
    if (when != null) {
      await flutterLocalNotificationsPlugin.schedule(notificationID, title,
          body, DateTime.now().add(when), platformChannelSpecifics,
          payload: payload, androidAllowWhileIdle: true);
    } else if (interval != null) {
      await flutterLocalNotificationsPlugin.periodicallyShow(
          notificationID, title, body, interval, platformChannelSpecifics,
          payload: payload);
    } else {
      await flutterLocalNotificationsPlugin.show(
          notificationID, title, body, platformChannelSpecifics,
          payload: payload);
    }

    if (when == null) {
      Logger().v("[NotificationsManager] Notifcation was shown.");
    } else {
      Logger().v("[NotificationsManager] Notifcation was scheduled.");
    }
  }

  static Future<void> cancelNotification(int notificationId) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  static Future<void> cancelAllNotifications() async {
    Logger().d("Cancel all notifications");
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> listNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests;
  }

  /// Create a Firebase notification
  static Future<void> createFirebaseNotification(
      String title, String body) async {
    // Firebase token
    const String serverToken =
        "AAAAx737F88:APA91bGx8c7ad1JkSxLda3TuNx1h3IRu_T8q3DTWO7_3XhNedAhJSFDCc9Wj0clH6565Nyy8vMCk86EPJmXpLKnOBLGaEMXfK4zX7mjuRA3lUP9qlzIfs0xpRG__BmFkTRVAl1VP9uwL";

    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    const String firebaseURL = "https://fcm.googleapis.com/fcm/send";

    // HTTP headers for Firebase
    const Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    };

    // Notification object
    final Map<String, String> notification = {'body': body, 'title': title};

    // Data object
    final Map<String, String> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done'
    };

    // Body object
    final Map<String, dynamic> httpBody = {
      'notification': notification,
      'data': data,
      'priority': 'high',
      'to': await firebaseMessaging.getToken()
    };

    // Do our http request
    await http.post(firebaseURL, headers: headers, body: jsonEncode(httpBody));

    Logger().v("[NotificationsManager] Pushed a notification to firebase.");
  }
}
