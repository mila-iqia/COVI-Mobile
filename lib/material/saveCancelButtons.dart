import 'package:flutter/material.dart';
import 'package:covi/material/customButton.dart';
import 'package:covi/material/saveButton.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:covi/utils/constants.dart' as Constants;

class SaveCancelButtons extends StatelessWidget {
  const SaveCancelButtons({
    this.saveFirst = true,
    this.saveLabel,
    this.isValidToSave,
    this.cancelLabel,
    this.padding = const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 16),
    this.margin,
    this.onPressedSave,
    this.onPressedCancel,
  });

  final bool saveFirst;
  final String saveLabel;
  final bool isValidToSave;
  final String cancelLabel;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Function onPressedSave;
  final Function onPressedCancel;

  @override
  Widget build(BuildContext context) {
    Widget _saveButton() {
      return SaveButton(
        isValidToSave: isValidToSave,
        label: saveLabel != null ? saveLabel : FlutterI18n.translate(context, "save"),
        width: MediaQuery.of(context).size.width - 32,
        onPressed: onPressedSave
      );
    }

    Widget _cancelButton() {
      return CustomButton(
                label: cancelLabel != null ? cancelLabel : FlutterI18n.translate(context, "cancel"),
                labelStyle: TextStyle(fontWeight: FontWeight.w500),
                width: MediaQuery.of(context).size.width - 32,
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                onPressed: onPressedCancel
              );
    }

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
              width: 1, color: Constants.borderGrey)
            )
          ),
          padding: padding,
          margin: margin,
          child:
            Column(children: <Widget>[
              saveFirst ? _saveButton() : _cancelButton(),
              Divider(height: 16, color: Colors.transparent),
              saveFirst ? _cancelButton() : _saveButton()
            ])
        )
      ],
    );
  }
}
