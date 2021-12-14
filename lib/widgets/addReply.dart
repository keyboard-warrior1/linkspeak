import 'package:flutter/material.dart';
import 'package:link_speak/models/miniProfile.dart';
import 'package:link_speak/models/reply.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/commentProvider.dart';
import '../providers/myProfileProvider.dart';
import 'profileImage.dart';
import 'registrationDialog.dart';

class AddReply extends StatefulWidget {
  final String postID;
  final String commentID;
  const AddReply({required this.postID, required this.commentID});
  @override
  _AddReplyState createState() => _AddReplyState();
}

class _AddReplyState extends State<AddReply> {
  bool isLoading = false;
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _key;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? _validateComment(String? value) {
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return 'Please write a reply';
    }
    if (value.length > 1000) {
      return 'Replies can be between 0-1500 characters long';
    }
    return null;
  }

  _showDialog(IconData icon, Color iconColor, String title, String rule) {
    showDialog(
      context: context,
      builder: (_) => RegistrationDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        rules: rule,
      ),
    );
  }

  Future<void> addReply(String commenter, String _username, String myUserImg,
      String description, void Function(Reply) _replyComment) async {
    setState(() {
      isLoading = true;
    });
    final batch = firestore.batch();
    final currentPostCommentReplies = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentID)
        .collection('replies');

    final myMiniProfile = MiniProfile(username: _username, imgUrl: myUserImg);
    final DateTime rightNow = DateTime.now();
    String _generateCommentId() {
      final DateTime _rightNowUTC = rightNow;
      final String _commentDate =
          '${DateFormat('dMyHmsS').format(_rightNowUTC)}';
      final String _theID = '$_username-$_commentDate';
      return _theID;
    }

    final lasthour = rightNow.subtract(const Duration(minutes: 60));
    final myComments = await currentPostCommentReplies
        .where('replier', isEqualTo: _username)
        .get();
    final myCommentsHour = myComments.docs;
    var lastHourComments = [];
    for (var comment in myCommentsHour) {
      var commentDate = comment.get('date').toDate();
      Duration diff = commentDate.difference(lasthour);
      if (diff.inMinutes >= 0 && diff.inMinutes <= 60) {
        lastHourComments.add(comment);
      } else {}
    }
    if (lastHourComments.length >= 30) {
      setState(() {
        isLoading = false;
      });
      _showDialog(
        Icons.info_outline,
        Colors.blue,
        'Notice',
        "Users can add up to 30 replies hourly on a comment",
      );
    } else {
      final targetUser =
          await firestore.collection('Users').doc(commenter).get();
      final token = targetUser.get('fcm');
      final replyID = _generateCommentId();
      final Reply myReply = Reply(
          replier: myMiniProfile,
          reply: description,
          replyDate: rightNow,
          replyID: replyID);
      final targetReply = currentPostCommentReplies.doc(replyID);
      final targetComment = firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('comments')
          .doc(widget.commentID);

      batch.set(targetReply, {
        'date': rightNow,
        'description': description,
        'likeCount': 0,
        'replier': _username,
      });
      batch.update(targetComment, {'replyCount': FieldValue.increment(1)});
      return batch.commit().then((value) async {
        var secondBatch = firestore.batch();
        final otherRepliesNotifs = firestore
            .collection('Users')
            .doc(commenter)
            .collection('CommentRepliesNotifs');
        if (targetUser.data()!.containsKey('AllowReplies')) {
          final allowReplies = targetUser.get('AllowReplies');
          if (allowReplies) {
            if (commenter != _username) {
              secondBatch.set(otherRepliesNotifs.doc(), {
                'post': widget.postID,
                'comment': widget.commentID,
                'user': _username,
                'token': token,
              });
              secondBatch.update(firestore.collection('Users').doc(commenter),
                  {'numOfCommentRepliesNotifs': FieldValue.increment(1)});
              // final _commentReplyDoc = firestore
              //     .collection('Users')
              //     .doc(commenter.toString())
              //     .collection('PostCommentsNotifs')
              //     .doc(_username);
              // secondBatch.set(_commentReplyDoc,
              //     {'post': widget.postID, 'description': description});
              secondBatch.commit();
            }
          }
        } else {
          if (commenter != _username) {
            secondBatch.set(otherRepliesNotifs.doc(), {
              'post': widget.postID,
              'comment': widget.commentID,
              'user': _username,
              'token': token,
            });
            secondBatch.update(firestore.collection('Users').doc(commenter),
                {'numOfCommentRepliesNotifs': FieldValue.increment(1)});
            // final _commentReplyDoc = firestore
            //     .collection('Users')
            //     .doc(commenter.toString())
            //     .collection('PostCommentsNotifs')
            //     .doc(_username);
            // secondBatch.set(_commentReplyDoc,
            //     {'post': widget.postID, 'description': description});
            secondBatch.commit();
          }
        }
        _controller.clear();
        _replyComment(myReply);
        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _key = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final _myProfile = context.read<MyProfile>();
    final Color _primarySwatch = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    final String _image = _myProfile.getProfileImage;
    final String _username = _myProfile.getUsername;
    final String myUserImg = _myProfile.getProfileImage;
    final void Function(Reply) _replyComment =
        Provider.of<FullCommentHelper>(context, listen: false).replyComment;
    final String _commenter =
        Provider.of<FullCommentHelper>(context, listen: false).username;
    final ProfileImage _userImage = ProfileImage(
      username: _username,
      url: _image,
      factor: 0.08,
      inEdit: false,
      asset: null,
    );
    final Widget _userInput = Container(
      width: double.infinity,
      child: TextFormField(
        maxLength: 1500,
        controller: _controller,
        validator: _validateComment,
        decoration: InputDecoration(
          hintText: 'Write a reply..',
          counterText: '',
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          filled: true,
          fillColor: Colors.grey.shade300,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        onFieldSubmitted: (_) {
          FocusScope.of(context).unfocus();
          if (isLoading) {
          } else {
            if (_key.currentState!.validate()) {
              addReply(_commenter, _username, myUserImg, _controller.value.text,
                  _replyComment);
            } else {}
          }
        },
      ),
    );
    final Widget _addReply = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color?>(
              _primarySwatch,
            ),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
              const EdgeInsets.all(0.0),
            ),
            shape: MaterialStateProperty.all<OutlinedBorder?>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (isLoading) {
            } else {
              if (_key.currentState!.validate()) {
                addReply(_commenter, _username, myUserImg,
                    _controller.value.text, _replyComment);
              } else {}
            }
          },
          child: (isLoading)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: CircularProgressIndicator(color: _accentColor)),
                )
              : Center(
                  child: Text(
                    'Reply',
                    style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ],
    );
    final ListTile _preview = ListTile(
      leading: _userImage,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _userInput,
      ),
      subtitle: _addReply,
    );
    return Form(
      key: _key,
      child: Container(
        padding: const EdgeInsets.all(3.0),
        child: _preview,
      ),
    );
  }
}
