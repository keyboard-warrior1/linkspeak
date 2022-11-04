import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/chatprofileImage.dart';
import '../settings/switchSheet.dart';
import 'appBarIcon.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton();
  @override
  Widget build(BuildContext context) {
    final MyProfile myProfile = Provider.of<MyProfile>(context);
    final myUsername = myProfile.getUsername;
    return GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.white,
              context: context,
              builder: (ctx) {
                return const SwitchSheet();
              });
        },
        child: AppBarIcon(
            splashColor: Colors.transparent,
            isInAppBar: true,
            icon: Center(
                child: ChatProfileImage(
                    username: myUsername,
                    factor: 0.0385,
                    inEdit: false,
                    asset: null)),
            onPressed: () =>
                Navigator.pushNamed(context, RouteGenerator.myProfileScreen),
            hint: null));
  }
}
