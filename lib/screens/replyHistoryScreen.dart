import 'package:flutter/material.dart';

import '../my_flutter_app_icons.dart' as customIcons;
import '../general.dart';
import '../routes.dart';
import '../widgets/common/settingsBar.dart';

class ReplyHistoryScreen extends StatelessWidget {
  const ReplyHistoryScreen();

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                child: Column(children: <Widget>[
          SettingsBar(lang.screens_replyHistory1),
          ListTile(
              horizontalTitleGap: 5.0,
              onTap: () => Navigator.pushNamed(
                  context, RouteGenerator.postCommentReplyHistoryScreen),
              leading: const Icon(customIcons.MyFlutterApp.feed,
                  color: Colors.black),
              title: Text(lang.screens_replyHistory2,
                  style: const TextStyle(color: Colors.black))),
          ListTile(
              horizontalTitleGap: 5.0,
              onTap: () => Navigator.pushNamed(
                  context, RouteGenerator.flareCommentReplyHistoryScreen),
              leading: const Icon(customIcons.MyFlutterApp.spotlight,
                  color: Colors.black),
              title: Text(lang.screens_replyHistory3,
                  style: const TextStyle(color: Colors.black)))
        ]))));
  }
}
