import 'package:flutter/material.dart';

import 'clubAboutTab.dart';
import 'clubPostsTab.dart';
import 'clubTopicsTab.dart';

class ClubTabs extends StatefulWidget {
  final TabController? controller;
  const ClubTabs(this.controller);

  @override
  _ClubTabsState createState() => _ClubTabsState();
}

class _ClubTabsState extends State<ClubTabs>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    super.build(context);
    return ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: 10, maxHeight: _deviceHeight * 0.90),
        child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: widget.controller,
            children: const <Widget>[
              const ClubPosts(),
              const ClubAbout(),
              const ClubTopics()
            ]));
  }

  @override
  bool get wantKeepAlive => true;
}
