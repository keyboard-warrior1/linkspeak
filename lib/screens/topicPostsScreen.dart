import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/topicScreenProvider.dart';
import '../widgets/share/shareWidget.dart';
import '../widgets/topics/topicPosts.dart';

class TopicPostsScreen extends StatefulWidget {
  final dynamic topic;
  const TopicPostsScreen(this.topic);
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
    TopicPostsScreen.shareSheetOpen = true;
    _shareController!.closed.then((value) {
      TopicPostsScreen.shareSheetOpen = false;
    });
  }

  @override
  _TopicPostsScreenState createState() => _TopicPostsScreenState();
}

class _TopicPostsScreenState extends State<TopicPostsScreen> {
  final helper = TopicScreenProvider();
  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButton: null,
      appBar: null,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: ChangeNotifierProvider<TopicScreenProvider>.value(
              value: helper,
              child: Builder(builder: (context) {
                Provider.of<TopicScreenProvider>(context, listen: false)
                    .setTopicName(widget.topic);
                return const TopicPosts();
              }))));
}
