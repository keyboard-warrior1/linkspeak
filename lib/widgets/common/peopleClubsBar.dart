import 'package:flutter/material.dart';
import '../../general.dart';

class PeopleClubsBar extends StatefulWidget {
  final TabController tabController;
  const PeopleClubsBar(this.tabController);
  @override
  _PeopleClubsBarState createState() => _PeopleClubsBarState();
}

class _PeopleClubsBarState extends State<PeopleClubsBar> {
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Size _querySize = MediaQuery.of(context).size;
    final double _deviceHeight = _querySize.height;
    Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Widget _postsTab = Container(
        height: double.infinity,
        child: Center(
            child: Text(lang.widgets_common8,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0))));
    final Widget _topicsTab = Container(
        height: double.infinity,
        child: Center(
            child: Text(lang.widgets_common9,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0))));
    final TabBar _tabbar = TabBar(
        controller: widget.tabController,
        indicatorColor: _primarySwatch,
        unselectedLabelColor: Colors.grey,
        automaticIndicatorColorAdjustment: false,
        indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Colors.transparent)),
        labelColor: _primarySwatch,
        tabs: [_postsTab, _topicsTab]);
    final Widget bar = Container(
        height: _deviceHeight * 0.045,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: _tabbar);
    return bar;
  }
}
