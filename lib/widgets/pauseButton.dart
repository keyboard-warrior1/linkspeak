import 'package:flutter/material.dart';
import 'appBarIcon.dart';

class PauseButton extends StatelessWidget {
  final void Function() pauseHandler;
  const PauseButton(this.pauseHandler);

  @override
  Widget build(BuildContext context) {
    return AppBarIcon(
      splashColor: Colors.transparent,
      icon: Icons.pause_outlined,
      onPressed: pauseHandler,
      hint: 'Pause',
    );
  }
}
