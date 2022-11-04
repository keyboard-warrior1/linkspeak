import 'package:flutter/material.dart';

class LikeScreenScrollProvider extends ChangeNotifier {
  final ScrollController _likedUserScrollController = ScrollController();
  final ScrollController _likedClubScrollController = ScrollController();
  ScrollController get likedUserScrollController => _likedUserScrollController;
  ScrollController get likedClubScrollController => _likedClubScrollController;
  void disposeLikedUserController() => _likedUserScrollController.dispose();
  void disposeLikedClubController() => _likedClubScrollController.dispose();
}
