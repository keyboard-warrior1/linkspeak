import 'package:flutter/material.dart';

import '../general.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../routes.dart';
import '../widgets/common/settingsBar.dart';

class CommentHistoryScreen extends StatelessWidget {
  const CommentHistoryScreen();

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                child: Column(children: <Widget>[
          SettingsBar(lang.screens_commentHistory1),
          ListTile(
              horizontalTitleGap: 5.0,
              onTap: () => Navigator.pushNamed(
                  context, RouteGenerator.postCommentHistoryScreen),
              leading: const Icon(customIcons.MyFlutterApp.feed,
                  color: Colors.black),
              title: Text(lang.screens_commentHistory2,
                  style: const TextStyle(color: Colors.black))),
          ListTile(
              horizontalTitleGap: 5.0,
              onTap: () => Navigator.pushNamed(
                  context, RouteGenerator.flareCommentHistoryScreen),
              leading: const Icon(customIcons.MyFlutterApp.spotlight,
                  color: Colors.black),
              title: Text(lang.screens_commentHistory3,
                  style: const TextStyle(color: Colors.black)))
        ]))));
  }
}
