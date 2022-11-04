import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/myProfileProvider.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/profile/myLinked.dart';
import '../widgets/profile/otherLinked.dart';

class LinkedToScreen extends StatelessWidget {
  final dynamic userID;
  final dynamic publicProfile;
  final dynamic imLinkedToThem;
  final dynamic instance;
  const LinkedToScreen({
    required this.userID,
    required this.publicProfile,
    required this.imLinkedToThem,
    required this.instance,
  });

  Widget giveLinked(bool isMyProfile) {
    if (isMyProfile) {
      return const MyLinked();
    } else {
      return OtherLinked(instance, userID);
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
      backgroundColor: Colors.white,
      body: SafeArea(
          child: (!isMyProfile)
              ? (!publicProfile)
                  ? (!imLinkedToThem)
                      ? (!myUsername.startsWith('Linkspeak'))
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                const SettingsBar('Linked'),
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
                          : giveLinked(isMyProfile)
                      : giveLinked(isMyProfile)
                  : giveLinked(isMyProfile)
              : giveLinked(isMyProfile)),
    );
  }
}
