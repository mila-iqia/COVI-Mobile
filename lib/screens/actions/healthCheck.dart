import 'package:covi/material/contextualBackdrops/darkBlueCross.dart';
import 'package:covi/material/ensureVisibleWhenFocused.dart';
import 'package:covi/utils/notifications.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/extensions.dart';
import 'package:covi/material/ExpandedSection.dart';
import 'package:covi/material/saveCancelButtons.dart';
import 'package:covi/material/toggleFormField.dart';
import 'package:covi/utils/settings.dart';

class HealthCheck extends StatefulWidget {
  HealthCheck({key}) : super(key: key);

  _HealthCheckState createState() => _HealthCheckState();
}

class _HealthCheckState extends State<HealthCheck> {
  bool loaded = false;
  String locale;

  DateTime healthCheckUpdateDate;

  List<FocusNode> errors = [];
  List<ToggleItem> toggleItems = [];

  FocusNode hasChronicHealthConditionFocusNode;
  FocusNode isSmokerFocusNode;
  FocusNode hasDiabetesFocusNode;
  FocusNode isImmunosuppressedFocusNode;
  FocusNode hasCancerFocusNode;
  FocusNode hasHeartDiseaseFocusNode;
  FocusNode hasHypertensionFocusNode;
  FocusNode hasChronicLungConditionFocusNode;
  FocusNode hadStrokeFocusNode;
  FocusNode hasSymptomsFocusNode;
  FocusNode closeToInfectedFocusNode;
  FocusNode hasTraveledOutsideCanadaFocusNode;
  FocusNode hasCloseContactToOutsideTravelerFocusNode;
  FocusNode isHealthcareWorkerFocusNode;
  FocusNode workWithInfectedFocusNode;

  Map<String, bool> choices = {};

  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  @override
  void initState() {
    super.initState();

    hasChronicHealthConditionFocusNode = FocusNode();
    isSmokerFocusNode = FocusNode();
    hasDiabetesFocusNode = FocusNode();
    isImmunosuppressedFocusNode = FocusNode();
    hasCancerFocusNode = FocusNode();
    hasHeartDiseaseFocusNode = FocusNode();
    hasHypertensionFocusNode = FocusNode();
    hasChronicLungConditionFocusNode = FocusNode();
    hadStrokeFocusNode = FocusNode();
    hasSymptomsFocusNode = FocusNode();
    closeToInfectedFocusNode = FocusNode();
    hasTraveledOutsideCanadaFocusNode = FocusNode();
    hasCloseContactToOutsideTravelerFocusNode = FocusNode();
    isHealthcareWorkerFocusNode = FocusNode();
    workWithInfectedFocusNode = FocusNode();

    toggleItems = [
      ToggleItem(
          name: 'hasChronicHealthCondition',
          focusNode: hasChronicHealthConditionFocusNode,
          subItems: [
            ToggleItem(
                name: 'isSmoker',
                focusNode: isSmokerFocusNode,
                parent: 'hasChronicHealthCondition'),
            ToggleItem(
                name: 'hasDiabetes',
                focusNode: hasDiabetesFocusNode,
                parent: 'hasChronicHealthCondition'),
            ToggleItem(
                name: 'isImmunosuppressed',
                focusNode: isImmunosuppressedFocusNode,
                parent: 'hasChronicHealthCondition'),
            ToggleItem(
                name: 'hasCancer',
                focusNode: hasCancerFocusNode,
                parent: 'hasChronicHealthCondition'),
            ToggleItem(
                name: 'hasHeartDisease',
                focusNode: hasHeartDiseaseFocusNode,
                parent: 'hasChronicHealthCondition'),
            ToggleItem(
                name: 'hasHypertension',
                focusNode: hasHypertensionFocusNode,
                parent: 'hasChronicHealthCondition'),
            ToggleItem(
                name: 'hasChronicLungCondition',
                focusNode: hasChronicLungConditionFocusNode,
                parent: 'hasChronicHealthCondition'),
            ToggleItem(
                name: 'hadStroke',
                focusNode: hadStrokeFocusNode,
                parent: 'hasChronicHealthCondition'),
          ]),
      ToggleItem(name: 'hasSymptoms', focusNode: hasSymptomsFocusNode),
      ToggleItem(name: 'closeToInfected', focusNode: closeToInfectedFocusNode),
      ToggleItem(
          name: 'hasTraveledOutsideCanada',
          focusNode: hasTraveledOutsideCanadaFocusNode),
      ToggleItem(
          name: 'hasCloseContactToOutsideTraveler',
          focusNode: hasCloseContactToOutsideTravelerFocusNode),
      ToggleItem(
          name: 'isHealthcareWorker',
          focusNode: isHealthcareWorkerFocusNode,
          subItems: [
            ToggleItem(
                name: 'workWithInfected',
                focusNode: workWithInfectedFocusNode,
                parent: 'isHealthcareWorkerFocusNode')
          ])
    ];

    toggleItems.forEach((element) {
      choices[element.name] = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  void _handleChoicesChange(String name, bool value) {
    setState(() {
      choices[name] = value;
    });
  }

  @override
  void dispose() {
    hasChronicHealthConditionFocusNode.dispose();
    isSmokerFocusNode.dispose();
    hasDiabetesFocusNode.dispose();
    isImmunosuppressedFocusNode.dispose();
    hasCancerFocusNode.dispose();
    hasHeartDiseaseFocusNode.dispose();
    hasHypertensionFocusNode.dispose();
    hasChronicLungConditionFocusNode.dispose();
    hadStrokeFocusNode.dispose();
    hasSymptomsFocusNode.dispose();
    closeToInfectedFocusNode.dispose();
    hasTraveledOutsideCanadaFocusNode.dispose();
    hasCloseContactToOutsideTravelerFocusNode.dispose();
    isHealthcareWorkerFocusNode.dispose();
    workWithInfectedFocusNode.dispose();

    super.dispose();
  }

  void startWeeklyNotification() async {
    Logger().d("Start weekly notification for self-assessment");

    String title = FlutterI18n.translate(context, "notifications.N006.title");
    String body = FlutterI18n.translate(context, "notifications.N006.body");

    Notifications.createNotification(title, body, "",
        interval: RepeatInterval.Weekly,
        notificationID: Constants.notificationSelfScreenId);
  }

  void _loadSettings() async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    await settingsManager.loadSettings();
    String lang = await settingsManager.getLang();
    setState(() {
      locale = lang;
      healthCheckUpdateDate =
          settingsManager.settings.user_data.healthCheckUpdateDate;

      if (healthCheckUpdateDate != null) {
        choices['hasChronicHealthCondition'] =
            settingsManager.settings.user_data.hasChronicHealthCondition;
        choices['isSmoker'] = settingsManager.settings.user_data.isSmoker;
        choices['hasDiabetes'] = settingsManager.settings.user_data.hasDiabetes;
        choices['isImmunosuppressed'] =
            settingsManager.settings.user_data.isImmunosuppressed;
        choices['hasCancer'] = settingsManager.settings.user_data.hasCancer;
        choices['hasHeartDisease'] =
            settingsManager.settings.user_data.hasHeartDisease;
        choices['hasHypertension'] =
            settingsManager.settings.user_data.hasHypertension;
        choices['hasChronicLungCondition'] =
            settingsManager.settings.user_data.hasChronicLungCondition;
        choices['hasSymptoms'] = settingsManager.settings.user_data.hasSymptoms;
        choices['hadStroke'] = settingsManager.settings.user_data.hadStroke;
        choices['closeToInfected'] =
            settingsManager.settings.user_data.closeToInfected;
        choices['hasTraveledOutsideCanada'] =
            settingsManager.settings.user_data.hasTraveledOutsideCanada;
        choices['hasCloseContactToOutsideTraveler'] =
            settingsManager.settings.user_data.hasCloseContactToOutsideTraveler;
        choices['isHealthcareWorker'] =
            settingsManager.settings.user_data.isHealthcareWorker;
        choices['workWithInfected'] =
            settingsManager.settings.user_data.workWithInfected;
      }

      loaded = true;
    });
  }

  void _manageError(bool condition, FocusNode focusNode) {
    if (condition) {
      if (!errors.contains(focusNode)) {
        errors.add(focusNode);
      }
    } else {
      if (errors.contains(focusNode)) {
        errors.remove(focusNode);
      }
    }
  }

  void _saveSettings() async {
    // Access to our settings manager
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    // Validate the form
    if (_formKey.currentState.validate()) {
      // Assign it to our SettingsData
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

      DateTime now = new DateTime.now();

      Provider.of<RecommendationsProvider>(context, listen: false)
          .updateExceptionExpirationDate();
      settingsManager.settings.user_data.recommendationUpdateDate = now;

      // // Save the settings
      await settingsManager.saveSettings();

      startWeeklyNotification();

      // Go back to the home screen
      Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
    } else {
      FocusScope.of(context).unfocus();
      await setState(() {
        _autovalidate = true;
      });
      errors[0].requestFocus();
    }
  }

  Row _parseUpdatedDate(DateTime date, {bool withIcon = true}) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    String dateString = date.isToday()
        ? "${FlutterI18n.translate(context, "today")}, ${FlutterI18n.translate(context, "at")} ${new intl.DateFormat.jm(locale).format(date)}"
        : new intl.DateFormat.MMMMd(locale).add_y().format(date);
    TextStyle style = TextStyle(
        height: 1,
        color: Color(0xFF62696a),
        fontStyle: FontStyle.italic,
        fontSize: 12 * sizeMultiplier);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (withIcon)
          ExcludeSemantics(
              child: SvgPicture.asset('assets/svg/icon-clock.svg',
                  height: 12 * sizeMultiplier)),
        Text(
            '  ${FlutterI18n.translate(context, "lastUpdated")}: ${dateString}',
            style: style)
      ],
    );
  }

  bool _isFormValid() {
    return _formKey.currentState != null && _formKey.currentState.validate();
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    String cameFrom = ModalRoute.of(context).settings.arguments;

    return GestureDetector(
        onTap: () {
          // Unfocus the age input when tapping outside of it
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: DarkBlueCross(
            backLabel: cameFrom == 'health'
                ? FlutterI18n.translate(context, "screens.health")
                : FlutterI18n.translate(context, "screens.dashboard"),
            contentPadding: EdgeInsets.all(0),
            hasBottomBack: false,
            title: FlutterI18n.translate(context, "actions.healthCheck.title"),
            subtitle:
                FlutterI18n.translate(context, "actions.healthCheck.subtitle"),
            child: !loaded
                ? Container()
                : Form(
                    autovalidate: _autovalidate,
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                            child: Column(
                          children: <Widget>[
                            Divider(height: 34, color: Colors.white),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(children: <Widget>[
                                  Semantics(
                                      label: FlutterI18n.translate(
                                          context, "a11y.header2"),
                                      header: true,
                                      child: Text(
                                        FlutterI18n.translate(context,
                                            "actions.healthCheck.formTitle"),
                                        style: TextStyle(
                                            fontSize: 18 * sizeMultiplier,
                                            fontWeight: FontWeight.bold,
                                            color: Constants.darkBlue),
                                      )),
                                  if (healthCheckUpdateDate != null)
                                    Semantics(
                                        label: FlutterI18n.translate(
                                            context, "a11y.header3"),
                                        header: true,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 8 * sizeMultiplier),
                                            child: _parseUpdatedDate(
                                                healthCheckUpdateDate,
                                                withIcon: false))),
                                  Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      child: Text(
                                          FlutterI18n.translate(context,
                                              "onboarding.userForm.allFieldsMandatory"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 13 * sizeMultiplier,
                                              color: Constants.mediumGrey))),
                                  Divider(height: 32),
                                  for (int i = 0; i < toggleItems.length; i++)
                                    Column(children: <Widget>[
                                      EnsureVisibleWhenFocused(
                                          focusNode: toggleItems[i].focusNode,
                                          child: ToggleFormField(
                                              focusNode:
                                                  toggleItems[i].focusNode,
                                              label: FlutterI18n.translate(
                                                  context,
                                                  "onboarding.userForm." +
                                                      toggleItems[i].name),
                                              autovalidate: _autovalidate,
                                              onPress: (bool value) {
                                                _handleChoicesChange(
                                                    toggleItems[i].name, value);
                                              },
                                              isMoreQuestionsOption:
                                                  toggleItems[i].subItems !=
                                                      null,
                                              status:
                                                  choices[toggleItems[i].name],
                                              validator: (value) {
                                                if (value == null) {
                                                  _manageError(true,
                                                      toggleItems[i].focusNode);
                                                  return '';
                                                }
                                                _manageError(false,
                                                    toggleItems[i].focusNode);
                                                return null;
                                              })),
                                      toggleItems[i].subItems == null &&
                                              i != toggleItems.length - 1
                                          ? Divider(height: 30)
                                          : Container(),
                                      if (toggleItems[i].subItems != null)
                                        ExpandedSection(
                                            expand: choices[
                                                        toggleItems[i].name] ==
                                                    null
                                                ? false
                                                : choices[toggleItems[i].name],
                                            child: Stack(children: <Widget>[
                                              Container(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 15),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          14 * sizeMultiplier,
                                                      horizontal:
                                                          8 * sizeMultiplier),
                                                  decoration: new BoxDecoration(
                                                    color: Constants.lightBlue,
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                      new Radius.circular(15.0),
                                                    ),
                                                  ),
                                                  child: Column(
                                                      children: <Widget>[
                                                        for (var j = 0;
                                                            j <
                                                                toggleItems[i]
                                                                    .subItems
                                                                    .length;
                                                            j++)
                                                          Column(
                                                              children: <
                                                                  Widget>[
                                                                EnsureVisibleWhenFocused(
                                                                    focusNode: toggleItems[
                                                                            i]
                                                                        .subItems[
                                                                            j]
                                                                        .focusNode,
                                                                    child: ToggleFormField(
                                                                        focusNode: toggleItems[i].subItems[j].focusNode,
                                                                        label: FlutterI18n.translate(context, "onboarding.userForm." + toggleItems[i].subItems[j].name),
                                                                        autovalidate: _autovalidate,
                                                                        onPress: (bool value) {
                                                                          _handleChoicesChange(
                                                                              toggleItems[i].subItems[j].name,
                                                                              value);
                                                                        },
                                                                        isSubOption: true,
                                                                        status: choices[toggleItems[i].subItems[j].name],
                                                                        validator: (value) {
                                                                          if (value == null &&
                                                                              choices[toggleItems[i].name] != null &&
                                                                              choices[toggleItems[i].name]) {
                                                                            _manageError(true,
                                                                                toggleItems[i].subItems[j].focusNode);
                                                                            return '';
                                                                          }
                                                                          _manageError(
                                                                              false,
                                                                              toggleItems[i].subItems[j].focusNode);
                                                                          return null;
                                                                        })),
                                                                j != toggleItems[i].subItems.length - 1
                                                                    ? Divider(
                                                                        height:
                                                                            30,
                                                                        color: Colors
                                                                            .white,
                                                                        thickness:
                                                                            1)
                                                                    : Container(),
                                                              ])
                                                      ])),
                                              Positioned(
                                                  top: 0,
                                                  right: 30,
                                                  child: ExcludeSemantics(
                                                      child: SvgPicture.asset(
                                                          "assets/svg/blue-expanded-arrow.svg")))
                                            ])),
                                      toggleItems[i].subItems != null &&
                                              i != toggleItems.length - 1
                                          ? Divider(height: 30)
                                          : Container(),
                                    ])
                                ])),
                          ],
                        )),
                        SaveCancelButtons(
                            margin: EdgeInsets.only(top: 20),
                            isValidToSave: _isFormValid(),
                            onPressedSave: () => _saveSettings(),
                            onPressedCancel: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    ))));
  }
}
