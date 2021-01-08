import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';

class RadioItem {
  RadioItem({
    @required this.label,
    this.sublabel,
    @required this.value,
    this.selected = false,
    this.onChanged,
    this.padding = const EdgeInsets.all(0)
  }):assert(label != null),
     assert(value != null);

  final String label;
  final String sublabel;
  final String value;
  final bool selected;
  final Function onChanged;
  final EdgeInsetsGeometry padding;
}

class RadioFormFields extends FormField<String> {
  RadioFormFields({
    Key key,
    String initialValue,
    validator,
    this.groupLabel,
    this.autovalidate,
    this.onChanged,
    this.items,
  })  : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          builder: (FormFieldState field) {
          double sizeMultiplier = MediaQuery.of(field.context).size.width / 320;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            for (var i = 0; i < items.length; i++)
              MergeSemantics(
                child:
                  Semantics(
                    label: groupLabel + items[i].label + items[i].sublabel + (items[i].value == initialValue
                      ? "" : FlutterI18n.translate(field.context, "a11y.tapToSelect")),
                      child:
                        Padding(
                          padding: items[i].padding,
                          child:
                            RadioListTile(
                              title: 
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(height: 11 * sizeMultiplier),
                                    ExcludeSemantics(
                                      child:
                                        Text(items[i].label,
                                            style: TextStyle(
                                                color: items[i].value == initialValue
                                                    ? Constants.mediumBlue
                                                    : Constants.mediumGrey,
                                                fontSize: 14 * sizeMultiplier,
                                                fontWeight: items[i].sublabel != null
                                                    ? FontWeight.bold
                                                    : FontWeight.w500))
                                    ),
                                    if (items[i].sublabel != null)
                                      ExcludeSemantics(
                                        child:
                                          Text(items[i].sublabel,
                                              style: TextStyle(
                                              fontSize: 14 * sizeMultiplier,
                                              color: Constants.darkBlue,
                                              fontStyle: FontStyle.italic))
                                      )
                                  ],
                              ),
                              activeColor: Constants.mediumBlue,
                              groupValue: initialValue,
                              value: items[i].value,
                              onChanged: (newValue) {
                                items[i].onChanged(newValue);
                                field.didChange(newValue);
                              },
                            )
                        )
                  )
              ),
              autovalidate && field.hasError ?
              Container(
                margin: EdgeInsets.only(left: 21, bottom: 21),
                child: Text(
                  FlutterI18n.translate(field.context, 'a11y.pleaseChooseAnswer'),
                  style: Constants.CustomTextStyle.red12Text(field.context)
                )
              ) : Container()
            ]);
          },
        );
  final String groupLabel;
  final bool autovalidate;
  final List<RadioItem> items;
  final ValueChanged onChanged;
  @override
  FormFieldState<String> createState() => _RadioFormFieldsState();
}

class _RadioFormFieldsState extends FormFieldState<String> {
  @override
  RadioFormFields get widget => super.widget;
  @override
  void didChange(String value) {
    super.didChange(value);
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }
  }
}