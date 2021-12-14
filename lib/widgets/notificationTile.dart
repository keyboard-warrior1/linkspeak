import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import '../models/notification.dart';

class NotificationTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final MyNotification? mykey;
  final Color mainIconColor;
  final Color badgeColor;
  final String badgeText;
  final bool navigate;
  final String? routeName;
  final bool enabled;

  const NotificationTile({
    required this.title,
    required this.mykey,
    required this.icon,
    required this.mainIconColor,
    required this.badgeColor,
    required this.badgeText,
    required this.navigate,
    required this.routeName,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      child: Card(
        shadowColor: Colors.grey.shade300,
        color: Colors.white,
        margin: const EdgeInsets.all(
          .5,
        ),
        elevation: 9.0,
        child: ListTile(
          enabled: enabled,
          onTap: () {
            if (navigate) {
              Navigator.of(context).pushNamed(routeName!);
            }
          },
          enableFeedback: false,
          leading: Icon(
            icon,
            color: mainIconColor,
            size: 35.0,
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10.0),
              Badge(
                elevation: 0.0,
                toAnimate: false,
                badgeColor: badgeColor,
                borderRadius: BorderRadius.circular(5.0),
                shape: BadgeShape.square,
                badgeContent: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Stack(
                      children: <Widget>[
                        Text(
                          badgeText,
                          softWrap: false,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = .5
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          badgeText,
                          softWrap: false,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
