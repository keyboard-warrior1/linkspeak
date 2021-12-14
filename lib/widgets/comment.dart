import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/commentProvider.dart';
import 'sensitiveComment.dart';
import 'profileImage.dart';
import 'reportDialog.dart';
import 'commentPreview.dart';

class CommentTile extends StatefulWidget {
  final String postID;
  final String commentId;
  final String commenterImageUrl;
  final String commenterUsername;
  final String comment;
  final void Function() handler;
  final Function handler2;
  final DateTime commentDate;
  final int numOfReplies;
  final int numOfLikes;
  final bool isLiked;
  final FullCommentHelper instance;
  final bool containsMedia;
  final String downloadURL;
  final bool hasNSFW;
  const CommentTile({
    required this.commentId,
    required this.postID,
    required this.handler2,
    required this.handler,
    required this.commenterImageUrl,
    required this.commenterUsername,
    required this.comment,
    required this.commentDate,
    required this.numOfReplies,
    required this.instance,
    required this.containsMedia,
    required this.downloadURL,
    required this.numOfLikes,
    required this.isLiked,
    required this.hasNSFW,
  });

  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _showSensitive = false;
  final firestore = FirebaseFirestore.instance;
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
      return '${_difference.inMinutes} minutes';
    } else if (_withinHour && _difference.inMinutes == 1) {
      return '${_difference.inMinutes} minute';
    } else if (_withinDay && _difference.inHours > 1) {
      return '${_difference.inHours} hours';
    } else if (_withinDay && _difference.inHours == 1) {
      return '${_difference.inHours} hour';
    } else if (!_withinMinute && !_withinHour && !_withinDay && _withinYear) {
      return '$_dateNoYear';
    } else {
      return '$_datewithYear';
    }
  }

  String _optimisedNumbers(num value) {
    if (value < 1000) {
      return '${value.toString()}';
    } else if (value >= 1000) {
      num dividedVal = value / 1000;
      return '${dividedVal.toStringAsFixed(1)}K';
    } else if (value >= 1000000) {
      num dividedVal = value / 1000000;
      return '${dividedVal.toStringAsFixed(1)}M';
    } else if (value >= 1000000000) {
      num dividedVal = value / 1000000000;
      return '${dividedVal.toStringAsFixed(1)}B';
    }
    return 'null';
  }

  Future<void> likeComment(String myUsername, void Function() like) async {
    like();
    var batch = firestore.batch();
    final theComment = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentId);
    final myLike = theComment.collection('likes').doc(myUsername);
    batch.set(myLike, {'0': 1});
    batch.update(theComment, {'likeCount': FieldValue.increment(1)});
    final getMyLike = await myLike.get();
    if (!getMyLike.exists) {
      return await batch.commit();
    } else {
      return null;
    }
  }

  Future<void> unlikeComment(String myUsername, void Function() unlike) async {
    unlike();
    var batch = firestore.batch();
    final theComment = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentId);
    final myLike = theComment.collection('likes').doc(myUsername);
    batch.delete(myLike);
    batch.update(theComment, {'likeCount': FieldValue.increment(-1)});
    final getMyLike = await myLike.get();
    if (getMyLike.exists) {
      return await batch.commit();
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<FullCommentHelper>(context, listen: false)
        .setNumOfReplies(widget.numOfReplies);
    Provider.of<FullCommentHelper>(context, listen: false)
        .setUsername(widget.commenterUsername);
    Provider.of<FullCommentHelper>(context, listen: false)
        .setNumOfLikes(widget.numOfLikes);
    Provider.of<FullCommentHelper>(context, listen: false)
        .setLiked(widget.isLiked);
  }

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return ChangeNotifierProvider<FullCommentHelper>.value(
      value: widget.instance,
      child: Builder(builder: (context) {
        final int _numOfReplies =
            Provider.of<FullCommentHelper>(context).numOfReplies;
        final int _numOfLikes =
            Provider.of<FullCommentHelper>(context).numOfLikes;
        final bool _isLiked = Provider.of<FullCommentHelper>(context).isLiked;
        final void Function() like =
            Provider.of<FullCommentHelper>(context, listen: false).likeComment;
        final void Function() unlike =
            Provider.of<FullCommentHelper>(context, listen: false)
                .unlikeComment;
        final CommentRepliesScreenArguments args =
            CommentRepliesScreenArguments(
          postID: widget.postID,
          commentID: widget.commentId,
          instance: widget.instance,
          isNotif: false,
        );
        final CommentLikesScreenArgs args2 = CommentLikesScreenArgs(
          postID: widget.postID,
          commentID: widget.commentId,
          instance: widget.instance,
        );
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
                        TextButton(
                          style: ButtonStyle(
                              splashFactory: NoSplash.splashFactory),
                          onPressed: () => Navigator.of(context).pushNamed(
                              RouteGenerator.commentRepliesScreen,
                              arguments: args),
                          child: const Text(
                            'Reply',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (widget.commenterUsername !=
                            context.read<MyProfile>().getUsername)
                          TextButton(
                            style: ButtonStyle(
                                splashFactory: NoSplash.splashFactory),
                            onPressed: widget.handler,
                            child: const Text(
                              'Visit profile',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        (widget.commenterUsername ==
                                context.read<MyProfile>().getUsername)
                            ? TextButton(
                                style: ButtonStyle(
                                    splashFactory: NoSplash.splashFactory),
                                onPressed: () {
                                  widget.handler2();
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Remove comment',
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
                                        id: widget.commentId,
                                        postID: widget.postID,
                                        commentID: widget.commentId,
                                        isInPost: false,
                                        isInComment: true,
                                        isInProfile: false,
                                        isInReply: false,
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  'Report comment',
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
          username: widget.commenterUsername,
          url: widget.commenterImageUrl,
          factor: 0.05,
          inEdit: false,
          asset: null,
        );
        final Text _commenterName = Text(
          widget.commenterUsername,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          ),
        );
        final Widget _comment = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommentPreview(widget.comment),
            const SizedBox(height: 10.0),
            if (widget.containsMedia)
              Container(
                color: Colors.grey.shade100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: Image.network(
                    widget.downloadURL,
                    height: 275,
                    width: 550,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (widget.containsMedia) const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  timeStamp(widget.commentDate),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onLongPress: () => Navigator.of(context).pushNamed(
                    RouteGenerator.commentLikesScreen,
                    arguments: args2),
                onTap: () {
                  if (!_isLiked) {
                    likeComment(myUsername, like);
                  } else {
                    unlikeComment(myUsername, unlike);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      customIcons.MyFlutterApp.upvote,
                      color: (_isLiked)
                          ? Colors.lightGreenAccent.shade400
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(
                      height: 7.0,
                    ),
                    Text(
                      (_numOfLikes == 0)
                          ? ''
                          : '${_optimisedNumbers(_numOfLikes)}',
                      style: TextStyle(
                          color: (_isLiked)
                              ? Colors.lightGreenAccent.shade400
                              : Colors.grey.shade400),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                    RouteGenerator.commentRepliesScreen,
                    arguments: args),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(
                      height: 7.0,
                    ),
                    Text(
                      (_numOfReplies == 0)
                          ? ''
                          : '${_optimisedNumbers(_numOfReplies)}',
                      style: TextStyle(color: Colors.grey.shade400),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        return Stack(
          children: [
            _tile,
            if (widget.hasNSFW)
              SensitiveComment(widget.commenterUsername ==
                  context.read<MyProfile>().getUsername)
          ],
        );
      }),
    );
  }
}
