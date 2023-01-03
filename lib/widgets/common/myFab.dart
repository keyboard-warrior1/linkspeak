import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/otherProfileProvider.dart';

class MyFab extends StatefulWidget {
  final ScrollController scrollController;
  final bool? isInOtherProfile;
  const MyFab(this.scrollController, [this.isInOtherProfile]);

  @override
  _MyFabState createState() => _MyFabState();
}

class _MyFabState extends State<MyFab> {
  bool atTop = true;
  void toTop() {
    final double top = widget.scrollController.position.minScrollExtent;
    final double currentPosition = widget.scrollController.position.pixels;
    final double distance = top - currentPosition;
    final double _num = distance / -15;
    final Duration duration = Duration(milliseconds: _num.round());
    widget.scrollController
        .animateTo(top, duration: duration, curve: Curves.linear);
  }

  void anchorHandler() {
    toTop();
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.minScrollExtent) {
        if (!atTop) {
          if (mounted)
            setState(() {
              atTop = true;
            });
        }
      } else {
        if (atTop) {
          if (mounted)
            setState(() {
              atTop = false;
            });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    Color _accentColor = Theme.of(context).colorScheme.secondary;
    if (widget.isInOtherProfile != null && widget.isInOtherProfile!) {
      _primaryColor =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    return FloatingActionButton(
      key: UniqueKey(),
      highlightElevation: 0.0,
      elevation: 0.0,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 100,
        ),
        child: (atTop)
            ? Icon(
                Icons.anchor_rounded,
                color: _accentColor,
                size: 35.0,
              )
            : Transform.rotate(
                angle: -40 * pi / 180,
                child: Icon(
                  Icons.anchor_rounded,
                  color: _accentColor,
                  size: 35.0,
                ),
              ),
      ),
      onPressed: () => anchorHandler(),
      backgroundColor: _primaryColor.withOpacity(0.65),
    );
  }
}
