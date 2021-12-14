import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';

class ProfileTabBar extends StatefulWidget {
  final int numOfPosts;
  final TabController tabController;
  final bool imBlocked;
  const ProfileTabBar(this.numOfPosts, this.tabController, this.imBlocked);
  @override
  _ProfileTabBarState createState() => _ProfileTabBarState();
}

class _ProfileTabBarState extends State<ProfileTabBar> {
  String _optimisedNumbers(num value) {
    if (value < 1000) {
      return '${value.toString()}';
    } else if (value >= 1000) {
      num dividedVal = value / 1000;
      return '${dividedVal.toStringAsFixed(1)}K';
    } else if (value >= 1000000) {
      num dividedVal = value / 1000000;
      return '${dividedVal.toStringAsFixed(1)}M';
    } else if (value >= 1000000000) {
      num dividedVal = value / 1000000000;
      return '${dividedVal.toStringAsFixed(1)}B';
    }
    return 'null';
  }

  @override
  Widget build(BuildContext context) {
    final Size _querySize = MediaQuery.of(context).size;
    final double _deviceHeight = _querySize.height;
    final Color _primarySwatch = Theme.of(context).primaryColor;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final Widget _postsTab = Container(
      height: double.infinity,
      child: Center(
        child: (widget.numOfPosts != 0)
            ? Text(
                (widget.imBlocked && !myUsername.startsWith('Linkspeak'))
                    ? 'Posts'
                    : 'Posts ${_optimisedNumbers(widget.numOfPosts)}',
                style: const TextStyle(
                  fontSize: 19.0,
                ),
              )
            : const Text(
                'Posts',
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
    final TabBar _tabbar = TabBar(
      controller: widget.tabController,
      indicatorColor: _primarySwatch,
      unselectedLabelColor: Colors.grey,
      labelColor: _primarySwatch,
      tabs: [
        _postsTab,
        _topicsTab,
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
