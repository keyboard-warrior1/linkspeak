import 'package:flutter/material.dart';

import 'flareCollectionSkeleton.dart';

class FlaresLoading extends StatelessWidget {
  const FlaresLoading();

  @override
  Widget build(BuildContext context) {
    const ScrollPhysics _neverScrollable = NeverScrollableScrollPhysics();
    final double _deviceHeight = MediaQuery.of(context).size.height;
    return ListView(
        physics: _neverScrollable,
        padding: EdgeInsets.only(top: _deviceHeight * 0.05, bottom: 60.0),
        shrinkWrap: true,
        children: <Widget>[
          for (var i = 0; i < 7; i++) const FlareCollectionSkeleton()
        ]);
  }
}
