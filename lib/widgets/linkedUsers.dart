import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'chatprofileImage.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../models/screenArguments.dart';
import '../routes.dart';

class NewLinks extends StatefulWidget {
  final String userName;

  const NewLinks({required this.userName});

  @override
  _NewLinksState createState() => _NewLinksState();
}

class _NewLinksState extends State<NewLinks> {
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

    _recognizer.onTap = () => _visitProfile(username: widget.userName);
    return ListTile(
      onTap: () => _visitProfile(username: widget.userName),
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
              text: '${widget.userName} ',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: 'is now linked with you',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
