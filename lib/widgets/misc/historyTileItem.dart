import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../routes.dart';
import '../../screens/postScreen.dart';
import '../common/chatProfileImage.dart';
import '../fullPost/commentPreview.dart';

class HistoryTileItem extends StatefulWidget {
  final QueryDocumentSnapshot item;
  final bool isPeopleComments;
  final bool isClubComments;
  final bool isFlareComments;
  final bool isPeoplePostReplies;
  final bool isClubPostReplies;
  final bool isFlareReplies;
  const HistoryTileItem(
      {required this.item,
      required this.isPeopleComments,
      required this.isClubComments,
      required this.isFlareComments,
      required this.isPeoplePostReplies,
      required this.isClubPostReplies,
      required this.isFlareReplies});

  @override
  State<HistoryTileItem> createState() => _HistoryTileItemState();
}

class _HistoryTileItemState extends State<HistoryTileItem> {
  dynamic getter(String field) => widget.item.get(field);
  String postID = '';
  String postPoster = '';

  String flarePoster = '';
  String collectionID = '';
  String flareID = '';

  String replyCommenter = '';
  String postCommentReplyPoster = '';
  String postCommentReplyCommentID = '';
  String flareCommentReplyCommentID = '';

  String commenter = '';
  String description = '';
  DateTime date = DateTime.now();
  bool containsMedia = false;
  String downloadURL = '';
  String clubName = '';
  void visitPostComments(
      {required String postID,
      required String clubName,
      required String singleCommentID}) {
    final args = PostScreenArguments(
        viewMode: ViewMode.comments,
        instance: null,
        previewSetstate: () {},
        isNotif: true,
        postID: postID,
        clubName: clubName,
        section: Section.single,
        singleCommentID: singleCommentID);
    Navigator.pushNamed(context, RouteGenerator.postScreen, arguments: args);
  }

  void visitPostCommentReplies(
      {required String postID,
      required String commentID,
      required String commenterName,
      required bool isClubPost,
      required String clubName,
      required String posterName,
      required String singleReplyID}) {
    final args = CommentRepliesScreenArguments(
        instance: null,
        postID: postID,
        commentID: commentID,
        isNotif: true,
        commenterName: commenterName,
        isClubPost: isClubPost,
        clubName: clubName,
        posterName: posterName,
        section: Section.single,
        singleReplyID: singleReplyID);
    Navigator.of(context)
        .pushNamed(RouteGenerator.commentRepliesScreen, arguments: args);
  }

  void visitFlareComments(
      {required String flarePoster,
      required String collectionID,
      required String flareID,
      required String singleCommentID}) {
    final args = SingleFlareScreenArgs(
        flarePoster: flarePoster,
        collectionID: collectionID,
        flareID: flareID,
        isComment: true,
        isLike: false,
        section: Section.single,
        singleCommentID: singleCommentID);
    Navigator.pushNamed(context, RouteGenerator.singleFlareScreen,
        arguments: args);
  }

  void visitFlareReplies(
      {required String flarePoster,
      required String collectionID,
      required String flareID,
      required String commentID,
      required String commentOwner,
      required String flareReplyID}) {
    final args = FlareReplyScreenArgs(
        instance: null,
        flarePoster: flarePoster,
        collectionID: collectionID,
        flareID: flareID,
        commentID: commentID,
        commenterName: commentOwner,
        isNotif: true,
        singleReplyID: flareReplyID,
        section: Section.single);
    Navigator.pushNamed(context, RouteGenerator.flareCommentReplies,
        arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final String itemID = widget.item.id;
    description = getter('description');
    date = getter('date').toDate();
    containsMedia = getter('containsMedia');
    downloadURL = getter('downloadURL');
    if (widget.isPeopleComments || widget.isClubComments) {
      postID = getter('post ID');
      postPoster = getter('poster');
      commenter = getter('commenter');
      clubName = getter('clubName');
    }
    if (widget.isFlareComments) {
      flarePoster = getter('flarePoster');
      collectionID = getter('collectionID');
      flareID = getter('flare ID');
      commenter = getter('commenter');
    }
    if (widget.isPeoplePostReplies || widget.isClubPostReplies) {
      postID = getter('post ID');
      postCommentReplyCommentID = getter('comment ID');
      replyCommenter = getter('commenter');
      commenter = getter('replier');
      clubName = getter('clubName');
      postCommentReplyPoster = getter('poster');
    }
    if (widget.isFlareReplies) {
      flarePoster = getter('poster');
      collectionID = getter('collectionID');
      flareID = getter('flareID');
      flareCommentReplyCommentID = getter('comment ID');
      commenter = getter('replier');
      replyCommenter = getter('commenter');
    }

    void Function() giveHandler() {
      if (widget.isPeopleComments || widget.isClubComments)
        return () => visitPostComments(
            clubName: clubName, postID: postID, singleCommentID: itemID);

      if (widget.isFlareComments)
        return () => visitFlareComments(
            flarePoster: flarePoster,
            collectionID: collectionID,
            flareID: flareID,
            singleCommentID: itemID);
      if (widget.isPeoplePostReplies || widget.isClubPostReplies)
        return () => visitPostCommentReplies(
            postID: postID,
            commentID: postCommentReplyCommentID,
            posterName: postCommentReplyPoster,
            commenterName: replyCommenter,
            singleReplyID: itemID,
            clubName: clubName,
            isClubPost: clubName != '');
      if (widget.isFlareReplies)
        return () => visitFlareReplies(
            flarePoster: flarePoster,
            collectionID: collectionID,
            flareID: flareID,
            commentID: flareCommentReplyCommentID,
            flareReplyID: itemID,
            commentOwner: replyCommenter);
      return () {};
    }

    return ListTile(
        enabled: true,
        onTap: giveHandler(),
        leading: TextButton(
            style: ButtonStyle(
                enableFeedback: false,
                splashFactory: NoSplash.splashFactory,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    const EdgeInsets.all(0.0))),
            onPressed: giveHandler(),
            child: ChatProfileImage(
                username: commenter, factor: 0.04, inEdit: false, asset: null)),
        title: TextButton(
            style: ButtonStyle(
                enableFeedback: false,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                splashFactory: NoSplash.splashFactory,
                alignment: Alignment.centerLeft,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    const EdgeInsets.all(0.0))),
            onPressed: giveHandler(),
            child: Text(commenter,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0))),
        subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommentPreview(description, false, () {}),
              const SizedBox(height: 10.0),
              if (containsMedia)
                GestureDetector(
                    onTap: () {
                      final MediaScreenArgs args = MediaScreenArgs(
                          mediaUrls: [downloadURL],
                          currentIndex: 0,
                          isInComment: true);
                      Navigator.pushNamed(context, RouteGenerator.mediaScreen,
                          arguments: args);
                    },
                    child: Container(
                        color: Colors.grey.shade100,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(3.0),
                            child: Image.network(downloadURL,
                                height: 275, width: 550, fit: BoxFit.cover)))),
              if (containsMedia) const SizedBox(height: 10.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(General.timeStamp(date),
                        style: const TextStyle(color: Colors.grey))
                  ])
            ]),
        isThreeLine: false,
        trailing: null);
  }
}
