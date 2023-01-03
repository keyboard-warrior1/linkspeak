import 'package:flutter/material.dart';

import '../../../my_flutter_app_icons.dart' as customIcons;
import '../../../routes.dart';

class AdminFAB extends StatelessWidget {
  const AdminFAB();
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 45.0),
      child: FloatingActionButton(
          key: UniqueKey(),
          highlightElevation: 0.0,
          elevation: 0.0,
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              child: const Icon(customIcons.MyFlutterApp.radio_1_,
                  color: Colors.white, size: 35.0)),
          onPressed: () =>
              Navigator.pushNamed(context, RouteGenerator.mainAdminScreen),
          backgroundColor: Colors.red));
}
