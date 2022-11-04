import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/appBarProvider.dart';
import '../../screens/feedScreen.dart';
import 'appBarIcon.dart';

class ReverseButton extends StatelessWidget {
  const ReverseButton();
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

  void reverseHandler(int selectedIndex, int _speedFactor) {
    if (FeedScreen.scrollMode == ScrollMode.downward ||
        FeedScreen.scrollController.position.pixels ==
            FeedScreen.scrollController.position.maxScrollExtent) {
      FeedScreen.scrollMode = ScrollMode.upward;
      _scrollUp(selectedIndex, _speedFactor);
    } else if (FeedScreen.scrollMode == ScrollMode.upward) {
      FeedScreen.scrollMode = ScrollMode.downward;
      _scrollDown(selectedIndex, _speedFactor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int _selectedIndex =
        Provider.of<AppBarProvider>(context).selectedIndex;
    final int _speedFactor = Provider.of<AppBarProvider>(context).speedFactor;
    return Transform.rotate(
        angle: 90 * pi / 180,
        child: AppBarIcon(
            splashColor: Colors.transparent,
            icon: customIcons.MyFlutterApp.reverse,
            onPressed: () => reverseHandler(_selectedIndex, _speedFactor),
            hint: 'Reverse'));
  }
}
