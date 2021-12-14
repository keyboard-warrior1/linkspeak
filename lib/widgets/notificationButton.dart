import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton();
  @override
  Widget build(BuildContext context) {
    final MyProfile myProfile = Provider.of<MyProfile>(context);
    final int myNumOfNewLinksNotifs = myProfile.myNumOfNewLinksNotifs;
    final int myNumOfNewLinkedNotifs = myProfile.myNumOfNewLinkedNotifs;
    final int myNumOfLinkRequestNotifs = myProfile.myNumOfLinkRequestNotifs;
    final int myNumOfPostLikesNotifs = myProfile.myNumOfPostLikesNotifs;
    final int myNumOfPostCommentsNotifs = myProfile.myNumOfPostCommentsNotifs;
    final int myNumOfCommentRepliesNotifs =
        myProfile.myNumOfCommentRepliesNotifs;
    final int myNumOfCommentsRemovedNotifs =
        myProfile.myNumOfCommentsRemovedNotifs;
    final int myNumOfPostsRemovedNotifs = myProfile.myNumOfPostsRemovedNotifs;
    final bool hasNotifications = myNumOfNewLinksNotifs != 0 ||
        myNumOfNewLinkedNotifs != 0 ||
        myNumOfLinkRequestNotifs != 0 ||
        myNumOfPostLikesNotifs != 0 ||
        myNumOfPostCommentsNotifs != 0 ||
        myNumOfCommentRepliesNotifs != 0 ||
        myNumOfCommentsRemovedNotifs != 0 ||
        myNumOfPostsRemovedNotifs != 0;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 50.0,
        maxWidth: 45.0,
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, RouteGenerator.notificationScreen);
          },
          tooltip: 'Alerts',
          icon: Stack(
            children: <Widget>[
              Center(
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                  size: 30.0,
                ),
              ),
              if (hasNotifications)
                Align(
                  alignment: Alignment(0.65, -0.55),
                  child: Container(
                    height: 10.0,
                    width: 10.0,
                    decoration: BoxDecoration(
                      color: Colors.lightGreenAccent.shade400,
                      border: Border.all(
                        color: Colors.black,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
