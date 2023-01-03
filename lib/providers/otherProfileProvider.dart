import 'package:flutter/material.dart';

import '../models/miniProfile.dart';
import '../models/post.dart';
import '../models/profile.dart';

class OtherProfile with ChangeNotifier implements Profile {
  String _otherAdditionalWebsite = '';
  String _otherAdditionalEmail = '';
  String _otherAdditionalNumber = '';
  dynamic _otherAdditionalAddress = '';
  String _otherAdditionalAddressName = '';
  String _otherProfileImageUrl = '';
  String _otherProfileBanner = '';
  String _otherUsername = '';
  String _name = '';
  String _surname = '';
  String _otherUserbio = '';
  String _otherUserActivity = '';
  String _otherUserStatus = '';
  String _otherUserEmail = '';
  String _activityStatus = 'Away';
  int _age = 0;
  int _otherUserCommentsRemovedNotifs = 0;
  int _otherUserPostsRemovedNotifs = 0;
  int _numOfLinks = 0;
  int _joinedClubs = 0;
  int _numOfLinkedTos = 0;
  int _numOfPosts = 0;
  bool _bannerNSFW = false;
  bool _showBanner = false;
  bool _hasSpotlight = false;
  bool _hasUnseenCollection = false;
  bool _linkedToMe = false;
  bool _imLinkedtoThem = false;
  bool _linkRequestSent = false;
  bool _isBlocked = false;
  bool _isBanned = false;
  bool _imBlocked = false;
  List<String> _otherUserPostIDs = [];
  List<String> _otherUserTopics = [];
  List<String> _otherUserLinkIDs = [];
  List<String> _otherUserLinkedIDs = [];
  List<String> _otherUserBlockedIDs = [];
  List<String> _otherUserNewLinksNotifs = [];
  List<String> _otherUserLinkRequestsNotifs = [];
  List<String> _otherUserLinkedToNotifs = [];
  List<Profile> _otherUserLinks = [];
  List<Profile> _otherUserLinkedTos = [];
  List<Profile> _otherUserBlockedUsers = [];
  List<Map<String, String>> _otherUserPostLikesNotifs = [];
  List<List<Map<String, String>>> _otherUserCommentNotifs = [];
  List<MiniProfile> _mylinks = [];
  List<MiniProfile> _mylinkedTo = [];
  List<Post> _otherUserPosts = [];
  Color _otherProfilePrimary = Colors.blue;
  Color _otherProfileAccent = Colors.yellow;
  Color _otherProfileLikeColor = Colors.green;
  final ScrollController _profilePostsScrollController = ScrollController();
  final ScrollController _otherProfileScrollController = ScrollController();
  late TheVisibility _otherUserVisibility;
  bool get linkedToMe => _linkedToMe;
  bool get imLinkedToThem => _imLinkedtoThem;
  bool get linkRequestSent => _linkRequestSent;
  bool get isBlocked => _isBlocked;
  bool get isBanned => _isBanned;
  bool get imBlocked => _imBlocked;
  String get activityStatus => _activityStatus;
  int get getJoinedClubs => _joinedClubs;
  bool get getBannerNSFW => _bannerNSFW;
  bool get getShowBanner => _showBanner;
  bool get getHasUnseen => _hasUnseenCollection;
  Color get getPrimaryColor => _otherProfilePrimary;
  Color get getAccentColor => _otherProfileAccent;
  Color get getLikeColor => _otherProfileLikeColor;
  List<MiniProfile> get getMylinks => _mylinks;
  List<MiniProfile> get getMyLinkedTos => _mylinkedTo;
  ScrollController get getProfilePostsScrollController =>
      _profilePostsScrollController;
  ScrollController get getProfileScrollController =>
      _otherProfileScrollController;
  @override
  String get getProfileImage => _otherProfileImageUrl;
  @override
  String get getProfileBanner => _otherProfileBanner;
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
  bool get getHasSpotlight => _hasSpotlight;
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
  set setAdditionalWebsite(String website) => _otherAdditionalWebsite = website;
  @override
  set setAdditionalEmail(String xemail) => _otherAdditionalEmail = xemail;
  @override
  set setAdditionalNumber(String xnumber) => _otherAdditionalNumber = xnumber;
  @override
  set setAdditionalAddress(dynamic xaddress) =>
      _otherAdditionalAddress = xaddress;
  @override
  set setAdditionalAddressName(String xname) =>
      _otherAdditionalAddressName = xname;
  @override
  set setHasSpotlight(bool xhasSpotlight) => _hasSpotlight = xhasSpotlight;

  @override
  set setpostLikesNotifs(List<Map<String, String>> postLikesNotifs) =>
      _otherUserPostLikesNotifs = postLikesNotifs;
  @override
  set setnewLinksNotifs(List<String> newLinksNotifs) =>
      _otherUserNewLinksNotifs = newLinksNotifs;
  @override
  set setlinkRequestNotifs(List<String> linkRequestNotifs) =>
      _otherUserLinkRequestsNotifs = linkRequestNotifs;
  @override
  set setlinkedToNotifs(List<String> linkedToNotifs) =>
      _otherUserLinkedToNotifs = linkedToNotifs;
  @override
  set setcommentNotifs(List<List<Map<String, String>>> commentNotifs) =>
      _otherUserCommentNotifs = commentNotifs;
  @override
  set setcommentRemovedNotifs(int commentsRemoved) =>
      _otherUserCommentsRemovedNotifs = commentsRemoved;
  @override
  set setpostsRemovedNotifs(int postsRemoved) =>
      _otherUserPostsRemovedNotifs = postsRemoved;
  @override
  set setProfileImage(String imgUrl) => _otherProfileImageUrl = imgUrl;
  @override
  set setProfileBanner(String bannerUrl) => _otherProfileBanner = bannerUrl;
  @override
  set setUsername(String username) => _otherUsername = username;
  @override
  set setEmail(String email) => null;
  @override
  set setName(String name) => null;
  @override
  set setSurname(String surname) => null;
  @override
  set setAge(int age) => _age = age;
  @override
  set setBio(String bio) => _otherUserbio = bio;
  @override
  set setActivity(String activity) => _otherUserActivity = activity;
  @override
  set setStatus(String status) => _otherUserStatus = status;
  @override
  set setPostIDs(List<String> postIDs) => _otherUserPostIDs = postIDs;
  @override
  set setPosts(List<Post> posts) => _otherUserPosts = posts;
  @override
  set setlinkIDs(List<String> linkIds) => _otherUserLinkIDs = linkIds;
  @override
  set setLinks(List<Profile> links) => _otherUserLinks = links;
  @override
  set setLinkedIDs(List<String> linkedIds) => _otherUserLinkedIDs = linkedIds;
  @override
  set setLinkedTos(List<Profile> linkedTos) => _otherUserLinkedTos = linkedTos;
  @override
  set setBlockedIDs(List<String> blockedIds) =>
      _otherUserBlockedIDs = blockedIds;
  @override
  set setBlockedUsers(List<Profile> blockedUsers) =>
      _otherUserBlockedUsers = blockedUsers;
  @override
  set setTopics(List<String> topics) => _otherUserTopics = topics;
  set setVisibility(TheVisibility xvis) => _otherUserVisibility = xvis;

  void setOtherUserVis(TheVisibility xvis) => _otherUserVisibility = xvis;
  void setOtherUserIMG(String ximgUrl) => _otherProfileImageUrl = ximgUrl;
  void setOtherUserBanner(String xbannerUrl) =>
      _otherProfileBanner = xbannerUrl;
  void setOtherPrimary(Color xprimary) => _otherProfilePrimary = xprimary;
  void setOtherAccent(Color xaccent) => _otherProfileAccent = xaccent;
  void setOtherLike(Color xlike) => _otherProfileLikeColor = xlike;
  void setOtherUserBannerNSFW(bool xbannerNSFW) => _bannerNSFW = xbannerNSFW;
  void setOtherUsername(String xusername) => _otherUsername = xusername;
  void setOtherUserBio(String xbio) => _otherUserbio = xbio;
  void setOtherUserNumOfLinks(int xnumOfLinks) => _numOfLinks = xnumOfLinks;
  void setOtherUserNumOfLinked(int xnumOfLinked) =>
      _numOfLinkedTos = xnumOfLinked;
  void setJoinedClubs(int xjoinedClubs) => _joinedClubs = xjoinedClubs;
  void setOtherUserTopics(List<String> xtopics) => _otherUserTopics = xtopics;
  void setOtherUserNumOfPosts(int xnumOfPosts) => _numOfPosts = xnumOfPosts;
  void setOtherPostIDs(List<String> xpostIDs) => _otherUserPostIDs = xpostIDs;
  void setOtherPosts(List<Post> xposts) => _otherUserPosts = xposts;
  void setMyLinks(List<MiniProfile> xlinks) => _mylinks = xlinks;
  void setMyLinkedTos(List<MiniProfile> xlinkedTos) => _mylinkedTo = xlinkedTos;
  void setLinkedToMe(bool linkedTOMe) => _linkedToMe = linkedTOMe;
  void setImLinkedToThem(bool linkedToThem) => _imLinkedtoThem = linkedToThem;
  void setLinkedRequestSent(bool requestSent) => _linkRequestSent = requestSent;
  void setIsBlocked(bool xisBlocked) => _isBlocked = xisBlocked;
  void setActivityStatus(String xstatus) => _activityStatus = xstatus;
  void setImBlocked(bool ximBlocked) => _imBlocked = ximBlocked;
  void setOtherAdditionalEmail(String xemail) => _otherAdditionalEmail = xemail;
  void setHasUnseen(bool xdoesHave) => _hasUnseenCollection = xdoesHave;
  void disposePostsController() => _profilePostsScrollController.dispose();
  void disposeProfileController() => _otherProfileScrollController.dispose();
  void setOtherAdditionalWebsite(String website) =>
      _otherAdditionalWebsite = website;
  void setOtherAdditionalNumber(String xnumber) =>
      _otherAdditionalNumber = xnumber;
  void setOtherAdditionalAddress(dynamic xaddress) =>
      _otherAdditionalAddress = xaddress;
  void setOtherAdditionalAddressName(String xname) =>
      _otherAdditionalAddressName = xname;
  void setOtherHasSpotlight(bool xhasSpotlight) =>
      _hasSpotlight = xhasSpotlight;

  void setIsBanned(String status) {
    if (status == 'Allowed') {
      _isBanned = false;
    } else {
      _isBanned = true;
    }
  }

  void showNSFWBanner() {
    _showBanner = true;
    notifyListeners();
  }

  void linkWithUser() {
    _imLinkedtoThem = true;
    _numOfLinks++;
    notifyListeners();
  }

  void block() {
    _isBlocked = true;
    notifyListeners();
  }

  void ban() {
    _isBanned = true;
    notifyListeners();
  }

  void unblock() {
    _isBlocked = false;
    notifyListeners();
  }

  void unban() {
    _isBanned = false;
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

  void setter(
      {required TheVisibility vis,
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
      required String status,
      required int numOfLinks,
      required int numOfLinked,
      required int joinedClubs,
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
      required bool doesHaveUnseen,
      required Color primaryColor,
      required Color accentColor,
      required Color likeColor}) {
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
    setOtherLike(likeColor);
    setOtherHasSpotlight(hasSpotlight);
    setHasUnseen(doesHaveUnseen);
    setOtherUsername(username);
    setOtherUserBio(bio);
    setOtherUserNumOfLinks(numOfLinks);
    setOtherUserNumOfLinked(numOfLinked);
    setOtherUserTopics(topics);
    setOtherUserNumOfPosts(numOfPosts);
    setJoinedClubs(joinedClubs);
    setOtherPostIDs(postIDs);
    setLinkedToMe(linkedTOMe);
    setImLinkedToThem(linkedToThem);
    setLinkedRequestSent(requestSent);
    setIsBlocked(isBlocked);
    setIsBanned(status);
    setImBlocked(imBlocked);
  }
}
