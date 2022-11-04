import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../../screens/postScreen.dart';
import '../common/chatprofileImage.dart';

class NewComments extends StatefulWidget {
  final String commentUserName;
  final String postUrl;
  final String clubName;
  final String commentID;
  final DateTime date;
  const NewComments(
      {required this.commentUserName,
      required this.postUrl,
      required this.date,
      required this.clubName,
      required this.commentID});

  @override
  _NewCommentsState createState() => _NewCommentsState();
}

class _NewCommentsState extends State<NewComments> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();

  void _goToPost(final BuildContext context, final ViewMode view,
      dynamic previewSetstate, String clubName) {
    final PostScreenArguments args = PostScreenArguments(
        instance: null,
        viewMode: view,
        previewSetstate: previewSetstate,
        isNotif: true,
        postID: widget.postUrl,
        clubName: clubName,
        section: Section.single,
        singleCommentID: widget.commentID);
    Navigator.pushNamed(context, RouteGenerator.postScreen, arguments: args);
  }

  @override
  void dispose() {
    super.dispose();
    _recognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUsername = context.read<MyProfile>().getUsername;
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
        onTap: () =>
            _goToPost(context, ViewMode.comments, () {}, widget.clubName),
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
              const TextSpan(
                  text: 'commented on your post',
                  style: TextStyle(color: Colors.black))
            ])),
        trailing: Text(General.timeStamp(widget.date),
            style: const TextStyle(color: Colors.grey)));
  }
}
