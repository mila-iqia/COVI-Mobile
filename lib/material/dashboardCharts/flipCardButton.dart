import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlipCardButton extends StatelessWidget {
  const FlipCardButton({
    @required this.isStatisticsShown,
    this.onPressed
  });

  final bool isStatisticsShown;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return MergeSemantics(
          child:
            Semantics(
              label: isStatisticsShown ? FlutterI18n.translate(context,'home.charts.flipCardChart') : FlutterI18n.translate(context,'home.charts.flipCardStats'),
              button: true,
              child:
                Container(
                  width: 48 * sizeMultiplier,
                  height: 48 * sizeMultiplier,
                  child: FlatButton(
                    splashColor: Colors.black12,
                    highlightColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    padding: EdgeInsets.all(0),
                    child: ExcludeSemantics(child: SvgPicture.asset('assets/svg/icon-flip.svg')),
                    onPressed: onPressed))
            )
        );
  }
}
