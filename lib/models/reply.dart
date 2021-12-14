
import 'package:link_speak/models/miniProfile.dart';

class Reply {
  final String replyID;
  final String reply;
  final MiniProfile replier;
  final DateTime replyDate;

  const Reply({
    required this.reply,
    required this.replier,
    required this.replyDate,
    required this.replyID,
  });
}
