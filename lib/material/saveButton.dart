import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

class SaveButton extends StatefulWidget {
  const SaveButton({
    this.label,
    this.a11yLabel,
    this.liveProcessLabel,
    this.liveDoneLabel,
    this.width,
    this.minWidth,
    this.height,
    this.rightPosition = 12,
    this.borderRadius = 30.0,
    this.padding = const EdgeInsets.all(0),
    this.labelStyle = const TextStyle(),
    this.shadowColor = Colors.black12,
    this.splashColor = Constants.yellowSplash,
    this.backgroundColor = Constants.yellow,
    this.textColor = Constants.darkBlue,
    this.disabledBackgroundColor = Constants.borderGrey,
    this.disabledTextColor = Constants.mediumGrey,
    this.loaderSize = 30,
    this.isValidToSave,
    this.doBeforeLoader,
    this.onPressed,
  });

  final String label;
  final String a11yLabel;
  final String liveProcessLabel;
  final String liveDoneLabel;
  final double width;
  final double minWidth;
  final double height;
  final double rightPosition;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle labelStyle;
  final Color shadowColor;
  final Color splashColor;
  final Color backgroundColor;
  final Color textColor;
  final Color disabledBackgroundColor;
  final Color disabledTextColor;
  final double loaderSize;
  final bool isValidToSave;
  final Function doBeforeLoader;
  final Function onPressed;

  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton>
  with SingleTickerProviderStateMixin {
  double loadingOpacity = 0.0;
  double loadingCheckOpacity = 0.0;
  bool isLoading = false;
  bool isSaved = false;
  Timer loadingTimer;
  Timer saveTimer;
  String savingStatus = "";

  void initState() {
    super.initState();
  }

  static Future<void> announce(String message, TextDirection textDirection) async {
    final AnnounceSemanticsEvent event = AnnounceSemanticsEvent(message, textDirection);
    await SystemChannels.accessibility.send(event.toMap());
  }

  void _startLoader() {
    if (widget.isValidToSave) {
      setState(() {
        announce(widget.liveProcessLabel != null ? widget.liveProcessLabel : FlutterI18n.translate(context, "saving"), TextDirection.ltr);
        isLoading = true;
        if (loadingTimer != null) loadingTimer.cancel();
        loadingTimer = new Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            isLoading = false;
            isSaved = true;
            loadingCheckOpacity = 1.0;
            announce(widget.liveDoneLabel != null ? widget.liveDoneLabel : FlutterI18n.translate(context, "saved"), TextDirection.ltr);

            Future.delayed(const Duration(milliseconds: 2000), () { 
              setState(() => loadingCheckOpacity = 0.0);
            });
          });
          if(saveTimer != null) saveTimer.cancel();
          saveTimer = new Timer(const Duration(seconds: 2), () {
            setState(() {
              isSaved = false;
            });
            widget.onPressed();
          });
        });
      });
    } else {
      widget.onPressed();
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    if(isLoading) setState(() => loadingOpacity = 1.0);
    else setState(() => loadingOpacity = 0.0);

    return 
      Stack(children: <Widget>[
        Container(
            width: widget.width != null ? widget.width * sizeMultiplier : null,
            height: widget.height != null ? widget.height * sizeMultiplier : null,
            constraints: BoxConstraints(
              minHeight: 48 * sizeMultiplier,
              minWidth: widget.minWidth != null ? widget.minWidth : 0,
            ),
            decoration: widget.shadowColor != null && widget.onPressed != null
                ? new BoxDecoration(boxShadow: [
                    new BoxShadow(
                      color: widget.shadowColor,
                      blurRadius: 40.0,
                    ),
                  ])
                : null,
            child: Semantics(
              label: widget.isValidToSave || widget.onPressed == null
                ? widget.label != null ? widget.label : FlutterI18n.translate(context, "save")
                : FlutterI18n.translate(context, "a11y.savingDisabled"),
              button: true,
              enabled: widget.onPressed != null,
              child:
                FlatButton(
                  padding: widget.padding * sizeMultiplier,
                  color: widget.backgroundColor,
                  textColor: widget.textColor,
                  disabledColor: widget.disabledBackgroundColor,
                  disabledTextColor: widget.disabledTextColor,
                  splashColor: widget.splashColor,
                  highlightColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(widget.borderRadius * sizeMultiplier)),
                  child:
                      Text(
                        widget.label != null ? widget.label : FlutterI18n.translate(context, "save"),
                        style: TextStyle(
                          fontSize: 16 * sizeMultiplier,
                          fontFamily: 'Neue',
                          fontWeight: FontWeight.w500).merge(widget.labelStyle)
                      ),
                  onPressed: widget.onPressed != null ? () {
                    if (widget.doBeforeLoader != null) {
                      widget.doBeforeLoader();
                    }
                    _startLoader();
                  } : null)
              )
            ),
            Positioned(
              right: widget.rightPosition * sizeMultiplier,
              top: (((widget.height != null ? widget.height : 48) - widget.loaderSize) / 2) * sizeMultiplier,
              child: SizedBox(
                child: 
                  AnimatedOpacity(
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: 400),
                    opacity: loadingOpacity,
                    child: Center(child: Lottie.asset('assets/animations/blue-loading.json', width: widget.loaderSize * sizeMultiplier)))
                  ,
                height: widget.loaderSize * sizeMultiplier,
                width: widget.loaderSize * sizeMultiplier,
              )
            ),
            Positioned(
              right: 5 * sizeMultiplier,
              top: 15 * sizeMultiplier,
              child: ExcludeSemantics(
                child: Align(
                  alignment: Alignment.centerRight,
                  heightFactor: 0.2,
                  widthFactor: 0.1,
                  child: AnimatedOpacity(
                    curve: Curves.easeInOut,
                    duration: Duration(milliseconds: 300),
                    opacity: loadingCheckOpacity,
                    child: isSaved ? Lottie.asset(
                      'assets/animations/P2-LoadingCheck.json', 
                      width: widget.loaderSize * 1.5 * sizeMultiplier, 
                      fit: BoxFit.fitWidth, 
                      repeat: false
                    ) : Container()  
                  )    
                )
              )
            ),
      ]);
  }
}
