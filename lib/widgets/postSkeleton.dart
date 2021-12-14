import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class PostSkeleton extends StatelessWidget {
  const PostSkeleton();

  @override
  Widget build(BuildContext context) {
    const Widget heightBox = SizedBox(height: 15.0);
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 7.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              const SkeletonAvatar(
                style: const SkeletonAvatarStyle(
                  shape: BoxShape.circle,
                  borderRadius: BorderRadius.all(const Radius.circular(0.0)),
                ),
              ),
              const SizedBox(width: 10.0),
              const SkeletonLine(
                style: const SkeletonLineStyle(width: 100.0),
              )
            ],
          ),
          heightBox,
          SkeletonParagraph(
            style: const SkeletonParagraphStyle(
              lines: 7,
              lineStyle: SkeletonLineStyle(
                randomLength: true,
              ),
            ),
          ),
          heightBox,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                const SkeletonAvatar(
                  style: const SkeletonAvatarStyle(
                    height: 25.0,
                    width: 25.0,
                  ),
                ),
                const SkeletonAvatar(
                  style: const SkeletonAvatarStyle(
                    height: 25.0,
                    width: 25.0,
                  ),
                ),
                const SkeletonAvatar(
                  style: const SkeletonAvatarStyle(
                    height: 25.0,
                    width: 25.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
