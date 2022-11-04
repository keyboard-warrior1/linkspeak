import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/historyScrollProvider.dart';
import '../widgets/common/settingsBar.dart';
import 'flareHistory.dart';

class FlareHistoryScreen extends StatefulWidget {
  const FlareHistoryScreen();

  @override
  State<FlareHistoryScreen> createState() => _FlareHistoryScreenState();
}

class _FlareHistoryScreenState extends State<FlareHistoryScreen> {
  final scrollHelper = HistoryScrollProvider();
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
                          const SettingsBar('History'),
                          Expanded(child: const FlareHistory())
                        ])))));
  }
}
