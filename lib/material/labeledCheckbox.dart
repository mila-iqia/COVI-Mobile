import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox(
      {this.label,
      this.value,
      this.key,
      this.focusNode,
      this.onChanged,
      this.padding = const EdgeInsets.symmetric(vertical: 16)});

  final String label;
  final bool value;
  final Key key;
  final FocusNode focusNode;
  final Function onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Focus(
      key: key,
      canRequestFocus: true,
      focusNode: focusNode,
      child:
        MergeSemantics(
          child:
            Semantics(
              label: label + (value
                  ? FlutterI18n.translate(context, "a11y.tapToUnselect")
                  : FlutterI18n.translate(context, "a11y.tapToSelect")),
              child:
                Padding(
                  padding: this.padding,
                  child:
                    CheckboxListTile(
                      title: 
                      ExcludeSemantics(
                        child:
                          Text(label,
                            style: TextStyle(
                                color: value
                                    ? Constants.mediumBlue
                                    : Constants.mediumGrey,
                                fontSize: 16 * sizeMultiplier,
                                height: 1.3,
                                fontWeight:
                                    value ? FontWeight.bold : FontWeight.w500))
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Constants.mediumBlue,
                      checkColor: Colors.white,
                      value: value,
                      onChanged: (bool newValue) {
                        onChanged(newValue);
                      },
                    )
                )
            )
        )
    );
  }
}
