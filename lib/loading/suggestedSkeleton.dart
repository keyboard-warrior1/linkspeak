import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class SuggestedSkeleton extends StatelessWidget {
  const SuggestedSkeleton();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _deviceHeight = size.height;
    final _deviceWidth = size.width;
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
        height: _deviceHeight * 0.375,
        width: _deviceWidth * 0.5,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Card(
                margin: const EdgeInsets.all(0),
                borderOnForeground: false,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Spacer(),
                      SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                              height: _deviceHeight * 0.10,
                              width: _deviceHeight * 0.10,
                              shape: BoxShape.circle)),
                      const SizedBox(height: 10),
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SkeletonLine(
                                style: SkeletonLineStyle(
                                    height: 25, width: _deviceWidth * 0.4))
                          ]),
                      const Spacer(),
                    ]))));
  }
}
