import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/placesScreenProvider.dart';
import '../common/peopleClubsBar.dart';
import '../common/settingsBar.dart';
import 'placeList.dart';
import 'placeScreenMap.dart';

class PlacePosts extends StatefulWidget {
  const PlacePosts();

  @override
  State<PlacePosts> createState() => _PlacePostsState();
}

class _PlacePostsState extends State<PlacePosts>
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
    final help = Provider.of<PlacesScreenProvider>(context, listen: false);
    final String _topicName = help.placeName;
    final dynamic place = help.place;
    String _displayTopicName = _topicName;
    if (_topicName.length > 25)
      _displayTopicName = '${_topicName.substring(0, 25).trim()}..';
    const theMap = const PlaceScreenMap();
    return SizedBox(
        height: _deviceHeight,
        width: _deviceWidth,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SettingsBar(_displayTopicName),
              if (place != null && !kIsWeb) theMap,
              PeopleClubsBar(_controller!),
              Expanded(
                  child: TabBarView(
                      physics: _neverScrollable,
                      controller: _controller,
                      children: <Widget>[
                    const PlacePostList(false),
                    const PlacePostList(true)
                  ]))
            ]));
  }
}
