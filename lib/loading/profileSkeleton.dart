import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import '../loading/postsLoading.dart';
import '../my_flutter_app_icons.dart' as customIcons;

class ProfileLoading extends StatelessWidget {
  const ProfileLoading();

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    const ScrollPhysics _neverScrollable = NeverScrollableScrollPhysics();
    return Stack(
      children: <Widget>[
        Container(
          child: ListView(
            physics: _neverScrollable,
            children: <Widget>[
              SizedBox(height: _deviceHeight * 0.12),
              SizedBox(
                height: 500.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(
                        30.50,
                      ),
                      topRight: const Radius.circular(
                        30.50,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(
                        30.0,
                      ),
                      topRight: const Radius.circular(
                        30.0,
                      ),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 500,
                          maxHeight: 500,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              color: _primarySwatch,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  IconButton(
                                    tooltip: 'back',
                                    icon: const Icon(
                                      customIcons.MyFlutterApp.curve_arrow,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              horizontalTitleGap: 0,
                              leading: const SkeletonAvatar(
                                style: const SkeletonAvatarStyle(
                                  width: 100.0,
                                  height: 100.0,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: const SkeletonLine(
                                style: const SkeletonLineStyle(width: 175.0),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const SkeletonLine(
                                  style: const SkeletonLineStyle(width: 50.0),
                                ),
                                const SkeletonLine(
                                  style: const SkeletonLineStyle(width: 50.0),
                                ),
                                const SkeletonLine(
                                  style: const SkeletonLineStyle(width: 50.0),
                                ),
                              ],
                            ),
                            SkeletonParagraph(
                              style: SkeletonParagraphStyle(
                                lineStyle: const SkeletonLineStyle(
                                  width: 325.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: const PostsLoading(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
