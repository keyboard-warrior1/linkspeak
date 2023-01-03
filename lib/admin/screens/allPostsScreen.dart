import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/common/peopleClubsBar.dart';
import '../../widgets/common/settingsBar.dart';
import '../../widgets/share/shareWidget.dart';
import '../../general.dart';
import '../widgets/All Posts/allPostsTab.dart';

class AllPostsScreen extends StatefulWidget {
  const AllPostsScreen();
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
            flareID: '');
      },
      backgroundColor: Colors.transparent,
    );
    AllPostsScreen.shareSheetOpen = true;
    _shareController!.closed.then((value) {
      AllPostsScreen.shareSheetOpen = false;
    });
  }

  @override
  State<AllPostsScreen> createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen>
    with SingleTickerProviderStateMixin {
  final firestore = FirebaseFirestore.instance;
  late final TabController tabController;
  void handleTabSelection() {
    if (tabController.indexIsChanging) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(handleTabSelection);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.removeListener(() {});
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: height,
                width: width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SettingsBar(General.language(context).admin_allposts),
                      PeopleClubsBar(tabController),
                      Expanded(
                          child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: tabController,
                              children: [
                            const AllPostsTab(false),
                            const AllPostsTab(true)
                          ]))
                    ]))));
  }
}
