import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';

enum ExpandleCardColors { red, blue, yellow, green }

class ExpandableCard extends StatefulWidget {
  const ExpandableCard({
    @required this.headerText,
    this.headerStyle = const TextStyle(),
    @required this.content,
    this.color,
  }) : assert(headerText != null);

  final String headerText;
  final TextStyle headerStyle;
  final Widget content;
  final ExpandleCardColors color;

  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false;
  final FocusScopeNode contentNode = FocusScopeNode();

  void _toggleExpanded() {
    setState(() {
      if (_isExpanded) {
        _isExpanded = false;
      } else {
        _isExpanded = true;
        contentNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    SvgPicture _ExpCardCircleColor() {
      switch (widget.color) {
        case ExpandleCardColors.red:
          return SvgPicture.asset("assets/svg/red-circle.svg", height: 45 * sizeMultiplier);
          break;
        case ExpandleCardColors.blue:
          return SvgPicture.asset("assets/svg/blue-circle.svg", height: 45 * sizeMultiplier);
          break;
        case ExpandleCardColors.yellow:
          return SvgPicture.asset("assets/svg/yellow-circle.svg", height: 45 * sizeMultiplier);
          break;
        case ExpandleCardColors.green:
          return SvgPicture.asset("assets/svg/green-circle.svg", height: 45 * sizeMultiplier);
          break;
        default:
          return null;
      }
    }

    return Container(
        decoration: BoxDecoration(
            color: Constants.lightGrey,
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Column(
          children: <Widget>[
            Material(
                color: Colors.transparent,
                child:
                  Semantics(
                    label: _isExpanded ? FlutterI18n.translate(context, "a11y.tapToClose") : FlutterI18n.translate(context, "a11y.tapToOpen"),
                    button: true,
                    child:
                      InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        splashColor: Colors.black12,
                        onTap: () => _toggleExpanded(),
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                                border: _isExpanded
                                    ? Border(
                                        bottom: BorderSide(
                                            width: 1, color: Constants.borderGrey))
                                    : null),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(right: 14),
                                      child: ExcludeSemantics(child:_ExpCardCircleColor())),
                                  Expanded(
                                      child: Text(widget.headerText,
                                          style: TextStyle(
                                                  fontSize: 16 * sizeMultiplier,
                                                  height: 1.1,
                                                  fontWeight: FontWeight.w700,
                                                  color: Constants.mediumGrey)
                                              .merge(widget.headerStyle))),
                                  Container(
                                      width: 36 * sizeMultiplier,
                                      padding: EdgeInsets.only(right: 24),
                                      margin: EdgeInsets.only(left: 12),
                                      child: RotatedBox(
                                          quarterTurns: _isExpanded ? 3 : 1,
                                          child: 
                                            ExcludeSemantics(
                                              child:
                                                SvgPicture.asset(
                                                    "assets/svg/arrow-blue.svg",
                                                    height: 12 * sizeMultiplier,
                                                    width: 8 * sizeMultiplier)
                                            )
                                        ))
                                ])),
                      )
                  )
              ),
              Semantics(
                focusable: true,
                child:
                FocusScope(
                  canRequestFocus: _isExpanded,
                  node: contentNode,
                  child: _isExpanded ? widget.content : Container()
                )
              )
          ],
        ));
  }
}
