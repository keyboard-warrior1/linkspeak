import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/appBarProvider.dart';
import '../common/myLinkify.dart';
import '../common/nestedScroller.dart';

class NoMediaPostDescriptionPreview extends StatefulWidget {
  final String description;
  final ScrollController controller;
  final bool isInFeed;
  final bool isInClubFeed;
  const NoMediaPostDescriptionPreview(
      this.description, this.controller, this.isInFeed, this.isInClubFeed);

  @override
  State<NoMediaPostDescriptionPreview> createState() =>
      _NoMediaPostDescriptionPreviewState();
}

class _NoMediaPostDescriptionPreviewState
    extends State<NoMediaPostDescriptionPreview> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    super.dispose();
    if (widget.isInFeed || widget.isInClubFeed)
      _scrollController.removeListener(() {});
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final String preview;
    if (widget.description.length > 1000) {
      preview = widget.description.substring(0, 1000);
      return ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: _deviceHeight * 0.15,
              maxHeight: _deviceHeight * 0.55,
              minWidth: _deviceWidth,
              maxWidth: _deviceWidth),
          child: Container(
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              child: NestedScroller(
                  controller: widget.controller,
                  child: SingleChildScrollView(
                      physics: const ScrollPhysics(),
                      controller: _scrollController,
                      child: MyLinkify(
                          text: preview + '...',
                          style: const TextStyle(
                              fontFamily: 'Roboto', fontSize: 17.0),
                          textDirection: TextDirection.ltr,
                          maxLines: 1500)))));
    } else {
      return ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: _deviceHeight * 0.15,
              maxHeight: _deviceHeight * 0.55,
              minWidth: _deviceWidth,
              maxWidth: _deviceWidth),
          child: Container(
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              child: NestedScroller(
                  controller: widget.controller,
                  child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const ScrollPhysics(),
                      child: MyLinkify(
                          text: '${widget.description}',
                          style: const TextStyle(
                              fontFamily: 'Roboto', fontSize: 17.0),
                          textDirection: TextDirection.ltr,
                          maxLines: 1500)))));
    }
  }
}
