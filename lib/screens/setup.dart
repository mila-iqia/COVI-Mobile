import 'package:covi/utils/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/material/customButton.dart';
import 'package:provider/provider.dart';

class SetupScreen extends StatefulWidget {
  SetupScreen({key}) : super(key: key);

  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  var logger = Logger();
  double opacityLevel = 0.0;

  void _setOpacity() {
    setState(() => opacityLevel = 1.0);
  }

  @override
  void initState() {
    super.initState();

    // Check for setup after tree has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setOpacity();
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    SettingsManager settingsManager = Provider.of<SettingsManager>(context);

    return LogConsoleOnShake(
        child: Scaffold(
            body: Stack(children: <Widget>[
      Container(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          color: Constants.darkBlue,
          child: SingleChildScrollView(
            child: AnimatedOpacity(
              opacity: opacityLevel,
              curve: Curves.easeIn,
              duration: Duration(milliseconds: 500),
              child: Stack(
                children: <Widget>[
                  Positioned(
                      left: 0,
                      top: 0,
                      child: ExcludeSemantics(
                          child: SvgPicture.asset(
                              "assets/svg/backdrops/setup-red.svg",
                              height: 95 * sizeMultiplier))),
                  Positioned(
                      left: 30 * sizeMultiplier,
                      top: 0,
                      child: ExcludeSemantics(
                          child: SvgPicture.asset(
                              "assets/svg/backdrops/setup-green.svg",
                              height: 170 * sizeMultiplier))),
                  Positioned(
                      left: 0,
                      top: 30 * sizeMultiplier,
                      child: ExcludeSemantics(
                          child: SvgPicture.asset(
                              "assets/svg/backdrops/setup-blue.svg",
                              width: 265 * sizeMultiplier))),
                  Positioned(
                      left: 215 * sizeMultiplier,
                      top: 0,
                      child: ExcludeSemantics(
                          child: SvgPicture.asset(
                              "assets/svg/backdrops/setup-blue-2.svg",
                              width: 50 * sizeMultiplier))),
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.4),
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(children: [
                            Semantics(
                                header: true,
                                label: "Level 1 header. Titre de niveau 1",
                                child: Text(
                                    "Application setup. Configuration de l'application.",
                                    style: TextStyle(
                                        fontSize: 1,
                                        color: Colors.transparent))),
                            Container(
                                margin: EdgeInsets.only(
                                    bottom: 28 * sizeMultiplier),
                                child: kDebugMode
                                    ? GestureDetector(
                                        onLongPress: () {
                                          Navigator.of(context)
                                              .pushNamed("/test");
                                        },
                                        child: Semantics(
                                            label: "Covi",
                                            child: SvgPicture.asset(
                                                "assets/svg/logo-covi.svg",
                                                width: 146 * sizeMultiplier,
                                                height: 59 * sizeMultiplier)))
                                    : Semantics(
                                        label: "Covi",
                                        child: SvgPicture.asset(
                                            "assets/svg/logo-covi.svg",
                                            width: 146 * sizeMultiplier,
                                            height: 59 * sizeMultiplier))),
                            Text("In motion. Together.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Constants.yellow,
                                    fontSize: 18 * sizeMultiplier,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2)),
                            Padding(
                                padding: EdgeInsetsDirectional.only(
                                    top: 6 * sizeMultiplier),
                                child: Text("En mouvement. Ensemble.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Constants.yellow,
                                        fontSize: 14 * sizeMultiplier,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w500))),
                          ]),
                          Container(
                            padding: EdgeInsets.all(30 * sizeMultiplier),
                            child: Wrap(
                              runSpacing: 16,
                              children: <Widget>[
                                CustomButton(
                                    label: "English",
                                    minWidth:
                                        MediaQuery.of(context).size.width *
                                                0.5 -
                                            (4 * sizeMultiplier) -
                                            (30 * sizeMultiplier),
                                    shadowColor: Colors.black38,
                                    backgroundColor: Constants.mediumBlue,
                                    splashColor: Constants.blueSplash,
                                    textColor: Constants.beige,
                                    onPressed: () async {
                                      await settingsManager.setLang("en");
                                      await settingsManager.loadLang(context);
                                      Navigator.of(context).pushNamed("/intro");
                                    }),
                                Container(width: 8 * sizeMultiplier),
                                CustomButton(
                                    label: "Français",
                                    minWidth:
                                        MediaQuery.of(context).size.width *
                                                0.5 -
                                            (4 * sizeMultiplier) -
                                            (30 * sizeMultiplier),
                                    shadowColor: Colors.black38,
                                    backgroundColor: Constants.mediumBlue,
                                    splashColor: Constants.blueSplash,
                                    textColor: Constants.beige,
                                    onPressed: () async {
                                      await settingsManager.setLang("fr");
                                      await settingsManager.loadLang(context);
                                      Navigator.of(context).pushNamed("/intro");
                                    }),
                              ],
                            ),
                          )
                        ]),
                  ),
                ],
              ),
            ),
          )),
      Container(
          color: Constants.darkBlue70,
          height: MediaQuery.of(context).padding.top)
    ])));
  }
}
