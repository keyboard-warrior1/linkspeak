import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class PostSkeleton extends StatelessWidget {
  const PostSkeleton();
  @override
  Widget build(BuildContext context) {
    final _skeletonItem = SkeletonItem(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        height: 35.0,
        width: 35.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
    const _widthBox = const SizedBox(width: 15.0);
    return Container(
      height: 400.0,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 7.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const ListTile(
            leading: const SkeletonAvatar(
              style: const SkeletonAvatarStyle(shape: BoxShape.circle),
            ),
            title: const SkeletonLine(
              style: const SkeletonLineStyle(
                width: 125.0,
              ),
            ),
          ),
          SkeletonParagraph(
            style: const SkeletonParagraphStyle(
              lines: 2,
            ),
          ),
          Expanded(
            child: SkeletonItem(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _skeletonItem,
              _widthBox,
              _skeletonItem,
              _widthBox,
              _skeletonItem,
            ],
          )
        ],
      ),
    );
  }
}
