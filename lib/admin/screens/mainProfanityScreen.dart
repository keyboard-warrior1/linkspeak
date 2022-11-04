import 'package:flutter/material.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../routes.dart';
import '../../widgets/common/noglow.dart';
import '../../widgets/common/settingsBar.dart';
import '../widgets/Misc/navigationTile.dart';

class MainProfanityScreen extends StatelessWidget {
  const MainProfanityScreen();

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
                      const SettingsBar('Profanity'),
                      Expanded(
                          child: Noglow(
                              child: ListView(children: <Widget>[
                        NavigationTile(
                            handler: () {
                              var args = ProfanityItemScreenArgs(
                                  isProfileBio: true,
                                  isClubAbout: false,
                                  isFlareProfileBio: false,
                                  isPostDescription: false,
                                  isPostComments: false,
                                  isPostCommentReplies: false,
                                  isFlareComments: false,
                                  isFlareCommentReplies: false);
                              Navigator.pushNamed(
                                  context, RouteGenerator.profanityItems,
                                  arguments: args);
                            },
                            icon: Icons.person,
                            screenName: 'Profile Bios'),
                        NavigationTile(
                            handler: () {
                              var args = ProfanityItemScreenArgs(
                                  isProfileBio: false,
                                  isClubAbout: true,
                                  isFlareProfileBio: false,
                                  isPostDescription: false,
                                  isPostComments: false,
                                  isPostCommentReplies: false,
                                  isFlareComments: false,
                                  isFlareCommentReplies: false);
                              Navigator.pushNamed(
                                  context, RouteGenerator.profanityItems,
                                  arguments: args);
                            },
                            icon: customIcons.MyFlutterApp.clubs,
                            screenName: 'Club Descriptions'),
                        NavigationTile(
                            handler: () {
                              var args = ProfanityItemScreenArgs(
                                  isProfileBio: false,
                                  isClubAbout: false,
                                  isFlareProfileBio: true,
                                  isPostDescription: false,
                                  isPostComments: false,
                                  isPostCommentReplies: false,
                                  isFlareComments: false,
                                  isFlareCommentReplies: false);
                              Navigator.pushNamed(
                                  context, RouteGenerator.profanityItems,
                                  arguments: args);
                            },
                            icon: customIcons.MyFlutterApp.spotlight,
                            screenName: 'Flare Profile Bios'),
                        NavigationTile(
                            handler: () {
                              var args = ProfanityItemScreenArgs(
                                  isProfileBio: false,
                                  isClubAbout: false,
                                  isFlareProfileBio: false,
                                  isPostDescription: true,
                                  isPostComments: false,
                                  isPostCommentReplies: false,
                                  isFlareComments: false,
                                  isFlareCommentReplies: false);
                              Navigator.pushNamed(
                                  context, RouteGenerator.profanityItems,
                                  arguments: args);
                            },
                            icon: customIcons.MyFlutterApp.feed,
                            screenName: 'Post Descriptions'),
                        NavigationTile(
                            handler: () {
                              var args = ProfanityItemScreenArgs(
                                  isProfileBio: false,
                                  isClubAbout: false,
                                  isFlareProfileBio: false,
                                  isPostDescription: false,
                                  isPostComments: true,
                                  isPostCommentReplies: false,
                                  isFlareComments: false,
                                  isFlareCommentReplies: false);
                              Navigator.pushNamed(
                                  context, RouteGenerator.profanityItems,
                                  arguments: args);
                            },
                            icon: Icons.chat_bubble_outline_rounded,
                            screenName: 'Post Comments'),
                        NavigationTile(
                            handler: () {
                              var args = ProfanityItemScreenArgs(
                                  isProfileBio: false,
                                  isClubAbout: false,
                                  isFlareProfileBio: false,
                                  isPostDescription: false,
                                  isPostComments: false,
                                  isPostCommentReplies: true,
                                  isFlareComments: false,
                                  isFlareCommentReplies: false);
                              Navigator.pushNamed(
                                  context, RouteGenerator.profanityItems,
                                  arguments: args);
                            },
                            icon: Icons.reply_rounded,
                            screenName: 'Post Comment Replies'),
                        NavigationTile(
                            handler: () {
                              var args = ProfanityItemScreenArgs(
                                  isProfileBio: false,
                                  isClubAbout: false,
                                  isFlareProfileBio: false,
                                  isPostDescription: false,
                                  isPostComments: false,
                                  isPostCommentReplies: false,
                                  isFlareComments: false,
                                  isFlareCommentReplies: false);
                              Navigator.pushNamed(
                                  context, RouteGenerator.profanityItems,
                                  arguments: args);
                            },
                            icon: customIcons.MyFlutterApp.spotlight,
                            screenName: 'Flare Collection Titles'),
                        NavigationTile(
                            handler: () {
                              var args = ProfanityItemScreenArgs(
                                  isProfileBio: false,
                                  isClubAbout: false,
                                  isFlareProfileBio: false,
                                  isPostDescription: false,
                                  isPostComments: false,
                                  isPostCommentReplies: false,
                                  isFlareComments: true,
                                  isFlareCommentReplies: false);
                              Navigator.pushNamed(
                                  context, RouteGenerator.profanityItems,
                                  arguments: args);
                            },
                            icon: Icons.comment,
                            screenName: 'Flare Comments'),
                        NavigationTile(
                            handler: () {
                              var args = ProfanityItemScreenArgs(
                                  isProfileBio: false,
                                  isClubAbout: false,
                                  isFlareProfileBio: false,
                                  isPostDescription: false,
                                  isPostComments: false,
                                  isPostCommentReplies: false,
                                  isFlareComments: false,
                                  isFlareCommentReplies: true);
                              Navigator.pushNamed(
                                  context, RouteGenerator.profanityItems,
                                  arguments: args);
                            },
                            icon: Icons.reply_all_rounded,
                            screenName: 'Flare Comment Replies')
                      ])))
                    ]))));
  }
}
