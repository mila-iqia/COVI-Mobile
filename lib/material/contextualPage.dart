import 'package:covi/material/customBackButton.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class ContextualPage extends StatelessWidget {
  const ContextualPage({
    @required this.title,
    this.subtitle,
    this.backLabel,
    this.titleColor = Colors.white,
    this.textAlignment = const Alignment(0.0, 0.5),
    this.subtitleColor = Constants.beige,
    this.topBackTextColor = Colors.white,
    this.topBackBackgroudColor = Constants.mediumBlue,
    this.bottomBackTextColor = Constants.darkBlue,
    this.bottomBackBackgroudColor = Constants.yellow,
    this.textBackgroundColor = Constants.mediumBlue,
    this.keyboardBuildConfig,
    @required this.child,
    @required this.backdrop,
    this.backdropEnd,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.hasBottomBack = true,
  }) : assert(
          title != null,
          child != null,
        );

  final String title;
  final String subtitle;
  final String backLabel;
  final Alignment textAlignment;
  final Color titleColor;
  final Color subtitleColor;
  final Color topBackTextColor;
  final Color topBackBackgroudColor;
  final Color bottomBackTextColor;
  final Color bottomBackBackgroudColor;
  final Color textBackgroundColor;
  final Widget child;
  final List<Widget> backdrop;
  final Widget backdropEnd;
  final EdgeInsetsGeometry contentPadding;
  final bool hasBottomBack;
  final KeyboardActionsConfig keyboardBuildConfig;

  Widget buildPage(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    double headerHeight = (273 * sizeMultiplier).round().toDouble();

    return SingleChildScrollView(padding: EdgeInsets.all(0), child:
      RepaintBoundary(
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(minHeight: headerHeight),
                decoration: BoxDecoration(
                    color: textBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                          color: textBackgroundColor,
                          offset: Offset(0.0, 0.0),
                      ),
                      BoxShadow(
                          color: textBackgroundColor,
                          offset: Offset(0.0, 0.0),
                          spreadRadius: 2.0,
                          blurRadius: 0.0,
                      )
                    ]
                ),
                child:
                  Stack(children: <Widget>[
                    Container(
                      height: headerHeight, child: Stack(children: backdrop)),
                    Center(
                      child: Container(
                        constraints: BoxConstraints(minHeight: headerHeight),
                        padding: EdgeInsets.only(top: 80 * sizeMultiplier),
                        width: 260 * sizeMultiplier,
                          child:
                          Align(
                            alignment: textAlignment,
                            child:
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    child: 
                                      Semantics(
                                        label: FlutterI18n.translate(context, "a11y.header1"),
                                        header: true,
                                        child:
                                          Text(title,
                                              textAlign: TextAlign.center,
                                              style: Constants.CustomTextStyle.darkBlue18Text(context)
                                                  .merge(TextStyle(color: titleColor, fontSize: 26 * sizeMultiplier)))
                                      )
                                  ),
                                  if (this.subtitle != null)
                                    Text(this.subtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                                color: subtitleColor, fontSize: 14 * sizeMultiplier, height: 1.3, fontWeight: FontWeight.w500)),
                              ])
                          )
                    )),
                    Positioned(
                      top: 8 + MediaQuery.of(context).padding.top,
                      left: 0,
                      child: CustomBackButton(
                        label: FlutterI18n.translate(context, "back"),
                        a11yLabel: FlutterI18n.translate(context, "goBackTo") + backLabel,
                        backgroundColor: topBackBackgroudColor,
                        textColor: topBackTextColor,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ])
              ),
              backdropEnd,
              Container(padding: this.contentPadding, child: this.child),
              if (hasBottomBack)
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 105,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            bottom: 0,
                            left: 0,
                            child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/yellow-oval.svg'))),
                        Positioned(
                          left: 0,
                          bottom: 16,
                          child: CustomBackButton(
                            label: FlutterI18n.translate(context, "back"),
                            a11yLabel: FlutterI18n.translate(context, "goBackTo") + backLabel,
                            backgroundColor: bottomBackBackgroudColor,
                            textColor: bottomBackTextColor,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        )
                      ],
                    ))
            ],
          )
        )
      );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: <Widget>[
        keyboardBuildConfig != null ?
        KeyboardActions(
          config: keyboardBuildConfig,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child:
              buildPage(context)
          )
        ) :
        buildPage(context),
      Container(color: Constants.darkBlue70, height: MediaQuery.of(context).padding.top),
    ]));
  }
}
