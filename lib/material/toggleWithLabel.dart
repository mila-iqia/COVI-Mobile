import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';

class ToggleWithLabel extends StatelessWidget {
  const ToggleWithLabel({
    @required this.label,
    @required this.onPress,
    @required this.autovalidate,
    this.focusNode,
    this.status,
    this.choicePadding = 18,
    this.isSubOption = false,
    this.isMoreQuestionsOption = false,
  })  : assert(label != null),
        assert(onPress != null);

  final String label;
  final double choicePadding;
  final Function onPress;
  final bool autovalidate;
  final FocusNode focusNode;
  final bool status;
  final bool isSubOption;
  final bool isMoreQuestionsOption;

  @override
  Widget build(BuildContext context) {
  double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    var choices = this.status == null ? [false, false] : [this.status == false, this.status == true];

    return Focus(
      canRequestFocus: true,
      focusNode: focusNode,
      child:
        Column(
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
                  width: isSubOption ? MediaQuery.of(context).size.width * 0.45 : MediaQuery.of(context).size.width * 0.5,
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
                        Semantics(
                          label: label + FlutterI18n.translate(context, "no")
                          + (choices[0] ? "" : FlutterI18n.translate(context, "a11y.tapToSelect"))
                          + (isMoreQuestionsOption && choices[1] ? FlutterI18n.translate(context, "a11y.hideAdditionalQuestions") : ""),
                          selected: choices[0],
                          child:
                            Container(
                              constraints: BoxConstraints(
                                minHeight: 48 * sizeMultiplier,
                                minWidth: 60 * sizeMultiplier,
                              ),
                              alignment: Alignment.center,
                              // padding: EdgeInsets.only(left: 18, right: 18, top: 15, bottom: 18),
                              child: Center(child: ExcludeSemantics(child: Text(FlutterI18n.translate(context, "no").toUpperCase(),
                              style: TextStyle(height: choices[0] ? 1.1 : 1,fontWeight: choices[0] ? FontWeight.w700 : FontWeight.w500, fontSize: 12 * sizeMultiplier)))))
                        ),
                        Semantics(
                          label: label + FlutterI18n.translate(context, "yes")
                          + (choices[1] ? "" : FlutterI18n.translate(context, "a11y.tapToSelect"))
                          + (isMoreQuestionsOption && !choices[1] ? FlutterI18n.translate(context, "a11y.additionalQuestions") : ""),
                          selected: choices[1],
                          child:
                            Container(
                              constraints: BoxConstraints(
                                minHeight: 48 * sizeMultiplier,
                                minWidth: 60 * sizeMultiplier,
                              ),
                              alignment: Alignment.center,
                              // padding: EdgeInsets.only(left: 18, right: 18, top: 15, bottom: 18),
                              child: Center(child: ExcludeSemantics(child: Text(FlutterI18n.translate(context, "yes").toUpperCase(),
                              style: TextStyle(height: choices[1] ? 1.1 : 1,fontWeight: choices[1] ? FontWeight.w700 : FontWeight.w500, fontSize: 12 * sizeMultiplier)))))
                        )
                      ],
                      onPressed: (int index) {
                        onPress(index == 1);
                      },
                      isSelected: choices,
                    )),
              ],
            )),
            autovalidate && status == null ?
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Text(
                  FlutterI18n.translate(context, 'a11y.pleaseChooseAnswer'),
                  style: Constants.CustomTextStyle.red12Text(context)
                )
              ) : Container()
          ]
      )
    );
  }
}
