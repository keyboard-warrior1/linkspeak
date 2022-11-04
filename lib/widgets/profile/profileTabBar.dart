import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';

class ProfileTabBar extends StatefulWidget {
  final TabController tabController;
  final bool isMyProfile;
  const ProfileTabBar(this.tabController, this.isMyProfile);
  @override
  _ProfileTabBarState createState() => _ProfileTabBarState();
}

class _ProfileTabBarState extends State<ProfileTabBar> {
  int numOfPosts = 0;
  bool imBlocked = false;
  bool isBanned = false;
  @override
  Widget build(BuildContext context) {
    final Size _querySize = MediaQuery.of(context).size;
    final double _deviceHeight = _querySize.height;
    Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final String myUsername = Provider.of<MyProfile>(context).getUsername;
    if (widget.isMyProfile) {
      numOfPosts = Provider.of<MyProfile>(context).getNumberOfPosts;
    } else {
      numOfPosts = Provider.of<OtherProfile>(context).getNumberOfPosts;
      imBlocked = Provider.of<OtherProfile>(context).imBlocked;
      isBanned = Provider.of<OtherProfile>(context).isBanned;
      _primarySwatch = Provider.of<OtherProfile>(context).getPrimaryColor;
    }
    final Widget _postsTab = Container(
        height: double.infinity,
        child: Center(
            child: (numOfPosts != 0)
                ? Text(
                    ((imBlocked || isBanned) &&
                            !myUsername.startsWith('Linkspeak'))
                        ? 'Posts'
                        : 'Posts ${General.optimisedNumbers(numOfPosts)}',
                    style: const TextStyle(fontSize: 18.0))
                : const Text('Posts',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18.0))));
    final Widget _topicsTab = Container(
        height: double.infinity,
        child: const Center(
            child: const Text('Topics',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0))));
    final TabBar _tabbar = TabBar(
        controller: widget.tabController,
        indicatorColor: _primarySwatch,
        unselectedLabelColor: Colors.grey,
        labelColor: _primarySwatch,
        tabs: [_postsTab, _topicsTab]);
    final Widget bar = Container(
        height: _deviceHeight * 0.045,
        width: double.infinity,
        child: _tabbar,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200))));
    return bar;
  }
}
