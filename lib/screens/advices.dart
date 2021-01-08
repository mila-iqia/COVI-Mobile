import 'package:covi/material/actionCard.dart';
import 'package:covi/material/customButton.dart';
import 'package:covi/material/mainRecommandationCard.dart';
import 'package:covi/utils/providers/menuNotificationProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/extensions.dart';
import 'package:covi/material/expandableCard.dart';
import 'package:covi/material/genericTitleLayout.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:covi/utils/settings.dart';
import 'package:covi/material/expandableList.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvicesScreen extends StatefulWidget {
  AdvicesScreen({key}) : super(key: key);

  _AdvicesScreenState createState() => _AdvicesScreenState();
}

class _AdvicesScreenState extends State<AdvicesScreen> {
  String locale;
  FocusNode recommendationCardInfoFocusNode;
  String updateSource = "W001";

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url})';
    }
  }

  _call911() {
    _launchURL("tel:911");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<MenuNotificationProvider>(context, listen: false)
          .turnNotificationOff(NotificationsName.tips, true);
      recommendationCardInfoFocusNode = new FocusNode();
    });
  }

  @override
  void dispose() {
    recommendationCardInfoFocusNode.dispose();
    super.dispose();
  }

  Row _parseUpdatedDate(DateTime date, {bool withIcon = true}) {
    String locale = FlutterI18n.currentLocale(context).languageCode;
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    String dateString = date.isToday()
        ? "${FlutterI18n.translate(context, "today")}, ${FlutterI18n.translate(context, "at")} ${new DateFormat.jm(locale).format(date)}"
        : new DateFormat.MMMMd(locale).add_y().format(date);
    TextStyle style = TextStyle(
        height: 1,
        color: Color(0xFF62696a),
        fontStyle: FontStyle.italic,
        fontSize: 12 * sizeMultiplier);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (withIcon)
          ExcludeSemantics(
              child: SvgPicture.asset('assets/svg/icon-clock.svg',
                  height: 12 * sizeMultiplier)),
        Text(
            '  ${FlutterI18n.translate(context, "lastUpdated")}: ${dateString}',
            style: style)
      ],
    );
  }

  Widget _build911Content() {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    DateTime symptomsUpdateDate = Provider.of<SettingsManager>(context)
        .settings
        .user_data
        .symptomsUpdateDate;
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
        Widget>[
      Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Text(
            FlutterI18n.translate(
                context, "recommendations.call911Explanation"),
            textAlign: TextAlign.center,
            style: Constants.CustomTextStyle.grey14Text(context)),
      ),
      Divider(height: 32, color: Colors.transparent),
      Stack(children: <Widget>[
        CustomButton(
          label: "911",
          onPressed: _call911,
          width: MediaQuery.of(context).size.width * 0.7,
          shadowColor: Colors.black12,
        ),
        Positioned(
            left: 16 * sizeMultiplier,
            top: 12 * sizeMultiplier,
            child: SvgPicture.asset("assets/svg/phone.svg"))
      ]),
      Divider(height: 60 * sizeMultiplier),
      Text(FlutterI18n.translate(context, "recommendations.didYouMakeAMistake"),
          textAlign: TextAlign.center,
          style: Constants.CustomTextStyle.darkBlue18Text(context)),
      Divider(height: 8, color: Colors.transparent),
      Text(
          FlutterI18n.translate(
              context, "recommendations.reSelfAssessExplanation"),
          textAlign: TextAlign.center,
          style: Constants.CustomTextStyle.grey14Text(context)),
      Divider(height: 24, color: Colors.transparent),
      ActionCard(
        title: FlutterI18n.translate(
            context, "actions.actionCards.AC001.category"),
        onTap: () {
          Navigator.of(context).pushNamed("/actions/self-diagnostic");
        },
        circleColor: ActionCardColor.beige,
        content: Text(
            FlutterI18n.translate(context, "actions.actionCards.AC001.title"),
            style: TextStyle(
              color: Color(0xFF2d3953),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.left),
        backgroundColor: Constants.lightBeige,
        lastUpdate: symptomsUpdateDate,
        icon: SvgPicture.asset('assets/svg/action-hand.svg'),
        button: SvgPicture.asset('assets/svg/arrow-blue.svg'),
      ),
      Divider(height: 24 * sizeMultiplier, color: Constants.transparent),
    ]);
  }

  Widget _buildRegularContent(List<Recommendation> publicHealthRecommendations,
      List<Recommendation> wellBeingRecommendations) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    String locale = FlutterI18n.currentLocale(context).languageCode;
    return Column(children: <Widget>[
      if (!publicHealthRecommendations.isEmpty)
        ExpandableList(
            title: FlutterI18n.translate(
                context, "recommendations.publicHealthRecommendations"),
            content: publicHealthRecommendations.map((recommendation) {
              return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ExpandableCard(
                    headerText: recommendation.title[locale],
                    color: ExpandleCardColors.yellow,
                    content: Column(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.fromLTRB(32, 16, 24, 24),
                            child: Html(
                              defaultTextStyle: TextStyle(
                                  color: Color(0xFF62696a),
                                  fontSize: 12 * sizeMultiplier,
                                  fontFamily: 'Neue'),
                              data: recommendation.content[locale],
                              onLinkTap: (url) {
                                _launchURL(url);
                              },
                            )),
                        // Divider(),
                        // Container(
                        //     padding: EdgeInsets.fromLTRB(32, 16, 24, 24),
                        //     child: Html(
                        //       defaultTextStyle: TextStyle(color: Color(0xFF62696a), fontSize: 12 * sizeMultiplier, fontFamily: 'Neue'),
                        //       data: recommendation.explanation[locale],
                        //       onLinkTap: (url) {
                        //         _launchURL(url);
                        //       },
                        //     ))
                      ],
                    ),
                  ));
            }).toList()),
      if (!wellBeingRecommendations.isEmpty)
        Padding(
            padding: EdgeInsets.only(top: 24 * sizeMultiplier),
            child: ExpandableList(
                title: FlutterI18n.translate(
                    context, "recommendations.wellBeingRecommendations"),
                content: wellBeingRecommendations.map((recommendation) {
                  return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ExpandableCard(
                        headerText: recommendation.title[locale],
                        color: ExpandleCardColors.green,
                        content: Column(
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.fromLTRB(32, 16, 24, 24),
                                child: Html(
                                  defaultTextStyle: TextStyle(
                                      color: Color(0xFF62696a),
                                      fontSize: 12 * sizeMultiplier,
                                      fontFamily: 'Neue'),
                                  data: recommendation.content[locale],
                                  onLinkTap: (url) {
                                    _launchURL(url);
                                  },
                                )),
                            // Divider(),
                            // Container(
                            //     padding: EdgeInsets.fromLTRB(32, 16, 24, 24),
                            //     child: Html(
                            //       defaultTextStyle: TextStyle(color: Color(0xFF62696a), fontSize: 12 * sizeMultiplier, fontFamily: 'Neue'),
                            //       data: recommendationContent.explanation[locale],
                            //       onLinkTap: (url) {
                            //         _launchURL(url);
                            //       },
                            //     ))
                          ],
                        ),
                      ));
                }).toList())),
      Divider(height: 32 * sizeMultiplier, color: Constants.transparent),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<Recommendation> publicHealthRecommendations =
        Provider.of<RecommendationsProvider>(context).healthRecommendations;
    List<Recommendation> wellBeingRecommendations =
        Provider.of<RecommendationsProvider>(context).wellnessRecommendations;
    MainRecommendation mainRecommendation =
        Provider.of<RecommendationsProvider>(context).mainRecommendation;
    DateTime recommendationUpdateDate = Provider.of<SettingsManager>(context)
        .settings
        .user_data
        .recommendationUpdateDate;
    return GenericTitleLayout(
        title: FlutterI18n.translate(context, "recommendations.title"),
        backdropChoice: Backdrops.mapPin,
        child: Column(
          children: <Widget>[
            MainRecommandationCard(
                isEmergency: mainRecommendation.id == "BB_C001",
                recommendation: mainRecommendation,
                recommendationUpdateDate: recommendationUpdateDate,
                parseUpdatedDate: _parseUpdatedDate(recommendationUpdateDate),
                recommendationCardInfoFocusNode:
                    recommendationCardInfoFocusNode,
                updateSource: updateSource,
                dialogParseUpdatedDate: _parseUpdatedDate(
                    recommendationUpdateDate,
                    withIcon: false)),
            mainRecommendation.id == "BB_C001"
                ? _build911Content()
                : _buildRegularContent(
                    publicHealthRecommendations, wellBeingRecommendations)
          ],
        ));
  }
}
