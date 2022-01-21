import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../models/miniProfile.dart';
import '../models/post.dart';

class OtherProfile with ChangeNotifier implements Profile {
  String _otherAdditionalWebsite = '';
  String _otherAdditionalEmail = '';
  String _otherAdditionalNumber = '';
  dynamic _otherAdditionalAddress = '';
  String _otherAdditionalAddressName = '';
  String _otherProfileImageUrl = '';
  String _otherProfileBanner = '';
  Color _otherProfilePrimary = Colors.blue;
  Color _otherProfileAccent = Colors.yellow;
  bool _bannerNSFW = false;
  bool _showBanner = false;
  bool _hasSpotlight = false;
  String _otherUsername = '';
  String _name = '';
  String _surname = '';
  String _otherUserbio = '';
  String _otherUserActivity = '';
  String _otherUserStatus = '';
  String _otherUserEmail = '';
  String _activityStatus = 'Away';
  int _age = 0;
  late TheVisibility _otherUserVisibility;
  List<String> _otherUserPostIDs = [];
  List<Post> _otherUserPosts = [];
  List<String> _otherUserTopics = [];
  List<String> _otherUserLinkIDs = [];
  List<Profile> _otherUserLinks = [];
  List<String> _otherUserLinkedIDs = [];
  List<Profile> _otherUserLinkedTos = [];
  List<String> _otherUserBlockedIDs = [];
  List<Profile> _otherUserBlockedUsers = [];
  List<Map<String, String>> _otherUserPostLikesNotifs = [];
  List<String> _otherUserNewLinksNotifs = [];
  List<String> _otherUserLinkRequestsNotifs = [];
  List<String> _otherUserLinkedToNotifs = [];
  List<List<Map<String, String>>> _otherUserCommentNotifs = [];
  int _otherUserCommentsRemovedNotifs = 0;
  int _otherUserPostsRemovedNotifs = 0;
  int _numOfLinks = 0;
  int _numOfLinkedTos = 0;
  int _numOfPosts = 0;
  bool _linkedToMe = false;
  bool _imLinkedtoThem = false;
  bool _linkRequestSent = false;
  bool _isBlocked = false;
  bool _imBlocked = false;
  bool get linkedToMe => _linkedToMe;
  bool get imLinkedToThem => _imLinkedtoThem;
  bool get linkRequestSent => _linkRequestSent;
  bool get isBlocked => _isBlocked;
  bool get imBlocked => _imBlocked;
  String get activityStatus => _activityStatus;
  List<MiniProfile> get getMylinks => _mylinks;
  List<MiniProfile> get getMyLinkedTos => _mylinkedTo;

  void setActivityStatus(String status) {
    _activityStatus = status;
  }

  List<MiniProfile> _mylinks = [];
  List<MiniProfile> _mylinkedTo = [];

  void linkWithUser() {
    _imLinkedtoThem = true;
    _numOfLinks++;
    notifyListeners();
  }

  void block() {
    _isBlocked = true;
    notifyListeners();
  }

  void unblock() {
    _isBlocked = false;
    notifyListeners();
  }

  void unlinkWithUser() {
    _imLinkedtoThem = false;
    _numOfLinks--;
    notifyListeners();
  }

  void removeThem() {
    _linkedToMe = false;
    _numOfLinkedTos--;
    notifyListeners();
  }

  void sendLinkRequest() {
    _linkRequestSent = true;
    notifyListeners();
  }

  void cancelLinkRequest() {
    _linkRequestSent = false;
    notifyListeners();
  }

  void setLinkedToMe(bool linkedTOMe) {
    _linkedToMe = linkedTOMe;
  }

  void setImLinkedToThem(bool linkedToThem) {
    _imLinkedtoThem = linkedToThem;
  }

  void setLinkedRequestSent(bool requestSent) {
    _linkRequestSent = requestSent;
  }

  void setIsBlocked(bool isBlocked) {
    _isBlocked = isBlocked;
  }

  void setImBlocked(bool imBlocked) {
    _imBlocked = imBlocked;
  }

  @override
  String get getProfileImage => _otherProfileImageUrl;
  @override
  String get getProfileBanner => _otherProfileBanner;
  Color get getPrimaryColor => _otherProfilePrimary;
  Color get getAccentColor => _otherProfileAccent;
  bool get getBannerNSFW => _bannerNSFW;
  bool get getShowBanner => _showBanner;
  @override
  String get getAdditionalWebsite => _otherAdditionalWebsite;
  @override
  String get getAdditionalEmail => _otherAdditionalEmail;
  @override
  String get getAdditionalNumber => _otherAdditionalNumber;
  @override
  dynamic get getAdditionalAddress => _otherAdditionalAddress;
  @override
  String get getAdditionalAddressName => _otherAdditionalAddressName;
  @override
  bool get getHasSpotlight => _hasSpotlight;
  @override
  String get getUsername => _otherUsername;
  @override
  String get getEmail => _otherUserEmail;
  @override
  String get getName => _name;
  @override
  String get getSurname => _surname;
  @override
  String get getBio => _otherUserbio;
  @override
  get getActivity => _otherUserActivity;
  @override
  get getStatus => _otherUserStatus;
  @override
  int get getAge => _age;
  @override
  TheVisibility get getVisibility => _otherUserVisibility;
  @override
  List<String> get getPostIDs => _otherUserPostIDs;
  @override
  List<Post> get getPosts => _otherUserPosts;
  @override
  int get getNumberOfPosts => _numOfPosts;
  @override
  List<String> get getTopics => _otherUserTopics;

  @override
  List<String> get getLinkIDs => _otherUserLinkIDs;
  @override
  List<Profile> get getlinks => _otherUserLinks;
  @override
  int get getNumberOflinks => _numOfLinks;
  @override
  List<String> get getLinkedIDs => _otherUserLinkedIDs;
  @override
  List<Profile> get getLinkedTos => _otherUserLinkedTos;
  @override
  int get getNumberOfLinkedTos => _numOfLinkedTos;
  @override
  List<String> get getBlockedIDs => _otherUserBlockedIDs;
  @override
  List<Profile> get getBlockedUsers => _otherUserBlockedUsers;
  @override
  List<Map<String, String>> get getpostLikesNotifs => _otherUserPostLikesNotifs;
  @override
  List<String> get getnewLinksNotifs => _otherUserNewLinksNotifs;
  @override
  List<String> get getlinkRequestNotifs => _otherUserLinkRequestsNotifs;
  @override
  List<String> get getlinkedToNotifs => _otherUserLinkedToNotifs;
  @override
  List<List<Map<String, String>>> get getcommentNotifs =>
      _otherUserCommentNotifs;
  @override
  int get getcommentRemovedNotifs => _otherUserCommentsRemovedNotifs;
  @override
  int get getpostsRemovedNotifs => _otherUserPostsRemovedNotifs;

  @override
  set setAdditionalWebsite(String website) {
    _otherAdditionalWebsite = website;
  }

  void setOtherAdditionalWebsite(String website) {
    _otherAdditionalWebsite = website;
  }

  @override
  set setAdditionalEmail(String email) {
    _otherAdditionalEmail = email;
  }

  void setOtherAdditionalEmail(String email) {
    _otherAdditionalEmail = email;
  }

  @override
  set setAdditionalNumber(String number) {
    _otherAdditionalNumber = number;
  }

  void setOtherAdditionalNumber(String number) {
    _otherAdditionalNumber = number;
  }

  @override
  set setAdditionalAddress(dynamic address) {
    _otherAdditionalAddress = address;
  }

  void setOtherAdditionalAddress(dynamic address) {
    _otherAdditionalAddress = address;
  }

  @override
  set setAdditionalAddressName(String name) {
    _otherAdditionalAddressName = name;
  }

  void setOtherAdditionalAddressName(String name) {
    _otherAdditionalAddressName = name;
  }

  @override
  set setHasSpotlight(bool hasSpotlight) {
    _hasSpotlight = hasSpotlight;
  }

  void setOtherHasSpotlight(bool hasSpotlight) {
    _hasSpotlight = hasSpotlight;
  }

  @override
  set setpostLikesNotifs(List<Map<String, String>> postLikesNotifs) {
    _otherUserPostLikesNotifs = postLikesNotifs;
  }

  @override
  set setnewLinksNotifs(List<String> newLinksNotifs) {
    _otherUserNewLinksNotifs = newLinksNotifs;
  }

  @override
  set setlinkRequestNotifs(List<String> linkRequestNotifs) {
    _otherUserLinkRequestsNotifs = linkRequestNotifs;
  }

  @override
  set setlinkedToNotifs(List<String> linkedToNotifs) {
    _otherUserLinkedToNotifs = linkedToNotifs;
  }

  @override
  set setcommentNotifs(List<List<Map<String, String>>> commentNotifs) {
    _otherUserCommentNotifs = commentNotifs;
  }

  @override
  set setcommentRemovedNotifs(int commentsRemoved) {
    _otherUserCommentsRemovedNotifs = commentsRemoved;
  }

  @override
  set setpostsRemovedNotifs(int postsRemoved) {
    _otherUserPostsRemovedNotifs = postsRemoved;
  }

  @override
  set setProfileImage(String imgUrl) {
    _otherProfileImageUrl = imgUrl;
  }

  @override
  set setProfileBanner(String bannerUrl) {
    _otherProfileBanner = bannerUrl;
  }

  @override
  set setUsername(String username) {
    _otherUsername = username;
  }

  @override
  set setEmail(String email) {
    return null;
  }

  @override
  set setName(String name) {
    return null;
  }

  @override
  set setSurname(String surname) {
    return null;
  }

  @override
  set setAge(int age) {
    _age = age;
  }

  @override
  set setBio(String bio) {
    _otherUserbio = bio;
  }

  @override
  set setActivity(String activity) {
    _otherUserActivity = activity;
  }

  @override
  set setStatus(String status) {
    _otherUserStatus = status;
  }

  @override
  set setPostIDs(List<String> postIDs) {
    _otherUserPostIDs = postIDs;
  }

  @override
  set setPosts(List<Post> posts) {
    _otherUserPosts = posts;
  }

  @override
  set setlinkIDs(List<String> linkIds) {
    _otherUserLinkIDs = linkIds;
  }

  @override
  set setLinks(List<Profile> links) {
    _otherUserLinks = links;
  }

  @override
  set setLinkedIDs(List<String> linkedIds) {
    _otherUserLinkedIDs = linkedIds;
  }

  @override
  set setLinkedTos(List<Profile> linkedTos) {
    _otherUserLinkedTos = linkedTos;
  }

  @override
  set setBlockedIDs(List<String> blockedIds) {
    _otherUserBlockedIDs = blockedIds;
  }

  @override
  set setBlockedUsers(List<Profile> blockedUsers) {
    _otherUserBlockedUsers = blockedUsers;
  }

  @override
  set setTopics(List<String> topics) {
    _otherUserTopics = topics;
  }

  set setVisibility(TheVisibility vis) {
    _otherUserVisibility = vis;
  }

  void setOtherUserVis(TheVisibility vis) {
    _otherUserVisibility = vis;
  }

  void setOtherUserIMG(String imgUrl) {
    _otherProfileImageUrl = imgUrl;
  }

  void setOtherUserBanner(String bannerUrl) {
    _otherProfileBanner = bannerUrl;
  }

  void setOtherPrimary(Color primary) {
    _otherProfilePrimary = primary;
  }

  void setOtherAccent(Color accent) {
    _otherProfileAccent = accent;
  }

  void setOtherUserBannerNSFW(bool bannerNSFW) {
    _bannerNSFW = bannerNSFW;
  }

  void showNSFWBanner() {
    _showBanner = true;
    notifyListeners();
  }

  void setOtherUsername(String username) {
    _otherUsername = username;
  }

  void setOtherUserBio(String bio) {
    _otherUserbio = bio;
  }

  void setOtherUserNumOfLinks(int numOfLinks) {
    _numOfLinks = numOfLinks;
  }

  void setOtherUserNumOfLinked(int numOfLinked) {
    _numOfLinkedTos = numOfLinked;
  }

  void setOtherUserTopics(List<String> topics) {
    _otherUserTopics = topics;
  }

  void setOtherUserNumOfPosts(int numOfPosts) {
    _numOfPosts = numOfPosts;
  }

  void setOtherPostIDs(List<String> postIDs) {
    _otherUserPostIDs = postIDs;
  }

  void setOtherPosts(List<Post> posts) {
    _otherUserPosts = posts;
  }

  void setMyLinks(List<MiniProfile> links) {
    _mylinks = links;
  }

  void setMyLinkedTos(List<MiniProfile> linkedTos) {
    _mylinkedTo = linkedTos;
  }

  void setter({
    required TheVisibility vis,
    required String activity,
    required String imgUrl,
    required String bannerUrl,
    required String additionalWebsite,
    required String additionalEmail,
    required String additionalNumber,
    required dynamic additionalAddress,
    required String additionalAddressName,
    required String username,
    required String bio,
    required int numOfLinks,
    required int numOfLinked,
    required List<String> topics,
    required int numOfPosts,
    required List<String> postIDs,
    required bool linkedTOMe,
    required bool linkedToThem,
    required bool requestSent,
    required bool isBlocked,
    required bool imBlocked,
    required bool bannerNSFW,
    required bool hasSpotlight,
    required Color primaryColor,
    required Color accentColor,
  }) {
    setActivityStatus(activity);
    setOtherUserVis(vis);
    setOtherUserIMG(imgUrl);
    setOtherUserBanner(bannerUrl);
    setOtherUserBannerNSFW(bannerNSFW);
    setOtherAdditionalWebsite(additionalWebsite);
    setOtherAdditionalEmail(additionalEmail);
    setOtherAdditionalNumber(additionalNumber);
    setOtherAdditionalAddress(additionalAddress);
    setOtherAdditionalAddressName(additionalAddressName);
    setOtherPrimary(primaryColor);
    setOtherAccent(accentColor);
    setOtherHasSpotlight(hasSpotlight);
    setOtherUsername(username);
    setOtherUserBio(bio);
    setOtherUserNumOfLinks(numOfLinks);
    setOtherUserNumOfLinked(numOfLinked);
    setOtherUserTopics(topics);
    setOtherUserNumOfPosts(numOfPosts);
    setOtherPostIDs(postIDs);
    setLinkedToMe(linkedTOMe);
    setImLinkedToThem(linkedToThem);
    setLinkedRequestSent(requestSent);
    setIsBlocked(isBlocked);
    setImBlocked(imBlocked);
  }
}
