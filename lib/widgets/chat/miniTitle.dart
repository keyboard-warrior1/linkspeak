import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/adaptiveText.dart';
import '../common/chatprofileImage.dart';

class MiniTitle extends StatelessWidget {
  const MiniTitle();
  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = General.widthQuery(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final helper = Provider.of<FullHelper>(context, listen: false);
    final String username = helper.posterId;
    void _goProfile() {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: username);

      Navigator.pushNamed(
        context,
        (username == myUsername)
            ? RouteGenerator.myProfileScreen
            : RouteGenerator.posterProfileScreen,
        arguments: (username == myUsername) ? null : args,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: _goProfile,
            child: ChatProfileImage(
              username: username,
              factor: 0.04,
              inEdit: false,
              asset: null,
            ),
          ),
          OptimisedText(
            minWidth: _deviceWidth * 0.10,
            maxWidth: _deviceWidth * 0.70,
            minHeight: 10.0,
            maxHeight: 75.0,
            fit: BoxFit.scaleDown,
            child: TextButton(
              onPressed: _goProfile,
              style: ButtonStyle(
                  alignment: Alignment.centerLeft,
                  splashFactory: NoSplash.splashFactory),
              child: Text(
                username,
                textAlign: TextAlign.start,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 17.0,
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
