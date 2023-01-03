import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/clubProvider.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/nestedScroller.dart';
import '../widgets/topics/topicChip.dart';
import 'privateClub.dart';

class ClubTopics extends StatelessWidget {
  const ClubTopics();
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final isAdmin = myUsername.startsWith('Linkspeak');
    final _club = Provider.of<ClubProvider>(context, listen: false);
    final ScrollController screenController =
        Provider.of<ClubProvider>(context, listen: false)
            .getScreenScrollController;
    final List<String> topics = _club.clubTopics;
    final ClubVisibility clubVisibility = _club.clubVisibility;
    final bool isDisabled = _club.isDisabled;
    final bool isBanned = _club.isBanned;
    final bool isProhibited = _club.isProhibited;
    final bool _isPrivate = clubVisibility == ClubVisibility.private;
    final bool _isHidden = clubVisibility == ClubVisibility.hidden;
    final bool isMember = _club.isJoined;
    final Widget privateClub =
        PrivateClub(icon: Icons.lock_outlined, message: lang.clubs_topics1);
    final Widget prohibitedClub = PrivateClub(
        icon: customIcons.MyFlutterApp.radio_1_, message: lang.clubs_topics2);
    final Widget disabledClub = PrivateClub(
        icon: customIcons.MyFlutterApp.clubs, message: lang.clubs_topics3);
    final Widget bannedClub = PrivateClub(
        icon: customIcons.MyFlutterApp.no_stopping,
        message: lang.clubs_topics4);
    final Widget hiddenClub = PrivateClub(
        icon: customIcons.MyFlutterApp.hidden, message: lang.clubs_topics5);

    final emptyTopics = Container(
        height: _deviceHeight * 0.5,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: OptimisedText(
                      minWidth: _deviceWidth * 0.75,
                      maxWidth: _deviceWidth * 0.75,
                      minHeight: _deviceHeight * 0.05,
                      maxHeight: _deviceHeight * 0.10,
                      fit: BoxFit.scaleDown,
                      child: Container(
                          padding: const EdgeInsets.all(
                            21.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              31.0,
                            ),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(lang.clubs_topics6,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 35.0)))))
            ]));
    return (isDisabled && !isAdmin)
        ? disabledClub
        : (isProhibited && !isAdmin)
            ? prohibitedClub
            : (isBanned && !isAdmin)
                ? bannedClub
                : (_isPrivate && !isMember && !isAdmin)
                    ? privateClub
                    : (_isHidden && !isMember && !isAdmin)
                        ? hiddenClub
                        : (topics.isEmpty)
                            ? emptyTopics
                            : ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: _deviceHeight * 0.35,
                                  maxHeight: _deviceHeight * 0.85,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0.0,
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  child: NestedScroller(
                                    controller: screenController,
                                    child: ListView(
                                      padding:
                                          const EdgeInsets.only(bottom: 55.0),
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        Wrap(
                                          children: <Widget>[
                                            ...topics.map(
                                              (name) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    final TopicScreenArgs
                                                        screenArgs =
                                                        TopicScreenArgs(name);
                                                    Navigator.pushNamed(
                                                      context,
                                                      RouteGenerator
                                                          .topicPostsScreen,
                                                      arguments: screenArgs,
                                                    );
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                      1.0,
                                                    ),
                                                    child: TopicChip(
                                                        name,
                                                        null,
                                                        null,
                                                        Colors.white,
                                                        FontWeight.normal,
                                                        _primaryColor),
                                                  ),
                                                );
                                              },
                                            ).toList(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
  }
}
