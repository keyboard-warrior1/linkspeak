import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/likeScreenScrollProvider.dart';
import '../widgets/common/peopleClubsBar.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/share/shareWidget.dart';
import 'likedClubPosts.dart';
import 'likedUserPosts.dart';

class LikedPostScreen extends StatefulWidget {
  const LikedPostScreen();
  static bool shareSheetOpen = false;
  static PersistentBottomSheetController? _shareController;
  static void sharePost(
    BuildContext context,
    String postID,
    String clubName,
    bool isClubPost,
  ) {
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
            flareID: '');
      },
      backgroundColor: Colors.transparent,
    );
    LikedPostScreen.shareSheetOpen = true;
    _shareController!.closed.then((value) {
      LikedPostScreen.shareSheetOpen = false;
    });
  }

  @override
  _LikedPostScreenState createState() => _LikedPostScreenState();
}

class _LikedPostScreenState extends State<LikedPostScreen>
    with SingleTickerProviderStateMixin {
  late final TabController? _controller;
  final scrollHelper = LikeScreenScrollProvider();
  _handleTabSelection() {
    if (_controller!.indexIsChanging) {
      LikedPostScreen._shareController!.close();
      LikedPostScreen.shareSheetOpen = false;
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
    final lang = General.language(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    const _neverScrollable = NeverScrollableScrollPhysics();
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: null,
        body: SafeArea(
            child: ChangeNotifierProvider.value(
                value: scrollHelper,
                child: SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SettingsBar(lang.screens_likedPosts),
                          PeopleClubsBar(_controller!),
                          Expanded(
                              child: TabBarView(
                                  physics: _neverScrollable,
                                  controller: _controller,
                                  children: <Widget>[
                                const LikedUserPosts(),
                                const LikedClubPosts()
                              ]))
                        ])))));
  }
}
