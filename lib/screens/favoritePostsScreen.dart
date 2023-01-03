import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/favScreenScrollProvider.dart';
import '../widgets/common/peopleClubsBar.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/share/shareWidget.dart';
import 'favClubPosts.dart';
import 'favUserPosts.dart';

class FavPostScreen extends StatefulWidget {
  const FavPostScreen();
  static bool shareSheetOpen = false;
  static PersistentBottomSheetController? _shareController;
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
    FavPostScreen.shareSheetOpen = true;
    _shareController!.closed.then((value) {
      FavPostScreen.shareSheetOpen = false;
    });
  }

  @override
  _FavPostScreenState createState() => _FavPostScreenState();
}

class _FavPostScreenState extends State<FavPostScreen>
    with SingleTickerProviderStateMixin {
  late final TabController? _controller;
  final scrollhelper = FavScreenScrollProvider();
  _handleTabSelection() {
    if (_controller!.indexIsChanging) {
      FavPostScreen._shareController!.close();
      FavPostScreen.shareSheetOpen = false;
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
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    const _neverScrollable = NeverScrollableScrollPhysics();
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: null,
        body: SafeArea(
            child: ChangeNotifierProvider.value(
                value: scrollhelper,
                child: SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SettingsBar(lang.screens_favorites),
                          PeopleClubsBar(_controller!),
                          Expanded(
                              child: TabBarView(
                                  physics: _neverScrollable,
                                  controller: _controller,
                                  children: <Widget>[
                                const FavUserPosts(),
                                const FavClubPosts()
                              ]))
                        ])))));
  }
}
