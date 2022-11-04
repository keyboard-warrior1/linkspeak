import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../../widgets/common/noglow.dart';
import '../../widgets/common/settingsBar.dart';
import '../widgets/Misc/navigationTile.dart';
import 'findScreen.dart';

class MainAdminScreen extends StatefulWidget {
  const MainAdminScreen();

  @override
  State<MainAdminScreen> createState() => _MainAdminScreenState();
}

class _MainAdminScreenState extends State<MainAdminScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> getStatus;
  bool isUpperManagement = false;
  Future<void> _getStatus(String myUsername) async {
    final getIt = await firestore.doc('Management/$myUsername').get();
    final isManager = getIt.exists;
    if (mounted) setState(() => isUpperManagement = isManager);
  }

  void visitGeneralItems(dynamic args) =>
      Navigator.pushNamed(context, RouteGenerator.generalItems,
          arguments: args);
  @override
  void initState() {
    super.initState();
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    getStatus = _getStatus(myUsername);
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final _height = _size.height;
    final _width = General.widthQuery(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
          height: _height,
          width: _width,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SettingsBar('Admin'),
                Expanded(
                    child: FutureBuilder(
                        future: getStatus,
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return Column(children: <Widget>[
                              const Spacer(),
                              const Center(
                                  child: SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 1.5))),
                              const Spacer()
                            ]);
                          return Noglow(
                              child: ListView(children: <Widget>[
                            NavigationTile(
                                handler: () {
                                  var args = GeneralItemScreenArgs(
                                      numOfTabs: 4,
                                      isProfiles: true,
                                      isClubs: false,
                                      isPosts: false,
                                      isPostComments: false,
                                      isPostCommentReplies: false,
                                      isFlares: false,
                                      isFlareComments: false,
                                      isFlareCommentReplies: false,
                                      showReports: true,
                                      showWatchList: true,
                                      showBanned: true,
                                      showProhibited: false,
                                      showReviewals: true,
                                      showFab: false,
                                      findMode: FindMode.post);
                                  visitGeneralItems(args);
                                },
                                icon: Icons.person,
                                screenName: 'Profiles'),
                            NavigationTile(
                                handler: () {
                                  var args = GeneralItemScreenArgs(
                                      numOfTabs: 4,
                                      isProfiles: false,
                                      isClubs: true,
                                      isPosts: false,
                                      isPostComments: false,
                                      isPostCommentReplies: false,
                                      isFlares: false,
                                      isFlareComments: false,
                                      isFlareCommentReplies: false,
                                      showReports: true,
                                      showWatchList: true,
                                      showBanned: false,
                                      showProhibited: true,
                                      showReviewals: true,
                                      showFab: false,
                                      findMode: FindMode.post);
                                  visitGeneralItems(args);
                                },
                                icon: customIcons.MyFlutterApp.clubs,
                                screenName: 'Clubs'),
                            NavigationTile(
                                handler: () {
                                  var args = GeneralItemScreenArgs(
                                      numOfTabs: 2,
                                      isProfiles: false,
                                      isClubs: false,
                                      isPosts: true,
                                      isPostComments: false,
                                      isPostCommentReplies: false,
                                      isFlares: false,
                                      isFlareComments: false,
                                      isFlareCommentReplies: false,
                                      showReports: true,
                                      showWatchList: false,
                                      showBanned: false,
                                      showProhibited: false,
                                      showReviewals: true,
                                      showFab: true,
                                      findMode: FindMode.post);
                                  visitGeneralItems(args);
                                },
                                icon: customIcons.MyFlutterApp.feed,
                                screenName: 'Posts'),
                            NavigationTile(
                                handler: () {
                                  var args = GeneralItemScreenArgs(
                                      numOfTabs: 2,
                                      isProfiles: false,
                                      isClubs: false,
                                      isPosts: false,
                                      isPostComments: true,
                                      isPostCommentReplies: false,
                                      isFlares: false,
                                      isFlareComments: false,
                                      isFlareCommentReplies: false,
                                      showReports: true,
                                      showWatchList: false,
                                      showBanned: false,
                                      showProhibited: false,
                                      showReviewals: true,
                                      showFab: true,
                                      findMode: FindMode.postComment);
                                  visitGeneralItems(args);
                                },
                                icon: Icons.chat_bubble_rounded,
                                screenName: 'Post Comments'),
                            NavigationTile(
                                handler: () {
                                  var args = GeneralItemScreenArgs(
                                      numOfTabs: 2,
                                      isProfiles: false,
                                      isClubs: false,
                                      isPosts: false,
                                      isPostComments: false,
                                      isPostCommentReplies: true,
                                      isFlares: false,
                                      isFlareComments: false,
                                      isFlareCommentReplies: false,
                                      showReports: true,
                                      showWatchList: false,
                                      showBanned: false,
                                      showProhibited: false,
                                      showReviewals: true,
                                      showFab: true,
                                      findMode: FindMode.postCommentReply);
                                  visitGeneralItems(args);
                                },
                                icon: Icons.reply_rounded,
                                screenName: 'Post Comment Replies'),
                            NavigationTile(
                                handler: () {
                                  var args = GeneralItemScreenArgs(
                                      numOfTabs: 2,
                                      isProfiles: false,
                                      isClubs: false,
                                      isPosts: false,
                                      isPostComments: false,
                                      isPostCommentReplies: false,
                                      isFlares: true,
                                      isFlareComments: false,
                                      isFlareCommentReplies: false,
                                      showReports: true,
                                      showWatchList: false,
                                      showBanned: false,
                                      showProhibited: false,
                                      showReviewals: true,
                                      showFab: true,
                                      findMode: FindMode.flare);
                                  visitGeneralItems(args);
                                },
                                icon: customIcons.MyFlutterApp.spotlight,
                                screenName: 'Flares'),
                            NavigationTile(
                                handler: () {
                                  var args = GeneralItemScreenArgs(
                                      numOfTabs: 2,
                                      isProfiles: false,
                                      isClubs: false,
                                      isPosts: false,
                                      isPostComments: false,
                                      isPostCommentReplies: false,
                                      isFlares: false,
                                      isFlareComments: true,
                                      isFlareCommentReplies: false,
                                      showReports: true,
                                      showWatchList: false,
                                      showBanned: false,
                                      showProhibited: false,
                                      showReviewals: true,
                                      showFab: true,
                                      findMode: FindMode.flareComment);
                                  visitGeneralItems(args);
                                },
                                icon: Icons.comment,
                                screenName: 'Flare Comments'),
                            NavigationTile(
                                handler: () {
                                  var args = GeneralItemScreenArgs(
                                      numOfTabs: 2,
                                      isProfiles: false,
                                      isClubs: false,
                                      isPosts: false,
                                      isPostComments: false,
                                      isPostCommentReplies: false,
                                      isFlares: false,
                                      isFlareComments: false,
                                      isFlareCommentReplies: true,
                                      showReports: true,
                                      showWatchList: false,
                                      showBanned: false,
                                      showProhibited: false,
                                      showReviewals: true,
                                      showFab: true,
                                      findMode: FindMode.flareCommentReply);
                                  visitGeneralItems(args);
                                },
                                icon: Icons.reply_all_rounded,
                                screenName: 'Flare Comment Replies'),
                            NavigationTile(
                                handler: () => Navigator.pushNamed(
                                    context, RouteGenerator.mainProfanity),
                                icon: Icons.abc,
                                screenName: 'Profanity'),
                            if (isUpperManagement)
                              NavigationTile(
                                  handler: () => Navigator.pushNamed(context,
                                      RouteGenerator.mainArchiveScreen),
                                  icon: Icons.archive,
                                  screenName: 'Archives'),
                            if (isUpperManagement)
                              NavigationTile(
                                  handler: () => Navigator.pushNamed(
                                      context, RouteGenerator.mainControl),
                                  icon: Icons.admin_panel_settings_rounded,
                                  screenName: 'Control'),
                            NavigationTile(
                                handler: () {
                                  const args = AdminUserClubScreenArgs(true);
                                  Navigator.pushNamed(
                                      context, RouteGenerator.allUserClubs,
                                      arguments: args);
                                },
                                icon: Icons.person,
                                screenName: 'All Users'),
                            NavigationTile(
                                handler: () {
                                  const args = AdminUserClubScreenArgs(false);
                                  Navigator.pushNamed(
                                      context, RouteGenerator.allUserClubs,
                                      arguments: args);
                                },
                                icon: customIcons.MyFlutterApp.clubs,
                                screenName: 'All Clubs'),
                            NavigationTile(
                                handler: () {
                                  Navigator.pushNamed(
                                      context, RouteGenerator.allPosts);
                                },
                                icon: customIcons.MyFlutterApp.feed,
                                screenName: 'All Posts'),
                            NavigationTile(
                                handler: () {
                                  Navigator.pushNamed(
                                      context, RouteGenerator.adminNewFlares);
                                },
                                icon: customIcons.MyFlutterApp.spotlight,
                                screenName: 'New Flares'),
                            NavigationTile(
                                handler: () {
                                  Navigator.pushNamed(
                                      context, RouteGenerator.adminFeedbacks);
                                },
                                icon: Icons.message_outlined,
                                screenName: 'Feedbacks'),
                            NavigationTile(
                                handler: () {},
                                icon: Icons.live_tv_rounded,
                                screenName: 'Streams')
                          ]));
                        }))
              ]),
        )));
  }
}
