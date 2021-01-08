import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;

class DashboardChartCardLoading extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DashboardChartCardLoadingState();
}

class _DashboardChartCardLoadingState extends State<DashboardChartCardLoading>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Color> _colorTween;

  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1800),
      vsync: this,
    );
    _colorTween = _animationController
        .drive(ColorTween(begin: Constants.yellow, end: Constants.mediumBlue));
    _animationController.repeat();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    return Container(
      transform: Matrix4.translationValues(-16, 0.0, 0.0),
          margin: EdgeInsets.only(right: 8 * sizeMultiplier),
        height: sizeMultiplier * 300,
        padding: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Constants.lightGrey,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: Container(
            child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Center(
                    child: SizedBox(
                  child: CircularProgressIndicator(
                    valueColor: _colorTween,
                    strokeWidth: 4 * sizeMultiplier,
                  ),
                  height: 50 * sizeMultiplier,
                  width: 50 * sizeMultiplier,
                )),
              ),
            )
          ],
        )));
  }
}
