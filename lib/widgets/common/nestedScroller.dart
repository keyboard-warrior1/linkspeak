import 'package:flutter/material.dart';

class NestedScroller extends StatelessWidget {
  final Widget child;
  final ScrollController controller;
  const NestedScroller({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) =>
      NotificationListener<OverscrollNotification>(
          onNotification: (OverscrollNotification value) {
            if (value.overscroll < 0 &&
                controller.offset + value.overscroll <= 0) {
              if (controller.offset != 0) controller.jumpTo(0);
              return true;
            }
            if (controller.offset + value.overscroll >=
                controller.position.maxScrollExtent) {
              if (controller.offset != controller.position.maxScrollExtent)
                controller.jumpTo(controller.position.maxScrollExtent);
              return true;
            }
            controller.jumpTo(controller.offset + value.overscroll);
            return true;
          },
          child: child);
}
/*NotificationListener<OverscrollNotification>(
          onNotification: (OverscrollNotification value) {
            if (value.overscroll < 0 &&
                profileScrollController.offset + value.overscroll <= 0) {
              if (profileScrollController.offset != 0)
                profileScrollController.jumpTo(0);
              return true;
            }
            if (profileScrollController.offset + value.overscroll >=
                profileScrollController.position.maxScrollExtent) {
              if (profileScrollController.offset !=
                  profileScrollController.position.maxScrollExtent)
                profileScrollController
                    .jumpTo(profileScrollController.position.maxScrollExtent);
              return true;
            }
            profileScrollController
                .jumpTo(profileScrollController.offset + value.overscroll);
            return true;
          },
          child:*/