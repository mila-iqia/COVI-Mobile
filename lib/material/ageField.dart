import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:covi/material/ExpandedSection.dart';
import 'package:covi/material/InputField.dart';
import 'package:covi/material/labeledCheckbox.dart';
import 'package:flutter/services.dart';
import 'package:covi/utils/constants.dart' as Constants;

class AgeField extends StatelessWidget {
  const AgeField({
    @required this.age,
    @required this.ageFocusNode,
    @required this.ageController,
    @required this.consentForTeen,
    @required this.autovalidate,
    @required this.onAgeChanged,
    @required this.onConsentTeenChanged
  })  : assert(ageFocusNode != null),
        assert(ageController != null),
        assert(consentForTeen != null);

  final String age;
  final FocusNode ageFocusNode;
  final TextEditingController ageController;
  final bool consentForTeen;
  final bool autovalidate;
  final Function onAgeChanged;
  final Function onConsentTeenChanged;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    RegExp digitsOnly = new RegExp('[0-9]');
    bool ageIsValid = age != null && !age.isEmpty && digitsOnly.hasMatch(age);
    bool tooYoung = ageIsValid && int.parse(age) < 13;
    bool needConsent = ageIsValid && int.parse(age) > 12 && int.parse(age) < 16;

    return Column(children: <Widget> [
      InputField(
        a11yLabel: tooYoung
          ? FlutterI18n.translate(
              context, "onboarding.userForm.tooYoung")
          : '',
        onChanged: onAgeChanged,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3)
        ],
        focusNode: ageFocusNode,
        controller: ageController,
        validator: (value) {
          // if (value.isEmpty) {
          //   ageFocusNode.requestFocus();
          //   return FlutterI18n.translate(
          //       context, "onboarding.userForm.ageFieldIncomplete");
          // }
          return null;
        },
        label: FlutterI18n.translate(context, "profile.genderField"),
        keyboardType: TextInputType.number,
      ),
      ExpandedSection(
        expand: tooYoung,
        child: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Stack(children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFfff2f2),
                      borderRadius: BorderRadius.all(
                          Radius.circular(7.0))),
                  height: 82 * sizeMultiplier),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: 
                  Semantics(
                    focusable: true,
                    child:
                      Text(
                          FlutterI18n.translate(context,
                              "onboarding.userForm.tooYoung"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFFbd232a),
                              fontSize: 14 * sizeMultiplier,
                              fontWeight: FontWeight.w500))
                  )
                ),
              ),
            ]))),
      ExpandedSection(
        expand: needConsent,
        child: 
          Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: 
                Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFf6f5f2),
                        borderRadius: BorderRadius.all(
                            Radius.circular(7.0))),
                    child:
                      LabeledCheckbox(
                        label: FlutterI18n.translate(context,
                            'onboarding.userForm.guardianConsent'),
                        value: consentForTeen,
                        onChanged: onConsentTeenChanged)
                )
            ),
            autovalidate && !consentForTeen ?
            Container(
              child: Text(
                FlutterI18n.translate(context, 'onboarding.userForm.ageFieldConsentNeeded'),
                style: Constants.CustomTextStyle.red12Text(context)
              )
            ) : Container()
          ])
      )
    ]);
  }
}