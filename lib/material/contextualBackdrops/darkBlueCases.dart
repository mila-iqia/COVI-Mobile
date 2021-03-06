import 'package:covi/material/contextualPage.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class DarkBlueCases extends StatelessWidget {
  const DarkBlueCases({
    @required this.title,
    this.subtitle,
    this.backLabel,
    @required this.child,
    this.hasBottomBack = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.keyboardBuildConfig
  }) : assert(title != null, child != null);

  final String title;
  final String subtitle;
  final String backLabel;
  final Widget child;
  final bool hasBottomBack;
  final EdgeInsetsGeometry contentPadding;
  final KeyboardActionsConfig keyboardBuildConfig;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return ContextualPage(
      backLabel: backLabel,
      keyboardBuildConfig: keyboardBuildConfig,
      contentPadding: contentPadding,
      hasBottomBack: hasBottomBack,
      titleColor: Colors.white,
      subtitleColor: Constants.beige,
      topBackTextColor: Colors.white,
      topBackBackgroudColor: Constants.darkBlue,
      bottomBackTextColor: Constants.darkBlue,
      bottomBackBackgroudColor: Constants.yellow,
      textBackgroundColor: Constants.darkBlue,
      backdropEnd: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/darkBlueCases-bottom.svg",
        width: MediaQuery.of(context).size.width)),
      child: child,
      backdrop: <Widget>[
        Positioned(
            left: 0,
            top: 0,
            child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/darkBlueCases-pink.svg",
                width: 50 * sizeMultiplier))),
        Positioned(
            top: 0,
            right: 0,
            child: ExcludeSemantics(child: SvgPicture.asset(
                "assets/svg/backdrops/darkBlueCases-blue.svg",
                width: 165 * sizeMultiplier))),
      ],
      title: this.title,
      subtitle: this.subtitle,
    );
  }
}
