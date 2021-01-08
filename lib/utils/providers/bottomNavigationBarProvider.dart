import 'package:flutter/widgets.dart';

enum HomeScreens { dashboard, health, advices, resources }

class BottomNavigationBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToScreen(HomeScreens screen) {
    switch (screen) {
      case HomeScreens.dashboard:
        this.currentIndex = 0;
        break;
      case HomeScreens.health:
        this.currentIndex = 1;
        break;
      case HomeScreens.advices:
        this.currentIndex = 2;
        break;
      case HomeScreens.resources:
        this.currentIndex = 3;
        break;
      default:
        this.currentIndex = 0;
    }
  }
}
