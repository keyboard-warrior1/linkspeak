import 'package:flutter/material.dart';

class RemovedSnack extends StatelessWidget {
  const RemovedSnack();
  @override
  Widget build(BuildContext context) {
    const Widget _icon = const Icon(
      Icons.person_remove,
      color: Colors.white,
      size: 35.0,
    );
    const Widget _message = const Text(
      'Removed',
      style: const TextStyle(
        fontSize: 25.0,
        color: Colors.white,
      ),
    );
    final Widget _snackBar = Container(
      height: 40.0,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const <Widget>[
          _icon,
          const Spacer(flex: 1),
          _message,
          const Spacer(flex: 4),
        ],
      ),
    );
    return _snackBar;
  }
}
