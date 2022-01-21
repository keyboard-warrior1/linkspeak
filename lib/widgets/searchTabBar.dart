import 'package:flutter/material.dart';

class SearchTabBar extends StatefulWidget {
  final TabController tabController;
  const SearchTabBar(this.tabController);
  @override
  _SearchTabBarState createState() => _SearchTabBarState();
}

class _SearchTabBarState extends State<SearchTabBar> {
  @override
  Widget build(BuildContext context) {
    final Size _querySize = MediaQuery.of(context).size;
    final double _deviceHeight = _querySize.height;
    final Color _primarySwatch = Theme.of(context).primaryColor;
    final Widget _peopleTab = Container(
      height: double.infinity,
      child: const Center(
        child: const Text(
          'People',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19.0,
          ),
        ),
      ),
    );
    final Widget _topicsTab = Container(
      height: double.infinity,
      child: const Center(
        child: const Text(
          'Topics',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19.0,
          ),
        ),
      ),
    );
    final Widget _clubsTab = Container(
      height: double.infinity,
      child: const Center(
        child: const Text(
          'Clubs',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19.0,
          ),
        ),
      ),
    );
    final TabBar _tabbar = TabBar(
      controller: widget.tabController,
      indicatorColor: _primarySwatch,
      unselectedLabelColor: Colors.grey,
      labelColor: _primarySwatch,
      tabs: [
        _peopleTab,
        _topicsTab,
        _clubsTab,
      ],
    );
    final Widget bar = Container(
      height: _deviceHeight * 0.045,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: _tabbar,
    );
    return bar;
  }
}
