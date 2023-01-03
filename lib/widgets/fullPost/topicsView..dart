import 'package:flutter/material.dart';

import '../../models/screenArguments.dart';
import '../../routes.dart';
import '../../general.dart';
import '../topics/topicChip.dart';

class TopicsView extends StatelessWidget {
  final String postID;
  final int numOfTopics;
  final List<String> topics;
  TopicsView({
    required this.numOfTopics,
    required this.postID,
    required this.topics,
  });

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final double deviceHeight = MediaQuery.of(context).size.height;
    return Column(children: <Widget>[
      if (numOfTopics == 0)
        Container(
            height: deviceHeight * 0.3,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          padding: const EdgeInsets.all(17.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(31.0),
                              border: Border.all(color: Colors.grey)),
                          child: Text(lang.widgets_fullPost15,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 33.0))))
                ])),
      if (numOfTopics != 0)
        Padding(
            padding: const EdgeInsets.only(bottom: 85.0),
            child: Wrap(children: <Widget>[
              ...topics.map((topic) {
                final String _name = topic;
                final Widget _chips = GestureDetector(
                    onTap: () {
                      final screenArgs = TopicScreenArgs(_name);
                      Navigator.pushNamed(
                          context, RouteGenerator.topicPostsScreen,
                          arguments: screenArgs);
                    },
                    child: TopicChip(
                        _name, null, null, Colors.white, FontWeight.normal));
                return _chips;
              })
            ]))
    ]);
  }
}
