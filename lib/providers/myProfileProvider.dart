import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/miniProfile.dart';
import '../models/profile.dart';
import '../models/post.dart';

class MyProfile with ChangeNotifier implements Profile {
  String _myProfileImageUrl = '';
  String _myusername = '';
  String _myemail = '';
  String _myname = '';
  String _mysurname = '';
  String _mybio = '';
  String _myActivity = '';
  bool _setupComplete = true;
  String _myStatus = '';
  int _myAge = 18;
  TheVisibility _myVisibilityStatus = TheVisibility.public;
  List<Post> _myposts = [];
  List<String> _myPostIDs = [];
  List<Post> _favoritePosts = [];
  List<String> _favPostIDs = [];
  List<Post> _postsLiked = [];
  List<String> _likedPostIDs = [];
  List<Post> _hiddenPosts = [];
  List<String> _hiddenPostIDs = [];
  List<Profile> _myBlockedUsers = [];
  List<String> _myBlockedUserIDs = [];
  List<Map<String, String>> _myPostLikesNotifs = [];
  List<Map<String, String>> _myPostCommentsNotifs = [];
  List<String> _myNewLinksNotifs = [];
  List<String> _myLinkRequestsNotifs = [];
  List<String> _myLinkedToNotifs = [];
  List<List<Map<String, String>>> _myCommentNotifs = [];
  List<Map<String, String>> _commentLikesNotifs = [];
  List<Map<String, String>> _commentRepliesNotifs = [];
  int _myNumOfLinks = 0;
  int _myNumOfLinked = 0;
  int _myNumOfPosts = 0;
  int _myNumOfBlocked = 0;
  int _myNumOfNewLinksNotifs = 0;
  int _myNumOfNewLinkedNotifs = 0;
  int _myNumOfLinkRequestNotifs = 0;
  int _myNumOfPostLikesNotifs = 0;
  int _myNumOfPostCommentsNotifs = 0;
  int _myNumOfCommentRepliesNotifs = 0;
  int _myNumOfCommentsRemovedNotifs = 0;
  int _myNumOfPostsRemovedNotifs = 0;
  List<String> _mytopics = [];
  List<Profile> _myLink = [];
  List<Profile> _myLinkTo = [];
  List<String> _myLinkIDs = [];

  List<MiniProfile> _mylinks = [];
  List<MiniProfile> _mylinkedTo = [];
  List<String> _myLinkedIDs = [];

  bool get getSetup => _setupComplete;
  @override
  String get getProfileImage => _myProfileImageUrl;
  @override
  String get getUsername => _myusername;
  @override
  String get getEmail => _myemail;
  @override
  String get getName => _myname;
  @override
  String get getSurname => _mysurname;
  @override
  String get getBio => _mybio;
  @override
  get getActivity => _myActivity;
  @override
  get getStatus => _myStatus;
  @override
  int get getAge => _myAge;
  @override
  TheVisibility get getVisibility => _myVisibilityStatus;
  @override
  List<Post> get getPosts => _myposts;
  @override
  List<String> get getPostIDs => _myPostIDs;
  List<Post> get getFavPosts => _favoritePosts;
  List<String> get getfavPostIDs => _favPostIDs;
  List<Post> get getLikedPosts => _postsLiked;
  List<String> get getLikedPostIDs => _likedPostIDs;
  List<Post> get getHiddenPosts => _hiddenPosts;
  List<String> get getHiddenPostIDs => _hiddenPostIDs;
  @override
  int get getNumberOfPosts => _myNumOfPosts;
  int get myNumOfBlocked => _myNumOfBlocked;
  int get myNumOfNewLinksNotifs => _myNumOfNewLinksNotifs;
  int get myNumOfNewLinkedNotifs => _myNumOfNewLinkedNotifs;
  int get myNumOfLinkRequestNotifs => _myNumOfLinkRequestNotifs;
  int get myNumOfPostLikesNotifs => _myNumOfPostLikesNotifs;
  int get myNumOfPostCommentsNotifs => _myNumOfPostCommentsNotifs;
  int get myNumOfCommentRepliesNotifs => _myNumOfCommentRepliesNotifs;
  int get myNumOfCommentsRemovedNotifs => _myNumOfCommentsRemovedNotifs;
  int get myNumOfPostsRemovedNotifs => _myNumOfPostsRemovedNotifs;
  @override
  int get getNumberOflinks => _myNumOfLinks;
  @override
  int get getNumberOfLinkedTos => _myNumOfLinked;
  void setMyNumOfLinks(int numOfLinks) {
    _myNumOfLinks = numOfLinks;
    notifyListeners();
  }

  void setMyNumOfLinked(int numOfLinked) {
    _myNumOfLinked = numOfLinked;
    notifyListeners();
  }

  void setNumOfPosts(int numOfPosts) {
    _myNumOfPosts = numOfPosts;
    notifyListeners();
  }

  void decreaseLinkRequests() {
    _myNumOfLinkRequestNotifs--;
    notifyListeners();
  }

  void setNumOfNewLinksNotifs(int newNum) {
    _myNumOfNewLinksNotifs = newNum;
  }

  void setNumOfNewLinkedNotifs(int newNum) {
    _myNumOfNewLinkedNotifs = newNum;
  }

  void setNumOfLinkRequestNotifs(int newNum) {
    _myNumOfLinkRequestNotifs = newNum;
  }

  void setNumOfPostLikesNotifs(int newNum) {
    _myNumOfPostLikesNotifs = newNum;
  }

  void setNumOfPostCommentsNotifs(int newNum) {
    _myNumOfPostCommentsNotifs = newNum;
  }

  void setNumOfCommentRepliesNotifs(int newNum) {
    _myNumOfCommentRepliesNotifs = newNum;
  }

  void setNumOfCommentsRemovedNotifs(int newNum) {
    _myNumOfCommentsRemovedNotifs = newNum;
  }

  void setmyNumOfPostsRemovedNotifs(int newNum) {
    _myNumOfPostsRemovedNotifs = newNum;
  }

  void zero() {
    setNumOfNewLinksNotifs(0);
    setNumOfNewLinkedNotifs(0);
    setNumOfLinkRequestNotifs(0);
    setNumOfPostLikesNotifs(0);
    setNumOfPostCommentsNotifs(0);
    setNumOfCommentRepliesNotifs(0);
    notifyListeners();
  }

  void setNumOfBlocked(int newNum) {
    _myNumOfBlocked = newNum;
  }

  @override
  List<String> get getTopics => _mytopics;

  @override
  List<Profile> get getlinks => _myLink;

  @override
  List<String> get getLinkIDs => _myLinkIDs;

  @override
  List<Profile> get getLinkedTos => _myLinkTo;
  List<MiniProfile> get getMylinks => _mylinks;
  List<MiniProfile> get getMyLinkedTos => _mylinkedTo;

  @override
  List<String> get getLinkedIDs => _myLinkedIDs;

  @override
  List<Profile> get getBlockedUsers => _myBlockedUsers;
  @override
  List<String> get getBlockedIDs => _myBlockedUserIDs;
  @override
  List<Map<String, String>> get getpostLikesNotifs => _myPostLikesNotifs;
  List<Map<String, String>> get getPostCommentsNotifs => _myPostCommentsNotifs;
  List<Map<String, String>> get getCommentLikesNotifs => _commentLikesNotifs;
  List<Map<String, String>> get getCommentRepliesNotifs =>
      _commentRepliesNotifs;
  @override
  List<String> get getnewLinksNotifs => _myNewLinksNotifs;
  @override
  List<String> get getlinkRequestNotifs => _myLinkRequestsNotifs;
  @override
  List<String> get getlinkedToNotifs => _myLinkedToNotifs;
  @override
  List<List<Map<String, String>>> get getcommentNotifs => _myCommentNotifs;
  @override
  int get getcommentRemovedNotifs => _myNumOfCommentsRemovedNotifs;
  @override
  int get getpostsRemovedNotifs => _myNumOfPostsRemovedNotifs;
  @override
  set setpostLikesNotifs(List<Map<String, String>> postLikesNotifs) {
    _myPostLikesNotifs = postLikesNotifs;
  }

  set setPostCommentsNotifs(List<Map<String, String>> postCommentNotifs) =>
      _myPostCommentsNotifs = postCommentNotifs;
  set setCommentLikesNotifs(List<Map<String, String>> commentLikesNotifs) =>
      _commentLikesNotifs = commentLikesNotifs;
  set setCommentRepliesNotifs(List<Map<String, String>> commentRepliesNotifs) =>
      _commentRepliesNotifs = commentRepliesNotifs;

  @override
  set setnewLinksNotifs(List<String> newLinksNotifs) {
    _myNewLinksNotifs = newLinksNotifs;
  }

  @override
  set setlinkRequestNotifs(List<String> linkRequestNotifs) {
    _myLinkRequestsNotifs = linkRequestNotifs;
  }

  @override
  set setlinkedToNotifs(List<String> linkedToNotifs) {
    _myLinkedToNotifs = linkedToNotifs;
  }

  @override
  set setcommentNotifs(List<List<Map<String, String>>> commentNotifs) {
    _myCommentNotifs = commentNotifs;
  }

  @override
  set setcommentRemovedNotifs(int commentsRemoved) {
    _myNumOfCommentsRemovedNotifs = commentsRemoved;
  }

  @override
  set setpostsRemovedNotifs(int postsRemoved) {
    _myNumOfPostsRemovedNotifs = postsRemoved;
  }

  set setSetup(bool setup) {
    _setupComplete = setup;
  }

  @override
  set setProfileImage(String imgUrl) {
    _myProfileImageUrl = imgUrl;
  }

  void setMyProfileImage(String url) {
    _myProfileImageUrl = url;
    notifyListeners();
  }

  @override
  set setUsername(String username) {
    _myusername = username;
  }

  void setMyUsername(String username) {
    _myusername = username;
    notifyListeners();
  }

  @override
  set setEmail(String email) {
    _myemail = email;
  }

  void setMyEmail(String email) {
    _myemail = email;
    notifyListeners();
  }

  @override
  set setName(String name) {
    _myname = name;
  }

  @override
  set setSurname(String surname) {
    _mysurname = surname;
  }

  @override
  set setAge(int age) {
    _myAge = age;
  }

  @override
  set setBio(String bio) {
    _mybio = bio;
  }

  @override
  set setActivity(String activity) {
    _myActivity = activity;
  }

  @override
  set setStatus(String status) {
    _myStatus = status;
  }

  @override
  set setPostIDs(List<String> postIds) {
    _myPostIDs = postIds;
  }

  void setMyPostIDs(List<String> ids) {
    _myPostIDs = ids;
  }

  @override
  set setPosts(List<Post> posts) {
    _myposts = posts;
  }

  void setMyPosts(List<Post> posts) {
    _myposts = posts;
  }

  set setFavPostIDs(List<String> favpostIds) {
    _favPostIDs = favpostIds;
  }

  set setFavPosts(List<Post> favPosts) {
    _favoritePosts = favPosts;
  }

  void setFavPostas(List<Post> favPosts) {
    _favoritePosts = favPosts;
  }

  void addFavPostas(List<Post> favPosts) {
    _favoritePosts.addAll(favPosts);
  }

  void removeFavID(String id) {
    _favoritePosts.remove(id);
  }

  set setLikedPostIDs(List<String> likedPostIds) {
    _likedPostIDs = likedPostIds;
  }

  set setLikedPosts(List<Post> likedPosts) {
    _postsLiked = likedPosts;
  }

  void setLikedPostas(List<Post> likedPosts) {
    _postsLiked = likedPosts;
  }

  set setHiddenPostIds(List<String> hiddenPostIds) {
    _hiddenPostIDs = hiddenPostIds;
  }

  void setHiddenIDs(List<String> hiddenIDs) {
    _hiddenPostIDs = hiddenIDs;
    notifyListeners();
  }

  void setFavIDs(List<String> favIDs) {
    _favPostIDs = favIDs;
    notifyListeners();
  }

  void setLikedIDs(List<String> likedIDs) {
    _likedPostIDs = likedIDs;
    notifyListeners();
  }

  set setHiddenPosts(List<Post> hiddenPosts) {
    _hiddenPosts = hiddenPosts;
  }

  @override
  set setlinkIDs(List<String> linkIds) {
    _myLinkIDs = linkIds;
  }

  void setMyLinkIDs(List<String> linkIds) {
    _myLinkIDs = linkIds;
    notifyListeners();
  }

  @override
  set setLinks(List<Profile> links) {
    _myLink = links;
  }

  void setMyLinks(List<MiniProfile> links) {
    _mylinks = links;
  }

  @override
  set setLinkedIDs(List<String> linkedIds) {
    _myLinkedIDs = linkedIds;
  }

  void setMyLinkedIDs(List<String> linkedIds) {
    _myLinkedIDs = linkedIds;
    notifyListeners();
  }

  @override
  set setLinkedTos(List<Profile> linkedTos) {
    _myLinkTo = linkedTos;
  }

  void setMyLinkedTos(List<MiniProfile> linkedTos) {
    _mylinkedTo = linkedTos;
  }

  @override
  set setBlockedIDs(List<String> blockedIds) {
    _myBlockedUserIDs = blockedIds;
  }

  void setBlockedUserIDs(List<String> blocked) {
    _myBlockedUserIDs = blocked;
  }

  @override
  set setBlockedUsers(List<Profile> blockedUsers) {
    _myBlockedUsers = blockedUsers;
  }

  @override
  set setTopics(List<String> topics) {
    _mytopics = topics;
  }

  void blockUser(String blockedUserID) {
    if (!_myBlockedUserIDs.contains(blockedUserID)) {
      _myBlockedUserIDs.insert(0, blockedUserID);
      _myNumOfBlocked++;
      notifyListeners();
    }
  }

  void unblockUser(String unblockedUserID) {
    if (_myBlockedUserIDs.contains(unblockedUserID)) {
      _myBlockedUserIDs.remove(unblockedUserID);
      _myNumOfBlocked--;
      notifyListeners();
    }
  }

  void addPost(String postId) {
    _myPostIDs.insert(0, postId);
    _myNumOfPosts++;
    notifyListeners();
  }

  void likePost(String postID) {
    if (_likedPostIDs.contains(postID)) {
      _likedPostIDs.remove(postID);
    } else {
      _likedPostIDs.insert(0, postID);
    }
    notifyListeners();
  }

  void deletePost(String postID) {
    _myposts.removeWhere((post) => post.postID == postID);
    _postsLiked.removeWhere((post) => post.postID == postID);
    _favoritePosts.removeWhere((post) => post.postID == postID);
    _myPostIDs.remove(postID);
    _likedPostIDs.remove(postID);
    _favPostIDs.remove(postID);
    _myNumOfPosts--;
    notifyListeners();
  }

  void favPost(String postID) {
    if (!_favPostIDs.contains(postID)) _favPostIDs.insert(0, postID);
    notifyListeners();
  }

  void removeFavPost(String postID) {
    _favPostIDs.remove(postID);
    notifyListeners();
  }

  void hidePost(String postID) {
    _hiddenPostIDs.insert(0, postID);
    if (_favoritePosts.any((post) => post.postID == postID)) {
      final theFavPost =
          _favoritePosts.firstWhere((element) => element.postID == postID);
      final favIndex = _favoritePosts.indexOf(theFavPost);
      _favoritePosts.removeWhere((post) => post.postID == postID);
      if (!_favoritePosts.any((post) => post.postID == postID)) {
        _favoritePosts.insert(favIndex, theFavPost);
      }
    }
    if (_postsLiked.any((post) => post.postID == postID)) {
      final theLikedPost =
          _postsLiked.firstWhere((element) => element.postID == postID);
      final likedIndex = _postsLiked.indexOf(theLikedPost);
      _postsLiked.removeWhere((post) => post.postID == postID);
      if (!_postsLiked.any((post) => post.postID == postID)) {
        _postsLiked.insert(likedIndex, theLikedPost);
      }
    }
    notifyListeners();
  }

  void unhidePost(String postID) {
    _hiddenPostIDs.remove(postID);
    notifyListeners();
  }

  void changeBio(String newBio) {
    _mybio = newBio;
    notifyListeners();
  }

  void changeTopics(List<String> newNames) {
    _mytopics = newNames;
    notifyListeners();
  }

  void setMyTopics(List<String> topics) {
    _mytopics = topics;
    notifyListeners();
  }

  dynamic setMyVisibilityStatus(TheVisibility vis) {
    _myVisibilityStatus = vis;
    notifyListeners();
  }

  void setMyVis(String vis) {
    if (vis == 'Public') {
      _myVisibilityStatus = TheVisibility.public;
    } else if (vis == 'Private') {
      _myVisibilityStatus = TheVisibility.private;
    }

    notifyListeners();
  }

  void removeTopic(int index) {
    getTopics.removeAt(index);
    notifyListeners();
  }

  void addTopic(String name) {
    getTopics.insert(0, name);
    notifyListeners();
  }

  void addLinks() {
    _myNumOfLinks++;
    notifyListeners();
  }

  void subtractMyLinks() {
    _myNumOfLinks--;
    notifyListeners();
  }

  void addLinked() {
    _myNumOfLinked++;
    notifyListeners();
  }

  void subtractLinked() {
    _myNumOfLinked--;
    notifyListeners();
  }

  void resetProfile() {
    _myProfileImageUrl = '';
    _myusername = '';
    _myemail = '';
    _myname = '';
    _mysurname = '';
    _mybio = '';
    _myActivity = '';
    _setupComplete = true;
    _myStatus = '';
    _myAge = 18;
    _myVisibilityStatus = TheVisibility.public;
    _myposts = [];
    _myPostIDs = [];
    _favoritePosts = [];
    _favPostIDs = [];
    _postsLiked = [];
    _likedPostIDs = [];
    _hiddenPosts = [];
    _hiddenPostIDs = [];
    _myBlockedUsers = [];
    _myBlockedUserIDs = [];
    _myPostLikesNotifs = [];
    _myPostCommentsNotifs = [];
    _myNewLinksNotifs = [];
    _myLinkRequestsNotifs = [];
    _myLinkedToNotifs = [];
    _myCommentNotifs = [];
    _commentLikesNotifs = [];
    _commentRepliesNotifs = [];
    _myNumOfLinks = 0;
    _myNumOfLinked = 0;
    _myNumOfPosts = 0;
    _myNumOfBlocked = 0;
    _myNumOfNewLinksNotifs = 0;
    _myNumOfNewLinkedNotifs = 0;
    _myNumOfLinkRequestNotifs = 0;
    _myNumOfPostLikesNotifs = 0;
    _myNumOfPostCommentsNotifs = 0;
    _myNumOfCommentRepliesNotifs = 0;
    _myNumOfCommentsRemovedNotifs = 0;
    _myNumOfPostsRemovedNotifs = 0;
    _mytopics = [];
    _myLink = [];
    _myLinkTo = [];
    _myLinkIDs = [];

    _mylinks = [];
    _mylinkedTo = [];
    _myLinkedIDs = [];
  }
}
