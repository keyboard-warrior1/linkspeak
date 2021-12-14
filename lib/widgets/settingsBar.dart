import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsBar extends StatelessWidget {
  final String? title;
  final bool? showbutton;
  final void Function()? handler;
  const SettingsBar([this.title, this.handler, this.showbutton]);
  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).primaryColor;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    return ClipPath(
      clipper: CoolClipper(),
      child: Container(
        height: _deviceHeight * 0.08,
        width: _deviceWidth,
        decoration: BoxDecoration(color: _primaryColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (showbutton == null)
              IconButton(
                padding: const EdgeInsets.all(0.0),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (handler != null) {
                    handler!();
                  }
                  Navigator.pop(context);
                },
              ),
            if (showbutton != null) const SizedBox(width: 15.0),
            Text(
              '$title',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoolClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(15, size.height - 15);
    path.lineTo(size.width - 15, size.height - 15);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
