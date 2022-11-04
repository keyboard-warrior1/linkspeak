import 'package:flutter/material.dart';

import '../../../general.dart';
import '../../../models/screenArguments.dart';
import '../../../routes.dart';
import '../../../screens/postScreen.dart';
import '../../generalAdmin.dart';

class GeneralWidget extends StatelessWidget {
  final String collectionName;
  final String docAddress;
  final String id;
  final dynamic doc;
  final bool? paramshowActionButton;
  final bool? paramshowCopyButton;
  final bool? paramshowDeleteButton;
  final dynamic paramactionHandler;
  final bool isProfiles;
  final bool isClubs;
  final bool isPosts;
  final bool isPostComments;
  final bool isPostCommentReplies;
  final bool isFlares;
  final bool isFlareComments;
  final bool isFlareCommentReplies;
  final bool inReports;
  final bool inWatchlist;
  final bool inProhibited;
  final bool inBanned;
  final bool inReview;
  const GeneralWidget(
      {required this.collectionName,
      required this.docAddress,
      required this.id,
      required this.doc,
      required this.isProfiles,
      required this.isClubs,
      required this.isPosts,
      required this.isPostComments,
      required this.isPostCommentReplies,
      required this.isFlares,
      required this.isFlareComments,
      required this.isFlareCommentReplies,
      required this.inReports,
      required this.inWatchlist,
      required this.inProhibited,
      required this.inBanned,
      required this.inReview,
      this.paramshowActionButton,
      this.paramshowCopyButton,
      this.paramshowDeleteButton,
      this.paramactionHandler});
  void Function() actionHandler(BuildContext context) {
    if (paramactionHandler != null) return paramactionHandler;
    if (isProfiles) {
      String profileID = '';
      if (inReports)
        profileID = doc.get('user');
      else
        profileID = id;
      var args = OtherProfileScreenArguments(otherProfileId: profileID);
      return () => Navigator.pushNamed(
          context, RouteGenerator.posterProfileScreen,
          arguments: args);
    }
    if (isClubs) {
      String clubID = '';
      if (inReports)
        clubID = doc.get('clubName');
      else
        clubID = id;
      var args = ClubScreenArgs(clubID);
      return () => Navigator.pushNamed(context, RouteGenerator.clubScreen,
          arguments: args);
    }
    if (isPosts) {
      String postID = '';
      var clubName = doc.get('clubName');
      if (inReports)
        postID = doc.get('post');
      else
        postID = id;
      var args = PostScreenArguments(
          viewMode: ViewMode.post,
          instance: null,
          previewSetstate: () {},
          isNotif: true,
          postID: postID,
          clubName: clubName,
          section: Section.multiple,
          singleCommentID: '');
      return () => Navigator.pushNamed(context, RouteGenerator.postScreen,
          arguments: args);
    }
    if (isPostComments) {
      String commentID = '';
      String postID = '';
      String clubName = doc.get('clubName');
      if (inReports) {
        commentID = doc.get('comment');
        postID = doc.get('post');
      } else {
        commentID = id;
        postID = doc.get('ID');
      }
      var args = PostScreenArguments(
          viewMode: ViewMode.comments,
          instance: null,
          previewSetstate: () {},
          isNotif: true,
          postID: postID,
          clubName: clubName,
          section: Section.single,
          singleCommentID: commentID);
      return () => Navigator.pushNamed(context, RouteGenerator.postScreen,
          arguments: args);
    }
    if (isPostCommentReplies) {
      String postID = '';
      String commentID = '';
      String replyID = '';
      String clubName = '';
      if (inReports) {
        postID = doc.get('post');
        commentID = doc.get('comment');
        replyID = doc.get('reply');
        clubName = doc.get('clubName');
      } else {
        postID = doc.get('ID');
        commentID = doc.get('commentID');
        replyID = doc.get('replyID');
        clubName = doc.get('clubName');
      }
      var args = CommentRepliesScreenArguments(
          isNotif: true,
          instance: null,
          commenterName: '',
          isClubPost: clubName != '',
          posterName: '',
          postID: postID,
          commentID: commentID,
          clubName: clubName,
          section: Section.single,
          singleReplyID: replyID);
      return () => Navigator.pushNamed(
          context, RouteGenerator.commentRepliesScreen,
          arguments: args);
    }
    if (isFlares) {
      String flarePoster = '';
      String collectionID = '';
      String flareID = '';
      if (inReports) {
        flarePoster = doc.get('flarePoster');
        collectionID = doc.get('collection');
        flareID = doc.get('flare');
      } else {
        flarePoster = doc.get('poster');
        collectionID = doc.get('collectionID');
        flareID = doc.get('flareID');
      }
      var args = SingleFlareScreenArgs(
          flarePoster: flarePoster,
          collectionID: collectionID,
          flareID: flareID,
          isComment: false,
          isLike: false,
          section: Section.multiple,
          singleCommentID: '');
      return () => Navigator.pushNamed(
          context, RouteGenerator.singleFlareScreen,
          arguments: args);
    }
    if (isFlareComments) {
      String flarePoster = '';
      String collectionID = '';
      String flareID = '';
      String commentID = '';
      if (inReports) {
        flarePoster = doc.get('flarePoster');
        collectionID = doc.get('collection');
        flareID = doc.get('flare');
        commentID = doc.get('comment');
      } else {
        flarePoster = doc.get('flarePoster');
        collectionID = doc.get('collectionID');
        flareID = doc.get('flareID');
        commentID = doc.get('commentID');
      }
      var args = SingleFlareScreenArgs(
          flarePoster: flarePoster,
          collectionID: collectionID,
          flareID: flareID,
          isComment: true,
          isLike: false,
          section: Section.single,
          singleCommentID: commentID);
      return () => Navigator.pushNamed(
          context, RouteGenerator.singleFlareScreen,
          arguments: args);
    }
    if (isFlareCommentReplies) {
      String flarePoster = '';
      String collectionID = '';
      String flareID = '';
      String commentID = '';
      String replyID = '';
      if (inReports) {
        flarePoster = doc.get('flarePoster');
        collectionID = doc.get('collection');
        flareID = doc.get('flare');
        commentID = doc.get('comment');
        replyID = doc.get('reply');
      } else {
        flarePoster = doc.get('flarePoster');
        collectionID = doc.get('collectionID');
        flareID = doc.get('flareID');
        commentID = doc.get('commentID');
        replyID = doc.get('replyID');
      }
      var args = FlareReplyScreenArgs(
          instance: null,
          flarePoster: flarePoster,
          collectionID: collectionID,
          flareID: flareID,
          commentID: commentID,
          commenterName: '',
          isNotif: true,
          section: Section.single,
          singleReplyID: replyID);
      return () => Navigator.pushNamed(
          context, RouteGenerator.flareCommentReplies,
          arguments: args);
    }
    return () {};
  }

  bool showActionButton() {
    if (paramshowActionButton != null) return paramshowActionButton!;
    return true;
  }

  bool showCopyButton() {
    if (paramshowCopyButton != null) return paramshowCopyButton!;
    return true;
  }

  bool showDeleteButton() {
    if (paramshowDeleteButton != null) return paramshowDeleteButton!;
    return true;
  }

  @override
  Widget build(BuildContext context) => TextButton(
      key: UniqueKey(),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Text(id)]),
      onPressed: () => GeneralAdmin.displayDocDetails(
          context: context,
          doc: doc,
          actionLabel: 'CHECK',
          actionHandler: actionHandler(context),
          docAddress: docAddress,
          resolveDocID: id,
          resolvedCollection: collectionName,
          showActionButton: showActionButton(),
          showCopyButton: showCopyButton(),
          showDeleteButton: showDeleteButton()));
}
