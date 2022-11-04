import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../routes.dart';
import 'topicChip.dart';

class TopicResult extends StatefulWidget {
  final String name;
  const TopicResult(this.name);

  @override
  State<TopicResult> createState() => _TopicResultState();
}

class _TopicResultState extends State<TopicResult> {
  int _numOfPosts = 0;
  late Future<void> _getTopic;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getTopic() async {
    final topic = await firestore.collection('Topics').doc(widget.name).get();
    if (topic.exists) {
      final numOfPosts = topic.get('count');
      _numOfPosts = numOfPosts;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _getTopic = getTopic();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getTopic,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError)
            return TextButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  final screenArgs = TopicScreenArgs(widget.name);
                  Navigator.of(context).pushNamed(
                      RouteGenerator.topicPostsScreen,
                      arguments: screenArgs);
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                        const EdgeInsets.all(0.0))),
                child: ListTile(
                    enabled: false,
                    horizontalTitleGap: 5.0,
                    contentPadding: const EdgeInsets.all(8.0),
                    leading: TopicChip(widget.name, null, null, Colors.white,
                        FontWeight.normal),
                    title: const Text('',
                        softWrap: false,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            color: Colors.transparent, fontSize: 15.0))));

          return TextButton(
              key: ValueKey<String>(widget.name),
              onPressed: () {
                FocusScope.of(context).unfocus();
                final screenArgs = TopicScreenArgs(widget.name);
                Navigator.of(context).pushNamed(RouteGenerator.topicPostsScreen,
                    arguments: screenArgs);
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                      const EdgeInsets.all(0.0))),
              child: ListTile(
                  enabled: false,
                  horizontalTitleGap: 5.0,
                  contentPadding: const EdgeInsets.all(8.0),
                  leading: TopicChip(
                      widget.name, null, null, Colors.white, FontWeight.normal),
                  title: Text(General.optimisedNumbers(_numOfPosts),
                      softWrap: false,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 15.0))));
        });
  }
}
