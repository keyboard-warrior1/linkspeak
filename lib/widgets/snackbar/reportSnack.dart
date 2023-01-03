import 'package:flutter/material.dart';

class ReportSnack extends StatelessWidget {
  final String message;
  const ReportSnack(this.message);
  @override
  Widget build(BuildContext context) {
    const Widget _icon =
        const Icon(Icons.check, color: Colors.white, size: 35.0);
    final Widget _message = Text(message,
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
