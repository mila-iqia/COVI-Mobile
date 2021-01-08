import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';

enum ToggleChoices{ no, yes }

class ToggleItem {
  ToggleItem({
    @required this.name,
    @required this.focusNode,
    this.subItems,
    this.parent
  }):assert(name != null),
     assert(focusNode != null);

  final String name;
  final FocusNode focusNode;
  final List<ToggleItem> subItems;
  final String parent;
}

class ToggleFormField extends FormField<ToggleChoices> {
ToggleFormField({
    Key key,
    @required this.label,
    @required this.onPress,
    @required this.autovalidate,
    @required this.focusNode,
    @required this.validator,
    this.status,
    this.isSubOption = false,
    this.isMoreQuestionsOption = false,
    this.onChanged
  })  : super(
          key: key,
          validator: validator,
          initialValue: status == null ? null : status ? ToggleChoices.yes : ToggleChoices.no,
          builder: (FormFieldState field) {
            double sizeMultiplier = MediaQuery.of(field.context).size.width / 320;
            var choices = status == null ? [false, false] : [status == false, status == true];

            return Focus(
              focusNode: focusNode,
              child:
                InputDecorator(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(0)
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      FractionallySizedBox(
                        widthFactor: 1,
                        child:
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 8 * sizeMultiplier,
                          children: <Widget>[
                            Container(
                              width: isSubOption ? MediaQuery.of(field.context).size.width * 0.45 : MediaQuery.of(field.context).size.width * 0.5,
                              padding: EdgeInsets.only(right: 4 * sizeMultiplier),
                              child:
                                ExcludeSemantics(child:
                                  Text(label,
                                    style: TextStyle(
                                      fontSize: 14 * sizeMultiplier,
                                      height: 1.2,
                                      fontWeight: FontWeight.w500,
                                      color: Constants.darkBlue))
                                )
                            ),
                            Container(
                                child: ToggleButtons(
                                  borderColor: autovalidate && status == null ? Constants.mediumRed : Constants.mediumGrey,
                                  selectedBorderColor: Constants.mediumBlue,
                                  selectedColor: isSubOption ? Colors.white : Constants.mediumBlue,
                                  color: autovalidate && status == null ? Constants.mediumRed : Constants.mediumGrey,
                                  fillColor: isSubOption ? Constants.mediumBlue : Constants.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                  children: <Widget>[
                                    for (var item in ToggleChoices.values)
                                      Semantics(
                                        label: label + FlutterI18n.translate(field.context, describeEnum(item))
                                        + (field.value == item ? "" : FlutterI18n.translate(field.context, "a11y.tapToSelect"))
                                        + (isMoreQuestionsOption ? 
                                        (item == ToggleChoices.no
                                          ? FlutterI18n.translate(field.context, "a11y.hideAdditionalQuestions")
                                          : FlutterI18n.translate(field.context, "a11y.additionalQuestions")) : ""),
                                        selected: field.value == item,
                                        child:
                                          Container(
                                            constraints: BoxConstraints(
                                              minHeight: 48 * sizeMultiplier,
                                              minWidth: 60 * sizeMultiplier,
                                            ),
                                            alignment: Alignment.center,
                                            child: Center(child: ExcludeSemantics(child: Text(FlutterI18n.translate(field.context, describeEnum(item)).toUpperCase(),
                                            style: TextStyle(fontWeight: field.value == item ? FontWeight.w700 : FontWeight.w500, fontSize: 12 * sizeMultiplier)))))
                                      ),
                                  ],
                                  onPressed: (int index) {
                                    onPress(index == 1);
                                    field.didChange(index == 1 ? ToggleChoices.yes : ToggleChoices.no);
                                  },
                                  isSelected: choices,
                                )),
                          ],
                        )),
                        status == null && autovalidate ?
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Text(
                              FlutterI18n.translate(field.context, 'a11y.pleaseChooseAnswer'),
                              style: Constants.CustomTextStyle.red12Text(field.context)
                            )
                          ) : Container()
                      ]
                      )
                  )
            );
          },
        );
  final FocusNode focusNode; 
  final bool autovalidate;
  final String label;
  final Function onPress;
  final FormFieldValidator validator;
  final ValueChanged<ToggleChoices> onChanged;
  final bool status;
  final bool isSubOption;
  final bool isMoreQuestionsOption;
  @override
  ToggleFormFieldState createState() =>
      ToggleFormFieldState();
}

class ToggleFormFieldState extends FormFieldState<ToggleChoices> {
  @override
ToggleFormField get widget => super.widget;
  @override
  void didChange(ToggleChoices value) {
    super.didChange(value);
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }
  }
}