import 'package:flutter/material.dart';
import 'appBarIcon.dart';

class PlayButton extends StatelessWidget {
  final void Function() playButtonHandler;
  const PlayButton(this.playButtonHandler);

  @override
  Widget build(BuildContext context) {
    return AppBarIcon(
      splashColor: Colors.transparent,
      icon: Icons.auto_fix_high_outlined,
      onPressed: playButtonHandler,
      hint: 'Scroller',
    );
  }
}
