import 'package:flutter/material.dart';

import '../general.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/misc/historyFutureBuilder.dart';

class FlareReplyHistoryScreen extends StatefulWidget {
  const FlareReplyHistoryScreen();

  @override
  State<FlareReplyHistoryScreen> createState() =>
      _FlareReplyHistoryScreenState();
}

class _FlareReplyHistoryScreenState extends State<FlareReplyHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final _size = MediaQuery.of(context).size;
    final _deviceHeight = _size.height;
    final _deviceWidth = General.widthQuery(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
          height: _deviceHeight,
          width: _deviceWidth,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SettingsBar(lang.screens_flareCommentReplyHistory),
                Expanded(
                    child: const HistoryFutureBuilder(
                        isPeopleComments: false,
                        isClubComments: false,
                        isFlareComments: false,
                        isPeoplePostReplies: false,
                        isClubPostReplies: false,
                        isFlareReplies: true))
              ]),
        )));
  }
}
