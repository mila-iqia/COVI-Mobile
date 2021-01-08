import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/material/customButton.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';

class ExpandableList extends StatefulWidget {
  const ExpandableList({
    @required this.title,
    this.subtitle,
    this.infoBubbleCallback,
    this.focusNode,
    @required this.content,
  }) : assert(title != null);

  final String title;
  final Widget subtitle;
  final Function infoBubbleCallback;
  final FocusNode focusNode;
  final List<Widget> content;

  _ExpandableListState createState() => _ExpandableListState();
}

class _ExpandableListState extends State<ExpandableList> {
  bool _needMoreButton = false;
  bool _isExpanded = false;
  void _toggleExpanded() {
    setState(() {
      if (_isExpanded) {
        _isExpanded = false;
      } else {
        _isExpanded = true;
      }
    });
  }

  List<Widget> _expandedContent() {
    if (widget.content.length > 4) {
      _needMoreButton = true;
      if (!_isExpanded) {
        return widget.content.sublist(0, 4);
      }
    }
    return widget.content;
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Column(children: <Widget>[
      Container(
          margin: EdgeInsets.only(bottom: widget.subtitle != null ? 0 : 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child:
                  Semantics(
                      label: FlutterI18n.translate(context, "a11y.header2"),
                      header: true,
                      child: Text(widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Constants.darkBlue, fontSize: 18 * sizeMultiplier, fontWeight: FontWeight.w700, height: 1.2)))
              ),
              if(widget.infoBubbleCallback != null)
              Semantics(
                  label: FlutterI18n.translate(context, "onboarding.infoLabel"),
                  button: true,
                  container: true,
                  child: InkWell(
                      focusNode: widget.focusNode,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: widget.infoBubbleCallback,
                      child: Container(
                        height: 48 * sizeMultiplier,
                        width: 48 * sizeMultiplier,
                        padding: EdgeInsets.all(14 * sizeMultiplier),
                        child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/icon-questionmark.svg')),
                      )))
            ],
          )),
      if (widget.subtitle != null)
        Align(
          alignment: Alignment.center,
          child: Container(
              margin: EdgeInsets.only(bottom: 24),
              child: Semantics(label: FlutterI18n.translate(context, "a11y.header3"), header: true, child: widget.subtitle)),
        ),
      Column(
        children: <Widget>[..._expandedContent()],
      ),
      _needMoreButton
          ? Container(
              margin: EdgeInsets.only(top: 24),
              child: CustomButton(
                height: 48,
                width: 200,
                label: _isExpanded ? FlutterI18n.translate(context, "seeLess") : FlutterI18n.translate(context, "seeMore"),
                labelStyle: TextStyle(fontWeight: FontWeight.w700),
                icon: SvgPicture.asset(_isExpanded ? 'assets/svg/minus.svg' : 'assets/svg/plus.svg'),
                iconPosition: CustomButtonIconPosition.after,
                backgroundColor: Constants.transparent,
                textColor: Constants.darkBlue,
                onPressed: () => _toggleExpanded(),
              ))
          : Container()
    ]);
  }
}
