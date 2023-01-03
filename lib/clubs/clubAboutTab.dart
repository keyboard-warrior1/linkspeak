import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/clubProvider.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/myLinkify.dart';
import '../widgets/common/nestedScroller.dart';
import 'privateClub.dart';

class ClubAbout extends StatelessWidget {
  const ClubAbout();
  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final lang = General.language(context);
    final isAdmin = myUsername.startsWith('Linkspeak');
    final _club = Provider.of<ClubProvider>(context, listen: false);
    final ScrollController screenController =
        Provider.of<ClubProvider>(context, listen: false)
            .getScreenScrollController;
    final String clubAbout = _club.clubDescription;
    final String clubName = _club.clubName;
    final bool isFounder = _club.isFounder;
    final ClubVisibility clubVisibility = _club.clubVisibility;
    final bool isDisabled = _club.isDisabled;
    final bool isBanned = _club.isBanned;
    final bool isProhibited = _club.isProhibited;
    final bool _isPrivate = clubVisibility == ClubVisibility.private;
    final bool _isHidden = clubVisibility == ClubVisibility.hidden;
    final bool isMember = _club.isJoined;
    final Widget privateClub =
        PrivateClub(icon: Icons.lock_outlined, message: lang.clubs_about1);
    final Widget prohibitedClub = PrivateClub(
        icon: customIcons.MyFlutterApp.radio_1_, message: lang.clubs_about2);
    final Widget disabledClub = PrivateClub(
        icon: customIcons.MyFlutterApp.clubs, message: lang.clubs_about3);
    final Widget bannedClub = PrivateClub(
        icon: customIcons.MyFlutterApp.no_stopping, message: lang.clubs_about4);
    final Widget hiddenClub = PrivateClub(
        icon: customIcons.MyFlutterApp.hidden, message: lang.clubs_about5);

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
                        : NestedScroller(
                            controller: screenController,
                            child: ListView(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(bottom: 85),
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: MyLinkify(
                                          text: '$clubAbout',
                                          maxLines: 500,
                                          style: const TextStyle(
                                              fontFamily: 'Roboto',
                                              wordSpacing: 1.5,
                                              fontSize: 18.0),
                                          textDirection: null)),
                                  const Divider(),
                                  ListTile(
                                      onTap: () {
                                        final AdminScreenArgs args =
                                            AdminScreenArgs(
                                                isFounder: isFounder,
                                                clubName: clubName);
                                        Navigator.pushNamed(context,
                                            RouteGenerator.clubAdminScreen,
                                            arguments: args);
                                      },
                                      horizontalTitleGap: 5.0,
                                      leading: const Icon(Icons.people,
                                          color: Colors.black),
                                      title: Text(lang.clubs_about6,
                                          style: const TextStyle(
                                              color: Colors.black)))
                                ]));
  }
}
