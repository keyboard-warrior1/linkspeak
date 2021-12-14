import 'package:flutter/material.dart';
import 'package:provider/Provider.dart';

import '../providers/myProfileProvider.dart';
import '../widgets/settingsBar.dart';
import '../widgets/myLinks.dart';
import '../widgets/otherLinks.dart';

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
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: (!isMyProfile)
            ? (!publicProfile)
                ? (!imLinkedToThem)
                    ? (!myUsername.startsWith('Linkspeak'))
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SettingsBar('Links'),
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
