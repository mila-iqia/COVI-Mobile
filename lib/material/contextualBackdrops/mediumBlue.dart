import 'package:covi/material/contextualPage.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_svg/flutter_svg.dart';

class MediumBlue extends StatelessWidget {
  const MediumBlue({@required this.title, this.subtitle, @required this.child})
      : assert(title != null, child != null);

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return ContextualPage(
      titleColor: Colors.white,
      subtitleColor: Constants.beige,
      topBackTextColor: Colors.white,
      topBackBackgroudColor: Constants.mediumBlue,
      bottomBackTextColor: Constants.darkBlue,
      bottomBackBackgroudColor: Constants.yellow,
      backdropEnd: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/mediumBlue-bottom.svg",
        width: MediaQuery.of(context).size.width)),
      child: child,
      backdrop: <Widget>[
        Positioned(
            top: 0,
            left: 0,
            child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/mediumBlue-bg.svg",
                width: MediaQuery.of(context).size.width))),
        Positioned(
            top: 10,
            left: 0,
            child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/mediumBlue-green.svg",
                width: 59 * sizeMultiplier))),
        Positioned(
            top: 116 * sizeMultiplier,
            left: 153 * sizeMultiplier,
            child: ExcludeSemantics(child: SvgPicture.asset(
                "assets/svg/backdrops/mediumBlue-green-2.svg",
                width: 14 * sizeMultiplier))),
        Positioned(
            top: 0,
            right: 0,
            child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/mediumBlue-shape.svg",
                width: 85 * sizeMultiplier)))
      ],
      title: this.title,
      subtitle: this.subtitle,
    );
  }
}
