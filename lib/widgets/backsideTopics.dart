import 'package:flutter/material.dart';
import 'topicChip.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../providers/fullPostHelper.dart';
import '../providers/otherProfileProvider.dart';
import '../models/screenArguments.dart';
import 'adaptiveText.dart';

class BacksideTopics extends StatelessWidget {
  final ScrollController scrollController;
  final bool isInOtherProfile;
  const BacksideTopics(this.scrollController, this.isInOtherProfile);

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).primaryColor;
    final helper = Provider.of<FullHelper>(context, listen: false);
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final List<String> topics = helper.postTopics;
    if (isInOtherProfile) {
      _primaryColor =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
    }
    return (topics.isNotEmpty)
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: const Radius.circular(10.0),
                bottomLeft: const Radius.circular(10.0),
              ),
            ),
            child: NotificationListener<OverscrollNotification>(
              onNotification: (OverscrollNotification value) {
                if (value.overscroll < 0 &&
                    scrollController.offset + value.overscroll <= 0) {
                  if (scrollController.offset != 0) scrollController.jumpTo(0);
                  return true;
                }
                if (scrollController.offset + value.overscroll >=
                    scrollController.position.maxScrollExtent) {
                  if (scrollController.offset !=
                      scrollController.position.maxScrollExtent)
                    scrollController
                        .jumpTo(scrollController.position.maxScrollExtent);
                  return true;
                }
                scrollController
                    .jumpTo(scrollController.offset + value.overscroll);
                return true;
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 55.0),
                shrinkWrap: true,
                children: <Widget>[
                  Wrap(
                    children: <Widget>[
                      ...topics.map(
                        (name) {
                          void _visitTopic(String topicName) {
                            final TopicScreenArgs screenArgs =
                                TopicScreenArgs(topicName);
                            Navigator.pushNamed(
                              context,
                              RouteGenerator.topicPostsScreen,
                              arguments: screenArgs,
                            );
                          }

                          return GestureDetector(
                            onTap: () => _visitTopic(name),
                            child: Container(
                              margin: const EdgeInsets.all(
                                1.0,
                              ),
                              child: TopicChip(name, null, null, Colors.white,
                                  FontWeight.normal, _primaryColor),
                            ),
                          );
                        },
                      ).toList(),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: const Radius.circular(10.0),
                bottomLeft: const Radius.circular(10.0),
              ),
            ),
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
                      padding: const EdgeInsets.all(
                        21.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          31.0,
                        ),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Text(
                        'No topics added',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 35.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
