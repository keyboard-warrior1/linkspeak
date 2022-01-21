import 'package:flutter/material.dart';
import '../routes.dart';
import '../models/screenArguments.dart';
import 'topicChip.dart';

class TopicResult extends StatelessWidget {
  final String name;
  final int numOfPosts;
  const TopicResult(this.name, this.numOfPosts);
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
    return TextButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        final screenArgs = TopicScreenArgs(name);
        Navigator.of(context)
            .pushNamed(RouteGenerator.topicPostsScreen, arguments: screenArgs);
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
          const EdgeInsets.all(0.0),
        ),
      ),
      child: ListTile(
        enabled: false,
        horizontalTitleGap: 5.0,
        contentPadding: const EdgeInsets.all(8.0),
        leading: TopicChip(name, null, null, Colors.white, FontWeight.normal),
        title: Text(
          _optimisedNumbers(numOfPosts),
          softWrap: false,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }
}
