import 'dart:async';

import 'package:covi/material/customBackButton.dart';
import 'package:covi/material/customButton.dart';
import 'package:covi/material/Dropdown.dart';
import 'package:covi/material/externalLink.dart';
import 'package:covi/material/saveCancelButtons.dart';
import 'package:covi/material/ExpandedSection.dart';
import 'package:covi/material/switchWithLabel.dart';
import 'package:covi/material/toggleWithLabel.dart';
import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AgeConsent extends StatefulWidget {
  const AgeConsent({
    this.validityHandler,
  });

  final Function validityHandler;
  _AgeConsentState createState() => _AgeConsentState();
}

class _AgeConsentState extends State<AgeConsent> {
  bool anonymousMILADataShare = false;
  bool hasTurned19;
  String genderValue = null;
  FocusNode genderFocusNode;
  String householdValue = null;
  FocusNode householdFocusNode;
  bool fromTurned19Button = false;

  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  @override
  void initState() {
    super.initState();

    genderFocusNode = FocusNode();
    householdFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSettings();
    });
  }

  @override
  void dispose() {
    genderFocusNode.dispose();

    super.dispose();
  }

  void loadSettings() async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    await settingsManager.loadSettings();

    if (settingsManager.settings.user_data.gender == null &&
        settingsManager.settings.user_data.household == null) {
      fromTurned19Button = true;
    }

    setState(() {
      anonymousMILADataShare = settingsManager.settings.anonymousMILADataShare;
      genderValue = settingsManager.settings.user_data.gender;
      householdValue = settingsManager.settings.user_data.household;
    });
  }

  void _saveSettings() async {
    // Access to our settings manager
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    if (_formKey.currentState.validate() && _isFormValid()) {
      if (hasTurned19) {
        settingsManager.settings.user_data.age = 19;
        settingsManager.settings.user_data.gender = genderValue;
        settingsManager.settings.user_data.household = householdValue;
      }

      settingsManager.settings.anonymousMILADataShare = anonymousMILADataShare;

      // // Save the settings
      await settingsManager.saveSettings();

      // Go back to the home screen
      Navigator.of(context).pop();
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
  }

  bool _isFormValid() {
    if (hasTurned19 == null) {
      return false;
    }

    // if (hasTurned19 != null && hasTurned19) {
    //   if (genderValue == null) {
    //     return false;
    //   }
    //   if (householdValue == null) {
    //     return false;
    //   }
    // }

    return true;
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

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          Container(
              alignment: Alignment.topLeft,
              child: ExcludeSemantics(
                  child: SvgPicture.asset('assets/svg/backdrops/consent.svg',
                      height: 90 * sizeMultiplier))),
          SafeArea(
              child: Column(children: <Widget>[
            Row(children: <Widget>[
              Container(
                height:
                    (90 * sizeMultiplier) - MediaQuery.of(context).padding.top,
                padding: EdgeInsets.only(
                    top: 4 * sizeMultiplier, bottom: 8 * sizeMultiplier),
                child: CustomBackButton(
                  label: FlutterI18n.translate(context, "back"),
                  a11yLabel: FlutterI18n.translate(context, "goBackTo") +
                      FlutterI18n.translate(context, "screens.profile"),
                  shadowColor: Colors.black54,
                  backgroundColor: Constants.darkBlue,
                  textColor: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            ]),
            Expanded(
                child: Form(
                    autovalidate: _autovalidate,
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                      Container(
                          padding:
                              EdgeInsets.only(top: 40, left: 16, right: 16),
                          child: Column(children: <Widget>[
                            Semantics(
                                label: FlutterI18n.translate(
                                    context, "a11y.header2"),
                                header: true,
                                child: Text(
                                  FlutterI18n.translate(
                                      context, "ageConsent.ageConsentTitle"),
                                  style: TextStyle(
                                      fontSize: 18 * sizeMultiplier,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.darkBlue),
                                )),
                            Divider(height: 40),
                            ToggleWithLabel(
                              label: FlutterI18n.translate(
                                  context, "ageConsent.turned19Recently"),
                              isMoreQuestionsOption: true,
                              autovalidate: _autovalidate,
                              onPress: (bool value) {
                                setState(() {
                                  hasTurned19 = value;
                                });
                              },
                              status: hasTurned19,
                            ),
                            Divider(height: 40),
                          ])),
                      ExpandedSection(
                          expand: hasTurned19 != null ? hasTurned19 : false,
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  fromTurned19Button
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              top: 8, bottom: 16),
                                          child: Dropdown(
                                            value: genderValue,
                                            onChanged: (String newValue) {
                                              setState(() {
                                                genderValue = newValue;
                                              });
                                            },
                                            focusNode: genderFocusNode,
                                            validator: (value) {
                                              // if (value == null) {
                                              //   genderFocusNode.requestFocus();
                                              //   return FlutterI18n.translate(context,
                                              //       "onboarding.userForm.genderFieldIncomplete");
                                              // }
                                              return null;
                                            },
                                            items: <DropdownItem>[
                                              DropdownItem(
                                                  FlutterI18n.translate(context,
                                                      "onboarding.userForm.man"),
                                                  'man'),
                                              DropdownItem(
                                                  FlutterI18n.translate(context,
                                                      "onboarding.userForm.woman"),
                                                  'woman'),
                                              DropdownItem(
                                                  FlutterI18n.translate(context,
                                                      "onboarding.userForm.other"),
                                                  'other')
                                            ],
                                            label: FlutterI18n.translate(
                                                context,
                                                "onboarding.userForm.genderField"),
                                          ))
                                      : Container(),
                                  fromTurned19Button
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              top: 20, bottom: 16),
                                          child: Dropdown(
                                            value: householdValue,
                                            onChanged: (String newValue) {
                                              setState(() {
                                                householdValue = newValue;
                                              });
                                            },
                                            focusNode: householdFocusNode,
                                            validator: (value) {
                                              // if (value == null) {
                                              //   householdFocusNode.requestFocus();
                                              //   return FlutterI18n.translate(context,
                                              //       "onboarding.userForm.householdFieldIncomplete");
                                              // }
                                              return null;
                                            },
                                            items: <DropdownItem>[
                                              DropdownItem("1", "1"),
                                              DropdownItem("2", "2"),
                                              DropdownItem("3", "3"),
                                              DropdownItem("4+", "4+"),
                                            ],
                                            label: FlutterI18n.translate(
                                                context,
                                                "onboarding.userForm.householdField"),
                                          ))
                                      : Container(),
                                  Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      child: Text(
                                          FlutterI18n.translate(context,
                                              "onboarding.dataShare.title"),
                                          style: TextStyle(
                                            fontSize: 14 * sizeMultiplier,
                                            color: Constants.darkBlue,
                                            fontWeight: FontWeight.bold,
                                          ))),
                                  Container(
                                      child: Text(
                                          FlutterI18n.translate(context,
                                              "onboarding.dataShare.subtitle"),
                                          style: Constants.CustomTextStyle
                                              .grey14Text(context))),
                                  Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 16 * sizeMultiplier),
                                      decoration: new BoxDecoration(
                                        color: Constants.lightGrey,
                                        borderRadius: new BorderRadius.all(
                                          new Radius.circular(15.0),
                                        ),
                                      ),
                                      child: SwitchWithLabel(
                                          title: FlutterI18n.translate(context,
                                              "onboarding.dataShare.switchLabel"),
                                          subtitle: FlutterI18n.translate(
                                              context,
                                              "onboarding.dataShare.switchSubtitle"),
                                          value: anonymousMILADataShare,
                                          activeText: FlutterI18n.translate(
                                                  context, "yes")
                                              .toUpperCase(),
                                          inactiveText: FlutterI18n.translate(
                                                  context, "no")
                                              .toUpperCase(),
                                          onChanged: (bool newValue) {
                                            setState(() {
                                              anonymousMILADataShare = newValue;
                                            });
                                          })),
                                  Container(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                        Text(
                                            FlutterI18n.translate(context,
                                                "onboarding.dataShare.privacySpeech"),
                                            style: Constants.CustomTextStyle
                                                .grey14Text(context)),
                                        Semantics(
                                            button: true,
                                            child: InkResponse(
                                              child: Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  constraints: BoxConstraints(
                                                      minHeight: 48),
                                                  child: Text(
                                                      FlutterI18n.translate(
                                                          context,
                                                          "onboarding.dataShare.privacyButton"),
                                                      style: TextStyle(
                                                          color: Constants
                                                              .mediumBlue,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14 *
                                                              sizeMultiplier,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline))),
                                              onTap: () => {_ackAlert(context)},
                                            ))
                                      ]))
                                ],
                              ))),
                    ])))),
            SaveCancelButtons(
                isValidToSave: _isFormValid(),
                onPressedSave: () => _saveSettings(),
                onPressedCancel: () {
                  Navigator.of(context).pop();
                })
          ])),
          Container(
              color: Constants.darkBlue70,
              height: MediaQuery.of(context).padding.top)
        ]));
  }
}
