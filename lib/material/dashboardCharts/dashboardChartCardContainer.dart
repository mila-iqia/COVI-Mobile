import 'package:covi/material/dashboardCharts/dashboardChartCardLoading.dart';
import 'package:covi/material/dashboardCharts/dashboardChartCardNoInternet.dart';
import 'package:covi/material/dashboardCharts/dashboardChartCardNotFound.dart';
import 'package:covi/utils/user_regions.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:covi/material/dashboardCharts/dashboardChartCardFront.dart';
import 'package:covi/material/dashboardCharts/dashboardChartCardBack.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class DashboardBackDataBag {
  int cases;
  int casesChange;
  int deaths;
  int deathsChange;
  int recoveries;
  int recoveriesChange;
  DateTime date;

  DashboardBackDataBag({
    @required this.date,
    this.cases = null,
    this.casesChange = null,
    this.deaths = null,
    this.deathsChange = null,
    this.recoveries = null,
    this.recoveriesChange = null,
  });
}

class DashboardChartCardContainer extends StatefulWidget {
  final UserRegion region;
  final String locale;
  final String level;

  const DashboardChartCardContainer({Key key, @required this.region, @required this.locale, @required this.level}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardChartCardContainerState();
}

class _DashboardChartCardContainerState extends State<DashboardChartCardContainer> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  bool isFrontCardDisplayed = true;

  List<DashboardBackDataBag> _parseData(Map<dynamic, dynamic> data) {
    Map<String, DashboardBackDataBag> dataByDate = {};

    if (data.containsKey('cases') && data['cases'] != null) {
      data['cases'].forEach((row) {
        DateTime date = DateTime.parse(row['date']);
        String mapDateKey = "${date.day}-${date.month}-${date.year}";
        if (!dataByDate.containsKey(mapDateKey)) {
          dataByDate[mapDateKey] = DashboardBackDataBag(date: date, cases: row['value'], casesChange: row['change']);
        } else {
          dataByDate[mapDateKey].cases = row['value'];
          dataByDate[mapDateKey].casesChange = row['change'];
        }
      });
    }
    if (data.containsKey('deaths') && data['deaths'] != null) {
      data['deaths'].forEach((row) {
        DateTime date = DateTime.parse(row['date']);
        String mapDateKey = "${date.day}-${date.month}-${date.year}";
        if (!dataByDate.containsKey(mapDateKey)) {
          dataByDate[mapDateKey] = DashboardBackDataBag(date: date, deaths: row['value'], deathsChange: row['change']);
        } else {
          dataByDate[mapDateKey].deaths = row['value'];
          dataByDate[mapDateKey].deathsChange = row['change'];
        }
      });
    }
    if (data.containsKey('recoveries') && data['recoveries'] != null) {
      data['recoveries'].forEach((row) {
        DateTime date = DateTime.parse(row['date']);
        String mapDateKey = "${date.day}-${date.month}-${date.year}";
        if (!dataByDate.containsKey(mapDateKey)) {
          dataByDate[mapDateKey] = DashboardBackDataBag(date: date, recoveries: row['value'], recoveriesChange: row['change']);
        } else {
          dataByDate[mapDateKey].recoveries = row['value'];
          dataByDate[mapDateKey].recoveriesChange = row['change'];
        }
      });
    }

    List<DashboardBackDataBag> parsedList = [];
    dataByDate.forEach((date, data) => parsedList.add(data));
    parsedList.sort((a, b) => a.date.millisecondsSinceEpoch.compareTo(b.date.millisecondsSinceEpoch));

    return parsedList;
  }

  @override
  Widget build(BuildContext context) {
    Function flipHandler = () {
      cardKey.currentState.toggleCard();
    };

    if (widget.region == null) {
      return DashboardChartCardLoading();
    }

    if (widget.region.state == UserRegionState.notFound) {
      return DashboardChartCardNotFound(
        title: FlutterI18n.translate(context, 'home.charts.notFound.${widget.level}'),
      );
    }

    String title = widget.region.data != null ? widget.region.data['name'][widget.locale] : '';
    if (title != null && title.length > 35) {
      title = title.substring(0, 35) + '…';
    }

    if (widget.region.state == UserRegionState.loading &&
        (widget.region.data == null || widget.region.data.isEmpty || (widget.region.data != null && !widget.region.hasLoadedData()))) {
      return DashboardChartCardLoading();
    }

    if ((widget.region.state == UserRegionState.noDataNoInternet || widget.region.state == UserRegionState.noDataNotReachable) &&
        (widget.region.data == null || widget.region.data.isEmpty || (widget.region.data != null && !widget.region.hasLoadedData()))) {
      return DashboardChartCardNoInternet(title: title, state: 
      widget.region.state);
    }

    return FlipCard(
        key: cardKey,
        flipOnTouch: false,
        direction: FlipDirection.VERTICAL,
        speed: 500,
        front: isFrontCardDisplayed
            ? DashboardChartCardFront(
                title: title,
                data: widget.region.data != null ? widget.region.data['stats']['cases'] : [],
                state: widget.region.state,
                locale: widget.locale,
                flipCardHandler: flipHandler)
            : ExcludeSemantics(
                child: DashboardChartCardFront(
                    title: title,
                    data: widget.region.data != null ? widget.region.data['stats']['cases'] : [],
                    state: widget.region.state,
                    locale: widget.locale,
                    flipCardHandler: flipHandler)),
        back: !isFrontCardDisplayed
            ? DashboardChartCardBack(
                title: title,
                data: widget.region.data != null ? _parseData(widget.region.data['stats']) : null,
                state: widget.region.state,
                locale: widget.locale,
                flipCardHandler: flipHandler)
            : ExcludeSemantics(
                child: DashboardChartCardBack(
                    title: title,
                    data: widget.region.data != null ? _parseData(widget.region.data['stats']) : null,
                    state: widget.region.state,
                    locale: widget.locale,
                    flipCardHandler: flipHandler)),
        onFlipDone: (status) {
          setState(() {
            isFrontCardDisplayed = status;
          });
        });
  }
}
