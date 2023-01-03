import 'package:flutter/material.dart';

import '../general.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/settings/terms.dart';

class TermScreen extends StatelessWidget {
  const TermScreen();
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final lang = General.language(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: _deviceHeight,
                child: Column(children: <Widget>[
                  SettingsBar(lang.screens_settings15),
                  const Expanded(child: const Terms())
                ]))));
  }
}
