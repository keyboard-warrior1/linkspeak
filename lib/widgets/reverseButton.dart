import 'dart:math';
import 'package:flutter/material.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import 'appBarIcon.dart';

class ReverseButton extends StatelessWidget {
  final void Function() reverseHandler;
  const ReverseButton(this.reverseHandler);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 90 * pi / 180,
      child: AppBarIcon(
        splashColor: Colors.transparent,
        icon: customIcons.MyFlutterApp.reverse,
        onPressed: reverseHandler,
        hint: 'Reverse',
      ),
    );
  }
}
