import 'package:flutter/foundation.dart';

import '../models/miniProfile.dart';
import '../models/reply.dart';

class FullCommentHelper with ChangeNotifier {
  String _commenter = '';
  int _numOfLikes = 0;
  int _numOfReplies = 0;
  bool _isLiked = false;
  List<Reply> _replies = [];
  List<MiniProfile> _likes = [];
  String get username => _commenter;
  int get numOfLikes => _numOfLikes;
  int get numOfReplies => _numOfReplies;
  bool get isLiked => _isLiked;
  List<Reply> get replies => _replies;
  List<MiniProfile> get likes => _likes;
  void setLiked(bool liked) => _isLiked = liked;
  void setNumOfLikes(int numlikes) => _numOfLikes = numlikes;
  void setUsername(String name) => _commenter = name;
  void setNumOfReplies(int thesereplies) => _numOfReplies = thesereplies;
  void setReplies(List<Reply> thesereplies) => _replies = thesereplies;
  void setLikes(List<MiniProfile> itlikes) => _likes = itlikes;
  void clearReplies() => _replies.clear();
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
