import 'package:flutter/foundation.dart';
import '../models/reply.dart';
import '../models/miniProfile.dart';

class FullCommentHelper with ChangeNotifier {
  bool _isLiked = false;
  int _numOfLikes = 0;
  String _commenter = '';
  int _numOfReplies = 0;
  List<Reply> _replies = [];
  List<MiniProfile> _likes = [];
  int get numOfLikes => _numOfLikes;
  int get numOfReplies => _numOfReplies;
  bool get isLiked => _isLiked;
  List<Reply> get replies => _replies;
  List<MiniProfile> get likes => _likes;
  String get username => _commenter;

  void setLiked(bool liked) {
    _isLiked = liked;
  }

  void setNumOfLikes(int likes) {
    _numOfLikes = likes;
  }

  void setUsername(String name) {
    _commenter = name;
  }

  void setNumOfReplies(int replies) {
    _numOfReplies = replies;
  }

  void setReplies(List<Reply> replies) {
    _replies = replies;
  }

  void setLikes(List<MiniProfile> likes) {
    _likes = likes;
  }

  void likeComment() {
    _isLiked = true;
    _numOfLikes++;
    notifyListeners();
  }

  void unlikeComment() {
    _isLiked = false;
    _numOfLikes--;
    notifyListeners();
  }

  void replyComment(Reply myReply) {
    _replies.insert(0, myReply);
    _numOfReplies++;
    notifyListeners();
  }

  void removeReply(String replyID) {
    _replies.removeWhere((reply) => reply.replyID == replyID);
    _numOfReplies--;
    notifyListeners();
  }
}
