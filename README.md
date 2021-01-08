# K9-Team Covid App

## Setup

- Install the [Flutter](https://flutter.dev/docs/get-started/install) framework.
- Clone the repo
- You then can run the project using `flutter run`.
- Alternatively, you can install the [VSCode plugin](https://flutter.dev/docs/development/tools/vs-code) which makes development a LOT easier.

## Setup (iOS)

- Install [CocoaPods](https://cocoapods.org) on you computer.
- Go in the `ios` folder in a terminal and run `pod install`
- Open the `Runner.xcworkspace` Workspace in XCode, click on the Runner Project on the left, this will open the Project settings. Go in the "Signing & Capabilities" tab then select your team as the team parameter if it is not already present.
- Make sure to provision your device for local testing with the team. To do so, plug in your device. Click "Trust" or "Se fier" on your device, then in XCode, in the top bar next to the Play and Stop icon, select your device, then in the Signing & Capabilities section, it should show you a button to "Register Device", click on it.
- You are ready to run the app, to do so, simply click on the Play button in the top bar or do `cmd+R` in the XCode window.
- To attach the command line flutter debugger (and gaining access to Flutter DevTools), run `flutter devices` to see your device's name, then run `flutter attach -d "YOUR DEVICE NAME"` to attach. *Warning* Make sure your device's name doesn't include single quote and/or apostrophe as the flutter command will translate your double quote to single quote and will never find your device. You can change a device's name from Finder.

## Automatic Build

To trigger an automatic build, you must create a new tag. However, before doing so, make sure to update the version in the following files:

- ios/Runner.xcodeproj/project.pbxproj (you must change the 3 values referring to MARKETING_VERSION)
- pubspec.yaml (you must change the version)

## Useful links

- How to [Install and run Flutter/Dart DevTools](https://flutter.dev/docs/development/tools/devtools/cli) which provides "classical" web dev tools for the flutter app, including logger, performance analysing and element inspector in real time.

- The [Flutter Cookbook](https://flutter.dev/docs/cookbook) has lots of example on how to use Flutter.
- The [Effective Dart: Style](https://dart.dev/guides/language/effective-dart/style) guide will teach you how to properly write Dart code.
- [Adding assets](https://flutter.dev/docs/development/ui/assets-and-images) explains how to add assets (Images, fonts, etc) to the app.
- The [Widget Catalog](https://flutter.dev/docs/development/ui/widgets) shows a list of all the widgets you can use in Flutter.
- Also check [Material Components widgets](https://flutter.dev/docs/development/ui/widgets/material), we want to use these widgets instead of the Cupertino ones.
- The [Basic widgets](https://flutter.dev/docs/development/ui/widgets/basics) list is very good as well.
- The [Animations Introduction](https://flutter.dev/docs/development/ui/animations) shows how easy it is to animate part of the Flutter app.
- The [Navigation and routing](https://flutter.dev/docs/development/ui/navigation) page explains how to navigate between screens.
- [Layouts in Flutter](https://flutter.dev/docs/development/ui/layout), guide on how to do layouts.
- [JSON and serialization](https://flutter.dev/docs/development/data-and-backend/json), how to serialize json.
- [Simple app management](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple) explains how to do state management using [Provider](https://pub.dev/packages/provider).

## Useful Widgets

- [Hero](https://api.flutter.dev/flutter/widgets/Hero-class.html) makes it easy to transition a Widget from one screen to another screen effortless.
- [Icon](https://api.flutter.dev/flutter/widgets/Icon-class.html) makes it easy to use any Material Icons.
- [Image](https://api.flutter.dev/flutter/widgets/Image-class.html) makes it eay to display any Image from the assets, network and even memory!
- [Stack](https://api.flutter.dev/flutter/widgets/Stack-class.html) lets you stack Widgets on top of each other.
- [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html) shows Widgets in a list with no effort.

## Packages list

- [http](https://pub.dev/packages/http) for web requests.
- [flutter_file_picker](https://pub.dev/packages/flutter_file_picker) for selecting files or folders in the user's phone.
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for notifications.
- [share](https://pub.dev/packages/share) implements the native share feature on Android and iOS.
- [device_info](https://pub.dev/packages/device_info) to get some informations about the user's device.
- [permission_handler](https://pub.dev/packages/permission_handler) simplifies requesting permissons.
- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) adds support for Google Maps in Flutter.
- [connectivity](https://pub.dev/packages/connectivity) to check if the user is connected to Wifi, Mobile data or nothing.
- [cached_network_image](https://pub.dev/packages/cached_network_image) to show an image from the web and cache it after loading.
- [url_launcher](https://pub.dev/packages/url_launcher) to launch an url using external apps.
- [provider](https://pub.dev/packages/provider) for state management.
- [shared_preferences](https://pub.dev/packages/shared_preferences) to save settings on the device.
- [geolocator](https://pub.dev/packages/geolocator) to get the user location and such.
- [flutter_translate](https://pub.dev/packages/flutter_translate) simplifies translation in the app.
- [encrypt](https://pub.dev/packages/encrypt) can be used to encrypt some data.
- [background_fetch](https://pub.dev/packages/background_fetch) is used to fetch data in the background while the app isn't in foreground.
- [logger & logger_flutter](https://pub.dev/packages/logger#-readme-tab-) Allow pretty logs, multiple levels of logging and adds an in app console when you shake the device

## Useful commands

- `adb shell cmd jobscheduler run -f com.covi.app 999` to trigger/test the background service.
