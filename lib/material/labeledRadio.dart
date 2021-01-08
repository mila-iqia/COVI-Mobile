import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';

class LabeledRadio<T> extends StatelessWidget {
  const LabeledRadio(
      {this.label,
      this.sublabel,
      this.groupLabel,
      this.value,
      this.groupValue,
      this.selected = false,
      this.onChanged,
      this.padding = const EdgeInsets.symmetric(vertical: 16)});

  final String label;
  final String sublabel;
  final String groupLabel;
  final T value;
  final T groupValue;
  final bool selected;
  final Function onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return 
    MergeSemantics(
      child:
        Semantics(
          label: groupLabel + label + sublabel + (value == groupValue
            ? "" : FlutterI18n.translate(context, "a11y.tapToSelect")),
            child:
              Padding(
                padding: padding,
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
                              Text(label,
                                  style: TextStyle(
                                      color: value == groupValue
                                          ? Constants.mediumBlue
                                          : Constants.mediumGrey,
                                      fontSize: 14 * sizeMultiplier,
                                      fontWeight: sublabel != null
                                          ? FontWeight.bold
                                          : FontWeight.w500))
                          ),
                          if (sublabel != null)
                            ExcludeSemantics(
                              child:
                                Text(sublabel,
                                    style: TextStyle(
                                    fontSize: 14 * sizeMultiplier,
                                    color: Constants.darkBlue,
                                    fontStyle: FontStyle.italic))
                            )
                        ],
                    ),
                    activeColor: Constants.mediumBlue,
                    groupValue: groupValue,
                    value: value,
                    onChanged: (newValue) {
                      onChanged(newValue);
                    },
                  )
              )
        )
    );
  }
}
