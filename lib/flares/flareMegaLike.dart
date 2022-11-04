import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/themeModel.dart';

class MegaLike extends StatefulWidget {
  final bool triggerLike;
  const MegaLike(this.triggerLike);

  @override
  State<MegaLike> createState() => _MegaLikeState();
}

class _MegaLikeState extends State<MegaLike> {
  Widget buildIconButton(
          File? activePath, double deviceHeight, double deviceWidth) =>
      ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: deviceHeight * 0.5,
            maxHeight: deviceHeight * 0.5,
            maxWidth: deviceWidth * 0.5,
            minWidth: deviceWidth * 0.5),
        child: FittedBox(
          fit: BoxFit.contain,
          child: IconButton(
            padding: const EdgeInsets.all(0.0),
            onPressed: () {},
            iconSize: deviceHeight * 0.1,
            icon: Image.file(activePath!, fit: BoxFit.contain),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    // final _accentColor = Theme.of(context).colorScheme.secondary;
    final themeHelper = Provider.of<ThemeModel>(context);
    final currentIconName = themeHelper.selectedIconName;
    final currentIcon = themeHelper.themeIcon;
    final active = themeHelper.activeLikeFile;
    final likeColor = themeHelper.likeColor;
    return Align(
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: widget.triggerLike ? 1.5 : 0,
        duration: const Duration(milliseconds: 175),
        curve: Curves.easeInOutCubicEmphasized,
        child: currentIconName != 'Custom'
            ? Icon(currentIcon, color: likeColor, size: height * 0.1)
            : buildIconButton(active, height, width),
      ),
    );
  }
}
