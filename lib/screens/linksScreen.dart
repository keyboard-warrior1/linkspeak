import 'package:flutter/material.dart';
import 'package:provider/Provider.dart';

import '../general.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/profile/myLinks.dart';
import '../widgets/profile/otherLinks.dart';

class LinksScreen extends StatelessWidget {
  final dynamic userID;
  final dynamic publicProfile;
  final dynamic imLinkedToThem;
  final dynamic instance;
  const LinksScreen({
    required this.userID,
    required this.publicProfile,
    required this.imLinkedToThem,
    required this.instance,
  });

  Widget giveLinks(bool isMyProfile) {
    if (isMyProfile) {
      return const MyLinks();
    } else {
      return OtherLinks(instance, userID);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final String myUsername = context.read<MyProfile>().getUsername;
    final bool isMyProfile = userID == myUsername;
    final lang = General.language(context);
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: (!isMyProfile)
            ? (!publicProfile)
                ? (!imLinkedToThem)
                    ? (!myUsername.startsWith('Linkspeak'))
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SettingsBar(lang.screens_links),
                              const Spacer(),
                              Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Colors.black,
                                  size: _deviceHeight * 0.15,
                                ),
                              ),
                              const Spacer(),
                            ],
                          )
                        : giveLinks(isMyProfile)
                    : giveLinks(isMyProfile)
                : giveLinks(isMyProfile)
            : giveLinks(isMyProfile),
      ),
    );
  }
}
