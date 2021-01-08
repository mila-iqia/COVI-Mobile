import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    this.label,
    this.a11yLabel,
    this.width = 120,
    this.height = 45,
    this.shadowColor = Colors.black38,
    this.backgroundColor = Constants.mediumBlue,
    this.textColor = Colors.white,
    this.disabledBackgroundColor = Colors.grey,
    this.disabledTextColor = Colors.grey,
    this.onPressed,
  });

  final String label;
  final String a11yLabel;
  final double width;
  final double height;
  final Color shadowColor;
  final Color backgroundColor;
  final Color textColor;
  final Color disabledBackgroundColor;
  final Color disabledTextColor;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    Widget _generateButtonContent() {
      var text = Text(label,
          style: TextStyle(
              fontSize: 16.0, fontFamily: 'Neue', fontWeight: FontWeight.w600));

      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              child: Container(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(11),
                  decoration: BoxDecoration(
                      color: onPressed != null ? backgroundColor : disabledBackgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      boxShadow: [
                        new BoxShadow(
                          color: shadowColor,
                          blurRadius: 40.0,
                        ),
                      ]),
                  child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/arrow-back.svg',
                      color: textColor))),
            ),
            a11yLabel != null
            ? ExcludeSemantics(child: text)
            : text
          ]);
    }

    return Container(
        constraints: BoxConstraints(
          minHeight: height != null ? height * sizeMultiplier : null,
        ),
        alignment: Alignment.centerLeft,
        child: Semantics(
          label: a11yLabel != null ? a11yLabel : '',
          child:
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30 * sizeMultiplier)),
              splashColor: Colors.black12,
              highlightColor: Colors.transparent,
              color: Constants.transparent,
              textColor: textColor,
              disabledColor: Colors.transparent,
              disabledTextColor: disabledTextColor,
              child: _generateButtonContent(),
              onPressed: onPressed)
            )
        );
  }
}
