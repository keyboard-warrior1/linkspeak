import 'package:flutter/material.dart';

class FavScreenScrollProvider extends ChangeNotifier {
  final ScrollController _favUserScrollController = ScrollController();
  final ScrollController _favClubScrollController = ScrollController();
  ScrollController get favUserScrollController => _favUserScrollController;
  ScrollController get favClubScrollController => _favClubScrollController;
  void disposeFavUserController() => _favUserScrollController.dispose();
  void disposeFavClubController() => _favClubScrollController.dispose();
}
