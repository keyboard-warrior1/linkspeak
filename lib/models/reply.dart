import 'miniProfile.dart';

class Reply {
  final String replyID;
  final String reply;
  final String downloadURL;
  final int numOfLikes;
  final bool likedByMe;
  final bool containsMedia;
  final bool hasNSFW;
  final MiniProfile replier;
  final DateTime replyDate;
  const Reply(
      {required this.reply,
      required this.replier,
      required this.numOfLikes,
      required this.replyDate,
      required this.replyID,
      required this.likedByMe,
      required this.downloadURL,
      required this.containsMedia,
      required this.hasNSFW});
}
