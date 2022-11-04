import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appBarProvider.dart';
import 'appBarIcon.dart';

class SlowerButton extends StatelessWidget {
  const SlowerButton();
  @override
  Widget build(BuildContext context) {
    final void Function() _decreaseSpeed =
        context.read<AppBarProvider>().decreaseSpeed;
    return AppBarIcon(
        splashColor: Colors.transparent,
        icon: Icons.remove,
        onPressed: () {
          _decreaseSpeed();
        },
        hint: null);
  }
}
