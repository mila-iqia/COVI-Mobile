import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:covi/material/dashboardCharts/flipCardButton.dart';
import "package:covi/utils/extensions.dart";
import 'package:flutter/semantics.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart' as intl;
import 'package:covi/utils/user_regions.dart';

enum DashboardChartDateRange { total, month, twoweeks }

class DashboardChartCardFront extends StatefulWidget {
  final String title;
  final List<dynamic> data;
  final UserRegionState state;
  final String locale;
  final Function flipCardHandler;

  const DashboardChartCardFront({Key key, this.title, this.data, @required this.state, this.locale, this.flipCardHandler}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardChartCardFrontState();
}

class _DashboardChartCardFrontState extends State<DashboardChartCardFront> with SingleTickerProviderStateMixin {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  AnimationController _animationController;
  Animation<Color> _colorTween;
  bool hasDataInRange = true;
  double minimumY = 0;
  double maximumY = 0;
  double minimumTooltipX = 0;
  double minimumX = 0;
  double maximumX = 0;
  double touchTreshold = 10;
  DashboardChartDateRange dateRange = DashboardChartDateRange.twoweeks;

  List<HorizontalLine> horizontalLines = [];
  List<VerticalLine> verticalLines = [];
  LineChartBarData parsedData;
  List<Map<String, dynamic>> parsedDataDates = [];
  List<bool> dateRangeChoices = [false, false, true];
  List<DashboardChartDateRange> dateRangesEnum = [DashboardChartDateRange.total, DashboardChartDateRange.month, DashboardChartDateRange.twoweeks];

  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1800),
      vsync: this,
    );
    _colorTween = _animationController.drive(ColorTween(begin: Constants.yellow, end: Constants.mediumBlue));
    _animationController.repeat();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose(); // you need this
    super.dispose();
  }

  bool _isDaysDifferenceInSelectedDateRange(double daysDifference) {
    switch (dateRange) {
      case DashboardChartDateRange.twoweeks:
        return daysDifference > -15;
        break;
      case DashboardChartDateRange.month:
        return daysDifference > -32;
        break;
      case DashboardChartDateRange.total:
        return true;
        break;
      default:
    }

    return false;
  }

  void _handleDateRangeChange(int index) {
    List<bool> parsedDateRangeChoices = [false, false, false];
    parsedDateRangeChoices[index] = true;
    setState(() {
      dateRangeChoices = parsedDateRangeChoices;
      dateRange = dateRangesEnum[index];
    });
  }

  static Future<void> announce(String message, TextDirection textDirection) async {
    final AnnounceSemanticsEvent event = AnnounceSemanticsEvent(message, textDirection);
    await SystemChannels.accessibility.send(event.toMap());
  }

  void _parseData(List<dynamic> data) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    double parsingMaximumY = 0;
    double parsingMinimumY;
    double parsingMinimumTooltipX = 0;
    double parsingMinimumX = 0;
    double parsingMaximumX = 0;
    double parsingTouchTreshold = 10;
    DateTime lastDataDate;
    List<FlSpot> spots = [];
    List<Map<String, dynamic>> spotDates = [];

    DateTime now = new DateTime.now();
    DateTime today = new DateTime(now.year, now.month, now.day);

    if (data != null && !data.isEmpty) {
      data.forEach((row) {
        DateTime dateFull = DateTime.parse(row['date']);
        DateTime date = new DateTime(dateFull.year, dateFull.month, dateFull.day);
        double daysDifference = today.difference(date).inDays.negative().toDouble();

        if (_isDaysDifferenceInSelectedDateRange(daysDifference)) {
          if (lastDataDate == null || date.millisecondsSinceEpoch > lastDataDate.millisecondsSinceEpoch) {
            lastDataDate = date;
            parsingMaximumX = today.difference(date).inDays.negative().toDouble();
          }

          if (parsingMinimumY == null || row['value'].toDouble() < parsingMinimumY) parsingMinimumY = row['value'].toDouble();

          if (row['value'].toDouble() > parsingMaximumY) parsingMaximumY = row['value'].toDouble();

          if (daysDifference.toDouble() < parsingMinimumX) parsingMinimumX = daysDifference.toDouble();

          spots.add(FlSpot(daysDifference, (row['value'].toDouble())));
          spotDates.add({"x": daysDifference, "date": date});
        }
      });

      if (spots.isEmpty) {
        setState(() {
          hasDataInRange = false;
        });
      } else {
        spots.sort((a, b) => a.x.compareTo(b.x));
        spotDates.sort((a, b) => a['x'].compareTo(b['x']));

        HorizontalLineLabel sharedLineLabel = HorizontalLineLabel(
          show: true,
          alignment: Alignment(-1, 0),
          padding: EdgeInsets.only(left: 24),
          style: TextStyle(color: Constants.mediumGrey, fontSize: 12 * sizeMultiplier, backgroundColor: Constants.lightGrey),
          labelResolver: (line) => '  ${line.y.round().formatDecimal(separator: " ")}  ',
        );

        double totalRange = parsingMaximumY - parsingMinimumY;
        double roundDouble(double value, int places) {
          double mod = pow(10.0, places);
          return ((value * mod).round().toDouble() / mod);
        }

        HorizontalLine lowLine = HorizontalLine(
          y: roundDouble(parsingMinimumY, -1),
          color: const Color(0xFFecefef),
          strokeWidth: 2,
          label: sharedLineLabel,
        );
        HorizontalLine medLine = HorizontalLine(
          y: roundDouble(totalRange * 0.55 + parsingMinimumY, -1),
          color: const Color(0xFFecefef),
          strokeWidth: 2,
          label: sharedLineLabel,
        );
        HorizontalLine highLine = HorizontalLine(
          y: roundDouble(totalRange * 1.15 + parsingMinimumY, -1),
          color: const Color(0xFFecefef),
          strokeWidth: 2,
          label: sharedLineLabel,
        );

        VerticalLine lastDateLine = VerticalLine(
          x: today.difference(lastDataDate).inDays.negative().toDouble(),
          color: const Color(0xFF62696a),
          strokeWidth: 2,
          dashArray: [4, 4],
          label: VerticalLineLabel(
              style: TextStyle(
                  height: 1, backgroundColor: Constants.lightGrey, color: const Color(0xFF62696a), fontWeight: FontWeight.w500, fontSize: 14 * sizeMultiplier),
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(0),
              show: true,
              labelResolver: (line) => lastDataDate.isToday() ? 'Today' : '${new intl.DateFormat.MMMd(widget.locale).format(lastDataDate)}'),
        );

        double parsingMaximumXBuffer = 0;

        switch (dateRange) {
          case DashboardChartDateRange.total:
            parsingTouchTreshold = 8;
            break;
          case DashboardChartDateRange.month:
            parsingTouchTreshold = 10;
            break;
          case DashboardChartDateRange.twoweeks:
            parsingTouchTreshold = 20;
            break;
          default:
        }

        parsingMaximumXBuffer = -(parsingMinimumX * 0.12);
        parsingMinimumTooltipX = parsingMinimumX + (parsingMinimumX.abs() * 0.1);

        setState(() {
          hasDataInRange = true;
          horizontalLines = [lowLine, medLine, highLine];
          verticalLines = [lastDateLine];
          minimumY = parsingMinimumY - totalRange * 0.1;
          maximumY = totalRange * 1.3 + parsingMinimumY;
          minimumX = parsingMinimumX;
          minimumTooltipX = parsingMinimumTooltipX;
          maximumX = parsingMaximumX + parsingMaximumXBuffer;
          parsedDataDates = spotDates;
          touchTreshold = parsingTouchTreshold;
          parsedData = LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            curveSmoothness: 0,
            colors: [
              Constants.mediumBlue,
              Constants.mediumBlue,
            ],
            barWidth: 8,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              cutOffY: parsingMinimumY,
              applyCutOffY: true,
              show: true,
              colors: [
                Color.fromRGBO(46, 78, 158, 0.05),
                Color.fromRGBO(46, 78, 158, 0.3),
              ],
            ),
          );
        });
      }
    }
  }

  Widget _buildCardHeader(double sizeMultiplier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 24, top: 24),
              child: Semantics(
                  sortKey: OrdinalSortKey(1.0),
                  label: FlutterI18n.translate(context, "a11y.header3"),
                  header: true,
                  child: Text(widget.title != null ? widget.title : "",
                      style: TextStyle(color: Constants.darkBlue, fontWeight: FontWeight.bold, fontSize: 14 * sizeMultiplier)))),
          Padding(
              padding: EdgeInsets.only(bottom: 4, left: 24),
              child: Semantics(
                  sortKey: OrdinalSortKey(2.0),
                  child: Text(FlutterI18n.translate(context, 'home.charts.cases'),
                      style: TextStyle(fontStyle: FontStyle.italic, color: Constants.mediumGrey, fontWeight: FontWeight.w500, fontSize: 12 * sizeMultiplier))))
        ])),
        SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (widget.state == UserRegionState.noDataNoInternet || widget.state == UserRegionState.noDataNotReachable)
                Center(
                    child: SizedBox(
                  child: Tooltip(
                      message: FlutterI18n.translate(context, 'home.charts.tooltipUpdateWarnings.${EnumToString.parse(widget.state)}'),
                      child: ExcludeSemantics(
                        child:
                          FlatButton(
                            onPressed: () => {},
                            splashColor: Colors.black12,
                            highlightColor: Colors.black12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                            child:
                              Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 24.0 * sizeMultiplier
                              )
                          )
                      )
                  ),
                  height: 48 * sizeMultiplier,
                  width: 48 * sizeMultiplier,
                )),
              if (widget.state == UserRegionState.loading)
                Container(
                  child: Center(
                      child: SizedBox(
                    child: CircularProgressIndicator(
                      valueColor: _colorTween,
                      strokeWidth: 4 * sizeMultiplier,
                    ),
                    height: 12 * sizeMultiplier,
                    width: 12 * sizeMultiplier,
                  )),
                ),
              FlipCardButton(onPressed: widget.flipCardHandler, isStatisticsShown: false)
            ],
          ),
        )
      ],
    );
  }

  Widget _buildChart(double sizeMultiplier) {
    if (!hasDataInRange) {
      return Container(
          width: MediaQuery.of(context).size.width - 180,
          height: 160 * sizeMultiplier,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Flexible(
              child: Text(
                FlutterI18n.translate(context, 'home.charts.noDataForRange'),
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            )
          ]));
    }
    return Semantics(
      sortKey: OrdinalSortKey(4.0),
      label: FlutterI18n.translate(context, 'home.charts.instructions'),
      child:
        Container(
          width: MediaQuery.of(context).size.width - 8,
          height: 160 * sizeMultiplier,
          child: LineChart(
            LineChartData(
              clipToBorder: true,
              lineTouchData: LineTouchData(
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      final FlSpot spot = barData.spots[spotIndex];
                      if (spot.x <= minimumTooltipX) {
                        return null;
                      }
                      return TouchedSpotIndicatorData(
                        FlLine(color: Constants.transparent, strokeWidth: 0),
                        FlDotData(
                          dotSize: 6,
                          strokeWidth: 8,
                          getDotColor: (spot, percent, barData) => Constants.lightGrey,
                          getStrokeColor: (spot, percent, barData) => Constants.mediumBlue,
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        if (touchedSpot.x <= minimumTooltipX) {
                          return null;
                        }
                        DateTime date = parsedDataDates[touchedSpot.spotIndex]['date'];
                        announce("${new intl.DateFormat.MMMd(widget.locale).format(date)}\n${touchedSpot.y.round().formatDecimal(separator: " ")} ${FlutterI18n.translate(context, 'home.charts.cases')}", TextDirection.ltr);
                        return LineTooltipItem("${new intl.DateFormat.MMMd(widget.locale).format(date)}\n${touchedSpot.y.round().formatDecimal(separator: " ")}",
                            TextStyle(color: touchedSpot.bar.colors[0], fontWeight: FontWeight.bold));
                      }).toList();
                    },
                    tooltipBottomMargin: 20,
                    tooltipRoundedRadius: 16,
                    tooltipBgColor: Colors.white,
                  ),
                  handleBuiltInTouches: true,
                  touchSpotThreshold: touchTreshold),
              gridData: FlGridData(
                show: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: SideTitles(
                  showTitles: false,
                ),
                leftTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              extraLinesData: ExtraLinesData(extraLinesOnTop: false, horizontalLines: horizontalLines, verticalLines: verticalLines),
              borderData: FlBorderData(
                show: false,
              ),
              minX: minimumX,
              maxX: maximumX,
              maxY: maximumY,
              minY: minimumY,
              lineBarsData: parsedData == null ? null : [parsedData],
            ),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ))
      );
  }

  Widget _buildDateRangeToggle(double sizeMultiplier) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 56 * sizeMultiplier - 16),
            padding: EdgeInsets.only(bottom: 16 * sizeMultiplier),
            child: Center(
                child: Container(
                    constraints: BoxConstraints(minHeight: 48),
                    child: ToggleButtons(
                      borderColor: Color(0xFF62696a),
                      selectedBorderColor: Constants.mediumBlue,
                      selectedColor: Constants.mediumBlue,
                      color: Color(0xFF62696a),
                      fillColor: Constants.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                      children: <Widget>[
                        Semantics(
                            selected: dateRangeChoices[0],
                            child: Container(
                                constraints: BoxConstraints(minHeight: 48, minWidth: 60 * sizeMultiplier),
                                alignment: Alignment.center,
                                child: Center(
                                    child: Text(FlutterI18n.translate(context, 'home.charts.total'),
                                        style: TextStyle(height: 1, fontWeight: dateRangeChoices[2] ? FontWeight.w500 : FontWeight.normal))))),
                        Semantics(
                            selected: dateRangeChoices[1],
                            child: Container(
                                constraints: BoxConstraints(minHeight: 48, minWidth: 60 * sizeMultiplier),
                                alignment: Alignment.center,
                                child: Center(
                                    child: Text(FlutterI18n.translate(context, 'home.charts.oneMonth'),
                                        style: TextStyle(height: 1, fontWeight: dateRangeChoices[0] ? FontWeight.w500 : FontWeight.normal))))),
                        Semantics(
                            selected: dateRangeChoices[2],
                            child: Container(
                                constraints: BoxConstraints(minHeight: 48, minWidth: 60 * sizeMultiplier),
                                alignment: Alignment.center,
                                child: Center(
                                    child: Text(FlutterI18n.translate(context, 'home.charts.fourteenDays'),
                                        style: TextStyle(height: 1, fontWeight: dateRangeChoices[1] ? FontWeight.w500 : FontWeight.normal))))),
                      ],
                      onPressed: (int index) {
                        _handleDateRangeChange(index);
                      },
                      isSelected: dateRangeChoices,
                    )))));
  }

  @override
  Widget build(BuildContext context) {
    _parseData(widget.data);
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    return Container(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        margin: EdgeInsets.only(right: 8 * sizeMultiplier),
        padding: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Constants.lightGrey,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: SingleChildScrollView(
            child: Container(
                constraints: BoxConstraints(minHeight: 300 * sizeMultiplier),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  _buildCardHeader(sizeMultiplier),
                  _buildChart(sizeMultiplier),
                  _buildDateRangeToggle(sizeMultiplier),
                ]))));
  }
}
