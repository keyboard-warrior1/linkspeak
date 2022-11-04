import 'package:flutter/material.dart';

import '../general.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/misc/historyFutureBuilder.dart';

class FlareCommentHistoryScreen extends StatefulWidget {
  const FlareCommentHistoryScreen();

  @override
  State<FlareCommentHistoryScreen> createState() =>
      _FlareCommentHistoryScreenState();
}

class _FlareCommentHistoryScreenState extends State<FlareCommentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
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
                const SettingsBar('Flare Comments'),
                Expanded(
                    child: const HistoryFutureBuilder(
                        isPeopleComments: false,
                        isClubComments: false,
                        isFlareComments: true,
                        isPeoplePostReplies: false,
                        isClubPostReplies: false,
                        isFlareReplies: false))
              ]),
        )));
  }
}
