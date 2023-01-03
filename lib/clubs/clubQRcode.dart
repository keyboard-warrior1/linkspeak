import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ClubQR extends StatelessWidget {
  final String clubName;
  const ClubQR(this.clubName);

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
          height: 200.0,
          width: 200.0,
          color: Colors.white,
          child: Center(
              child: QrImage(
                  data: clubName, version: QrVersions.auto, size: 200.0))));
}
