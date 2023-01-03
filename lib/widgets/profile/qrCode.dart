import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/myProfileProvider.dart';

class QRcode extends StatelessWidget {
  const QRcode();

  @override
  Widget build(BuildContext context) {
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 200.0,
        width: 200.0,
        color: Colors.white,
        child: Center(
          child: QrImage(
            data: myUsername,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
      ),
    );
  }
}
