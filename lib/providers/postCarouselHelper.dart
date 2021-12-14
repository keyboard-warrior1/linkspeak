import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CarouselPhysHelp with ChangeNotifier {
  ScrollPhysics _alwaysPhysics = AlwaysScrollableScrollPhysics();
  ScrollPhysics _neverScroll = NeverScrollableScrollPhysics();
  int current = 0;
  bool carouselPlay = false;
  ScrollPhysics physics = AlwaysScrollableScrollPhysics();
  ScrollPhysics get getPhysics => _alwaysPhysics;
  ScrollPhysics get getNeverScroll => _neverScroll;

  void noScrolling() {
    _alwaysPhysics = NeverScrollableScrollPhysics();
    notifyListeners();
  }

  void canScroll() {
    _alwaysPhysics = AlwaysScrollableScrollPhysics();
    notifyListeners();
  }

  void disallowScroll() {
    physics = NeverScrollableScrollPhysics();
    notifyListeners();
  }

  void allowScroll() {
    physics = AlwaysScrollableScrollPhysics();
    notifyListeners();
  }

  Future<void> changeInd(int index) async {
    current = index;
    notifyListeners();
  }

  void playCarousel() {
    carouselPlay = !carouselPlay;
    notifyListeners();
  }

  void resetCarouselIndex() {
    current = 0;
    notifyListeners();
  }

  void pauseCarousel() {
    carouselPlay = false;
    notifyListeners();
  }

  void resetCarousel() {
    resetCarouselIndex();
    pauseCarousel();
  }
}
