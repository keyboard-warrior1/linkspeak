import 'package:flutter/material.dart';

class CarouselPhysHelp with ChangeNotifier {
  int current = 0;
  bool carouselPlay = false;
  ScrollPhysics _alwaysPhysics = const AlwaysScrollableScrollPhysics();
  ScrollPhysics _neverScroll = const NeverScrollableScrollPhysics();
  ScrollPhysics physics = const AlwaysScrollableScrollPhysics();
  ScrollPhysics get getPhysics => _alwaysPhysics;
  ScrollPhysics get getNeverScroll => _neverScroll;

  void noScrolling() {
    _alwaysPhysics = const NeverScrollableScrollPhysics();
    notifyListeners();
  }

  void canScroll() {
    _alwaysPhysics = const AlwaysScrollableScrollPhysics();
    notifyListeners();
  }

  void disallowScroll() {
    physics = const NeverScrollableScrollPhysics();
    notifyListeners();
  }

  void allowScroll() {
    physics = const AlwaysScrollableScrollPhysics();
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
