import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../models/miniProfile.dart';
import '../models/comment.dart';
import '../widgets/videoPlayer.dart';

class FullHelper with ChangeNotifier {
  String _posterId = '';
  String _postId = '';
  DateTime _postedDate = DateTime.now();
  int _numOfTopics = 0;
  String _userImageUrl = '';
  String _bio = '';
  int _numOfLinks = 0;
  int _numOfLinkedTos = 0;
  String _title = '';
  String _description = '';
  List<String> _postTopics = [];
  List<String> _postImgUrls = [];
  List<MyVideoPlayer> _videos = [];
  TheVisibility _visibility = TheVisibility.public;
  bool _sensitiveContent = false;
  bool _isHidden = false;
  bool _isDeleted = false;

  List<String> _likers = [];
  int _numOfLikes = 0;
  int _numOfComments = 0;
  List<Comment> _comments = [];
  List<MiniProfile> _likes = [];
  String get posterId => _posterId;
  String get postId => _postId;
  DateTime get postedDate => _postedDate;
  int get numOfTopics => _numOfTopics;
  String get userImageUrl => _userImageUrl;
  String get bio => _bio;
  int get numOfLinks => _numOfLinks;
  int get numOfLinkedTos => _numOfLinkedTos;
  String get title => _title;
  String get decription => _description;
  List<String> get postImgUrls => _postImgUrls;
  List<String> get postTopics => _postTopics;
  List<MyVideoPlayer> get postVids => _videos;
  TheVisibility get visibility => _visibility;
  bool get sensitiveContent => _sensitiveContent;
  bool get isHidden => _isHidden;
  bool get isDeleted => _isDeleted;
  List<String> get getLikers => _likers;
  List<Comment> get getComments => _comments;
  List<MiniProfile> get getLikes => _likes;
  int get getNumOfLikes => _numOfLikes;
  int get getNumOfComments => _numOfComments;
  bool showPost = false;

  void addVideos(MyVideoPlayer vid, int index,) {
    _videos.insert(index,vid);
  }

  void deletePost() {
    _isDeleted = true;
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

  void show() {
    showPost = true;
    notifyListeners();
  }

  void setPosterID(String posterID) {
    _posterId = posterID;
  }

  void setPostID(String postID) {
    _postId = postID;
  }

  void setPostedDate(DateTime date) {
    _postedDate = date;
  }

  void setNumOfTopics(int number) {
    _numOfTopics = number;
  }

  void setUserImgUrl(String url) {
    _userImageUrl = url;
  }

  void setBio(String bio) {
    _bio = bio;
  }

  void setNumOfLinks(int numOfLinks) {
    _numOfLinks = numOfLinks;
  }

  void setNumOfLinkedTos(int numOfLinked) {
    _numOfLinkedTos = numOfLinked;
  }

  void setTitle(String title) {
    _title = title;
  }

  void setDescription(String description) {
    _description = description;
  }

  void setTopics(List<String> topics) {
    _postTopics = topics;
  }

  void setImgUrls(List<String> imgUrls) {
    _postImgUrls = imgUrls;
  }

  void setVisibility(TheVisibility vis) {
    _visibility = vis;
  }

  void setSensitiveContent(bool sensitive) {
    _sensitiveContent = sensitive;
  }

  void setNumOfComments(int number) {
    _numOfComments = number;
  }

  void setNumOfLikes(int number) {
    _numOfLikes = number;
  }

  void setComments(List<Comment> comments) {
    _comments = comments;
  }

  void addComments(List<Comment> comments) {
    _comments.addAll(comments);
  }

  void setLikes(List<MiniProfile> likers) {
    _likes = likers;
  }

  void setLikers(List<String> likers) {
    _likers = likers;
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

  likePost(String myusername, String myUserImg) {
    final MiniProfile _myMiniProfile =
        MiniProfile(username: myusername, imgUrl: myUserImg);
    _likers.insert(0, myusername);
    _likes.insert(0, _myMiniProfile);
    _numOfLikes++;
    notifyListeners();
  }

  void unlikePost(String myusername, String myUserImg) {
    final MiniProfile _myMiniProfile =
        MiniProfile(username: myusername, imgUrl: myUserImg);
    _likers.remove(myusername);
    _likes.removeWhere((liker) => liker.username == _myMiniProfile.username);
    _numOfLikes--;
    notifyListeners();
  }
}
