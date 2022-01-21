import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import 'adaptiveText.dart';
import 'profileImage.dart';

class UserResult extends StatelessWidget {
  final String username;
  final String img;
  const UserResult({
    required this.username,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    void _visitProfile({required final String username}) {
      FocusScope.of(context).unfocus();
      if ((username == myUsername)) {
      } else {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: username);
        Navigator.pushNamed(
          context,
          (username == myUsername)
              ? RouteGenerator.myProfileScreen
              : RouteGenerator.posterProfileScreen,
          arguments: args,
        );
      }
    }

    return TextButton(
      onPressed: () => _visitProfile(username: username),
      child: Container(
        height: _deviceHeight * 0.07,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 3.0,
            horizontal: 3.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ProfileImage(
                username: username,
                url: img,
                factor: 0.05,
                inEdit: false,
                asset: null,
              ),
              const SizedBox(
                width: 7.0,
              ),
              OptimisedText(
                minWidth: _deviceWidth * 0.1,
                maxWidth: _deviceWidth,
                minHeight: _deviceHeight * 0.05,
                maxHeight: _deviceHeight * 0.1,
                fit: BoxFit.scaleDown,
                child: Text(
                  username,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 18.0,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
