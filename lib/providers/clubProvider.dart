import 'package:flutter/material.dart';

import '../models/post.dart';

enum ClubVisibility { public, private, hidden }

class ClubProvider with ChangeNotifier {
  String _clubName = '';
  String _clubAvatarURL = '';
  String _clubDescription = '';
  String _clubBannerUrl = '';
  int _numOfMembers = 0;
  int _numOfPosts = 0;
  int _numOfJoinRequests = 0;
  int _numOfNewMembers = 0;
  int _maxDailyPostsByMembers = 0;
  int _numOfBannedMembers = 0;
  double _earnings = 0.0;
  bool _isDisabled = false;
  bool _isProhibited = false;
  bool _memberCanPost = false;
  bool _bannerNSFW = false;
  bool _isJoined = false;
  bool _isRequested = false;
  bool _isMod = false;
  bool _isBanned = false;
  bool _isFounder = false;
  bool _monetize = false;
  bool _allowQuickJoin = false;
  List<String> _clubTopics = [];
  List<Post> _posts = [];
  final ScrollController _clubPostsScrollController = ScrollController();
  final ScrollController _clubScreenScrollController = ScrollController();
  ClubVisibility _clubVisibility = ClubVisibility.public;
  String get clubName => _clubName;
  String get clubAvatar => _clubAvatarURL;
  String get clubDescription => _clubDescription;
  String get clubBannerUrl => _clubBannerUrl;
  int get numOfMembers => _numOfMembers;
  int get numOfPosts => _numOfPosts;
  int get numOfJoinRequests => _numOfJoinRequests;
  int get numOfNewMembers => _numOfNewMembers;
  int get maxDailyPostsByMembers => _maxDailyPostsByMembers;
  int get numOfBannedMembers => _numOfBannedMembers;
  double get earnings => _earnings;
  bool get memberCanPost => _memberCanPost;
  bool get bannerNSFW => _bannerNSFW;
  bool get isJoined => _isJoined;
  bool get isRequested => _isRequested;
  bool get isMod => _isMod;
  bool get isBanned => _isBanned;
  bool get isFounder => _isFounder;
  bool get isDisabled => _isDisabled;
  bool get isProhibited => _isProhibited;
  bool get isMonetized => _monetize;
  bool get allowQuickJoin => _allowQuickJoin;
  List<Post> get posts => _posts;
  List<String> get clubTopics => _clubTopics;
  ScrollController get getClubPostsScrollController =>
      _clubPostsScrollController;
  ScrollController get getScreenScrollController => _clubScreenScrollController;
  ClubVisibility get clubVisibility => _clubVisibility;
  void setQuickJoin(bool quick) => _allowQuickJoin = quick;
  void setClubMonetization(bool money) => _monetize = money;
  void setEarnings(double earns) => _earnings = earns;
  void setclubName(String thisclubname) => _clubName = thisclubname;
  void setClubAvatar(String thisurl) => _clubAvatarURL = thisurl;
  void setClubVisibility(ClubVisibility thisvis) => _clubVisibility = thisvis;
  void setIsRequested(bool thisisRequested) => _isRequested = thisisRequested;
  void setclubBannerUrl(String thisbannerURL) => _clubBannerUrl = thisbannerURL;
  void setnumOfPosts(int thisnumOfPosts) => _numOfPosts = thisnumOfPosts;
  void setNumOfNewMembers(int thismembers) => _numOfNewMembers = thismembers;
  void setMemberCanPost(bool thiscanPost) => _memberCanPost = thiscanPost;
  void setbannerNSFW(bool thisbannerNSFW) => _bannerNSFW = thisbannerNSFW;
  void setsJoined(bool thisisJoined) => _isJoined = thisisJoined;
  void setisMod(bool thisisMod) => _isMod = thisisMod;
  void setisBanned(bool thisisBanned) => _isBanned = thisisBanned;
  void setisFounder(bool thisisFounder) => _isFounder = thisisFounder;
  void setIsDisabled(bool thisisDisable) => _isDisabled = thisisDisable;
  void setIsProhibited(bool thisprohibited) => _isProhibited = thisprohibited;
  void setposts(List<Post> thisposts) => _posts = thisposts;
  void setNumOfJoinRequests(int thisrequests) =>
      _numOfJoinRequests = thisrequests;
  void setnumOfMembers(int thisnumOfMembers) =>
      _numOfMembers = thisnumOfMembers;
  void setclubTopics(List<String> thistopics) => _clubTopics = thistopics;
  void setMaxDailyPostsByMembers(int thismax) =>
      _maxDailyPostsByMembers = thismax;
  void setNumOfBannedMembers(int thisnumOfbanned) =>
      _numOfBannedMembers = thisnumOfbanned;
  void setclubDescription(String thisclubDescription) =>
      _clubDescription = thisclubDescription;
  void clearPosts() => _posts.clear();
  void disposeScrollController() => _clubPostsScrollController.dispose();
  void disposeScreenScrollController() => _clubScreenScrollController.dispose();
  void notifyThem() => notifyListeners();
  void changeVisibility(ClubVisibility newVis) {
    _clubVisibility = newVis;
    notifyListeners();
  }

  void changeBanner(String newUrl, bool newNSFW) {
    _clubBannerUrl = newUrl;
    _bannerNSFW = newNSFW;
    notifyListeners();
  }

  void changeTopics(List<String> newNames) {
    _clubTopics = newNames;
    notifyListeners();
  }

  void changeBio(String newBio) {
    _clubDescription = newBio;
    notifyListeners();
  }

  void changeClubAvatar(String newUrl) {
    _clubAvatarURL = newUrl;
    notifyListeners();
  }

  void changeMaxDailyPosts(int newMax) {
    _maxDailyPostsByMembers = newMax;
    notifyListeners();
  }

  void changeAllowUserPosts(bool newRule) {
    _memberCanPost = newRule;
    notifyListeners();
  }

  void changeAllowQuickJoin(bool newRule) {
    _allowQuickJoin = newRule;
    notifyListeners();
  }

  void changeDisableClub(bool newDis) {
    _isDisabled = newDis;
    notifyListeners();
  }

  void decreaseNumOfRequests() {
    _numOfJoinRequests--;
    notifyListeners();
  }

  void addMembers() {
    _numOfMembers++;
    notifyListeners();
  }

  void zeroNotifs() {
    _numOfNewMembers = 0;
    _numOfJoinRequests = 0;
    notifyListeners();
  }

  void prohibitClub(bool prohibition) {
    _isProhibited = prohibition;
    notifyListeners();
  }

  void requestJoinClub() {
    _isRequested = true;
    notifyListeners();
  }

  void cancelRequest() {
    _isRequested = false;
    notifyListeners();
  }

  void joinClub() {
    _isJoined = true;
    _numOfMembers++;
    notifyListeners();
  }

  void leaveClub() {
    _isJoined = false;
    _numOfMembers--;
    notifyListeners();
  }

  void setter(
      {required String clubberclubname,
      required String clubberurl,
      required String clubberclubDescription,
      required String clubberbannerURL,
      required int clubbernumOfMembers,
      required int clubbernumOFPosts,
      required int clubberrequests,
      required int clubbermembers,
      required int clubbermax,
      required int clubberbanned,
      required bool clubbercanPost,
      required bool clubberbannerNSFW,
      required bool clubberisJoined,
      required bool clubberisMod,
      required bool clubberisBanned,
      required bool clubberisFounder,
      required bool clubberisDisable,
      required bool clubberprohibited,
      required bool clubberisRequested,
      required bool clubberQuickJoin,
      required List<String> clubbertopics,
      required ClubVisibility clubbervis}) {
    setclubName(clubberclubname);
    setClubAvatar(clubberurl);
    setClubVisibility(clubbervis);
    setclubDescription(clubberclubDescription);
    setclubBannerUrl(clubberbannerURL);
    setnumOfMembers(clubbernumOfMembers);
    setnumOfPosts(clubbernumOFPosts);
    setNumOfJoinRequests(clubberrequests);
    setNumOfNewMembers(clubbermembers);
    setMaxDailyPostsByMembers(clubbermax);
    setNumOfBannedMembers(clubberbanned);
    setMemberCanPost(clubbercanPost);
    setbannerNSFW(clubberbannerNSFW);
    setsJoined(clubberisJoined);
    setisMod(clubberisMod);
    setisBanned(clubberisBanned);
    setisFounder(clubberisFounder);
    setIsDisabled(clubberisDisable);
    setIsProhibited(clubberprohibited);
    setclubTopics(clubbertopics);
    setIsRequested(clubberisRequested);
    setQuickJoin(clubberQuickJoin);
  }
}
