import 'package:flutter/material.dart';

import '../../general.dart';
import 'adaptiveText.dart';

class MyTitle extends StatelessWidget {
  const MyTitle();
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    return OptimisedText(
        minWidth: _deviceWidth * 0.25,
        maxWidth: _deviceWidth * 0.35,
        minHeight: _deviceHeight * 0.05,
        maxHeight: _deviceHeight * 0.05,
        fit: BoxFit.scaleDown,
        child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Stack(children: <Widget>[
              Text(lang.logo,
                  softWrap: false,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 50.0,
                      fontFamily: 'JosefinSans',
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3.75
                        ..color = Colors.black)),
              Text(lang.logo,
                  softWrap: false,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontFamily: 'JosefinSans',
                      fontSize: 50.0,
                      color: Colors.white))
            ])));
  }
}
