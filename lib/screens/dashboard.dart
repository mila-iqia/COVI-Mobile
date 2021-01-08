import 'dart:ui';
import 'package:covi/material/customButton.dart';
import 'package:covi/material/mainRecommandationCard.dart';
import 'package:covi/material/profileScreenArguments.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/extensions.dart';
import 'package:covi/utils/providers/actionCardsList.dart';
import 'package:covi/utils/providers/contentManagerProvider.dart';
import 'package:covi/utils/providers/pollsProvider.dart';
import 'package:covi/utils/providers/recommendationsProvider.dart';
import 'package:covi/utils/settings.dart';
import 'package:covi/material/actionCard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:share/share.dart';
import 'package:infinity_page_view/infinity_page_view.dart';
import 'package:covi/utils/providers/bottomNavigationBarProvider.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({key}) : super(key: key);

  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with RouteAware, RouteObserverMixin, TickerProviderStateMixin {
  String updateSource = "W001";
  FocusNode recommendationCardInfoFocusNode;
  DateTime recommendationUpdateDate;

  DateTime testUpdate;
  DateTime symptomsUpdate;

  Map<String, dynamic> userRegionsStats = new Map();

  InfinityPageController chartsController;

  bool headerNewsExpanded = false;

  int userAnswerNumber = 1034;
  double yesPercentage = 35;
  double noPercentage = 65;
  double initalYesPercentage = 0;
  double initalNoPercentage = 0;
  AnimationController _controllerYes;
  AnimationController _controllerNo;
  Animation<double> _animationYes;
  Animation<double> _animationNo;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url})';
    }
  }

  @override
  void initState() {
    _controllerYes = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _controllerNo = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationYes = _controllerYes;
    _animationNo = _controllerNo;

    super.initState();

    // Check for setup after tree has been built
    chartsController = InfinityPageController(viewportFraction: 0.99999);
    recommendationCardInfoFocusNode = new FocusNode();
  }

  void _savePoll(int choiceId) async {
    await Provider.of<PollsProvider>(context, listen: false)
        .postActivePollAwnser(choiceId);
  }

  void _pollAnimation() {
    setState(() {
      initalYesPercentage += 1;
      _animationYes = new Tween<double>(
        begin: _animationYes.value,
        end: yesPercentage,
      ).animate(new CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: _controllerYes,
      ));
    });
    _controllerYes.forward(from: 0);

    setState(() {
      initalNoPercentage += 1;
      _animationNo = new Tween<double>(
        begin: _animationNo.value,
        end: noPercentage,
      ).animate(new CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: _controllerNo,
      ));
    });
    _controllerNo.forward(from: 0);
  }

  @override
  void dispose() {
    recommendationCardInfoFocusNode.dispose();
    super.dispose();
  }

  void _share() {
    Share.share(FlutterI18n.translate(context, "shareURL"),
        subject: FlutterI18n.translate(context, "shareSubject"));
  }

  Widget _buildAlert(String title, String details) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Container(
        padding: EdgeInsets.all(16 * sizeMultiplier),
        decoration: BoxDecoration(
            border:
                Border(left: BorderSide(width: 4, color: Constants.pinkRed)),
            color: Color(0xFFfff2f2)),
        child: Row(children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 13 * sizeMultiplier),
            child: ExcludeSemantics(
                child: SvgPicture.asset("assets/svg/alert-triangle-red.svg")),
          ),
          Flexible(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Text(title,
                    style: Constants.CustomTextStyle.darkBlue14Text(context)
                        .merge(TextStyle(fontWeight: FontWeight.w700))),
                Divider(color: Colors.transparent, height: 4),
                Text(details,
                    style: Constants.CustomTextStyle.darkBlue14Text(context)
                        .merge(TextStyle(
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                            fontSize: 12 * sizeMultiplier))),
              ]))
        ]));
  }

  Widget _buildShareBox() {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Stack(children: <Widget>[
      Container(
          margin: EdgeInsets.only(bottom: 30 * sizeMultiplier),
          decoration: BoxDecoration(
              color: Constants.darkBlue,
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Center(
              child: Container(
                  child: Column(
            children: <Widget>[
              Container(
                  width: 180 * sizeMultiplier,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          0, 40 * sizeMultiplier, 0, 12 * sizeMultiplier),
                      child: Text(FlutterI18n.translate(context, "shareTitle"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14 * sizeMultiplier,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)))),
              ExcludeSemantics(
                  child: Image.asset(
                'assets/img/rainbow.png',
                height: 130 * sizeMultiplier,
              ))
            ],
          )))),
      Positioned(
          bottom: 4 * sizeMultiplier,
          width: MediaQuery.of(context).size.width * 1 - 32 * sizeMultiplier,
          child: Center(
              child: CustomButton(
                  label: FlutterI18n.translate(context, "shareButtonLabel"),
                  icon: SvgPicture.asset(
                    'assets/svg/share.svg',
                    width: 18 * sizeMultiplier,
                  ),
                  iconPosition: CustomButtonIconPosition.after,
                  shadowColor: Colors.transparent,
                  backgroundColor: Constants.mediumBlue,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  splashColor: Constants.blueSplash,
                  textColor: Colors.white,
                  onPressed: () {
                    _share();
                  })))
    ]);
  }

  Widget _buildPollBox(Poll activePoll) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    String locale = FlutterI18n.currentLocale(context).languageCode;
    int activePollAwnser = Provider.of<PollsProvider>(context).activePollAwnser;
    return Stack(children: <Widget>[
      Container(
          width: MediaQuery.of(context).size.width - 32 * sizeMultiplier,
          decoration: BoxDecoration(
              color: Constants.lightGrey,
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          padding: EdgeInsets.only(
              top: 24 * sizeMultiplier, bottom: 16 * sizeMultiplier),
          child: Column(children: <Widget>[
            Text(FlutterI18n.translate(context, "home.poll.title"),
                textAlign: TextAlign.center,
                style: Constants.CustomTextStyle.grey14Text(context)
                    .merge(TextStyle(fontWeight: FontWeight.w700))),
            Container(
                margin: EdgeInsets.only(
                    top: 24 * sizeMultiplier, bottom: 16 * sizeMultiplier),
                constraints: BoxConstraints(maxWidth: 205 * sizeMultiplier),
                child: Text(activePoll.question[locale],
                    textAlign: TextAlign.center,
                    style: Constants.CustomTextStyle.darkBlue18Text(context)
                        .merge(TextStyle(fontSize: 16 * sizeMultiplier)))),
            Container(
                // constraints: BoxConstraints(maxWidth: 205 * sizeMultiplier),
                child: FractionallySizedBox(
                    widthFactor: 1,
                    child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        children: activePoll.choices
                            .map(
                              (choice) => CustomButton(
                                a11yLabel: activePollAwnser != null &&
                                        activePollAwnser == choice.id
                                    ? FlutterI18n.translate(
                                        context, "a11y.selected")
                                    : "",
                                minWidth: 94 * sizeMultiplier,
                                backgroundColor: activePollAwnser != null &&
                                        activePollAwnser == choice.id
                                    ? Color(0xFFd5e8e2)
                                    : Constants.lightBeige,
                                shadowColor: Colors.black12,
                                splashColor: Colors.black12,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                customContent: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                          choice.label[locale]
                                              .toString()
                                              .capitalize(),
                                          style: Constants.CustomTextStyle
                                                  .whiteMd14Text(context)
                                              .merge(TextStyle(
                                            color: Constants.darkBlue,
                                            fontSize: 16 * sizeMultiplier,
                                          ))),
                                      if (activePollAwnser != null)
                                        Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: new AnimatedBuilder(
                                            animation: _animationYes,
                                            builder: (BuildContext context,
                                                Widget child) {
                                              return new Text(
                                                  ((choice.awnsers /
                                                                  activePoll
                                                                      .total) *
                                                              100)
                                                          .toStringAsFixed(0) +
                                                      "%",
                                                  style:
                                                      Constants.CustomTextStyle
                                                              .darkBlue14Text(
                                                                  context)
                                                          .merge(
                                                    TextStyle(
                                                        fontWeight:
                                                            activePollAwnser !=
                                                                        null &&
                                                                    activePollAwnser ==
                                                                        choice
                                                                            .id
                                                                ? FontWeight
                                                                    .w700
                                                                : FontWeight
                                                                    .w400,
                                                        fontSize: 16 *
                                                            sizeMultiplier),
                                                  ));
                                            },
                                          ),
                                        )
                                    ]),
                                onPressed: () {
                                  if (activePollAwnser == null) {
                                    _savePoll(choice.id);
                                    _pollAnimation();
                                  }
                                },
                              ),
                            )
                            .toList()))),
            Divider(height: 16, color: Colors.transparent),
            Text(
                (activePoll.total.toString() +
                    FlutterI18n.translate(context, "home.poll.answerNumber")),
                textAlign: TextAlign.center,
                style: Constants.CustomTextStyle.grey14Text(context)
                    .merge(TextStyle(fontSize: 13 * sizeMultiplier))),
          ])),
      Positioned(
          top: 0,
          child: ExcludeSemantics(
              child: SvgPicture.asset('assets/svg/question-mark-top.svg'))),
      Positioned(
          bottom: 0,
          right: 0,
          child: ExcludeSemantics(
              child: SvgPicture.asset('assets/svg/question-mark-bottom.svg')))
    ]);
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
        Flexible(
            child: Text(
                '  ${FlutterI18n.translate(context, "lastUpdated")}: ${dateString}',
                style: style))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    var navigationBarProvider =
        Provider.of<BottomNavigationBarProvider>(context);
    Map<String, dynamic> actions = Provider.of<ActionsManager>(context).actions;
    SettingsData settings = Provider.of<SettingsManager>(context).settings;
    List<String> alertActions = Provider.of<ActionsManager>(context)
        .getActionsFromUserData(settings, ActionType.alert);

    String lang = FlutterI18n.currentLocale(context).languageCode;
    DateFormat dateFormat = new DateFormat(
        lang == 'en' ? 'EEEE MMMM d yyyy' : 'EEEE d MMMM yyyy', lang);

    List<NewsContent> news = Provider.of<ContentManagerProvider>(context).news;
    Poll activePoll = Provider.of<PollsProvider>(context).activePoll;
    NewsContent currentNews = news.firstWhere(
        (element) =>
            element.from.isBefore(DateTime.now()) &&
            element.to.isAfter(DateTime.now()),
        orElse: () => null);

    MainRecommendation recommendation =
        Provider.of<RecommendationsProvider>(context).mainRecommendation;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          SingleChildScrollView(
              padding: EdgeInsets.all(0),
              child: Column(children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                      color: Constants.darkBlue,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(60 * sizeMultiplier)),
                    ),
                    child: Stack(children: <Widget>[
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: ExcludeSemantics(
                              child: SvgPicture.asset(
                                  "assets/svg/backdrops/dashboard_circle.svg",
                                  width: 115 * sizeMultiplier))),
                      if (currentNews != null)
                        Positioned(
                            bottom: (68 - 40) * sizeMultiplier,
                            right: 24 * sizeMultiplier,
                            child: CustomButton(
                              backgroundColor: Colors.transparent,
                              splashColor: Colors.black26,
                              width: 48,
                              height: 48,
                              onPressed: () {
                                setState(() {
                                  headerNewsExpanded = !headerNewsExpanded;
                                });
                              },
                              iconLabel: FlutterI18n.translate(context,
                                  headerNewsExpanded ? "seeLess" : "seeMore"),
                              icon: SvgPicture.asset(
                                  headerNewsExpanded
                                      ? "assets/svg/white-minus.svg"
                                      : "assets/svg/white-plus.svg",
                                  width: 20 * sizeMultiplier),
                            )),
                      Padding(
                          padding: EdgeInsets.fromLTRB(
                              24 * sizeMultiplier,
                              40 * sizeMultiplier,
                              24 * sizeMultiplier,
                              34 * sizeMultiplier),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      kDebugMode
                                          ? GestureDetector(
                                              onLongPress: () {
                                                Navigator.of(context)
                                                    .pushNamed("/test");
                                              },
                                              child: Semantics(
                                                  label: "Covi",
                                                  child: SvgPicture.asset(
                                                      "assets/svg/logo-covi.svg",
                                                      width:
                                                          90 * sizeMultiplier)))
                                          : Semantics(
                                              label: "Covi",
                                              child: SvgPicture.asset(
                                                  "assets/svg/logo-covi.svg",
                                                  width: 90 * sizeMultiplier)),
                                      CustomButton(
                                        backgroundColor: Constants.covidBlue,
                                        splashColor: Colors.black26,
                                        width: 48,
                                        borderRadius: 16,
                                        height: 48,
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushNamed("/profile");
                                        },
                                        iconLabel: FlutterI18n.translate(
                                            context, "profile.profile"),
                                        icon: SvgPicture.asset(
                                            "assets/svg/action-setup.svg",
                                            color: Constants.beige,
                                            width: 30 * sizeMultiplier),
                                      ),
                                    ]),
                                Divider(height: 30, color: Colors.transparent),
                                Semantics(
                                    label: FlutterI18n.translate(
                                        context, "a11y.header1"),
                                    header: true,
                                    child: Text(
                                        FlutterI18n.translate(
                                            context, "home.dashboardTitle"),
                                        style: Constants.CustomTextStyle
                                                .darkBlue18Text(context)
                                            .merge(TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    26 * sizeMultiplier)))),
                                Divider(height: 24, color: Colors.transparent),
                                Text(
                                    FlutterI18n.translate(
                                        context, "home.today"),
                                    style: Constants.CustomTextStyle
                                            .whiteMd14Text(context)
                                        .merge(TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20 * sizeMultiplier))),
                                Text(
                                    dateFormat
                                        .format(new DateTime.now())
                                        .capitalize(),
                                    style: Constants.CustomTextStyle
                                            .whiteMd14Text(context)
                                        .merge(TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 16 * sizeMultiplier))),
                                if (currentNews != null && headerNewsExpanded)
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Divider(
                                            height: 16,
                                            color: Colors.transparent),
                                        Container(
                                            constraints: BoxConstraints(
                                                maxWidth: 240 * sizeMultiplier),
                                            child: Html(
                                              defaultTextStyle:
                                                  Constants.CustomTextStyle
                                                      .whiteMd14Text(context),
                                              data: currentNews.content[lang],
                                              onLinkTap: (url) {
                                                _launchURL(url);
                                              },
                                            )),
                                        Divider(
                                            height: 30,
                                            color: Colors.transparent),
                                        SvgPicture.asset(
                                            "assets/svg/signature.svg",
                                            color: Constants.beige,
                                            width: 74 * sizeMultiplier),
                                      ])
                              ]))
                    ])),
                Stack(
                  children: <Widget>[
                    ExcludeSemantics(
                      child: ClipRect(
                          child: Align(
                        alignment: Alignment(0, 0.56),
                        heightFactor: 0.4,
                        child: Lottie.asset('assets/animations/P2-vagues.json',
                            repeat: true,
                            width: MediaQuery.of(context).size.width),
                      )),
                      // child: SvgPicture.asset(
                      // "assets/svg/backdrops/dashboard_wave.svg",
                      // width: MediaQuery.of(context).size.width)
                    ),
                    Column(children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(
                              top: 40 * sizeMultiplier,
                              left: 16 * sizeMultiplier,
                              right: 16 * sizeMultiplier),
                          child: Column(
                            children: <Widget>[
                              for (var actionId in alertActions)
                                ActionCard(
                                  title: FlutterI18n.translate(context,
                                      "actions.actionCards.${actionId}.category"),
                                  onTap: () {
                                    if (actionId == "AC003" ||
                                        actionId == "AC004") {
                                      Navigator.of(context).pushNamed(
                                          actions[actionId].url,
                                          arguments: ProfileScreenArguments(
                                              1, 'dashboard'));
                                    } else if (actionId == "AC008") {
                                      Navigator.of(context).pushNamed(
                                          actions[actionId].url,
                                          arguments: ProfileScreenArguments(
                                              0, 'dashboard'));
                                    } else {
                                      Navigator.of(context).pushNamed(
                                          actions[actionId].url,
                                          arguments: 'dashboard');
                                    }
                                  },
                                  circleColor: ActionCardColor.red,
                                  content: Text(
                                      FlutterI18n.translate(context,
                                          "actions.actionCards.${actionId}.title"),
                                      style: TextStyle(
                                        color: Color(0xFF2d3953),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16 * sizeMultiplier,
                                      ),
                                      textAlign: TextAlign.left),
                                  backgroundColor: Color(0xFFf7f0ea),
                                  lastUpdate:
                                      actions[actionId].lastUpdate != null
                                          ? actions[actionId].lastUpdate
                                          : null,
                                  icon: SvgPicture.asset(
                                      'assets/svg/' + actions[actionId].icon,
                                      color: Constants.pinkRed),
                                  button: SvgPicture.asset(
                                      'assets/svg/arrow-blue.svg'),
                                ),
                              alertActions.length > 0
                                  ? Divider(
                                      color: Colors.transparent,
                                      height: 16 * sizeMultiplier)
                                  : Container(),
                              if (recommendation != null) ...[
                                MainRecommandationCard(
                                    isEmergency: recommendation.id == "C001",
                                    recommendation: recommendation,
                                    recommendationUpdateDate:
                                        Provider.of<SettingsManager>(context)
                                            .settings
                                            .user_data
                                            .recommendationUpdateDate,
                                    parseUpdatedDate: _parseUpdatedDate(
                                        Provider.of<SettingsManager>(context)
                                            .settings
                                            .user_data
                                            .recommendationUpdateDate),
                                    recommendationCardInfoFocusNode:
                                        recommendationCardInfoFocusNode,
                                    updateSource: updateSource,
                                    dialogParseUpdatedDate: _parseUpdatedDate(
                                        Provider.of<SettingsManager>(context)
                                            .settings
                                            .user_data
                                            .recommendationUpdateDate,
                                        withIcon: false),
                                    onTap: () =>
                                        navigationBarProvider.currentIndex = 2),
                              ],
                              Divider(height: 16, color: Colors.transparent),
                              if (activePoll != null)
                                _buildPollBox(activePoll),
                              // Divider(height: 45),
                              // _buildShareBox(),
                              Container(
                                  padding: EdgeInsets.only(
                                      top: 32 * sizeMultiplier,
                                      bottom: 24 * sizeMultiplier),
                                  child: Text(Constants.appVersion))
                            ],
                          )),
                    ]),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ExcludeSemantics(
                          child: SvgPicture.asset(
                              "assets/svg/backdrops/dashboard_beigeWave.svg",
                              width: MediaQuery.of(context).size.width -
                                  24 * sizeMultiplier)),
                    )
                  ],
                )
              ])),
          Container(
              color: Constants.darkBlue70,
              height: MediaQuery.of(context).padding.top)
        ]));
  }
}
