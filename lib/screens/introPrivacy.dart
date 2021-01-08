import 'dart:io';

import 'package:covi/utils/permissions.dart';

import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:logger/logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/material/customButton.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:covi/material/dataShareModal.dart';
import 'package:lottie/lottie.dart';

class IntroPrivacyScreen extends StatefulWidget {
  IntroPrivacyScreen({key}) : super(key: key);

  _IntroPrivacyScreenState createState() => _IntroPrivacyScreenState();
}

class _IntroPrivacyScreenState extends State<IntroPrivacyScreen> {
  var logger = Logger();
  TapGestureRecognizer _termsConditionRecognizer;
  FocusNode moreInfoButton = FocusNode();

  @override
  void initState() {
    super.initState();
    _termsConditionRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _launchURL(FlutterI18n.translate(context, "termsAndConditionsURL"));
      };
  }

  @override
  void dispose() {
    moreInfoButton.dispose();
    _termsConditionRecognizer.dispose();
    super.dispose();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url})';
    }
  }

  Future<void> _ackAlert(BuildContext superContext) {
    return showGeneralDialog(
      context: superContext,
      barrierColor: Colors.black12.withOpacity(0.6), // background color
      barrierDismissible:
          false, // should dialog be dismissed when tapped outside
      barrierLabel: FlutterI18n.translate(
          context, "onboarding.consent.barrierLabel"), // label for barrier
      transitionDuration: Duration(
          milliseconds:
              400), // how long it takes to popup dialog after button click
      pageBuilder: (context, __, ___) {
        // your widget implementati

        return StatefulBuilder(
          builder: (context, setState) {
            return DataShareModal(
                type: ShareModalType.intro,
                closeCallback: () {
                  Navigator.of(context).pop();
                  moreInfoButton.requestFocus();
                });
          },
        );
      },
    );
  }

  void _agreeHandler() async {
    await Provider.of<SettingsManager>(context, listen: false).clearSettings();
    await Provider.of<SettingsManager>(context, listen: false)
        .setSetupCompleted(true);

    /**
     * Since Android 6.0 applications using BLE scanning must have location permission enabled,
     * to this day (Android 10) Google still have not changed their mindd on this issue. 
     * 
     * Question on stack overflow on the subject
     * https://stackoverflow.com/questions/33045581/location-needs-to-be-enabled-for-bluetooth-low-energy-scanning-on-android-6-0
     * 
     * Google issue
     * https://issuetracker.google.com/issues/37065090
     */
    if (Platform.isAndroid) {
      await PermissionsManager.requestPermissions();
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          color: Constants.darkBlue,
          child: SingleChildScrollView(
              child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15),
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Semantics(
                          header: true,
                          label: FlutterI18n.translate(context, "a11y.header1"),
                          child: Text("Introduction",
                              style: TextStyle(
                                  fontSize: 1, color: Colors.transparent))),
                      SizedBox(
                          width: 290 * sizeMultiplier,
                          child: Column(
                            children: <Widget>[
                              Text(
                                FlutterI18n.translate(
                                    context, "introPrivacy.title"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 1.2,
                                    color: Constants.beige,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20 * sizeMultiplier),
                              ),
                              Divider(
                                  color: Constants.transparent,
                                  height: 8 * sizeMultiplier),
                              Text(
                                FlutterI18n.translate(
                                    context, "introPrivacy.text"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 1.2,
                                    color: Constants.beige,
                                    fontSize: 16 * sizeMultiplier),
                              )
                            ],
                          )),
                      ClipRect(
                          child: Align(
                              alignment: Alignment(0, 0.271),
                              heightFactor: 0.35,
                              child: ExcludeSemantics(
                                  child: Lottie.asset(
                                      'assets/animations/COVI-P1-Tutoriel-D.json',
                                      repeat: false)))),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32 * sizeMultiplier),
                          child: RichText(
                            textScaleFactor:
                                MediaQuery.of(context).textScaleFactor,
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: 12 * sizeMultiplier,
                                  color: Colors.white),
                              text: FlutterI18n.translate(
                                  context, "introPrivacy.touAndPP"),
                              children: [
                                TextSpan(
                                  semanticsLabel: FlutterI18n.translate(context,
                                          "introPrivacy.touAndPPLink") +
                                      FlutterI18n.translate(
                                          context, "a11y.externalLink"),
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                  text: FlutterI18n.translate(
                                      context, "introPrivacy.touAndPPLink"),
                                  recognizer: _termsConditionRecognizer,
                                ),
                                WidgetSpan(
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            focusNode: moreInfoButton,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100)),
                                            splashColor:
                                                Colors.white.withAlpha(30),
                                            onTap: () {
                                              _ackAlert(context);
                                            },
                                            child: Container(
                                              // padding: EdgeInsets.all(18 * sizeMultiplier),
                                              // height: 48 * sizeMultiplier,
                                              // width: 48 * sizeMultiplier,
                                              margin: EdgeInsets.only(
                                                  left: 8 * sizeMultiplier),
                                              height: 12 * sizeMultiplier,
                                              width: 12 * sizeMultiplier,
                                              child: ExcludeSemantics(
                                                  child: SvgPicture.asset(
                                                      'assets/svg/info-circle.svg',
                                                      color: Colors.white)),
                                            ))))
                              ],
                            ),
                          )),
                      Container(
                          margin: EdgeInsets.only(bottom: 16 * sizeMultiplier),
                          child: Center(
                              child: CustomButton(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24 * sizeMultiplier),
                                  label: FlutterI18n.translate(
                                      context, "introPrivacy.agree"),
                                  minWidth: 200 * sizeMultiplier,
                                  backgroundColor: Constants.yellow,
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  textColor: Constants.darkBlue,
                                  onPressed: _agreeHandler))),
                    ]),
              ),
              Positioned(
                  top: (24 * sizeMultiplier) +
                      MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: Container(
                      margin: EdgeInsets.only(bottom: 18 * sizeMultiplier),
                      child: Semantics(
                          label: "Covi",
                          child: SvgPicture.asset("assets/svg/logo-covi.svg",
                              width: 78 * sizeMultiplier,
                              height: 32 * sizeMultiplier))))
            ],
          ))),
      Container(
          color: Constants.darkBlue70,
          height: MediaQuery.of(context).padding.top)
    ]));
  }
}
