import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;

enum CCardColor { red, green, blue, yellow }

class CCard extends StatelessWidget {
  const CCard({
    @required this.title,
    this.subtitle,
    this.color,
    this.iconPadding = 0.0,
    @required this.icon,
    this.focusNode,
    this.onTap,
  })  : assert(icon != null),
        assert(title != null);

  final String title;
  final String subtitle;
  final CCardColor color;
  final double iconPadding;
  final Widget icon;
  final FocusNode focusNode;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    SvgPicture _cCardCircleColor() {
      switch (color) {
        case CCardColor.red:
          return SvgPicture.asset("assets/svg/ccard-oval-red.svg");
          break;
        case CCardColor.blue:
          return SvgPicture.asset("assets/svg/ccard-oval-blue.svg");
          break;
        case CCardColor.yellow:
          return SvgPicture.asset("assets/svg/ccard-oval-yellow.svg");
          break;
        case CCardColor.green:
          return SvgPicture.asset("assets/svg/ccard-oval-green.svg");
          break;
        default:
          return null;
      }
    }

    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Constants.lightGrey,
        child: Container(
          constraints: BoxConstraints(minHeight: 90 * sizeMultiplier),
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  ExcludeSemantics(
                      child: Container(
                          width: 57,
                          child: Stack(
                            children: <Widget>[
                              if (color != null) Container(child: _cCardCircleColor()),
                              Positioned(top: 20, child: Container(padding: EdgeInsets.only(left: iconPadding), child: icon))
                            ],
                          ))),
                  Flexible(
                      child: Container(
                          padding: EdgeInsets.only(right: focusNode != null ? 24 * sizeMultiplier : 16 * sizeMultiplier),
                          margin: EdgeInsets.symmetric(vertical: 16 * sizeMultiplier),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                            Text(title, style: TextStyle(fontSize: 14 * sizeMultiplier, height: 1.2, fontWeight: FontWeight.bold, color: Constants.darkBlue)),
                            Container(
                                margin: EdgeInsets.only(top: 2 * sizeMultiplier),
                                child: Text(subtitle, style: TextStyle(height: 1.2, fontSize: 12 * sizeMultiplier, color: Constants.mediumGrey))),
                          ]))),
                ],
              ),
              if (onTap != null)
                Positioned(
                    right: 0,
                    top: 0,
                    child: Semantics(
                        label: FlutterI18n.translate(context, "onboarding.infoLabel"),
                        button: true,
                        container: true,
                        child: InkWell(
                            focusNode: focusNode,
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                            splashColor: Colors.blue.withAlpha(30),
                            onTap: onTap,
                            child: Container(
                              padding: EdgeInsets.all(16 * sizeMultiplier),
                              height: 48 * sizeMultiplier,
                              width: 48 * sizeMultiplier,
                              child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/info-circle.svg')),
                            ))))
            ],
          ),
        ));
  }
}
