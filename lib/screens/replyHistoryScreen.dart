import 'package:flutter/material.dart';

import '../my_flutter_app_icons.dart' as customIcons;
import '../routes.dart';
import '../widgets/common/settingsBar.dart';

class ReplyHistoryScreen extends StatelessWidget {
  const ReplyHistoryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                child: Column(children: <Widget>[
          const SettingsBar('My Replies'),
          ListTile(
              horizontalTitleGap: 5.0,
              onTap: () => Navigator.pushNamed(
                  context, RouteGenerator.postCommentReplyHistoryScreen),
              leading: const Icon(customIcons.MyFlutterApp.feed,
                  color: Colors.black),
              title: const Text('Post Comment Replies',
                  style: const TextStyle(color: Colors.black))),
          ListTile(
              horizontalTitleGap: 5.0,
              onTap: () => Navigator.pushNamed(
                  context, RouteGenerator.flareCommentReplyHistoryScreen),
              leading: const Icon(customIcons.MyFlutterApp.spotlight,
                  color: Colors.black),
              title: const Text('Flare Comment Replies',
                  style: const TextStyle(color: Colors.black)))
        ]))));
  }
}
