import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/topicScreenProvider.dart';
import '../common/peopleClubsBar.dart';
import '../common/settingsBar.dart';
import 'topicList.dart';

class TopicPosts extends StatefulWidget {
  const TopicPosts();
  @override
  _TopicPostsState createState() => _TopicPostsState();
}

class _TopicPostsState extends State<TopicPosts>
    with SingleTickerProviderStateMixin {
  late final TabController? _controller;
  _handleTabSelection() {
    if (_controller!.indexIsChanging) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _controller?.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.removeListener(() {});
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    const _neverScrollable = NeverScrollableScrollPhysics();
    final String _topicName =
        Provider.of<TopicScreenProvider>(context, listen: false).getTopicName;
    String _displayTopicName = _topicName;
    if (_topicName.length > 25)
      _displayTopicName = '${_topicName.substring(0, 25).trim()}..';
    return SizedBox(
        height: _deviceHeight,
        width: _deviceWidth,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SettingsBar(_displayTopicName),
              PeopleClubsBar(_controller!),
              Expanded(
                  child: TabBarView(
                      physics: _neverScrollable,
                      controller: _controller,
                      children: <Widget>[
                    const TopicList(false),
                    const TopicList(true)
                  ]))
            ]));
  }
}
