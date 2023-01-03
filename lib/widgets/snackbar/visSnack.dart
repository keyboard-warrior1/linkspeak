import 'package:flutter/material.dart';

import '../../general.dart';

class VisSnack extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isClub;
  const VisSnack(this.icon, this.message, this.isClub);
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final Widget _icon = Icon(icon, color: Colors.white, size: 45.0);
    final Widget _message = RichText(
        text: TextSpan(children: [
      TextSpan(
          text: !isClub ? lang.wigets_snack5 : lang.wigets_snack6,
          style: const TextStyle(fontSize: 25.0, color: Colors.white)),
      TextSpan(
          text: message,
          style: TextStyle(
              fontSize: 25.0, color: _accentColor, fontWeight: FontWeight.bold))
    ]));
    final Widget _snackBar = Container(
        height: _deviceHeight * 0.05,
        width: _deviceWidth,
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _icon,
              const Spacer(flex: 1),
              _message,
              const Spacer(flex: 2)
            ]));
    return _snackBar;
  }
}
