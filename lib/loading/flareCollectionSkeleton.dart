import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import 'flareSkeleton.dart';

class FlareCollectionSkeleton extends StatelessWidget {
  const FlareCollectionSkeleton();
  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
          height: 320.0,
          margin: const EdgeInsets.only(top: 5.50, bottom: 5.50),
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          width: double.infinity,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                    contentPadding: const EdgeInsets.only(left: 8.0),
                    horizontalTitleGap: 10.0,
                    leading: const SkeletonAvatar(
                        style:
                            const SkeletonAvatarStyle(shape: BoxShape.circle)),
                    title: const SkeletonLine(
                        style: const SkeletonLineStyle(width: 125.0))),
                Container(
                    height: 200,
                    child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        children: [
                          for (var i = 0; i < 10; i++) const FlareSkeleton()
                        ]))
              ])));
}
