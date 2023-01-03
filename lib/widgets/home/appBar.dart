import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/themeModel.dart';
import '../../providers/appBarProvider.dart';
import 'notificationButton.dart';
import 'playButton.dart';
import 'profileButton.dart';
import 'searchButton.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar();
  @override
  Widget build(BuildContext context) {
    final textDirection =
        Provider.of<ThemeModel>(context, listen: false).textDirection;
    final bool isRTL = textDirection == TextDirection.rtl;
    final View viewMode = Provider.of<AppBarProvider>(context).viewMode;
    final bool showbar = Provider.of<AppBarProvider>(context).showBar;
    const Widget _playButton = const PlayButton();
    const Widget _searchButton = const SearchButton();
    const Widget _profileButton = const ProfileButton();
    const Widget _notificationButton = const NotificationButton();
    final int selectedIndex =
        Provider.of<AppBarProvider>(context).selectedIndex;
    return Align(
        alignment: isRTL ? Alignment.topLeft : Alignment.topRight,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: (viewMode == View.normal && showbar) ? 50.0 : 0.0,
            decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(isRTL ? 0 : 15.0),
                    bottomRight: Radius.circular(isRTL ? 15.0 : 0))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (selectedIndex == 0 || selectedIndex == 3) _playButton,
                  _searchButton,
                  _notificationButton,
                  _profileButton
                ])));
  }
}
