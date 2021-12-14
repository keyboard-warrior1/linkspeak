import 'package:flutter/material.dart';
import 'appBarIcon.dart';

class StartButton extends StatelessWidget {
  final void Function() startHandler;
  const StartButton(this.startHandler);

  @override
  Widget build(BuildContext context) {
    return AppBarIcon(
      splashColor: Colors.transparent,
      icon: Icons.play_arrow_outlined,
      onPressed: startHandler,
      hint: 'Start',
    );
  }
}
