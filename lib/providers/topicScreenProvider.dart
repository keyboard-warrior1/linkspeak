import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import '../models/post.dart';

class TopicScreenProvider with ChangeNotifier {
  List<Post> _posts = [];

  List<Post> get posts => _posts;
  void clearPosts() {
    _posts.clear();
  }

  void setPosts(List<Post> posts) {
    _posts = posts;
  }

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
