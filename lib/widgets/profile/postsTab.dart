import 'package:flutter/material.dart';

import '../share/shareWidget.dart';
import 'myPostsTab.dart';
import 'otherPostTab.dart';

class PostsTab extends StatefulWidget {
  final bool isMyProfile;
  const PostsTab({required this.isMyProfile});
  static bool shareSheetOpen = false;
  static late PersistentBottomSheetController? _shareController;
  static void sharePost(
      BuildContext context, String postID, String clubName, bool isClubPost) {
    _shareController = showBottomSheet(
      context: context,
      builder: (context) {
        return ShareWidget(
          isInFeed: false,
          bottomSheetController: _shareController,
          postID: postID,
          clubName: clubName,
          isClubPost: isClubPost,
          isFlare: false,
          flarePoster: '',
          collectionID: '',
          flareID: '',
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
  Widget getTab() {
    if (widget.isMyProfile) {
      return const MyPostsTab();
    } else {
      return const OtherPostsTab();
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
