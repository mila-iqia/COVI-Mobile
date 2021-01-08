import 'package:covi/material/contextualPage.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_svg/flutter_svg.dart';

class DarkBlueArrows extends StatelessWidget {
  const DarkBlueArrows({
    @required this.title,
    this.subtitle,
    this.backLabel,
    @required this.child,
    this.hasBottomBack = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
  }) : assert(title != null, child != null);

  final String title;
  final String subtitle;
  final String backLabel;
  final Widget child;
  final bool hasBottomBack;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return ContextualPage(
      backLabel: backLabel,
      contentPadding: contentPadding,
      hasBottomBack: hasBottomBack,
      titleColor: Colors.white,
      subtitleColor: Constants.beige,
      textAlignment: Alignment(0.0, 1.0),
      topBackTextColor: Colors.white,
      topBackBackgroudColor: Constants.darkBlue,
      bottomBackTextColor: Constants.darkBlue,
      bottomBackBackgroudColor: Constants.yellow,
      textBackgroundColor: Constants.darkBlue,
      backdropEnd: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/darkBlueArrows-bottom.svg",
        width: MediaQuery.of(context).size.width)),
      child: child,
      backdrop: <Widget>[
        Positioned(
            top: 0,
            left: 0,
            child: ExcludeSemantics(child: SvgPicture.asset(
                "assets/svg/backdrops/darkBlueArrows-bg.svg",
                width: MediaQuery.of(context).size.width))),
        Positioned(
            left: 0,
            top: 50 * sizeMultiplier,
            child: ExcludeSemantics(child: SvgPicture.asset(
                "assets/svg/backdrops/darkBlueArrows-blue.svg",
                width: 128 * sizeMultiplier))),
        Positioned(
            top: 0,
            right: 0,
            child: ExcludeSemantics(child: SvgPicture.asset(
                "assets/svg/backdrops/darkBlueArrows-shape.svg",
                width: 141 * sizeMultiplier))),
        Positioned(
            top: 80 * sizeMultiplier,
            left: 76 * sizeMultiplier,
            child: ExcludeSemantics(child: SvgPicture.asset(
                "assets/svg/backdrops/darkBlueArrows-green.svg",
                width: 14 * sizeMultiplier))),
      ],
      title: this.title,
      subtitle: this.subtitle,
    );
  }
}
