import 'dart:ui';
import 'package:covi/material/genericTitleLayout.dart';
import 'package:covi/material/profileScreenArguments.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/providers/actionCardsList.dart';
import 'package:covi/utils/providers/menuNotificationProvider.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:covi/utils/settings.dart';
import 'package:covi/material/actionCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class HealthScreen extends StatefulWidget {
  HealthScreen({key}) : super(key: key);

  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
    with RouteAware, RouteObserverMixin {
  MainRecommendation recommendation;
  DateTime recommendationUpdate;

  Map<String, dynamic> userRegionsStats = new Map();
  String locale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<MenuNotificationProvider>(context, listen: false)
          .turnNotificationOff(NotificationsName.health, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    SettingsData settings = Provider.of<SettingsManager>(context).settings;
    Map<String, dynamic> actions = Provider.of<ActionsManager>(context).actions;
    List<String> regularActions =
        Provider.of<ActionsManager>(context, listen: false)
            .getActionsFromUserData(settings, ActionType.regular);
    List<String> alertActions =
        Provider.of<ActionsManager>(context, listen: false)
            .getActionsFromUserData(settings, ActionType.alert);
    return GenericTitleLayout(
        title: FlutterI18n.translate(context, "myHealth.title"),
        backdropChoice: Backdrops.wave,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var actionId in alertActions)
                ActionCard(
                  title: FlutterI18n.translate(
                      context, "actions.actionCards.${actionId}.category"),
                  onTap: () {
                    if (actionId == "AC003" || actionId == "AC004") {
                      Navigator.of(context).pushNamed(actions[actionId].url,
                          arguments: ProfileScreenArguments(1, 'health'));
                    } else if (actionId == "AC008") {
                      Navigator.of(context).pushNamed(actions[actionId].url,
                          arguments: ProfileScreenArguments(0, 'health'));
                    } else {
                      Navigator.of(context).pushNamed(actions[actionId].url,
                          arguments: 'health');
                    }
                  },
                  circleColor: ActionCardColor.red,
                  content: Text(
                      FlutterI18n.translate(
                          context, "actions.actionCards.${actionId}.title"),
                      style: TextStyle(
                          color: Color(0xFF2d3953),
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * sizeMultiplier),
                      textAlign: TextAlign.left),
                  backgroundColor: Color(0xFFf7f0ea),
                  lastUpdate: actions[actionId].lastUpdate != null
                      ? actions[actionId].lastUpdate
                      : null,
                  icon: SvgPicture.asset('assets/svg/' + actions[actionId].icon,
                      color: Constants.pinkRed),
                  button: SvgPicture.asset('assets/svg/arrow-blue.svg'),
                ),
              alertActions.length != 0 && regularActions.length != 0
                  ? Divider(height: 40)
                  : Container(),
              for (var actionId in regularActions)
                ActionCard(
                  title: FlutterI18n.translate(
                      context, "actions.actionCards.${actionId}.category"),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(actions[actionId].url, arguments: 'health');
                  },
                  circleColor: ActionCardColor.beige,
                  content: Text(
                      FlutterI18n.translate(
                          context, "actions.actionCards.${actionId}.title"),
                      style: TextStyle(
                          color: Color(0xFF2d3953),
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * sizeMultiplier),
                      textAlign: TextAlign.left),
                  backgroundColor: Constants.lightBeige,
                  lastUpdate: actions[actionId].lastUpdate != null
                      ? actions[actionId].lastUpdate
                      : null,
                  icon:
                      SvgPicture.asset('assets/svg/' + actions[actionId].icon),
                  button: SvgPicture.asset('assets/svg/arrow-blue.svg'),
                ),
              Divider(height: 24, color: Colors.transparent),
            ],
          ),
        ));
  }
}
