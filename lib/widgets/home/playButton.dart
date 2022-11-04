import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appBarProvider.dart';
import '../../screens/feedScreen.dart';
import 'appBarIcon.dart';

class PlayButton extends StatelessWidget {
  const PlayButton();
  void playButtonHandler(void Function(View) _changeView) {
    if (FeedScreen.controller != null && FeedScreen.sheetOpen) {
      FeedScreen.controller!.closed.then((_) {
        FeedScreen.sheetOpen = false;
      });
      FeedScreen.controller!.close();
    } else if (FeedScreen.shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen.shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
      });
      FeedScreen.shareController!.close();
    }
    _changeView(View.autoScroll);
  }

  @override
  Widget build(BuildContext context) {
    final void Function(View) _changeView =
        Provider.of<AppBarProvider>(context, listen: false).changeView;
    return AppBarIcon(
        splashColor: Colors.transparent,
        icon: Icons.auto_fix_high_outlined,
        onPressed: () => playButtonHandler(_changeView),
        hint: 'Scroller');
  }
}
