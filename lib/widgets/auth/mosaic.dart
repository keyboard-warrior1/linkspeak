import 'dart:math';

import 'package:flutter/material.dart';
import 'package:o_color_picker/o_color_picker.dart';
import '../../general.dart';

class Mosaic extends StatelessWidget {
  const Mosaic();
  static const double _height = 50.0;
  static const double _width = 50.0;
  static var initialPrimaryPalette = primaryColorsPalette.take(19).toList();
  static var initialAccentPalette = accentColorsPalette.take(16).toList();
  static var _allColors = [...initialPrimaryPalette, ...initialAccentPalette];
  static var _allAlignments = [
    Alignment.bottomRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.center,
    Alignment.centerLeft,
    Alignment.centerRight,
    Alignment.topCenter,
    Alignment.topLeft,
    Alignment.topRight
  ];
  static var _allRadii = [0.0, 5.0, 10.0, 15.0];
  static var _showBorder = [true, false, true, false, true, false, true, false];
  static var _showGradient = [
    true,
    false,
    true,
    false,
    true,
    false,
    true,
    false
  ];
  Widget buildBannerColorTile(
      bool isGradient, double randomRadius, bool randomBorder) {
    final _random = Random();
    final _allColorsLength = _allColors.length;
    final _randomIndex = _random.nextInt(_allColorsLength);
    final _randomMixIndex = _random.nextInt(_allColorsLength);
    final _randomAlignIndex = _random.nextInt(_allAlignments.length);
    final _randomEnd = _random.nextInt(_allAlignments.length);
    final _randomColor = _allColors[_randomIndex];
    final _randomEnder = _allAlignments[_randomEnd];
    final _randomAlignment = _allAlignments[_randomAlignIndex];
    final _randomMixColor = _allColors[_randomMixIndex];
    return Container(
      height: _height,
      width: _width,
      decoration: isGradient
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: _randomAlignment,
                end: _randomEnder,
                tileMode: TileMode.clamp,
                colors: [
                  _randomMixColor,
                  _randomColor,
                ],
              ),
              border: randomBorder ? Border.all() : null,
              borderRadius: BorderRadius.circular(randomRadius),
            )
          : BoxDecoration(
              color: _randomColor,
              borderRadius: BorderRadius.circular(randomRadius),
              border: randomBorder ? Border.all() : null,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _random = Random();
    final _randomGradientIndex = _random.nextInt(_showGradient.length);
    final _randomRadiusIndex = _random.nextInt(_allRadii.length);
    final _randomBorderIndex = _random.nextInt(_showBorder.length);
    final _showTheGradient = _showGradient[_randomGradientIndex];
    final _randomRadius = _allRadii[_randomRadiusIndex];
    final _randomBorder = _showBorder[_randomBorderIndex];
    final size = MediaQuery.of(context).size;
    final deviceheight = size.height;
    final devicewidth = General.widthQuery(context);
    final amountHeight = deviceheight / _height;
    final addHeightHalf = amountHeight + 0.50;
    final heightNum = addHeightHalf.round();
    final amountWidth = devicewidth / _width;
    final addWidthHalf = amountWidth + 0.50;
    final widthNum = addWidthHalf.round();
    return SizedBox(
      height: deviceheight,
      width: devicewidth,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          for (var i = 0; i < heightNum; i++)
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                for (var i = 0; i < widthNum; i++)
                  buildBannerColorTile(
                      _showTheGradient, _randomRadius, _randomBorder),
              ],
            )
        ],
      ),
    );
  }
}
