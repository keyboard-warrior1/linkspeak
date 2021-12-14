import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/chatProfileImage.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../screens/postScreen.dart';
import '../models/screenArguments.dart';
import '../routes.dart';

class NewLikes extends StatefulWidget {
  final String userName;
  final String postUrl;
  const NewLikes({required this.userName, required this.postUrl});

  @override
  _NewLikesState createState() => _NewLikesState();
}

class _NewLikesState extends State<NewLikes> {
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

    _recognizer.onTap = () => _visitProfile(username: widget.userName);
    return ListTile(
      onTap: () {
        _goToPost(context, ViewMode.post, () {});
      },
      enabled: true,
      key: UniqueKey(),
      leading: GestureDetector(
        onTap: () => _visitProfile(username: widget.userName),
        child: ChatProfileImage(
          username: '${widget.userName}',
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
              text: '${widget.userName} ',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: 'liked your post',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
