import 'package:covi/material/customButton.dart';
import 'package:covi/material/externalLink.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:covi/utils/constants.dart' as Constants;

enum ShareModalType{intro, profile}

class DataShareModal extends StatelessWidget {
  const DataShareModal({
    @required this.closeCallback,
    @required this.type,
  }) : assert(closeCallback != null),
       assert(closeCallback != null);

  final ShareModalType type;
  final Function closeCallback;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url})';
    }
  }

  Widget buildIntroContent(BuildContext context, double sizeMultiplier, TextStyle headerStyle, TextStyle textStyle) {
    TextStyle listTextStyle = Constants.CustomTextStyle.grey14Text(context).merge(TextStyle(fontWeight: FontWeight.w500));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Text(
            FlutterI18n.translate(
                context, "onboarding.consent.dialogSubtitle"),
            style: textStyle,
            textAlign: TextAlign.left,
          )),
      Text(
          FlutterI18n.translate(
              context, "onboarding.consent.infoDesc1"),
          style: listTextStyle,
          textAlign: TextAlign.left),
      Divider(color: Colors.transparent, height: 8 * sizeMultiplier),
      Text(
          FlutterI18n.translate(
              context, "onboarding.consent.infoDesc2"),
          style: listTextStyle,
          textAlign: TextAlign.left),
      Divider(color: Colors.transparent, height: 8 * sizeMultiplier),
      Text(
          FlutterI18n.translate(
              context, "onboarding.consent.infoDesc3"),
          style: listTextStyle,
          textAlign: TextAlign.left),
      Divider(color: Colors.transparent, height: 8 * sizeMultiplier),
      Text(
          FlutterI18n.translate(
              context, "onboarding.consent.infoDesc4"),
          style: listTextStyle,
          textAlign: TextAlign.left),
      Divider(color: Colors.transparent, height: 8 * sizeMultiplier),
      Text(
          FlutterI18n.translate(
              context, "onboarding.consent.infoDesc5"),
          style: listTextStyle,
          textAlign: TextAlign.left),
      Divider(color: Colors.transparent, height: 8 * sizeMultiplier),
      Text(
          FlutterI18n.translate(
              context, "onboarding.consent.infoDesc6"),
          style: listTextStyle,
          textAlign: TextAlign.left),
      Divider(color: Colors.transparent, height: 8 * sizeMultiplier),
      Text(
          FlutterI18n.translate(
              context, "onboarding.consent.infoDesc7"),
          style: listTextStyle,
          textAlign: TextAlign.left),
      Divider(color: Colors.transparent, height: 8 * sizeMultiplier),
      Container(
          margin: EdgeInsets.only(top: 24, bottom: 4),
          alignment: Alignment.centerLeft,
          child: Semantics(
              label: FlutterI18n.translate(context, "a11y.header2"),
              header: true,
              child: Text(
                  FlutterI18n.translate(
                      context, "onboarding.consent.riskScoreTitle"),
                  style: headerStyle,
                  textAlign: TextAlign.left))),
      Text(
          FlutterI18n.translate(
              context, "onboarding.consent.riskScoreContent"),
          style: textStyle,
          textAlign: TextAlign.left),
      Container(
          margin: EdgeInsets.only(top: 24, bottom: 4),
          alignment: Alignment.centerLeft,
          child: Semantics(
              label: FlutterI18n.translate(context, "a11y.header2"),
              header: true,
              child: Text(
                  FlutterI18n.translate(
                      context, "onboarding.consent.analyticsTitle"),
                  style: headerStyle,
                  textAlign: TextAlign.left))),
      Text(
          FlutterI18n.translate(
              context, "onboarding.consent.analyticsContent"),
          style: textStyle),
      Container(
          padding: EdgeInsets.symmetric(vertical: 24),
          alignment: Alignment.center,
          child: ExternalLink(
            label: FlutterI18n.translate(
                context, "onboarding.consent.moreInformation"),
            onTap: () => {
              _launchURL(FlutterI18n.translate(
                  context, "privacyPolicyURL"))
            },
          ))
    ]);
  }

  Widget buildProfileContent(BuildContext context, double sizeMultiplier, TextStyle headerStyle, TextStyle textStyle) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      Container(
          margin: EdgeInsets.only(top: 24 * sizeMultiplier, bottom: 8 * sizeMultiplier),
          alignment: Alignment.centerLeft,
          child: Semantics(
              label: FlutterI18n.translate(context, "a11y.header2"),
              header: true,
              child: Text(FlutterI18n.translate(context, "onboarding.dataShare.modal.nonIdentifyingTitle"),
                  style: headerStyle, textAlign: TextAlign.left))),
      Text(FlutterI18n.translate(context, "onboarding.dataShare.modal.nonIdentifyingContent"), style: textStyle, textAlign: TextAlign.left),
      Container(
          margin: EdgeInsets.only(top: 24 * sizeMultiplier, bottom: 8 * sizeMultiplier),
          alignment: Alignment.centerLeft,
          child: Semantics(
              label: FlutterI18n.translate(context, "a11y.header2"),
              header: true,
              child: Text(FlutterI18n.translate(context, "onboarding.dataShare.modal.aggregateDataTitle"),
                  style: headerStyle, textAlign: TextAlign.left))),
      Text(FlutterI18n.translate(context, "onboarding.dataShare.modal.aggregateDataContent"), style: textStyle, textAlign: TextAlign.left),
      Container(
          padding: EdgeInsets.all(24 * sizeMultiplier),
          child: ExternalLink(
            label: FlutterI18n.translate(context, "onboarding.dataShare.modal.moreInformation"),
            onTap: () {
              _launchURL(FlutterI18n.translate(
                  context, "privacyPolicyURL"));
            },
          ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    TextStyle headerStyle = Constants.CustomTextStyle.darkBlue18Text(context).merge(TextStyle(fontSize: 16 * sizeMultiplier));
    TextStyle textStyle = Constants.CustomTextStyle.grey14Text(context);
    
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          SafeArea(
            child: SizedBox.expand(
          // makes widget fullscreen
          child: Stack(
            children: <Widget>[
              ListView(
                padding: EdgeInsets.only(left: 24, right: 24, top: 16 * sizeMultiplier),
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 16 * sizeMultiplier, bottom: 8),
                      child: ExcludeSemantics(
                          child: SvgPicture.asset(
                        "assets/svg/info-circle.svg",
                        height: 30 * sizeMultiplier,
                        width: 30 * sizeMultiplier,
                      ))),
                  Semantics(
                      label: FlutterI18n.translate(context, "a11y.header1"),
                      header: true,
                      child: Container(
                          margin: EdgeInsets.only(top: 8, bottom: 16),
                          child: Text(
                              FlutterI18n.translate(
                                  context, "onboarding.consent.dialogTitle"),
                              style: headerStyle.merge(TextStyle(fontSize: 20 * sizeMultiplier)),
                              textAlign: TextAlign.center))),
                  type == ShareModalType.intro
                  ? buildIntroContent(context, sizeMultiplier, headerStyle, textStyle)
                  : buildProfileContent(context, sizeMultiplier, headerStyle, textStyle)
                ],
              ),
              Positioned(
                  top: 16,
                  left: 16,
                  child: CustomButton(
                      width: 48,
                      height: 48,
                      borderRadius: 16,
                      padding: EdgeInsets.all(12),
                      shadowColor: Colors.black12,
                      icon: SvgPicture.asset('assets/svg/x.svg',
                          width: 30, height: 30),
                      iconLabel: FlutterI18n.translate(
                          context, "onboarding.consent.closeModal"),
                      backgroundColor: Colors.white,
                      onPressed: closeCallback)),
            ],
          ),
        )),
        Container(color: Constants.darkBlue70, height: MediaQuery.of(context).padding.top)
      ])
    );
  }
}
