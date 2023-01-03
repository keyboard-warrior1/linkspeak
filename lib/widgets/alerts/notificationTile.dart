import 'package:flutter/material.dart';

// import 'package:badges/badges.dart';
import '../../models/notification.dart';
import '../../models/screenArguments.dart';

class NotificationTile extends StatelessWidget {
  final String title;
  final String clubName;
  final String username;
  final MyNotification? mykey;
  final Color badgeColor;
  final String badgeText;
  final bool navigate;
  final String? routeName;
  final bool enabled;
  final bool isClub;
  final bool isFlare;
  final void Function() decreaseNotifs;
  final void Function() addMembers;
  const NotificationTile({
    required this.title,
    required this.mykey,
    required this.badgeColor,
    required this.badgeText,
    required this.navigate,
    required this.routeName,
    required this.enabled,
    required this.isClub,
    required this.clubName,
    required this.decreaseNotifs,
    required this.addMembers,
    required this.isFlare,
    required this.username,
  });

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      child: Card(
          shadowColor: Colors.grey.shade300,
          color: Colors.white,
          margin: const EdgeInsets.all(.5),
          elevation: 9.0,
          child: ListTile(
              enabled: enabled,
              onTap: () {
                if (navigate) {
                  if (isClub) {
                    final ClubRequestsArgs args = ClubRequestsArgs(
                        clubName: clubName,
                        decreaseNotifs: decreaseNotifs,
                        addMembers: addMembers);
                    Navigator.of(context)
                        .pushNamed(routeName!, arguments: args);
                  } else {
                    Navigator.of(context).pushNamed(routeName!);
                  }
                }
              },
              enableFeedback: false,
              title: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(width: 10.0),
                    // Badge(
                    //   elevation: 0.0,
                    //   toAnimate: false,
                    //   badgeColor: badgeColor,
                    //   shape: BadgeShape.circle,
                    //   badgeContent: Center(
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    //       child: Stack(
                    //         children: <Widget>[
                    //           Text(
                    //             badgeText,
                    //             softWrap: false,
                    //             textAlign: TextAlign.center,
                    //             style: TextStyle(
                    //               foreground: Paint()
                    //                 ..style = PaintingStyle.stroke
                    //                 ..strokeWidth = .5
                    //                 ..color = Colors.black,
                    //             ),
                    //           ),
                    //           Text(
                    //             badgeText,
                    //             softWrap: false,
                    //             textAlign: TextAlign.center,
                    //             style: const TextStyle(
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: BoxDecoration(
                            color: badgeColor,
                            // border: Border.all(color: Colors.black),
                            shape: BoxShape.circle))
                  ]))));
}
