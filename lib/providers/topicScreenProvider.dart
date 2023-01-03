import 'package:flutter/material.dart';

import '../models/post.dart';

class TopicScreenProvider with ChangeNotifier {
  String _topicName = '';
  List<Post> _posts = [];
  List<Post> _clubPosts = [];
  final ScrollController _scrollController = ScrollController();
  final ScrollController _clubScrollController = ScrollController();
  String get getTopicName => _topicName;
  List<Post> get posts => _posts;
  List<Post> get clubPosts => _clubPosts;
  ScrollController get getScrollController => _scrollController;
  ScrollController get getClubController => _clubScrollController;

  void setTopicName(String name) => _topicName = name;
  void setPosts(List<Post> posts) => _posts = posts;
  void setClubPosts(List<Post> posts) => _clubPosts = posts;

  void disposeScrollController() => _scrollController.dispose();
  void disposeClubController() => _clubScrollController.dispose();
  void clearPosts() => _posts.clear();
  void clearClubPosts() => _clubPosts.clear();
  void hidePost(String postID) {
    final thePost = _posts.firstWhere((element) => element.postID == postID);
    final index = _posts.indexOf(thePost);
    if (_posts.any((element) => element.postID == postID)) {
      _posts.removeWhere((post) => post.postID == postID);
      notifyListeners();
    }
    if (!_posts.any((element) => element.postID == postID)) {
      thePost.setter();
      _posts.insert(index, thePost);
      notifyListeners();
    }
  }

  void deletePost(String postID) {
    if (_posts.any((element) => element.postID == postID))
      _posts.removeWhere((post) => post.postID == postID);
    notifyListeners();
  }
}
