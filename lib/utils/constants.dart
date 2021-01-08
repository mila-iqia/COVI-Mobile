library constants;

import 'package:flutter/material.dart';

const Color transparent = Color(0x00000000);
const Color darkGrey = Color.fromRGBO(99, 106, 107, 1);
const Color mediumGrey = Color(0xFF62696a);
const Color borderGrey = Color.fromRGBO(230, 230, 230, 1);
const Color lightGrey = Color(0xFFfaf9f7);
const Color beige = Color.fromRGBO(235, 232, 225, 1);
const Color lightBeige = Color(0xFFf4f3f0);
const Color darkBlue = Color.fromRGBO(45, 57, 83, 1);
const Color darkBlue20 = Color.fromRGBO(45, 57, 83, 0.2);
const Color darkBlue70 = Color.fromRGBO(45, 57, 83, 0.7);
const Color mediumBlue = Color.fromRGBO(46, 78, 158, 1);
const Color blueSplash = Color.fromRGBO(102, 132, 209, 0.5);
const Color ceruleanBlue = Color.fromRGBO(82, 131, 255, 1);
const Color lightBlue = Color.fromRGBO(229, 234, 243, 1);
const Color veryLightBlue = Color(0xFFedf0f6);
const Color covidBlue = Color(0xFF3E4D6D);
const Color yellow = Color.fromRGBO(249, 195, 90, 1);
const Color yellowSplash = Color.fromRGBO(255, 226, 159, 0.5);
const Color lightRed = Color.fromRGBO(255, 242, 242, 1);
const Color beigeRed = Color(0xFFf6f0e9);
const Color pinkRed = Color(0xFFfe8a8a);
const Color lightPink = Color.fromRGBO(247, 240, 234, 1);
const Color mediumRed = Color.fromRGBO(189, 35, 42, 1);
const Color redSplash = Color.fromRGBO(208, 118, 122, 0.5);

const String privacyPolicyURL_EN =
    "https://covicanada.org/legal/privacy-policy/";
const String privacyPolicyURl_FR =
    "https://covicanada.org/fr/legal/politique-vie-privee/";
const String cdnUrl = "https://cdn.coviapp.io";
const String updateJsonURL = '${cdnUrl}/updates.json';
const String apiUrl = "https://api.coviapp.io";

const String playStoreID = "com.covi.app";
const String appStoreID = "1507220865";

const int notificationsRange = 100;
const int notificationSetupNotDoneId = 500;
const int notificationSelfScreenId = 600;
const int notificationSymptomsId = 700;
const int notificationAppClosed = 800;

bool isBluetoothServiceStarted = false;

const String appVersion = "COVI 1.5.6";

class CustomTextStyle {
  // For a11y
  static TextStyle visuallyHidden(BuildContext context) {
    return TextStyle(fontSize: 1, color: Colors.transparent);
  }

  // For header 1
  static TextStyle darkBlue18Text(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return TextStyle(
        fontFamily: 'Neue',
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontSize: 18 * sizeMultiplier,
        color: darkBlue);
  }

  // For headers
  static TextStyle whiteMd14Text(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return TextStyle(
        fontFamily: 'Neue',
        fontWeight: FontWeight.w500,
        height: 1.3,
        fontSize: 14 * sizeMultiplier,
        color: Colors.white);
  }

  // For body font
  static TextStyle grey14Text(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return TextStyle(
        fontFamily: 'Neue',
        fontWeight: FontWeight.w300,
        height: 1.3,
        fontSize: 14 * sizeMultiplier,
        color: mediumGrey);
  }

  // For labels
  static TextStyle darkBlue14Text(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return TextStyle(
        fontFamily: 'Neue',
        fontWeight: FontWeight.w500,
        height: 1.3,
        fontSize: 14 * sizeMultiplier,
        color: darkBlue);
  }

  // For form errors
  static TextStyle red12Text(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return TextStyle(
        fontFamily: 'Neue',
        fontWeight: FontWeight.w500,
        height: 1.2,
        fontSize: 12 * sizeMultiplier,
        color: mediumRed);
  }

  // For keyboard actions
  static TextStyle blue14Text(BuildContext context) {
    double sizeMultiplier = MediaQuery.of(context).size.width / 320;

    return TextStyle(
        fontFamily: 'Neue',
        fontWeight: FontWeight.w500,
        height: 1,
        fontSize: 14 * sizeMultiplier,
        color: ceruleanBlue);
  }
}
