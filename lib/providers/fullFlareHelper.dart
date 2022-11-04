import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/profile.dart';

class FlareHelper with ChangeNotifier {
  String _poster = '';
  String _flareID = '';
  String _collectionID = '';
  String _collectionName = '';
  String _mediaURL = '';
  String _thumbNailURL = '';
  int _numOfLikes = 0;
  int _numOfViewers = 0;
  int _numOfComments = 0;
  int _duration = 0;
  bool _likedByMe = false;
  bool _isVid = false;
  bool _isImage = false;
  bool _isMyFlare = false;
  bool _isShown = false;
  bool _viewedByMe = false;
  bool _isDeleted = false;
  bool _hasNSFW = false;
  bool _isBanned = false;
  bool _isBlocked = false;
  bool _imBlocked = false;
  bool _isHidden = false;
  bool _imLinked = false;
  bool _commentsDisabled = false;
  //  List<String> _topics = [];
  List<Comment> _comments = [];
  DateTime _postedDate = DateTime.now();
  TheVisibility _posterVis = TheVisibility.public;
  Color _backgroundColor = Colors.blue;
  Color _gradientColor = Colors.yellow;
  String get poster => _poster;
  String get flareID => _flareID;
  String get collectionID => _collectionID;
  String get collectionName => _collectionName;
  String get mediaURL => _mediaURL;
  String get thumbNailURL => _thumbNailURL;
  List<Comment> get comments => _comments;
  int get numOfViewers => _numOfViewers;
  int get numOfLikes => _numOfLikes;
  int get numOfComments => _numOfComments;
  int get duration => _duration;
  bool get likedByMe => _likedByMe;
  bool get viewedByMe => _viewedByMe;
  bool get isMyFlare => _isMyFlare;
  bool get isImage => _isImage;
  bool get isVid => _isVid;
  bool get isDeleted => _isDeleted;
  bool get isBanned => _isBanned;
  bool get isBlocked => _isBlocked;
  bool get imBlocked => _imBlocked;
  bool get isHidden => _isHidden;
  bool get hasNSFW => _hasNSFW;
  bool get isShow => _isShown;
  bool get imLinked => _imLinked;
  bool get commentsDisabled => _commentsDisabled;
  //  List<String> get topics => _topics;
  DateTime get postedDate => _postedDate;
  TheVisibility get posterVisibility => _posterVis;
  Color get backgorundColor => _backgroundColor;
  Color get gradientColor => _gradientColor;
  void setposter(String user) => _poster = user;
  void setFlareID(String id) => _flareID = id;
  void setCollectionID(String id) => _collectionID = id;
  void setCollectionName(String name) => _collectionName = name;
  void setPostedDate(DateTime date) => _postedDate = date;
  void setDuration(int d) => _duration = d;
  //  void  setTopics(List<String> tops) => _topics=tops;
  void setComments(List<Comment> c) => _comments = c;
  void setNumOfViewers(int viewers) => _numOfViewers = viewers;
  void setNumOfLikes(int likes) => _numOfLikes = likes;
  void setNumOfComments(int comments) => _numOfComments = comments;
  void setMediaURL(String url) => _mediaURL = url;
  void setThumbNailURL(String t) => _thumbNailURL = t;
  void setLikedByMe(bool liked) => _likedByMe = liked;
  void setViewedByMe(bool viewed) => _viewedByMe = viewed;
  void setIsMyFlare(bool i) => _isMyFlare = i;
  void setIsImage(bool isIt) => _isImage = isIt;
  void setIsVid(bool vid) => _isVid = vid;
  void setIsDeleted(bool deleted) => _isDeleted = deleted;
  void setIsBanned(bool ban) => _isBanned = ban;
  void setIsBlocked(bool blck) => _isBlocked = blck;
  void setImBlocked(bool blk) => _imBlocked = blk;
  void setIsHidden(bool hid) => _isHidden = hid;
  void setHasNSFW(bool has) => _hasNSFW = has;
  void setImLinked(bool l) => _imLinked = l;
  void setVis(TheVisibility v) => _posterVis = v;
  void setcommentsDisabled(bool i) => _commentsDisabled = i;
  void setBackgroundColor(Color c) => _backgroundColor = c;
  void setGradientColor(Color c) => _gradientColor = c;
  void clearComments() => _comments.clear();
  void deleteFlare() {
    _isDeleted = true;
    notifyListeners();
  }

  void showFlare() {
    _isShown = true;
    notifyListeners();
  }

  void viewFlare() {
    _viewedByMe = true;
    _numOfViewers++;
    notifyListeners();
  }

  void like() {
    _likedByMe = !_likedByMe;
    if (_likedByMe)
      _numOfLikes++;
    else
      _numOfLikes--;
    notifyListeners();
  }

  void addComment(Comment comment) {
    _comments.insert(0, comment);
    _numOfComments++;
    notifyListeners();
  }

  void removeComment(String commentID) {
    _comments.removeWhere((comment) => comment.commentID == commentID);
    _numOfComments--;
    notifyListeners();
  }

  void initializeThisFlare(
      {required String paramposter,
      required String paramflareID,
      required String paramCollectionID,
      required String paramcollectionName,
      required DateTime parampostedDate,
      //required  List<String> paramtopics,
      required int paramnumOfViewers,
      required int paramnumOfLikes,
      required int paramnumOfComments,
      required int paramDuration,
      required String parammediaURL,
      required String paramthumbNailURL,
      required bool paramlikedByMe,
      required bool paramviewedByMe,
      required bool paramisMyFlare,
      required bool paramisImage,
      required bool paramisVid,
      required bool paramisDeleted,
      required bool paramIsBanned,
      required bool paramIsBlocked,
      required bool paramImBlocked,
      required bool paramIsHidden,
      required bool paramhasNSFW,
      required bool paramImLinked,
      required bool paramCommentsDisabled,
      required Color paramBackgroundColor,
      required Color paramGradientColor,
      required TheVisibility paramVis}) {
    setposter(paramposter);
    setFlareID(paramflareID);
    setCollectionID(paramCollectionID);
    setCollectionName(paramcollectionName);
    setPostedDate(parampostedDate);
    //  setTopics(paramtopics);
    setNumOfViewers(paramnumOfViewers);
    setNumOfLikes(paramnumOfLikes);
    setNumOfComments(paramnumOfComments);
    setDuration(paramDuration);
    setMediaURL(parammediaURL);
    setThumbNailURL(paramthumbNailURL);
    setLikedByMe(paramlikedByMe);
    setViewedByMe(paramviewedByMe);
    setIsMyFlare(paramisMyFlare);
    setIsImage(paramisImage);
    setIsVid(paramisVid);
    setIsDeleted(paramisDeleted);
    setIsBanned(paramIsBanned);
    setIsBlocked(paramIsBlocked);
    setImBlocked(paramImBlocked);
    setIsHidden(paramIsHidden);
    setHasNSFW(paramhasNSFW);
    setImLinked(paramImLinked);
    setcommentsDisabled(paramCommentsDisabled);
    setBackgroundColor(paramBackgroundColor);
    setGradientColor(paramGradientColor);
    setVis(paramVis);
  }
}
