import 'package:covi/material/actionCard.dart';
import 'package:covi/material/contextualBackdrops/beige.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:covi/utils/constants.dart' as Constants;
import 'package:covi/utils/settings.dart';
import 'package:url_launcher/url_launcher.dart';

class GetTestedScreen extends StatefulWidget {
  GetTestedScreen({key}) : super(key: key);

  _GetTestedScreenState createState() => _GetTestedScreenState();
}

class _GetTestedScreenState extends State<GetTestedScreen> {
  String locale;
  DateTime symptomsUpdateDate;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url})';
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SettingsManager settingsManager =
          Provider.of<SettingsManager>(context, listen: false);

      String language = await settingsManager.getLang();

      setState(() {
        locale = language;
        symptomsUpdateDate =
            settingsManager.settings.user_data.symptomsUpdateDate;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;
    String cameFrom = ModalRoute.of(context).settings.arguments;

    return Beige(
        title: FlutterI18n.translate(context, "actions.getTested.title"),
        subtitle: FlutterI18n.translate(context, "actions.getTested.subtitle"),
        backLabel: cameFrom == 'health'
            ? FlutterI18n.translate(context, "screens.health")
            : FlutterI18n.translate(context, "screens.dashboard"),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Divider(height: 32, color: Colors.transparent),
          Text(
              FlutterI18n.translate(
                  context, "actions.getTested.callHealthcarePro"),
              style: Constants.CustomTextStyle.darkBlue18Text(context)),
          Divider(height: 8, color: Colors.transparent),
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Text(
                FlutterI18n.translate(
                    context, "actions.getTested.explanations"),
                style: Constants.CustomTextStyle.grey14Text(context)),
          ),
          Divider(height: 20, color: Colors.transparent),
          ActionCard(
            cardPadding: 0,
            circleColor: ActionCardColor.gradientBlue,
            onTap: () {
              _launchURL('');
            },
            button: SvgPicture.asset('assets/svg/share-icon.svg',
                width: 20 * sizeMultiplier),
            semanticLabel: FlutterI18n.translate(context, "a11y.externalLink"),
            iconWidth: 32 * sizeMultiplier,
            content: Text(
                FlutterI18n.translate(
                    context, "actions.getTested.governmentWebsiteLink"),
                style: Constants.CustomTextStyle.darkBlue14Text(context).merge(
                    TextStyle(
                        color: Constants.mediumBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * sizeMultiplier))),
          ),
          Divider(height: 60 * sizeMultiplier),
          Text(
              FlutterI18n.translate(
                  context, "recommendations.didYouMakeAMistake"),
              style: Constants.CustomTextStyle.darkBlue18Text(context)),
          Divider(height: 8, color: Colors.transparent),
          Text(
              FlutterI18n.translate(
                  context, "recommendations.reSelfAssessExplanation"),
              style: Constants.CustomTextStyle.grey14Text(context)),
          Divider(height: 24, color: Colors.transparent),
          ActionCard(
            title: FlutterI18n.translate(
                context, "actions.actionCards.AC001.category"),
            onTap: () {
              Navigator.of(context).pushNamed("/actions/self-diagnostic");
            },
            circleColor: ActionCardColor.beige,
            content: Text(
                FlutterI18n.translate(
                    context, "actions.actionCards.AC001.title"),
                style: TextStyle(
                  color: Color(0xFF2d3953),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left),
            backgroundColor: Constants.lightBeige,
            lastUpdate: symptomsUpdateDate,
            icon: SvgPicture.asset('assets/svg/action-hand.svg'),
            button: SvgPicture.asset('assets/svg/arrow-blue.svg'),
          ),
          Divider(height: 24 * sizeMultiplier, color: Constants.transparent),
        ]));
  }
}
