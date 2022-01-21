import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/otherProfileProvider.dart';
import 'backsideTopics.dart';
import 'backsideMap.dart';

class PostBackSide extends StatefulWidget {
  final void Function() toggleCard;
  final double givenHeight;
  final double givenWidth;
  final ScrollController controller;
  final bool isInOtherProfile;
  const PostBackSide({
    required this.toggleCard,
    required this.givenHeight,
    required this.givenWidth,
    required this.controller,
    required this.isInOtherProfile,
  });

  @override
  _PostBackSideState createState() => _PostBackSideState();
}

class _PostBackSideState extends State<PostBackSide>
    with SingleTickerProviderStateMixin {
  late final TabController? _controller;
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
        initialIndex: 0,
        length: (postLocation == '' || postTopics.isEmpty) ? 1 : 2,
        vsync: this);
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
    Color _primarySwatch = Theme.of(context).primaryColor;
    Color _accentColor = Theme.of(context).accentColor;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final List<String> postImgUrls =
        Provider.of<FullHelper>(context, listen: false).postImgUrls;
    final bool withMedia = postImgUrls.isNotEmpty;
    final postLocation =
        Provider.of<FullHelper>(context, listen: false).getLocation;
    final postTopics =
        Provider.of<FullHelper>(context, listen: false).postTopics;
    if (widget.isInOtherProfile) {
      _primarySwatch =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    final Widget _topicsTab = Container(
      width: widget.givenWidth / 2,
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
      width: widget.givenWidth / 2,
      child: const Center(
        child: const Text(
          'Location',
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
        borderSide: BorderSide(width: 2.0, color: Colors.transparent),
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
      height: _deviceHeight * 0.045,
      width: widget.givenWidth,
      child: _tabbar,
    );
    return Container(
      height: widget.givenHeight,
      width: widget.givenWidth,
      margin: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 7.0,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade300)),
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
                    controller: _controller,
                    children: <Widget>[
                      if (postTopics.isNotEmpty)
                        BacksideTopics(
                            widget.controller, widget.isInOtherProfile),
                      if (postLocation != '') const PostWidgetMap(),
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
