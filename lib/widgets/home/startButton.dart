import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appBarProvider.dart';
import '../../screens/feedScreen.dart';
import 'appBarIcon.dart';

class StartButton extends StatelessWidget {
  const StartButton();
  void _scrollUp(int selectedIndex, int _speedFactor) {
    final top = selectedIndex == 0
        ? FeedScreen.scrollController.position.minScrollExtent
        : FeedScreen.clubScrollController.position.minScrollExtent;
    final double currentPosition = selectedIndex == 0
        ? FeedScreen.scrollController.position.pixels
        : FeedScreen.clubScrollController.position.pixels;
    final double distance = top - currentPosition;
    final double factor = -_speedFactor / 20;
    final double _num = distance / factor;
    final Duration duration = Duration(milliseconds: _num.round());
    if (FeedScreen.controller != null && FeedScreen.sheetOpen) {
      FeedScreen.controller!.closed.then((_) {
        FeedScreen.sheetOpen = false;
        if (selectedIndex == 0)
          FeedScreen.scrollController
              .animateTo(top, duration: duration, curve: Curves.linear);
        else
          FeedScreen.clubScrollController
              .animateTo(top, duration: duration, curve: Curves.linear);
      });
      FeedScreen.controller!.close();
    } else if (FeedScreen.shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen.shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
        if (selectedIndex == 0)
          FeedScreen.scrollController
              .animateTo(top, duration: duration, curve: Curves.linear);
        else
          FeedScreen.clubScrollController
              .animateTo(top, duration: duration, curve: Curves.linear);
      });
      FeedScreen.shareController!.close();
    } else {
      if (selectedIndex == 0)
        FeedScreen.scrollController
            .animateTo(top, duration: duration, curve: Curves.linear);
      else
        FeedScreen.clubScrollController
            .animateTo(top, duration: duration, curve: Curves.linear);
    }
  }

  void _scrollDown(int selectedIndex, int _speedFactor) {
    final bottom = selectedIndex == 0
        ? FeedScreen.scrollController.position.maxScrollExtent
        : FeedScreen.clubScrollController.position.maxScrollExtent;
    final double currentPosition = selectedIndex == 0
        ? FeedScreen.scrollController.position.pixels
        : FeedScreen.clubScrollController.position.pixels;
    final double distance = currentPosition - bottom;
    final double factor = -_speedFactor / 20;
    final double _num = distance / factor;
    final Duration duration = Duration(milliseconds: _num.round());
    if (FeedScreen.controller != null && FeedScreen.sheetOpen) {
      FeedScreen.controller!.closed.then((_) {
        FeedScreen.sheetOpen = false;
        if (selectedIndex == 0)
          FeedScreen.scrollController
              .animateTo(bottom, duration: duration, curve: Curves.linear);
        else
          FeedScreen.clubScrollController
              .animateTo(bottom, duration: duration, curve: Curves.linear);
      });
      FeedScreen.controller!.close();
    } else if (FeedScreen.shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen.shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
        if (selectedIndex == 0)
          FeedScreen.scrollController
              .animateTo(bottom, duration: duration, curve: Curves.linear);
        else
          FeedScreen.clubScrollController
              .animateTo(bottom, duration: duration, curve: Curves.linear);
      });
      FeedScreen.shareController!.close();
    } else {
      if (selectedIndex == 0)
        FeedScreen.scrollController
            .animateTo(bottom, duration: duration, curve: Curves.linear);
      else
        FeedScreen.clubScrollController
            .animateTo(bottom, duration: duration, curve: Curves.linear);
    }
  }

  void startHandler(int selectedIndex, int _speedFactor, Scroll scrollMode,
      dynamic _changeScroll) {
    if (scrollMode != Scroll.scrolling) {
      _changeScroll(Scroll.scrolling);
    }
    if (FeedScreen.scrollMode == ScrollMode.upward) {
      _scrollUp(selectedIndex, _speedFactor);
    } else {
      FeedScreen.scrollMode = ScrollMode.downward;
      _changeScroll(Scroll.scrolling);
      _scrollDown(selectedIndex, _speedFactor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Scroll _scrollMode = Provider.of<AppBarProvider>(context).scrollMode;
    final int _speedFactor = Provider.of<AppBarProvider>(context).speedFactor;
    final int _selectedIndex =
        Provider.of<AppBarProvider>(context).selectedIndex;
    final void Function(Scroll) _changeScroll =
        Provider.of<AppBarProvider>(context, listen: false).changeScroll;
    return AppBarIcon(
        splashColor: Colors.transparent,
        icon: Icons.play_arrow_outlined,
        onPressed: () => startHandler(
            _selectedIndex, _speedFactor, _scrollMode, _changeScroll),
        hint: 'Start');
  }
}
