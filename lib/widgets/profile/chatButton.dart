import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/screenArguments.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../../routes.dart';

class ChatButton extends StatelessWidget {
  const ChatButton();
  @override
  Widget build(BuildContext context) {
    final otherProfile = Provider.of<OtherProfile>(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String otherUsername = otherProfile.getUsername;
    final imBlocked = otherProfile.imBlocked;
    final isBanned = otherProfile.isBanned;
    final imLinkedToThem = otherProfile.imLinkedToThem;
    final theyLinkedToMe = otherProfile.linkedToMe;
    final activityStatus = otherProfile.activityStatus;
    final bool isOnline = activityStatus == 'Online';
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    return (otherUsername.startsWith('Linkspeak'))
        ? Stack(children: <Widget>[
            Positioned.fill(
                child: Container(
                    decoration: BoxDecoration(
                        color: _accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: _primaryColor)))),
            Align(
                alignment: Alignment.center,
                child: Icon(Icons.verified, color: _primaryColor, size: 25.0))
          ])
        : IconButton(
            icon: Icon(customIcons.MyFlutterApp.chats,
                color: (isOnline)
                    ? Colors.lightGreenAccent.shade400
                    : Colors.grey.shade400,
                size: ((imBlocked ||
                            !imLinkedToThem ||
                            isBanned ||
                            !theyLinkedToMe) &&
                        !myUsername.startsWith('Linkspeak'))
                    ? 0
                    : 25.0),
            onPressed: () {
              if ((imBlocked || !imLinkedToThem || !theyLinkedToMe) &&
                  !myUsername.startsWith('Linkspeak')) {
              } else {
                final ChatScreenArgs args = ChatScreenArgs(
                    chatID: otherUsername, comeFromProfile: true);
                Navigator.pushNamed(context, RouteGenerator.chatScreen,
                    arguments: args);
              }
            },
          );
  }
}
