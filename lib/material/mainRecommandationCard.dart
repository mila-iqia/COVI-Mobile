import 'package:covi/material/customButton.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:html/dom.dart' as dom;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainRecommandationCard extends StatelessWidget {
  const MainRecommandationCard({
    @required this.isEmergency,
    @required this.recommendation,
    this.recommendationUpdateDate,
    this.onTap,
    this.parseUpdatedDate,
    this.dialogParseUpdatedDate,
    this.recommendationCardInfoFocusNode,
    this.updateSource
  })  : assert(recommendation != null),
        assert(isEmergency != null);

  final bool isEmergency;
  final MainRecommendation recommendation;
  final DateTime recommendationUpdateDate;
  final Function onTap;
  final Widget parseUpdatedDate;
  final Widget dialogParseUpdatedDate;
  final FocusNode recommendationCardInfoFocusNode;
  final String updateSource;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url})';
    }
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    MainRecommendation mainRecommendationContent = Provider.of<RecommendationsProvider>(context).mainRecommendation;
    String currentLocale = FlutterI18n.currentLocale(context).languageCode;

    Future<void> _showPersonalizedRecommendationsDialog() async {
      double sizeMultiplier = MediaQuery.of(context).size.width / 320;

      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            content: SingleChildScrollView(
                child: Container(
                    child: ListBody(
              children: <Widget>[
                Divider(height: 16 * sizeMultiplier, color: Constants.transparent),
                Center(child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/icon-questionmark.svg', width: 30 * sizeMultiplier))),
                Divider(height: 16 * sizeMultiplier, color: Constants.transparent),
                Center(child: dialogParseUpdatedDate),
                Divider(height: 24 * sizeMultiplier, color: Constants.transparent),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * sizeMultiplier),
                    child: Center(
                      child: Html(
                        data: FlutterI18n.translate(context, "recommendations.updateSource.${updateSource}"),
                        customTextAlign: (dom.Node node) {
                          return TextAlign.center;
                        },
                        defaultTextStyle: TextStyle(color: Constants.darkBlue, fontSize: 16 * sizeMultiplier, fontWeight: FontWeight.w500),
                        onLinkTap: (url) {
                          _launchURL(url);
                        },
                      ),
                    )),
                Divider(height: 24 * sizeMultiplier, color: Constants.transparent),
                Divider(height: 1),
                Center(
                  child: CustomButton(
                  padding: EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width,
                  label: FlutterI18n.translate(context, "close"),
                  textColor: Constants.darkBlue,
                  labelStyle: TextStyle(fontSize: 14 * sizeMultiplier, fontWeight: FontWeight.normal),
                  backgroundColor: Constants.transparent,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )),
              ],
            ))),
          );
        },
      );
    }

    return Container(
        margin: EdgeInsets.only(bottom: 16 * sizeMultiplier),
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: (onTap != null || isEmergency) ? 27 * sizeMultiplier : 0),
              child:
                Container(
                    padding: EdgeInsets.only(
                        top: onTap != null ? 40 * sizeMultiplier : 30 * sizeMultiplier, right: isEmergency ? 0 : 24 * sizeMultiplier, bottom: onTap != null ? 55 * sizeMultiplier : 30 * sizeMultiplier, left: isEmergency ? 0 : 24 * sizeMultiplier),
                    margin: EdgeInsets.only(bottom: 24 * sizeMultiplier * MediaQuery.of(context).textScaleFactor),
                    decoration: BoxDecoration(
                      color: isEmergency ? Constants.lightPink : Constants.veryLightBlue,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20 * sizeMultiplier,
                          offset: Offset(0, 1 * sizeMultiplier)),
                        new BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 1 * sizeMultiplier)),
                      ],
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 16 * sizeMultiplier, top: isEmergency ? 8 * sizeMultiplier : 0),
                            child: Text(mainRecommendationContent.title[currentLocale],
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Constants.darkBlue, fontSize: 20 * sizeMultiplier, fontWeight: FontWeight.bold, height: 1.2))),
                        Padding(
                            padding: EdgeInsets.only(bottom: recommendationUpdateDate != null ? 16 : 24),
                            child: Text(mainRecommendationContent.subtitle[currentLocale],
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Constants.darkBlue, fontSize: 16 * sizeMultiplier, fontWeight: FontWeight.w500, height: 1.4))),
                        if (recommendationUpdateDate != null) parseUpdatedDate
                      ]))
                    ])),
            ),
            updateSource != null ?
            Positioned(
                top: (onTap != null || isEmergency) ? 27 * sizeMultiplier : 0,
                right: 0,
                child: Semantics(
                    label: FlutterI18n.translate(context, "onboarding.infoLabel"),
                    button: true,
                    container: true,
                    child: InkWell(
                        focusNode: recommendationCardInfoFocusNode,
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: _showPersonalizedRecommendationsDialog,
                        child: Container(
                          height: 48 * sizeMultiplier,
                          width: 48 * sizeMultiplier,
                          padding: EdgeInsets.all(16 * sizeMultiplier),
                          child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/icon-questionmark.svg', width: 16 * sizeMultiplier)),
                        )))) : Container(),
            if (onTap != null || isEmergency)
              Positioned(
                top: 0,
                child: 
                  Center(
                      child: ExcludeSemantics(
                          child: Container(
                              width: MediaQuery.of(context).size.width - 32 * sizeMultiplier,
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: <Widget>[
                                  Container(
                                      decoration: BoxDecoration(
                                        color: isEmergency ? Color(0xFFf5e2e3) : Color(0xFFdde4f6),
                                        shape: BoxShape.circle,
                                      ),
                                      width: 58 * sizeMultiplier,
                                      height: 58 * sizeMultiplier),
                                  Container(
                                    child: 
                                    isEmergency ?
                                      SvgPicture.asset("assets/svg/alert-triangle-red.svg", width: 22 * sizeMultiplier)
                                    : SvgPicture.asset("assets/svg/navbar/advices.svg", width: 30 * sizeMultiplier, color: Constants.mediumBlue))
                                ],
                              ))))
              ),
            if (onTap != null)
              Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width * 1 - 32 * sizeMultiplier,
                child: Center(
                    child: CustomButton(
                        label: FlutterI18n.translate(context, "home.myRecommendations"),
                        icon: SvgPicture.asset(
                          'assets/svg/arrow-blue.svg',
                          width: 11 * sizeMultiplier,
                          color: isEmergency ? Constants.darkBlue : Colors.white
                        ),
                        iconPosition: CustomButtonIconPosition.after,
                        shadowColor: Colors.transparent,
                        backgroundColor: isEmergency ? Constants.pinkRed : Constants.mediumBlue,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        splashColor: isEmergency ? Constants.redSplash : Constants.blueSplash,
                        textColor: isEmergency ? Constants.darkBlue : Colors.white,
                        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16 * sizeMultiplier),
                        onPressed: onTap
                  )))
          ],
        ));
  }
}
