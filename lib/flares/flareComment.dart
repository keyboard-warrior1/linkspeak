import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../providers/commentProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/auth/reportDialog.dart';
import '../widgets/common/chatprofileImage.dart';
import '../widgets/fullPost/commentPreview.dart';
import '../widgets/fullPost/sensitiveComment.dart';

class FlareComment extends StatefulWidget {
  final String flarePoster;
  final String collectionID;
  final String flareID;
  final String commentId;
  final String commenterUsername;
  final String comment;
  final bool isMyFlare;
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
  const FlareComment(
      {required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.commentId,
      required this.handler2,
      required this.handler,
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
      required this.isInReply,
      required this.isMyFlare});

  @override
  State<FlareComment> createState() => _FlareCommentState();
}

class _FlareCommentState extends State<FlareComment>
    with AutomaticKeepAliveClientMixin {
  final firestore = FirebaseFirestore.instance;
  bool _isShown = false;
  Future<void> likeComment(String myUsername, void Function() like) async {
    like();
    final DateTime _rightNow = DateTime.now();
    var batch = firestore.batch();
    final myUser = firestore.collection('Users').doc(myUsername);
    final theseComments = firestore
        .collection('Flares')
        .doc(widget.flarePoster)
        .collection('collections')
        .doc(widget.collectionID)
        .collection('flares')
        .doc(widget.flareID)
        .collection('comments');
    final theComment = theseComments.doc(widget.commentId);
    final myLikedComments = myUser.collection('Liked Flare Comments');
    final myLike = theComment.collection('likes').doc(myUsername);
    batch.set(myLikedComments.doc(widget.commentId), {
      'poster': widget.flarePoster,
      'collectionID': widget.collectionID,
      'flareID': widget.flareID,
      'comment ID': widget.commentId,
      'like date': _rightNow,
    });
    batch.set(myLike, {'date': _rightNow});
    batch.update(theComment, {'likeCount': FieldValue.increment(1)});
    batch.set(myUser, {'flare comments liked': FieldValue.increment(1)},
        SetOptions(merge: true));
    Map<String, dynamic> fields = {
      'flare comment likes': FieldValue.increment(1)
    };
    Map<String, dynamic> docFields = {
      'poster': widget.flarePoster,
      'collection': widget.collectionID,
      'flare': widget.flareID,
      'date': _rightNow,
      'commentID': widget.commentId
    };
    final getMyLike = await myLike.get();
    if (!getMyLike.exists) {
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'flare comment likes',
          docID: '${widget.commentId}',
          docFields: docFields);
      return await batch.commit();
    } else {
      return null;
    }
  }

  Future<void> unlikeComment(String myUsername, void Function() unlike) async {
    unlike();
    var batch = firestore.batch();
    final _now = DateTime.now();
    final theseComments = firestore
        .collection('Flares')
        .doc(widget.flarePoster)
        .collection('collections')
        .doc(widget.collectionID)
        .collection('flares')
        .doc(widget.flareID)
        .collection('comments');
    final theComment = theseComments.doc(widget.commentId);
    final getComment = await theComment.get();
    final myUser = firestore.collection('Users').doc(myUsername);
    final myLikedComments = myUser.collection('Liked Flare Comments');
    final myUnlikedComments =
        myUser.collection('Unliked Flare Comments').doc(widget.commentId);
    final myLike = theComment.collection('likes').doc(myUsername);
    final myUnlike = theComment.collection('unlikes').doc(myUsername);
    final options = SetOptions(merge: true);
    Map<String, dynamic> fields = {
      'flare comment unlikes': FieldValue.increment(1)
    };
    Map<String, dynamic> docFields = {
      'poster': widget.flarePoster,
      'collection': widget.collectionID,
      'flare': widget.flareID,
      'date': _now,
      'commentID': widget.commentId
    };
    batch.delete(myLike);
    batch.set(
        myUnlike, {'date': _now, 'times': FieldValue.increment(1)}, options);
    batch.delete(myLikedComments.doc(widget.commentId));
    batch.set(myUnlikedComments,
        {'times': FieldValue.increment(1), 'date': _now}, options);
    batch.set(
        myUser,
        {
          'flare comments liked': FieldValue.increment(-1),
          'flare comments unliked': FieldValue.increment(1),
        },
        options);
    batch.update(theComment, {'likeCount': FieldValue.increment(-1)});
    if (getComment.exists)
      batch.set(theComment, {'unlikes': FieldValue.increment(1)}, options);
    final getMyLike = await myLike.get();
    if (getMyLike.exists) {
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'flare comment unlikes',
          docID: '${widget.commentId}',
          docFields: docFields);
      return await batch.commit();
    } else {
      return null;
    }
  }

  void _showDialog() {
    final lang = General.language(context);
    final FlareReplyScreenArgs args = FlareReplyScreenArgs(
        flarePoster: widget.flarePoster,
        collectionID: widget.collectionID,
        flareID: widget.flareID,
        commentID: widget.commentId,
        instance: widget.instance,
        commenterName: widget.commenterUsername,
        isNotif: false,
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
                                RouteGenerator.flareCommentReplies,
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
                            context
                                .read<MyProfile>()
                                .getUsername
                                .startsWith('Linkspeak') ||
                            widget.isMyFlare)
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
                                          postID: '',
                                          commentID: widget.commentId,
                                          isInPost: false,
                                          isInComment: true,
                                          isInProfile: false,
                                          isInReply: false,
                                          isInClubScreen: false,
                                          isInSpotlight: true,
                                          spotlightID: widget.flareID,
                                          isClubPost: false,
                                          clubName: '',
                                          collectionID: widget.collectionID,
                                          flarePoster: widget.flarePoster,
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
                                    'Flares/${widget.flarePoster}/collections/${widget.collectionID}/flares/${widget.flareID}/comments/${widget.commentId}';
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
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final Map<String, dynamic> profileDocData = {
      'shown flare comments': FieldValue.increment(1)
    };
    final Map<String, dynamic> profileShownData = {
      'posterID': widget.flarePoster,
      'collectionID': widget.collectionID,
      'flareID': widget.flareID,
      'commentID': widget.commentId,
      'times': FieldValue.increment(1),
      'date': DateTime.now()
    };
    General.showItem(
        documentAddress:
            'Flares/${widget.flarePoster}/collections/${widget.collectionID}/flares/${widget.flareID}/comments/${widget.commentId}',
        itemShownDocAddress:
            'Flares/${widget.flarePoster}/collections/${widget.collectionID}/flares/${widget.flareID}/comments/${widget.commentId}/Shown To/$myUsername',
        profileShownDocAddress:
            'Users/$myUsername/Shown Flare Comments/${widget.commentId}',
        profileAddress: 'Users/$myUsername',
        profileShownData: profileShownData,
        profileDocData: profileDocData);
    Map<String, dynamic> fields = {
      'shown flare comments': FieldValue.increment(1)
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'shown flare comments',
        docID: '${widget.commentId}',
        docFields: profileShownData);
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final themeIconHelper = Provider.of<ThemeModel>(context, listen: false);
    final selectedCensorMode = themeIconHelper.censorMode;
    final locale = themeIconHelper.serverLangCode;
    final String currentIconName = themeIconHelper.selectedIconName;
    final IconData currentIcon = themeIconHelper.themeIcon;
    final Color currentIconColor = themeIconHelper.likeColor;
    final File? inactiveIconPath = themeIconHelper.inactiveLikeFile;
    final File? activeIconPath = themeIconHelper.activeLikeFile;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    String displayName = widget.commenterUsername;
    if (widget.commenterUsername.length > 15)
      displayName = '${widget.commenterUsername.substring(0, 15)}..';
    super.build(context);
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
          final FlareReplyScreenArgs args = FlareReplyScreenArgs(
              flarePoster: widget.flarePoster,
              collectionID: widget.collectionID,
              flareID: widget.flareID,
              commentID: widget.commentId,
              instance: widget.instance,
              commenterName: widget.commenterUsername,
              isNotif: false,
              section: Section.multiple,
              singleReplyID: '');
          final FlareCommentLikesArgs args2 = FlareCommentLikesArgs(
              flarePoster: widget.flarePoster,
              collectionID: widget.collectionID,
              flareID: widget.flareID,
              commentID: widget.commentId,
              instance: widget.instance);
          final ChatProfileImage _commenterImage = ChatProfileImage(
              username: widget.commenterUsername,
              factor: 0.04,
              inEdit: false,
              asset: null);
          final Text _commenterName = Text(displayName,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0));
          final Widget _comment = Column(
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
                        final MediaScreenArgs args = MediaScreenArgs(
                            mediaUrls: [widget.downloadURL],
                            currentIndex: 0,
                            isInComment: true);
                        Navigator.pushNamed(context, RouteGenerator.mediaScreen,
                            arguments: args);
                      },
                      child: Container(
                          color: Colors.grey.shade100,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(3.0),
                              child: Image.network(widget.downloadURL,
                                  height: 275,
                                  width: 550,
                                  fit: BoxFit.cover)))),
                if (widget.containsMedia) const SizedBox(height: 10.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(General.timeStamp(widget.commentDate,locale,context),
                          style: const TextStyle(color: Colors.grey))
                    ])
              ]);
          final ListTile _tile = ListTile(
              key: ValueKey<String>(widget.commentId),
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
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                          const EdgeInsets.all(0.0))),
                  onPressed: (widget.isInReply)
                      ? () {
                          if (widget.commenterUsername !=
                              context.read<MyProfile>().getUsername) {
                            final OtherProfileScreenArguments args =
                                OtherProfileScreenArguments(
                                    otherProfileId: widget.commenterUsername);
                            Navigator.pushNamed(
                                context, RouteGenerator.posterProfileScreen,
                                arguments: args);
                          } else {
                            setState(() {
                              _isShown = false;
                            });
                          }
                        }
                      : _showDialog,
                  child: _commenterImage),
              title: TextButton(
                  style: ButtonStyle(
                      enableFeedback: false,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashFactory: NoSplash.splashFactory,
                      alignment: Alignment.centerLeft,
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                          const EdgeInsets.all(0.0))),
                  onPressed: (widget.isInReply)
                      ? () {
                          if (widget.commenterUsername !=
                              context.read<MyProfile>().getUsername) {
                            final OtherProfileScreenArguments args =
                                OtherProfileScreenArguments(
                                    otherProfileId: widget.commenterUsername);
                            Navigator.pushNamed(
                                context, RouteGenerator.posterProfileScreen,
                                arguments: args);
                          } else {
                            setState(() {
                              _isShown = false;
                            });
                          }
                        }
                      : _showDialog,
                  child: _commenterName),
              subtitle: _comment,
              isThreeLine: false,
              trailing: (!widget.isInReply)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                          Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                if (currentIconName != 'Custom')
                                  GestureDetector(
                                      onTap: () {
                                        if (!_isLiked) {
                                          likeComment(myUsername, like);
                                        } else {
                                          unlikeComment(myUsername, unlike);
                                        }
                                      },
                                      child: Icon(currentIcon,
                                          color: (_isLiked)
                                              ? currentIconColor
                                              : Colors.grey.shade400,
                                          size: 25)),
                                if (currentIconName == 'Custom')
                                  General.constrain(IconButton(
                                      padding: const EdgeInsets.all(0.0),
                                      onPressed: () {
                                        if (!_isLiked) {
                                          likeComment(myUsername, like);
                                        } else {
                                          unlikeComment(myUsername, unlike);
                                        }
                                      },
                                      icon: Image.file((_isLiked)
                                          ? activeIconPath!
                                          : inactiveIconPath!))),
                                const SizedBox(height: 7.0),
                                GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .pushNamed(
                                            RouteGenerator.flareCommentLikes,
                                            arguments: args2),
                                    child: Text(
                                        (_numOfLikes == 0)
                                            ? ''
                                            : '${General.optimisedNumbers(_numOfLikes)}',
                                        style: TextStyle(
                                            color: (_isLiked)
                                                ? currentIconColor
                                                : Colors.grey.shade400)))
                              ]),
                          const SizedBox(width: 12.0),
                          GestureDetector(
                              onTap: () => Navigator.of(context).pushNamed(
                                  RouteGenerator.flareCommentReplies,
                                  arguments: args),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.reply_all_rounded,
                                        color: Colors.grey.shade400, size: 25),
                                    const SizedBox(height: 7.0),
                                    Text(
                                        (_numOfReplies == 0)
                                            ? ''
                                            : '${General.optimisedNumbers(_numOfReplies)}',
                                        style: TextStyle(
                                            color: Colors.grey.shade400))
                                  ]))
                        ])
                  : null);
          return Container(
              key: ValueKey<String>(widget.commentId),
              height: (widget.isInReply && !_isShown) ? 50.0 : null,
              child: (widget.isInReply && !_isShown)
                  ? TextButton(
                      child: Text(lang.flares_comment6),
                      onPressed: () {
                        setState(() {
                          _isShown = true;
                        });
                      },
                    )
                  : Stack(children: [
                      _tile,
                      if (widget.hasNSFW && selectedCensorMode)
                        SensitiveComment(widget.commenterUsername ==
                            context.read<MyProfile>().getUsername)
                    ]));
        }));
  }

  @override
  bool get wantKeepAlive => true;
}
