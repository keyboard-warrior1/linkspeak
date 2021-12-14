import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import 'appBarIcon.dart';
import 'profileImage.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton();

  @override
  Widget build(BuildContext context) {
    final MyProfile myProfile = Provider.of<MyProfile>(context);
    final myUsername = myProfile.getUsername;
    final myAvatar = myProfile.getProfileImage;
    return AppBarIcon(
      splashColor: Colors.transparent,
      isInAppBar: true,
      icon: Center(
        child: ProfileImage(
            username: myUsername,
            url: myAvatar,
            factor: 0.0385,
            inEdit: false,
            asset: null),
      ),
      onPressed: () => Navigator.pushNamed(
        context,
        RouteGenerator.myProfileScreen,
      ),
      hint: myUsername,
    );
  }
}
