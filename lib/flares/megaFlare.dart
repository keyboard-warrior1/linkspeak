import 'dart:math';

import 'package:flutter/material.dart';
import 'package:o_color_picker/o_color_picker.dart';

import '../general.dart';

class MegaFlare extends StatefulWidget {
  final bool isTriggered;
  const MegaFlare(this.isTriggered);

  @override
  State<MegaFlare> createState() => _MegaFlareState();
}

class _MegaFlareState extends State<MegaFlare> {
  bool reverse = false;
  static const double _itemheight = 100.0;
  static const double _itemwidth = 100.0;
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
  static var _allSizes = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
  Widget buildItem(Color _accentColor) {
    final _random = Random();
    final _firstRandomColorInd = _random.nextInt(_allColors.length);
    final _secondRandomColorInd = _random.nextInt(_allColors.length);
    final _firstRandom = _random.nextInt(_allAlignments.length);
    final _secondRandom = _random.nextInt(_allAlignments.length);
    final _randomSizeInt = _random.nextInt(_allSizes.length);
    final _firstColor = _allColors[_firstRandomColorInd];
    final _secondColor = _allColors[_secondRandomColorInd];
    final _randomFirstAlignment = _allAlignments[_firstRandom];
    final _randomSecondAlignment = _allAlignments[_secondRandom];
    final _randomSize = _allSizes[_randomSizeInt];
    return Container(
      height: _itemheight,
      width: _itemwidth,
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _randomFirstAlignment,
            duration: const Duration(milliseconds: 750),
            child: StarIcon(_randomSize, _firstColor),
          ),
          AnimatedAlign(
            alignment: _randomSecondAlignment,
            duration: const Duration(milliseconds: 750),
            child: StarIcon(_randomSize, _secondColor),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTriggered) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {});
      });
    }

    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final _size = MediaQuery.of(context).size;
    final _height = _size.height;
    final _width = General.widthQuery(context);
    final _x50 = _height * 0.90;
    final amountHeight = _x50 / _itemheight;
    final addHeightHalf = amountHeight + 0.50;
    final heightNum = addHeightHalf.round();
    final amountWidth = _width / _itemwidth;
    final addWidthHalf = amountWidth + 0.50;
    final widthNum = addWidthHalf.round();
    return AnimatedOpacity(
      opacity: (widget.isTriggered) ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: widget.isTriggered
                ? Duration.zero
                : const Duration(milliseconds: 500),
            height: widget.isTriggered ? _height : 0,
            width: widget.isTriggered ? _width : 0,
            child: AnimatedAlign(
              alignment: widget.isTriggered
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              curve: Curves.fastOutSlowIn,
              duration: const Duration(milliseconds: 1000),
              child: AnimatedContainer(
                height: _x50,
                width: _width,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    for (var i = 0; i < heightNum; i++)
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          for (var i = 0; i < widthNum; i++)
                            buildItem(_accentColor),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // ),
    );
  }
}

class StarIcon extends StatefulWidget {
  final double scale;
  final Color randomColor;
  const StarIcon(this.scale, this.randomColor);

  @override
  State<StarIcon> createState() => _StarIconState();
}

class _StarIconState extends State<StarIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: AnimatedScale(
        scale: widget.scale,
        duration: kThemeAnimationDuration,
        child: Icon(
          Icons.star,
          color: widget.randomColor,
          size: 50,
        ),
      ),
    );
  }
}
