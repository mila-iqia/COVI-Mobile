import 'dart:async';
import 'package:covi/screens/onboarding/dataShare.dart';
import 'package:covi/material/ageField.dart';
import 'package:covi/material/Dropdown.dart';
import 'package:covi/material/ExpandedSection.dart';
import 'package:covi/material/saveButton.dart';
import 'package:covi/material/toggleWithLabel.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/notifications.dart';
import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class UserForm extends StatefulWidget {
  const UserForm({
    @required this.continueHandler,
    @required this.ageFocusNode,
  }) : assert(continueHandler != null);

  final Function continueHandler;
  final FocusNode ageFocusNode;

  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  String genderValue = null;
  String householdValue = null;

  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  Map<String, bool> choices = {
    'hasChronicHealthCondition': null,
    'isSmoker': null,
    'hasDiabetes': null,
    'isImmunosuppressed': null,
    'hasCancer': null,
    'hasHeartDisease': null,
    'hasHypertension': null,
    'hasChronicLungCondition': null,
    'hadStroke': null,
    'hasSymptoms': null,
    'closeToInfected': null,
    'hasTraveledOutsideCanada': null,
    'hasCloseContactToOutsideTraveler': null,
    'isHealthcareWorker': null,
    'workWithInfected': null,
  };

  bool consentForTeen = false;
  String age = "";
  TextEditingController ageInputController;

  FocusNode genderFocusNode;
  FocusNode householdFocusNode;
  Timer ageTimer;

  @override
  void dispose() {
    ageInputController.dispose();
    genderFocusNode.dispose();
    householdFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    ageInputController = new TextEditingController();
    genderFocusNode = FocusNode();
    householdFocusNode = FocusNode();
    _loadData();
  }

  void startWeeklyNotification() {
    Logger().d("Start weekly notification for self-assessment");

    String title = FlutterI18n.translate(
        context, "actions.selfDiagnostic.notification.situation.title");
    String body = FlutterI18n.translate(
        context, "actions.selfDiagnostic.notification.situation.body");

    Notifications.createNotification(title, body, "",
        interval: RepeatInterval.Weekly,
        notificationID: Constants.notificationSelfScreenId);
  }

  void _handleAgeChange(value) {
    setState(() {
      age = "";
    });
    if (ageTimer != null) ageTimer.cancel();
    ageTimer = new Timer(const Duration(seconds: 1), () {
      setState(() {
        age = value;
      });
    });
  }

  void _handleChoicesChange(String name, bool value) {
    setState(() {
      choices[name] = value;
    });
  }

  void _handleConsentForTeenChange(value) {
    setState(() {
      consentForTeen = value;
    });
  }

  void _loadData() async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);
    await settingsManager.loadSettings();
    String ageFromData = settingsManager.settings.user_data.age != null
        ? settingsManager.settings.user_data.age.toString()
        : "";
    ageInputController.text = ageFromData;

    setState(() {
      age = ageFromData;
      genderValue = settingsManager.settings.user_data.gender;
      householdValue = settingsManager.settings.user_data.household;
      choices = {
        'hasChronicHealthCondition':
            settingsManager.settings.user_data.hasChronicHealthCondition,
        'isSmoker': settingsManager.settings.user_data.isSmoker,
        'hasDiabetes': settingsManager.settings.user_data.hasDiabetes,
        'isImmunosuppressed':
            settingsManager.settings.user_data.isImmunosuppressed,
        'hasCancer': settingsManager.settings.user_data.hasCancer,
        'hasHeartDisease': settingsManager.settings.user_data.hasHeartDisease,
        'hasHypertension': settingsManager.settings.user_data.hasHypertension,
        'hasChronicLungCondition':
            settingsManager.settings.user_data.hasChronicLungCondition,
        'hadStroke': settingsManager.settings.user_data.hadStroke,
        'hasSymptoms': settingsManager.settings.user_data.hasSymptoms,
        'closeToInfected': settingsManager.settings.user_data.closeToInfected,
        'hasTraveledOutsideCanada':
            settingsManager.settings.user_data.hasTraveledOutsideCanada,
        'hasCloseContactToOutsideTraveler':
            settingsManager.settings.user_data.hasCloseContactToOutsideTraveler,
        'isHealthcareWorker':
            settingsManager.settings.user_data.isHealthcareWorker,
        'workWithInfected': settingsManager.settings.user_data.workWithInfected,
      };
      consentForTeen = settingsManager.settings.user_data.consentForTeen;
    });
  }

  void _validateForm() async {
    // Access to our settings manager
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    // Validate the form
    if (_formKey.currentState.validate() && _isFormReady()) {
      // User's age
      int age = int.parse(ageInputController.text);

      settingsManager.settings.user_data.onboardingDate = new DateTime.now();
      settingsManager.settings.user_data.age = age;
      settingsManager.settings.user_data.gender = genderValue;
      settingsManager.settings.user_data.household = householdValue;
      if (age < 19) {
        settingsManager.settings.user_data.consentForTeen = consentForTeen;
        settingsManager.settings.user_data.hasChronicHealthCondition = false;
        settingsManager.settings.user_data.isSmoker = false;
        settingsManager.settings.user_data.hasDiabetes = false;
        settingsManager.settings.user_data.isImmunosuppressed = false;
        settingsManager.settings.user_data.hasCancer = false;
        settingsManager.settings.user_data.hasHeartDisease = false;
        settingsManager.settings.user_data.hasHypertension = false;
        settingsManager.settings.user_data.hasChronicLungCondition = false;
        settingsManager.settings.user_data.hadStroke = false;
        settingsManager.settings.user_data.hasSymptoms = false;
        settingsManager.settings.user_data.closeToInfected = false;
        settingsManager.settings.user_data.hasTraveledOutsideCanada = false;
        settingsManager.settings.user_data.hasCloseContactToOutsideTraveler =
            false;
        settingsManager.settings.user_data.isHealthcareWorker = false;
        settingsManager.settings.user_data.workWithInfected = false;
      } else {
        settingsManager.settings.user_data.healthCheckUpdateDate =
            new DateTime.now();
        settingsManager.settings.user_data.hasChronicHealthCondition =
            choices['hasChronicHealthCondition'];
        settingsManager.settings.user_data.isSmoker = choices['isSmoker'];
        settingsManager.settings.user_data.hasDiabetes = choices['hasDiabetes'];
        settingsManager.settings.user_data.isImmunosuppressed =
            choices['isImmunosuppressed'];
        settingsManager.settings.user_data.hasCancer = choices['hasCancer'];
        settingsManager.settings.user_data.hasHeartDisease =
            choices['hasHeartDisease'];
        settingsManager.settings.user_data.hasHypertension =
            choices['hasHypertension'];
        settingsManager.settings.user_data.hasChronicLungCondition =
            choices['hasChronicLungCondition'];
        settingsManager.settings.user_data.hadStroke = choices['hadStroke'];
        settingsManager.settings.user_data.hasSymptoms = choices['hasSymptoms'];
        settingsManager.settings.user_data.closeToInfected =
            choices['closeToInfected'];
        settingsManager.settings.user_data.hasTraveledOutsideCanada =
            choices['hasTraveledOutsideCanada'];
        settingsManager.settings.user_data.hasCloseContactToOutsideTraveler =
            choices['hasCloseContactToOutsideTraveler'];
        settingsManager.settings.user_data.isHealthcareWorker =
            choices['isHealthcareWorker'];
        settingsManager.settings.user_data.workWithInfected =
            choices['workWithInfected'];
      }

      // Assign it to our SettingsData
      //settingsManager.settings.user_data = user;

      // Save the settings
      await settingsManager.saveSettings();

      // Set the setup as completed
      await settingsManager.setSetupCompleted(true);

      // cancel setup not done notification
      // await Notifications.cancelNotification(Constants.notificationSetupNotDoneId);

      // Add notification for weekly self-assessment update
      startWeeklyNotification();

      widget.continueHandler();
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
  }

  bool _isFormReady() {
    if (age.isEmpty) {
      return false;
    }

    if (!age.isEmpty && int.parse(age) < 13) {
      return false;
    }

    if (!age.isEmpty &&
        int.parse(age) > 12 &&
        int.parse(age) < 16 &&
        !consentForTeen) {
      return false;
    }

    if (!age.isEmpty && int.parse(age) >= 19) {
      if (choices['hasChronicHealthCondition'] == null ||
          choices['hasSymptoms'] == null ||
          choices['closeToInfected'] == null ||
          choices['hasTraveledOutsideCanada'] == null ||
          choices['hasCloseContactToOutsideTraveler'] == null ||
          choices['isHealthcareWorker'] == null) {
        return false;
      }

      if (genderValue == null) {
        return false;
      }

      if (householdValue == null) {
        return false;
      }

      if (choices['hasChronicHealthCondition']) {
        if (choices['isSmoker'] == null ||
            choices['hasDiabetes'] == null ||
            choices['isImmunosuppressed'] == null ||
            choices['hasCancer'] == null ||
            choices['hasHeartDisease'] == null ||
            choices['hasHypertension'] == null ||
            choices['hasChronicLungCondition'] == null ||
            choices['hadStroke'] == null) {
          return false;
        }
      }

      if (choices['isHealthcareWorker'] &&
          choices['workWithInfected'] == null) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Container(
        // To push buttons at the bottom of the screen when there is only age field (100% - header height)
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                (50 * sizeMultiplier + MediaQuery.of(context).padding.top) -
                (72 * sizeMultiplier)),
        child: Form(
            autovalidate: _autovalidate,
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(children: <Widget>[
                      Semantics(
                          header: true,
                          label: FlutterI18n.translate(context, "a11y.header2"),
                          child: Text(
                              FlutterI18n.translate(
                                  context, "onboarding.userForm.header2"),
                              style: TextStyle(
                                  fontSize: 1, color: Colors.transparent))),
                      Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          child: Text(
                              FlutterI18n.translate(
                                  context, "onboarding.userForm.title"),
                              textAlign: TextAlign.center,
                              style: Constants.CustomTextStyle.grey14Text(
                                  context))),
                      Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          child: Text(
                              FlutterI18n.translate(context,
                                  "onboarding.userForm.allFieldsMandatory"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13 * sizeMultiplier,
                                  color: Constants.mediumGrey))),
                      AgeField(
                        age: age,
                        ageFocusNode: widget.ageFocusNode,
                        ageController: ageInputController,
                        consentForTeen: consentForTeen,
                        autovalidate: _autovalidate,
                        onAgeChanged: _handleAgeChange,
                        onConsentTeenChanged: _handleConsentForTeenChange,
                      )
                    ])),
                ExpandedSection(
                    expand: !age.isEmpty && int.parse(age) >= 19,
                    child: Column(children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(top: 20),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: <Widget>[
                              Dropdown(
                                value: genderValue,
                                onChanged: (String newValue) {
                                  setState(() {
                                    genderValue = newValue;
                                  });
                                },
                                focusNode: genderFocusNode,
                                validator: (value) {
                                  if (value == null &&
                                      !age.isEmpty &&
                                      int.parse(age) >= 19) {
                                    genderFocusNode.requestFocus();
                                    return FlutterI18n.translate(context,
                                        "onboarding.userForm.genderFieldIncomplete");
                                  }
                                  return null;
                                },
                                items: <DropdownItem>[
                                  DropdownItem(
                                      FlutterI18n.translate(
                                          context, "onboarding.userForm.man"),
                                      'man'),
                                  DropdownItem(
                                      FlutterI18n.translate(
                                          context, "onboarding.userForm.woman"),
                                      'woman'),
                                  DropdownItem(
                                      FlutterI18n.translate(
                                          context, "onboarding.userForm.other"),
                                      'other')
                                ],
                                label: FlutterI18n.translate(
                                    context, "onboarding.userForm.genderField"),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 20, bottom: 16),
                                  child: Dropdown(
                                    value: householdValue,
                                    onChanged: (String newValue) {
                                      setState(() {
                                        householdValue = newValue;
                                      });
                                    },
                                    focusNode: householdFocusNode,
                                    validator: (value) {
                                      if (value == null &&
                                          !age.isEmpty &&
                                          int.parse(age) >= 19) {
                                        householdFocusNode.requestFocus();
                                        return FlutterI18n.translate(context,
                                            "onboarding.userForm.householdFieldIncomplete");
                                      }
                                      return null;
                                    },
                                    items: <DropdownItem>[
                                      DropdownItem("1", "1"),
                                      DropdownItem("2", "2"),
                                      DropdownItem("3", "3"),
                                      DropdownItem("4+", "4+"),
                                    ],
                                    label: FlutterI18n.translate(context,
                                        "onboarding.userForm.householdField"),
                                  )),
                              Divider(height: 30),
                              ToggleWithLabel(
                                label: FlutterI18n.translate(context,
                                    "onboarding.userForm.hasChronicHealthCondition"),
                                isMoreQuestionsOption: true,
                                autovalidate: _autovalidate,
                                onPress: (bool value) {
                                  _handleChoicesChange(
                                      'hasChronicHealthCondition', value);
                                },
                                status: choices['hasChronicHealthCondition'],
                              ),
                            ],
                          )),
                      ExpandedSection(
                          expand: choices['hasChronicHealthCondition'] == null
                              ? false
                              : choices['hasChronicHealthCondition'],
                          child: Stack(children: <Widget>[
                            Container(
                                margin: EdgeInsets.fromLTRB(8, 15, 8, 0),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 10),
                                decoration: new BoxDecoration(
                                  color: Constants.lightBlue,
                                  borderRadius: new BorderRadius.all(
                                    new Radius.circular(15.0),
                                  ),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    ToggleWithLabel(
                                      label: FlutterI18n.translate(context,
                                          "onboarding.userForm.isSmoker"),
                                      autovalidate: _autovalidate,
                                      onPress: (bool value) {
                                        _handleChoicesChange('isSmoker', value);
                                      },
                                      status: choices['isSmoker'],
                                      isSubOption: true,
                                    ),
                                    Divider(
                                        height: 30,
                                        color: Colors.white,
                                        thickness: 1),
                                    ToggleWithLabel(
                                      label: FlutterI18n.translate(context,
                                          "onboarding.userForm.hasDiabetes"),
                                      autovalidate: _autovalidate,
                                      onPress: (bool value) {
                                        _handleChoicesChange(
                                            'hasDiabetes', value);
                                      },
                                      status: choices['hasDiabetes'],
                                      isSubOption: true,
                                    ),
                                    Divider(
                                        height: 30,
                                        color: Colors.white,
                                        thickness: 1),
                                    ToggleWithLabel(
                                      label: FlutterI18n.translate(context,
                                          "onboarding.userForm.isImmunosuppressed"),
                                      autovalidate: _autovalidate,
                                      onPress: (bool value) {
                                        _handleChoicesChange(
                                            'isImmunosuppressed', value);
                                      },
                                      status: choices['isImmunosuppressed'],
                                      isSubOption: true,
                                    ),
                                    Divider(
                                        height: 30,
                                        color: Colors.white,
                                        thickness: 1),
                                    ToggleWithLabel(
                                      label: FlutterI18n.translate(context,
                                          "onboarding.userForm.hasCancer"),
                                      autovalidate: _autovalidate,
                                      onPress: (bool value) {
                                        _handleChoicesChange(
                                            'hasCancer', value);
                                      },
                                      status: choices['hasCancer'],
                                      isSubOption: true,
                                    ),
                                    Divider(
                                        height: 30,
                                        color: Colors.white,
                                        thickness: 1),
                                    ToggleWithLabel(
                                      label: FlutterI18n.translate(context,
                                          "onboarding.userForm.hasHeartDisease"),
                                      autovalidate: _autovalidate,
                                      onPress: (bool value) {
                                        _handleChoicesChange(
                                            'hasHeartDisease', value);
                                      },
                                      status: choices['hasHeartDisease'],
                                      isSubOption: true,
                                    ),
                                    Divider(
                                        height: 30,
                                        color: Colors.white,
                                        thickness: 1),
                                    ToggleWithLabel(
                                      label: FlutterI18n.translate(context,
                                          "onboarding.userForm.hasHypertension"),
                                      autovalidate: _autovalidate,
                                      onPress: (bool value) {
                                        _handleChoicesChange(
                                            'hasHypertension', value);
                                      },
                                      status: choices['hasHypertension'],
                                      isSubOption: true,
                                    ),
                                    Divider(
                                        height: 30,
                                        color: Colors.white,
                                        thickness: 1),
                                    ToggleWithLabel(
                                      label: FlutterI18n.translate(context,
                                          "onboarding.userForm.hasChronicLungCondition"),
                                      autovalidate: _autovalidate,
                                      onPress: (bool value) {
                                        _handleChoicesChange(
                                            'hasChronicLungCondition', value);
                                      },
                                      status:
                                          choices['hasChronicLungCondition'],
                                      isSubOption: true,
                                    ),
                                    Divider(
                                        height: 30,
                                        color: Colors.white,
                                        thickness: 1),
                                    ToggleWithLabel(
                                      label: FlutterI18n.translate(context,
                                          "onboarding.userForm.hadStroke"),
                                      autovalidate: _autovalidate,
                                      onPress: (bool value) {
                                        _handleChoicesChange(
                                            'hadStroke', value);
                                      },
                                      status: choices['hadStroke'],
                                      isSubOption: true,
                                    ),
                                  ],
                                )),
                            Positioned(
                                top: 0,
                                right: 30,
                                child: ExcludeSemantics(
                                    child: SvgPicture.asset(
                                        "assets/svg/blue-expanded-arrow.svg")))
                          ])),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(children: <Widget>[
                            Divider(height: 30),
                            ToggleWithLabel(
                              label: FlutterI18n.translate(
                                  context, "onboarding.userForm.hasSymptoms"),
                              autovalidate: _autovalidate,
                              onPress: (bool value) {
                                _handleChoicesChange('hasSymptoms', value);
                              },
                              status: choices['hasSymptoms'],
                            ),
                            Divider(height: 30),
                            ToggleWithLabel(
                              label: FlutterI18n.translate(context,
                                  "onboarding.userForm.closeToInfected"),
                              autovalidate: _autovalidate,
                              onPress: (bool value) {
                                _handleChoicesChange('closeToInfected', value);
                              },
                              status: choices['closeToInfected'],
                            ),
                            Divider(height: 30),
                            ToggleWithLabel(
                              label: FlutterI18n.translate(context,
                                  "onboarding.userForm.hasTraveledOutsideCanada"),
                              autovalidate: _autovalidate,
                              onPress: (bool value) {
                                _handleChoicesChange(
                                    'hasTraveledOutsideCanada', value);
                              },
                              status: choices['hasTraveledOutsideCanada'],
                            ),
                            Divider(height: 30),
                            ToggleWithLabel(
                              label: FlutterI18n.translate(context,
                                  "onboarding.userForm.hasCloseContactToOutsideTraveler"),
                              autovalidate: _autovalidate,
                              onPress: (bool value) {
                                _handleChoicesChange(
                                    'hasCloseContactToOutsideTraveler', value);
                              },
                              status:
                                  choices['hasCloseContactToOutsideTraveler'],
                            ),
                            Divider(height: 30),
                            ToggleWithLabel(
                              label: FlutterI18n.translate(context,
                                  "onboarding.userForm.isHealthcareWorker"),
                              autovalidate: _autovalidate,
                              isMoreQuestionsOption: true,
                              onPress: (bool value) {
                                _handleChoicesChange(
                                    'isHealthcareWorker', value);
                              },
                              status: choices['isHealthcareWorker'],
                            ),
                          ])),
                      Divider(height: 4, color: Colors.white),
                      ExpandedSection(
                          expand: choices['isHealthcareWorker'] == null
                              ? false
                              : choices['isHealthcareWorker'],
                          child: Stack(children: <Widget>[
                            Container(
                                margin: EdgeInsets.fromLTRB(8, 15, 8, 0),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 10),
                                decoration: new BoxDecoration(
                                  color: Constants.lightBlue,
                                  borderRadius: new BorderRadius.all(
                                    new Radius.circular(15.0),
                                  ),
                                ),
                                child: ToggleWithLabel(
                                  label: FlutterI18n.translate(context,
                                      "onboarding.userForm.workWithInfected"),
                                  autovalidate: _autovalidate,
                                  onPress: (bool value) {
                                    _handleChoicesChange(
                                        'workWithInfected', value);
                                  },
                                  status: choices['workWithInfected'],
                                  isSubOption: true,
                                )),
                            Positioned(
                                top: 0,
                                right: 30,
                                child: ExcludeSemantics(
                                    child: SvgPicture.asset(
                                        "assets/svg/blue-expanded-arrow.svg")))
                          ])),
                      !age.isEmpty && int.parse(age) >= 19
                          ? Column(children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 16, right: 16, bottom: 10),
                                child: Divider(height: 30),
                              ),
                              DataShare()
                            ])
                          : Container()
                    ])),
                FractionallySizedBox(
                    widthFactor: 1,
                    child: Container(
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    width: 1, color: Constants.borderGrey))),
                        child: Container(
                            padding: EdgeInsets.all(16 * sizeMultiplier),
                            alignment: Alignment.center,
                            child: SaveButton(
                                label: FlutterI18n.translate(
                                    context, "onboarding.continueButton"),
                                rightPosition: 8,
                                width: 320 * sizeMultiplier,
                                loaderSize: 30,
                                isValidToSave: _isFormReady(),
                                onPressed: _validateForm))))
              ],
            )));
  }
}
