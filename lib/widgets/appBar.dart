import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appBarProvider.dart';
import 'searchButton.dart';
import 'profileButton.dart';
import 'notificationButton.dart';
import 'playButton.dart';

class MyAppBar extends StatelessWidget {
  final void Function() playButtonHandler;
  const MyAppBar(this.playButtonHandler);

  @override
  Widget build(BuildContext context) {
    View viewMode = Provider.of<AppBarProvider>(context).viewMode;
    bool showbar = Provider.of<AppBarProvider>(context).showBar;
    final Widget _playButton = PlayButton(playButtonHandler);
    const Widget _searchButton = const SearchButton();
    const Widget _profileButton = const ProfileButton();
    const Widget _notificationButton = const NotificationButton();
    int selectedIndex = Provider.of<AppBarProvider>(context).selectedIndex;
    return Align(
      alignment: Alignment.topRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: (viewMode == View.normal && showbar) ? 50.0 : 0.0,
        decoration: const BoxDecoration(
          color: Colors.white70,
          borderRadius: const BorderRadius.only(
            bottomLeft: const Radius.circular(15.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (selectedIndex == 0) _playButton,
            _searchButton,
            _notificationButton,
            _profileButton,
          ],
        ),
      ),
    );
  }
}
