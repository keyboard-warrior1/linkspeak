import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appBarProvider.dart';
import 'appBarIcon.dart';

class FasterButton extends StatelessWidget {
  const FasterButton();

  @override
  Widget build(BuildContext context) {
    final void Function() _increaseSpeed =
        context.read<AppBarProvider>().increaseSpeed;
    return AppBarIcon(
      splashColor: Colors.transparent,
      icon: Icons.add,
      onPressed: () {
        _increaseSpeed();
      },
      hint: null,
    );
  }
}
