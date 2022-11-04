import 'package:flutter/material.dart';

import '../models/post.dart';

class PlacesScreenProvider with ChangeNotifier {
  String _locationName = '';
  dynamic _location = '';
  bool _showMap = true;
  List<Post> _posts = [];
  List<Post> _clubPosts = [];
  final ScrollController _scrollController = ScrollController();
  final ScrollController _clubScrollController = ScrollController();
  String get placeName => _locationName;
  dynamic get place => _location;
  bool get showMap => _showMap;
  List<Post> get posts => _posts;
  List<Post> get clubPosts => _clubPosts;
  ScrollController get getScrollController => _scrollController;
  ScrollController get getClubController => _clubScrollController;

  void setLocationName(String loocationName) => _locationName = loocationName;
  void setLocation(dynamic thislocation) => _location = thislocation;
  void setPosts(List<Post> posts) => _posts = posts;
  void setClubPosts(List<Post> posts) => _clubPosts = posts;
  void clearPosts() => _posts.clear();
  void clearClubPosts() => _clubPosts.clear();
  void disposeScrollController() => _scrollController.dispose();
  void disposeClubController() => _clubScrollController.dispose();

  // void mapHandler(bool newHide) {
  //   if (_showMap != newHide) {
  //     _showMap = newHide;
  //     notifyListeners();
  //   }
  // }
}
