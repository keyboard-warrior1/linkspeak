import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/flareCollectionModel.dart';
import '../models/miniClub.dart';
import '../models/miniProfile.dart';
import '../models/post.dart';
import '../models/profile.dart';

class MyProfile with ChangeNotifier implements Profile {
  String _additionalWebsite = '';
  String _additionalEmail = '';
  String _additionalNumber = '';
  dynamic _additionalAddress = '';
  String _additionalAddressName = '';
  String _myProfileImageUrl = '';
  String _myProfileBanner = '';
  String _myusername = '';
  String _myemail = '';
  String _myname = '';
  String _mysurname = '';
  String _mybio = '';
  String _myActivity = '';
  String _myStatus = '';
  int _myAge = 18;
  int _myNumOfLinks = 0;
  int _joinedClubs = 0;
  int _myNumOfLinked = 0;
  int _myNumOfPosts = 0;
  int _myNumOfBlocked = 0;
  int _myNumOfMentions = 0;
  int _myNumOfNewLinksNotifs = 0;
  int _myNumOfNewLinkedNotifs = 0;
  int _myNumOfLinkRequestNotifs = 0;
  int _myNumOfPostLikesNotifs = 0;
  int _myNumOfPostCommentsNotifs = 0;
  int _myNumOfCommentRepliesNotifs = 0;
  int _myNumOfCommentsRemovedNotifs = 0;
  int _myNumOfPostsRemovedNotifs = 0;
  int _myNumOfRepliesRemovedNotifs = 0;
  bool _bannerNSFW = false;
  bool _setupComplete = true;
  bool _hasSpotlight = false;
  List<String> _myPostIDs = [];
  List<String> _favPostIDs = [];
  List<String> _likedPostIDs = [];
  List<String> _hiddenPostIDs = [];
  List<String> _myBlockedUserIDs = [];
  List<String> _myLinkedIDs = [];
  List<String> _myNewLinksNotifs = [];
  List<String> _myLinkRequestsNotifs = [];
  List<String> _myLinkedToNotifs = [];
  List<String> _mytopics = [];
  List<String> _myLinkIDs = [];
  List<Post> _postsLiked = [];
  List<Post> _likedClubPosts = [];
  List<Post> _myposts = [];
  List<Post> _favoritePosts = [];
  List<Post> _favoriteClubPosts = [];
  List<Post> _hiddenPosts = [];
  List<Map<String, String>> _myPostLikesNotifs = [];
  List<Map<String, String>> _myPostCommentsNotifs = [];
  List<Map<String, String>> _commentLikesNotifs = [];
  List<Map<String, String>> _commentRepliesNotifs = [];
  List<Profile> _myBlockedUsers = [];
  List<Profile> _myLink = [];
  List<Profile> _myLinkTo = [];
  List<MiniProfile> _mylinks = [];
  List<MiniProfile> _mylinkedTo = [];
  List<FlareCollectionModel> _flaresLiked = [];
  List<FlareCollectionModel> _flareHistory = [];
  List<MiniClub> _myClubs = [];
  List<List<Map<String, String>>> _myCommentNotifs = [];
  TheVisibility _myVisibilityStatus = TheVisibility.public;

  int get myNumOfBlocked => _myNumOfBlocked;
  int get myNumOfNewLinksNotifs => _myNumOfNewLinksNotifs;
  int get myNumOfMentions => _myNumOfMentions;
  int get myNumOfNewLinkedNotifs => _myNumOfNewLinkedNotifs;
  int get myNumOfLinkRequestNotifs => _myNumOfLinkRequestNotifs;
  int get myNumOfPostLikesNotifs => _myNumOfPostLikesNotifs;
  int get myNumOfPostCommentsNotifs => _myNumOfPostCommentsNotifs;
  int get myNumOfCommentRepliesNotifs => _myNumOfCommentRepliesNotifs;
  int get myNumOfCommentsRemovedNotifs => _myNumOfCommentsRemovedNotifs;
  int get myNumOfPostsRemovedNotifs => _myNumOfPostsRemovedNotifs;
  int get myNumOfRepliesRemovedNotifs => _myNumOfRepliesRemovedNotifs;
  int get joinedClubs => _joinedClubs;
  bool get getSetup => _setupComplete;
  bool get getBannerNSFW => _bannerNSFW;
  List<String> get getHiddenPostIDs => _hiddenPostIDs;
  List<String> get getfavPostIDs => _favPostIDs;
  List<String> get getLikedPostIDs => _likedPostIDs;
  List<Post> get getFavPosts => _favoritePosts;
  List<Post> get getFavClubPosts => _favoriteClubPosts;
  List<Post> get getLikedClubPosts => _likedClubPosts;
  List<Post> get getLikedPosts => _postsLiked;
  List<FlareCollectionModel> get getLikedFlares => _flaresLiked;
  List<FlareCollectionModel> get getFlareHistory => _flareHistory;
  List<MiniProfile> get getMylinks => _mylinks;
  List<MiniProfile> get getMyLinkedTos => _mylinkedTo;
  List<Map<String, String>> get getPostCommentsNotifs => _myPostCommentsNotifs;
  List<Map<String, String>> get getCommentLikesNotifs => _commentLikesNotifs;
  List<Map<String, String>> get getCommentRepliesNotifs =>
      _commentRepliesNotifs;
  List<MiniClub> get getMyClubs => _myClubs;
  List<Post> get getHiddenPosts => _hiddenPosts;

  @override
  TheVisibility get getVisibility => _myVisibilityStatus;
  @override
  bool get getHasSpotlight => _hasSpotlight;
  @override
  String get getProfileImage => _myProfileImageUrl;
  @override
  String get getProfileBanner => _myProfileBanner;
  @override
  String get getAdditionalWebsite => _additionalWebsite;
  @override
  String get getAdditionalEmail => _additionalEmail;
  @override
  String get getAdditionalNumber => _additionalNumber;
  @override
  dynamic get getAdditionalAddress => _additionalAddress;
  @override
  String get getAdditionalAddressName => _additionalAddressName;
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
  int get getNumberOfPosts => _myNumOfPosts;
  @override
  int get getNumberOflinks => _myNumOfLinks;
  @override
  int get getNumberOfLinkedTos => _myNumOfLinked;
  @override
  int get getcommentRemovedNotifs => _myNumOfCommentsRemovedNotifs;
  @override
  int get getpostsRemovedNotifs => _myNumOfPostsRemovedNotifs;
  @override
  List<Post> get getPosts => _myposts;
  @override
  List<String> get getPostIDs => _myPostIDs;
  @override
  List<String> get getTopics => _mytopics;
  @override
  List<Profile> get getlinks => _myLink;
  @override
  List<String> get getLinkIDs => _myLinkIDs;
  @override
  List<Profile> get getLinkedTos => _myLinkTo;
  @override
  List<String> get getLinkedIDs => _myLinkedIDs;
  @override
  List<Profile> get getBlockedUsers => _myBlockedUsers;
  @override
  List<String> get getBlockedIDs => _myBlockedUserIDs;
  @override
  List<Map<String, String>> get getpostLikesNotifs => _myPostLikesNotifs;
  @override
  List<String> get getnewLinksNotifs => _myNewLinksNotifs;
  @override
  List<String> get getlinkRequestNotifs => _myLinkRequestsNotifs;
  @override
  List<String> get getlinkedToNotifs => _myLinkedToNotifs;
  @override
  List<List<Map<String, String>>> get getcommentNotifs => _myCommentNotifs;

  @override
  set setlinkIDs(List<String> linkIds) => _myLinkIDs = linkIds;
  @override
  set setLinks(List<Profile> links) => _myLink = links;
  @override
  set setLinkedIDs(List<String> linkedIds) => _myLinkedIDs = linkedIds;
  @override
  set setLinkedTos(List<Profile> linkedTos) => _myLinkTo = linkedTos;
  @override
  set setBlockedIDs(List<String> blockedIds) => _myBlockedUserIDs = blockedIds;
  @override
  set setBlockedUsers(List<Profile> blockedUsers) =>
      _myBlockedUsers = blockedUsers;
  @override
  set setTopics(List<String> topics) => _mytopics = topics;
  @override
  set setpostLikesNotifs(List<Map<String, String>> postLikesNotifs) =>
      _myPostLikesNotifs = postLikesNotifs;
  @override
  set setnewLinksNotifs(List<String> newLinksNotifs) =>
      _myNewLinksNotifs = newLinksNotifs;
  @override
  set setlinkRequestNotifs(List<String> linkRequestNotifs) =>
      _myLinkRequestsNotifs = linkRequestNotifs;
  @override
  set setlinkedToNotifs(List<String> linkedToNotifs) =>
      _myLinkedToNotifs = linkedToNotifs;
  @override
  set setcommentNotifs(List<List<Map<String, String>>> commentNotifs) =>
      _myCommentNotifs = commentNotifs;
  @override
  set setcommentRemovedNotifs(int commentsRemoved) =>
      _myNumOfCommentsRemovedNotifs = commentsRemoved;
  @override
  set setpostsRemovedNotifs(int postsRemoved) =>
      _myNumOfPostsRemovedNotifs = postsRemoved;
  @override
  set setProfileImage(String imgUrl) => _myProfileImageUrl = imgUrl;
  @override
  set setHasSpotlight(bool hasSpotlight) => _hasSpotlight = hasSpotlight;
  @override
  set setProfileBanner(String bannerUrl) => _myProfileBanner = bannerUrl;
  @override
  set setAdditionalWebsite(String website) => _additionalWebsite = website;
  @override
  set setAdditionalEmail(String email) => _additionalEmail = email;
  @override
  set setAdditionalNumber(String number) => _additionalNumber = number;
  @override
  set setAdditionalAddress(dynamic address) => _additionalAddress = address;
  @override
  set setAdditionalAddressName(String name) => _additionalAddressName = name;
  @override
  set setUsername(String username) => _myusername = username;
  @override
  set setEmail(String email) => _myemail = email;
  @override
  set setName(String name) => _myname = name;
  @override
  set setSurname(String surname) => _mysurname = surname;
  @override
  set setAge(int age) => _myAge = age;
  @override
  set setBio(String bio) => _mybio = bio;
  @override
  set setActivity(String activity) => _myActivity = activity;
  @override
  set setStatus(String status) => _myStatus = status;
  @override
  set setPostIDs(List<String> postIds) => _myPostIDs = postIds;
  @override
  set setPosts(List<Post> posts) => _myposts = posts;
  set setSetup(bool setup) => _setupComplete = setup;
  set setPostCommentsNotifs(List<Map<String, String>> postCommentNotifs) =>
      _myPostCommentsNotifs = postCommentNotifs;
  set setCommentLikesNotifs(List<Map<String, String>> commentLikesNotifs) =>
      _commentLikesNotifs = commentLikesNotifs;
  set setCommentRepliesNotifs(List<Map<String, String>> commentRepliesNotifs) =>
      _commentRepliesNotifs = commentRepliesNotifs;
  set setFavPostIDs(List<String> favpostIds) => _favPostIDs = favpostIds;
  set setFavPosts(List<Post> favPosts) => _favoritePosts = favPosts;
  set setLikedPostIDs(List<String> likedPostIds) =>
      _likedPostIDs = likedPostIds;
  set setLikedPosts(List<Post> likedPosts) => _postsLiked = likedPosts;
  set setHiddenPostIds(List<String> hiddenPostIds) =>
      _hiddenPostIDs = hiddenPostIds;
  set setHiddenPosts(List<Post> hiddenPosts) => _hiddenPosts = hiddenPosts;
  void setNumOfNewLinksNotifs(int newNum) => _myNumOfNewLinksNotifs = newNum;
  void setNumOfNewMentions(int newNum) => _myNumOfMentions = newNum;
  void setNumOfNewLinkedNotifs(int newNum) => _myNumOfNewLinkedNotifs = newNum;
  void setNumOfLinkRequestNotifs(int newNum) =>
      _myNumOfLinkRequestNotifs = newNum;
  void setNumOfPostLikesNotifs(int newNum) => _myNumOfPostLikesNotifs = newNum;
  void setNumOfPostCommentsNotifs(int newNum) =>
      _myNumOfPostCommentsNotifs = newNum;
  void setNumOfCommentRepliesNotifs(int newNum) =>
      _myNumOfCommentRepliesNotifs = newNum;
  void setNumOfCommentsRemovedNotifs(int newNum) =>
      _myNumOfCommentsRemovedNotifs = newNum;
  void setmyNumOfPostsRemovedNotifs(int newNum) =>
      _myNumOfPostsRemovedNotifs = newNum;
  void setMyNumOfRepliessRemovedNotifs(int newNum) =>
      _myNumOfRepliesRemovedNotifs = newNum;
  void setNumOfBlocked(int newNum) => _myNumOfBlocked = newNum;
  void setMySpotlight(bool hasSpotlight) => _hasSpotlight = hasSpotlight;
  void setMyPostIDs(List<String> ids) => _myPostIDs = ids;
  void setMyPosts(List<Post> posts) => _myposts = posts;
  void setFavPostas(List<Post> favPosts) => _favoritePosts = favPosts;
  void setFavClubPosts(List<Post> favClubPosts) =>
      _favoriteClubPosts = favClubPosts;
  void setLikedClubPosts(List<Post> likedClubPosts) =>
      _likedClubPosts = likedClubPosts;
  void addFavPostas(List<Post> favPosts) => _favoritePosts.addAll(favPosts);
  void removeFavID(String id) => _favoritePosts.remove(id);
  void setLikedPostas(List<Post> likedPosts) => _postsLiked = likedPosts;
  void setLikedFlares(List<FlareCollectionModel> _likes) =>
      _flaresLiked = _likes;
  void setFlareHistory(List<FlareCollectionModel> _history) =>
      _flareHistory = _history;
  void setMyLinks(List<MiniProfile> links) => _mylinks = links;
  void setMyClubs(List<MiniClub> clubs) => _myClubs = clubs;
  void setMyLinkedTos(List<MiniProfile> linkedTos) => _mylinkedTo = linkedTos;
  void setBlockedUserIDs(List<String> blocked) => _myBlockedUserIDs = blocked;
  void clearFavPosts() => _favoritePosts.clear();
  void clearFavClubPosts() => _favoriteClubPosts.clear();
  void clearLikedPosts() => _postsLiked.clear();
  void clearLikedFlares() => _flaresLiked.clear();
  void clearFlareHistory() => _flareHistory.clear();
  void clearLikedClubPosts() => _likedClubPosts.clear();

  void setMyNumOfLinks(int numOfLinks) {
    _myNumOfLinks = numOfLinks;
    notifyListeners();
  }

  void setJoinedClubs(int joinedClubs) {
    _joinedClubs = joinedClubs;
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

  void setMyProfileImage(String url) {
    _myProfileImageUrl = url;
    notifyListeners();
  }

  void setMyProfileBanner(String url, bool nsfw) {
    _myProfileBanner = url;
    _bannerNSFW = nsfw;
    notifyListeners();
  }

  void setMyAdditionalWebsite(String website) {
    _additionalWebsite = website;
    notifyListeners();
  }

  void setMyAdditionalEmail(String email) {
    _additionalEmail = email;
    notifyListeners();
  }

  void setMyAdditionalNumber(String number) {
    _additionalNumber = number;
    notifyListeners();
  }

  void setMyAdditionalAddress(dynamic address) {
    _additionalAddress = address;
    notifyListeners();
  }

  void setMyAdditionalAddressName(String name) {
    _additionalAddressName = name;
    notifyListeners();
  }

  void setMyUsername(String username) {
    _myusername = username;
    notifyListeners();
  }

  void setMyEmail(String email) {
    _myemail = email;
    notifyListeners();
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

  void setMyLinkIDs(List<String> linkIds) {
    _myLinkIDs = linkIds;
    notifyListeners();
  }

  void setMyLinkedIDs(List<String> linkedIds) {
    _myLinkedIDs = linkedIds;
    notifyListeners();
  }

  void unhidePost(String postID) {
    // _hiddenPostIDs.remove(postID);
    // notifyListeners();
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

  void addClubs() {
    _joinedClubs++;
    notifyListeners();
  }

  void subtractMyLinks() {
    _myNumOfLinks--;
    notifyListeners();
  }

  void subtractClubs() {
    _joinedClubs--;
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

  void blockUser(String blockedUserID) {
    // if (!_myBlockedUserIDs.contains(blockedUserID)) {
    // _myBlockedUserIDs.insert(0, blockedUserID);
    _myNumOfBlocked++;
    notifyListeners();
    // }
  }

  void unblockUser(String unblockedUserID) {
    // if (_myBlockedUserIDs.contains(unblockedUserID)) {
    // _myBlockedUserIDs.remove(unblockedUserID);
    _myNumOfBlocked--;
    notifyListeners();
    // }
  }

  void addPost(String postId) {
    _myPostIDs.insert(0, postId);
    _myNumOfPosts++;
    notifyListeners();
  }

  // void likePost(String postID) {
  //   if (_likedPostIDs.contains(postID)) {
  //     _likedPostIDs.remove(postID);
  //   } else {
  //     _likedPostIDs.insert(0, postID);
  //   }
  //   notifyListeners();
  // }

  void deletePost(String postID, bool isMyPost) {
    // _myposts.removeWhere((post) => post.postID == postID);
    // _postsLiked.removeWhere((post) => post.postID == postID);
    // _favoritePosts.removeWhere((post) => post.postID == postID);
    // _myPostIDs.remove(postID);
    // _likedPostIDs.remove(postID);
    // _favPostIDs.remove(postID);
    if (isMyPost) _myNumOfPosts--;
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

  void zero() {
    setNumOfNewMentions(0);
    setNumOfNewLinksNotifs(0);
    setNumOfNewLinkedNotifs(0);
    setNumOfLinkRequestNotifs(0);
    setNumOfPostLikesNotifs(0);
    setNumOfPostCommentsNotifs(0);
    setNumOfCommentRepliesNotifs(0);
    setNumOfCommentRepliesNotifs(0);
    setMyNumOfRepliessRemovedNotifs(0);
    setmyNumOfPostsRemovedNotifs(0);
    setNumOfCommentsRemovedNotifs(0);
    notifyListeners();
  }

  void initializeMyProfile(
      {required String visbility,
      required String additionalWebsite,
      required String additionalEmail,
      required String additionalNumber,
      required dynamic additionalAddress,
      required String additionalAddressName,
      required String imgUrl,
      required String bannerUrl,
      required bool bannerNSFW,
      required String email,
      required String username,
      required String bio,
      required bool hasSpotlight,
      required List<String> myTopics,
      required int joinedClubs,
      required int numOfLinks,
      required int numOfLinked,
      required int numOfPosts,
      required int numOfMentions,
      required int numOfNewLinksNotifs,
      required int numOfNewLinkedNotifs,
      required int numOfLinkRequestsNotifs,
      required int numOfPostLikesNotifs,
      required int numOfPostCommentsNotifs,
      required int numOfCommentRepliesNotifs,
      required int numOfPostsRemoved,
      required int numOfRepliesRemoved,
      required int numOfCommentsRemoved,
      required int numOfBlocked}) {
    setMyVis(visbility);
    setMyAdditionalWebsite(additionalWebsite);
    setMyAdditionalEmail(additionalEmail);
    setMyAdditionalNumber(additionalNumber);
    setMyAdditionalAddress(additionalAddress);
    setMyAdditionalAddressName(additionalAddressName);
    setMySpotlight(hasSpotlight);
    setMyProfileImage(imgUrl);
    setMyProfileBanner(bannerUrl, bannerNSFW);
    setMyEmail(email);
    setMyUsername(username);
    changeBio(bio);
    setMyTopics(myTopics);
    setJoinedClubs(joinedClubs);
    setMyNumOfLinks(numOfLinks);
    setMyNumOfLinked(numOfLinked);
    setNumOfPosts(numOfPosts);
    setNumOfNewLinksNotifs(numOfNewLinksNotifs);
    setNumOfNewMentions(numOfMentions);
    setNumOfNewLinkedNotifs(numOfNewLinkedNotifs);
    setNumOfLinkRequestNotifs(numOfLinkRequestsNotifs);
    setNumOfPostLikesNotifs(numOfPostLikesNotifs);
    setNumOfPostCommentsNotifs(numOfPostCommentsNotifs);
    setNumOfCommentRepliesNotifs(numOfCommentRepliesNotifs);
    setmyNumOfPostsRemovedNotifs(numOfPostsRemoved);
    setMyNumOfRepliessRemovedNotifs(numOfRepliesRemoved);
    setNumOfCommentsRemovedNotifs(numOfCommentsRemoved);
    setNumOfBlocked(numOfBlocked);
    notifyListeners();
  }

  void resetProfile() {
    _myProfileImageUrl = '';
    _myProfileBanner = '';
    _bannerNSFW = false;
    _myusername = '';
    _myemail = '';
    _myname = '';
    _additionalWebsite = '';
    _additionalEmail = '';
    _additionalNumber = '';
    _additionalAddress = '';
    _additionalAddressName = '';
    _mysurname = '';
    _mybio = '';
    _myActivity = '';
    _setupComplete = true;
    _hasSpotlight = false;
    _myStatus = '';
    _myAge = 18;
    _myVisibilityStatus = TheVisibility.public;
    _myposts = [];
    _myPostIDs = [];
    _favoritePosts = [];
    _favoriteClubPosts = [];
    _likedClubPosts = [];
    _favPostIDs = [];
    _postsLiked = [];
    _flaresLiked = [];
    _flareHistory = [];
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
    _joinedClubs = 0;
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
    _myNumOfRepliesRemovedNotifs = 0;
    _mytopics = [];
    _myLink = [];
    _myLinkTo = [];
    _myLinkIDs = [];
    _mylinks = [];
    _myClubs = [];
    _mylinkedTo = [];
    _myLinkedIDs = [];
  }
}
