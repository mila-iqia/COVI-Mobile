import 'package:flutter/material.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExternalLink extends StatelessWidget {
  const ExternalLink(
      {this.label, this.onTap, this.alignment = MainAxisAlignment.center});

  final String label;
  final Function onTap;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return Semantics(
      link: true,
      label: FlutterI18n.translate(context, "a11y.externalLink"),
      child: InkWell(
          child: Row(
            mainAxisAlignment: alignment,
            children: <Widget>[
              Flexible(
                  child: Text(label,
                      style: TextStyle(
                        color: Constants.mediumBlue,
                        fontSize: 14 * sizeMultiplier,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ))),
              Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: ExcludeSemantics(
                      child: SvgPicture.asset('assets/svg/share-icon.svg',
                          width: 20 * sizeMultiplier)))
            ],
          ),
          onTap: onTap),
    );
  }
}
