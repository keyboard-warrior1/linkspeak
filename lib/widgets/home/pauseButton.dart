import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/appBarProvider.dart';
import '../../screens/feedScreen.dart';
import 'appBarIcon.dart';

class PauseButton extends StatelessWidget {
  const PauseButton();
  void pauseHandler(int selectedIndex, dynamic _changeScroll) {
    if (FeedScreen.scrollMode == ScrollMode.upward) {
      FeedScreen.scrollMode = ScrollMode.upward;
      _changeScroll(Scroll.paused);
      if (selectedIndex == 0)
        FeedScreen.scrollController.animateTo(
            FeedScreen.scrollController.offset,
            duration: const Duration(seconds: 0),
            curve: Curves.linear);
      else
        FeedScreen.clubScrollController.animateTo(
            FeedScreen.clubScrollController.offset,
            duration: const Duration(seconds: 0),
            curve: Curves.linear);
    } else if (FeedScreen.scrollMode == ScrollMode.downward) {
      FeedScreen.scrollMode = ScrollMode.downward;
      _changeScroll(Scroll.paused);
      if (selectedIndex == 0)
        FeedScreen.scrollController.animateTo(
            FeedScreen.scrollController.offset,
            duration: const Duration(seconds: 0),
            curve: Curves.linear);
      else
        FeedScreen.clubScrollController.animateTo(
            FeedScreen.clubScrollController.offset,
            duration: const Duration(seconds: 0),
            curve: Curves.linear);
    } else {
      FeedScreen.scrollMode = ScrollMode.paused;
      _changeScroll(Scroll.paused);
      if (selectedIndex == 0)
        FeedScreen.scrollController.animateTo(
            FeedScreen.scrollController.offset,
            duration: const Duration(seconds: 0),
            curve: Curves.linear);
      else
        FeedScreen.clubScrollController.animateTo(
            FeedScreen.clubScrollController.offset,
            duration: const Duration(seconds: 0),
            curve: Curves.linear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final int _selectedIndex =
        Provider.of<AppBarProvider>(context).selectedIndex;
    final void Function(Scroll) _changeScroll =
        Provider.of<AppBarProvider>(context, listen: false).changeScroll;
    return AppBarIcon(
        splashColor: Colors.transparent,
        icon: Icons.pause_outlined,
        onPressed: () => pauseHandler(_selectedIndex, _changeScroll),
        hint: lang.widgets_home7);
  }
}
