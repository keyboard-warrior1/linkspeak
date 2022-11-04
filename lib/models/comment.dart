import 'package:flutter/foundation.dart';

import '../providers/commentProvider.dart';
import 'miniProfile.dart';

class Comment with ChangeNotifier {
  final String commentID;
  final String comment;
  final String downloadURL;
  final int numOfReplies;
  final int numOfLikes;
  final bool containsMedia;
  final bool isLiked;
  final bool hasNSFW;
  final DateTime commentDate;
  final FullCommentHelper instance;
  final MiniProfile commenter;
  Comment(
      {required this.comment,
      required this.commenter,
      required this.commentDate,
      required this.commentID,
      required this.numOfReplies,
      required this.instance,
      required this.containsMedia,
      required this.downloadURL,
      required this.numOfLikes,
      required this.isLiked,
      required this.hasNSFW});
}
