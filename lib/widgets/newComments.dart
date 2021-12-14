import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'chatprofileImage.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../models/screenArguments.dart';
import '../screens/postScreen.dart';
import '../routes.dart';

class NewComments extends StatefulWidget {
  final String commentUserName;
  final String postUrl;
  const NewComments({required this.commentUserName, required this.postUrl});

  @override
  _NewCommentsState createState() => _NewCommentsState();
}

class _NewCommentsState extends State<NewComments> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();

  @override
  void dispose() {
    super.dispose();
    _recognizer.dispose();
  }

  void _goToPost(final BuildContext context, final ViewMode view,
      dynamic previewSetstate) {
    final PostScreenArguments args = PostScreenArguments(
        instance: null,
        viewMode: view,
        previewSetstate: previewSetstate,
        isNotif: true,
        postID: widget.postUrl);

    Navigator.pushNamed(
      context,
      RouteGenerator.postScreen,
      arguments: args,
    );
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

    _recognizer.onTap = () => _visitProfile(username: widget.commentUserName);
    return ListTile(
      key: UniqueKey(),
      onTap: () {
        _goToPost(context, ViewMode.comments, () {});
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
              text: 'commented on your post',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
