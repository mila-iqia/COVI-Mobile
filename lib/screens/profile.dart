import 'dart:async';
import 'package:covi/material/Dropdown.dart';
import 'package:covi/material/ageField.dart';
import 'package:covi/material/actionCard.dart';
import 'package:covi/material/customBackButton.dart';
import 'package:covi/material/customButton.dart';
import 'package:covi/material/dataShareModal.dart';
import 'package:covi/material/profileScreenArguments.dart';
import 'package:covi/material/saveButton.dart';
import 'package:covi/material/switchWithLabel.dart';
import 'package:covi/utils/notifications.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:covi/utils/settings.dart';
import "package:covi/utils/extensions.dart";
import 'package:covi/utils/user_regions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class ChangeEvent<T> {
  final T originalValue;
  final String changedMessage;
  final Function comparatorGenerator;
  T newValue = null;

  ChangeEvent(
      this.originalValue, this.changedMessage, this.comparatorGenerator);

  bool setNewValue(T newValue) {
    if (newValue != this.originalValue) {
      this.newValue = newValue;
      return true;
    }
    this.newValue = null;
    return false;
  }

  String originalComparator() {
    return comparatorGenerator(this.originalValue);
  }

  String newComparator() {
    return comparatorGenerator(this.newValue);
  }
}

class ProfileScreen extends StatefulWidget {
  ProfileScreen({key}) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, RouteAware, RouteObserverMixin {
  @override
  void didPopNext() async {
    if (comesFromScreen) {
      await loadSettings();
    }
  }

  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  bool loaded = false;
  bool comesFromScreen = false;
  bool isSaving = false;
  bool isGoingBackAfterSaving = false;
  String locale;

  TabController _tabController;

  TextEditingController ageController;
  String age = "";
  bool consentForTeen = false;
  Timer ageTimer;
  bool hasSettingsChanged = false;
  String genderValue = null;
  String selectedLanguage = null;
  String householdValue = null;
  String userProvinceValue = null;
  String userRegionValue = null;

  FocusNode ageFocusNode;
  FocusNode genderFocusNode;
  FocusNode languageFocusNode;
  FocusNode householdFocusNode;
  FocusNode provinceFocusNode;
  FocusNode regionFocusNode;

  Map<String, bool> choices = {
    'receivePushNotifications': false,
    'shareCovidTestResult': false,
  };

  List<dynamic> allRegionsData;
  List<DropdownItem> provinces;
  List<DropdownItem> regions;

  Map<String, String> languageCorrespondance;
  Map<String, String> genderCorrespondance;
  Map<String, String> householdCorrespondance;

  Map<String, ChangeEvent> changedValues;

  bool dataHasChanged = false;

  FocusNode privacyDataToggleFocus = FocusNode();
  FocusNode locationToggleFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    ageController = TextEditingController();
    ageFocusNode = FocusNode();
    genderFocusNode = FocusNode();
    languageFocusNode = FocusNode();
    householdFocusNode = FocusNode();
    provinceFocusNode = FocusNode();
    regionFocusNode = FocusNode();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      allRegionsData =
          await Provider.of<UserRegionsManager>(context, listen: false)
              .loadRegionsData();

      languageCorrespondance = {
        "en": FlutterI18n.translate(context, 'english'),
        "fr": FlutterI18n.translate(context, 'french'),
      };

      genderCorrespondance = {
        "man": FlutterI18n.translate(context, 'onboarding.userForm.man'),
        "woman": FlutterI18n.translate(context, 'onboarding.userForm.woman'),
        "other": FlutterI18n.translate(context, 'onboarding.userForm.other'),
      };

      householdCorrespondance = {
        "1": "1",
        "2": "2",
        "3": "3",
        "4+": "4+",
      };

      await loadSettings();

      ProfileScreenArguments args = ModalRoute.of(context).settings.arguments;
      int activeTabIndex;
      if (args != null) {
        activeTabIndex = args.tab;
      }
      if (activeTabIndex != null) {
        _tabController.index = activeTabIndex;
      }
    });
  }

  @override
  void dispose() {
    privacyDataToggleFocus.dispose();
    locationToggleFocus.dispose();
    ageFocusNode.dispose();
    genderFocusNode.dispose();
    languageFocusNode.dispose();
    householdFocusNode.dispose();
    provinceFocusNode.dispose();
    regionFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Constants.lightGrey,
      nextFocus: false,
      actions: [
        KeyboardAction(focusNode: ageFocusNode, toolbarButtons: [
          (node) {
            return FlatButton(
                padding: EdgeInsets.all(8.0),
                child: Text(FlutterI18n.translate(context, "done"),
                    style: Constants.CustomTextStyle.blue14Text(context)),
                onPressed: () => node.unfocus());
          }
        ]),
      ],
    );
  }

  void loadSettings() async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);
    UserRegionsManager userRegionsManager =
        Provider.of<UserRegionsManager>(context, listen: false);

    await settingsManager.loadSettings();

    String lang = await settingsManager.getLang();

    setState(() {
      //Parse allRegionsData
      provinces = allRegionsData
          .where((region) => region['level'] == 'state')
          .map((region) => DropdownItem(region['name'][lang], region['region']))
          .toList();
      regions = allRegionsData
          .where((region) =>
              region['parent'] == userRegionsManager.regions['state']['region'])
          .map((region) => DropdownItem(region['name'][lang], region['region']))
          .toList();

      comesFromScreen = false;
      hasSettingsChanged = false;
      ageController.text = settingsManager.settings.user_data.age != null
          ? settingsManager.settings.user_data.age.toString()
          : "";
      age = settingsManager.settings.user_data.age != null
          ? settingsManager.settings.user_data.age.toString()
          : null;
      if (settingsManager.settings.user_data.age != null &&
          settingsManager.settings.user_data.age >= 13 &&
          settingsManager.settings.user_data.age <= 15) {
        consentForTeen = settingsManager.settings.user_data.consentForTeen;
      }

      genderValue = settingsManager.settings.user_data.gender;
      selectedLanguage = lang;
      locale = lang;
      householdValue = settingsManager.settings.user_data.household;
      userProvinceValue = userRegionsManager.regions['state']['region'];
      userRegionValue = userRegionsManager.regions['subregion']['region'];

      choices['receivePushNotifications'] =
          settingsManager.settings.receivePushNotifications;
      choices['shareCovidTestResult'] =
          settingsManager.settings.shareCovidTestResult;

      changedValues = {
        "age": ChangeEvent(settingsManager.settings.user_data.age.toString(),
            FlutterI18n.translate(context, 'privacy.modifiedAge'), (age) {
          return age.toString();
        }),
        "genderValue": ChangeEvent(genderValue,
            FlutterI18n.translate(context, 'privacy.modifiedGender'),
            (genderValue) {
          return genderCorrespondance[genderValue];
        }),
        "householdValue": ChangeEvent(householdValue,
            FlutterI18n.translate(context, 'privacy.modifiedHousehold'),
            (householdValue) {
          return householdCorrespondance[householdValue];
        }),
        "userProvinceValue": ChangeEvent(userProvinceValue,
            FlutterI18n.translate(context, 'privacy.modifiedHousehold'),
            (userProvinceValue) {
          return allRegionsData.firstWhere(
                  (region) => region['region'] == userProvinceValue)['name']
              [locale];
        }),
        "userRegionValue": ChangeEvent(userProvinceValue,
            FlutterI18n.translate(context, 'privacy.modifiedHousehold'),
            (userRegionValue) {
          return allRegionsData.firstWhere(
              (region) => region['region'] == userRegionValue)['name'][locale];
        }),
        "language": ChangeEvent(selectedLanguage,
            FlutterI18n.translate(context, 'privacy.modifiedLanguage'),
            (language) {
          return languageCorrespondance[language];
        }),
        "receivePushNotifications": ChangeEvent(
            choices['receivePushNotifications'],
            FlutterI18n.translate(
                context, 'privacy.modifiedReceivePushNotifications'), (choice) {
          return choice
              ? FlutterI18n.translate(context, 'yes').capitalize()
              : FlutterI18n.translate(context, 'no').capitalize();
        }),
        "shareCovidTestResult": ChangeEvent(
            choices['shareCovidTestResult'],
            FlutterI18n.translate(
                context, 'privacy.modifiedAnonymousMILADataShare'), (choice) {
          return choice
              ? FlutterI18n.translate(context, 'yes').capitalize()
              : FlutterI18n.translate(context, 'no').capitalize();
        }),
      };
      loaded = true;
    });
  }

  _launchURL() async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);
    String lang = await settingsManager.getLang();

    String url = lang == "fr"
        ? Constants.privacyPolicyURl_FR
        : Constants.privacyPolicyURL_EN;

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
                type: ShareModalType.profile,
                closeCallback: () {
                  Navigator.of(context).pop();
                  privacyDataToggleFocus.requestFocus();
                });
          },
        );
      },
    );
  }

  Future<void> _showLocationDialog() async {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: SingleChildScrollView(
              child: Container(
                  child: ListBody(
            children: <Widget>[
              Divider(
                  height: 16 * sizeMultiplier, color: Constants.transparent),
              Center(
                  child: SvgPicture.asset('assets/svg/icon-questionmark.svg',
                      width: 30 * sizeMultiplier)),
              Divider(
                  height: 16 * sizeMultiplier, color: Constants.transparent),
              Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16 * sizeMultiplier),
                  child: Center(
                    child: Text(
                        FlutterI18n.translate(
                            context, "privacy.locationServicesDialog"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Constants.darkBlue,
                            fontSize: 16 * sizeMultiplier,
                            fontWeight: FontWeight.w500)),
                  )),
              Divider(
                  height: 24 * sizeMultiplier, color: Constants.transparent),
              Divider(height: 1),
              Center(
                  child: CustomButton(
                padding: EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width,
                label: FlutterI18n.translate(context, "close"),
                textColor: Constants.darkBlue,
                labelStyle: TextStyle(
                    fontSize: 14 * sizeMultiplier,
                    fontWeight: FontWeight.normal),
                backgroundColor: Constants.transparent,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )),
            ],
          ))),
        );
      },
    );
  }

  //Changing Handlers

  bool _hasSettingsChanged() {
    for (final cV in changedValues.values) {
      if (cV.newValue != null) {
        return true;
      }
    }
    return false;
  }

  void _handleChoicesChange(String name, bool value) {
    changedValues[name].setNewValue(value);
    setState(() {
      choices[name] = value;
      hasSettingsChanged = _hasSettingsChanged();
    });
  }

  void _changeLanguage(value) {
    changedValues['language'].setNewValue(value);
    setState(() {
      selectedLanguage = value;
      hasSettingsChanged = _hasSettingsChanged();
    });
  }

  void _changeSex(value) {
    changedValues['genderValue'].setNewValue(value);
    setState(() {
      genderValue = value;
      hasSettingsChanged = _hasSettingsChanged();
    });
  }

  void _changeProvince(value) {
    changedValues['userProvinceValue'].setNewValue(value);
    changedValues['userRegionValue'].setNewValue(value);
    List<DropdownItem> newRegions = allRegionsData
        .where((region) => region['parent'] == value)
        .map((region) => DropdownItem(region['name'][locale], region['region']))
        .toList();
    setState(() {
      userProvinceValue = value;
      regions = newRegions;
      userRegionValue = newRegions.first.value;
      hasSettingsChanged = _hasSettingsChanged();
    });
  }

  void _changeRegion(value) {
    changedValues['userRegionValue'].setNewValue(value);
    setState(() {
      userRegionValue = value;
      hasSettingsChanged = _hasSettingsChanged();
    });
  }

  void _changeHousehold(value) {
    changedValues['householdValue'].setNewValue(value);
    setState(() {
      householdValue = value;
      hasSettingsChanged = _hasSettingsChanged();
    });
  }

  void _handleAgeChange(value) {
    setState(() {
      age = "";
    });
    if (ageTimer != null) ageTimer.cancel();
    ageTimer = new Timer(const Duration(seconds: 1), () {
      setState(() {
        age = value.toString();
      });
      changedValues['age'].setNewValue(value);

      setState(() {
        hasSettingsChanged = _hasSettingsChanged();
      });
    });
  }

  void _handleConsentForTeenChange(value) {
    setState(() {
      consentForTeen = value;
    });
  }

  bool _isFormValid() {
    // if (age == null) {
    //   return false;
    // }

    // if (age.isEmpty) {
    //   return false;
    // }
    if (age != null) {
      RegExp digitsOnly = new RegExp('[0-9]');
      if (age.isEmpty || !digitsOnly.hasMatch(age)) {
        return false;
      } else {
        if (int.parse(age) < 13) {
          return false;
        }

        if (int.parse(age) > 12 && int.parse(age) < 16 && !consentForTeen) {
          return false;
        }
      }

      // if (!age.isEmpty && int.parse(age) >= 19) {
      //   if (genderValue == null) {
      //     return false;
      //   }
      //   if (householdValue == null) {
      //     return false;
      //   }
      // }
    }

    return true;
  }

  //Back handler

  void _handleBackPress() {
    if (!isSaving) {
      if (hasSettingsChanged) {
        _confirmSavePrompt();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        isGoingBackAfterSaving = true;
      });
    }
  }

  //Saving & Reset Handlers

  void saveSettings(bool quitAfterSave) async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);
    UserRegionsManager userRegionsManager =
        Provider.of<UserRegionsManager>(context, listen: false);

    await settingsManager.loadSettings();

    if (_formKey.currentState.validate() && _isFormValid()) {
      String lang = selectedLanguage;
      await settingsManager.setLang(lang);
      await settingsManager.loadLang(context);
      bool isUnderToLegalAge = false;
      if (!ageController.text.isEmpty) {
        isUnderToLegalAge = (settingsManager.settings.user_data.age != null &&
                settingsManager.settings.user_data.age <= 18) &&
            int.parse(ageController.text) == 19;
        settingsManager.settings.user_data.age = int.parse(ageController.text);
        if (int.parse(ageController.text) >= 13 &&
            int.parse(ageController.text) <= 15) {
          settingsManager.settings.user_data.consentForTeen = consentForTeen;
        }
        settingsManager.settings.user_data.gender =
            int.parse(ageController.text) >= 19 ? genderValue : null;
        settingsManager.settings.user_data.household =
            int.parse(ageController.text) >= 19 ? householdValue : null;
        settingsManager.settings.shareCovidTestResult =
            int.parse(ageController.text) < 19
                ? false
                : choices['shareCovidTestResult'];
      }

      settingsManager.settings.receivePushNotifications =
          choices['receivePushNotifications'];
      // cancel all planned notifications if user doesn't want notifications
      if (!choices['receivePushNotifications'])
        await Notifications.cancelAllNotifications();

      DateTime now = new DateTime.now();
      Provider.of<RecommendationsProvider>(context, listen: false)
          .updateExceptionExpirationDate();
      settingsManager.settings.user_data.recommendationUpdateDate = now;
      settingsManager.settings.user_data.settingsUpdateDate = now;

      await settingsManager.saveSettings();

      //Save Region Data
      Map<String, dynamic> userProvince = allRegionsData
          .firstWhere((region) => region['region'] == userProvinceValue);
      await userRegionsManager.saveRegionToUserRegions(userProvince);
      Map<String, dynamic> userRegion = allRegionsData
          .firstWhere((region) => region['region'] == userRegionValue);
      await userRegionsManager.saveRegionToUserRegions(userRegion);

      setState(() {
        isSaving = false;
      });
      if (quitAfterSave || isGoingBackAfterSaving) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } else {
        await loadSettings();
        if (isUnderToLegalAge) {
          setState(() {
            comesFromScreen = true;
          });
          Navigator.of(context).pushNamed("/profile/age-consent");
        }
      }
    } else {
      setState(() {
        isSaving = false;
        _autovalidate = true;
      });
    }
  }

  //Modal Handlers

  Future<void> _confirmSavePrompt() async {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    List<ChangeEvent> hasChanged = [];
    changedValues.forEach((String name, ChangeEvent changeEvent) {
      if (changeEvent.newValue != null) {
        hasChanged.add(changeEvent);
      }
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: SingleChildScrollView(
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: ListBody(
                    children: <Widget>[
                      Text(
                        !_isFormValid()
                            ? FlutterI18n.translate(
                                context, "privacy.uncompletedChanges")
                            : FlutterI18n.translate(
                                context, "privacy.saveDataMessage"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16 * sizeMultiplier,
                            color: Constants.darkBlue),
                      ),
                      _isFormValid()
                          ? Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Column(
                                children: hasChanged
                                    .map((c) => Text(
                                          "${c.changedMessage}:\n${FlutterI18n.translate(context, 'privacy.from')} ${c.originalComparator() == 'null' || c.originalComparator() == null ? FlutterI18n.translate(context, 'nothing') : c.originalComparator()} ${FlutterI18n.translate(context, 'privacy.to')} ${c.newComparator()}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16 * sizeMultiplier,
                                              color: Constants.darkBlue,
                                              fontWeight: FontWeight.w500),
                                        ))
                                    .toList(),
                              ))
                          : Container(),
                      Divider(height: 40),
                      Text(
                          !_isFormValid()
                              ? FlutterI18n.translate(
                                  context, "privacy.backWarning")
                              : FlutterI18n.translate(
                                  context, "privacy.saveDataWarning"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14 * sizeMultiplier,
                            fontWeight: FontWeight.bold,
                            color: Constants.darkBlue,
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 16 * sizeMultiplier),
                          child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: <Widget>[
                                !_isFormValid()
                                    ? CustomButton(
                                        label: FlutterI18n.translate(
                                                context, "yes")
                                            .capitalize(),
                                        shadowColor: Colors.black12,
                                        onPressed: () {
                                          Navigator.popUntil(context,
                                              ModalRoute.withName('/'));
                                        },
                                      )
                                    : SaveButton(
                                        width: 150,
                                        rightPosition: 8,
                                        loaderSize: 20,
                                        isValidToSave: _isFormValid() &&
                                            hasSettingsChanged,
                                        onPressed: () async {
                                          await saveSettings(true);
                                        }),
                                CustomButton(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25 * sizeMultiplier),
                                    width: null,
                                    label: !_isFormValid()
                                        ? FlutterI18n.translate(context, "no")
                                            .capitalize()
                                        : FlutterI18n.translate(
                                            context, "cancel"),
                                    textColor: Constants.darkBlue,
                                    labelStyle: TextStyle(
                                        fontSize: 14 * sizeMultiplier,
                                        fontWeight: FontWeight.normal),
                                    backgroundColor: Constants.transparent,
                                    onPressed: () {
                                      if (_isFormValid()) {
                                        Navigator.popUntil(
                                            context, ModalRoute.withName('/'));
                                      } else {
                                        setState(() {
                                          _autovalidate = true;
                                        });
                                        Navigator.of(context).pop();
                                      }
                                    })
                              ]))
                    ],
                  ))),
        );
      },
    );
  }

  Future<void> _confirmDeleteAll() async {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: SingleChildScrollView(
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: ListBody(
                    children: <Widget>[
                      Text(
                        FlutterI18n.translate(
                            context, "privacy.deleteDataMessage"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16 * sizeMultiplier,
                            color: Constants.darkBlue),
                      ),
                      Divider(height: 40),
                      Text(
                          FlutterI18n.translate(
                              context, "privacy.deleteDataWarning"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14 * sizeMultiplier,
                            fontWeight: FontWeight.bold,
                            color: Constants.darkBlue,
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 18),
                          child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: <Widget>[
                                CustomButton(
                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                  label: FlutterI18n.translate(
                                      context, "privacy.deleteDataYes"),
                                  labelAlign: TextAlign.center,
                                  labelStyle: TextStyle(
                                      fontSize: 14 * sizeMultiplier,
                                      fontWeight: FontWeight.normal),
                                  textColor: Colors.white,
                                  width: null,
                                  backgroundColor: Color(0xFFbd232a),
                                  shadowColor: Colors.black12,
                                  onPressed: () {
                                    SettingsManager.resetApp(context);
                                  },
                                ),
                                CustomButton(
                                  padding: EdgeInsets.all(0),
                                  width: null,
                                  label:
                                      FlutterI18n.translate(context, "cancel"),
                                  textColor: Constants.darkBlue,
                                  labelStyle: TextStyle(
                                      fontSize: 14 * sizeMultiplier,
                                      fontWeight: FontWeight.normal),
                                  backgroundColor: Constants.transparent,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ]))
                    ],
                  ))),
        );
      },
    );
  }

  //Widget Building

  Widget _buildProfileForm() {
    if (!loaded) {
      return Container();
    }
    return ListView(
      children: <Widget>[
        Divider(
          height: 32,
          color: Colors.white,
        ),
        AgeField(
          age: age,
          ageController: ageController,
          ageFocusNode: ageFocusNode,
          consentForTeen: consentForTeen,
          autovalidate: _autovalidate,
          onAgeChanged: _handleAgeChange,
          onConsentTeenChanged: _handleConsentForTeenChange,
        ),
        Divider(
          height: 20,
          color: Colors.white,
        ),
        if (!ageController.text.isEmpty && int.parse(ageController.text) >= 19)
          Column(children: <Widget>[
            Dropdown(
              value: genderValue,
              onChanged: (String value) {
                _changeSex(value);
              },
              focusNode: genderFocusNode,
              validator: (value) {
                // if (value == null) {
                //   genderFocusNode.requestFocus();
                //   return FlutterI18n.translate(context, "onboarding.userForm.genderFieldIncomplete");
                // }
                return null;
              },
              items: <DropdownItem>[
                DropdownItem(
                    FlutterI18n.translate(context, "onboarding.userForm.man"),
                    'man'),
                DropdownItem(
                    FlutterI18n.translate(context, "onboarding.userForm.woman"),
                    'woman'),
                DropdownItem(
                    FlutterI18n.translate(context, "onboarding.userForm.other"),
                    'other')
              ],
              label: FlutterI18n.translate(
                  context, "onboarding.userForm.genderField"),
            ),
            Divider(
              height: 20,
              color: Colors.white,
            ),
            Dropdown(
              value: householdValue,
              onChanged: (String value) {
                _changeHousehold(value);
              },
              focusNode: householdFocusNode,
              validator: (value) {
                // if (value == null) {
                //   householdFocusNode.requestFocus();
                //   return FlutterI18n.translate(context, "onboarding.userForm.householdFieldIncomplete");
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
                  context, "onboarding.userForm.householdField"),
            ),
            Divider(
              height: 20,
              color: Colors.white,
            ),
          ]),
        Dropdown(
          value: selectedLanguage,
          focusNode: languageFocusNode,
          onChanged: (String value) {
            _changeLanguage(value);
          },
          validator: (value) {
            return null;
          },
          items: <DropdownItem>[
            DropdownItem(FlutterI18n.translate(context, "french"), 'fr'),
            DropdownItem(FlutterI18n.translate(context, "english"), 'en')
          ],
          label: FlutterI18n.translate(context, "profile.languageField"),
        ),
        Divider(
          height: 20,
          color: Colors.white,
        ),
        Dropdown(
          value: userProvinceValue,
          focusNode: provinceFocusNode,
          onChanged: (String value) {
            _changeProvince(value);
          },
          validator: (value) {
            return null;
          },
          items: provinces,
          label: FlutterI18n.translate(context, "profile.provinceField"),
        ),
        Divider(
          height: 20,
          color: Colors.white,
        ),
        Dropdown(
          value: userRegionValue,
          focusNode: regionFocusNode,
          onChanged: (String value) {
            _changeRegion(value);
          },
          validator: (value) {
            return null;
          },
          items: regions,
          label: FlutterI18n.translate(context, "profile.regionField"),
        ),
      ],
    );
  }

  Widget _consentDisableUnder19() {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(12),
              child: Text(
                  FlutterI18n.translate(
                      context, "ageConsent.ageConsentExplanation"),
                  style: TextStyle(
                      fontSize: 12 * sizeMultiplier,
                      height: 1.2,
                      fontStyle: FontStyle.italic))),
          !ageController.text.isEmpty && int.parse(ageController.text) == 18
              ? Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              width: 1, color: Constants.borderGrey))),
                  child: CustomButton(
                    width: MediaQuery.of(context).size.width - 32,
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    splashColor: Constants.blueSplash,
                    textColor: Constants.mediumBlue,
                    borderRadius: 12,
                    onPressed: () {
                      setState(() {
                        comesFromScreen = true;
                      });
                      Navigator.of(context).pushNamed("/profile/age-consent");
                    },
                    customContent: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              FlutterI18n.translate(
                                  context, "ageConsent.iTurned19Recently"),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12 * sizeMultiplier)),
                          SvgPicture.asset('assets/svg/arrow-blue.svg',
                              width: 8 * sizeMultiplier)
                        ]),
                  ))
              : Container()
        ]);
  }

  Widget _consentDisableProfileIncomplete() {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Container(
          padding: EdgeInsets.all(12),
          child: Text(
              FlutterI18n.translate(context, "profileIncomplete.explanation"),
              style: TextStyle(
                  fontSize: 12 * sizeMultiplier,
                  height: 1.2,
                  fontStyle: FontStyle.italic))),
      Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(width: 1, color: Constants.borderGrey))),
          child: CustomButton(
            width: MediaQuery.of(context).size.width - 32,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 12),
            splashColor: Constants.blueSplash,
            textColor: Constants.mediumBlue,
            borderRadius: 12,
            onPressed: () {
              setState(() {
                comesFromScreen = true;
                _tabController.index = 0;
              });
            },
            customContent: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                      FlutterI18n.translate(
                          context, "profileIncomplete.completeProfile"),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12 * sizeMultiplier)),
                  SvgPicture.asset('assets/svg/arrow-blue.svg',
                      width: 8 * sizeMultiplier)
                ]),
          ))
    ]);
  }

  Widget _buildPrivacyForm() {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    TextStyle titleStyle = TextStyle(color: Constants.darkBlue);
    return ListView(
      children: <Widget>[
        Divider(height: 15, color: Colors.white),
        SwitchWithLabel(
            title: FlutterI18n.translate(context, "privacy.pushNotifications"),
            titleStyle: titleStyle,
            value: choices['receivePushNotifications'],
            activeText: FlutterI18n.translate(context, "yes").toUpperCase(),
            inactiveText: FlutterI18n.translate(context, "no").toUpperCase(),
            onChanged: (bool newValue) {
              _handleChoicesChange('receivePushNotifications', newValue);
            }),
        Divider(height: 15),
        SwitchWithLabel(
          title: FlutterI18n.translate(context, "privacy.anonymousMilaShare"),
          titleStyle: titleStyle,
          focusNode: privacyDataToggleFocus,
          infoBubbleCallback: () {
            _ackAlert(context);
          },
          value: choices['shareCovidTestResult'],
          activeText: FlutterI18n.translate(context, "yes").toUpperCase(),
          inactiveText: FlutterI18n.translate(context, "no").toUpperCase(),
          isDisabled: (!ageController.text.isEmpty &&
                  int.parse(ageController.text) < 19) ||
              ageController.text.isEmpty,
          onChanged: (bool newValue) {
            _handleChoicesChange('shareCovidTestResult', newValue);
          },
          disabledExplanationContent: ageController.text.isEmpty
              ? _consentDisableProfileIncomplete()
              : _consentDisableUnder19(),
        ),
        Divider(height: 30),
        ActionCard(
            cardPadding: 0,
            circleColor: ActionCardColor.gradientBlue,
            onTap: () {
              _launchURL();
            },
            button: SvgPicture.asset('assets/svg/share-icon.svg',
                width: 20 * sizeMultiplier),
            semanticLabel: FlutterI18n.translate(context, "a11y.externalLink"),
            iconWidth: 32 * sizeMultiplier,
            content: RichText(
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              text: TextSpan(
                text: FlutterI18n.translate(context, "privacy.privacyPolicy1"),
                style: TextStyle(
                    fontFamily: 'Neue',
                    color: Constants.mediumBlue,
                    fontSize: 14 * sizeMultiplier,
                    fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                      text: FlutterI18n.translate(
                          context, "privacy.privacyPolicy2"),
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )),
        Divider(height: 30),
        Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Center(
                child: CustomButton(
              padding: EdgeInsets.symmetric(horizontal: 25),
              label: FlutterI18n.translate(context, "privacy.deleteDataButton"),
              labelStyle: TextStyle(
                  fontSize: 14 * sizeMultiplier, fontWeight: FontWeight.w700),
              textColor: Colors.white,
              width: null,
              backgroundColor: Color(0xFFbd232a),
              splashColor: Constants.redSplash,
              shadowColor: Colors.black12,
              onPressed: () {
                _confirmDeleteAll();
              },
            )))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    ProfileScreenArguments args = ModalRoute.of(context).settings.arguments;
    String cameFrom;

    if (args != null) {
      cameFrom = args.cameFrom == 'health'
          ? FlutterI18n.translate(context, "screens.health")
          : FlutterI18n.translate(context, "screens.dashboard");
    } else {
      cameFrom = FlutterI18n.translate(context, "screens.dashboard");
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          KeyboardActions(
              config: _buildConfig(context),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.topLeft,
                          child: ExcludeSemantics(
                              child: SvgPicture.asset(
                                  'assets/svg/backdrops/settings.svg',
                                  height: 75 * sizeMultiplier))),
                      SafeArea(
                          child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 8 * sizeMultiplier),
                                child: CustomBackButton(
                                  label: FlutterI18n.translate(context, "back"),
                                  a11yLabel: FlutterI18n.translate(
                                          context, "goBackTo") +
                                      cameFrom,
                                  shadowColor: Colors.black54,
                                  backgroundColor: Constants.beige,
                                  textColor: Constants.darkBlue,
                                  onPressed: () => _handleBackPress(),
                                ),
                              )
                            ],
                          ),
                          Semantics(
                              label: FlutterI18n.translate(
                                  context, "a11y.header1"),
                              header: true,
                              child: Text(
                                FlutterI18n.translate(context, "profile.title"),
                                style: TextStyle(
                                    color: Constants.darkBlue,
                                    fontSize: 20 * sizeMultiplier,
                                    height: 1,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              )),
                          Divider(
                              color: Constants.transparent,
                              height: 8 * sizeMultiplier),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: TabBar(
                                isScrollable:
                                    MediaQuery.of(context).textScaleFactor > 1
                                        ? true
                                        : false,
                                labelColor: Constants.mediumBlue,
                                indicatorColor: Constants.mediumBlue,
                                indicatorWeight: 5,
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16 * sizeMultiplier),
                                unselectedLabelColor: Constants.mediumGrey,
                                unselectedLabelStyle:
                                    TextStyle(fontWeight: FontWeight.w500),
                                controller: _tabController,
                                tabs: <Widget>[
                                  Container(
                                      height: (16 *
                                              MediaQuery.of(context)
                                                  .textScaleFactor) +
                                          (30 * sizeMultiplier),
                                      child: Tab(
                                          child: Text(
                                              FlutterI18n.translate(
                                                  context, "profile.profile"),
                                              style: TextStyle(
                                                  fontFamily: 'Neue')))),
                                  Container(
                                      height: (16 *
                                              MediaQuery.of(context)
                                                  .textScaleFactor) +
                                          (30 * sizeMultiplier),
                                      child: Tab(
                                        child: Text(
                                            FlutterI18n.translate(
                                                context, "profile.privacy"),
                                            style:
                                                TextStyle(fontFamily: 'Neue')),
                                      ))
                                ],
                              )),
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Form(
                                autovalidate: _autovalidate,
                                key: _formKey,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: <Widget>[
                                    _buildProfileForm(),
                                    _buildPrivacyForm()
                                  ],
                                )),
                          )),
                          FractionallySizedBox(
                              widthFactor: 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                              width: 1,
                                              color: Constants.borderGrey))),
                                  padding: EdgeInsets.only(
                                      top: 20, left: 16, right: 16, bottom: 24),
                                  child: SaveButton(
                                      width: MediaQuery.of(context).size.width -
                                          32,
                                      loaderSize: 30,
                                      isValidToSave:
                                          _isFormValid() && hasSettingsChanged,
                                      doBeforeLoader: () {
                                        setState(() {
                                          isSaving = true;
                                        });
                                      },
                                      onPressed: hasSettingsChanged
                                          ? () {
                                              saveSettings(false);
                                            }
                                          : null)))
                        ],
                      )),
                    ],
                  ))),
          Container(
              color: Constants.darkBlue70,
              height: MediaQuery.of(context).padding.top)
        ]));
  }
}
