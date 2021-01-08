import 'package:covi/material/ensureVisibleWhenFocused.dart';
import 'package:covi/material/radioFormFields.dart';
import 'package:covi/material/toggleFormField.dart';

import 'package:covi/utils/notifications.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:flutter/material.dart';
import 'package:covi/material/datepickerField.dart';
import 'package:covi/material/labeledCheckbox.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:flutter_rounded_date_picker/src/material_rounded_date_picker_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:covi/material/contextualBackdrops/darkBlueHand.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/extensions.dart';
import 'package:covi/material/ExpandedSection.dart';
import 'package:covi/material/saveCancelButtons.dart';
import 'package:covi/utils/settings.dart';

class SelfDiagnostic extends StatefulWidget {
  SelfDiagnostic({key}) : super(key: key);

  _SelfDiagnosticState createState() => _SelfDiagnosticState();
}

class _SelfDiagnosticState extends State<SelfDiagnostic> {
  bool hasNewSymptoms;
  FocusNode hasNewSymptomsFocusNode;

  TextEditingController dateInputController;
  FocusNode dateFocusNode;

  String locale;
  String breathingDifficultySeverity;
  FocusNode breathingDifficultyFocusNode;

  DateTime symptomsUpdateDate;
  DateTime hasSymptomsSince;

  List<FocusNode> errors = [];

  Map<String, bool> symptoms = {
    'hasDifficultyBreathing': false,
    'severeChestPain': false,
    'hardTimeWakingUp': false,
    'feelingConfused': false,
    'lostConsciousness': false,
    'lossOfSmell': false,
    'lossOfAppetite': false,
    'sneezing': false,
    'fever': false,
    'cough': false,
    'muscleAches': false,
    'fatigue': false,
    'headaches': false,
    'soreThroat': false,
    'runnyNose': false,
    'nausea': false,
    'diarrhea': false,
    'chills': false,
  };

  Map<String, bool> symptomsWereEntered = {
    'hasDifficultyBreathing': false,
    'severeChestPain': false,
    'hardTimeWakingUp': false,
    'feelingConfused': false,
    'lostConsciousness': false,
    'lossOfSmell': false,
    'lossOfAppetite': false,
    'sneezing': false,
    'fever': false,
    'cough': false,
    'muscleAches': false,
    'fatigue': false,
    'headaches': false,
    'soreThroat': false,
    'runnyNose': false,
    'nausea': false,
    'diarrhea': false,
    'chills': false,
  };

  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  @override
  void initState() {
    super.initState();

    hasNewSymptomsFocusNode = new FocusNode();

    dateInputController = new TextEditingController();
    dateFocusNode = new FocusNode();

    breathingDifficultyFocusNode = new FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    hasNewSymptomsFocusNode.dispose();

    dateInputController.dispose();
    dateFocusNode.dispose();

    breathingDifficultyFocusNode.dispose();

    super.dispose();
  }

  void startNotification() async {
    // we want notifications for the first two weeks only,
    // check if any symptoms notifications are already planned, if some are planned, don't do anything!
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);
    List<PendingNotificationRequest> pendingNotifications =
        await Notifications.listNotifications();
    if (pendingNotifications.any((element) =>
        element.id >= Constants.notificationSymptomsId &&
        element.id <
            Constants.notificationSymptomsId + Constants.notificationsRange))
      return;

    Logger().d("Start notification for symptoms");

    DateTime now = new DateTime.now();

    String title = FlutterI18n.translate(context, "notifications.N003.title");
    String body = FlutterI18n.translate(context, "notifications.N003.body",
        translationParams: {
          "days": now
              .difference(settingsManager.settings.user_data.hasSymptomsSince)
              .inDays
              .toString()
        });

    // create notifications for the next 14 days
    for (int i = 1; i <= 7; i++) {
      Notifications.createNotification(title, body, "",
          when: new Duration(days: i * 2),
          notificationID: Constants.notificationSymptomsId + i);
    }
  }

  void _loadSettings() async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    await settingsManager.loadSettings();
    String lang = await settingsManager.getLang();
    setState(() {
      locale = lang;
      symptomsUpdateDate =
          settingsManager.settings.user_data.symptomsUpdateDate;
      breathingDifficultySeverity =
          settingsManager.settings.user_data.breathingDifficultySeverity;
      dateInputController = dateInputController;

      symptoms['hasDifficultyBreathing'] =
          settingsManager.settings.user_data.hasDifficultyBreathing;
      symptoms['severeChestPain'] =
          settingsManager.settings.user_data.severeChestPain;
      symptoms['hardTimeWakingUp'] =
          settingsManager.settings.user_data.hardTimeWakingUp;
      symptoms['feelingConfused'] =
          settingsManager.settings.user_data.feelingConfused;
      symptoms['lostConsciousness'] =
          settingsManager.settings.user_data.lostConsciousness;
      symptoms['lossOfSmell'] = settingsManager.settings.user_data.lossOfSmell;
      symptoms['lossOfAppetite'] =
          settingsManager.settings.user_data.lossOfAppetite;
      symptoms['sneezing'] = settingsManager.settings.user_data.sneezing;
      symptoms['fever'] = settingsManager.settings.user_data.fever;
      symptoms['cough'] = settingsManager.settings.user_data.cough;
      symptoms['muscleAches'] = settingsManager.settings.user_data.muscleAches;
      symptoms['fatigue'] = settingsManager.settings.user_data.fatigue;
      symptoms['headaches'] = settingsManager.settings.user_data.headaches;
      symptoms['soreThroat'] = settingsManager.settings.user_data.soreThroat;
      symptoms['runnyNose'] = settingsManager.settings.user_data.runnyNose;
      symptoms['nausea'] = settingsManager.settings.user_data.nausea;
      symptoms['diarrhea'] = settingsManager.settings.user_data.diarrhea;
      symptoms['chills'] = settingsManager.settings.user_data.chills;

      symptomsWereEntered['hasDifficultyBreathing'] =
          settingsManager.settings.user_data.hasDifficultyBreathing;
      symptomsWereEntered['severeChestPain'] =
          settingsManager.settings.user_data.severeChestPain;
      symptomsWereEntered['hardTimeWakingUp'] =
          settingsManager.settings.user_data.hardTimeWakingUp;
      symptomsWereEntered['feelingConfused'] =
          settingsManager.settings.user_data.feelingConfused;
      symptomsWereEntered['lostConsciousness'] =
          settingsManager.settings.user_data.lostConsciousness;
      symptomsWereEntered['lossOfSmell'] =
          settingsManager.settings.user_data.lossOfSmell;
      symptomsWereEntered['lossOfAppetite'] =
          settingsManager.settings.user_data.lossOfAppetite;
      symptomsWereEntered['sneezing'] =
          settingsManager.settings.user_data.sneezing;
      symptomsWereEntered['fever'] = settingsManager.settings.user_data.fever;
      symptomsWereEntered['cough'] = settingsManager.settings.user_data.cough;
      symptomsWereEntered['muscleAches'] =
          settingsManager.settings.user_data.muscleAches;
      symptomsWereEntered['fatigue'] =
          settingsManager.settings.user_data.fatigue;
      symptomsWereEntered['headaches'] =
          settingsManager.settings.user_data.headaches;
      symptomsWereEntered['soreThroat'] =
          settingsManager.settings.user_data.soreThroat;
      symptomsWereEntered['runnyNose'] =
          settingsManager.settings.user_data.runnyNose;
      symptomsWereEntered['nausea'] = settingsManager.settings.user_data.nausea;
      symptomsWereEntered['diarrhea'] =
          settingsManager.settings.user_data.diarrhea;
      symptomsWereEntered['chills'] = settingsManager.settings.user_data.chills;
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
      settingsManager.settings.user_data.hasSymptoms = hasNewSymptoms;
      if (hasNewSymptoms) {
        settingsManager.settings.user_data.hasSymptomsSince = hasSymptomsSince;
      }
      settingsManager.settings.user_data.hasDifficultyBreathing =
          breathingDifficultySeverity == null
              ? false
              : symptoms['hasDifficultyBreathing'];
      settingsManager.settings.user_data.breathingDifficultySeverity =
          symptoms['hasDifficultyBreathing']
              ? breathingDifficultySeverity
              : null;
      settingsManager.settings.user_data.severeChestPain =
          symptoms['severeChestPain'];
      settingsManager.settings.user_data.hardTimeWakingUp =
          symptoms['hardTimeWakingUp'];
      settingsManager.settings.user_data.feelingConfused =
          symptoms['feelingConfused'];
      settingsManager.settings.user_data.lostConsciousness =
          symptoms['lostConsciousness'];
      settingsManager.settings.user_data.lossOfSmell = symptoms['lossOfSmell'];
      settingsManager.settings.user_data.lossOfAppetite =
          symptoms['lossOfAppetite'];
      settingsManager.settings.user_data.sneezing = symptoms['sneezing'];
      settingsManager.settings.user_data.fever = symptoms['fever'];
      settingsManager.settings.user_data.cough = symptoms['cough'];
      settingsManager.settings.user_data.muscleAches = symptoms['muscleAches'];
      settingsManager.settings.user_data.fatigue = symptoms['fatigue'];
      settingsManager.settings.user_data.headaches = symptoms['headaches'];
      settingsManager.settings.user_data.soreThroat = symptoms['soreThroat'];
      settingsManager.settings.user_data.runnyNose = symptoms['runnyNose'];
      settingsManager.settings.user_data.nausea = symptoms['nausea'];
      settingsManager.settings.user_data.diarrhea = symptoms['diarrhea'];
      settingsManager.settings.user_data.chills = symptoms['chills'];

      DateTime now = new DateTime.now();
      settingsManager.settings.user_data.symptomsUpdateDate = now;

      Provider.of<RecommendationsProvider>(context, listen: false)
          .updateExceptionExpirationDate();
      settingsManager.settings.user_data.recommendationUpdateDate = now;

      // // Save the settings
      await settingsManager.saveSettings();

      if (settingsManager.settings.user_data.hasSymptomsSince != null) {
        startNotification();
      }

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
        ? "${FlutterI18n.translate(context, "today")}, ${FlutterI18n.translate(context, "at")} ${new DateFormat.jm(locale).format(date)}"
        : new DateFormat.MMMMd(locale).add_y().format(date);
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

  Future _selectDate() async {
    DateTime picked = await showRoundedDatePicker(
        locale: new Locale(locale, 'CA'),
        context: context,
        initialDate: hasSymptomsSince == null ||
                (hasNewSymptoms == null || !hasNewSymptoms)
            ? DateTime.now()
            : hasSymptomsSince,
        firstDate: new DateTime(2020),
        lastDate: DateTime.now(),
        theme: ThemeData(
            primaryColor: Constants.darkBlue, accentColor: Constants.yellow),
        styleDatePicker: MaterialRoundedDatePickerStyle(
            textStyleButtonNegative: TextStyle(color: Constants.darkBlue),
            textStyleButtonPositive: TextStyle(color: Constants.darkBlue)));
    if (picked != null) {
      var date = DateTime.parse(picked.toIso8601String());
      dateInputController.text = DateFormat.yMd(locale).format(date);

      setState(() {
        dateInputController = dateInputController;
        hasSymptomsSince = picked;
      });
    }
  }

  void _handleSymptomChange(String name, bool value) {
    setState(() {
      symptoms[name] = value;
    });
  }

  bool _isFormValid() {
    return _formKey.currentState != null && _formKey.currentState.validate();
  }

  Widget _generateSeverityList() {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(height: 0),
        Padding(
            padding: EdgeInsets.only(left: 21, right: 21, top: 13),
            child: Text(
                FlutterI18n.translate(context,
                    'actions.selfDiagnostic.difficultyBreathingChoicesHeader'),
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 14 * sizeMultiplier,
                    height: 1.3,
                    color: Constants.darkBlue,
                    fontWeight: FontWeight.bold))),
        RadioFormFields(
            initialValue: breathingDifficultySeverity,
            autovalidate: _autovalidate,
            groupLabel: FlutterI18n.translate(
                    context, 'actions.selfDiagnostic.difficultyBreathing') +
                FlutterI18n.translate(context,
                    'actions.selfDiagnostic.difficultyBreathingChoicesHeader'),
            validator: (value) {
              if (value == null &&
                  symptoms['hasDifficultyBreathing'] != null &&
                  symptoms['hasDifficultyBreathing']) {
                _manageError(true, breathingDifficultyFocusNode);
                return '';
              }
              _manageError(false, breathingDifficultyFocusNode);
              return null;
            },
            items: [
              RadioItem(
                  value: "light",
                  label: FlutterI18n.translate(
                      context, 'actions.selfDiagnostic.lightChoiceLabel'),
                  sublabel: FlutterI18n.translate(
                      context, 'actions.selfDiagnostic.lightChoiceDescription'),
                  onChanged: (String value) {
                    setState(() {
                      breathingDifficultySeverity = value;
                    });
                  }),
              RadioItem(
                  value: "moderate",
                  label: FlutterI18n.translate(
                      context, 'actions.selfDiagnostic.moderateChoiceLabel'),
                  sublabel: FlutterI18n.translate(context,
                      'actions.selfDiagnostic.moderateChoiceDescription'),
                  onChanged: (String value) {
                    setState(() {
                      breathingDifficultySeverity = value;
                    });
                  }),
              RadioItem(
                  value: "heavy",
                  label: FlutterI18n.translate(
                      context, 'actions.selfDiagnostic.heavyChoiceLabel'),
                  sublabel: FlutterI18n.translate(
                      context, 'actions.selfDiagnostic.heavyChoiceDescription'),
                  onChanged: (String value) {
                    setState(() {
                      breathingDifficultySeverity = value;
                    });
                  })
            ])
      ],
    );
  }

  List<Widget> _generateSymptomsList(isStillValidForm) {
    List<Widget> list = new List<Widget>();
    symptoms.keys.forEach((key) {
      if (key != 'hasDifficultyBreathing' &&
          ((symptomsWereEntered[key] && isStillValidForm) ||
              ((!symptomsWereEntered[key] && !isStillValidForm)))) {
        list.add(Container(
            margin: EdgeInsets.only(top: 9),
            decoration: BoxDecoration(
                color: Color(0xFFf6f5f2),
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            child: LabeledCheckbox(
                padding: EdgeInsets.only(top: 6, bottom: 6, right: 6, left: 0),
                label: FlutterI18n.translate(
                    context, 'actions.selfDiagnostic.${key}'),
                value: symptoms[key],
                onChanged: (value) {
                  _handleSymptomChange(key, value);
                })));
      }
    });
    return list;
  }

  Widget _generateSymptomsForm({isStillValidForm = false}) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isStillValidForm && symptomsWereEntered.containsValue(true)) ...[
          Divider(height: 24 * sizeMultiplier),
          Text(
            FlutterI18n.translate(
                context, 'actions.selfDiagnostic.stillSymptomsTitle'),
            style: TextStyle(
                color: Constants.darkBlue,
                fontWeight: FontWeight.w500,
                fontSize: 14 * sizeMultiplier),
          ),
          Divider(color: Constants.transparent, height: 8 * sizeMultiplier),
          Text(
            FlutterI18n.translate(
                context, 'actions.selfDiagnostic.stillSymptomsSubtitle'),
            style: TextStyle(
                color: Color(0xFF62696a), fontSize: 12 * sizeMultiplier),
          ),
          Divider(color: Constants.transparent, height: 16 * sizeMultiplier),
        ],
        if (!isStillValidForm) ...[
          Divider(height: 36),
          EnsureVisibleWhenFocused(
            focusNode: dateFocusNode,
            child: DatepickerField(
              label: FlutterI18n.translate(
                  context, 'actions.selfDiagnostic.dateFieldLabel'),
              additionalLabel: FlutterI18n.translate(
                  context, 'actions.selfDiagnostic.dateFieldHeader'),
              autovalidate: _autovalidate,
              controller: dateInputController,
              focusNode: dateFocusNode,
              onTap: () {
                _selectDate();
              },
              validator: (value) {
                if (hasSymptomsSince == null &&
                    hasNewSymptoms != null &&
                    hasNewSymptoms) {
                  _manageError(true, dateFocusNode);
                  return '';
                }
                _manageError(false, dateFocusNode);
                return null;
              },
            ),
          ),
          Divider(height: 30),
          Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                  FlutterI18n.translate(
                      context, 'actions.selfDiagnostic.newSymptomsTitle'),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 14 * sizeMultiplier,
                      height: 1.3,
                      color: Constants.darkBlue,
                      fontWeight: FontWeight.w500))),
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              FlutterI18n.translate(
                  context, "actions.selfDiagnostic.newSymptomsSubtitle"),
              style: TextStyle(
                  color: Color(0xFF62696a), fontSize: 12 * sizeMultiplier),
            ),
          ),
        ],
        if ((symptomsWereEntered['hasDifficultyBreathing'] &&
                isStillValidForm) ||
            ((!symptomsWereEntered['hasDifficultyBreathing'] &&
                !isStillValidForm)))
          Container(
              decoration: BoxDecoration(
                  color: Color(0xFFf6f5f2),
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
              child: EnsureVisibleWhenFocused(
                  focusNode: breathingDifficultyFocusNode,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        LabeledCheckbox(
                            focusNode: breathingDifficultyFocusNode,
                            padding: EdgeInsets.fromLTRB(0, 6, 6, 6),
                            label: FlutterI18n.translate(context,
                                'actions.selfDiagnostic.difficultyBreathing'),
                            value: symptoms['hasDifficultyBreathing'],
                            onChanged: (value) {
                              setState(() {
                                symptoms['hasDifficultyBreathing'] = value;
                              });
                            }),
                        ExpandedSection(
                            expand: symptoms['hasDifficultyBreathing'],
                            child: _generateSeverityList())
                      ]))),
        ..._generateSymptomsList(isStillValidForm),
      ],
    );
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
        child: DarkBlueHand(
            backLabel: cameFrom == 'health'
                ? FlutterI18n.translate(context, "screens.health")
                : FlutterI18n.translate(context, "screens.dashboard"),
            contentPadding: EdgeInsets.all(0),
            hasBottomBack: false,
            title:
                FlutterI18n.translate(context, "actions.selfDiagnostic.title"),
            subtitle: FlutterI18n.translate(
                context, "actions.selfDiagnostic.subtitle"),
            child: Form(
                autovalidate: _autovalidate,
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: <Widget>[
                            Divider(height: 34, color: Colors.white),
                            Semantics(
                                label: FlutterI18n.translate(
                                    context, "a11y.header2"),
                                header: true,
                                child: Text(
                                  FlutterI18n.translate(context,
                                      "actions.selfDiagnostic.formTitle"),
                                  style: TextStyle(
                                      fontSize: 18 * sizeMultiplier,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.darkBlue),
                                )),
                            if (symptomsUpdateDate != null)
                              Semantics(
                                  label: FlutterI18n.translate(
                                      context, "a11y.header3"),
                                  header: true,
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 8 * sizeMultiplier),
                                      child: _parseUpdatedDate(
                                          symptomsUpdateDate,
                                          withIcon: false))),
                            if (symptomsUpdateDate != null)
                              _generateSymptomsForm(isStillValidForm: true),
                            Divider(height: 40),
                            EnsureVisibleWhenFocused(
                                focusNode: hasNewSymptomsFocusNode,
                                child: ToggleFormField(
                                    focusNode: hasNewSymptomsFocusNode,
                                    label: FlutterI18n.translate(context,
                                        "actions.selfDiagnostic.symptomsLabel"),
                                    autovalidate: _autovalidate,
                                    onPress: (bool value) {
                                      setState(() {
                                        hasNewSymptoms = value;
                                      });
                                    },
                                    isMoreQuestionsOption: true,
                                    status: hasNewSymptoms,
                                    validator: (value) {
                                      if (value == null) {
                                        _manageError(
                                            true, hasNewSymptomsFocusNode);
                                        return '';
                                      }
                                      _manageError(
                                          false, hasNewSymptomsFocusNode);
                                      return null;
                                    })),
                            ExpandedSection(
                                expand:
                                    (hasNewSymptoms != null && hasNewSymptoms),
                                child: _generateSymptomsForm())
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

  FlutterLocalNotificationsPlugin() {}
}
