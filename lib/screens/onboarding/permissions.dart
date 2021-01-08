import 'dart:async';

import 'package:covi/material/customButton.dart';
import 'package:covi/utils/permissions.dart';
import 'package:covi/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:provider/provider.dart';

class Permissions extends StatelessWidget {
  const Permissions(
      {@required this.validityHandler,
      @required this.userHasAllowedPermissions})
      : assert(validityHandler != null);

  final Function validityHandler;
  final bool userHasAllowedPermissions;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    Timer.run(() => validityHandler(true));
    return FutureBuilder<String>(
        future: Provider.of<SettingsManager>(context, listen: false).getLang(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          String lang = "en";
          if (snapshot.hasData) {
            lang = snapshot.data;
          }

          return Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                children: <Widget>[
                  Semantics(
                      header: true,
                      label: FlutterI18n.translate(context, "a11y.header2"),
                      child: Text(
                          FlutterI18n.translate(
                              context, "onboarding.permissions.header2"),
                          style: TextStyle(
                              fontSize: 1, color: Colors.transparent))),
                  if (!userHasAllowedPermissions)
                    Stack(children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(bottom: 24 * sizeMultiplier),
                          child: Container(
                              padding: const EdgeInsets.only(
                                  top: 24, left: 32, right: 32, bottom: 48),
                              decoration: BoxDecoration(
                                color: Constants.lightRed,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                  FlutterI18n.translate(
                                      context, "onboarding.permissions.error"),
                                  textAlign: TextAlign.center,
                                  style: Constants.CustomTextStyle
                                          .darkBlue14Text(context)
                                      .merge(TextStyle(
                                          fontSize: 14 * sizeMultiplier))))),
                      Positioned(
                          bottom: 5 * sizeMultiplier,
                          width: MediaQuery.of(context).size.width * 1 -
                              32 * sizeMultiplier,
                          child: Center(
                              child: CustomButton(
                                  label: FlutterI18n.translate(context,
                                      "onboarding.permissions.settingsButton"),
                                  labelStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14 * sizeMultiplier),
                                  iconPosition: CustomButtonIconPosition.after,
                                  backgroundColor: Constants.pinkRed,
                                  minHeight: 36,
                                  height: 8 * sizeMultiplier,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 0),
                                  splashColor: Constants.blueSplash,
                                  textColor: Constants.darkBlue,
                                  onPressed: () {
                                    PermissionsManager.openAppSettings();
                                  })))
                    ]),
                  if (userHasAllowedPermissions)
                    Container(
                        margin: EdgeInsets.only(bottom: 20 * sizeMultiplier),
                        child: Text(
                            FlutterI18n.translate(
                                context, "onboarding.permissions.title"),
                            textAlign: TextAlign.center,
                            style:
                                Constants.CustomTextStyle.grey14Text(context))),
                  Container(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.34),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ExcludeSemantics(
                                child: Stack(
                              children: <Widget>[
                                Container(
                                    height: 190 * sizeMultiplier,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/img/iphone-blur.png'),
                                            fit: BoxFit.fitHeight))),
                                Container(
                                    height: 190 * sizeMultiplier,
                                    alignment: Alignment(0.0, 0.4),
                                    child: Container(
                                        decoration: new BoxDecoration(
                                            borderRadius: new BorderRadius.all(
                                              new Radius.circular(20.0),
                                            ),
                                            boxShadow: [
                                              new BoxShadow(
                                                color: Colors.black12,
                                                spreadRadius: -15.0,
                                                blurRadius: 20.0,
                                              ),
                                            ]),
                                        child: lang == "en"
                                            ? SvgPicture.asset(
                                                'assets/svg/fake-modal.svg',
                                                width: 200 * sizeMultiplier)
                                            : SvgPicture.asset(
                                                'assets/svg/fake-modal-fr.svg',
                                                width: 200 * sizeMultiplier))),
                              ],
                            ))
                          ]))
                ],
              ));
        });
  }
}
