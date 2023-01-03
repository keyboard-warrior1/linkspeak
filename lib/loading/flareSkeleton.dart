import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class FlareSkeleton extends StatelessWidget {
  const FlareSkeleton();
  @override
  Widget build(BuildContext context) => SkeletonItem(
      child: Container(
          height: 150.0,
          width: 110.0,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                  decoration: BoxDecoration(color: Colors.grey.shade200)))));
}
