import 'package:flutter/material.dart';

import '../../general.dart';
import '../../routes.dart';
import '../../widgets/common/noglow.dart';
import '../../widgets/common/settingsBar.dart';
import '../widgets/Misc/navigationTile.dart';

class MainControlScreen extends StatelessWidget {
  const MainControlScreen();

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final _height = _size.height;
    final _width = General.widthQuery(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: _height,
                width: _width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SettingsBar('Control'),
                      Expanded(
                          child: Noglow(
                              child: ListView(children: <Widget>[
                        NavigationTile(
                            handler: () {
                              Navigator.pushNamed(
                                  context, RouteGenerator.generalControl);
                            },
                            icon: Icons.account_tree_rounded,
                            screenName: 'General'),
                        NavigationTile(
                            handler: () {
                              Navigator.pushNamed(
                                  context, RouteGenerator.dailyControl);
                            },
                            icon: Icons.calendar_month_rounded,
                            screenName: 'Daily'),
                      ])))
                    ]))));
  }
}
