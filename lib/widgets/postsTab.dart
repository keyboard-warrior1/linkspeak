import 'package:flutter/material.dart';
import 'shareWidget.dart';
import 'myPostsTab.dart';
import 'otherPostTab.dart';

class PostsTab extends StatefulWidget {
  final int numberOfPosts;
  final bool isMyProfile;
  final bool publicProfile;
  final bool imLinkedToThem;
  final ScrollController profileScrollController;
  const PostsTab({
    required this.numberOfPosts,
    required this.isMyProfile,
    required this.publicProfile,
    required this.imLinkedToThem,
    required this.profileScrollController,
  });
  static ScrollController scrollController = ScrollController();
  static bool shareSheetOpen = false;
  static late PersistentBottomSheetController? _shareController;
  static void sharePost(BuildContext context, String postID) {
    _shareController = showBottomSheet(
      context: context,
      builder: (context) {
        return ShareWidget(
          isInFeed: false,
          bottomSheetController: _shareController,
          postID: postID,
        );
      },
      backgroundColor: Colors.transparent,
    );
    PostsTab.shareSheetOpen = true;
    _shareController!.closed.then((value) {
      PostsTab.shareSheetOpen = false;
    });
  }

  @override
  _PostsTabState createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  void dispose() {
    super.dispose();
  }

  Widget getTab() {
    if (widget.isMyProfile) {
      return MyPostsTab(widget.profileScrollController);
    } else {
      return OtherPostsTab(
        imLinkedToThem: widget.imLinkedToThem,
        publicProfile: widget.publicProfile,
        scrollController: widget.profileScrollController,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return getTab();
  }

  @override
  bool get wantKeepAlive => true;
}
