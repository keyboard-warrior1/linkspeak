import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

class Chat {
  final String userName;
  final String profileImage;
  final Timestamp lastMessageTime;
  final bool isRead;
  final List<Message> messageList;

  String get lastMessage => messageList.first.getMessage;

  Chat(
      {required this.userName,
      required this.profileImage,
      required this.lastMessageTime,
      required this.isRead,
      required this.messageList});
}
