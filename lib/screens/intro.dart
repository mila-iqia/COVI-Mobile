import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:logger/logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/material/customButton.dart';
import 'package:lottie/lottie.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({key}) : super(key: key);

  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  var logger = Logger();
  double backgroundOpacity = 0.0;
  double alternateBackgroundOpacity = 0.0;
  int introIndex = 0;
  double _introAnimationOpacity = 1;
  bool _introAnimationDisplayed = true;
  List<double> screensOpacity = [0.0, 0.0, 0.0, 0.0];
  PageController sliderController = new PageController(viewportFraction: 1);

  @override
  void initState() {
    super.initState();

    // Check for setup after tree has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setBackgroundOpacity(1.0);
      _setActiveSlideScreenOpacity(0);
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      setState(() => _introAnimationOpacity = 0);
      Future.delayed(const Duration(milliseconds: 250), () {
        setState(() => _introAnimationDisplayed = false);
      });
    });
  }

  @override
  void dispose() {
    sliderController.dispose();
    super.dispose();
  }

  void _setBackgroundOpacity(
    double opacity,
  ) {
    setState(() => backgroundOpacity = opacity);
  }

  void _setActiveSlideScreenOpacity(int screenIndex) {
    List<double> newScreensOpacity = [0.0, 0.0, 0.0, 0.0];
    newScreensOpacity[screenIndex] = 1;
    setState(() => screensOpacity = newScreensOpacity);
  }

  void _changeSliderPage(int index) {
    sliderController.animateToPage(index,
        duration: Duration(milliseconds: 600), curve: Curves.easeInOut);
  }

  Widget _slide1(double sizeMultiplier) {
    return AnimatedOpacity(
        opacity: screensOpacity[0],
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
        child: SingleChildScrollView(
            child: Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.64),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Semantics(
                          header: true,
                          label: FlutterI18n.translate(context, "a11y.header2"),
                          child: Text(
                              FlutterI18n.translate(context, "slider.slide") +
                                  (introIndex + 1).toString(),
                              style: TextStyle(
                                  fontSize: 1, color: Colors.transparent))),
                      SizedBox(
                          width: 250 * sizeMultiplier,
                          child: Semantics(
                              header: true,
                              label: FlutterI18n.translate(
                                  context, "a11y.header3"),
                              child: Text(
                                FlutterI18n.translate(context, "intro.title"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 1.2,
                                    color: Constants.yellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20 * sizeMultiplier),
                              ))),
                      Divider(
                          color: Constants.transparent,
                          height: 22 * sizeMultiplier),
                      SizedBox(
                          width: 250 * sizeMultiplier,
                          child: RichText(
                            textAlign: TextAlign.center,
                            textScaleFactor:
                                MediaQuery.of(context).textScaleFactor,
                            text: TextSpan(
                              text: FlutterI18n.translate(
                                  context, "intro.subtitle"),
                              style: TextStyle(
                                height: 1.5,
                                fontFamily: 'Neue',
                                color: Constants.beige,
                                fontSize: 16 * sizeMultiplier,
                              ),
                            ),
                          )),
                      Divider(
                          color: Constants.transparent,
                          height: 40 * sizeMultiplier),
                      Stack(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16 * sizeMultiplier),
                              child: Text(
                                FlutterI18n.translate(context, "intro.swipe"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 1,
                                    color: Color(0xFFabb2c0),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14 * sizeMultiplier),
                              )),
                          Positioned(
                            right: 0,
                            top: (14 * sizeMultiplier) / 2 -
                                (10 * sizeMultiplier) / 2,
                            child: ExcludeSemantics(
                                child: SvgPicture.asset(
                              'assets/svg/arrow-blue.svg',
                              color: Color(0xFFabb2c0),
                              height: 10 * sizeMultiplier,
                            )),
                          )
                        ],
                      )
                    ]))));
  }

  Widget _slide2(double sizeMultiplier) {
    return AnimatedOpacity(
        opacity: screensOpacity[1],
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
        child: SingleChildScrollView(
            child: Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.53),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Semantics(
                          header: true,
                          label: FlutterI18n.translate(context, "a11y.header2"),
                          child: Text(
                              FlutterI18n.translate(context, "slider.slide") +
                                  (introIndex + 1).toString(),
                              style: TextStyle(
                                  fontSize: 1, color: Colors.transparent))),
                      Divider(
                          color: Constants.transparent,
                          height: 40 * sizeMultiplier),
                      AnimatedOpacity(
                          opacity: screensOpacity[1],
                          curve: Curves.easeIn,
                          duration: Duration(milliseconds: 800),
                          child: ClipRect(
                              child: Align(
                                  alignment: Alignment(0, -0.5),
                                  heightFactor: 0.37,
                                  child: ExcludeSemantics(
                                      child: Lottie.asset(
                                          'assets/animations/COVI-P1-Tutoriel-A.json',
                                          repeat: false))))),
                      Divider(
                          color: Constants.transparent,
                          height: 16 * sizeMultiplier),
                      SizedBox(
                          width: 260 * sizeMultiplier,
                          child: Text(
                            FlutterI18n.translate(context, "intro.slide2Title"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.2,
                                color: Constants.beige,
                                fontWeight: FontWeight.bold,
                                fontSize: 20 * sizeMultiplier),
                          )),
                      Divider(
                          color: Constants.transparent,
                          height: 8 * sizeMultiplier),
                      SizedBox(
                          width: 290 * sizeMultiplier,
                          child: Text(
                            FlutterI18n.translate(context, "intro.slide2Text"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.2,
                                color: Constants.beige,
                                fontSize: 16 * sizeMultiplier),
                          )),
                    ]))));
  }

  Widget _slide3(double sizeMultiplier) {
    return AnimatedOpacity(
        opacity: screensOpacity[2],
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
        child: SingleChildScrollView(
            child: Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.64),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Semantics(
                          header: true,
                          label: FlutterI18n.translate(context, "a11y.header2"),
                          child: Text(
                              FlutterI18n.translate(context, "slider.slide") +
                                  (introIndex + 1).toString(),
                              style: TextStyle(
                                  fontSize: 1, color: Colors.transparent))),
                      ClipRect(
                          child: Align(
                              alignment: Alignment(0, -0.6),
                              heightFactor: 0.4,
                              child: ExcludeSemantics(
                                  child: Lottie.asset(
                                      'assets/animations/COVI-P1-Tutoriel-B.json',
                                      repeat: false)))),
                      Divider(
                          color: Constants.transparent,
                          height: 21 * sizeMultiplier),
                      SizedBox(
                          width: 260 * sizeMultiplier,
                          child: Text(
                            FlutterI18n.translate(context, "intro.slide3Title"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.2,
                                color: Constants.beige,
                                fontWeight: FontWeight.bold,
                                fontSize: 20 * sizeMultiplier),
                          )),
                      Divider(
                          color: Constants.transparent,
                          height: 8 * sizeMultiplier),
                      SizedBox(
                          width: 290 * sizeMultiplier,
                          child: Text(
                            FlutterI18n.translate(context, "intro.slide3Text"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.2,
                                color: Constants.beige,
                                fontSize: 16 * sizeMultiplier),
                          )),
                    ]))));
  }

  Widget _slide4(double sizeMultiplier) {
    return AnimatedOpacity(
        opacity: screensOpacity[3],
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
        child: SingleChildScrollView(
            child: Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.64),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Semantics(
                          header: true,
                          label: FlutterI18n.translate(context, "a11y.header2"),
                          child: Text(
                              FlutterI18n.translate(context, "slider.slide") +
                                  (introIndex + 1).toString(),
                              style: TextStyle(
                                  fontSize: 1, color: Colors.transparent))),
                      ClipRect(
                          child: Align(
                              alignment: Alignment(0, -0.58),
                              heightFactor: 0.42,
                              child: ExcludeSemantics(
                                  child: Lottie.asset(
                                      'assets/animations/COVI-P1-Tutoriel-C.json',
                                      repeat: false)))),
                      Divider(
                          color: Constants.transparent,
                          height: 16 * sizeMultiplier),
                      SizedBox(
                          width: 260 * sizeMultiplier,
                          child: Text(
                            FlutterI18n.translate(context, "intro.slide4Title"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.2,
                                color: Constants.beige,
                                fontWeight: FontWeight.bold,
                                fontSize: 20 * sizeMultiplier),
                          )),
                      Divider(
                          color: Constants.transparent,
                          height: 8 * sizeMultiplier),
                      SizedBox(
                          width: 290 * sizeMultiplier,
                          child: Text(
                            FlutterI18n.translate(context, "intro.slide4Text"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.2,
                                color: Constants.beige,
                                fontSize: 16 * sizeMultiplier),
                          )),
                    ]))));
  }

  List<Widget> _generateSliderTicks(double sizeMultiplier) {
    return new List<Widget>.generate(4, (i) {
      return i == introIndex
          ? Semantics(
              label: FlutterI18n.translate(context, "slider.slide") +
                  " " +
                  (i + 1).toString() +
                  FlutterI18n.translate(context, "slider.of") +
                  " 4" +
                  FlutterI18n.translate(context, "slider.currentslide"),
              child: Container(
                  padding: EdgeInsets.all(4 * sizeMultiplier),
                  child: Container(
                      width: 10 * sizeMultiplier,
                      height: 10 * sizeMultiplier,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFFf6f0e9)))))
          : Semantics(
              label: FlutterI18n.translate(context, "slider.slide") +
                  (i + 1).toString() +
                  FlutterI18n.translate(context, "slider.of") +
                  " 4",
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(100.0)),
                      onTap: () {
                        _changeSliderPage(i);
                      },
                      child: Container(
                          padding: EdgeInsets.all(4 * sizeMultiplier),
                          child: Container(
                            padding: EdgeInsets.all(8 * sizeMultiplier),
                            width: 8 * sizeMultiplier,
                            height: 8 * sizeMultiplier,
                            decoration: BoxDecoration(
                              color: Constants.darkBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Color(0xFFf6f0e9),
                                  width: 2 * sizeMultiplier),
                            ),
                          )))));
    });
  }

  static Future<void> announce(
      String message, TextDirection textDirection) async {
    final AnnounceSemanticsEvent event =
        AnnounceSemanticsEvent(message, textDirection);
    await SystemChannels.accessibility.send(event.toMap());
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    // Provider.of<SettingsManager>(context).loadLang(context);
    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          color: Constants.darkBlue,
          child: SingleChildScrollView(
              child: Stack(
            children: <Widget>[
              Positioned(
                  top: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: backgroundOpacity,
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: 700),
                    child: Lottie.asset(
                        'assets/animations/P2-WelcomeToCovi.json',
                        repeat: true,
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height),
                  )),
              // Positioned(
              //     top: 0,
              //     right: 0,
              //     child: AnimatedOpacity(
              //         opacity: backgroundOpacity,
              //         curve: Curves.easeIn,
              //         duration: Duration(milliseconds: 700),
              //         child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/intro-yellow.svg", height: 120 * sizeMultiplier)))),
              // Positioned(
              //     top: 70 * sizeMultiplier,
              //     left: 0,
              //     child: AnimatedOpacity(
              //         opacity: backgroundOpacity,
              //         curve: Curves.easeIn,
              //         duration: Duration(milliseconds: 500),
              //         child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/intro-red.svg", width: 80 * sizeMultiplier)))),
              // Positioned(
              //     top: 55 * sizeMultiplier,
              //     left: 80 * sizeMultiplier,
              //     child: AnimatedOpacity(
              //         opacity: backgroundOpacity,
              //         curve: Curves.easeIn,
              //         duration: Duration(milliseconds: 500),
              //         child: ExcludeSemantics(
              //             child: SvgPicture.asset("assets/svg/backdrops/intro-green.svg", width: 16 * sizeMultiplier, height: 16 * sizeMultiplier)))),
              // Positioned(
              //     bottom: 0,
              //     left: 0,
              //     child: AnimatedOpacity(
              //         opacity: introIndex == 0 ? backgroundOpacity : 0,
              //         curve: Curves.easeIn,
              //         duration: Duration(milliseconds: 500),
              //         child: ExcludeSemantics(child: SvgPicture.asset("assets/svg/backdrops/intro-blue.svg", width: 170 * sizeMultiplier)))),
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15),
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Semantics(
                          header: true,
                          label: FlutterI18n.translate(context, "a11y.header1"),
                          child: Text("Introduction",
                              style: TextStyle(
                                  fontSize: 1, color: Colors.transparent))),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.64,
                          width: MediaQuery.of(context).size.width,
                          child: PageView(
                            controller: sliderController,
                            onPageChanged: (int index) {
                              if (index < 1) {
                                _setBackgroundOpacity(1.0);
                              } else {
                                _setBackgroundOpacity(0.0);
                              }
                              _setActiveSlideScreenOpacity(index);
                              setState(() => introIndex = index);
                            },
                            children: <Widget>[
                              _slide1(sizeMultiplier),
                              _slide2(sizeMultiplier),
                              _slide3(sizeMultiplier),
                              _slide4(sizeMultiplier),
                            ],
                          )),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 60 * sizeMultiplier,
                                height: 48 * sizeMultiplier,
                                child: introIndex != 0
                                    ? MergeSemantics(
                                        child: Semantics(
                                            label: FlutterI18n.translate(
                                                    context, "slider.goTo") +
                                                FlutterI18n.translate(
                                                    context, "slider.slide") +
                                                (introIndex).toString() +
                                                FlutterI18n.translate(
                                                    context, "slider.of") +
                                                " 4",
                                            child: FlatButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                                .circular(
                                                            30 *
                                                                sizeMultiplier)),
                                                splashColor: Colors.black12,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: ExcludeSemantics(
                                                    child: SvgPicture.asset(
                                                  'assets/svg/arrow-back.svg',
                                                  color: Colors.white,
                                                )),
                                                onPressed: introIndex == 0
                                                    ? null
                                                    : () {
                                                        _changeSliderPage(
                                                            introIndex - 1);
                                                        announce(
                                                            FlutterI18n.translate(
                                                                    context,
                                                                    "slider.slide") +
                                                                (introIndex + 1)
                                                                    .toString() +
                                                                FlutterI18n
                                                                    .translate(
                                                                        context,
                                                                        "slider.displayed"),
                                                            TextDirection.ltr);
                                                      })))
                                    : Container()),
                            SizedBox(
                              child: Row(
                                children: _generateSliderTicks(sizeMultiplier),
                              ),
                            ),
                            Container(
                                width: 60 * sizeMultiplier,
                                height: 48 * sizeMultiplier,
                                child: introIndex != 3
                                    ? MergeSemantics(
                                        child: Semantics(
                                            label: FlutterI18n.translate(
                                                    context, "slider.goTo") +
                                                FlutterI18n.translate(
                                                    context, "slider.slide") +
                                                (introIndex + 2).toString() +
                                                FlutterI18n.translate(
                                                    context, "slider.of") +
                                                " 4",
                                            child: FlatButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                                .circular(
                                                            30 *
                                                                sizeMultiplier)),
                                                splashColor: Colors.black12,
                                                highlightColor:
                                                    Colors.transparent,
                                                child: ExcludeSemantics(
                                                    child: RotatedBox(
                                                        quarterTurns: 2,
                                                        child: SvgPicture.asset(
                                                          'assets/svg/arrow-back.svg',
                                                          color: Colors.white,
                                                        ))),
                                                onPressed: introIndex == 3
                                                    ? null
                                                    : () {
                                                        _changeSliderPage(
                                                            introIndex + 1);
                                                        announce(
                                                            FlutterI18n.translate(
                                                                    context,
                                                                    "slider.slide") +
                                                                (introIndex + 1)
                                                                    .toString() +
                                                                FlutterI18n
                                                                    .translate(
                                                                        context,
                                                                        "slider.displayed"),
                                                            TextDirection.ltr);
                                                      })))
                                    : Container()),
                          ]),
                      Container(
                          margin: EdgeInsets.only(bottom: 16 * sizeMultiplier),
                          child: Center(
                            child: AnimatedCrossFade(
                              duration: const Duration(milliseconds: 200),
                              firstChild: CustomButton(
                                  label: FlutterI18n.translate(
                                      context, "intro.skip"),
                                  minWidth: 200,
                                  backgroundColor: Constants.transparent,
                                  textColor: Color(0xFFabb2c0),
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed("/intro-privacy")),
                              secondChild: CustomButton(
                                  label: FlutterI18n.translate(
                                      context, "intro.gotIt"),
                                  minWidth: 200,
                                  backgroundColor: Constants.transparent,
                                  textColor: Color(0xFFabb2c0),
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed("/intro-privacy")),
                              crossFadeState: introIndex != 3
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                            ),
                          )),
                    ]),
              ),
              Positioned(
                  top: (24 * sizeMultiplier) +
                      MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: Container(
                      margin: EdgeInsets.only(bottom: 18 * sizeMultiplier),
                      child: Semantics(
                          label: "Covi",
                          child: SvgPicture.asset("assets/svg/logo-covi.svg",
                              width: 78 * sizeMultiplier,
                              height: 32 * sizeMultiplier))))
            ],
          ))),
      Container(
          color: Constants.darkBlue70,
          height: MediaQuery.of(context).padding.top),
      if (_introAnimationDisplayed)
        AnimatedOpacity(
            opacity: _introAnimationOpacity,
            curve: Curves.easeIn,
            duration: Duration(milliseconds: 200),
            child: Container(
                height: MediaQuery.of(context).size.height,
                color: Constants.darkBlue,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Lottie.asset(
                        'assets/animations/COVI-P1-Ouverture.json',
                        repeat: false,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                        width: MediaQuery.of(context).size.width)))),
    ]));
  }
}
