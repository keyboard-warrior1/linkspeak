import 'package:link_speak/models/miniProfile.dart';
import 'package:flutter/foundation.dart';
import '../providers/commentProvider.dart';

class Comment with ChangeNotifier {
  final String commentID;
  final MiniProfile commenter;
  final String comment;
  final String downloadURL;
  final bool containsMedia;
  final DateTime commentDate;
  final int numOfReplies;
  final int numOfLikes;
  final bool isLiked;
  final FullCommentHelper instance;
  final bool hasNSFW;
  Comment({
    required this.comment,
    required this.commenter,
    required this.commentDate,
    required this.commentID,
    required this.numOfReplies,
    required this.instance,
    required this.containsMedia,
    required this.downloadURL,
    required this.numOfLikes,
    required this.isLiked,
    required this.hasNSFW,
  });
}
