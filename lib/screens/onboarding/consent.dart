import 'dart:async';

import 'package:covi/material/ccard.dart';
import 'package:covi/material/dataShareModal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:url_launcher/url_launcher.dart';

class Consent extends StatefulWidget {
  const Consent({
    @required this.validityHandler,
  }) : assert(validityHandler != null);

  final Function validityHandler;

  _ConsentState createState() => _ConsentState();
}

class _ConsentState extends State<Consent> {
  bool shareAnonymousData = true;
  bool sharePopupLevelData = true;
  FocusNode moreInfoButton = FocusNode();
  TapGestureRecognizer _termsConditionRecognizer;

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
    _termsConditionRecognizer.dispose();
    moreInfoButton.dispose();
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

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    Timer.run(() => widget.validityHandler(true));
    return Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Semantics(
                header: true,
                label: FlutterI18n.translate(context, "a11y.header2"),
                child: Text(
                    FlutterI18n.translate(
                        context, "onboarding.consent.header2"),
                    style: TextStyle(fontSize: 1, color: Colors.transparent))),
            Container(
                margin: EdgeInsets.fromLTRB(14 * sizeMultiplier, 0,
                    14 * sizeMultiplier, 16 * sizeMultiplier),
                child: Column(children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Text(
                          FlutterI18n.translate(
                              context, "onboarding.consent.title"),
                          textAlign: TextAlign.center,
                          style:
                              Constants.CustomTextStyle.grey14Text(context))),
                  RichText(
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Constants.CustomTextStyle.grey14Text(context),
                      text: FlutterI18n.translate(context,
                          "onboarding.consent.termsAndConditionsPreface"),
                      children: [
                        TextSpan(
                          semanticsLabel: FlutterI18n.translate(context,
                                  "onboarding.consent.termsAndConditions") +
                              FlutterI18n.translate(
                                  context, "a11y.externalLink"),
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                          text: FlutterI18n.translate(
                              context, "onboarding.consent.termsAndConditions"),
                          recognizer: _termsConditionRecognizer,
                        ),
                        TextSpan(
                            text: FlutterI18n.translate(
                                context, "onboarding.consent.asWellAs"))
                      ],
                    ),
                  ),
                ])),
            Container(
                child: CCard(
              color: CCardColor.red,
              icon: SvgPicture.asset('assets/svg/icon-bluetooth.svg'),
              title: FlutterI18n.translate(
                  context, "onboarding.consent.bluetoothCardTitle"),
              subtitle: FlutterI18n.translate(
                  context, "onboarding.consent.bluetoothCardText"),
            )),
            Container(
                child: CCard(
              focusNode: moreInfoButton,
              color: CCardColor.red,
              icon: SvgPicture.asset('assets/svg/icon-share.svg'),
              title: FlutterI18n.translate(
                  context, "onboarding.consent.anonymousCardTitle"),
              subtitle: FlutterI18n.translate(
                  context, "onboarding.consent.anonymousCardText"),
              onTap: () {
                _ackAlert(context);
              },
            )),
            Container(
                child: CCard(
              color: CCardColor.red,
              iconPadding: 4,
              icon: SvgPicture.asset('assets/svg/icon-notifications.svg'),
              title: FlutterI18n.translate(
                  context, "onboarding.consent.pushNotificationCardTitle"),
              subtitle: FlutterI18n.translate(
                  context, "onboarding.consent.pushNotificationCardText"),
            )),
            // Container(
            //   margin: EdgeInsets.only(top: 16 * sizeMultiplier),
            //   padding: EdgeInsets.symmetric(horizontal: 16 * sizeMultiplier),
            //   child: RichText(
            //     textScaleFactor: MediaQuery.of(context).textScaleFactor,
            //     textAlign: TextAlign.center,
            //     text: TextSpan(
            //       style: TextStyle(
            //           color: Color(0xFF62696a),
            //           fontSize: 14 * sizeMultiplier,
            //           fontWeight: FontWeight.normal),
            //       text: FlutterI18n.translate(
            //           context, "onboarding.consent.termsAndConditionsPreface"),
            //       children: [
            //         TextSpan(
            //           style: TextStyle(decoration: TextDecoration.underline),
            //           text: FlutterI18n.translate(
            //               context, "onboarding.consent.termsAndConditions"),
            //           recognizer: _termsConditionRecognizer,
            //         ),
            //       ],
            //     ),
            //   ),
            // )
          ],
        ));
  }
}
