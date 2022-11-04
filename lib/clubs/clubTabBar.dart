import 'package:flutter/material.dart';

class ClubTabBar extends StatefulWidget {
  final TabController tabController;
  const ClubTabBar(this.tabController);
  @override
  _ClubTabBarState createState() => _ClubTabBarState();
}

class _ClubTabBarState extends State<ClubTabBar> {
  @override
  Widget build(BuildContext context) {
    final Size _querySize = MediaQuery.of(context).size;
    final double _deviceHeight = _querySize.height;
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Widget _postsTab = Container(
        height: double.infinity,
        child: Center(
            child: const Text('Posts',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19.0))));
    final Widget _aboutTab = Container(
        height: double.infinity,
        child: const Center(
            child: const Text('About',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19.0))));
    final Widget _topicsTab = Container(
        height: double.infinity,
        child: const Center(
            child: const Text('Topics',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19.0))));
    final TabBar _tabbar = TabBar(
        controller: widget.tabController,
        indicatorColor: _primarySwatch,
        unselectedLabelColor: Colors.grey,
        labelColor: _primarySwatch,
        tabs: [_postsTab, _aboutTab, _topicsTab]);
    final Widget bar = Container(
        height: _deviceHeight * 0.045,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
        child: _tabbar);
    return bar;
  }
}
