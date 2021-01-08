import 'dart:ui';
import 'package:covi/material/dashboardCharts/dashboardChartCardContainer.dart';
import 'package:covi/material/expandableCard.dart';
import 'package:covi/material/expandableList.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/material/genericTitleLayout.dart';
import 'package:covi/utils/covid_stats.dart';
import 'package:covi/utils/settings.dart';
import 'package:covi/utils/user_regions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:infinity_page_view/infinity_page_view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesScreen extends StatefulWidget {
  ResourcesScreen({key}) : super(key: key);

  _ResourcesScreenState createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen>
    with RouteAware, RouteObserverMixin {
  DateTime testUpdate;
  DateTime symptomsUpdate;

  Map<String, dynamic> userRegionsStats = new Map();
  String locale = 'en';
  int _chartIndex = 0;

  SettingsManager settingsManager;
  CovidStatsManager covidStatsManager;

  InfinityPageController chartsController;

  @override
  void initState() {
    super.initState();

    // Check for setup after tree has been built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      chartsController = InfinityPageController(viewportFraction: 0.99999);

      settingsManager = Provider.of<SettingsManager>(context, listen: false);

      await _updateStats();
      Provider.of<CovidStatsManager>(context, listen: false).updateStats();
      String localeString = await settingsManager.getLang();
      setState(() {
        locale = localeString;
      });
    });
  }

  void _updateStats() async {
    Provider.of<CovidStatsManager>(context, listen: false).updateStats();
  }

  List<Widget> _buildCharts(
      double sizeMultiplier, CovidStatsManager covidStatsManager) {
    num screenCount = 0;
    if (covidStatsManager.statuses.isEmpty &&
        covidStatsManager.stats.isNotEmpty) {
      covidStatsManager.stats.forEach((key, region) {
        screenCount++;
      });
    }

    DateTime covidStatsUpdateTime = covidStatsManager.lastUpdateTime;
    var jiffyCovidStatsUpdateTime =
        covidStatsUpdateTime != null ? Jiffy(covidStatsUpdateTime) : null;
    if (jiffyCovidStatsUpdateTime != null) {
      jiffyCovidStatsUpdateTime.subtract(minutes: 1);
    }
    List<String> levels = UserRegionsManager.levels.reversed.toList();

    return [
      Semantics(
          header: true,
          label: FlutterI18n.translate(context, "a11y.header2"),
          child: Text(FlutterI18n.translate(context, "home.pageHeader"),
              style: TextStyle(fontSize: 1, color: Colors.transparent))),
      Container(
          decoration: BoxDecoration(boxShadow: [
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 40.0,
            ),
          ]),
          child: SizedBox(
              height: 300 * sizeMultiplier,
              child: InfinityPageView(
                itemCount: screenCount,
                controller: chartsController,
                onPageChanged: (int index) =>
                    setState(() => this._chartIndex = index),
                itemBuilder: (_, i) {
                  return this._chartIndex != i
                      ? ExcludeSemantics(
                          child: DashboardChartCardContainer(
                              level: levels[i],
                              region: covidStatsManager.stats[levels[i]],
                              locale: locale))
                      : DashboardChartCardContainer(
                          level: levels[i],
                          region: covidStatsManager.stats[levels[i]],
                          locale: locale);
                },
              ))),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(
              16 * sizeMultiplier, 0, 16 * sizeMultiplier, 0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 48 * sizeMultiplier,
                    height: 48 * sizeMultiplier,
                    child: FlatButton(
                        padding: EdgeInsets.only(right: 24 * sizeMultiplier),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                new BorderRadius.circular(30 * sizeMultiplier)),
                        splashColor: Colors.black12,
                        highlightColor: Colors.transparent,
                        child: ExcludeSemantics(
                            child: SvgPicture.asset(
                          'assets/svg/arrow-back.svg',
                          color: Constants.mediumBlue,
                        )),
                        onPressed: () {
                          chartsController.jumpToPage(this._chartIndex - 1);
                        }),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 14 * sizeMultiplier),
                      child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: new List<Widget>.generate(screenCount, (i) {
                            return i == _chartIndex
                                ? Semantics(
                                    label: FlutterI18n.translate(
                                            context, "slider.slide") +
                                        " " +
                                        (i + 1).toString() +
                                        FlutterI18n.translate(
                                            context, "slider.of") +
                                        screenCount.toString() +
                                        FlutterI18n.translate(
                                            context, "slider.currentslide"),
                                    child: Container(
                                        margin:
                                            EdgeInsets.all(4 * sizeMultiplier),
                                        width: 10 * sizeMultiplier,
                                        height: 10 * sizeMultiplier,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Constants.mediumBlue)))
                                : Semantics(
                                    label: FlutterI18n.translate(
                                            context, "slider.slide") +
                                        " " +
                                        (i + 1).toString() +
                                        FlutterI18n.translate(
                                            context, "slider.of") +
                                        screenCount.toString(),
                                    child: Container(
                                      margin:
                                          EdgeInsets.all(4 * sizeMultiplier),
                                      width: 8 * sizeMultiplier,
                                      height: 8 * sizeMultiplier,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Color(0xFF62696a),
                                            width: 2 * sizeMultiplier),
                                      ),
                                    ));
                          }))),
                  SizedBox(
                      width: 48 * sizeMultiplier,
                      height: 48 * sizeMultiplier,
                      child: FlatButton(
                          padding: EdgeInsets.only(left: 24 * sizeMultiplier),
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(
                                  30 * sizeMultiplier)),
                          splashColor: Colors.black12,
                          highlightColor: Colors.transparent,
                          child: ExcludeSemantics(
                              child: RotatedBox(
                                  quarterTurns: 2,
                                  child: SvgPicture.asset(
                                    'assets/svg/arrow-back.svg',
                                    color: Constants.mediumBlue,
                                  ))),
                          onPressed: () {
                            chartsController.jumpToPage(this._chartIndex + 1);
                          }))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "${FlutterI18n.translate(context, "home.charts.updatedAt")} ${covidStatsUpdateTime != null ? jiffyCovidStatsUpdateTime.fromNow() : FlutterI18n.translate(context, "home.charts.neverUpdated")}",
                    style: TextStyle(
                        fontSize: 10 * sizeMultiplier,
                        color: Color(0xFF62696a),
                        fontStyle: FontStyle.italic),
                  ),
                  Text(
                    FlutterI18n.translate(context, "home.charts.source"),
                    style: TextStyle(
                        color: Color(0xFF62696a), fontStyle: FontStyle.italic),
                  ),
                ],
              )
            ],
          ))
    ];
  }

  var cardHeaderStyle =
      TextStyle(color: Constants.mediumBlue, fontWeight: FontWeight.bold);

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url})';
    }
  }

  Container _generateGrouping(String groupKey, int max) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    final children = <Widget>[];
    for (var i = 1; i <= max; i++) {
      children.add(Material(
          child: Semantics(
              label: FlutterI18n.translate(
                      context, 'resources.documents.${groupKey}.doc${i}Title') +
                  FlutterI18n.translate(context, "a11y.externalLink"),
              link: true,
              child: InkWell(
                  onTap: () {
                    _launchURL(FlutterI18n.translate(
                        context, 'resources.documents.${groupKey}.doc${i}URL'));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          border: i != max
                              ? Border(
                                  bottom: BorderSide(
                                      width: 1, color: Constants.borderGrey))
                              : null),
                      padding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                              child: ExcludeSemantics(
                                  child: Text(
                                      FlutterI18n.translate(context,
                                          'resources.documents.${groupKey}.doc${i}Title'),
                                      style: TextStyle(
                                          color: Constants.mediumBlue,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14 * sizeMultiplier,
                                          height: 1.2)))),
                          Container(
                            width: 57,
                            child: Center(
                                child: ExcludeSemantics(
                                    child: SvgPicture.asset(
                                        "assets/svg/share-icon.svg"))),
                          )
                        ],
                      ))))));
    }

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: ExpandableCard(
          headerText: FlutterI18n.translate(
              context, 'resources.documents.${groupKey}.title'),
          headerStyle: cardHeaderStyle,
          color: ExpandleCardColors.blue,
          content: Column(
            children: children,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    CovidStatsManager covidStatsManager =
        Provider.of<CovidStatsManager>(context);

    return RefreshIndicator(
        onRefresh: () async {
          _updateStats();
        },
        child: GenericTitleLayout(
          title: FlutterI18n.translate(context, "resources.title"),
          contentPadding: EdgeInsets.all(0),
          backdropChoice: Backdrops.arrows,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ..._buildCharts(sizeMultiplier, covidStatsManager),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * sizeMultiplier),
                child: Column(
                  children: <Widget>[
                    Divider(height: 46 * sizeMultiplier),
                    ExpandableList(
                      title: FlutterI18n.translate(
                          context, "resources.officialDocumentation"),
                      content: <Widget>[
                        _generateGrouping('covidGrouping', 9),
                        _generateGrouping('socialDistancingGrouping', 1),
                        _generateGrouping('canadaResponseGrouping', 5),
                        _generateGrouping('travelAdviceGrouping', 5),
                      ],
                    ),
                    Divider(
                        height: 32 * sizeMultiplier,
                        color: Constants.transparent),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
