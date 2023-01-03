import 'package:flutter/material.dart';

import '../models/flareCollectionModel.dart';
import '../models/profile.dart';

class FlareProfile with ChangeNotifier {
  String _username = '';
  String _bannerURL = '';
  String _flaresBio = '';
  String _currentlyShowcasing = '';
  int _numOfFlares = 0;
  int _numOfViews = 0;
  int _numOfLikes = 0;
  int _numOfLikeNotifs = 0;
  int _numOfCommentNotifs = 0;
  bool _bannerNSFW = false;
  bool _isMyProfile = false;
  bool _imBlocked = false;
  bool _isBanned = false;
  bool _imLinked = false;
  List<FlareCollectionModel> _collections = [];
  TheVisibility _visibility = TheVisibility.public;
  final ScrollController _collectionScrollController = ScrollController();
  final ScrollController _profileScrollController = ScrollController();
  String get username => _username;
  String get bannerURL => _bannerURL;
  String get flaresBio => _flaresBio;
  String get currentlyShowcasing => _currentlyShowcasing;
  int get numOfFlares => _numOfFlares;
  int get numOfViews => _numOfViews;
  int get numOfLikes => _numOfLikes;
  int get numOfLikeNotifs => _numOfLikeNotifs;
  int get numOfCommentNotifs => _numOfCommentNotifs;
  bool get bannerNSFW => _bannerNSFW;
  bool get isMyProfile => _isMyProfile;
  bool get imBlocked => _imBlocked;
  bool get isBanned => _isBanned;
  bool get imLinked => _imLinked;
  List<FlareCollectionModel> get collections => _collections;
  ScrollController get getCollectionsController => _collectionScrollController;
  ScrollController get getprofileScrollController => _profileScrollController;
  TheVisibility get profileVis => _visibility;
  void setUsername(String u) => _username = u;
  void setBannerURL(String url) => _bannerURL = url;
  void setFlaresBio(String newBio) => _flaresBio = newBio;
  void setShowcase(String showcase) => _currentlyShowcasing = showcase;
  void setNumOfFlares(int num) => _numOfFlares = num;
  void setNumOfViews(int num) => _numOfViews = num;
  void setNumOfLikes(int num) => _numOfLikes = num;
  void setNumOfLikeNotifs(int num) => _numOfLikeNotifs = num;
  void setNumOfCommentNotifs(int num) => _numOfCommentNotifs = num;
  void setCollections(List<FlareCollectionModel> lsit) => _collections = lsit;
  void setBannerNSFW(bool nsfw) => _bannerNSFW = nsfw;
  void setIsMyProfile(bool ismy) => _isMyProfile = ismy;
  void setIsBanned(bool banned) => _isBanned = banned;
  void setImBlocked(bool blocked) => _imBlocked = blocked;
  void setImLinked(bool i) => _imLinked = i;
  void setVis(TheVisibility v) => _visibility = v;
  void disposeCollectionScrollController() =>
      _collectionScrollController.dispose();
  void disposeProfileScrollController() => _profileScrollController.dispose();

  void clearNotifs() {
    _numOfLikeNotifs = 0;
    _numOfCommentNotifs = 0;
    notifyListeners();
  }

  void addViews() {
    _numOfViews++;
    notifyListeners();
  }

  void addLikes() {
    _numOfLikes++;
    notifyListeners();
  }

  void addFlares(int added) {
    _numOfFlares = _numOfFlares + added;
    notifyListeners();
  }

  void changeBio(String editedBio) {
    _flaresBio = editedBio;
    notifyListeners();
  }

  void initializeFlareProfile(
      {required String paramUsername,
      required String paramBanner,
      required String paramBio,
      required String paramShowcase,
      required int paramNumFlares,
      required int paramNumViews,
      required int paramNumLikes,
      required int paramLikeNotifs,
      required int paramNumOfCommentNotifs,
      required List<FlareCollectionModel> paramList,
      required bool paramNSFW,
      required bool paramIsMine,
      required bool paramImBlocked,
      required bool paramIsBanned,
      required bool paramImLinked,
      required TheVisibility paramVisibility}) {
    setUsername(paramUsername);
    setBannerURL(paramBanner);
    setFlaresBio(paramBio);
    setShowcase(paramShowcase);
    setNumOfFlares(paramNumFlares);
    setNumOfViews(paramNumViews);
    setNumOfLikes(paramNumLikes);
    setNumOfLikeNotifs(paramLikeNotifs);
    setNumOfCommentNotifs(paramNumOfCommentNotifs);
    setCollections(paramList);
    setBannerNSFW(paramNSFW);
    setIsMyProfile(paramIsMine);
    setImBlocked(paramImBlocked);
    setIsBanned(paramIsBanned);
    setImLinked(paramImLinked);
    setVis(paramVisibility);
  }
}
