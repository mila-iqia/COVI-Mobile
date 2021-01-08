import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/user_regions.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:enum_to_string/enum_to_string.dart';

class DashboardChartCardNoInternet extends StatelessWidget {
  final UserRegionState state;
  final String title;

  DashboardChartCardNoInternet({
    @required this.state,
    @required this.title,
  })  : assert(state != null),
        assert(title != null);

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    Widget _buildCardHeader(double sizeMultiplier) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 24, top: 24),
                child: Text(
                  title,
                  style: TextStyle(color: Constants.darkBlue, fontWeight: FontWeight.bold, fontSize: 14 * sizeMultiplier),
                )),
            Padding(
                padding: EdgeInsets.only(bottom: 4, left: 24),
                child: Text(
                  FlutterI18n.translate(context, 'home.charts.informationUnavailable'),
                  style: TextStyle(fontStyle: FontStyle.italic, color: Constants.mediumGrey, fontWeight: FontWeight.w500, fontSize: 12 * sizeMultiplier),
                )),
          ])
        ],
      );
    }

    Widget _buildCard(double sizeMultiplier) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * sizeMultiplier),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 16 * sizeMultiplier),
              height: 205 * sizeMultiplier,
              width: 265 * sizeMultiplier,
              child: Stack(children: <Widget>[
                 Container(
                  decoration: BoxDecoration(color: Color(0xFFfff2f2), borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
                Center(
                    child: Padding(
                        padding: EdgeInsets.all(16 * sizeMultiplier),
                        child: Text(FlutterI18n.translate(context, 'home.charts.updateWarnings.${EnumToString.parse(state)}'),
                            textAlign: TextAlign.center,
                            style: TextStyle(height: 1.2, fontWeight: FontWeight.bold, fontSize: 14 * sizeMultiplier, color: Constants.darkBlue))))
              ])));
    }

    return Container(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        margin: EdgeInsets.only(right: 8 * sizeMultiplier),
        padding: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Constants.lightGrey,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        // margin: EdgeInsets.only(top: 25, right: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          _buildCardHeader(sizeMultiplier),
          _buildCard(sizeMultiplier),
        ]));
  }
}
