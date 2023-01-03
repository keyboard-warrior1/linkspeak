import 'package:flutter/material.dart';

class ProfileScrollProvider with ChangeNotifier {
  final ScrollController _postsScrollController = ScrollController();
  final ScrollController _profileScrollController = ScrollController();
  ScrollController get postsScrollController => _postsScrollController;
  ScrollController get profileScrollController => _profileScrollController;
  void disposeScrollController() => _postsScrollController.dispose();
  void disposeProfileScrollController() => _profileScrollController.dispose();
}
