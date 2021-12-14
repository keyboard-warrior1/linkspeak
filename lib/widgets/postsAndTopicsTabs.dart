import 'package:flutter/material.dart';
import 'postsTab.dart';
import 'topicsTab.dart';

class PostsAndTopics extends StatefulWidget {
  const PostsAndTopics({
    Key? key,
    required this.publicProfile,
    required this.imLinkedToThem,
    required this.numOfPosts,
    required this.isMyProfile,
    required this.addTopic,
    required this.removeTopic,
    required this.controller,
    required this.scrollController,
  }) : super(key: key);

  final bool publicProfile;
  final bool imLinkedToThem;
  final int numOfPosts;
  final bool isMyProfile;
  final dynamic addTopic;
  final dynamic removeTopic;
  final TabController? controller;
  final ScrollController scrollController;

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
          BoxConstraints(minHeight: 10, maxHeight: _deviceHeight * 0.85),
      child: TabBarView(
        controller: widget.controller,
        children: <Widget>[
          PostsTab(
            publicProfile: widget.publicProfile,
            imLinkedToThem: widget.imLinkedToThem,
            numberOfPosts: widget.numOfPosts,
            isMyProfile: widget.isMyProfile,
            profileScrollController: widget.scrollController,
          ),
          TopicsTab(
            scrollController: widget.scrollController,
            isMyProfile: widget.isMyProfile,
            publicProfile: widget.publicProfile,
            imLinkedToThem: widget.imLinkedToThem,
            addTopic: widget.addTopic,
            removeTopic: widget.removeTopic,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
