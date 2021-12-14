import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String description;
  final String user;
  final bool isRead;
  final bool isPost;
  final bool isDeleted;
  final Timestamp date;

  String get getMessage => description;

  Message({
    required this.id,
    required this.description,
    required this.user,
    required this.date,
    required this.isRead,
    required this.isPost,
    required this.isDeleted,
  });
}
