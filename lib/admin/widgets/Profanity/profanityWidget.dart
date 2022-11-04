import 'package:flutter/material.dart';

import '../../../general.dart';
import '../../../models/screenArguments.dart';
import '../../../routes.dart';
import '../../../screens/postScreen.dart';
import '../../generalAdmin.dart';

class ProfanityWidget extends StatelessWidget {
  final String collectionName;
  final String docAddress;
  final String id;
  final dynamic doc;
  final dynamic isProfileBio;
  final dynamic isClubAbout;
  final dynamic isFlareProfileBio;
  final dynamic isPostDescription;
  final dynamic isPostComments;
  final dynamic isPostCommentReplies;
  final dynamic isFlareComments;
  final dynamic isFlareCommentReplies;
  const ProfanityWidget(
      {required this.collectionName,
      required this.docAddress,
      required this.id,
      required this.doc,
      required this.isProfileBio,
      required this.isClubAbout,
      required this.isFlareProfileBio,
      required this.isPostDescription,
      required this.isPostComments,
      required this.isPostCommentReplies,
      required this.isFlareComments,
      required this.isFlareCommentReplies});
  void Function() actionHandler(BuildContext context) {
    if (isProfileBio) {
      String profileID = doc.get('profile');
      var args = OtherProfileScreenArguments(otherProfileId: profileID);
      return () => Navigator.pushNamed(
          context, RouteGenerator.posterProfileScreen,
          arguments: args);
    }
    if (isClubAbout) {
      String clubID = doc.get('club');
      var args = ClubScreenArgs(clubID);
      return () => Navigator.pushNamed(context, RouteGenerator.clubScreen,
          arguments: args);
    }
    if (isFlareProfileBio) {
      String profileID = doc.get('profile');
      var args = FlareProfileScreenArgs(profileID);
      return () => Navigator.pushNamed(
          context, RouteGenerator.flareProfileScreen,
          arguments: args);
    }
    if (isPostDescription) {
      String postID = doc.get('postID');
      var args = PostScreenArguments(
          viewMode: ViewMode.post,
          instance: null,
          previewSetstate: () {},
          isNotif: true,
          postID: postID,
          clubName: '',
          section: Section.multiple,
          singleCommentID: '');
      return () => Navigator.pushNamed(context, RouteGenerator.postScreen,
          arguments: args);
    }
    if (isPostComments) {
      String commentID = doc.get('commentID');
      String postID = doc.get('postID');
      var args = PostScreenArguments(
          viewMode: ViewMode.comments,
          instance: null,
          previewSetstate: () {},
          isNotif: true,
          postID: postID,
          clubName: '',
          section: Section.single,
          singleCommentID: commentID);
      return () => Navigator.pushNamed(context, RouteGenerator.postScreen,
          arguments: args);
    }
    if (isPostCommentReplies) {
      String postID = doc.get('postID');
      String commentID = doc.get('commentID');
      String replyID = doc.get('replyID');
      String clubName = doc.get('clubName');
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
    if (isFlareComments) {
      String flarePoster = doc.get('poster');
      String collectionID = doc.get('collectionID');
      String flareID = doc.get('flareID');
      String commentID = doc.get('commentID');
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
      String flarePoster = doc.get('poster');
      String collectionID = doc.get('collectionID');
      String flareID = doc.get('flareID');
      String commentID = doc.get('commentID');
      String replyID = doc.get('replyID');
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
    return () {
      var poster = doc.get('poster');
      var args = FlareProfileScreenArgs(poster);
      Navigator.pushNamed(context, RouteGenerator.flareProfileScreen,
          arguments: args);
    };
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
          resolvedCollection: collectionName,
          resolveDocID: id,
          showActionButton: true,
          showCopyButton: true,
          showDeleteButton: true));
}
