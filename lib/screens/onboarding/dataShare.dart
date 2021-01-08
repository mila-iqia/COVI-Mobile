import 'dart:async';

import 'package:covi/material/customButton.dart';
import 'package:covi/material/externalLink.dart';
import 'package:covi/material/switchWithLabel.dart';
import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DataShare extends StatefulWidget {
  const DataShare({
    this.validityHandler,
  });

  final Function validityHandler;
  _DataShareState createState() => _DataShareState();
}

class _DataShareState extends State<DataShare> {
  bool anonymousMILADataShare = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSettings();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadSettings() async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    await settingsManager.loadSettings();

    setState(() {
      anonymousMILADataShare = settingsManager.settings.anonymousMILADataShare;
    });
  }

  void _launchURL() async {
    String url = FlutterI18n.translate(context, "privacyPolicyURL");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url})';
    }
  }

  Future<void> _ackAlert(BuildContext superContext) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return showGeneralDialog(
      context: superContext,
      barrierColor: Colors.black12.withOpacity(0.6), // background color
      barrierDismissible:
          false, // should dialog be dismissed when tapped outside
      barrierLabel: FlutterI18n.translate(context,
          "onboarding.dataShare.modal.barrierLabel"), // label for barrier
      transitionDuration: Duration(
          milliseconds:
              400), // how long it takes to popup dialog after button click
      pageBuilder: (context, __, ___) {
        // your widget implementati
        var headerStyle = Constants.CustomTextStyle.darkBlue18Text(context);
        var textStyle = TextStyle(fontSize: 14 * sizeMultiplier, height: 1.2);
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                    child: SizedBox.expand(
                  // makes widget fullscreen
                  child: Stack(
                    children: <Widget>[
                      ListView(
                        padding: EdgeInsets.only(left: 24, right: 24, top: 16),
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(
                                  top: 16 * sizeMultiplier,
                                  bottom: 8 * sizeMultiplier),
                              child: ExcludeSemantics(
                                  child: SvgPicture.asset(
                                "assets/svg/info-circle.svg",
                                height: 30 * sizeMultiplier,
                                width: 30 * sizeMultiplier,
                              ))),
                          Semantics(
                              label: FlutterI18n.translate(
                                  context, "a11y.header1"),
                              header: true,
                              child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8 * sizeMultiplier),
                                  child: Text(
                                      FlutterI18n.translate(context,
                                          "onboarding.dataShare.modal.dialogTitle"),
                                      style: headerStyle,
                                      textAlign: TextAlign.center))),
                          Container(
                              margin: EdgeInsets.only(
                                  top: 24 * sizeMultiplier,
                                  bottom: 8 * sizeMultiplier),
                              alignment: Alignment.centerLeft,
                              child: Semantics(
                                  label: FlutterI18n.translate(
                                      context, "a11y.header2"),
                                  header: true,
                                  child: Text(
                                      FlutterI18n.translate(context,
                                          "onboarding.dataShare.modal.nonIdentifyingTitle"),
                                      style: headerStyle,
                                      textAlign: TextAlign.left))),
                          Text(
                              FlutterI18n.translate(context,
                                  "onboarding.dataShare.modal.nonIdentifyingContent"),
                              style: textStyle,
                              textAlign: TextAlign.left),
                          Container(
                              margin: EdgeInsets.only(
                                  top: 24 * sizeMultiplier,
                                  bottom: 8 * sizeMultiplier),
                              alignment: Alignment.centerLeft,
                              child: Semantics(
                                  label: FlutterI18n.translate(
                                      context, "a11y.header2"),
                                  header: true,
                                  child: Text(
                                      FlutterI18n.translate(context,
                                          "onboarding.dataShare.modal.aggregateDataTitle"),
                                      style: headerStyle,
                                      textAlign: TextAlign.left))),
                          Text(
                              FlutterI18n.translate(context,
                                  "onboarding.dataShare.modal.aggregateDataContent"),
                              style: textStyle,
                              textAlign: TextAlign.left),
                          Container(
                              padding: EdgeInsets.all(24 * sizeMultiplier),
                              child: ExternalLink(
                                label: FlutterI18n.translate(context,
                                    "onboarding.dataShare.modal.moreInformation"),
                                onTap: () {
                                  _launchURL();
                                },
                              ))
                        ],
                      ),
                      Positioned(
                          top: 16,
                          left: 16,
                          child: CustomButton(
                              width: 48,
                              height: 48,
                              borderRadius: 16,
                              padding: EdgeInsets.all(12),
                              shadowColor: Colors.black12,
                              splashColor: Colors.black12,
                              icon: SvgPicture.asset('assets/svg/x.svg',
                                  width: 30, height: 30),
                              iconLabel: FlutterI18n.translate(context,
                                  "onboarding.dataShare.modal.closeModal"),
                              backgroundColor: Colors.white,
                              onPressed: () {
                                Navigator.of(context).pop();
                              })),
                    ],
                  ),
                )));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    Future<void> _switchAnonymousData(bool newValue) async {
      SettingsManager settingsManager =
          Provider.of<SettingsManager>(context, listen: false);

      settingsManager.settings.anonymousMILADataShare = newValue;

      await settingsManager.saveSettings();

      setState(() {
        anonymousMILADataShare = newValue;
      });
    }

    return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Semantics(
                      focusable: true,
                      child: Text(
                          FlutterI18n.translate(
                              context, "onboarding.dataShare.title"),
                          style: TextStyle(
                            fontSize: 14 * sizeMultiplier,
                            color: Constants.darkBlue,
                            fontWeight: FontWeight.bold,
                          ))),
                  Material(
                      color: Colors.transparent,
                      child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          splashColor: Colors.white.withAlpha(30),
                          onTap: () {
                            _ackAlert(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(16 * sizeMultiplier),
                            height: 48 * sizeMultiplier,
                            width: 48 * sizeMultiplier,
                            child: ExcludeSemantics(
                                child: SvgPicture.asset(
                                    'assets/svg/info-circle.svg',
                                    color: Constants.darkBlue)),
                          )))
                ],
              ),
            ),
            Container(
                child: Semantics(
                    focusable: true,
                    child: Text(
                        FlutterI18n.translate(
                            context, "onboarding.dataShare.subtitle"),
                        style: Constants.CustomTextStyle.grey14Text(context)))),
            Container(
                margin: EdgeInsets.symmetric(vertical: 16 * sizeMultiplier),
                decoration: new BoxDecoration(
                  color: Constants.lightGrey,
                  borderRadius: new BorderRadius.all(
                    new Radius.circular(15.0),
                  ),
                ),
                child: SwitchWithLabel(
                    title: FlutterI18n.translate(
                        context, "onboarding.dataShare.switchLabel"),
                    subtitle: FlutterI18n.translate(
                        context, "onboarding.dataShare.switchSubtitle"),
                    value: anonymousMILADataShare,
                    activeText:
                        FlutterI18n.translate(context, "yes").toUpperCase(),
                    inactiveText:
                        FlutterI18n.translate(context, "no").toUpperCase(),
                    onChanged: (bool newValue) {
                      _switchAnonymousData(newValue);
                    })),
            Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Semantics(
                      focusable: true,
                      child: Text(
                          FlutterI18n.translate(context,
                              "onboarding.dataShare.deleteWhenYouWant"),
                          style: Constants.CustomTextStyle.grey14Text(context)
                              .merge(TextStyle(
                                  fontSize: 12 * sizeMultiplier,
                                  fontStyle: FontStyle.italic)))),
                ]))
          ],
        ));
  }
}
