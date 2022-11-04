import 'package:flutter/material.dart';

import '../general.dart';
import '../widgets/common/peopleClubsBar.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/misc/historyFutureBuilder.dart';

class PostCommentHistoryScreen extends StatefulWidget {
  const PostCommentHistoryScreen();

  @override
  State<PostCommentHistoryScreen> createState() =>
      _PostCommentHistoryScreenState();
}

class _PostCommentHistoryScreenState extends State<PostCommentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController? _controller;
  _handleTabSelection() {
    if (_controller!.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _controller?.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.removeListener(() {});
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final _deviceHeight = _size.height;
    final _deviceWidth = General.widthQuery(context);
    const _neverScrollable = NeverScrollableScrollPhysics();
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: null,
        body: SafeArea(
            child: SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SettingsBar('Post Comments'),
                      PeopleClubsBar(_controller!),
                      Expanded(
                          child: TabBarView(
                              physics: _neverScrollable,
                              controller: _controller,
                              children: <Widget>[
                            const HistoryFutureBuilder(
                                isPeopleComments: true,
                                isClubComments: false,
                                isFlareComments: false,
                                isPeoplePostReplies: false,
                                isClubPostReplies: false,
                                isFlareReplies: false),
                            const HistoryFutureBuilder(
                                isPeopleComments: false,
                                isClubComments: true,
                                isFlareComments: false,
                                isPeoplePostReplies: false,
                                isClubPostReplies: false,
                                isFlareReplies: false)
                          ]))
                    ]))));
  }
}
