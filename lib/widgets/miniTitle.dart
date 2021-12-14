import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profileImage.dart';
import 'adaptiveText.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/fullPostHelper.dart';
import '../routes.dart';

class MiniTitle extends StatelessWidget {
  const MiniTitle();

  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceWidth = _sizeQuery.width;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final helper = Provider.of<FullHelper>(context, listen: false);
    final String username = helper.posterId;
    final String userIMG = helper.userImageUrl;
    void _goProfile() {
      if (username == myUsername) {
      } else {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: username);

        Navigator.pushNamed(
          context,
          RouteGenerator.posterProfileScreen,
          arguments: args,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: _goProfile,
            child: ProfileImage(
              username: username,
              url: userIMG,
              factor: 0.05,
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
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0,
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
