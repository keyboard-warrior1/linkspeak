import 'package:flutter/material.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import 'appBarIcon.dart';

class StopButton extends StatelessWidget {
  final void Function() stopHandler;
  const StopButton(this.stopHandler);

  @override
  Widget build(BuildContext context) {
    return AppBarIcon(
      splashColor: Colors.transparent,
      icon: customIcons.MyFlutterApp.curve_arrow,
      onPressed: stopHandler,
      hint: 'Exit',
    );
  }
}
