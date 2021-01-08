import 'package:flutter/material.dart';
import 'package:covi/material/customButton.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:covi/utils/constants.dart' as Constants;

class StepperCoviButtons extends StatelessWidget {
  const StepperCoviButtons({
    this.backLabel,
    this.nextLabel,
    this.onPressedBack,
    this.onPressedNext,
  });

  final String backLabel;
  final String nextLabel;
  final Function onPressedBack;
  final Function onPressedNext;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Container(
        padding: EdgeInsets.all(16 * sizeMultiplier),
        child: Wrap(
          runSpacing: 16,
          children: <Widget>[
            CustomButton(
              minWidth: MediaQuery.of(context).size.width * 0.5 -
                  (4 * sizeMultiplier) -
                  (16 * sizeMultiplier),
              label: backLabel != null
                  ? backLabel
                  : FlutterI18n.translate(context, "onboarding.backButton"),
              icon: SvgPicture.asset('assets/svg/arrow-back.svg'),
              backgroundColor: Colors.white,
              textColor: Constants.darkBlue,
              padding: EdgeInsets.only(right: 10),
              onPressed: onPressedBack,
            ),
            Container(width: 8 * sizeMultiplier),
            CustomButton(
                minWidth: MediaQuery.of(context).size.width * 0.5 -
                    (4 * sizeMultiplier) -
                    (16 * sizeMultiplier),
                label: nextLabel != null
                    ? nextLabel
                    : FlutterI18n.translate(
                        context, "onboarding.continueButton"),
                backgroundColor: Constants.yellow,
                textColor: Constants.darkBlue,
                shadowColor: Colors.black12,
                onPressed: onPressedNext)
          ],
        ));
  }
}
