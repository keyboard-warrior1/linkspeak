import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/themeModel.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../../screens/postScreen.dart';
import '../common/chatProfileImage.dart';

class NewMentions extends StatefulWidget {
  final String userName;
  final String postID;
  final String commentID;
  final String replyID;
  final String flareID;
  final String flarePoster;
  final String collectionID;
  final String flareCommentID;
  final String flareReplyID;
  final String commenterName;
  final String clubName;
  final String posterName;
  final bool isClubPost;
  final bool isPost;
  final bool isComment;
  final bool isReply;
  final bool isBio;
  final bool isFlare;
  final bool isFlareComment;
  final bool isFlareReply;
  final bool isFlaresBio;
  final DateTime date;
  const NewMentions(
      {required this.userName,
      required this.postID,
      required this.commentID,
      required this.replyID,
      required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.flareCommentID,
      required this.flareReplyID,
      required this.commenterName,
      required this.posterName,
      required this.clubName,
      required this.isClubPost,
      required this.isPost,
      required this.isComment,
      required this.isReply,
      required this.isBio,
      required this.isFlare,
      required this.isFlareComment,
      required this.isFlareReply,
      required this.isFlaresBio,
      required this.date});
  @override
  _NewMentionsState createState() => _NewMentionsState();
}

class _NewMentionsState extends State<NewMentions> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();
  final TapGestureRecognizer _lastRecognizer = TapGestureRecognizer();

  void _goToPost(
      final BuildContext context,
      final ViewMode view,
      dynamic previewSetstate,
      String clubName,
      Section section,
      String singleCommentID) {
    final PostScreenArguments args = PostScreenArguments(
        instance: null,
        viewMode: view,
        previewSetstate: previewSetstate,
        isNotif: true,
        postID: widget.postID,
        clubName: clubName,
        section: section,
        singleCommentID: singleCommentID);
    Navigator.pushNamed(context, RouteGenerator.postScreen, arguments: args);
  }

  void _visitProfile(
      {required final String username, required final String myUsername}) {
    if ((username == myUsername)) {
    } else {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: username);
      Navigator.pushNamed(
          context,
          (username == myUsername)
              ? RouteGenerator.myProfileScreen
              : RouteGenerator.posterProfileScreen,
          arguments: args);
    }
  }

  String giveLastText() {
    final lang = General.language(context);
    if (widget.isPost) return lang.widgets_alerts9;
    if (widget.isComment || widget.isFlareComment) return lang.widgets_alerts10;
    if (widget.isReply || widget.isFlareReply) return lang.widgets_alerts11;
    if (widget.isBio || widget.isFlaresBio) return lang.widgets_alerts12;
    if (widget.isFlare) return lang.widgets_alerts13;
    return '';
  }

  @override
  void dispose() {
    super.dispose();
    _recognizer.dispose();
    _lastRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final myUsername = context.read<MyProfile>().getUsername;
    final locale =
        Provider.of<ThemeModel>(context, listen: false).serverLangCode;
    void Function() giveHandler() {
      if (widget.isPost)
        return () => _goToPost(context, ViewMode.post, () {}, widget.clubName,
            Section.multiple, '');
      if (widget.isComment)
        return () => _goToPost(context, ViewMode.comments, () {},
            widget.clubName, Section.single, widget.commentID);
      if (widget.isReply) {
        return () {
          final CommentRepliesScreenArguments args =
              CommentRepliesScreenArguments(
                  postID: widget.postID,
                  commentID: widget.commentID,
                  instance: null,
                  isNotif: true,
                  commenterName: widget.commenterName,
                  clubName: widget.clubName,
                  isClubPost: widget.isClubPost,
                  posterName: widget.posterName,
                  section: Section.single,
                  singleReplyID: widget.replyID);
          Navigator.of(context)
              .pushNamed(RouteGenerator.commentRepliesScreen, arguments: args);
        };
      }
      if (widget.isBio)
        return () =>
            _visitProfile(username: widget.userName, myUsername: myUsername);
      if (widget.isFlare) {
        return () {};
      }
      if (widget.isFlareComment) {
        final args = SingleFlareScreenArgs(
            flarePoster: widget.flarePoster,
            collectionID: widget.collectionID,
            flareID: widget.flareID,
            isComment: true,
            isLike: false,
            section: Section.single,
            singleCommentID: widget.flareCommentID);
        return () => Navigator.pushNamed(
            context, RouteGenerator.singleFlareScreen,
            arguments: args);
      }
      if (widget.isFlareReply) {
        final args = FlareReplyScreenArgs(
            instance: null,
            flarePoster: widget.flarePoster,
            collectionID: widget.collectionID,
            flareID: widget.flareID,
            commentID: widget.flareCommentID,
            commenterName: widget.commenterName,
            section: Section.single,
            isNotif: true,
            singleReplyID: widget.flareReplyID);
        return () => Navigator.pushNamed(
            context, RouteGenerator.flareCommentReplies,
            arguments: args);
      }
      if (widget.isFlaresBio) {
        final args = FlareProfileScreenArgs(widget.userName);
        return () => Navigator.pushNamed(
            context, RouteGenerator.flareProfileScreen,
            arguments: args);
      }
      return () {};
    }

    _recognizer.onTap =
        () => _visitProfile(username: widget.userName, myUsername: myUsername);
    _lastRecognizer.onTap = giveHandler();
    return ListTile(
        onTap: giveHandler(),
        enabled: true,
        key: UniqueKey(),
        leading: GestureDetector(
            onTap: () => _visitProfile(
                username: widget.userName, myUsername: myUsername),
            child: ChatProfileImage(
                username: '${widget.userName}',
                factor: 0.05,
                inEdit: false,
                asset: null,
                editUrl: '')),
        title: RichText(
            softWrap: true,
            text: TextSpan(children: [
              TextSpan(
                  recognizer: _recognizer,
                  text: '${widget.userName} ',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: lang.widgets_alerts8,
                  style: const TextStyle(color: Colors.black)),
              TextSpan(
                  text: giveLastText(),
                  recognizer: _lastRecognizer,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))
            ])),
        trailing: Text(General.timeStamp(widget.date, locale, context),
            style: const TextStyle(color: Colors.grey)));
  }
}
