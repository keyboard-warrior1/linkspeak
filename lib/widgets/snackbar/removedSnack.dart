import 'package:flutter/material.dart';
import '../../general.dart';

class RemovedSnack extends StatelessWidget {
  const RemovedSnack();
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    const Widget _icon =
        const Icon(Icons.person_remove, color: Colors.white, size: 35.0);
    final Widget _message = Text(lang.wigets_snack4,
        style: const TextStyle(fontSize: 25.0, color: Colors.white));
    final Widget _snackBar = Container(
        height: 40.0,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _icon,
              const Spacer(flex: 1),
              _message,
              const Spacer(flex: 4)
            ]));
    return _snackBar;
  }
}
