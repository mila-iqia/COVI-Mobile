import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:covi/material/contextualBackdrops/darkBlueArrows.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/material/expandableCard.dart';
import 'package:covi/material/expandableList.dart';

class OfficialResourcesScreen extends StatefulWidget {
  OfficialResourcesScreen({key}) : super(key: key);

  _OfficialResourcesScreenState createState() =>
      _OfficialResourcesScreenState();
}

class _OfficialResourcesScreenState extends State<OfficialResourcesScreen> {
  var cardHeaderStyle =
      TextStyle(color: Constants.mediumBlue, fontWeight: FontWeight.bold);

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url})';
    }
  }

  Container _generateGrouping(String groupKey, int max) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    final children = <Widget>[];
    for (var i = 1; i <= max; i++) {
      children.add(Material(
          child: Semantics(
              label: FlutterI18n.translate(
                      context, 'resources.documents.${groupKey}.doc${i}Title') +
                  FlutterI18n.translate(context, "a11y.externalLink"),
              link: true,
              child: InkWell(
                  onTap: () {
                    _launchURL(FlutterI18n.translate(
                        context, 'resources.documents.${groupKey}.doc${i}URL'));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          border: i != max
                              ? Border(
                                  bottom: BorderSide(
                                      width: 1, color: Constants.borderGrey))
                              : null),
                      padding: EdgeInsets.fromLTRB(32, 16, 0, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                              child: ExcludeSemantics(
                                  child: Text(
                                      FlutterI18n.translate(context,
                                          'resources.documents.${groupKey}.doc${i}Title'),
                                      style: TextStyle(
                                          color: Constants.mediumBlue,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14 * sizeMultiplier,
                                          height: 1.2)))),
                          Container(
                            width: 57,
                            child: Center(
                                child: ExcludeSemantics(
                                    child: SvgPicture.asset(
                                        "assets/svg/share-icon.svg"))),
                          )
                        ],
                      ))))));
    }

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: ExpandableCard(
          headerText: FlutterI18n.translate(
              context, 'resources.documents.${groupKey}.title'),
          headerStyle: cardHeaderStyle,
          color: ExpandleCardColors.blue,
          content: Column(
            children: children,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return DarkBlueArrows(
        title: FlutterI18n.translate(context, "resources.title"),
        subtitle: FlutterI18n.translate(context, "resources.subtitle"),
        child: Container(
            child: Column(
          children: <Widget>[
            ExpandableList(
              title: FlutterI18n.translate(
                  context, "resources.officialDocumentation"),
              content: <Widget>[
                _generateGrouping('covidGrouping', 9),
                _generateGrouping('socialDistancingGrouping', 1),
                _generateGrouping('canadaResponseGrouping', 5),
                _generateGrouping('travelAdviceGrouping', 5),
              ],
            ),
          ],
        )));
  }
}
