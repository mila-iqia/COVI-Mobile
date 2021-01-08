import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/material/customButton.dart';

class PreDashboardScreen extends StatefulWidget {
  PreDashboardScreen({key}) : super(key: key);

  _PreDashboardScreenState createState() => _PreDashboardScreenState();
}

class _PreDashboardScreenState extends State<PreDashboardScreen> {
  var logger = Logger();
  double loadingOpacity = 1;
  double statusOpacity = 0;

  @override
  void initState() {
    super.initState();
    new Timer(const Duration(milliseconds: 3000), () {
      setState(() {
        loadingOpacity = 0;
        statusOpacity = 1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            left: true,
            right: true,
            child: SizedBox(
                child: Stack(
              children: <Widget>[
                AnimatedOpacity(
                  curve: Curves.easeIn,
                  duration: Duration(milliseconds: 200),
                  opacity: statusOpacity,
                  child: Center(
                      child: Lottie.asset(
                          'assets/animations/COVI-VaguesLoop-V02.json',
                          width: 320 * sizeMultiplier,
                          fit: BoxFit.fill)),
                ),
                AnimatedOpacity(
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: 200),
                    opacity: loadingOpacity,
                    child: Center(
                        child: Lottie.asset(
                            'assets/animations/COVI-loading-V02.json',
                            width: 190 * sizeMultiplier))),
                AnimatedOpacity(
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: 200),
                    opacity: statusOpacity,
                    child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.2),
                        alignment: Alignment(0, -1),
                        child: SizedBox(
                            width: 280 * sizeMultiplier,
                            height: 140 * sizeMultiplier,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  FlutterI18n.translate(
                                      context, "preDashboard.title"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20 * sizeMultiplier,
                                    color: Constants.darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    FlutterI18n.translate(
                                      context,
                                      "preDashboard.subtitle",
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16 * sizeMultiplier,
                                        color: Constants.darkBlue,
                                        height: 1.5)),
                                ExcludeSemantics(
                                    child: SvgPicture.asset(
                                        'assets/svg/signature.svg',
                                        width: 75 * sizeMultiplier)),
                              ],
                            )))),
                AnimatedOpacity(
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: 200),
                    opacity: statusOpacity,
                    child: Center(
                        child: Container(
                            alignment: Alignment(0, 0.85),
                            child: CustomButton(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20 * sizeMultiplier),
                              backgroundColor: Constants.yellow,
                              label: FlutterI18n.translate(
                                  context, "preDashboard.buttonLabel"),
                              icon: SvgPicture.asset(
                                  'assets/svg/arrow-blue.svg',
                                  color: Constants.darkBlue,
                                  width: 10 * sizeMultiplier),
                              shadowColor: Colors.black12,
                              iconPosition: CustomButtonIconPosition.after,
                              labelStyle: TextStyle(
                                  color: Constants.darkBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 * sizeMultiplier),
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/', (route) => false);
                              },
                            )))),
                Positioned(
                    top: (24 * sizeMultiplier),
                    left: 0,
                    right: 0,
                    child: Container(
                        margin: EdgeInsets.only(bottom: 18 * sizeMultiplier),
                        child: Semantics(
                            label: "Covi",
                            child: SvgPicture.asset("assets/svg/logo.svg",
                                width: 80 * sizeMultiplier)))),
              ],
            ))));
  }
}
