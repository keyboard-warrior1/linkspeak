import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/commentProvider.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/themeModel.dart';
import '../../routes.dart';
import '../auth/reportDialog.dart';
import '../common/chatprofileImage.dart';
import 'commentPreview.dart';
import 'sensitiveComment.dart';

class CommentTile extends StatefulWidget {
  final String postID;
  final String commentId;
  final String commenterUsername;
  final String posterName;
  final String comment;
  final bool isClubPost;
  final bool isMyPost;
  final String clubName;
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
  final bool isInReply;
  final bool isMod;
  const CommentTile(
      {required this.commentId,
      required this.postID,
      required this.handler2,
      required this.handler,
      required this.commenterUsername,
      required this.posterName,
      required this.comment,
      required this.commentDate,
      required this.numOfReplies,
      required this.instance,
      required this.containsMedia,
      required this.downloadURL,
      required this.numOfLikes,
      required this.isLiked,
      required this.hasNSFW,
      required this.isInReply,
      required this.isClubPost,
      required this.clubName,
      required this.isMod,
      required this.isMyPost});

  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile>
    with AutomaticKeepAliveClientMixin {
  final firestore = FirebaseFirestore.instance;
  bool _isShown = false;
  int numLikes = 0;
  bool isLiked = false;
  Future<void> likeComment(String myUsername, void Function() like) async {
    like();
    isLiked = true;
    numLikes++;
    setState(() {});
    final myUser = firestore.collection('Users').doc(myUsername);
    final DateTime _rightNow = DateTime.now();
    var batch = firestore.batch();
    final theComment = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentId);
    final myLikedComments = myUser.collection(
        (widget.isClubPost) ? 'Liked Club Comments' : 'Liked Comments');
    final myLike = theComment.collection('likes').doc(myUsername);
    batch.set(myLikedComments.doc(widget.commentId), {
      'post ID': widget.postID,
      'comment ID': widget.commentId,
      'clubName': widget.clubName,
      'like date': _rightNow,
    });
    batch.set(myLike, {'date': _rightNow});
    batch.update(theComment, {'likeCount': FieldValue.increment(1)});
    batch.set(myUser, {'comments liked': FieldValue.increment(1)},
        SetOptions(merge: true));
    final getMyLike = await myLike.get();
    if (!getMyLike.exists) {
      Map<String, dynamic> fields = {
        if (widget.isClubPost) 'club comment likes': FieldValue.increment(1),
        if (!widget.isClubPost) 'comment likes': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'clubName': widget.clubName,
        'date': _rightNow,
        'postID': widget.postID,
        'commentID': widget.commentId
      };
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName:
              widget.isClubPost ? 'club comment likes' : 'comment likes',
          docID: '${widget.commentId}',
          docFields: docFields);
      return await batch.commit();
    } else {
      return null;
    }
  }

  Future<void> unlikeComment(String myUsername, void Function() unlike) async {
    unlike();
    isLiked = false;
    numLikes--;
    setState(() {});
    var batch = firestore.batch();
    final _now = DateTime.now();
    final theComment = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentId);
    final getComment = await theComment.get();
    final myUser = firestore.collection('Users').doc(myUsername);
    final myLikedComments = myUser.collection(
        (widget.isClubPost) ? 'Liked Club Comments' : 'Liked Comments');
    final myUnlikedComments = myUser
        .collection(
            (widget.isClubPost) ? 'Unliked Club Comments' : 'Unliked Comments')
        .doc(widget.commentId);
    final myLike = theComment.collection('likes').doc(myUsername);
    final myUnlike = theComment.collection('unlikes').doc(myUsername);
    final options = SetOptions(merge: true);
    batch.delete(myLike);
    batch.set(
        myUnlike, {'date': _now, 'times': FieldValue.increment(1)}, options);
    batch.delete(myLikedComments.doc(widget.commentId));
    batch.set(myUnlikedComments,
        {'date': _now, 'times': FieldValue.increment(1)}, options);
    batch.set(
        myUser,
        {
          'comments liked': FieldValue.increment(-1),
          'comments unliked': FieldValue.increment(1)
        },
        options);
    batch.update(theComment, {'likeCount': FieldValue.increment(-1)});
    final getMyLike = await myLike.get();
    if (getComment.exists)
      batch.set(theComment, {'unlikes': FieldValue.increment(1)}, options);
    if (getMyLike.exists) {
      Map<String, dynamic> fields = {
        if (widget.isClubPost) 'club comment unlikes': FieldValue.increment(1),
        if (!widget.isClubPost) 'comment unlikes': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'clubName': widget.clubName,
        'date': _now,
        'postID': widget.postID,
        'commentID': widget.commentId
      };
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName:
              widget.isClubPost ? 'club comment unlikes' : 'comment unlikes',
          docID: '${widget.commentId}',
          docFields: docFields);
      return await batch.commit();
    } else {
      return null;
    }
  }

  void _showDialog() {
    final lang = General.language(context);
    final CommentRepliesScreenArguments args = CommentRepliesScreenArguments(
        postID: widget.postID,
        commentID: widget.commentId,
        instance: widget.instance,
        commenterName: widget.commenterUsername,
        isNotif: false,
        clubName: widget.clubName,
        isClubPost: widget.isClubPost,
        posterName: widget.posterName,
        section: Section.multiple,
        singleReplyID: '');
    showDialog(
        context: context,
        builder: (_) {
          return Center(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white),
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
                            child: Text(lang.flares_comment1,
                                textAlign: TextAlign.start,
                                style: const TextStyle(color: Colors.black))),
                        if (widget.commenterUsername !=
                            context.read<MyProfile>().getUsername)
                          TextButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory),
                              onPressed: widget.handler,
                              child: Text(lang.flares_comment2,
                                  style: const TextStyle(color: Colors.black))),
                        if (widget.commenterUsername ==
                                context.read<MyProfile>().getUsername ||
                            (widget.isClubPost && widget.isMod) ||
                            context
                                .read<MyProfile>()
                                .getUsername
                                .startsWith('Linkspeak') ||
                            widget.isMyPost)
                          TextButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory),
                              onPressed: () {
                                widget.handler2();
                                Navigator.pop(context);
                              },
                              child: Text(lang.flares_comment3,
                                  style: const TextStyle(color: Colors.black))),
                        if (widget.commenterUsername !=
                            context.read<MyProfile>().getUsername)
                          TextButton(
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
                                          isInClubScreen: false,
                                          isInSpotlight: false,
                                          spotlightID: '',
                                          isClubPost: widget.isClubPost,
                                          clubName: widget.clubName,
                                          collectionID: '',
                                          flarePoster: '',
                                          flareProfileID: '',
                                          isInFlareProfile: false);
                                    });
                              },
                              child: Text(lang.flares_comment4,
                                  style: const TextStyle(color: Colors.black))),
                        if (context
                            .read<MyProfile>()
                            .getUsername
                            .startsWith('Linkspeak'))
                          TextButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory),
                              onPressed: () {
                                var docPath =
                                    'Posts/${widget.postID}/comments/${widget.commentId}';
                                General.getAndCopyDetails(
                                    docPath, false, context);
                              },
                              child: Text(lang.flares_comment5,
                                  style: const TextStyle(color: Colors.black)))
                      ])));
        });
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
    isLiked = widget.isLiked;
    numLikes = widget.numOfLikes;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final Map<String, dynamic> profileDocData = {
      'shown comments': FieldValue.increment(1)
    };
    final Map<String, dynamic> profileShownData = {
      'postID': widget.postID,
      'commentID': widget.commentId,
      'times': FieldValue.increment(1),
      'date': DateTime.now()
    };
    General.showItem(
        documentAddress: 'Posts/${widget.postID}/comments/${widget.commentId}',
        itemShownDocAddress:
            'Posts/${widget.postID}/comments/${widget.commentId}/Shown To/$myUsername',
        profileShownDocAddress:
            'Users/$myUsername/Shown Comments/${widget.commentId}',
        profileAddress: 'Users/$myUsername',
        profileShownData: profileShownData,
        profileDocData: profileDocData);
    Map<String, dynamic> fields = {'shown comments': FieldValue.increment(1)};
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'shown comments',
        docID: '${widget.commentId}',
        docFields: profileShownData);
  }

  Widget constrain(Widget child) => ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: 25, maxHeight: 25, minWidth: 25, maxWidth: 25),
      child: Center(
          child:
              FittedBox(fit: BoxFit.scaleDown, child: Center(child: child))));
  @override
  Widget build(BuildContext _) {
    final lang = General.language(context);
    final themeIconHelper = Provider.of<ThemeModel>(_, listen: false);
    final locale = themeIconHelper.serverLangCode;
    final selectedCensorMode = themeIconHelper.censorMode;
    final String currentIconName = themeIconHelper.selectedIconName;
    final IconData currentIcon = themeIconHelper.themeIcon;
    final Color currentIconColor = themeIconHelper.likeColor;
    final File? inactiveIconPath = themeIconHelper.inactiveLikeFile;
    final File? activeIconPath = themeIconHelper.activeLikeFile;
    final String myUsername =
        Provider.of<MyProfile>(_, listen: false).getUsername;
    String displayName = widget.commenterUsername;
    if (widget.commenterUsername.length > 15)
      displayName = '${widget.commenterUsername.substring(0, 15)}..';
    super.build(_);
    return ChangeNotifierProvider<FullCommentHelper>.value(
        value: widget.instance,
        child: Builder(builder: (context) {
          final int _numOfReplies =
              Provider.of<FullCommentHelper>(context).numOfReplies;
          final int _numOfLikes =
              Provider.of<FullCommentHelper>(context).numOfLikes;
          final bool _isLiked = Provider.of<FullCommentHelper>(context).isLiked;
          final void Function() like =
              Provider.of<FullCommentHelper>(context, listen: false)
                  .likeComment;
          final void Function() unlike =
              Provider.of<FullCommentHelper>(context, listen: false)
                  .unlikeComment;
          return Container(
              height: (widget.isInReply && !_isShown) ? 50.0 : null,
              child: (widget.isInReply && !_isShown)
                  ? TextButton(
                      child: Text(lang.flares_comment6),
                      onPressed: () {
                        setState(() {
                          _isShown = true;
                        });
                      })
                  : Stack(children: [
                      ListTile(
                          enabled: true,
                          onTap: (widget.isInReply)
                              ? () {
                                  setState(() {
                                    _isShown = false;
                                  });
                                }
                              : _showDialog,
                          leading: TextButton(
                              style: ButtonStyle(
                                  enableFeedback: false,
                                  splashFactory: NoSplash.splashFactory,
                                  padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry?>(
                                      const EdgeInsets.all(0.0))),
                              onPressed: (widget.isInReply)
                                  ? () {
                                      if (widget.commenterUsername !=
                                          context
                                              .read<MyProfile>()
                                              .getUsername) {
                                        final OtherProfileScreenArguments args =
                                            OtherProfileScreenArguments(
                                                otherProfileId:
                                                    widget.commenterUsername);
                                        Navigator.pushNamed(context,
                                            RouteGenerator.posterProfileScreen,
                                            arguments: args);
                                      } else {
                                        setState(() {
                                          _isShown = false;
                                        });
                                      }
                                    }
                                  : _showDialog,
                              child: ChatProfileImage(
                                  username: widget.commenterUsername,
                                  factor: 0.04,
                                  inEdit: false,
                                  asset: null)),
                          title: TextButton(
                              style: ButtonStyle(
                                  enableFeedback: false,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  splashFactory: NoSplash.splashFactory,
                                  alignment: Alignment.centerLeft,
                                  padding:
                                      MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                          const EdgeInsets.all(0.0))),
                              onPressed: (widget.isInReply)
                                  ? () {
                                      if (widget.commenterUsername !=
                                          context
                                              .read<MyProfile>()
                                              .getUsername) {
                                        final OtherProfileScreenArguments args =
                                            OtherProfileScreenArguments(
                                                otherProfileId:
                                                    widget.commenterUsername);
                                        Navigator.pushNamed(context,
                                            RouteGenerator.posterProfileScreen,
                                            arguments: args);
                                      } else {
                                        setState(() {
                                          _isShown = false;
                                        });
                                      }
                                    }
                                  : _showDialog,
                              child: Text(displayName,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0))),
                          subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommentPreview(
                                    widget.comment,
                                    widget.isInReply,
                                    () => setState(() {
                                          _isShown = false;
                                        })),
                                const SizedBox(height: 10.0),
                                if (widget.containsMedia)
                                  GestureDetector(
                                      onTap: () {
                                        final MediaScreenArgs args =
                                            MediaScreenArgs(
                                                mediaUrls: [widget.downloadURL],
                                                currentIndex: 0,
                                                isInComment: true);
                                        Navigator.pushNamed(
                                            context, RouteGenerator.mediaScreen,
                                            arguments: args);
                                      },
                                      child: Container(
                                          color: Colors.grey.shade100,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(3.0),
                                              child: Image.network(
                                                  widget.downloadURL,
                                                  height: 275,
                                                  width: 550,
                                                  fit: BoxFit.cover)))),
                                if (widget.containsMedia)
                                  const SizedBox(height: 10.0),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          General.timeStamp(widget.commentDate,
                                              locale, context),
                                          style: const TextStyle(
                                              color: Colors.grey))
                                    ])
                              ]),
                          isThreeLine: false,
                          trailing: (!widget.isInReply)
                              ? Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                  Column(
                                      key: ValueKey<String>(widget.commentId),
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        if (currentIconName != 'Custom')
                                          GestureDetector(
                                            onTap: () {
                                              if (!_isLiked) {
                                                likeComment(myUsername, like);
                                              } else {
                                                unlikeComment(
                                                    myUsername, unlike);
                                              }
                                            },
                                            child: Icon(currentIcon,
                                                color: (isLiked)
                                                    ? currentIconColor
                                                    : Colors.grey.shade400,
                                                size: 25),
                                          ),
                                        if (currentIconName == 'Custom')
                                          General.constrain(IconButton(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              onPressed: () {
                                                if (!_isLiked) {
                                                  likeComment(myUsername, like);
                                                } else {
                                                  unlikeComment(
                                                      myUsername, unlike);
                                                }
                                              },
                                              icon: Image.file((isLiked)
                                                  ? activeIconPath!
                                                  : inactiveIconPath!))),
                                        const SizedBox(height: 7.0),
                                        GestureDetector(
                                            onTap: () => Navigator.of(context)
                                                .pushNamed(
                                                    RouteGenerator
                                                        .commentLikesScreen,
                                                    arguments: CommentLikesScreenArgs(
                                                        postID: widget.postID,
                                                        commentID:
                                                            widget.commentId,
                                                        instance:
                                                            widget.instance,
                                                        isClubPost:
                                                            widget.isClubPost,
                                                        clubName:
                                                            widget.clubName)),
                                            child: Text(
                                                (_numOfLikes == 0)
                                                    ? ''
                                                    : '${General.optimisedNumbers(numLikes)}',
                                                style: TextStyle(
                                                    color: (isLiked)
                                                        ? currentIconColor
                                                        : Colors.grey.shade400)))
                                      ]),
                                  const SizedBox(width: 12.0),
                                  GestureDetector(
                                      onTap: () => Navigator.of(context)
                                          .pushNamed(
                                              RouteGenerator
                                                  .commentRepliesScreen,
                                              arguments:
                                                  CommentRepliesScreenArguments(
                                                      postID: widget.postID,
                                                      commentID:
                                                          widget.commentId,
                                                      instance: widget.instance,
                                                      commenterName: widget
                                                          .commenterUsername,
                                                      isNotif: false,
                                                      clubName: widget.clubName,
                                                      isClubPost:
                                                          widget.isClubPost,
                                                      posterName:
                                                          widget.posterName,
                                                      section: Section.multiple,
                                                      singleReplyID: '')),
                                      child:
                                          Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                            Icon(Icons.reply_all_rounded,
                                                color: Colors.grey.shade400,
                                                size: 25),
                                            const SizedBox(height: 7.0),
                                            Text(
                                                (_numOfReplies == 0)
                                                    ? ''
                                                    : '${General.optimisedNumbers(_numOfReplies)}',
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade400))
                                          ]))
                                ])
                              : null),
                      if (widget.hasNSFW && selectedCensorMode)
                        SensitiveComment(widget.commenterUsername ==
                            context.read<MyProfile>().getUsername)
                    ]));
        }));
  }

  @override
  bool get wantKeepAlive => true;
}
