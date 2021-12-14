import 'package:flutter/material.dart';

class NoConnectionSnack extends StatelessWidget {
  const NoConnectionSnack();
  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    final Color _accentColor = Theme.of(context).accentColor;
    const Widget _message =const Text(
      'No internet connection',
      style: TextStyle(
        fontSize: 25.0,
        color: Colors.white,
      ),
    );
    final Widget _snackBar = Container(
      height: _deviceHeight * 0.03,
      width: _deviceWidth,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _message,
          const Spacer(),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
            },
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: 25.0,
                color: _accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
    return _snackBar;
  }
}
