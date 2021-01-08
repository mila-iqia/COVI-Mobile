import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/covid_stats.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../customButton.dart';

class DashboardChartCardLocationUnavailable extends StatelessWidget {
  final List<CovidStatsStatuses> statuses;

  DashboardChartCardLocationUnavailable({
    @required this.statuses,
  }) : assert(statuses != null);

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    Widget _buildCardHeader(double sizeMultiplier) {
      return 
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(FlutterI18n.translate(context, 'home.charts.noLocationServices.${EnumToString.parse(statuses.first)}'),
              style: TextStyle(color: Constants.darkBlue, fontWeight: FontWeight.bold, fontSize: 14 * sizeMultiplier),
          ),
          Text(
              FlutterI18n.translate(context, 'home.charts.informationUnavailable'),
              style: TextStyle(fontStyle: FontStyle.italic, color: Constants.mediumGrey, fontWeight: FontWeight.w500, fontSize: 12 * sizeMultiplier),
          )
        ],
      );
    }

    Widget _buildCard(double sizeMultiplier) {
      return Stack(children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 135 * sizeMultiplier),
          margin: EdgeInsets.only(
              top: 16 * sizeMultiplier, bottom: 24 * sizeMultiplier),
          decoration: BoxDecoration(
              color: Color(0xFFfff2f2),
              borderRadius:
                  BorderRadius.all(Radius.circular(12.0))),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * sizeMultiplier),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(12 * sizeMultiplier),
                    child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/no-location.svg', height: 66 * sizeMultiplier))),
                  Container(
                    margin: EdgeInsets.only(bottom: 40 * sizeMultiplier * MediaQuery.of(context).textScaleFactor),
                    child:
                      Text(FlutterI18n.translate(context, 'home.charts.regionUnavailable'),
                        textAlign: TextAlign.center,
                        style: TextStyle(height: 1.2, fontWeight: FontWeight.bold, fontSize: 14 * sizeMultiplier, color: Constants.darkBlue))
                  )
                ],
              ))),
        Positioned(
          bottom: 0,
          child:
            Container(
              width: MediaQuery.of(context).size.width - 56 * sizeMultiplier - 16,
              constraints: BoxConstraints(minHeight: 48 * sizeMultiplier),
              child: Center(
                  child: CustomButton(
                    borderRadius: 16,
                    label: FlutterI18n.translate(context, 'home.charts.privacySettings'),
                    icon: SvgPicture.asset(
                      'assets/svg/arrow-blue.svg',
                      height: 12 * sizeMultiplier,
                      color: Constants.darkBlue,
                    ),
                    iconPosition: CustomButtonIconPosition.after,
                    shadowColor: Colors.transparent,
                    backgroundColor: Color(0xFFfe8a8a),
                    padding: EdgeInsets.symmetric(horizontal: 16 * sizeMultiplier),
                    splashColor: Constants.blueSplash,
                    textColor: Constants.darkBlue,
                    onPressed: () {
                      Navigator.of(context).pushNamed("/profile", arguments: 1);
                    })))
        )
      ]);
    }

    return Container(
      transform: Matrix4.translationValues(-16, 0.0, 0.0),
      margin: EdgeInsets.only(right: 8 * sizeMultiplier),
      padding: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Constants.lightGrey,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: 
        SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: sizeMultiplier * 300),
            padding: EdgeInsets.fromLTRB(
              24 * sizeMultiplier,
              24 * sizeMultiplier,
              24 * sizeMultiplier,
              0),
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              _buildCardHeader(sizeMultiplier),
              _buildCard(sizeMultiplier),
            ])
          )
        )
    );
  }
}
