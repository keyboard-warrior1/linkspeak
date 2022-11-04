import 'package:flutter/material.dart';

import '../../widgets/common/settingsBar.dart';
import '../widgets/Finders/findFAB.dart';
import '../widgets/Generals/generalTabBar.dart';
import '../widgets/Generals/generalTabs.dart';

class GeneralItemsScreen extends StatefulWidget {
  final dynamic numOfTabs;
  final dynamic isProfiles;
  final dynamic isClubs;
  final dynamic isPosts;
  final dynamic isPostComments;
  final dynamic isPostCommentReplies;
  final dynamic isFlares;
  final dynamic isFlareComments;
  final dynamic isFlareCommentReplies;
  final dynamic showReports;
  final dynamic showWatchList;
  final dynamic showBanned;
  final dynamic showProhibited;
  final dynamic showReviewals;
  final dynamic showFab;
  final dynamic findMode;
  const GeneralItemsScreen(
      {required this.numOfTabs,
      required this.isProfiles,
      required this.isClubs,
      required this.isPosts,
      required this.isPostComments,
      required this.isPostCommentReplies,
      required this.isFlares,
      required this.isFlareComments,
      required this.isFlareCommentReplies,
      required this.showReports,
      required this.showWatchList,
      required this.showBanned,
      required this.showProhibited,
      required this.showReviewals,
      required this.showFab,
      required this.findMode});

  @override
  State<GeneralItemsScreen> createState() => _GeneralItemsScreenState();
}

class _GeneralItemsScreenState extends State<GeneralItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String buildBarName() {
    if (widget.isProfiles) return 'Profiles';
    if (widget.isClubs) return 'Clubs';
    if (widget.isPosts) return 'Posts';
    if (widget.isPostComments) return 'Post Comments';
    if (widget.isPostCommentReplies) return 'Post Comment Replies';
    if (widget.isFlares) return 'Flares';
    if (widget.isFlareComments) return 'Flare Comments';
    if (widget.isFlareCommentReplies) return 'Flare Comment Replies';
    return '';
  }

  void handleTabSelection() {
    if (tabController.indexIsChanging) setState(() {});
  }

  @override
  void initState() {
    tabController = TabController(vsync: this, length: widget.numOfTabs);
    tabController.addListener(handleTabSelection);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: (widget.showFab) ? FindFab(widget.findMode) : null,
      floatingActionButtonLocation:
          (widget.showFab) ? FloatingActionButtonLocation.endFloat : null,
      body: SafeArea(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            SettingsBar(buildBarName()),
            GeneralTabBar(
                tabController: tabController,
                showReports: widget.showReports,
                showWatchList: widget.showWatchList,
                showBanned: widget.showBanned,
                showProhibited: widget.showProhibited,
                showReviewals: widget.showReviewals),
            GeneralTabs(
                tabController: tabController,
                isProfiles: widget.isProfiles,
                isClubs: widget.isClubs,
                isPosts: widget.isPosts,
                isPostComments: widget.isPostComments,
                isPostCommentReplies: widget.isPostCommentReplies,
                isFlares: widget.isFlares,
                isFlareComments: widget.isFlareComments,
                isFlareCommentReplies: widget.isFlareCommentReplies,
                showReports: widget.showReports,
                showWatchList: widget.showWatchList,
                showBanned: widget.showBanned,
                showProhibited: widget.showProhibited,
                showReviewals: widget.showReviewals)
          ])));
}
