import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screenArguments.dart';
import '../routes.dart';
import '../providers/myProfileProvider.dart';
import '../providers/otherProfileProvider.dart';
import '../my_flutter_app_icons.dart' as customIcons;

class ChatButton extends StatelessWidget {
  const ChatButton();
  @override
  Widget build(BuildContext context) {
    final otherProfile = Provider.of<OtherProfile>(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String otherUsername = otherProfile.getUsername;
    final imBlocked = otherProfile.imBlocked;
    final imLinkedToThem = otherProfile.imLinkedToThem;
    final activityStatus = otherProfile.activityStatus;
    final bool isOnline = activityStatus == 'Online';
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;

    return (otherUsername.startsWith('Linkspeak'))
        ? Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: _primaryColor),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.verified,
                  color: _primaryColor,
                  size: 31.0,
                ),
              ),
            ],
          )
        : IconButton(
            icon: Icon(
              customIcons.MyFlutterApp.chats,
              color: (isOnline)
                  ? Colors.lightGreenAccent.shade400
                  : Colors.grey.shade400,
              size: ((imBlocked || !imLinkedToThem) &&
                      !myUsername.startsWith('Linkspeak'))
                  ? 0
                  : 31.0,
            ),
            onPressed: () {
              if ((imBlocked || !imLinkedToThem) &&
                  !myUsername.startsWith('Linkspeak')) {
              } else {
                final ChatScreenArgs args = ChatScreenArgs(
                  chatID: otherUsername,
                  comeFromProfile: true,
                );
                Navigator.pushNamed(context, RouteGenerator.chatScreen,
                    arguments: args);
              }
            },
          );
  }
}
