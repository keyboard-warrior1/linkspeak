import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import '../general.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/title.dart';
import 'postSkeleton.dart';

class ClubLoading extends StatelessWidget {
  const ClubLoading();

  @override
  Widget build(BuildContext context) {
    const Widget _heightBox = SizedBox(height: 25.0);
    final double _deviceWidth = General.widthQuery(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            SkeletonItem(
              child: Container(
                height: 150,
                width: double.infinity,
              ),
            ),
            _heightBox,
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SkeletonAvatar(
                  style: const SkeletonAvatarStyle(
                    width: 150.0,
                    height: 150.0,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            _heightBox,
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                const SkeletonLine(
                  style: const SkeletonLineStyle(width: 100.0),
                ),
              ],
            ),
            _heightBox,
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                const SkeletonLine(
                  style: const SkeletonLineStyle(width: 50.0),
                ),
              ],
            ),
            for (var i = 0; i < 4; i++) const PostSkeleton()
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: OptimisedText(
            minWidth: _deviceWidth * 0.5,
            maxWidth: _deviceWidth * 0.65,
            minHeight: 50.0,
            maxHeight: 50.0,
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  splashColor: Colors.transparent,
                  icon: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: const Icon(
                      customIcons.MyFlutterApp.curve_arrow,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all<double?>(0.0),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                      const EdgeInsets.all(0.0),
                    ),
                    splashFactory: NoSplash.splashFactory,
                    enableFeedback: false,
                  ),
                  onPressed: () {},
                  child: const MyTitle(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
