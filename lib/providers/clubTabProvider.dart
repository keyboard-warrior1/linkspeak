import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/posterProfile.dart';
import '../providers/fullPostHelper.dart';

class ClubTabProvider with ChangeNotifier {
  List<Post> _posts = [];
  List<Post> get posts => _posts;
  void setPosts(List<Post> posts) => _posts = posts;
  void clearPosts() => _posts.clear();
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

  void addPost(
      {required FullHelper instance,
      required String myUsername,
      required String description,
      required List<String> images,
      required List<String> topics,
      required DateTime postedDate,
      required String postId,
      required bool sensitiveContent,
      required PosterProfile myPosterProfile,
      required dynamic location,
      required String locationName}) {
    final Post _newPost = Post(
        key: UniqueKey(),
        instance: instance,
        postID: postId,
        poster: myPosterProfile,
        clubName: '',
        isClubPost: false,
        description: description,
        isLiked: false,
        isFav: false,
        commentsDisabled: false,
        isHidden: false,
        imgUrls: images,
        topics: topics,
        postedDate: postedDate,
        sensitiveContent: sensitiveContent,
        numOfLikes: 0,
        numOfComments: 0,
        numOfTopics: topics.length,
        location: location,
        locationName: locationName,
        isMod: false,
        postType: PostType.legacy,
        items: [],
        backgroundColor: Colors.blue,
        gradientColor: Colors.yellow);
    _newPost.setter();
    _posts.insert(0, _newPost);
    notifyListeners();
  }
}
