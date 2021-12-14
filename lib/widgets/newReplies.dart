import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'chatprofileImage.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../models/screenArguments.dart';
import '../routes.dart';

class NewReplies extends StatefulWidget {
  final String commentUserName;
  final String postUrl;
  final String commentID;
  const NewReplies({
    required this.commentUserName,
    required this.postUrl,
    required this.commentID,
  });

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
          arguments: args,
        );
      }
    }

    final CommentRepliesScreenArguments args = CommentRepliesScreenArguments(
      postID: widget.postUrl,
      commentID: widget.commentID,
      instance: null,
      isNotif: true,
    );
    _recognizer.onTap = () => _visitProfile(username: widget.commentUserName);
    return ListTile(
      key: UniqueKey(),
      onTap: () {
        Navigator.of(context)
            .pushNamed(RouteGenerator.commentRepliesScreen, arguments: args);
      },
      enabled: true,
      leading: GestureDetector(
        onTap: () => _visitProfile(username: widget.commentUserName),
        child: ChatProfileImage(
          username: '${widget.commentUserName.toString()}',
          factor: 0.05,
          inEdit: false,
          asset: null,
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              recognizer: _recognizer,
              text: '${widget.commentUserName.toString()} ',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: 'Replied to your comment',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
