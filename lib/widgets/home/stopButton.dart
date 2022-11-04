import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/appBarProvider.dart';
import '../../screens/feedScreen.dart';
import 'appBarIcon.dart';

class StopButton extends StatelessWidget {
  const StopButton();
  void stopHandler(
      int selectedIndex, dynamic _changeView, dynamic _changeScroll) {
    if (FeedScreen.controller != null && FeedScreen.sheetOpen) {
      FeedScreen.controller!.closed.then((_) {
        FeedScreen.sheetOpen = false;
        _changeView(View.normal);
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
      });
      FeedScreen.controller!.close();
    } else if (FeedScreen.shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen.shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
      });
      FeedScreen.shareController!.close();
      _changeView(View.normal);
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
    } else {
      _changeView(View.normal);
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
    final int _selectedIndex =
        Provider.of<AppBarProvider>(context).selectedIndex;
    final void Function(View) _changeView =
        Provider.of<AppBarProvider>(context, listen: false).changeView;
    final void Function(Scroll) _changeScroll =
        Provider.of<AppBarProvider>(context, listen: false).changeScroll;
    return AppBarIcon(
        splashColor: Colors.transparent,
        icon: customIcons.MyFlutterApp.curve_arrow,
        onPressed: () =>
            stopHandler(_selectedIndex, _changeView, _changeScroll),
        hint: 'Exit');
  }
}
