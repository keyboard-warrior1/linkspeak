import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/themeModel.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/chatprofileImage.dart';

class NewReplies extends StatefulWidget {
  final String commentUserName;
  final String commentOwner;
  final String postUrl;
  final String commentID;
  final DateTime date;
  final String clubName;
  final bool isClubPost;
  final String posterName;
  final bool isFlareReply;
  final String flarePoster;
  final String collectionID;
  final String flareID;
  final String flareReplyID;
  final String replyID;
  const NewReplies(
      {required this.commentUserName,
      required this.commentOwner,
      required this.postUrl,
      required this.commentID,
      required this.date,
      required this.clubName,
      required this.isClubPost,
      required this.posterName,
      required this.isFlareReply,
      required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.flareReplyID,
      required this.replyID});

  @override
  _NewRepliesState createState() => _NewRepliesState();
}

class _NewRepliesState extends State<NewReplies> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();

  @override
  void dispose() {
    super.dispose();
    _recognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final myUsername = context.read<MyProfile>().getUsername;
    final locale =
        Provider.of<ThemeModel>(context, listen: false).serverLangCode;
    void _visitProfile({required final String username}) {
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

    _recognizer.onTap = () => _visitProfile(username: widget.commentUserName);
    return ListTile(
        key: UniqueKey(),
        onTap: () {
          if (widget.isFlareReply) {
            final args = FlareReplyScreenArgs(
                instance: null,
                flarePoster: widget.flarePoster,
                collectionID: widget.collectionID,
                flareID: widget.flareID,
                commentID: widget.commentID,
                commenterName: widget.commentOwner,
                isNotif: true,
                singleReplyID: widget.flareReplyID,
                section: Section.single);
            Navigator.pushNamed(context, RouteGenerator.flareCommentReplies,
                arguments: args);
          } else {
            final CommentRepliesScreenArguments args =
                CommentRepliesScreenArguments(
                    postID: widget.postUrl,
                    commentID: widget.commentID,
                    commenterName: widget.commentOwner,
                    instance: null,
                    isNotif: true,
                    clubName: widget.clubName,
                    isClubPost: widget.isClubPost,
                    posterName: widget.posterName,
                    section: Section.single,
                    singleReplyID: widget.replyID);
            Navigator.of(context).pushNamed(RouteGenerator.commentRepliesScreen,
                arguments: args);
          }
        },
        enabled: true,
        leading: GestureDetector(
            onTap: () => _visitProfile(username: widget.commentUserName),
            child: ChatProfileImage(
                username: '${widget.commentUserName.toString()}',
                factor: 0.05,
                inEdit: false,
                asset: null)),
        title: RichText(
            softWrap: true,
            text: TextSpan(children: [
              TextSpan(
                  recognizer: _recognizer,
                  text: '${widget.commentUserName.toString()} ',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: lang.widgets_alerts14,
                  style: const TextStyle(color: Colors.black))
            ])),
        trailing: Text(General.timeStamp(widget.date, locale, context),
            style: const TextStyle(color: Colors.grey)));
  }
}
