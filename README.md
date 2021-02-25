# K9-Team Covid App

Covi Canada has developed a COVID-19 mobile software application to help people change the course of the COVID-19 crisis as they go about their daily lives by providing information to navigate social distancing measures and better understand evolving personal and societal risk factors specific to each user’s context (the “Covi Code”). The Covi Code is comprised of a mobile application code (the "App Code") developed in collaboration with Libéo Inc. ("Libeo"), and of machine learning code (the "Simulator Code"). This effort is led by world-renowned AI researcher Yoshua Bengio at Mila - Institut québécois d'intelligence artificielle ("Mila") and rallies a coalition of researchers, developers and experts across Canada. 

MILA is making the Covi Code available to the public on a non-exclusive, royalty-free basis to enable other interested groups to reuse the work products they have created. The Simulator Code will be distributed under the terms of the Apache License, Version 2.0 (“Apache License”) whereas the App Code will be distributed under the GNU Affero General Public License, Version 3 (“AGPL License”). If copies of the Apache License or the AGPL License were not distributed with your software, you can obtain one at https://www.apache.org/licenses/LICENSE-2.0 or https://www.gnu.org/licenses/agpl-3.0.en.html, respectively.

The Apache License allows users of the software to use it for any purpose, to distribute it, to modify it, and to distribute modified versions thereof under the terms of the license on a royalty-free basis. One of its conditions is that users can’t remove existing copyright, patent, trademarks and attribution notices. As for the AGPL License, it is a free, copyleft license for software and other kinds of works, specifically designed to ensure cooperation with the community in the case of network server software. It is designed specifically to ensure that any modified source code derived from the relevant licensed portion of the Covi Code becomes available to the community. Any software that uses code under an AGPL License is itself subject to the same AGPL licensing terms. Furthermore, it requires the operator of a network server to provide the source code of the modified version running there to the users of that server. Therefore, public use of a modified version, on a publicly accessible server, gives the public access to the source code of the modified version.

You should note that the combination of code libraries under the Apache License and the AGPL Licence is permitted, with the resulting software being subject to the AGPL License.

Please note that in compliance with the Apache License and AGPL License and unless prohibited under applicable law: (i) Covi Canada is not making or offering any representation, warranty, guarantee or covenant with respect to the Covi Code and provides it to you "as is", without warranty of any kind, written or oral, express or implied, including any implied warranties of merchantability and fitness for a particular purpose or with respect to its condition, quality, conformity, availability, absence of defects, errors and inaccuracies (or their corrections); and (ii) the entire risk including as to the quality and performance of the Covi Code is with you; should the Covi Code or any portion thereof prove defective, you assume the cost of all necessary servicing, repair or correction; and (iii) modifying and adapting the Covi Code shall be at your own risk and any resulting derivative program or code shall be used at your discretion, in accordance with the Apache License and/or the AGPL License, as applicable, without any liability to Covi Canada whatsoever.

In addition, and unless prohibited under applicable law, the following additional disclaimer of warranty and limitation of liability is hereby incorporated into the terms and conditions of the Apache License and the AGPL License for the Covi Code:

1. No representations, covenants, guarantees and/or warranties of any kind whatsoever are made as to the results that you will obtain from relying upon the Covi Code (or any information or content obtained by way of the Covi Code), including but not limited to compliance with privacy laws or regulations or clinical care industry standards and protocols.

2. Even if the Covi Code and/or the content could be considered (and/or was obtained using) information about individuals’ health/medical condition, the Covi Code and content are not intended to provide medical advice, and accordingly such data shall not: (i) be used for self-diagnosis; (ii) constitute or be construed as an interpretation of any medical condition; (iii) be considered as giving prognostics, opinions, diagnosis or medical recommendations; or (iv) be considered as a substitute for professional advice. Any decision with regard to the appropriateness of treatment, or the validity or reliability of information or content made available by the Covi Code (or other interpretation of the content for medical or related purposes), shall be made by (or in consultation with) health care professionals. Consequently, it is incumbent upon each health care provider to verify all medical history and treatment plans with each patient.

3. Unless prohibited under applicable laws, under no circumstances and under no legal theory, whether tort (including negligence), contract, or otherwise, shall Covi Canada, any user, or anyone who distributes any software programs which incorporate in whole or in part the Covi Code as permitted by the license, be liable to you for any direct, indirect, special, incidental, consequential damages of any character including, without limitation, damages for loss of goodwill, work stoppage, computer failure or malfunction, or any and all other damages or losses, of any nature whatsoever (direct or otherwise) on account of or associated with the use or inability to use the covered content (including, without limitation, the use of information or content made available by the Covi Code, all documentation associated therewith; the foregoing applies as well to any compliance with privacy laws and regulations and/or clinical care industry standards and protocols), is incumbent upon you only even if Covi Canada (or other entity) have been informed of the possibility of such damages. Some jurisdictions do not allow the exclusion or limitation of liability for direct, consequential, incidental or other damages. In such jurisdiction, Covi Canada’s liability is limited to the greatest extent permitted by law, or to $100, whichever is less, unless the foregoing is prohibited in which case said limitation will be inapplicable in that case (but applicable and enforceable to the fullest extent legally permitted against any person and/or in any other circumstances).

4. You understand and agree: (i) that the access, use and other processes of the Covi Code and content shall only be made for lawful purposes (and in no event to attempt re-identifying any individual) and further to your own decision and initiative; (ii) that you are deemed to access, rely on, use and/or otherwise process the content at your own risks and based (a) on the abovementioned essential terms, which apply in addition to (and in case of inconsistencies shall have precedence over) any other terms of either the Apache License or AGPL License; and (b) on the fact that such access, reliance, use or other process and/or any dispute/proceeding are governed by the laws in force in the Province of Quebec excluding principles and rules that could lead to the application of foreign laws and subject to the exclusive jurisdictions of the courts of that Province; and (iv) that unless prohibited by laws of public order (in certain circumstances), Covi Canada assumes no responsibility whatsoever and shall not be responsible for any claim/damage including those arising/resulting from one of the occurrences referred to in these essential terms.

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
