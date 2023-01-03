import 'package:flutter/material.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../routes.dart';
import '../../widgets/common/noglow.dart';
import '../../widgets/common/settingsBar.dart';
import '../widgets/Misc/navigationTile.dart';
import 'archiveFindScreen.dart';

class MainArchiveScreen extends StatelessWidget {
  const MainArchiveScreen();

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final _height = _size.height;
    final _width = General.widthQuery(context);
    final lang = General.language(context);
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
                      SettingsBar(lang.admin_mainArchive1),
                      Expanded(
                          child: Noglow(
                              child: ListView(children: <Widget>[
                        NavigationTile(
                            handler: () {
                              var args = ArchiveItemScreenArgs(
                                  deletedPosts: true,
                                  deletedComments: false,
                                  deletedReplies: false,
                                  deletedUsers: false,
                                  deletedFlareProfiles: false,
                                  deletedFlares: false,
                                  unbannedUsers: false,
                                  unprohibitedClubs: false,
                                  disabledClubs: false,
                                  showFinder: true,
                                  findMode: ArchiveFindMode.deletedPost);
                              Navigator.pushNamed(
                                  context, RouteGenerator.archiveItems,
                                  arguments: args);
                            },
                            icon: customIcons.MyFlutterApp.feed,
                            screenName: lang.admin_mainArchive2),
                        NavigationTile(
                            handler: () {
                              var args = ArchiveItemScreenArgs(
                                  deletedPosts: false,
                                  deletedComments: true,
                                  deletedReplies: false,
                                  deletedUsers: false,
                                  deletedFlareProfiles: false,
                                  deletedFlares: false,
                                  unbannedUsers: false,
                                  unprohibitedClubs: false,
                                  disabledClubs: false,
                                  showFinder: true,
                                  findMode: ArchiveFindMode.deletedComment);
                              Navigator.pushNamed(
                                  context, RouteGenerator.archiveItems,
                                  arguments: args);
                            },
                            icon: Icons.chat_bubble_rounded,
                            screenName: lang.admin_mainArchive3),
                        NavigationTile(
                            handler: () {
                              var args = ArchiveItemScreenArgs(
                                  deletedPosts: false,
                                  deletedComments: false,
                                  deletedReplies: true,
                                  deletedUsers: false,
                                  deletedFlareProfiles: false,
                                  deletedFlares: false,
                                  unbannedUsers: false,
                                  unprohibitedClubs: false,
                                  disabledClubs: false,
                                  showFinder: true,
                                  findMode: ArchiveFindMode.deletedReply);
                              Navigator.pushNamed(
                                  context, RouteGenerator.archiveItems,
                                  arguments: args);
                            },
                            icon: Icons.reply_all_rounded,
                            screenName: lang.admin_mainArchive4),
                        NavigationTile(
                            handler: () {
                              var args = ArchiveItemScreenArgs(
                                  deletedPosts: false,
                                  deletedComments: false,
                                  deletedReplies: false,
                                  deletedUsers: false,
                                  deletedFlareProfiles: false,
                                  deletedFlares: true,
                                  unbannedUsers: false,
                                  unprohibitedClubs: false,
                                  disabledClubs: false,
                                  showFinder: true,
                                  findMode: ArchiveFindMode.deletedFlare);
                              Navigator.pushNamed(
                                  context, RouteGenerator.archiveItems,
                                  arguments: args);
                            },
                            icon: customIcons.MyFlutterApp.spotlight,
                            screenName: lang.admin_mainArchive5),
                        NavigationTile(
                            handler: () {
                              var args = ArchiveItemScreenArgs(
                                  deletedPosts: false,
                                  deletedComments: false,
                                  deletedReplies: false,
                                  deletedUsers: true,
                                  deletedFlareProfiles: false,
                                  deletedFlares: false,
                                  unbannedUsers: false,
                                  unprohibitedClubs: false,
                                  disabledClubs: false,
                                  showFinder: true,
                                  findMode: ArchiveFindMode.deletedUser);
                              Navigator.pushNamed(
                                  context, RouteGenerator.archiveItems,
                                  arguments: args);
                            },
                            icon: Icons.delete,
                            screenName: lang.admin_mainArchive6),
                        NavigationTile(
                            handler: () {
                              var args = ArchiveItemScreenArgs(
                                  deletedPosts: false,
                                  deletedComments: false,
                                  deletedReplies: false,
                                  deletedUsers: false,
                                  deletedFlareProfiles: true,
                                  deletedFlares: false,
                                  unbannedUsers: false,
                                  unprohibitedClubs: false,
                                  disabledClubs: false,
                                  showFinder: true,
                                  findMode:
                                      ArchiveFindMode.deletedFlareProfile);
                              Navigator.pushNamed(
                                  context, RouteGenerator.archiveItems,
                                  arguments: args);
                            },
                            icon: Icons.delete,
                            screenName: lang.admin_mainArchive7),
                        NavigationTile(
                            handler: () {
                              var args = ArchiveItemScreenArgs(
                                  deletedPosts: false,
                                  deletedComments: false,
                                  deletedReplies: false,
                                  deletedUsers: false,
                                  deletedFlareProfiles: false,
                                  deletedFlares: false,
                                  unbannedUsers: true,
                                  unprohibitedClubs: false,
                                  disabledClubs: false,
                                  showFinder: false,
                                  findMode:
                                      ArchiveFindMode.deletedFlareProfile);
                              Navigator.pushNamed(
                                  context, RouteGenerator.archiveItems,
                                  arguments: args);
                            },
                            icon: Icons.person_add,
                            screenName: lang.admin_mainArchive8),
                        NavigationTile(
                            handler: () {
                              var args = ArchiveItemScreenArgs(
                                  deletedPosts: false,
                                  deletedComments: false,
                                  deletedReplies: false,
                                  deletedUsers: false,
                                  deletedFlareProfiles: false,
                                  deletedFlares: false,
                                  unbannedUsers: false,
                                  unprohibitedClubs: true,
                                  disabledClubs: false,
                                  showFinder: false,
                                  findMode:
                                      ArchiveFindMode.deletedFlareProfile);
                              Navigator.pushNamed(
                                  context, RouteGenerator.archiveItems,
                                  arguments: args);
                            },
                            icon: customIcons.MyFlutterApp.clubs,
                            screenName: lang.admin_mainArchive9),
                        NavigationTile(
                            handler: () {
                              var args = ArchiveItemScreenArgs(
                                  deletedPosts: false,
                                  deletedComments: false,
                                  deletedReplies: false,
                                  deletedUsers: false,
                                  deletedFlareProfiles: false,
                                  deletedFlares: false,
                                  unbannedUsers: false,
                                  unprohibitedClubs: false,
                                  disabledClubs: true,
                                  showFinder: false,
                                  findMode:
                                      ArchiveFindMode.deletedFlareProfile);
                              Navigator.pushNamed(
                                  context, RouteGenerator.archiveItems,
                                  arguments: args);
                            },
                            icon: customIcons.MyFlutterApp.clubs,
                            screenName: lang.admin_mainArchive10)
                      ])))
                    ]))));
  }
}
