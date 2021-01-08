import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';

enum Backdrops { wave, mapPin, arrows }

class GenericTitleLayout extends StatelessWidget {
  const GenericTitleLayout({
    @required this.title,
    this.subtitle,
    this.titleColor = Constants.darkBlue,
    this.textAlignment = const Alignment(0.0, 0.0),
    this.subtitleColor = Constants.darkBlue,
    @required this.child,
    @required this.backdropChoice,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
  }) : assert(
          title != null,
          child != null,
        );

  final String title;
  final String subtitle;
  final Alignment textAlignment;
  final Color titleColor;
  final Color subtitleColor;
  final Widget child;
  final Backdrops backdropChoice;
  final EdgeInsetsGeometry contentPadding;

  List<Widget> _buildBackdrop(Backdrops backdropChoice, BuildContext context, double sizeMultiplier) {
    switch (backdropChoice) {
      case Backdrops.wave:
        return <Widget>[
          Positioned(right: 0, top: 0, child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/backdrops/myHealth.svg', height: 120 * sizeMultiplier))),
          Positioned(
              top: 18 * sizeMultiplier + MediaQuery.of(context).padding.top,
              left: 28 * sizeMultiplier,
              child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/dot.svg", color: Constants.yellow, width: 18 * sizeMultiplier)))
        ];
        break;
      case Backdrops.mapPin:
        return <Widget>[
          Positioned(
              right: 0, top: 0, child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/backdrops/mediumBlue-shape.svg', width: 100 * sizeMultiplier))),
          Positioned(
              top: 18 * sizeMultiplier + MediaQuery.of(context).padding.top,
              left: 28 * sizeMultiplier,
              child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/dot.svg", color: Constants.darkBlue, width: 18 * sizeMultiplier)))
        ];
        break;
      case Backdrops.arrows:
        return <Widget>[
          Positioned(
              right: 0,
              top: 10 * sizeMultiplier,
              child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/backdrops/resources-arrows.svg', width: 160 * sizeMultiplier))),
          Positioned(
              top: 18 * sizeMultiplier + MediaQuery.of(context).padding.top,
              left: 28 * sizeMultiplier,
              child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/dot.svg", width: 18 * sizeMultiplier)))
        ];
        break;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    double sizeMultiplier = MediaQuery.of(parentContext).size.width / 320;
    double headerHeight = (backdropChoice == Backdrops.mapPin ? 165 * sizeMultiplier : backdropChoice == Backdrops.wave ? 185 * sizeMultiplier : 130 * sizeMultiplier).round().toDouble();
    Color backgroundColor = Constants.lightGrey;

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(children: <Widget>[
            SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(0),
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(minHeight: headerHeight),
                          decoration: BoxDecoration(color: backgroundColor, boxShadow: [
                            BoxShadow(
                              color: backgroundColor,
                              offset: Offset(0.0, 0.0),
                            ),
                            BoxShadow(
                              color: backgroundColor,
                              offset: Offset(0.0, 0.0),
                              spreadRadius: 2.0,
                              blurRadius: 0.0,
                            )
                          ]),
                        ),
                        ExcludeSemantics(child: SvgPicture.asset('assets/svg/backdrops/genericTitle-bg.svg', color: backgroundColor, width: 320 * sizeMultiplier)),
                      ],
                    ),
                    ..._buildBackdrop(backdropChoice, context, sizeMultiplier),
                    Column(children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(
                              24 * sizeMultiplier, 56 * sizeMultiplier + MediaQuery.of(context).padding.top, 24 * sizeMultiplier, 24 * sizeMultiplier),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Semantics(
                                      label: FlutterI18n.translate(context, "a11y.header1"),
                                      header: true,
                                      child: Text(title,
                                          textAlign: TextAlign.left,
                                          style: Constants.CustomTextStyle.darkBlue18Text(context)
                                              .merge(TextStyle(color: titleColor, fontSize: 26 * sizeMultiplier))))),
                              if (this.subtitle != null)
                                Padding(
                                    padding: EdgeInsets.only(top: 8 * sizeMultiplier),
                                    child: Text(this.subtitle,
                                        textAlign: TextAlign.left, style: TextStyle(color: subtitleColor, fontSize: 14 * sizeMultiplier, height: 1.3))),
                            ],
                          )),
                      Container(padding: this.contentPadding, child: this.child),
                    ])
                  ],
                )),
            Container(color: Constants.darkBlue70, height: MediaQuery.of(context).padding.top)
          ]));
    });
  }
}
