import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';

class DropdownItem {
  final String label;
  final String value;

  DropdownItem(this.label, this.value);
}

class Dropdown extends StatelessWidget {
  const Dropdown({
    this.label,
    this.hint,
    this.errorMessage,
    this.additionalLabel,
    @required this.items,
    this.value,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    @required this.focusNode,
    this.validator,
  });

  final String label;
  final String hint;
  final String errorMessage;
  final String additionalLabel;
  final List<DropdownItem> items;
  final Function onChanged;
  final String value;
  final TextInputType keyboardType;
  final Function validator;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    var hasValue = value != null;
    var statusColor = hasValue || this.focusNode.hasPrimaryFocus ? Constants.mediumBlue : Constants.mediumGrey;
    return 
    MergeSemantics(
      child:
        Semantics(
            label: (additionalLabel != null ? additionalLabel : "") + FlutterI18n.translate(context, "a11y.tapToSelectOption"),
            enabled: onChanged != null,
            child: 
            Focus(
              focusNode: focusNode,
              child: Listener(
                onPointerDown: (_) {
                  FocusScope.of(context).requestFocus(focusNode);
                },
                child:
                  Column(children: <Widget>[
                    additionalLabel != null ?
                    Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child:
                        Text(additionalLabel, style: Constants.CustomTextStyle.darkBlue14Text(context))
                    ) : Container(),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      validator: (value) {
                        return this.validator(value);
                      },
                      value: this.value,
                      style: TextStyle(color: statusColor, fontSize: 14 * sizeMultiplier),
                      iconEnabledColor:statusColor,
                      hint: hint != null ? Text(hint, style: Constants.CustomTextStyle.grey14Text(context).merge(TextStyle(fontSize: 16 * sizeMultiplier, fontWeight: FontWeight.w500))) : Text(""),
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
                        errorStyle: TextStyle(
                          color: Constants.mediumRed, fontSize: 12 * sizeMultiplier, fontWeight: FontWeight.w500),
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
                      onChanged: (String newValue) {
                        if (this.onChanged != null) {
                          this.onChanged(newValue);
                        }
                      },
                      items: 
                        onChanged != null ?
                        items.map<DropdownMenuItem<String>>((DropdownItem item) {
                          return DropdownMenuItem<String>(
                            value: item.value,
                            child: Text(item.label),
                          );
                        }).toList() : null,
                      selectedItemBuilder: (BuildContext context) {
                        return items.map<Widget>((DropdownItem item) {
                          return Text(item.label, overflow: TextOverflow.ellipsis, style: Constants.CustomTextStyle.darkBlue14Text(context).merge(TextStyle(color: Constants.mediumBlue)));
                        }).toList();
                      }
                    )
                  ])
              ))
            )
    );
  }
}
