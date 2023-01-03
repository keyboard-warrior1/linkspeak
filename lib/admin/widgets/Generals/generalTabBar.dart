import 'package:flutter/material.dart';

import '../../../my_flutter_app_icons.dart' as customIcons;

class GeneralTabBar extends StatelessWidget {
  final TabController tabController;
  final bool showReports;
  final bool showWatchList;
  final bool showBanned;
  final bool showProhibited;
  final bool showReviewals;
  const GeneralTabBar(
      {required this.tabController,
      required this.showReports,
      required this.showWatchList,
      required this.showBanned,
      required this.showProhibited,
      required this.showReviewals});
  Widget buildTab(IconData icon) => Container(child: Center(child: Icon(icon)));
  @override
  Widget build(BuildContext context) {
    return TabBar(
        controller: tabController,
        indicatorColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey,
        labelColor: Theme.of(context).colorScheme.primary,
        tabs: <Widget>[
          if (showReports) buildTab(Icons.flag),
          if (showWatchList) buildTab(Icons.remove_red_eye),
          if (showProhibited) buildTab(customIcons.MyFlutterApp.no_stopping),
          if (showBanned) buildTab(Icons.person_off),
          if (showReviewals) buildTab(Icons.warning)
        ]);
  }
}
