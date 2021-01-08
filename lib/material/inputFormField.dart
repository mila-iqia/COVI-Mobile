import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter/services.dart';

class InputFormField extends FormField<String> {
  InputFormField({
    Key key,
    this.label,
    this.a11yLabel,
    @required this.autovalidate,
    @required this.focusNode,
    @required this.errorMessage,
    @required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.readOnly = false,
    this.additionalLabel,
    this.icon,
    this.onChanged,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })  : assert(autovalidate != null),
        assert(focusNode != null),
        super(
          key: key,
          onSaved: onSaved,
          initialValue: controller.text,
          validator: validator,
          builder: (FormFieldState<String> field) {
            double sizeMultiplier = MediaQuery.of(field.context).size.width / 320;
            var hasValue = !controller.text.isEmpty;
            var statusColor = hasValue || focusNode.hasPrimaryFocus ? Constants.mediumBlue : Constants.mediumGrey;
            void onChangedHandler(String value) {
              if (onChanged != null) {
                onChanged(value);
              }
              if (field.hasError) {
                field.validate();
              }
              field.didChange(value);
            }
            return MergeSemantics(
              child:
                Semantics(
                  label: a11yLabel,
                  child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      additionalLabel != null ?
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child:
                          Text(additionalLabel, style: Constants.CustomTextStyle.darkBlue14Text(field.context))
                      ) : Container(),
                      TextFormField(
                        readOnly: readOnly,
                        showCursor: true,
                        inputFormatters: inputFormatters,
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: onChangedHandler,
                        validator: validator,
                        obscureText: false,
                        keyboardType: keyboardType,
                        style: TextStyle(color: statusColor, fontSize: 14 * sizeMultiplier),
                        decoration: InputDecoration(
                          suffixIcon: icon,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14 * sizeMultiplier,
                            vertical: 14 * sizeMultiplier * MediaQuery.of(field.context).textScaleFactor),
                          labelStyle: TextStyle(
                              color: statusColor,
                              fontSize: 16 * sizeMultiplier,
                              fontWeight: FontWeight.w500),
                          errorStyle: TextStyle(fontSize: 1),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: statusColor, width: 2)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: statusColor,
                                width: 2,
                              )),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: field.hasError && autovalidate ? Constants.mediumRed : statusColor,
                                width: 2,
                              )),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: field.hasError && autovalidate ? Constants.mediumRed : statusColor,
                                width: 2,
                              )),
                          labelText: label,
                        ),
                      ),
                      field.hasError && autovalidate ?
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(errorMessage, style: Constants.CustomTextStyle.red12Text(field.context))
                      ) : Container()
                    ])
                )
            );
          },
        );
  final bool autovalidate;
  final bool readOnly;
  final String label;
  final String a11yLabel;
  final String errorMessage;
  final String additionalLabel;
  final FocusNode focusNode;
  final Widget icon;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  @override
  _InputFormFieldState createState() =>
      _InputFormFieldState();
}

class _InputFormFieldState extends FormFieldState<String> {
  @override
  InputFormField get widget => super.widget;
  @override
  void didChange(String value) {
    super.didChange(value);
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }
  }
}
