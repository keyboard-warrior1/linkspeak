import 'package:flutter/material.dart';

import '../../clubs/clubAvatar.dart';
import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../routes.dart';
import 'adaptiveText.dart';

class ClubObject extends StatelessWidget {
  final String clubName;
  const ClubObject({required this.clubName});

  @override
  Widget build(BuildContext context) {
    void _visitClub({required final String clubName}) {
      final ClubScreenArgs args = ClubScreenArgs(clubName);
      Navigator.pushNamed(
        context,
        RouteGenerator.clubScreen,
        arguments: args,
      );
    }

    void _showDialog() {
      _visitClub(clubName: clubName);
    }

    final Size _size = MediaQuery.of(context).size;
    final double _deviceHeight = _size.height;
    final double _deviceWidth = General.widthQuery(context);
    return TextButton(
      key: ValueKey<String>(clubName),
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
              ClubAvatar(
                clubName: clubName,
                radius: 20.0,
                inEdit: false,
                asset: null,
                fontSize: 30,
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
                  clubName,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 17.0,
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
