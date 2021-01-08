import 'dart:ui';
import 'package:covi/material/datepickerField.dart';
import 'package:covi/material/ensureVisibleWhenFocused.dart';
import 'package:covi/material/inputFormField.dart';
import 'package:covi/material/saveCancelButtons.dart';
import 'package:covi/services/bluetooth_token_storage_service.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:flutter_rounded_date_picker/src/material_rounded_date_picker_style.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:covi/material/labeledCheckbox.dart';
import 'package:covi/material/contextualBackdrops/darkBlueChecks.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TestResults extends StatefulWidget {
  TestResults({key}) : super(key: key);

  _TestResultsState createState() => _TestResultsState();
}

class _TestResultsState extends State<TestResults> {
  bool loaded = false;
  bool testResultIsPositive;
  bool shareResult = false;
  String locale;

  List<FocusNode> errors = [];

  TextEditingController symptomsStartedDateInputController;
  FocusNode symptomsStartedDateFocusNode;
  DateTime symptomsStartedDate;

  TextEditingController testDateInputController;
  FocusNode testDateFocusNode;
  DateTime testDate;

  FocusNode positiveNegativeFocusNode;

  TextEditingController attestInputController;
  FocusNode attestFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  @override
  void initState() {
    super.initState();

    attestInputController = new TextEditingController();
    attestFocusNode = FocusNode();

    symptomsStartedDateInputController = new TextEditingController();
    symptomsStartedDateFocusNode = new FocusNode();
    testDateInputController = new TextEditingController();
    testDateFocusNode = new FocusNode();
    positiveNegativeFocusNode = new FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    attestInputController.dispose();
    attestFocusNode.dispose();
    symptomsStartedDateInputController.dispose();
    symptomsStartedDateFocusNode.dispose();
    testDateInputController.dispose();
    testDateFocusNode.dispose();
    positiveNegativeFocusNode.dispose();

    super.dispose();
  }

  bool _isFormValid() {
    if (attestInputController.text.toUpperCase() !=
        FlutterI18n.translate(context, 'yes').toUpperCase()) {
      return false;
    }

    if (symptomsStartedDateInputController.text.isEmpty ||
        testDateInputController.text.isEmpty) {
      return false;
    }

    return true;
  }

  void _loadSettings() async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    await settingsManager.loadSettings();
    String lang = await settingsManager.getLang();
    if (settingsManager.settings.user_data.covidTestSymptomsStartedDate != null)
      symptomsStartedDateInputController.text = DateFormat.yMd(locale).format(
          settingsManager.settings.user_data.covidTestSymptomsStartedDate);

    if (settingsManager.settings.user_data.covidTestResultDate != null)
      testDateInputController.text = DateFormat.yMd(locale)
          .format(settingsManager.settings.user_data.covidTestResultDate);

    setState(() {
      locale = lang;
      symptomsStartedDate =
          settingsManager.settings.user_data.covidTestSymptomsStartedDate;
      testDate = settingsManager.settings.user_data.covidTestResultDate;
      testDateInputController = testDateInputController;
      symptomsStartedDateInputController = symptomsStartedDateInputController;
      testResultIsPositive =
          settingsManager.settings.user_data.covidTestResultIsPositive;
      shareResult = settingsManager.settings.shareCovidTestResult == null
          ? false
          : settingsManager.settings.shareCovidTestResult;
      if (testResultIsPositive != null) {
        attestInputController.text = FlutterI18n.translate(context, "yes");
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
    if (_formKey.currentState.validate() && _isFormValid()) {
      // Assign it to our SettingsData
      settingsManager.settings.shareCovidTestResult = shareResult;
      settingsManager.settings.user_data.covidTestResultIsPositive =
          testResultIsPositive;
      settingsManager.settings.user_data.covidTestResultDate = testDate;
      settingsManager.settings.user_data.covidTestSymptomsStartedDate =
          symptomsStartedDate;

      DateTime now = new DateTime.now();
      settingsManager.settings.user_data.testUpdateDate = now;

      Provider.of<RecommendationsProvider>(context, listen: false)
          .updateExceptionExpirationDate();
      settingsManager.settings.user_data.recommendationUpdateDate = now;

      if (testResultIsPositive) {
        DateTime _now = DateTime.now().add(Duration(seconds: 5));
        settingsManager.settings.pushingNextTime = _now;
        settingsManager.settings.user_data.oldSymptomaticRisk =
            settingsManager.settings.user_data.newSymptomaticRisk;
        settingsManager.settings.user_data.newSymptomaticRisk = 0x0F;
      }

      await settingsManager.saveSettings();

      if (testResultIsPositive)
        BluetoothTokenStorageService.updateEncountersRiskFactor();

      // Go back to the home screen
      Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
    } else {
      FocusScope.of(context).unfocus();
      await setState(() {
        _autovalidate = true;

        _manageError(testResultIsPositive == null, positiveNegativeFocusNode);
      });
      errors[0].requestFocus();
    }
  }

  Future _selectSymptomsDate() async {
    DateTime picked = await showRoundedDatePicker(
        locale: new Locale(locale, 'CA'),
        context: context,
        initialDate:
            symptomsStartedDate == null ? DateTime.now() : symptomsStartedDate,
        firstDate: new DateTime(2020),
        lastDate: DateTime.now(),
        theme: ThemeData(
            primaryColor: Constants.darkBlue, accentColor: Constants.yellow),
        styleDatePicker: MaterialRoundedDatePickerStyle(
            textStyleButtonNegative: TextStyle(color: Constants.darkBlue),
            textStyleButtonPositive: TextStyle(color: Constants.darkBlue)));
    if (picked != null) {
      symptomsStartedDateInputController.text =
          DateFormat.yMd(locale).format(picked);

      setState(() {
        symptomsStartedDateInputController = symptomsStartedDateInputController;
        symptomsStartedDate = picked;
      });
    }
  }

  Future _selectTestDateDate() async {
    DateTime picked = await showRoundedDatePicker(
        locale: new Locale(locale, 'CA'),
        context: context,
        initialDate: testDate == null ? DateTime.now() : testDate,
        firstDate: new DateTime(2020),
        lastDate: DateTime.now(),
        theme: ThemeData(
            primaryColor: Constants.darkBlue, accentColor: Constants.yellow),
        styleDatePicker: MaterialRoundedDatePickerStyle(
            textStyleButtonNegative: TextStyle(color: Constants.darkBlue),
            textStyleButtonPositive: TextStyle(color: Constants.darkBlue)));
    if (picked != null) {
      testDateInputController.text = DateFormat.yMd(locale).format(picked);

      setState(() {
        testDateInputController = testDateInputController;
        testDate = picked;
      });
    }
  }

  Widget _choiceButton(String label, value) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    var isChoiceMade = testResultIsPositive != null;
    var isActive = isChoiceMade && testResultIsPositive == value;
    return Container(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.39),
        child: Material(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10)),
            color: isActive ? Constants.mediumBlue : Colors.white,
            child: Semantics(
                label: FlutterI18n.translate(
                        context, "actions.testResult.question") +
                    label +
                    (!isActive
                        ? FlutterI18n.translate(context, "a11y.tapToApply")
                        : ""),
                selected: isActive,
                child: InkWell(
                    onTap: () {
                      setState(() {
                        testResultIsPositive = value;
                      });
                    },
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    splashColor: isActive ? Colors.white12 : Colors.black12,
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0,
                                color: _autovalidate && !isChoiceMade
                                    ? Constants.mediumRed
                                    : Constants.mediumBlue),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: ExcludeSemantics(
                                child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _autovalidate && !isChoiceMade
                                      ? Constants.mediumRed
                                      : (isActive
                                          ? Colors.white
                                          : Constants.mediumBlue),
                                  fontSize: 12 * sizeMultiplier,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.w500),
                            ))))))));
  }

  Widget _generateAttests() {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
          color: Color(0xFFf6f5f2),
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Column(
        children: <Widget>[
          ExcludeSemantics(
            child: Text(
              FlutterI18n.translate(
                      context, 'actions.testResult.acknowledgmentStart') +
                  (testResultIsPositive
                      ? FlutterI18n.translate(
                              context, 'actions.testResult.positive')
                          .toLowerCase()
                      : FlutterI18n.translate(
                              context, 'actions.testResult.negative')
                          .toLowerCase()) +
                  FlutterI18n.translate(
                      context, 'actions.testResult.acknowledgmentEnd'),
              style: TextStyle(
                  color: Constants.darkBlue,
                  fontSize: 12 * sizeMultiplier,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic),
            ),
          ),
          Divider(
            height: 16,
            color: Colors.transparent,
          ),
          Semantics(
              label: FlutterI18n.translate(
                  context, 'actions.testResult.acknowledgment'),
              child: InputFormField(
                  autovalidate: _autovalidate,
                  errorMessage: FlutterI18n.translate(
                      context, 'actions.testResult.acknowledgmentError'),
                  label: FlutterI18n.translate(
                      context, 'actions.testResult.acknowledgmentLabel'),
                  validator: (String value) {
                    if (value.toUpperCase() !=
                        FlutterI18n.translate(context, 'yes').toUpperCase()) {
                      _manageError(true, attestFocusNode);
                      return '';
                    }
                    _manageError(false, attestFocusNode);
                    return null;
                  },
                  focusNode: attestFocusNode,
                  controller: attestInputController)),
        ],
      ),
    );
  }

  Widget _generateMilaShareConsent() {
    return LabeledCheckbox(
        // label: translate('actions.testResult.shareLabel'),
        label: FlutterI18n.translate(context, 'actions.testResult.shareLabel'),
        value: shareResult,
        onChanged: (value) {
          setState(() {
            shareResult = value;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    String cameFrom = ModalRoute.of(context).settings.arguments;

    return DarkBlueChecks(
        backLabel: cameFrom == 'health'
            ? FlutterI18n.translate(context, "screens.health")
            : FlutterI18n.translate(context, "screens.dashboard"),
        contentPadding: EdgeInsets.all(0),
        hasBottomBack: false,
        title: FlutterI18n.translate(context, "actions.testResult.title"),
        subtitle: FlutterI18n.translate(context, "actions.testResult.subtitle"),
        child: !loaded
            ? Container()
            : Form(
                autovalidate: _autovalidate,
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Divider(height: 34, color: Colors.white),
                            Semantics(
                                label: FlutterI18n.translate(
                                    context, "a11y.header2"),
                                header: true,
                                child: Center(
                                    child: Text(
                                  FlutterI18n.translate(
                                      context, "actions.testResult.formTitle"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18 * sizeMultiplier,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.darkBlue),
                                ))),
                            Center(
                              child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Text(
                                      FlutterI18n.translate(context,
                                          "onboarding.userForm.allFieldsMandatory"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13 * sizeMultiplier,
                                          color: Constants.mediumGrey))),
                            ),
                            Divider(height: 32 * sizeMultiplier),
                            EnsureVisibleWhenFocused(
                                focusNode: symptomsStartedDateFocusNode,
                                child: DatepickerField(
                                  label: FlutterI18n.translate(context,
                                      'actions.selfDiagnostic.dateFieldLabel'),
                                  additionalLabel: FlutterI18n.translate(
                                      context,
                                      'actions.testResult.symptomsBeganDateLabel'),
                                  autovalidate: _autovalidate,
                                  controller:
                                      symptomsStartedDateInputController,
                                  focusNode: symptomsStartedDateFocusNode,
                                  onTap: () {
                                    _selectSymptomsDate(); // Call Function that has showDatePicker()
                                  },
                                  validator: (value) {
                                    if (symptomsStartedDate == null) {
                                      _manageError(
                                          true, symptomsStartedDateFocusNode);
                                      return '';
                                    }
                                    _manageError(
                                        false, symptomsStartedDateFocusNode);
                                    return null;
                                  },
                                )),
                            Divider(height: 10, color: Colors.transparent),
                            EnsureVisibleWhenFocused(
                                focusNode: testDateFocusNode,
                                child: DatepickerField(
                                  label: FlutterI18n.translate(context,
                                      'actions.selfDiagnostic.dateFieldLabel'),
                                  additionalLabel: FlutterI18n.translate(
                                      context,
                                      'actions.testResult.testDateLabel'),
                                  autovalidate: _autovalidate,
                                  controller: testDateInputController,
                                  focusNode: testDateFocusNode,
                                  onTap: () {
                                    _selectTestDateDate(); // Call Function that has showDatePicker()
                                  },
                                  validator: (value) {
                                    if (testDate == null) {
                                      _manageError(true, testDateFocusNode);
                                      return '';
                                    }
                                    _manageError(false, testDateFocusNode);
                                    return null;
                                  },
                                )),
                            Divider(height: 10, color: Colors.transparent),
                            ExcludeSemantics(
                                child: Text(
                              FlutterI18n.translate(
                                  context, "actions.testResult.question"),
                              style: TextStyle(
                                  fontSize: 14 * sizeMultiplier,
                                  fontWeight: FontWeight.w500,
                                  color: Constants.darkBlue),
                            )),
                            EnsureVisibleWhenFocused(
                                focusNode: positiveNegativeFocusNode,
                                child: FractionallySizedBox(
                                    widthFactor: 1,
                                    child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            child: Wrap(
                                              runAlignment:
                                                  WrapAlignment.center,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              runSpacing: 8,
                                              children: <Widget>[
                                                _choiceButton(
                                                    FlutterI18n.translate(
                                                            context,
                                                            "actions.testResult.positive")
                                                        .toUpperCase(),
                                                    true),
                                                ExcludeSemantics(
                                                    child: Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8 *
                                                                    sizeMultiplier),
                                                        child: Text(
                                                            FlutterI18n.translate(
                                                                context,
                                                                "actions.testResult.or"),
                                                            style: TextStyle(
                                                                fontSize: 12 *
                                                                    sizeMultiplier)))),
                                                _choiceButton(
                                                    FlutterI18n.translate(
                                                            context,
                                                            "actions.testResult.negative")
                                                        .toUpperCase(),
                                                    false),
                                              ],
                                            ))))),
                            _autovalidate && testResultIsPositive == null
                                ? Container(
                                    padding: EdgeInsets.only(left: 16),
                                    child: Text(
                                        FlutterI18n.translate(
                                            context, 'a11y.pleaseChooseAnswer'),
                                        style:
                                            Constants.CustomTextStyle.red12Text(
                                                context)))
                                : Container(),
                            if (testResultIsPositive != null)
                              _generateAttests(),
                            _generateMilaShareConsent(),
                          ],
                        )),
                    SaveCancelButtons(
                        isValidToSave: _isFormValid(),
                        onPressedSave: () => _saveSettings(),
                        onPressedCancel: () {
                          Navigator.of(context).pop();
                        })
                  ],
                )));
  }
}
