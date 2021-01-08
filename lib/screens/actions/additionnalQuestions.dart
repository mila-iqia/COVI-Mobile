import 'package:covi/material/contextualBackdrops/darkBlueCases.dart';
import 'package:covi/material/datepickerField.dart';
import 'package:covi/material/dropdownFormField.dart';
import 'package:covi/material/ensureVisibleWhenFocused.dart';
import 'package:covi/material/inputFormField.dart';
import 'package:covi/material/toggleFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:flutter_rounded_date_picker/src/material_rounded_date_picker_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/extensions.dart';
import 'package:covi/material/ExpandedSection.dart';
import 'package:covi/material/saveCancelButtons.dart';
import 'package:covi/utils/settings.dart';

class AdditionnalQuestions extends StatefulWidget {
  AdditionnalQuestions({key}) : super(key: key);

  _AdditionnalQuestionsState createState() => _AdditionnalQuestionsState();
}

class _AdditionnalQuestionsState extends State<AdditionnalQuestions> {
  bool loaded = false;
  String locale;

  List<FocusNode> errors = [];
  List<ToggleItem> toggleItems = [];

  DateTime additionalQuestionsUpdateDate;

  FocusNode hasHouseholdContactFocusNode;
  FocusNode hasFewPeopleContactFocusNode;
  FocusNode hasManyPeopleContactFocusNode;
  FocusNode wearMaskAtWorkFocusNode;
  FocusNode workWithProtectiveScreenFocusNode;
  FocusNode washingHandsOutsideFocusNode;
  FocusNode washHandsReturningHomeFocusNode;
  FocusNode takePublicTransportationFocusNode;

  DateTime lastPublicTransportationDate;
  TextEditingController lastPublicTransportationDateController;
  FocusNode lastPublicTransportationDateFocusNode;

  String typeOfPublicTransportation;
  FocusNode typeOfPublicTransportationFocusNode;

  String timesUsingPublicTransit = "";
  TextEditingController timesUsingTransitInputController;
  FocusNode timesUsingTransitFocusNode;

  Map<String, bool> choices = {};

  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Constants.lightGrey,
      nextFocus: false,
      actions: [
        KeyboardAction(focusNode: timesUsingTransitFocusNode, toolbarButtons: [
          (node) {
            return FlatButton(
                padding: EdgeInsets.all(8.0),
                child: Text(FlutterI18n.translate(context, "done"),
                    style: Constants.CustomTextStyle.blue14Text(context)),
                onPressed: () => node.unfocus());
          }
        ])
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    hasHouseholdContactFocusNode = FocusNode();
    hasFewPeopleContactFocusNode = FocusNode();
    hasManyPeopleContactFocusNode = FocusNode();
    wearMaskAtWorkFocusNode = FocusNode();
    workWithProtectiveScreenFocusNode = FocusNode();
    washingHandsOutsideFocusNode = FocusNode();
    washHandsReturningHomeFocusNode = FocusNode();
    takePublicTransportationFocusNode = FocusNode();
    lastPublicTransportationDateController = new TextEditingController();
    lastPublicTransportationDateFocusNode = FocusNode();
    typeOfPublicTransportationFocusNode = FocusNode();
    timesUsingTransitInputController = new TextEditingController();
    timesUsingTransitFocusNode = FocusNode();

    toggleItems = [
      ToggleItem(
          name: 'hasHouseholdContact', focusNode: hasHouseholdContactFocusNode),
      ToggleItem(
          name: 'hasFewPeopleContact', focusNode: hasFewPeopleContactFocusNode),
      ToggleItem(
          name: 'hasManyPeopleContact',
          focusNode: hasManyPeopleContactFocusNode),
      ToggleItem(name: 'wearMaskAtWork', focusNode: wearMaskAtWorkFocusNode),
      ToggleItem(
          name: 'workWithProtectiveScreen',
          focusNode: workWithProtectiveScreenFocusNode),
      ToggleItem(
          name: 'washingHandsOutside', focusNode: washingHandsOutsideFocusNode),
      ToggleItem(
          name: 'washHandsReturningHome',
          focusNode: washHandsReturningHomeFocusNode),
      ToggleItem(
          name: 'takePublicTransportation',
          focusNode: takePublicTransportationFocusNode),
    ];

    toggleItems.forEach((element) {
      choices[element.name] = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSettings();
    });
  }

  void _handleChoicesChange(String name, bool value) {
    setState(() {
      choices[name] = value;
    });
  }

  @override
  void dispose() {
    hasHouseholdContactFocusNode.dispose();
    hasFewPeopleContactFocusNode.dispose();
    hasManyPeopleContactFocusNode.dispose();
    wearMaskAtWorkFocusNode.dispose();
    workWithProtectiveScreenFocusNode.dispose();
    washingHandsOutsideFocusNode.dispose();
    washHandsReturningHomeFocusNode.dispose();
    takePublicTransportationFocusNode.dispose();
    typeOfPublicTransportationFocusNode.dispose();
    timesUsingTransitInputController.dispose();
    timesUsingTransitFocusNode.dispose();

    super.dispose();
  }

  void _loadSettings() async {
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    await settingsManager.loadSettings();
    String lang = await settingsManager.getLang();

    setState(() {
      locale = lang;
      additionalQuestionsUpdateDate =
          settingsManager.settings.user_data.additionalQuestionsUpdateDate;
      choices['hasHouseholdContact'] =
          settingsManager.settings.user_data.hasHouseholdContact;
      choices['hasFewPeopleContact'] =
          settingsManager.settings.user_data.hasFewPeopleContact;
      choices['hasManyPeopleContact'] =
          settingsManager.settings.user_data.hasManyPeopleContact;
      choices['wearMaskAtWork'] =
          settingsManager.settings.user_data.wearMaskAtWork;
      choices['workWithProtectiveScreen'] =
          settingsManager.settings.user_data.workWithProtectiveScreen;
      choices['washingHandsOutside'] =
          settingsManager.settings.user_data.washingHandsOutside;
      choices['washHandsReturningHome'] =
          settingsManager.settings.user_data.washHandsReturningHome;
      choices['takePublicTransportation'] =
          settingsManager.settings.user_data.takePublicTransportation;
      lastPublicTransportationDate =
          settingsManager.settings.user_data.lastPublicTransportationDate;
      lastPublicTransportationDateController.text = settingsManager
                  .settings.user_data.lastPublicTransportationDate ==
              null
          ? null
          : DateFormat.yMd(locale).format(
              settingsManager.settings.user_data.lastPublicTransportationDate);
      typeOfPublicTransportation =
          settingsManager.settings.user_data.typeOfPublicTransportation;
      timesUsingTransitInputController.text =
          settingsManager.settings.user_data.timesUsingPublicTransit == null
              ? ""
              : settingsManager.settings.user_data.timesUsingPublicTransit
                  .toString();
      timesUsingPublicTransit =
          settingsManager.settings.user_data.timesUsingPublicTransit.toString();

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
      settingsManager.settings.user_data.additionalQuestionsUpdateDate =
          new DateTime.now();
      settingsManager.settings.user_data.hasHouseholdContact =
          choices['hasHouseholdContact'];
      settingsManager.settings.user_data.hasFewPeopleContact =
          choices['hasFewPeopleContact'];
      settingsManager.settings.user_data.hasManyPeopleContact =
          choices['hasManyPeopleContact'];
      settingsManager.settings.user_data.wearMaskAtWork =
          choices['wearMaskAtWork'];
      settingsManager.settings.user_data.workWithProtectiveScreen =
          choices['workWithProtectiveScreen'];
      settingsManager.settings.user_data.washingHandsOutside =
          choices['washingHandsOutside'];
      settingsManager.settings.user_data.washHandsReturningHome =
          choices['washHandsReturningHome'];
      settingsManager.settings.user_data.takePublicTransportation =
          choices['takePublicTransportation'];
      settingsManager.settings.user_data.lastPublicTransportationDate =
          choices['takePublicTransportation']
              ? lastPublicTransportationDate
              : null;
      settingsManager.settings.user_data.typeOfPublicTransportation =
          choices['takePublicTransportation']
              ? typeOfPublicTransportation
              : null;
      settingsManager.settings.user_data.timesUsingPublicTransit =
          choices['takePublicTransportation'] &&
                  !timesUsingTransitInputController.text.isEmpty
              ? int.parse(timesUsingTransitInputController.text)
              : null;

      // // Save the settings
      await settingsManager.saveSettings();

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

  bool _isFormValid() {
    return _formKey.currentState != null && _formKey.currentState.validate();
  }

  Future _selectLastTransportationDate() async {
    DateTime picked = await showRoundedDatePicker(
        locale: new Locale(locale, 'CA'),
        context: context,
        initialDate: lastPublicTransportationDate == null
            ? DateTime.now()
            : lastPublicTransportationDate,
        firstDate: new DateTime(2020),
        lastDate: DateTime.now(),
        theme: ThemeData(
            primaryColor: Constants.darkBlue, accentColor: Constants.yellow),
        styleDatePicker: MaterialRoundedDatePickerStyle(
            textStyleButtonNegative: TextStyle(color: Constants.darkBlue),
            textStyleButtonPositive: TextStyle(color: Constants.darkBlue)));
    if (picked != null) {
      setState(() {
        lastPublicTransportationDateController.text =
            DateFormat.yMd(locale).format(picked);
        lastPublicTransportationDate = picked;
      });
    }
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
        child: DarkBlueCases(
            backLabel: cameFrom == 'health'
                ? FlutterI18n.translate(context, "screens.health")
                : FlutterI18n.translate(context, "screens.dashboard"),
            keyboardBuildConfig: _buildConfig(context),
            contentPadding: EdgeInsets.all(0),
            hasBottomBack: false,
            title: FlutterI18n.translate(
                context, "actions.additionnalQuestions.title"),
            subtitle: FlutterI18n.translate(
                context, "actions.additionnalQuestions.subtitle"),
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
                            Divider(height: 34, color: Colors.transparent),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(children: <Widget>[
                                  if (additionalQuestionsUpdateDate != null)
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 8 * sizeMultiplier),
                                        child: _parseUpdatedDate(
                                            additionalQuestionsUpdateDate,
                                            withIcon: false)),
                                  Container(
                                      child: Text(
                                          FlutterI18n.translate(context,
                                              "onboarding.userForm.allFieldsMandatory"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 13 * sizeMultiplier,
                                              color: Constants.mediumGrey))),
                                  Divider(height: 32),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        FlutterI18n.translate(context,
                                            "actions.additionnalQuestions.atWorkContact"),
                                        style: Constants.CustomTextStyle
                                                .darkBlue18Text(context)
                                            .merge(TextStyle(
                                                fontSize: 14 * sizeMultiplier,
                                                fontWeight: FontWeight.w500))),
                                  ),
                                  for (int i = 0; i < toggleItems.length; i++)
                                    Column(children: <Widget>[
                                      EnsureVisibleWhenFocused(
                                          focusNode: toggleItems[i].focusNode,
                                          child: ToggleFormField(
                                              focusNode:
                                                  toggleItems[i].focusNode,
                                              label: FlutterI18n.translate(
                                                  context,
                                                  "actions.additionnalQuestions." +
                                                      toggleItems[i].name),
                                              autovalidate: _autovalidate,
                                              onPress: (bool value) {
                                                _handleChoicesChange(
                                                    toggleItems[i].name, value);
                                              },
                                              isMoreQuestionsOption:
                                                  toggleItems[i].name ==
                                                      "takePublicTransportation",
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
                                      i != toggleItems.length - 1
                                          ? Divider(
                                              height: 30,
                                              color: toggleItems[i].name !=
                                                          "hasHouseholdContact" &&
                                                      toggleItems[i].name !=
                                                          "hasFewPeopleContact"
                                                  ? Color(0x1f000000)
                                                  : Colors.transparent)
                                          : Container()
                                    ])
                                ])),
                            Divider(height: 4, color: Colors.white),
                            ExpandedSection(
                                expand:
                                    choices['takePublicTransportation'] == null
                                        ? false
                                        : choices['takePublicTransportation'],
                                child: Stack(children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(
                                          left: 8, right: 8, top: 15),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 10),
                                      decoration: new BoxDecoration(
                                        color: Constants.lightBlue,
                                        borderRadius: new BorderRadius.all(
                                          new Radius.circular(15.0),
                                        ),
                                      ),
                                      child: Column(children: <Widget>[
                                        DatepickerField(
                                          label: FlutterI18n.translate(context,
                                              'actions.selfDiagnostic.dateFieldLabel'),
                                          additionalLabel: FlutterI18n.translate(
                                              context,
                                              'actions.additionnalQuestions.lastPublicTransportation'),
                                          autovalidate: _autovalidate,
                                          controller:
                                              lastPublicTransportationDateController,
                                          focusNode:
                                              lastPublicTransportationDateFocusNode,
                                          onTap: () {
                                            _selectLastTransportationDate(); // Call Function that has showDatePicker()
                                          },
                                          validator: (value) {
                                            if (lastPublicTransportationDate ==
                                                    null &&
                                                choices['takePublicTransportation'] !=
                                                    null &&
                                                choices[
                                                    'takePublicTransportation']) {
                                              _manageError(true,
                                                  lastPublicTransportationDateFocusNode);
                                              return '';
                                            }
                                            _manageError(false,
                                                lastPublicTransportationDateFocusNode);
                                            return null;
                                          },
                                        ),
                                        Divider(
                                            height: 14,
                                            color: Colors.transparent),
                                        DropdownFormField(
                                            autovalidate: _autovalidate,
                                            additionalLabel: FlutterI18n.translate(
                                                context,
                                                "actions.additionnalQuestions.typeOfPublicTransportation"),
                                            value: typeOfPublicTransportation,
                                            errorMessage: FlutterI18n.translate(
                                                context,
                                                "actions.additionnalQuestions.typeOfPublicTransportationError"),
                                            onChanged: (String newValue) {
                                              setState(() {
                                                typeOfPublicTransportation =
                                                    newValue;
                                              });
                                            },
                                            focusNode:
                                                typeOfPublicTransportationFocusNode,
                                            validator: (value) {
                                              if (value == null &&
                                                  choices['takePublicTransportation'] !=
                                                      null &&
                                                  choices[
                                                      'takePublicTransportation']) {
                                                _manageError(true,
                                                    typeOfPublicTransportationFocusNode);
                                                return '';
                                              }
                                              _manageError(false,
                                                  typeOfPublicTransportationFocusNode);
                                              return null;
                                            },
                                            options: <DropdownItem>[
                                              DropdownItem(
                                                  FlutterI18n.translate(context,
                                                      'actions.additionnalQuestions.bus'),
                                                  'bus'),
                                              DropdownItem(
                                                  FlutterI18n.translate(context,
                                                      'actions.additionnalQuestions.metro'),
                                                  'metro'),
                                              DropdownItem(
                                                  FlutterI18n.translate(context,
                                                      'actions.additionnalQuestions.train'),
                                                  'train'),
                                              DropdownItem(
                                                  FlutterI18n.translate(context,
                                                      'actions.additionnalQuestions.taxiRideSharing'),
                                                  'taxiRideSharing')
                                            ],
                                            hint: FlutterI18n.translate(
                                                context, 'selectAnswer')),
                                        Divider(
                                            height: 30,
                                            color: Colors.transparent),
                                        InputFormField(
                                          autovalidate: _autovalidate,
                                          label: FlutterI18n.translate(
                                              context, 'yourAnswer'),
                                          additionalLabel: FlutterI18n.translate(
                                              context,
                                              'actions.additionnalQuestions.timeUsingPublicTransit'),
                                          onChanged: (value) {
                                            setState(() {
                                              timesUsingPublicTransit = value;
                                            });
                                          },
                                          inputFormatters: <TextInputFormatter>[
                                            WhitelistingTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(2)
                                          ],
                                          focusNode: timesUsingTransitFocusNode,
                                          controller:
                                              timesUsingTransitInputController,
                                          errorMessage: FlutterI18n.translate(
                                              context,
                                              "actions.additionnalQuestions.inputFieldError"),
                                          validator: (value) {
                                            if (value.isEmpty &&
                                                choices['takePublicTransportation'] !=
                                                    null &&
                                                choices[
                                                    'takePublicTransportation']) {
                                              _manageError(true,
                                                  timesUsingTransitFocusNode);
                                              return '';
                                            }
                                            _manageError(false,
                                                timesUsingTransitFocusNode);
                                            return null;
                                          },
                                          keyboardType: TextInputType.number,
                                        ),
                                      ])),
                                  Positioned(
                                      top: 0,
                                      right: 30,
                                      child: ExcludeSemantics(
                                          child: SvgPicture.asset(
                                              "assets/svg/blue-expanded-arrow.svg")))
                                ]))
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
