import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/miniProfile.dart';
import '../models/profile.dart';
import '../models/boardPostItem.dart';
import '../providers/postCarouselHelper.dart';
import 'clubProvider.dart';

enum PostType { legacy, board, branch }

class FullHelper with ChangeNotifier {
  PostType _postType = PostType.legacy;
  String _postId = '';
  String _posterId = '';
  String _locationName = '';
  String _clubName = '';
  String _bio = '';
  String _title = '';
  String _description = '';
  dynamic _location = '';
  int _numOfTopics = 0;
  int _numOfLinks = 0;
  int _numOfLinkedTos = 0;
  int _numOfLikes = 0;
  int _numOfComments = 0;
  int _previewCarouselIndex = 0;
  double _occupiedHeight = 0.0;
  double _occupiedWidth = 0.0;
  bool _sensitiveContent = false;
  bool _commentsDisabled = false;
  bool _postExists = true;
  bool _isLiked = false;
  bool _isFav = false;
  bool _isHidden = false;
  bool _isDeleted = false;
  bool _isClubPost = false;
  bool _isMod = false;
  bool _isBlocked = false;
  bool _imBlocked = false;
  bool _posterBanned = false;
  bool _imClubBanned = false;
  bool _clubDisabled = false;
  bool _clubProhibited = false;
  bool _isClubMember = false;
  bool _isLinkedToPoster = false;
  bool showPost = false;
  bool measuresGiven = false;
  List<String> _postTopics = [];
  List<String> _postImgUrls = [];
  List<String> _likers = [];
  List<Comment> _comments = [];
  List<MiniProfile> _likes = [];
  List<BoardPostItem> _boardPostItems = [];
  Color _boardPostBackground = Colors.blue;
  Color _boardPostGradient = Colors.yellow;
  DateTime _postedDate = DateTime.now();
  TheVisibility _visibility = TheVisibility.public;
  ClubVisibility _clubVisibility = ClubVisibility.public;
  final CarouselPhysHelp _carouselInstance = CarouselPhysHelp();
  CarouselPhysHelp get getCarouselInstance => _carouselInstance;
  dynamic get getLocation => _location;
  String get getLocationName => _locationName;
  String get posterId => _posterId;
  String get clubName => _clubName;
  String get postId => _postId;
  String get bio => _bio;
  String get title => _title;
  String get decription => _description;
  int get numOfTopics => _numOfTopics;
  int get numOfLinks => _numOfLinks;
  int get numOfLinkedTos => _numOfLinkedTos;
  int get getNumOfLikes => _numOfLikes;
  int get getNumOfComments => _numOfComments;
  int get previewCarouselIndex => _previewCarouselIndex;
  double get occupiedHeight => _occupiedHeight;
  double get occupiedWidth => _occupiedWidth;
  bool get sensitiveContent => _sensitiveContent;
  bool get commentsDisabled => _commentsDisabled;
  bool get postExists => _postExists;
  bool get isHidden => _isHidden;
  bool get isDeleted => _isDeleted;
  bool get isLiked => _isLiked;
  bool get isFav => _isFav;
  bool get isClubPost => _isClubPost;
  bool get isMod => _isMod;
  bool get isBlocked => _isBlocked;
  bool get imBlocked => _imBlocked;
  bool get posterBanned => _posterBanned;
  bool get imClubBanned => _imClubBanned;
  bool get clubDisabled => _clubDisabled;
  bool get clubProhibited => _clubProhibited;
  bool get isClubMember => _isClubMember;
  bool get isLinkedToPoster => _isLinkedToPoster;
  List<String> get postImgUrls => _postImgUrls;
  List<String> get postTopics => _postTopics;
  List<String> get getLikers => _likers;
  List<Comment> get getComments => _comments;
  List<MiniProfile> get getLikes => _likes;
  List<BoardPostItem> get boardPostItems => _boardPostItems;
  Color get boardPostBackground => _boardPostBackground;
  Color get boardPostGradient => _boardPostGradient;
  DateTime get postedDate => _postedDate;
  TheVisibility get visibility => _visibility;
  ClubVisibility get clubVisibility => _clubVisibility;
  PostType get postType => _postType;
  void setPostExists(bool xisExisting) => _postExists = xisExisting;
  void setIsLiked(bool xisLiked) => _isLiked = xisLiked;
  void setIsFav(bool xisFav) => _isFav = xisFav;
  void setIsHidden(bool xisHidden) => _isHidden = xisHidden;
  void setLocation(dynamic xlocation) => _location = xlocation;
  void setLocationName(String xlocationName) => _locationName = xlocationName;
  void setPosterID(String xposterID) => _posterId = xposterID;
  void setPostID(String xpostID) => _postId = xpostID;
  void setPostedDate(DateTime xdate) => _postedDate = xdate;
  void setNumOfTopics(int xnumber) => _numOfTopics = xnumber;
  void setBio(String xbio) => _bio = xbio;
  void setNumOfLinks(int xnumOfLinks) => _numOfLinks = xnumOfLinks;
  void setNumOfLinkedTos(int xnumOfLinked) => _numOfLinkedTos = xnumOfLinked;
  void setTitle(String xtitle) => _title = xtitle;
  void setDescription(String xdescription) => _description = xdescription;
  void setTopics(List<String> xtopics) => _postTopics = xtopics;
  void setImgUrls(List<String> ximgUrls) => _postImgUrls = ximgUrls;
  void setVisibility(TheVisibility xvis) => _visibility = xvis;
  void setSensitiveContent(bool xsensitive) => _sensitiveContent = xsensitive;
  void setCommentsDisabled(bool xdisabled) => _commentsDisabled = xdisabled;
  void setNumOfComments(int xnumber) => _numOfComments = xnumber;
  void setNumOfLikes(int xnumber) => _numOfLikes = xnumber;
  void setComments(List<Comment> xcomments) => _comments = xcomments;
  void clearComments() => _comments.clear();
  void addComments(List<Comment> xcomments) => _comments.addAll(xcomments);
  void setLikes(List<MiniProfile> xlikers) => _likes = xlikers;
  void setBoardPostItems(List<BoardPostItem> _i) => _boardPostItems = _i;
  void setLikers(List<String> xlikers) => _likers = xlikers;
  void setBoardPostBackground(Color _b) => _boardPostBackground = _b;
  void setBoardPostGradient(Color _g) => _boardPostGradient = _g;
  void setIsClubPost(bool xisClubPost) => _isClubPost = xisClubPost;
  void setIsMod(bool xisMod) => _isMod = xisMod;
  void setClubName(String xclubName) => _clubName = xclubName;
  void setIsBlocked(bool paramBlocked) => _isBlocked = paramBlocked;
  void setImBlocked(bool paramImBlocked) => _imBlocked = paramImBlocked;
  void setPosterBanned(bool paramPosterBanned) =>
      _posterBanned = paramPosterBanned;
  void setImClubBanned(bool paramClubBanned) => _imClubBanned = paramClubBanned;
  void setClubDisabled(bool paramClubDisabled) =>
      _clubDisabled = paramClubDisabled;
  void setClubProhibited(bool paramClubProhibited) =>
      _clubProhibited = paramClubProhibited;
  void setIsClubMember(bool paramIsClubMember) =>
      _isClubMember = paramIsClubMember;
  void setIsLinkedToPoster(bool paramLinkedToPoster) =>
      _isLinkedToPoster = paramLinkedToPoster;
  void setClubVis(ClubVisibility paramVis) => _clubVisibility = paramVis;
  void setPostType(PostType t) => _postType = t;
  void changePreviewCarouselIndex(int n) {
    _previewCarouselIndex = n;
    notifyListeners();
  }

  void giveMeasure() {
    measuresGiven = true;
    notifyListeners();
  }

  void giveOccupiedMeasures(double height, double width) {
    _occupiedHeight = height;
    _occupiedWidth = width;
  }

  void deletePost() {
    _isDeleted = true;
    notifyListeners();
  }

  void show() {
    showPost = true;
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

  void like() {
    _isLiked = !_isLiked;
    if (_isLiked)
      _numOfLikes++;
    else
      _numOfLikes--;
    notifyListeners();
  }

  void fav() {
    _isFav = !_isFav;
    notifyListeners();
  }

  void hidePost() {
    _isHidden = true;
    notifyListeners();
  }

  void unhidePost() {
    _isHidden = false;
    notifyListeners();
  }

  void initializeThisPost(
      {required String paramUsername,
      required String paramclubName,
      required String paramdescription,
      required String parampostID,
      required TheVisibility paramVisibility,
      required ClubVisibility paramClubVis,
      required int paramnumOfLikes,
      required int paramnumOfComments,
      required int paramnumOfTopics,
      required List<String> paramtopics,
      required List<String> paramimgUrls,
      required List<BoardPostItem> paramBoardPostItems,
      required Color paramBoardPostBackground,
      required Color paramBoardPostGradient,
      required DateTime parampostedDate,
      required dynamic paramlocation,
      required String paramlocationName,
      required bool paramsensitiveContent,
      required bool paramCommentsDisabled,
      required bool paramisLiked,
      required bool paramisFav,
      required bool paramisHidden,
      required bool paramisClubPost,
      required bool paramisMod,
      required bool paramBlocked,
      required bool paramImBlocked,
      required bool paramPosterBanned,
      required bool paramClubBanned,
      required bool paramClubDisabled,
      required bool paramClubProhibited,
      required bool paramIsClubMember,
      required bool paramLinkedToPoster,
      required bool paramExists,
      required PostType paramType}) {
    setPostExists(paramExists);
    setTitle(paramUsername);
    setClubName(paramclubName);
    setVisibility(paramVisibility);
    setDescription(paramdescription);
    setNumOfLikes(paramnumOfLikes);
    setNumOfComments(paramnumOfComments);
    setNumOfTopics(paramnumOfTopics);
    setTopics(paramtopics);
    setImgUrls(paramimgUrls);
    setBoardPostItems(paramBoardPostItems);
    setSensitiveContent(paramsensitiveContent);
    setCommentsDisabled(paramCommentsDisabled);
    setPostedDate(parampostedDate);
    setPostID(parampostID);
    setPosterID(paramUsername);
    setLocation(paramlocation);
    setLocationName(paramlocationName);
    setIsLiked(paramisLiked);
    setIsFav(paramisFav);
    setIsHidden(paramisHidden);
    setIsClubPost(paramisClubPost);
    setIsMod(paramisMod);
    setIsBlocked(paramBlocked);
    setImBlocked(paramImBlocked);
    setPosterBanned(paramPosterBanned);
    setImClubBanned(paramClubBanned);
    setClubDisabled(paramClubDisabled);
    setClubProhibited(paramClubProhibited);
    setIsClubMember(paramIsClubMember);
    setIsLinkedToPoster(paramLinkedToPoster);
    setClubVis(paramClubVis);
    setPostType(paramType);
    setBoardPostBackground(paramBoardPostBackground);
    setBoardPostGradient(paramBoardPostGradient);
  }
}
