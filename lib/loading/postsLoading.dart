import 'package:flutter/material.dart';

import 'postSkeleton.dart';

class PostsLoading extends StatelessWidget {
  final bool isInFeed;
  const PostsLoading(this.isInFeed);

  @override
  Widget build(BuildContext context) {
    const ScrollPhysics _neverScrollable = NeverScrollableScrollPhysics();
    final double _deviceHeight = MediaQuery.of(context).size.height;
    return ListView(
      padding: (isInFeed)
          ? EdgeInsets.only(top: _deviceHeight * 0.05, bottom: 60.0)
          : null,
      physics: _neverScrollable,
      shrinkWrap: true,
      children: <Widget>[
        for (var i = 0; i < 7; i++) const PostSkeleton(),
      ],
    );
  }
}
