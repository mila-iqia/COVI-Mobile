import 'package:covi/material/dashboardCharts/dashboardChartCardContainer.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:covi/material/dashboardCharts/flipCardButton.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart' as intl;
import "package:covi/utils/extensions.dart";
import 'package:covi/utils/user_regions.dart';

class DashboardChartCardBack extends StatefulWidget {
  final String title;
  final List<DashboardBackDataBag> data;
  final UserRegionState state;
  final String locale;
  final Function flipCardHandler;

  const DashboardChartCardBack({Key key, this.title, this.data, @required this.state, this.locale, this.flipCardHandler}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardChartCardBackState();
}

class _DashboardChartCardBackState extends State<DashboardChartCardBack> with SingleTickerProviderStateMixin {
  int activeDayIndex = 0;
  AnimationController _animationController;
  Animation<Color> _colorTween;
  int cases;
  int casesChange;
  int recoveries;
  int recoveriesChange;
  int deaths;
  int deathsChange;

  DateTime from;
  DateTime to;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1800),
      vsync: this,
    );
    _colorTween = _animationController.drive(ColorTween(begin: Constants.yellow, end: Constants.mediumBlue));
    _animationController.repeat();
    if (!widget.data.isEmpty) {
      _updateCounts(widget.data.length - 1);
      _setDates();
    }
  }

  @override
  dispose() {
    _animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  void didUpdateWidget(DashboardChartCardBack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data && widget.data.isEmpty) {
      _updateCounts(widget.data.length - 1);
      _setDates();
    }
  }

  void _setDates() {
    setState(() {
      from = widget.data.first.date;
      to = widget.data.last.date;
    });
  }

  void _updateCounts(int index) {
    if (widget.data != null && widget.data.length > 0 && widget.data[index] != null) {
      setState(() {
        activeDayIndex = index;
        cases = widget.data[index].cases;
        casesChange = widget.data[index].casesChange;
        deaths = widget.data[index].deaths;
        deathsChange = widget.data[index].deathsChange;
        recoveries = widget.data[index].recoveries;
        recoveriesChange = widget.data[index].recoveriesChange;
      });
    }
  }

  String _getPointerDate(int index, bool isTitle) {
    if (widget.data == null || widget.data.isEmpty || index + 1 > widget.data.length|| widget.data[index] == null) {
      return null;
    }
    DateTime date = widget.data[index].date;
    return date.isToday() ? FlutterI18n.translate(context, 'today') : isTitle ? '${new intl.DateFormat.MMMMd(widget.locale).format(date)}' : '${new intl.DateFormat.MMMd(widget.locale).format(date)}';
  }

  String _getFormattedDate(DateTime date) {
    if (date == null) return "";
    return '${new intl.DateFormat.MMMd(widget.locale).format(date)}';
  }

  Text _parseChange(int change, double sizeMultiplier, String semanticsLabel, {bool isPositiveRed = true}) {
    String changeSign = "";
    String changeStr = "0";
    Color color = Color(0xFF62696a);
    if (change != null) {
      if (change > 0) {
        changeSign = "+";
        color = isPositiveRed ? Color(0xFFdb6464) : Color(0xFF2d9a77);
      } else if (change < 0) {
        changeSign = "-";
        color = isPositiveRed ? Color(0xFF2d9a77) : Color(0xFFdb6464);
      }
      changeStr = change.abs().formatDecimal(separator: " ");
    }

    return Text(
      " ${changeSign} ${changeStr}",
      semanticsLabel: " ${changeSign} ${changeStr}" + semanticsLabel,
      style: TextStyle(fontSize: 12 * sizeMultiplier, height: 1, color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _generateCounts(double sizeMultiplier) {
    return Container(
        padding: EdgeInsets.only(left: 16 * sizeMultiplier, top: 8 * sizeMultiplier),
        margin: EdgeInsets.only(top: 0, bottom: 16 * sizeMultiplier),
        width: MediaQuery.of(context).size.width - 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
                label: FlutterI18n.translate(context, "a11y.header4"),
                header: true,
                child: Text(
                  FlutterI18n.translate(context, 'home.charts.cases'),
                  style: TextStyle(fontSize: 14 * sizeMultiplier, color: Color(0xFF62696a), fontWeight: FontWeight.w500),
                )),
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
              Text(
                cases == null ? FlutterI18n.translate(context, 'home.charts.n/a') : cases.formatDecimal(separator: " "),
                semanticsLabel: cases == null ? FlutterI18n.translate(context, 'home.charts.notAvailable') : cases.formatDecimal(separator: " "),
                style: TextStyle(height: 1, fontSize: 40 * sizeMultiplier, color: Color(0xFF2d3953), fontWeight: FontWeight.bold),
              ),
              _parseChange(casesChange, sizeMultiplier, FlutterI18n.translate(context, 'home.charts.newCases'), isPositiveRed: true)
            ]),
            Padding(
                padding: EdgeInsets.only(top: 8 * sizeMultiplier),
                child: Wrap(alignment: WrapAlignment.spaceBetween, children: <Widget>[
                  FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Semantics(
                            label: FlutterI18n.translate(context, "a11y.header4"),
                            sortKey: OrdinalSortKey(1.0),
                            header: true,
                            child: Text(
                              FlutterI18n.translate(context, 'home.charts.recoveries'),
                              style: TextStyle(fontSize: 14 * sizeMultiplier, color: Color(0xFF62696a), fontWeight: FontWeight.w500),
                            ),
                          ),
                          Semantics(
                              sortKey: OrdinalSortKey(2.0),
                              label: recoveries == null ? FlutterI18n.translate(context, 'home.charts.notAvailable') : recoveries.formatDecimal(separator: " "),
                              child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
                                ExcludeSemantics(
                                    child: Text(
                                  recoveries == null ? FlutterI18n.translate(context, 'home.charts.n/a') : recoveries.formatDecimal(separator: " "),
                                  style: TextStyle(fontSize: 22 * sizeMultiplier, height: 1, color: Color(0xFF2d3953), fontWeight: FontWeight.bold),
                                )),
                                _parseChange(recoveriesChange, sizeMultiplier, FlutterI18n.translate(context, 'home.charts.newRecoveries'),
                                    isPositiveRed: false)
                              ])),
                        ],
                      )),
                  FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Semantics(
                              sortKey: OrdinalSortKey(3.0),
                              label: FlutterI18n.translate(context, "a11y.header4"),
                              header: true,
                              child: Text(
                                FlutterI18n.translate(context, 'home.charts.deaths'),
                                style: TextStyle(fontSize: 14 * sizeMultiplier, color: Color(0xFF62696a), fontWeight: FontWeight.w500),
                              )),
                          Semantics(
                              sortKey: OrdinalSortKey(4.0),
                              label: deaths == null ? FlutterI18n.translate(context, 'home.charts.notAvailable') : deaths.formatDecimal(separator: " "),
                              child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
                                ExcludeSemantics(
                                    child: Text(
                                  deaths == null ? FlutterI18n.translate(context, 'home.charts.n/a') : deaths.formatDecimal(separator: " "),
                                  style: TextStyle(height: 1, fontSize: 22 * sizeMultiplier, color: Color(0xFF2d3953), fontWeight: FontWeight.bold),
                                )),
                                _parseChange(deathsChange, sizeMultiplier, FlutterI18n.translate(context, 'home.charts.newDeaths'), isPositiveRed: true)
                              ])),
                        ],
                      ))
                ])),
          ],
        ));
  }

  static Future<void> announce(String message, TextDirection textDirection) async {
    final AnnounceSemanticsEvent event = AnnounceSemanticsEvent(message, textDirection);
    await SystemChannels.accessibility.send(event.toMap());
  }

  Widget _generateSlider(double sizeMultiplier) {
    return Center(
        child: MergeSemantics(
            child: Semantics(
                label: FlutterI18n.translate(context, 'home.charts.dataDisplayedFor'),
                value: _getPointerDate(activeDayIndex, true),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    valueIndicatorColor: Colors.white,
                    valueIndicatorTextStyle: TextStyle(color: Constants.mediumBlue, fontWeight: FontWeight.w500),
                    activeTrackColor: Constants.mediumBlue,
                    inactiveTrackColor: Constants.mediumBlue,
                    trackShape: RoundedRectSliderTrackShape(),
                    tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 0),
                    trackHeight: 4.0,
                    thumbColor: Constants.mediumBlue,
                    thumbShape: CustomSliderThumbRect(thumbRadius: 32, thumbHeight: 32 * sizeMultiplier, min: 0, max: 3),
                    overlayColor: Constants.lightBlue,
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 24 * sizeMultiplier),
                  ),
                  child: Container(
                      constraints: BoxConstraints(minHeight: 74 * sizeMultiplier),
                      margin: EdgeInsets.all(16 * sizeMultiplier),
                      decoration: BoxDecoration(color: Color(0xFFf0f0f0), borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      child: Column(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(14 * sizeMultiplier, 8 * sizeMultiplier, 14 * sizeMultiplier, 0),
                              child: ExcludeSemantics(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(_getFormattedDate(from),
                                      style: TextStyle(color: Constants.mediumBlue, fontSize: 12 * sizeMultiplier, fontWeight: FontWeight.w500)),
                                  Text(to.isToday() ? FlutterI18n.translate(context, 'today') : _getFormattedDate(to),
                                      style: TextStyle(color: Constants.mediumBlue, fontSize: 12 * sizeMultiplier, fontWeight: FontWeight.w500)),
                                ],
                              ))),
                          Slider(
                            min: 0.0,
                            max: widget.data == null || widget.data.length == 0 ? 1 : widget.data.length.toDouble() - 1,
                            divisions: widget.data == null || widget.data.length == 0 ? 1 : widget.data.length - 1,
                            label: _getPointerDate(activeDayIndex, false),
                            value: widget.data != null && widget.data.length > activeDayIndex ? activeDayIndex.toDouble() : 0,
                            onChanged: (value) {
                              _updateCounts(value.toInt());
                              announce(FlutterI18n.translate(context, 'home.charts.dataDisplayedFor') + _getPointerDate(activeDayIndex, false), TextDirection.ltr);
                            },
                          )
                        ],
                      )),
                ))));
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Container(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        margin: EdgeInsets.only(right: 8 * sizeMultiplier),
        padding: EdgeInsets.only(left: 16 * sizeMultiplier),
        height: sizeMultiplier * 300,
        decoration: BoxDecoration(
          color: Constants.lightGrey,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: SingleChildScrollView(
            child: Container(
                constraints: BoxConstraints(minHeight: sizeMultiplier * 300),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 16 * sizeMultiplier, top: 16 * sizeMultiplier),
                          child: Semantics(
                              sortKey: OrdinalSortKey(1.0),
                              label: FlutterI18n.translate(context, "a11y.header3"),
                              header: true,
                              child: Text(
                                widget.title != null ? widget.title : "",
                                style: TextStyle(color: Constants.darkBlue, fontWeight: FontWeight.bold, fontSize: 14 * sizeMultiplier),
                              )),
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 4 * sizeMultiplier, left: 16 * sizeMultiplier),
                            child: Semantics(
                                sortKey: OrdinalSortKey(2.0),
                                child: Text(
                                  _getPointerDate(activeDayIndex, true),
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic, color: Constants.mediumGrey, fontWeight: FontWeight.w500, fontSize: 12 * sizeMultiplier),
                                ))),

                      ])),
                      SizedBox(
                        child: Row(
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
                                    strokeWidth: 2 * sizeMultiplier,
                                  ),
                                  height: 12 * sizeMultiplier,
                                  width: 12 * sizeMultiplier,
                                )),
                              ),
                            FlipCardButton(onPressed: widget.flipCardHandler, isStatisticsShown: true)
                          ],
                        ),
                      )
                    ],
                  ),
                  _generateCounts(sizeMultiplier),
                  Semantics(
                      label: FlutterI18n.translate(context, "a11y.header4"),
                      header: true,
                      child: Text(
                          FlutterI18n.translate(context, "home.charts.dateStats") +
                              _getFormattedDate(from) +
                              FlutterI18n.translate(context, "home.charts.to") +
                              _getFormattedDate(to),
                          style: Constants.CustomTextStyle.visuallyHidden(context))),
                  _generateSlider(sizeMultiplier)
                ]))));
  }
}

class CustomSliderThumbRect extends SliderComponentShape {
  final double thumbRadius;
  final thumbHeight;
  final int min;
  final int max;

  const CustomSliderThumbRect({@required this.thumbRadius, @required this.thumbHeight, this.min, this.max});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius / 2);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: thumbHeight * 1, height: thumbHeight * .6),
      Radius.circular(thumbRadius * .4),
    );

    final paint = Paint()
      ..color = sliderTheme.thumbColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rRect, paint);
    canvas.drawPath(_rightTriangle(thumbHeight * 0.15, center.translate(thumbHeight * .25, 0)), Paint()..color = Constants.lightGrey);
    canvas.drawPath(_leftTriangle(thumbHeight * 0.15, center.translate(-(thumbHeight * .25), 0)), Paint()..color = Constants.lightGrey);
  }

  Path _rightTriangle(double size, Offset thumbCenter, {bool invert = false}) {
    final Path thumbPath = Path();
    final double halfSize = size / 2.0;
    final double sign = invert ? -1.0 : 1.0;
    thumbPath.moveTo(thumbCenter.dx + halfSize * sign, thumbCenter.dy);
    thumbPath.lineTo(thumbCenter.dx - halfSize * sign, thumbCenter.dy - size);
    thumbPath.lineTo(thumbCenter.dx - halfSize * sign, thumbCenter.dy + size);
    thumbPath.close();
    return thumbPath;
  }

  Path _leftTriangle(double size, Offset thumbCenter) => _rightTriangle(size, thumbCenter, invert: true);

  String getValue(double value) {
    return ((max) * (value)).round().toString();
  }
}
