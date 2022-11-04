import 'package:flutter/material.dart';

import '../widgets/common/settingsBar.dart';
import '../widgets/settings/privacyPolicy.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen();

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: _deviceHeight,
          child: Column(
            children: <Widget>[
              const SettingsBar('Privacy Policy'),
              const Expanded(child: const PrivacyPolicy()),
            ],
          ),
        ),
      ),
    );
  }
}
