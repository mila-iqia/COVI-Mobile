import 'package:covi/material/contextualPage.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_svg/flutter_svg.dart';

class Beige extends StatelessWidget {
  const Beige({
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
      titleColor: Constants.darkBlue,
      subtitleColor: Constants.darkBlue,
      topBackTextColor: Constants.darkBlue,
      topBackBackgroudColor: Constants.beige,
      bottomBackTextColor: Constants.darkBlue,
      bottomBackBackgroudColor: Constants.yellow,
      backdropEnd: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/beige-bottom.svg",
        width: MediaQuery.of(context).size.width)),
      child: child,
      backdrop: <Widget>[
        Positioned(
            top: 0,
            left: 0,
            child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/beige-bg.svg",
                width: MediaQuery.of(context).size.width))),
        Positioned(
            top: 23 * sizeMultiplier,
            left: 0,
            child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/beige-red.svg",
                width: 83 * sizeMultiplier))),
        Positioned(
            right: 0,
            top: 0,
            child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/beige-green.svg",
                width: 144 * sizeMultiplier))),
        Positioned(
            top: 72 * sizeMultiplier,
            left: 185 * sizeMultiplier,
            child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/beige-yellow-2.svg",
                width: 14 * sizeMultiplier))),
      ],
      title: this.title,
      subtitle: this.subtitle,
    );
  }
}
