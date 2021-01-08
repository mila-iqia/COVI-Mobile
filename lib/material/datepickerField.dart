import 'package:covi/material/inputFormField.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class DatepickerField extends StatelessWidget {
  const DatepickerField({
    @required this.label,
    @required this.additionalLabel,
    @required this.controller,
    @required this.focusNode,
    this.autovalidate,
    this.validator,
    this.onTap
  }) : assert(label != null),
       assert(additionalLabel != null);

  final String label;
  final String additionalLabel;
  final FocusNode focusNode;
  final bool autovalidate;
  final FormFieldValidator validator;
  final TextEditingController controller;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      ExcludeSemantics(
        child: Text(
          additionalLabel,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 14 * sizeMultiplier,
              color: Constants.darkBlue,
              fontWeight: FontWeight.w500))),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child:
        MergeSemantics(
          child:
            Semantics(
              label: additionalLabel
              + controller.text
              + FlutterI18n.translate(context, 'a11y.tapToChooseDate'),
              child:
                InkWell(
                  onTap: onTap,
                  child: AbsorbPointer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      InputFormField(
                        autovalidate: autovalidate,
                        errorMessage: FlutterI18n.translate(context, 'actions.selfDiagnostic.dateFieldErrorLabel'),
                        readOnly: true,
                        label: label,
                        icon: Padding(
                            padding: EdgeInsets.all(16),
                            child: SvgPicture.asset(
                                'assets/svg/icon-calendar.svg')),
                        validator: validator,
                        controller: controller,
                        focusNode: focusNode,
                      ),
                    ])
                  ),
                )
            )
        )
      )
    ]);
  }
}
