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
                      SettingsBar(lang.admin_mainProfanity1),
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
                            screenName: lang.admin_mainProfanity2),
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
                            screenName: lang.admin_mainProfanity3),
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
                            screenName: lang.admin_mainProfanity4),
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
                            screenName: lang.admin_mainProfanity5),
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
                            screenName: lang.admin_mainProfanity6),
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
                            screenName: lang.admin_mainProfanity7),
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
                            screenName: lang.admin_mainProfanity8),
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
                            screenName: lang.admin_mainProfanity9),
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
                            screenName: lang.admin_mainProfanity10)
                      ])))
                    ]))));
  }
}
