import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/otherProfileProvider.dart';
import '../../routes.dart';
import '../common/adaptiveText.dart';
import '../common/nestedScroller.dart';
import '../common/noglow.dart';
import '../topics/topicChip.dart';

class BacksideTopics extends StatefulWidget {
  final ScrollController scrollController;
  final ScrollController topicScrollController;
  final bool isInOtherProfile;
  const BacksideTopics(
    this.scrollController,
    this.isInOtherProfile,
    this.topicScrollController,
  );

  @override
  State<BacksideTopics> createState() => _BacksideTopicsState();
}

class _BacksideTopicsState extends State<BacksideTopics>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    final helper = Provider.of<FullHelper>(context, listen: false);
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final List<String> topics = helper.postTopics;
    if (widget.isInOtherProfile) {
      _primaryColor =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
    }
    super.build(context);
    return (topics.isNotEmpty)
        ? Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: const Radius.circular(10.0),
                    bottomLeft: const Radius.circular(10.0))),
            child: Noglow(
                child: NestedScroller(
                    controller: widget.scrollController,
                    child: ListView(
                        controller: widget.topicScrollController,
                        padding: const EdgeInsets.only(bottom: 55.0),
                        shrinkWrap: true,
                        children: <Widget>[
                          Wrap(children: <Widget>[
                            ...topics.map((name) {
                              void _visitTopic(String topicName) {
                                final TopicScreenArgs screenArgs =
                                    TopicScreenArgs(topicName);
                                Navigator.pushNamed(
                                    context, RouteGenerator.topicPostsScreen,
                                    arguments: screenArgs);
                              }

                              return GestureDetector(
                                  onTap: () => _visitTopic(name),
                                  child: Container(
                                      margin: const EdgeInsets.all(1.0),
                                      child: TopicChip(
                                          name,
                                          null,
                                          null,
                                          Colors.white,
                                          FontWeight.normal,
                                          _primaryColor)));
                            }).toList(),
                          ])
                        ]))))
        : Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: const Radius.circular(10.0),
                    bottomLeft: const Radius.circular(10.0))),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                      child: OptimisedText(
                          minWidth: _deviceWidth * 0.55,
                          maxWidth: _deviceWidth * 0.55,
                          minHeight: _deviceHeight * 0.05,
                          maxHeight: _deviceHeight * 0.10,
                          fit: BoxFit.scaleDown,
                          child: Container(
                              padding: const EdgeInsets.all(21.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(31.0),
                                  border: Border.all(color: Colors.grey)),
                              child: const Text('No topics added',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 35.0)))))
                ]));
  }

  @override
  bool get wantKeepAlive => true;
}
