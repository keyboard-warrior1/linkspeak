import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/likedFlareScrollProvider.dart';
import '../widgets/common/settingsBar.dart';
import 'likedFlares.dart';

class LikedFlareScreen extends StatefulWidget {
  const LikedFlareScreen();

  @override
  State<LikedFlareScreen> createState() => _LikedFlareScreenState();
}

class _LikedFlareScreenState extends State<LikedFlareScreen> {
  final scrollHelper = LikedFlareScrollProvider();
  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: null,
      body: SafeArea(
        child: ChangeNotifierProvider.value(
          value: scrollHelper,
          child: SizedBox(
            height: _deviceHeight,
            width: _deviceWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SettingsBar('Liked flares'),
                Expanded(child: const LikedFlares())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
