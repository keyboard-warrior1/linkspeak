import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
// import '../providers/commentProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/auth/reportDialog.dart';
import '../widgets/common/chatprofileImage.dart';
import '../widgets/fullPost/commentPreview.dart';
import '../widgets/fullPost/sensitiveComment.dart';

class FlareReply extends StatefulWidget {
  final String flarePoster;
  final String collectionID;
  final String flareID;
  final String commentID;
  final String replyID;
  final String replierUsername;
  final String reply;
  final bool liked;
  final int numLikes;
  final DateTime replyDate;
  final bool containsMedia;
  final bool hasNSFW;
  final String downloadURL;
  final dynamic listHandler;
  const FlareReply(
      {required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.commentID,
      required this.replyID,
      required this.replierUsername,
      required this.reply,
      required this.replyDate,
      required this.liked,
      required this.numLikes,
      required this.containsMedia,
      required this.hasNSFW,
      required this.downloadURL,
      required this.listHandler});

  @override
  State<FlareReply> createState() => _FlareReplyState();
}

class _FlareReplyState extends State<FlareReply>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  bool stateLiked = false;
  int stateNumLikes = 0;
  final firestore = FirebaseFirestore.instance;
  Future<void> likeReply(String myUsername) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
        stateLiked = true;
        stateNumLikes++;
      });
      final DateTime _rightNow = DateTime.now();
      var batch = firestore.batch();
      final myUser = firestore.collection('Users').doc(myUsername);
      final thisCollection = firestore
          .collection('Flares')
          .doc(widget.flarePoster)
          .collection('collections')
          .doc(widget.collectionID);
      final thisFlare = thisCollection.collection('flares').doc(widget.flareID);
      final theseComments = thisFlare.collection('comments');
      final theseReplies =
          theseComments.doc(widget.commentID).collection('replies');
      final thisReply = theseReplies.doc(widget.replyID);
      final myLikedReplies = myUser.collection('Liked Flare Replies');
      final myLike = thisReply.collection('likes').doc(myUsername);
      batch.set(myLikedReplies.doc(widget.replyID), {
        'poster': widget.flarePoster,
        'collection ID': widget.collectionID,
        'flare ID': widget.flareID,
        'comment ID': widget.commentID,
        'reply ID': widget.replyID,
        'like date': _rightNow
      });
      batch.set(myLike, {'date': _rightNow});
      batch.update(thisReply, {'likeCount': FieldValue.increment(1)});
      batch.set(myUser, {'flare replies liked': FieldValue.increment(1)},
          SetOptions(merge: true));
      final getMyLike = await myLike.get();
      if (!getMyLike.exists) {
        Map<String, dynamic> fields = {
          'flare reply likes': FieldValue.increment(1)
        };
        Map<String, dynamic> docFields = {
          'poster': widget.flarePoster,
          'collection': widget.collectionID,
          'flare': widget.flareID,
          'date': _rightNow
        };
        General.updateControl(
            fields: fields,
            myUsername: myUsername,
            collectionName: 'flare reply likes',
            docID: '${widget.replyID}',
            docFields: docFields);
        return await batch.commit().then((value) {
          setState(() {
            isLoading = false;
          });
        }).catchError((_) {
          setState(() {
            isLoading = false;
            stateLiked = false;
            stateNumLikes--;
          });
        });
      } else {
        return null;
      }
    }
  }

  Future<void> unlikeReply(String myUsername) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
        stateLiked = false;
        stateNumLikes--;
      });
      var batch = firestore.batch();
      final _now = DateTime.now();
      final thisCollection = firestore
          .collection('Flares')
          .doc(widget.flarePoster)
          .collection('collections')
          .doc(widget.collectionID);
      final thisFlare = thisCollection.collection('flares').doc(widget.flareID);
      final theseComments = thisFlare.collection('comments');
      final theseReplies =
          theseComments.doc(widget.commentID).collection('replies');
      final thisReply = theseReplies.doc(widget.replyID);
      final getReply = await thisReply.get();
      final myUser = firestore.collection('Users').doc(myUsername);
      final myLikedReplies = myUser.collection('Liked Flare Replies');
      final myUnlikedReplies =
          myUser.collection('Unliked Flare Replies').doc(widget.replyID);
      final myLike = thisReply.collection('likes').doc(myUsername);
      final myUnlike = thisReply.collection('unlikes').doc(myUsername);
      final options = SetOptions(merge: true);
      batch.delete(myLike);
      batch.set(
          myUnlike, {'date': _now, 'times': FieldValue.increment(1)}, options);
      batch.delete(myLikedReplies.doc(widget.replyID));
      batch.set(myUnlikedReplies,
          {'date': _now, 'times': FieldValue.increment(1)}, options);
      batch.set(
          myUser,
          {
            'flare replies unliked': FieldValue.increment(1),
            'flare replies liked': FieldValue.increment(-1)
          },
          options);
      batch.update(thisReply, {'likeCount': FieldValue.increment(-1)});
      if (getReply.exists)
        batch.set(thisReply, {'unlikes': FieldValue.increment(1)}, options);
      final getMyLike = await myLike.get();
      if (getMyLike.exists) {
        Map<String, dynamic> fields = {
          'flare reply likes': FieldValue.increment(-1),
          'flare reply unlikes': FieldValue.increment(1)
        };

        Map<String, dynamic> docFields = {
          'poster': widget.flarePoster,
          'collection': widget.collectionID,
          'flare': widget.flareID,
          'date': _now
        };
        General.updateControl(
            fields: fields,
            myUsername: myUsername,
            collectionName: 'flare reply unlikes',
            docID: '${widget.replyID}',
            docFields: docFields);
        return await batch.commit().then((value) {
          setState(() {
            isLoading = false;
          });
        }).catchError((_) {
          setState(() {
            isLoading = false;
            stateLiked = true;
            stateNumLikes++;
          });
        });
      } else {
        return null;
      }
    }
  }

  /*FIX THE ABYSSMAL BUG THAT RUINS THE STATE GAINED BY COMMENTS OR REPLY
      AFTER A COMMENT OR REPLY IS ADDED,
      THE BUG OCCURS IF YOU LIKE OR REPLY TO A COMMENT/REPLY AND THEN ADD OR REMOVE 
      ANOTHER COMMENT/REPLY; THE STATE GAINED FROM LIKING/REPLYING IE: THE ADDED NUM OF LIKES
      OR THE ADDED NUM OF REPLIES IS LOST UPON ADDITION OR REMOVAL OF A COMMENT
      TO THE PREEXISTING LIST OF COMMENTS.*/
  Future<void> removeReply(
    // void Function(String) removeReply,
    String myUsername,
  ) async {
    final lang = General.language(context);
    EasyLoading.show(status: lang.flares_reply1, dismissOnTap: false);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final replierDoc =
        firestore.collection('Users').doc(widget.replierUsername);
    final getReplier = await replierDoc.get();
    final thisProfileDeleted =
        replierDoc.collection('Deleted Flare Replies').doc(widget.replyID);
    final thisCollection = firestore
        .collection('Flares')
        .doc(widget.flarePoster)
        .collection('collections')
        .doc(widget.collectionID);
    final thisFlare = thisCollection.collection('flares').doc(widget.flareID);
    final theseComments = thisFlare.collection('comments');
    final theseReplies =
        theseComments.doc(widget.commentID).collection('replies');
    final _deletedReplies =
        theseComments.doc(widget.commentID).collection('deleted replies');
    final thisDeletedReply =
        firestore.collection('Deleted Replies').doc(widget.replyID);
    final replierDocument =
        firestore.collection('Users').doc(widget.replierUsername);
    var batch = firestore.batch();
    final _now = DateTime.now();
    final currentReply = theseReplies.doc(widget.replyID);
    final getReply = await currentReply.get();
    Map<String, dynamic> replyData = getReply.data()!;
    Map<String, dynamic> de = {'deletedBy': myUsername, 'date deleted': _now};
    replyData.addAll(de);
    final targetComment = theseComments.doc(widget.commentID);
    final getComment = await targetComment.get();
    final commentDeletedReply =
        targetComment.collection('Deleted Replies').doc(widget.replyID);
    final options = SetOptions(merge: true);
    batch.set(commentDeletedReply, {'date': _now, 'by': myUsername});
    batch.set(thisDeletedReply, replyData);
    batch.delete(currentReply);
    batch.set(_deletedReplies.doc(widget.replyID),
        {'id': widget.replyID, 'date': _now, 'deleted by': myUsername});
    batch.set(
        targetComment,
        {
          'replyCount': FieldValue.increment(-1),
          'deleted replies': FieldValue.increment(1)
        },
        options);
    if (widget.replierUsername != myUsername)
      batch
          .update(replierDocument, {'repliesRemoved': FieldValue.increment(1)});
    Map<String, dynamic> fields = {
      'flare replies': FieldValue.increment(-1),
      'deleted flare replies': FieldValue.increment(1)
    };
    Map<String, dynamic> docFields = {
      'flarePoster': widget.flarePoster,
      'collection': widget.collectionID,
      'flare': widget.flareID,
      'comment': widget.commentID,
      'reply': widget.replyID,
      'date': _now
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'deleted flare replies',
        docID: '${widget.replyID}',
        docFields: docFields);
    if (getComment.exists)
      batch.set(
          targetComment, {'deleted replies': FieldValue.increment(1)}, options);
    if (getReplier.exists) {
      batch.set(thisProfileDeleted, {'date': _now, 'by': myUsername}, options);
      batch.set(
          replierDoc,
          {
            'flare replies deleted': FieldValue.increment(1),
            'flare replies': FieldValue.increment(-1)
          },
          options);
    }
    return batch.commit().then((value) {
      // removeReply(widget.replyID);
      widget.listHandler();
      EasyLoading.showSuccess(lang.flares_reply2,
          dismissOnTap: true, duration: const Duration(seconds: 1));
    });
  }

  void _showDialog() {
    // final void Function(String) _removeReply =
    //     Provider.of<FullCommentHelper>(context, listen: false).removeReply;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    showDialog(
        context: context,
        builder: (_) {
          final lang = General.language(context);
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
                        if ((widget.replierUsername !=
                            context.read<MyProfile>().getUsername))
                          TextButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory),
                              onPressed: () {
                                final args = OtherProfileScreenArguments(
                                    otherProfileId: widget.replierUsername);
                                Navigator.pushNamed(
                                    context, RouteGenerator.posterProfileScreen,
                                    arguments: args);
                              },
                              child: Text(lang.flares_reply3,
                                  style: const TextStyle(color: Colors.black))),
                        if (widget.replierUsername ==
                                context.read<MyProfile>().getUsername ||
                            context
                                .read<MyProfile>()
                                .getUsername
                                .startsWith('Linkspeak'))
                          TextButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory),
                              onPressed: () {
                                Navigator.pop(context);
                                removeReply(
                                  // _removeReply,
                                  myUsername,
                                );
                              },
                              child: Text(lang.flares_reply4,
                                  style: const TextStyle(color: Colors.black))),
                        if (widget.replierUsername !=
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
                                          id: widget.replyID,
                                          postID: '',
                                          commentID: widget.commentID,
                                          isInProfile: false,
                                          isInComment: false,
                                          isInPost: false,
                                          isInReply: true,
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
                              child: Text(lang.flares_reply5,
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
                                    'Flares/${widget.flarePoster}/collections/${widget.collectionID}/flares/${widget.flareID}/comments/${widget.commentID}/replies/${widget.replyID}';
                                General.getAndCopyDetails(
                                    docPath, false, context);
                              },
                              child: Text(lang.flares_reply6,
                                  style: const TextStyle(color: Colors.black)))
                      ])));
        });
  }

  @override
  void initState() {
    super.initState();
    stateLiked = widget.liked;
    stateNumLikes = widget.numLikes;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final Map<String, dynamic> profileDocData = {
      'shown flare replies': FieldValue.increment(1)
    };
    final Map<String, dynamic> profileShownData = {
      'posterID': widget.flarePoster,
      'collectionID': widget.collectionID,
      'flareID': widget.flareID,
      'commentID': widget.commentID,
      'replyID': widget.replyID,
      'times': FieldValue.increment(1),
      'date': DateTime.now()
    };
    General.showItem(
        documentAddress:
            'Flares/${widget.flarePoster}/collections/${widget.collectionID}/flares/${widget.flareID}/comments/${widget.commentID}/replies/${widget.replyID}',
        itemShownDocAddress:
            'Flares/${widget.flarePoster}/collections/${widget.collectionID}/flares/${widget.flareID}/comments/${widget.commentID}/replies/${widget.replyID}/Shown To/$myUsername',
        profileShownDocAddress:
            'Users/$myUsername/Shown Flare Replies/${widget.replyID}',
        profileAddress: 'Users/$myUsername',
        profileShownData: profileShownData,
        profileDocData: profileDocData);
    Map<String, dynamic> fields = {
      'shown flare replies': FieldValue.increment(1)
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'shown flare replies',
        docID: '${widget.replyID}',
        docFields: profileShownData);
  }

  @override
  Widget build(BuildContext context) {
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
    String displayName = widget.replierUsername;
    if (widget.replierUsername.length > 15)
      displayName = '${widget.replierUsername.substring(0, 15)}..';
    final ReplyLikesScreenArgs args2 = ReplyLikesScreenArgs(
        postID: '',
        commentID: widget.commentID,
        replyID: widget.replyID,
        isClubPost: false,
        clubName: '',
        isInFlare: true,
        collectionID: widget.collectionID,
        flareID: widget.flareID,
        flarePoster: widget.flarePoster);
    final ChatProfileImage _commenterImage = ChatProfileImage(
        username: widget.replierUsername,
        factor: 0.04,
        inEdit: false,
        asset: null);
    final Text _commenterName = Text(displayName,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0));
    final Widget _comment = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentPreview(widget.reply, false, () {}),
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
                            height: 275, width: 550, fit: BoxFit.cover)))),
          if (widget.containsMedia) const SizedBox(height: 10.0),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(General.timeStamp(widget.replyDate, locale, context),
                    style: const TextStyle(color: Colors.grey))
              ])
        ]);
    final ListTile _tile = ListTile(
        key: ValueKey<String>(widget.replyID),
        enabled: true,
        onTap: _showDialog,
        leading: TextButton(
            style: ButtonStyle(
                enableFeedback: false,
                splashFactory: NoSplash.splashFactory,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    const EdgeInsets.all(0.0))),
            onPressed: _showDialog,
            child: _commenterImage),
        title: TextButton(
            style: ButtonStyle(
                enableFeedback: false,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                splashFactory: NoSplash.splashFactory,
                alignment: Alignment.centerLeft,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    const EdgeInsets.all(0.0))),
            onPressed: _showDialog,
            child: _commenterName),
        trailing: Row(
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
                            if (!stateLiked) {
                              likeReply(myUsername);
                            } else {
                              unlikeReply(myUsername);
                            }
                          },
                          child: Icon(currentIcon,
                              color: (stateLiked)
                                  ? currentIconColor
                                  : Colors.grey.shade400,
                              size: 25)),
                    if (currentIconName == 'Custom')
                      General.constrain(IconButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          if (!stateLiked) {
                            likeReply(myUsername);
                          } else {
                            unlikeReply(myUsername);
                          }
                        },
                        icon: Image.file(
                          (stateLiked) ? activeIconPath! : inactiveIconPath!,
                        ),
                      )),
                    const SizedBox(height: 7.0),
                    GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                            RouteGenerator.replyLikesScreen,
                            arguments: args2),
                        child: Text(
                            (stateNumLikes == 0)
                                ? ''
                                : '${General.optimisedNumbers(stateNumLikes)}',
                            style: TextStyle(
                                color: (stateLiked)
                                    ? currentIconColor
                                    : Colors.grey.shade400)))
                  ])
            ]),
        subtitle: _comment,
        isThreeLine: false);
    super.build(context);
    return Stack(key: ValueKey<String>(widget.replyID), children: [
      _tile,
      if (widget.hasNSFW && selectedCensorMode)
        SensitiveComment(
            widget.replierUsername == context.read<MyProfile>().getUsername)
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
