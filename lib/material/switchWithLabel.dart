import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwitchWithLabel extends StatefulWidget {
  const SwitchWithLabel(
      {Key key,
      this.title,
      this.titleStyle = const TextStyle(),
      this.subtitle,
      this.subtitleStyle = const TextStyle(),
      this.infoBubbleCallback,
      this.focusNode,
      @required this.value,
      @required this.onChanged,
      this.activeColor = const Color(0xFF2a8367),
      this.inactiveColor = Constants.darkGrey,
      this.activeText,
      this.inactiveText,
      this.activeTextColor = Colors.white,
      this.inactiveTextColor = Colors.white,
      this.isDisabled = false,
      this.disabledExplanationContent,
      })
      : assert(title != null),
        assert(value != null),
        super(key: key);

  final String title;
  final TextStyle titleStyle;
  final String subtitle;
  final TextStyle subtitleStyle;
  final Function infoBubbleCallback;
  final FocusNode focusNode;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final String activeText;
  final String inactiveText;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final bool isDisabled;
  final Widget disabledExplanationContent;

  @override
  _SwitchWithLabelState createState() => _SwitchWithLabelState();
}

class _SwitchWithLabelState extends State<SwitchWithLabel>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    double screenSize = MediaQuery.of(context).size.width - 32;
    return 
    Column(children: <Widget>[
      Semantics(
          label: widget.value
              ? FlutterI18n.translate(context, "a11y.tapToRefuse")
              : FlutterI18n.translate(context, "a11y.tapToAccept"),
          enabled: !widget.isDisabled,
          button: true,
          selected: widget.value,
          child: GestureDetector(
              onTap: widget.isDisabled ? null : () {
                widget.onChanged(!widget.value);
              },
              child: Stack(children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Constants.lightGrey,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                FractionallySizedBox(
                    widthFactor: 1,
                    child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          FractionallySizedBox(
                              widthFactor:
                                  widget.infoBubbleCallback == null ? 0.6 : 0.54,
                              child: Container(
                                  margin: EdgeInsets.only(
                                      top: 16 * sizeMultiplier,
                                      left: 16 * sizeMultiplier,
                                      bottom: 16 * sizeMultiplier),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            margin: widget.subtitle != null
                                                ? EdgeInsets.only(
                                                    bottom: 8 * sizeMultiplier)
                                                : null,
                                            child: Text(widget.title,
                                                style: TextStyle(
                                                        fontSize:
                                                            14 * sizeMultiplier,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Constants.darkGrey,
                                                        height: 1.3)
                                                    .merge(widget.titleStyle))),
                                        if (widget.subtitle != null)
                                          Text(widget.subtitle,
                                              style: TextStyle(
                                                      fontSize:
                                                          13 * sizeMultiplier,
                                                      color: Constants.darkGrey,
                                                      height: 1.3)
                                                  .merge(widget.subtitleStyle)),
                                      ]))),
                          Container(
                            constraints: BoxConstraints(
                              minWidth: 
                                widget.infoBubbleCallback == null
                                  ? screenSize * 0.4
                                  : screenSize * 0.46,
                              maxWidth: MediaQuery.of(context).textScaleFactor > 1.3 ?
                                screenSize
                                : (widget.infoBubbleCallback == null
                                  ? screenSize * 0.4
                                  : screenSize * 0.46)
                            ),
                            child: Row(
                                mainAxisAlignment: widget.infoBubbleCallback == null ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  if (widget.infoBubbleCallback != null)
                                    Semantics(
                                        label: FlutterI18n.translate(
                                            context, "onboarding.infoLabel") + FlutterI18n.translate(context, "on") + widget.title,
                                        button: true,
                                        container: true,
                                        child: InkWell(
                                            focusNode: widget.focusNode,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100)),
                                            splashColor:
                                                Colors.blue.withAlpha(30),
                                            onTap: widget.infoBubbleCallback,
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              padding: EdgeInsets.all(14),
                                              child: ExcludeSemantics(
                                                  child: SvgPicture.asset('assets/svg/icon-questionmark.svg')),
                                            ))),
                                  Stack(
                                    children: <Widget>[
                                      Container(
                                          margin:
                                              EdgeInsets.fromLTRB(8 * sizeMultiplier,16 * sizeMultiplier,11 * sizeMultiplier,16 * sizeMultiplier),
                                          constraints: BoxConstraints(
                                              minHeight: 28 * sizeMultiplier,
                                              minWidth: 65 * sizeMultiplier),
                                          child: Container(
                                            
                                              constraints: BoxConstraints(
                                                  minHeight: 28 * sizeMultiplier,
                                                  minWidth: 65 * sizeMultiplier),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0 * sizeMultiplier),
                                                  color: widget.isDisabled ? Color(0xFF929798) : (!widget.value
                                                      ? widget.inactiveColor
                                                      : widget.activeColor)),
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 4 * sizeMultiplier,
                                                    bottom: 4 * sizeMultiplier,
                                                    left: !widget.value
                                                        ? 32 * sizeMultiplier
                                                        : 8 * sizeMultiplier,
                                                    right: !widget.value
                                                        ? 8 * sizeMultiplier
                                                        : 32 * sizeMultiplier,
                                                  ),
                                                  child: Center(child:Text(
                                                      widget.value
                                                          ? widget.activeText
                                                          : widget.inactiveText,
                                                      textAlign: !widget.value
                                                          ? TextAlign.right
                                                          : TextAlign.left,
                                                      style: TextStyle(
                                                        height: 1,
                                                          color: widget
                                                              .activeTextColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12 *
                                                              sizeMultiplier)))))),
                                      Positioned(
                                          top: 14 * sizeMultiplier,
                                          left: !widget.value
                                              ? 4 * sizeMultiplier
                                              : null,
                                          right: widget.value
                                              ? 10 * sizeMultiplier
                                              : null,
                                          child: Align(
                                            alignment: widget.value
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Container(
                                                width: 32 * sizeMultiplier,
                                                height: 32 * sizeMultiplier,
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      new BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius:
                                                              3 * sizeMultiplier,
                                                          offset: Offset(0,
                                                              1 * sizeMultiplier)),
                                                    ],
                                                    shape: BoxShape.circle,
                                                    color: widget.isDisabled ? Color(0xFFB6B6B6) : Colors.white)),
                                          )),
                                    ],
                                  )
                                ]),
                          )
                        ]))
              ]))),
              widget.disabledExplanationContent != null && widget.isDisabled ?
              Container(
                decoration: BoxDecoration(
                  color: Constants.lightGrey,
                  borderRadius: BorderRadius.circular(12.0)
                ),
                child: widget.disabledExplanationContent
              ) : Container()
    ]);
  }
}
