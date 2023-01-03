import 'package:flutter/material.dart';

import 'postsTab.dart';
import 'topicsTab.dart';

class PostsAndTopics extends StatefulWidget {
  final bool isMyProfile;
  final TabController? controller;
  const PostsAndTopics({required this.isMyProfile, required this.controller});
  @override
  _PostsAndTopicsState createState() => _PostsAndTopicsState();
}

class _PostsAndTopicsState extends State<PostsAndTopics>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    super.build(context);
    return ConstrainedBox(
      constraints:
          BoxConstraints(minHeight: 10, maxHeight: _deviceHeight * 0.94),
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: widget.controller,
        children: <Widget>[
          PostsTab(isMyProfile: widget.isMyProfile),
          TopicsTab(isMyProfile: widget.isMyProfile),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
