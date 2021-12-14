import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import 'adaptiveText.dart';
import 'profileImage.dart';
import '../routes.dart';

class LinkObject extends StatelessWidget {
  final String imgUrl;
  final String username;
  const LinkObject({required this.imgUrl, required this.username});

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;

    void _visitProfile({required final String username}) {
      if (username != myUsername) {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: username);
        Navigator.pushNamed(
          context,
          RouteGenerator.posterProfileScreen,
          arguments: args,
        );
      }
    }

    void _showDialog() {
      _visitProfile(username: username);
    }

    final Size _size = MediaQuery.of(context).size;
    final double _deviceHeight = _size.height;
    final double _deviceWidth = _size.width;
    return TextButton(
      onPressed: _showDialog,
      child: Container(
        width: double.infinity,
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
                url: imgUrl,
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
                    fontSize: 21.0,
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
