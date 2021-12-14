import 'package:flutter/material.dart';

class VisSnack extends StatelessWidget {
  final IconData icon;
  final String message;
  const VisSnack(this.icon, this.message);
  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    final Color _accentColor = Theme.of(context).accentColor;
    final Widget _icon = Icon(
      icon,
      color: Colors.white,
      size: 45.0,
    );
    final Widget _message = RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Profile is now ',
            style: const TextStyle(
              fontSize: 25.0,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: message,
            style: TextStyle(
              fontSize: 25.0,
              color: _accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
          const Spacer(flex: 2),
        ],
      ),
    );
    return _snackBar;
  }
}
