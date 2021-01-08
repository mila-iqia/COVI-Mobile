import 'package:covi/material/customButton.dart';
import 'package:covi/utils/constants.dart';
import 'package:covi/utils/notifications.dart';
import 'package:covi/utils/permissions.dart';
import 'package:covi/material/stepperCoviButtons.dart';
import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:covi/material/stepperCovi.dart';
import 'package:covi/screens/onboarding/userForm.dart';
import 'package:covi/screens/onboarding/permissions.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({key}) : super(key: key);

  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  FocusNode ageFocusNode;

  @protected
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ageFocusNode = FocusNode();
    setState(() {
      keyboardListenEventId = KeyboardVisibilityNotification().addNewListener(
        onChange: (bool visible) {
          setState(() {
            isKeyboardUp = visible;
          });
        },
      );
    });
  }

  @override
  void dispose() {
    ageFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    KeyboardVisibilityNotification().removeListener(keyboardListenEventId);
    super.dispose();
  }

  int keyboardListenEventId;
  bool isKeyboardUp = false;
  int activeStepIndex = 0;
  bool isStepValid = false;

  bool userAllowedPermissions = true;
  bool askedForPermission = false;

  bool _isStepActive(int index) {
    return activeStepIndex == index;
  }

  StepState _stepState(int index) {
    if (activeStepIndex == index) {
      return StepState.indexed;
    } else if (activeStepIndex > index) {
      return StepState.complete;
    } else {
      return StepState.disabled;
    }
  }

  void setIsStepValid(bool validity) {
    setState(() {
      isStepValid = validity;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Check for permissions again when going back to the app
    if (state == AppLifecycleState.resumed && activeStepIndex == 1) {
      bool permissionsGranted = await PermissionsManager.checkPermissions();

      if (permissionsGranted) {
        setState(() {
          isStepValid = false;
          userAllowedPermissions = true;
          askedForPermission = false;
        });
      } else {
        bool permGranted = await PermissionsManager.requestPermissions();

        setState(() {
          userAllowedPermissions = permGranted;
          askedForPermission = true;
        });
      }
    }
  }

  void pressContinue() async {
    // Ask for permissions.
    if (activeStepIndex == 1) {
      bool permissionsGranted = await PermissionsManager.checkPermissions();

      if (permissionsGranted) {
        // Set the setup as completed
        await Provider.of<SettingsManager>(context, listen: false)
            .setSetupCompleted(true);

        // cancel setup not done notification
        await Notifications.cancelNotification(notificationSetupNotDoneId);

        // Go to permission screen
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/pre-dashboard', (route) => false);
      } else {
        if (askedForPermission == true) {
          await PermissionsManager.openAppSettings();
        } else {
          bool permGranted = await PermissionsManager.requestPermissions();

          setState(() {
            userAllowedPermissions = permGranted;
            askedForPermission = true;
          });
        }
      }
    } else {
      setState(() {
        activeStepIndex += 1;
        isStepValid = false;
      });
    }
  }

  void pressBack() {
    if (activeStepIndex > 0) {
      setState(() {
        activeStepIndex -= 1;
        isStepValid = false;
      });
    } else {
      Navigator.of(context).pop();
    }
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

  Future<void> _confirmBackPrompt() async {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

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
                          FlutterI18n.translate(context,
                              "onboarding.userForm.uncompletedChanges"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14 * sizeMultiplier,
                            fontWeight: FontWeight.bold,
                            color: Constants.darkBlue,
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 24 * sizeMultiplier),
                          child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: <Widget>[
                                CustomButton(
                                    minWidth:
                                        (MediaQuery.of(context).size.width -
                                                80 -
                                                40 -
                                                8) *
                                            0.5,
                                    label: FlutterI18n.translate(
                                        context, "continue"),
                                    shadowColor: Colors.black12,
                                    onPressed: () {
                                      Navigator.popUntil(
                                          context,
                                          ModalRoute.withName(
                                              '/intro-privacy'));
                                    }),
                                CustomButton(
                                    minWidth:
                                        (MediaQuery.of(context).size.width -
                                                80 -
                                                40 -
                                                8) *
                                            0.5,
                                    label: FlutterI18n.translate(
                                        context, "cancel"),
                                    textColor: Constants.darkBlue,
                                    labelStyle: TextStyle(
                                        fontSize: 14 * sizeMultiplier,
                                        fontWeight: FontWeight.normal),
                                    backgroundColor: Constants.transparent,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    })
                              ]))
                    ],
                  ))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return WillPopScope(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(children: <Widget>[
            KeyboardActions(
                config: _buildConfig(context),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Semantics(
                            header: true,
                            label:
                                FlutterI18n.translate(context, "a11y.header1"),
                            child: Text(
                                FlutterI18n.translate(
                                    context, "onboarding.header1"),
                                style: TextStyle(
                                    fontSize: 1, color: Colors.transparent))),
                        Container(
                            height: 50 * sizeMultiplier +
                                MediaQuery.of(context).padding.top,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Semantics(
                                    label: "Covi",
                                    child: SvgPicture.asset(
                                        "assets/svg/logo.svg",
                                        width: 80 * sizeMultiplier)))),
                        Expanded(
                          child: StepperCovi(
                            currentStep: activeStepIndex,
                            controlsBuilder: (BuildContext context,
                                {VoidCallback onStepContinue,
                                VoidCallback onStepCancel}) {
                              return Container();
                            },
                            type: StepperType.horizontal,
                            steps: <StepCovi>[
                              StepCovi(
                                isActive: _isStepActive(0),
                                state: _stepState(0),
                                content: UserForm(
                                  ageFocusNode: ageFocusNode,
                                  continueHandler: pressContinue,
                                ),
                              ),
                              StepCovi(
                                isActive: _isStepActive(1),
                                state: _stepState(1),
                                content: Permissions(
                                  validityHandler: setIsStepValid,
                                  userHasAllowedPermissions:
                                      userAllowedPermissions,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isKeyboardUp && activeStepIndex > 0)
                          StepperCoviButtons(
                              nextLabel: FlutterI18n.translate(
                                  context, "onboarding.continueButton"),
                              onPressedBack: pressBack,
                              onPressedNext:
                                  isStepValid ? () => pressContinue() : null)
                      ],
                    ))),
            Container(
                color: Constants.darkBlue70,
                height: MediaQuery.of(context).padding.top)
          ])),
      onWillPop: () async {
        if (activeStepIndex == 0) {
          _confirmBackPrompt();
          return false;
        } else {
          pressBack();
          return false;
        }
      },
    );
  }
}
