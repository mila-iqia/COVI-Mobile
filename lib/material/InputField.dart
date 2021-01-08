import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  const InputField({
    @required this.label,
    this.additionalLabel,
    this.a11yLabel,
    this.icon,
    this.customStatusColor,
    @required this.validator,
    @required this.controller,
    @required this.focusNode,
    this.inputFormatters,
    this.readOnly = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    
  }) : assert(label != null);

  final String label;
  final String additionalLabel;
  final String a11yLabel;
  final Widget icon;
  final Color customStatusColor;
  final Function validator;
  final TextInputType keyboardType;
  final FocusNode focusNode;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final bool readOnly;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    var hasValue = !controller.text.isEmpty;
    var statusColor = hasValue || this.focusNode.hasPrimaryFocus ? Constants.mediumBlue : Constants.mediumGrey;
    return 
    MergeSemantics(
      child:
        Semantics(
          label: a11yLabel,
          child:
            Column(children: <Widget>[
              additionalLabel != null ?
              Container(
                margin: EdgeInsets.only(bottom: 12),
                child:
                  Text(additionalLabel, style: Constants.CustomTextStyle.darkBlue14Text(context))
              ) : Container(),
              TextFormField(
                readOnly: readOnly,
                showCursor: true,
                inputFormatters: inputFormatters,
                controller: controller,
                focusNode: this.focusNode,
                onChanged: onChanged,
                validator: (value) {
                  return this.validator(value);
                },
                obscureText: false,
                keyboardType: keyboardType,
                style: TextStyle(color: statusColor, fontSize: 14 * sizeMultiplier),
                decoration: InputDecoration(
                  suffixIcon: icon,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14 * sizeMultiplier,
                    vertical: 14 * sizeMultiplier * MediaQuery.of(context).textScaleFactor),
                  labelStyle: TextStyle(
                      color: statusColor,
                      fontSize: 16 * sizeMultiplier,
                      fontWeight: FontWeight.w500),
                  errorStyle: Constants.CustomTextStyle.red12Text(context),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: customStatusColor != null ? customStatusColor : statusColor, width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: customStatusColor != null ? customStatusColor : statusColor,
                        width: 2,
                      )),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Constants.mediumRed,
                        width: 2,
                      )),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Constants.mediumRed,
                        width: 2,
                      )),
                  labelText: label,
                ),
              )
            ])
        )
    );
  }
}
