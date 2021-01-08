import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;

enum CustomButtonIconPosition {
  before,
  after,
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    this.label,
    this.a11yLabel,
    this.width,
    this.minWidth,
    this.minHeight = 48,
    this.height,
    this.borderRadius = 30.0,
    this.padding = const EdgeInsets.all(0),
    this.labelStyle = const TextStyle(),
    this.labelAlign = TextAlign.left,
    this.icon,
    this.iconLabel,
    this.iconPosition = CustomButtonIconPosition.before,
    this.customContent,
    this.shadowColor,
    this.splashColor = Constants.yellowSplash,
    this.backgroundColor = Constants.yellow,
    this.textColor = Constants.darkBlue,
    this.disabledBackgroundColor = Constants.borderGrey,
    this.disabledTextColor = Constants.mediumGrey,
    this.onPressed,
  });

  final String label;
  final String a11yLabel;
  final double width;
  final double minWidth;
  final double minHeight;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle labelStyle;
  final TextAlign labelAlign;
  final Widget icon;
  final String iconLabel;
  final CustomButtonIconPosition iconPosition;
  final Widget customContent;
  final Color shadowColor;
  final Color splashColor;
  final Color backgroundColor;
  final Color textColor;
  final Color disabledBackgroundColor;
  final Color disabledTextColor;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    Widget _generateButtonContent() {
      var defaultStyle = TextStyle(fontSize: 16 * sizeMultiplier, fontFamily: 'Neue', fontWeight: FontWeight.w500).merge(this.labelStyle);
      if (customContent != null) {
        return customContent;
      } else {
        if (this.label == null) {
          return ExcludeSemantics(child: this.icon);
        } else {
          var text = (a11yLabel == null ? Text(label, style:defaultStyle, textAlign: labelAlign) : ExcludeSemantics(child: Text(label, style:defaultStyle, textAlign: labelAlign)));
          if (this.icon == null) {
            return text;
          } else {
            if (iconPosition == CustomButtonIconPosition.before) {
              return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(right: 15 * sizeMultiplier), child: ExcludeSemantics(child: icon)),
                    text
                  ]);
            }
            return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  text,
                  Container(margin: EdgeInsets.only(left: 15 * sizeMultiplier), child: ExcludeSemantics(child: icon)),
                ]);
          }
        }

      }
    }

    return Container(
        width: width != null ? width * sizeMultiplier : null,
        height: height != null ? height * sizeMultiplier : null,
        constraints: BoxConstraints(
          minHeight: minHeight * sizeMultiplier,
          minWidth: minWidth != null ? minWidth : 0,
        ),
        decoration: shadowColor != null && onPressed != null
            ? new BoxDecoration(boxShadow: [
                new BoxShadow(
                  color: shadowColor,
                  blurRadius: 40.0,
                ),
              ])
            : null,
        child:
          FlatButton(
            padding: padding * sizeMultiplier,
            color: backgroundColor,
            textColor: textColor,
            disabledColor: disabledBackgroundColor,
            disabledTextColor: disabledTextColor,
            splashColor: splashColor,
            highlightColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(borderRadius * sizeMultiplier)),
            child: 
            Semantics(
              label: a11yLabel == null ? (label == null ? iconLabel : '') : a11yLabel,
              child:
                _generateButtonContent()
            ),
            onPressed: onPressed)
        );
  }
}
