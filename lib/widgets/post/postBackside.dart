import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../providers/appBarProvider.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/otherProfileProvider.dart';
import 'backsideMap.dart';
import 'backsideTopics.dart';

class PostBackSide extends StatefulWidget {
  final void Function() toggleCard;
  final ScrollController controller;
  final bool isInOtherProfile;
  final bool isInFeed;
  final bool isInClubFeed;
  const PostBackSide({
    required this.toggleCard,
    required this.controller,
    required this.isInOtherProfile,
    required this.isInFeed,
    required this.isInClubFeed,
  });

  @override
  _PostBackSideState createState() => _PostBackSideState();
}

class _PostBackSideState extends State<PostBackSide>
    with SingleTickerProviderStateMixin {
  late final TabController? _controller;
  late final ScrollController _scrollController;
  bool hasTopics = false;
  _handleTabSelection() {
    if (_controller!.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final postLocation =
        Provider.of<FullHelper>(context, listen: false).getLocation;
    final postTopics =
        Provider.of<FullHelper>(context, listen: false).postTopics;
    _controller = TabController(
        length: (postLocation != '' && postTopics.isNotEmpty)
            ? 2
            : (postLocation == '' && postTopics.isEmpty)
                ? 0
                : 1,
        vsync: this);
    _controller?.addListener(_handleTabSelection);
    if (postTopics.isNotEmpty) {
      hasTopics = true;
      _scrollController = ScrollController();
      if (widget.isInFeed || widget.isInClubFeed)
        _scrollController.addListener(() {
          if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            Provider.of<AppBarProvider>(context, listen: false).hideBar();
          }
          if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            Provider.of<AppBarProvider>(context, listen: false).showbar();
          }
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.removeListener(() {});
    _controller?.dispose();
    if (hasTopics) {
      if (widget.isInFeed || widget.isInClubFeed)
        _scrollController.removeListener(() {});
      _scrollController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color _primarySwatch = Theme.of(context).colorScheme.primary;
    Color _accentColor = Theme.of(context).colorScheme.secondary;
    const _neverScrollable = NeverScrollableScrollPhysics();
    final helper = Provider.of<FullHelper>(context, listen: false);
    final List<String> postImgUrls = helper.postImgUrls;
    final bool withMedia = postImgUrls.isNotEmpty;
    final postLocation = helper.getLocation;
    final postTopics = helper.postTopics;
    final double givenHeight = helper.occupiedHeight;
    final double givenWidth = helper.occupiedWidth;
    if (widget.isInOtherProfile) {
      _primarySwatch =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    final Widget _topicsTab = Container(
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

    final Widget _mapTab = Container(
      child: const Center(
        child: const Text(
          'Place',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19.0,
          ),
        ),
      ),
    );
    final TabBar _tabbar = TabBar(
      controller: _controller,
      indicatorColor: Colors.transparent,
      unselectedLabelColor: Colors.grey,
      labelColor: _primarySwatch,
      automaticIndicatorColorAdjustment: false,
      indicator: const UnderlineTabIndicator(
        borderSide: const BorderSide(width: 2.0, color: Colors.transparent),
      ),
      tabs: [
        if (postTopics.isNotEmpty) _topicsTab,
        if (postLocation != '') _mapTab,
      ],
    );
    final Widget bar = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(10.0),
          topLeft: const Radius.circular(10.0),
        ),
      ),
      height: 50,
      width: double.infinity,
      child: _tabbar,
    );
    return Container(
      height: givenHeight,
      width: givenWidth,
      margin: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 7.0,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          bar,
          Expanded(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: TabBarView(
                    physics: _neverScrollable,
                    controller: _controller,
                    children: <Widget>[
                      if (postTopics.isNotEmpty)
                        BacksideTopics(widget.controller,
                            widget.isInOtherProfile, _scrollController),
                      if (postLocation != '')
                        PostWidgetMap(widget.isInOtherProfile),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (withMedia)
                                ? _primarySwatch.withOpacity(0.5)
                                : _primarySwatch,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => widget.toggleCard(),
                            icon: Icon(
                              Icons.info_outline,
                              color: (withMedia) ? _accentColor : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
