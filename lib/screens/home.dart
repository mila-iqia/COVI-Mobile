import 'dart:io';

import 'dart:ui';
import 'package:covi/screens/advices.dart';
import 'package:covi/screens/dashboard.dart';
import 'package:covi/screens/health.dart';
import 'package:covi/screens/resources.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/providers/bottomNavigationBarProvider.dart';
import 'package:covi/utils/providers/contentManagerProvider.dart';
import 'package:covi/utils/providers/pollsProvider.dart';
import 'package:covi/utils/providers/menuNotificationProvider.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:covi/utils/settings.dart';
import 'package:covi/utils/updater_checker.dart';
import 'package:covi/utils/user_regions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({key}) : super(key: key);

  _HomeSreenState createState() => _HomeSreenState();
}

class _HomeSreenState extends State<HomeScreen>
    with RouteAware, RouteObserverMixin {
  String locale;
  bool isHomeReady = false;

  SettingsManager settingsManager;

  static List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    HealthScreen(),
    AdvicesScreen(),
    ResourcesScreen(),
  ];

  void _checkForUpdates() async {
    UpdateChecker checker = new UpdateChecker();

    Update update = await checker.checkForUpdate();

    if (update != null) {
      checker.showUpdateDialog(
          context, update, await settingsManager.getLang());
    }
  }

  void _loadMainScreen() {
    setState(() {
      isHomeReady = true;
    });
  }

  void _updateLocale() async {
    settingsManager.getLang().then((lang) => setState(() {
          locale = lang;
        }));
    MainScreenState.setBackgroundTaskTranslation(context);
  }

  @override
  void didPopNext() {
    if (isHomeReady) {
      MenuNotificationProvider.checkAll();
    }
  }

  @override
  void initState() {
    super.initState();

    // Check for setup after tree has been built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsManager = Provider.of<SettingsManager>(context, listen: false);
      await settingsManager.loadLang(context);
      _checkForUpdates();
      _updateLocale();

      bool setupComplete = await settingsManager.isSetupComplete();

      if (!setupComplete) {
        Navigator.of(context).pushReplacementNamed("/intro");
      } else {
        _loadMainScreen();
      }
    });
  }

  BottomNavigationBarItem _buildNavigationBarItem(
      String svgPicture, String titlei18n,
      {bool isNotificationDotVisible = false,
      bool isAlertNotification = false,
      double notificationPositionX = 0}) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    Widget icon({String svgPicture, bool active = false}) {
      return Container(
          height: 30 * sizeMultiplier,
          width: 38 * sizeMultiplier,
          child: Stack(children: [
            Center(
                child: ExcludeSemantics(
                    child: SvgPicture.asset(
              svgPicture,
              width: 24 * sizeMultiplier,
              height: 24 * sizeMultiplier,
              color: active ? Constants.mediumBlue : null,
            ))),
            // Dot notification
            if (isNotificationDotVisible && !isAlertNotification)
              Positioned(
                  top: 0,
                  right: notificationPositionX,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Constants.mediumRed,
                        borderRadius: BorderRadius.all(Radius.circular(7.0))),
                    width: 12 * sizeMultiplier,
                    height: 12 * sizeMultiplier,
                  )),
            // Dot notification 911 style
            if (isAlertNotification)
              Positioned(
                  top: 0,
                  right: notificationPositionX,
                  child: SvgPicture.asset(
                    'assets/svg/navbar/alert-notification.svg',
                    width: 12 * sizeMultiplier,
                    height: 12 * sizeMultiplier,
                  ))
          ]));
    }

    return BottomNavigationBarItem(
      icon: icon(svgPicture: svgPicture),
      activeIcon: icon(svgPicture: svgPicture, active: true),
      title: Text(FlutterI18n.translate(context, titlei18n)),
    );
  }

  @override
  Widget build(BuildContext context) {
    MenuNotificationProvider menuNotificationProvider =
        Provider.of<MenuNotificationProvider>(context);
    BottomNavigationBarProvider navigationBarProvider =
        Provider.of<BottomNavigationBarProvider>(context);
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    // Check if menu notification has to be active

    if (!isHomeReady ||
        !Provider.of<SettingsManager>(context).isReady ||
        !Provider.of<UserRegionsManager>(context).isReady ||
        !Provider.of<ContentManagerProvider>(context).isReady ||
        !Provider.of<RecommendationsProvider>(context).isReady ||
        !Provider.of<PollsProvider>(context).isReady) {
      return Container(
          alignment: Alignment.center,
          color: Constants.darkBlue,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
              child: Lottie.asset('assets/animations/COVI-loading-V02.json',
                  width: 200 * sizeMultiplier)));
    }

    final _channel = const MethodChannel('com.covi.app/app_retain');
    MenuNotificationProvider.checkAll(shouldNotify: false);
    return WillPopScope(
        onWillPop: () async {
          if (navigationBarProvider.currentIndex == 0) {
            // keep app running if user click back button
            if (Platform.isAndroid) {
              if (Navigator.of(context).canPop()) {
                return true;
              } else {
                _channel.invokeMethod('sendToBackground');
                return false;
              }
            } else {
              return true;
            }
          } else {
            navigationBarProvider.goToScreen(HomeScreens.dashboard);
            return false;
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _widgetOptions[navigationBarProvider.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            elevation: 40.0,
            backgroundColor: Colors.white,
            selectedItemColor: Constants.mediumBlue,
            unselectedItemColor: Constants.darkGrey,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle:
                TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            items: <BottomNavigationBarItem>[
              _buildNavigationBarItem(
                  'assets/svg/navbar/home.svg', 'bottomNavigation.home'),
              _buildNavigationBarItem(
                  'assets/svg/navbar/health.svg', 'bottomNavigation.health',
                  isNotificationDotVisible:
                      menuNotificationProvider.notifications['health']['dot'],
                  isAlertNotification:
                      menuNotificationProvider.notifications['health']['911']),
              _buildNavigationBarItem(
                  'assets/svg/navbar/advices.svg', 'bottomNavigation.advices',
                  notificationPositionX: 5,
                  isNotificationDotVisible:
                      menuNotificationProvider.notifications['tips']['dot'],
                  isAlertNotification:
                      menuNotificationProvider.notifications['tips']['911']),
              _buildNavigationBarItem('assets/svg/navbar/resources.svg',
                  'bottomNavigation.resources'),
            ],
            currentIndex: navigationBarProvider.currentIndex,
            onTap: (index) {
              MenuNotificationProvider.checkAll();
              navigationBarProvider.currentIndex = index;
            },
          ),
        ));
  }
}
