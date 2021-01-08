import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';

class DropdownItem {
  final String label;
  final String value;

  DropdownItem(this.label, this.value);
}

class DropdownFormField extends FormField<String> {
  DropdownFormField({
    Key key,
    this.label,
    @required this.autovalidate,
    @required this.value,
    @required List<DropdownItem> options,
    @required this.focusNode,
    this.errorMessage,
    this.hint,
    this.additionalLabel,
    this.onChanged,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
  })  : assert(autovalidate != null),
        assert(focusNode != null),
        assert(options != null),
        super(
          key: key,
          onSaved: onSaved,
          initialValue: value,
          validator: validator,
          builder: (FormFieldState<String> field) {
            double sizeMultiplier = MediaQuery.of(field.context).size.width / 320;
            var hasValue = value != null;
            var statusColor = hasValue || focusNode.hasPrimaryFocus ? Constants.mediumBlue : Constants.mediumGrey;
            return MergeSemantics(
              child:
                Semantics(
                    label: (additionalLabel != null ? additionalLabel : "") + FlutterI18n.translate(field.context, "a11y.tapToSelectOption"),
                    enabled: onChanged != null,
                    child: 
                    Focus(
                      focusNode: focusNode,
                      child: Listener(
                        onPointerDown: (_) {
                          FocusScope.of(field.context).requestFocus(focusNode);
                        },
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
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              validator: validator,
                              value: field.value,
                              style: TextStyle(color: statusColor, fontSize: 14 * sizeMultiplier),
                              iconEnabledColor:statusColor,
                              hint: hint != null ? Text(hint, style: Constants.CustomTextStyle.grey14Text(field.context).merge(TextStyle(fontSize: 16 * sizeMultiplier, fontWeight: FontWeight.w500))) : Text(""),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 14 * sizeMultiplier, horizontal: 14 * sizeMultiplier),
                                labelStyle: TextStyle(
                                    color: statusColor,
                                    fontSize: 16 * sizeMultiplier,
                                    fontWeight: FontWeight.w500),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: statusColor, width: 2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Constants.mediumBlue,
                                      width: 2,
                                    )),
                                errorStyle: TextStyle(fontSize: 1),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: field.hasError && autovalidate ? Constants.mediumRed : statusColor,
                                      width: 2,
                                    )),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: statusColor,
                                      width: 2,
                                    )),
                                labelText: label,
                              ),
                              onChanged: (String newValue) {
                                if (onChanged != null) {
                                  onChanged(newValue);
                                  field.didChange(newValue);
                                }
                              },
                              items: 
                                onChanged != null ?
                                options.map<DropdownMenuItem<String>>((DropdownItem item) {
                                  return DropdownMenuItem<String>(
                                    value: item.value,
                                    child: Text(item.label),
                                  );
                                }).toList() : null,
                              selectedItemBuilder: (BuildContext context) {
                                return options.map<Widget>((DropdownItem item) {
                                  return Text(item.label, overflow: TextOverflow.ellipsis, style: Constants.CustomTextStyle.darkBlue14Text(context).merge(TextStyle(color: Constants.mediumBlue)));
                                }).toList();
                              }
                            ),
                            field.hasError && autovalidate ?
                            Container(
                              margin: EdgeInsets.only(left: 16),
                              child: Text(
                                errorMessage != null ? errorMessage : FlutterI18n.translate(field.context, 'a11y.pleaseChooseAnswer'),
                                style: Constants.CustomTextStyle.red12Text(field.context)
                              )
                            ) : Container()
                          ])
                      ))
                    )
                );
              },
            );
  final bool autovalidate;
  final String value;
  final String label;
  final String hint;
  final String errorMessage;
  final String additionalLabel;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  @override
  _DropdownFormFieldState createState() =>
      _DropdownFormFieldState();
}

class _DropdownFormFieldState extends FormFieldState<String> {
  @override
  DropdownFormField get widget => super.widget;
  @override
  void didChange(String value) {
    super.didChange(value);
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }
  }
}
