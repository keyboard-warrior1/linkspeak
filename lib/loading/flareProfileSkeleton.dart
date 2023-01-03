import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import '../general.dart';
import '../loading/flareCollectionSkeleton.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/title.dart';

class FlareProfileSkeleton extends StatelessWidget {
  const FlareProfileSkeleton();
  Widget buildBackButton(BuildContext context, double deviceWidth) {
    return Align(
      alignment: Alignment.topLeft,
      child: OptimisedText(
        minWidth: deviceWidth * 0.5,
        maxWidth: deviceWidth * 0.65,
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
    );
  }

  Widget giveStatWidget() {
    return SkeletonItem(
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    const SizedBox _widthBox = const SizedBox(width: 30.0);
    const _heightBox = const SizedBox(height: 15);
    const _mediumHeightBox = const SizedBox(height: 30);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Noglow(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0),
            children: <Widget>[
              SkeletonItem(
                child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade300),
              ),
              _heightBox,
              ListTile(
                horizontalTitleGap: 5,
                leading: SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    width: _deviceHeight * 0.05,
                    height: _deviceHeight * 0.05,
                    shape: BoxShape.circle,
                  ),
                ),
                title: const SkeletonLine(
                  style: SkeletonLineStyle(width: 150),
                ),
              ),
              _heightBox,
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SkeletonParagraph(
                  style: const SkeletonParagraphStyle(
                    lines: 2,
                    lineStyle: const SkeletonLineStyle(width: 200),
                  ),
                ),
              ),
              _heightBox,
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  giveStatWidget(),
                  _widthBox,
                  giveStatWidget(),
                  _widthBox,
                  giveStatWidget(),
                ],
              ),
              _mediumHeightBox,
              for (var i = 0; i < 7; i++) const FlareCollectionSkeleton(),
            ],
          ),
        ),
        buildBackButton(context, _deviceWidth),
      ],
    );
  }
}
