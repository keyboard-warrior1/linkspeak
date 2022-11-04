import 'package:flutter/material.dart';

import '../widgets/common/settingsBar.dart';
import '../widgets/settings/terms.dart';

class TermScreen extends StatelessWidget {
  const TermScreen();
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: _deviceHeight,
                child: Column(children: <Widget>[
                  const SettingsBar('Terms and Guidelines'),
                  const Expanded(child: const Terms())
                ]))));
  }
}
