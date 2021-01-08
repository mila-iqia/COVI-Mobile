import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/extensions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum ActionCardColor { red, green, blue, gradientBlue, yellow, beige }

class ActionCard extends StatelessWidget {
  const ActionCard({
    this.title,
    this.content,
    this.lastUpdate,
    this.alternateLastUpdate = false,
    this.button,
    this.semanticLabel,
    this.margin = const EdgeInsets.symmetric(vertical: 5),
    this.backgroundColor = Constants.lightGrey,
    this.circleColor,
    this.iconPadding = 0.0,
    this.cardPadding = 16,
    this.icon,
    this.iconWidth = 57,
    this.onTap,
  });

  final String title;
  final Widget content;
  final DateTime lastUpdate;
  final bool alternateLastUpdate;
  final Widget button;
  final String semanticLabel;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;
  final ActionCardColor circleColor;
  final double iconPadding;
  final double cardPadding;
  final Widget icon;
  final double iconWidth;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    SettingsManager settingsManager = Provider.of<SettingsManager>(context, listen: false);
    SvgPicture _cCardCircleColor() {
      switch (circleColor) {
        case ActionCardColor.red:
          return SvgPicture.asset("assets/svg/ccard-oval-red.svg", width: 50 * sizeMultiplier);
          break;
        case ActionCardColor.blue:
          return SvgPicture.asset("assets/svg/ccard-oval-blue.svg", width: 50 * sizeMultiplier);
          break;
        case ActionCardColor.gradientBlue:
          return SvgPicture.asset("assets/svg/half-circle-blue.svg", width: 50 * sizeMultiplier);
          break;
        case ActionCardColor.yellow:
          return SvgPicture.asset("assets/svg/ccard-oval-yellow.svg", width: 50 * sizeMultiplier);
          break;
        case ActionCardColor.green:
          return SvgPicture.asset("assets/svg/ccard-oval-green.svg", width: 50 * sizeMultiplier);
          break;
        case ActionCardColor.beige:
          return SvgPicture.asset("assets/svg/ccard-oval-beige.svg", width: 50 * sizeMultiplier);
          break;
        default:
          return null;
      }
    }

    Widget _parseUpdatedDate(DateTime date, String locale) {
      String dateString = date.isToday() ? "${FlutterI18n.translate(context, "today")}, ${FlutterI18n.translate(context, "at")} ${new DateFormat.jm(locale).format(date)}" : new DateFormat.MMMMd(locale).add_y().format(date);
      TextStyle style = TextStyle(height: 1, color: Color(0xFF62696a), fontStyle: FontStyle.italic, fontSize: 12 * sizeMultiplier);
      return Padding(
        padding: EdgeInsets.only(top: 8 * sizeMultiplier),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExcludeSemantics(
            child:
              alternateLastUpdate ? SvgPicture.asset('assets/svg/icon-check.svg', height: 12 * sizeMultiplier) : SvgPicture.asset('assets/svg/icon-clock.svg', height: 12 * sizeMultiplier),
          ),
          Flexible(child: alternateLastUpdate ? Text('  ${dateString}', style: style) : Text('  ${FlutterI18n.translate(context, "lastUpdated")}: ${dateString}', style: style))
        ],
      ));
    }

    return FutureBuilder<String>(
        future: settingsManager.getLang(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          String locale = "en";
          if (snapshot.hasData) {
            locale = snapshot.data;
          }
          return Card(
              elevation: 0,
              margin: this.margin,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: backgroundColor,
              child: Semantics(
                  label: semanticLabel,
                  link: true,
                  child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: this.onTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: cardPadding),
                        child: Stack(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if (circleColor != null || icon != null)
                                  ExcludeSemantics(
                                      child: Container(
                                          width: this.iconWidth,
                                          margin: EdgeInsets.only(right: 8),
                                          child: Stack(
                                            alignment: AlignmentDirectional.center,
                                            children: <Widget>[
                                              if (circleColor != null) Container(alignment: Alignment(-1.0, 0.0), child: _cCardCircleColor()),
                                              if (icon != null)
                                                Container(padding: EdgeInsets.only(left: iconPadding), alignment: Alignment(-0.3, 0.0), child: icon)
                                            ],
                                          ))),
                                Expanded(
                                    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                  if (this.title != null)
                                    Text(title, style: Constants.CustomTextStyle.grey14Text(context).merge(TextStyle(fontWeight: FontWeight.w500))),
                                  if (this.content != null) Container(margin: const EdgeInsets.only(top: 2), child: content),
                                  if (this.lastUpdate != null)
                                    Container(margin: const EdgeInsets.only(top: 2), child: _parseUpdatedDate(this.lastUpdate, locale)),
                                ])),
                                Container(width: 57, child: ExcludeSemantics(child: button)),
                              ],
                            ),
                          ],
                        ),
                      ))));
        });
  }
}
