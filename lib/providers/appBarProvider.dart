import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum View { normal, autoScroll }
enum Scroll { scrolling, paused }

class AppBarProvider with ChangeNotifier {
  View viewMode = View.normal;
  Scroll scrollMode = Scroll.paused;
  int speedFactor = 1;
  int selectedIndex = 0;
  bool showBar = true;

  void hideBar() {
    if (showBar) {
      showBar = false;
      notifyListeners();
    }
  }

  void showbar() {
    if (!showBar) {
      showBar = true;
      notifyListeners();
    }
  }

  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void changeView(View newView) {
    viewMode = newView;
    scrollMode = Scroll.paused;
    notifyListeners();
  }

  void changeScroll(Scroll newScroll) {
    scrollMode = newScroll;
    notifyListeners();
  }

  void increaseSpeed() {
    if (speedFactor <= 2) {
      speedFactor += 1;
    } else {}
    notifyListeners();
  }

  void decreaseSpeed() {
    if (speedFactor >= 2) {
      speedFactor -= 1;
    } else {}
    notifyListeners();
  }

  void reset() {
    viewMode = View.normal;
    scrollMode = Scroll.paused;
    speedFactor = 1;
    selectedIndex = 0;
    notifyListeners();
  }
}
