import 'dart:async';

import 'package:covi/screens/actions/additionnalQuestions.dart';
import 'package:covi/screens/actions/getTested.dart';
import 'package:covi/screens/actions/healthCheck.dart';
import 'package:covi/screens/actions/selfDiagnostic.dart';
import 'package:covi/screens/actions/testResult.dart';
import 'package:covi/screens/advices.dart';
import 'package:covi/screens/home.dart';
import 'package:covi/screens/preDashboard.dart';
import 'package:covi/screens/introPrivacy.dart';
import 'package:covi/screens/onboarding.dart';
import 'package:covi/screens/officialResources.dart';
import 'package:covi/screens/profile.dart';
import 'package:covi/screens/ageConsent.dart';
import 'package:covi/screens/setup.dart';
import 'package:covi/screens/intro.dart';
import 'package:covi/screens/test.dart';
import 'package:covi/services/bluetooth_gatt_service.dart';
import 'package:covi/utils/backgroundWorker.dart';

import 'package:covi/utils/notifications.dart';
import 'package:covi/utils/providers/bottomNavigationBarProvider.dart';
import 'package:covi/utils/providers/actionCardsList.dart';
import 'package:covi/utils/providers/menuNotificationProvider.dart';
import 'package:covi/utils/providers/contentManagerProvider.dart';
import 'package:covi/utils/providers/pollsProvider.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:covi/utils/settings.dart';
import 'package:covi/utils/constants.dart';
import 'package:covi/utils/covid_stats.dart';
import 'package:covi/utils/user_regions.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:provider/provider.dart';
import 'package:background_fetch/background_fetch.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import 'dart:io' show Platform;

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print('[Covi BackgroundFetch] Headless event received. Create notification');
  BackgroundFetch.finish(taskId);
}

// Dart main function
void main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        useCountryCode: false,
        fallbackFile: 'en',
        basePath: 'assets/i18n',
        forcedLocale: Locale('en')),
  );

  WidgetsFlutterBinding.ensureInitialized();
  await flutterI18nDelegate.load(null);

  // Prepare notifications
  await Notifications.prepareNotifications();

  // Conifgure Firebase Messaging
  await Notifications.prepareFirebaseNotifications();

  //_firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Start the Flutter app
  runApp(Phoenix(
      child: RouteObserverProvider(
    child: MainScreen(
      flutterI18nDelegate: flutterI18nDelegate,
    ),
  )));
}

// Our main Flutter screen
class MainScreen extends StatefulWidget {
  final FlutterI18nDelegate flutterI18nDelegate;

  MainScreen({key, this.flutterI18nDelegate}) : super(key: key);

  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  static String _notificationAppClosedTitle = "Covi app";
  static String _notificationAppClosedBody =
      "Please keep Covi opened to keep track of your contacts";

  static void setBackgroundTaskTranslation(BuildContext context) {
    _notificationAppClosedTitle =
        FlutterI18n.translate(context, "notifications.N007.title");
    _notificationAppClosedBody =
        FlutterI18n.translate(context, "notifications.N007.body");
  }

  @override
  void initState() {
    super.initState();

    // only init background fetch on Android atm
    initPlatformState();
    BackgroundFetch.start().then((int status) {
      print('[Covi BackgroundFetch] start success: $status');
    }).catchError((e) {
      print('[Covi BackgroundFetch] start FAILURE: $e');
    });
    ;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE,
        ), (String taskId) async {
      // This is the fetch-event callback.
      print("[Covi BackgroundFetch] Event received $taskId");
      switch (taskId) {
        case 'com.covi.app.startBluetooth':
          print("[Covi BackgroundFetch] Start BL Service");
          int result = await BluetoothGattService.startService();

          if (result == -1) {
            // could not start service last time, try again in 15 minutes
            BackgroundFetch.scheduleTask(TaskConfig(
              taskId: "com.covi.app.startBluetooth",
              delay: 900000, // <-- 15 minutes in milliseconds
              stopOnTerminate: false,
              enableHeadless: true,
            ));
          }
          break;
        case 'com.covi.app.changeDhKey':
          await BluetoothGattService.pullSaveSharedKeysAndChangePublicKey();

          BackgroundFetch.scheduleTask(TaskConfig(
            taskId: "com.covi.app.changeDhKey",
            delay: 900000, // <-- 15 minutes in milliseconds
            stopOnTerminate: false,
            enableHeadless: true,
          ));

          break;
        case 'com.covi.app.scheduleAPPClosedNotification':
          // print("[Covi BackgroundFetch] Reschedule app closed notification");
          await Notifications.createNotification(
              _notificationAppClosedTitle, _notificationAppClosedBody, "",
              when: new Duration(minutes: 60),
              notificationID: notificationAppClosed);
          await Notifications.createNotification(
              _notificationAppClosedTitle, _notificationAppClosedBody, "",
              interval: RepeatInterval.Daily,
              notificationID: notificationAppClosed + 1);

          BackgroundFetch.scheduleTask(TaskConfig(
            taskId: "com.covi.app.scheduleAPPClosedNotification",
            delay: 900000, // <-- reset notification every 15 minutes
            stopOnTerminate: true,
            enableHeadless: false,
          ));

          break;
        case 'com.covi.app.syncMailbox':
          await BackgroundWorker.syncWithMailboxes();

          BackgroundFetch.scheduleTask(TaskConfig(
            taskId: "com.covi.app.syncMailbox",
            delay: 86000000, // sync every 24 hours
            stopOnTerminate: true,
            enableHeadless: false,
          ));

          break;
        default:
          print("[Covi BackgroundFetch] Default fetch task");
      }

      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[Covi BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[Covi BackgroundFetch] configure ERROR: $e');
    });

    if (Platform.isAndroid) {
      // Schedule tasks
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.covi.app.startBluetooth",
          delay: 1000, // <-- milliseconds
          stopOnTerminate: true,
          startOnBoot: false,
          enableHeadless: false));

      BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.covi.app.changeDhKey",
        delay: 1000, // <-- 15 minutes in milliseconds
        stopOnTerminate: true,
        startOnBoot: false,
        enableHeadless: false,
      ));

      BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.covi.app.com.scheduleAPPClosedNotification",
        delay: 1000, // <-- 1 seconds
        stopOnTerminate: true,
        startOnBoot: false,
        enableHeadless: false,
      ));

      BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.covi.app.syncMailbox SyncWithMailbox",
        delay: 10000, // <-- 1 seconds
        stopOnTerminate: true,
        startOnBoot: false,
        enableHeadless: false,
      ));
    } else if (Platform.isIOS) {
      await BluetoothGattService.pullSaveSharedKeysAndChangePublicKey();
      await BluetoothGattService.startService();

      /**
       * this will only works when the device's screen is opened but since 
       * Apple won't guarantee consistent background-fetch events this is the only way around
       * I can think of atm. See https://pub.dev/packages/background_fetch
       * 
       * > iOS can take some hours or even days to start a consistently scheduling background-fetch events 
       * > since iOS schedules fetch events based upon the user's patterns of activity. If Simulate Background Fetch works, 
       * > your can be sure that everything is working fine. You just need to wait.
       * 
       */

      Timer.periodic(new Duration(minutes: 15), (timer) async {
        await BluetoothGattService.pullSaveSharedKeysAndChangePublicKey();
      });

      Timer.periodic(new Duration(hours: 1), (timer) async {
        await BackgroundWorker.syncWithMailboxes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark));

    return MultiProvider(
        // Load the providers/services used by the app
        providers: [
          //ChangeNotifierProvider<NearbyService>(
          //create: (context) => NearbyService(context)),
          ChangeNotifierProvider<BottomNavigationBarProvider>(
              create: (context) => BottomNavigationBarProvider()),
          ChangeNotifierProvider<SettingsManager>(
              create: (context) => SettingsManager()),
          ChangeNotifierProvider<ActionsManager>(
            create: (context) => ActionsManager(),
          ),
          ChangeNotifierProvider<UserRegionsManager>(
            create: (context) => UserRegionsManager(context),
          ),
          ChangeNotifierProvider<CovidStatsManager>(
            create: (context) => CovidStatsManager(context),
          ),
          ChangeNotifierProvider<ContentManagerProvider>(
            create: (context) => ContentManagerProvider(),
          ),
          ChangeNotifierProvider<RecommendationsProvider>(
            create: (context) => RecommendationsProvider(context),
          ),
          ChangeNotifierProvider<PollsProvider>(
            create: (context) => PollsProvider(),
          ),
          ChangeNotifierProvider<MenuNotificationProvider>(
            create: (context) => MenuNotificationProvider(context),
          ),
        ],
        child: MaterialApp(
          navigatorObservers: [RouteObserverProvider.of(context)],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            widget.flutterI18nDelegate
          ],

          // Tile of the app shown in the app drawer, not on the homescreen
          title: 'Covid App',
          theme: ThemeData(
              primaryColor: darkBlue, accentColor: yellow, fontFamily: 'Neue'),

          // The routes define our screens.
          // Learn more about this here: https://flutter.dev/docs/cookbook/navigation/named-routes
          initialRoute: '/',
          routes: {
            '/': (context) => HomeScreen(),
            '/profile': (context) => ProfileScreen(),
            '/official-resources': (context) => OfficialResourcesScreen(),
            '/onboarding': (context) => OnboardingScreen(),
            '/pre-dashboard': (context) => PreDashboardScreen(),
            '/advices': (context) => AdvicesScreen(),
            '/actions/test-result': (context) => TestResults(),
            '/actions/self-diagnostic': (context) => SelfDiagnostic(),
            '/actions/get-tested': (context) => GetTestedScreen(),
            '/actions/health-check': (context) => HealthCheck(),
            '/actions/additionnal-questions': (context) =>
                AdditionnalQuestions(),
            '/profile/age-consent': (context) => AgeConsent(),
            '/setup': (context) => SetupScreen(),
            '/intro': (context) => IntroScreen(),
            '/intro-privacy': (context) => IntroPrivacyScreen(),
            '/test': (context) => TestScreen()
          },
          builder: (BuildContext context, Widget child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(
                  textScaleFactor:
                      data.textScaleFactor >= 1.5 ? 1.5 : data.textScaleFactor),
              child: child,
            );
          },
        ));
  }
}

//Splash Screen
