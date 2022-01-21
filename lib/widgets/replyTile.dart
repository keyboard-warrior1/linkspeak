import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../providers/commentProvider.dart';
import '../providers/myProfileProvider.dart';
import 'profileImage.dart';
import 'reportDialog.dart';
import 'commentPreview.dart';

class ReplyTile extends StatelessWidget {
  final String postID;
  final String commentID;
  final String replyID;
  final String replierImageUrl;
  final String replierUsername;
  final String reply;
  final DateTime replyDate;

  const ReplyTile({
    required this.postID,
    required this.commentID,
    required this.replyID,
    required this.replierImageUrl,
    required this.replierUsername,
    required this.reply,
    required this.replyDate,
  });
  String timeStamp(DateTime postedDate) {
    final String _datewithYear = DateFormat('MMMM d yyyy').format(postedDate);
    final String _dateNoYear = DateFormat('MMMM d').format(postedDate);
    final Duration _difference = DateTime.now().difference(postedDate);
    final bool _withinMinute =
        _difference <= const Duration(seconds: 59, milliseconds: 999);
    final bool _withinHour = _difference <=
        const Duration(minutes: 59, seconds: 59, milliseconds: 999);
    final bool _withinDay = _difference <=
        const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999);
    final bool _withinYear = _difference <=
        const Duration(days: 364, minutes: 59, seconds: 59, milliseconds: 999);

    if (_withinMinute) {
      return 'a few seconds';
    } else if (_withinHour && _difference.inMinutes > 1) {
      return '~ ${_difference.inMinutes} minutes';
    } else if (_withinHour && _difference.inMinutes == 1) {
      return '~ ${_difference.inMinutes} minute';
    } else if (_withinDay && _difference.inHours > 1) {
      return '~ ${_difference.inHours} hours';
    } else if (_withinDay && _difference.inHours == 1) {
      return '~ ${_difference.inHours} hour';
    } else if (!_withinMinute && !_withinHour && !_withinDay && _withinYear) {
      return '$_dateNoYear';
    } else {
      return '$_datewithYear';
    }
  }

  Future<void> removeReply(void Function(String) removeReply) {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final thisDeletedReply =
        firestore.collection('Deleted Replies').doc(replyID);
    var batch = firestore.batch();
    final currentReply = firestore
        .collection('Posts')
        .doc(postID)
        .collection('comments')
        .doc(commentID)
        .collection('replies')
        .doc(replyID);
    final targetComment = firestore
        .collection('Posts')
        .doc(postID)
        .collection('comments')
        .doc(commentID);
    batch.set(thisDeletedReply, {
      'post': postID,
      'comment': commentID,
      'description': reply,
      'likeCount': 0,
      'user': replierUsername,
      'date': replyDate,
      'date deleted': DateTime.now(),
    });
    batch.delete(currentReply);
    batch.update(targetComment, {'replyCount': FieldValue.increment(-1)});
    return batch.commit().then((value) {
      removeReply(replyID);
      EasyLoading.showSuccess('Reply removed', dismissOnTap: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final void Function(String) _removeReply =
        Provider.of<FullCommentHelper>(context, listen: false).removeReply;
    void _showDialog() {
      showDialog(
          context: context,
          builder: (_) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if ((replierUsername !=
                        context.read<MyProfile>().getUsername))
                      TextButton(
                        style:
                            ButtonStyle(splashFactory: NoSplash.splashFactory),
                        onPressed: () {},
                        child: const Text(
                          'Visit profile',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    (replierUsername == context.read<MyProfile>().getUsername)
                        ? TextButton(
                            style: ButtonStyle(
                                splashFactory: NoSplash.splashFactory),
                            onPressed: () {
                              Navigator.pop(context);
                              removeReply(_removeReply);
                            },
                            child: const Text(
                              'Remove reply',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          )
                        : TextButton(
                            style: ButtonStyle(
                                splashFactory: NoSplash.splashFactory),
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ReportDialog(
                                    id: replyID,
                                    postID: postID,
                                    commentID: commentID,
                                    isInProfile: false,
                                    isInComment: false,
                                    isInPost: false,
                                    isInReply: true,
                                  );
                                },
                              );
                            },
                            child: const Text(
                              'Report reply',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          )
                  ],
                ),
              ),
            );
          });
    }

    final ProfileImage _commenterImage = ProfileImage(
      username: replierUsername,
      url: replierImageUrl,
      factor: 0.06,
      inEdit: false,
      asset: null,
    );
    final Text _commenterName = Text(
      replierUsername,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 17.0,
      ),
    );
    final Widget _comment = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentPreview(reply),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              timeStamp(replyDate),
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        )
      ],
    );
    final ListTile _tile = ListTile(
      key: UniqueKey(),
      enabled: true,
      onTap: _showDialog,
      leading: TextButton(
        style: ButtonStyle(
          enableFeedback: false,
          splashFactory: NoSplash.splashFactory,
          padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
            const EdgeInsets.all(0.0),
          ),
        ),
        onPressed: _showDialog,
        child: _commenterImage,
      ),
      title: TextButton(
        style: ButtonStyle(
          enableFeedback: false,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          splashFactory: NoSplash.splashFactory,
          alignment: Alignment.centerLeft,
          padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
            const EdgeInsets.all(0.0),
          ),
        ),
        onPressed: _showDialog,
        child: _commenterName,
      ),
      subtitle: _comment,
      isThreeLine: false,
    );
    return _tile;
  }
}
