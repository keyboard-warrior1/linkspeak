import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appBarProvider.dart';
import 'adaptiveText.dart';

class SpeedFactor extends StatelessWidget {
  const SpeedFactor();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _deviceHeight = _size.height;
    final double _deviceWidth = _size.width;
    int _speedFactor = context.watch<AppBarProvider>().speedFactor;

    return OptimisedText(
      minHeight: _deviceHeight * 0.05,
      maxHeight: _deviceHeight * 0.05,
      minWidth: _deviceWidth * 0.1,
      maxWidth: _deviceWidth * 0.1,
      fit: BoxFit.contain,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          color: Colors.blue,
        ),
        child: Center(
          child: OptimisedText(
            minHeight: 10.0,
            maxHeight: 10.0,
            minWidth: 17.0,
            maxWidth: 17.0,
            fit: BoxFit.scaleDown,
            child: Text(
              '${_speedFactor}x',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'JosefinSans',
                fontSize: 100.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
