import 'package:flutter/material.dart';

import '../models/post.dart';

class AdminPostsProvider with ChangeNotifier {
  List<Post> _userPosts = [];
  List<Post> _newClubPosts = [];
  List<Post> get userPosts => _userPosts;
  List<Post> get clubPosts => _newClubPosts;
  void setUserPosts(List<Post> posts) => _userPosts = posts;
  void setClubPosts(List<Post> posts) => _newClubPosts = posts;
  void clearUserPosts() => _userPosts.clear();
  void clearClubPosts() => _newClubPosts.clear();
  final ScrollController _userScrollController = ScrollController();
  final ScrollController _clubScrollController = ScrollController();
  ScrollController get userScrollController => _userScrollController;
  ScrollController get clubScrollController => _clubScrollController;
  void disposeUserController() => _userScrollController.dispose();
  void disposeClubController() => _clubScrollController.dispose();
}
