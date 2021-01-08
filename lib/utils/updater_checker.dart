import 'dart:convert';

import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
import 'package:launch_review/launch_review.dart';
import 'package:version/version.dart';

class UpdateChecker {
  /// Show update dialog
  Future<void> showUpdateDialog(
      BuildContext context, Update update, String lang) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              title: Text(FlutterI18n.translate(context, "updates.title")),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(FlutterI18n.translate(
                        context, "updates.version_available",
                        translationParams: {
                          "version_name": update.version_name
                        })),
                    Text(FlutterI18n.translate(
                        context, "updates.current_version", translationParams: {
                      "version_name": packageInfo.version
                    })),
                    Text(FlutterI18n.translate(context, "updates.changelog")),
                    Text(""),
                    for (var changelog in update.getChangelog(lang))
                      Text("* " + changelog),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Update the app'),
                  onPressed: () async {
                    LaunchReview.launch(
                        androidAppId: Constants.playStoreID,
                        iOSAppId: Constants.appStoreID,
                        writeReview: false);
                  },
                ),
              ],
            ));
      },
    );
  }

  /// Check if an update is available
  Future<Update> checkForUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // Get our app version
    Version version = Version.parse(packageInfo.version);

    Logger().v("[UpdateChecker] Local version is $version");

    try {
      // Fetch the remote JSON
      Response response = await http.get(Constants.updateJsonURL);

      // Parse the json
      List<dynamic> updates = json.decode(response.body);

      if (updates.length == 0) {
        Logger().v("[UpdateChecker] No update is available.");
        return null;
      }

      // Compare the latest update with our local version
      Update update = new Update.fromJson(updates.first);

      if (Version.parse(update.version_name) > version) {
        Logger().v("[UpdateChecker] New version is available.");

        return update;
      }

      Logger().v("[UpdateChecker] No update is available.");
      return null;
    } catch (e) {
      Logger().e("[UpdateChecker] Couldn't fetch updates.json from CDN.");
      return null;
    }
  }
}

class Update {
  int id;
  String version_name;
  String short_desc_en;
  String short_desc_fr;
  String changelog_en;
  String changelog_fr;

  Update({this.id, this.version_name, this.changelog_en, this.changelog_fr});

  List<String> getChangelog(lang) {
    if (lang == "fr") {
      return this.changelog_fr.split("_");
    }

    return this.changelog_en.split("_");
  }

  Update.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.version_name = json["version_name"];
    this.changelog_en = json["changelog_en"];
    this.changelog_fr = json["changelog_fr"];
  }
}
