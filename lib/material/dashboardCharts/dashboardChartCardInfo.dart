import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardChartCardInfo extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return 
        Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        FlutterI18n.translate(context,'home.yourActivity.title'),
                        style: TextStyle(
                            fontSize: 16 * sizeMultiplier,
                            color: Constants.darkBlue,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        FlutterI18n.translate(context,'home.yourActivity.subtitle'),
                        style: TextStyle(
                          height: 1.2,
                          fontSize: 14 * sizeMultiplier,
                          color: Color(0xFF62696a),
                        ),
                      ),
                      Stack(children: <Widget>[
                        Container(
                            constraints: BoxConstraints(minHeight: 135 * sizeMultiplier),
                            margin: EdgeInsets.only(
                                top: 16 * sizeMultiplier, bottom: 24 * sizeMultiplier),
                            decoration: BoxDecoration(
                                color: Color(0xFFedf0f6),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0))),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16 * sizeMultiplier),
                                    child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(12 * sizeMultiplier),
                                  child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/icon-activity.svg', height: 32 * sizeMultiplier))),
                                Container(
                                  // margin: EdgeInsets.only(bottom: 40 * sizeMultiplier),
                                  child:
                                    Text(FlutterI18n.translate(context,'home.yourActivity.bubbleText'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          height: 1.2,
                                          fontWeight: FontWeight.bold,
                                                fontSize: 14 * sizeMultiplier,
                                                color: Constants.darkBlue))
                                ),
                              ],
                            ))),
                      ])
                    ],
              ))
            )
    );
  }
}
