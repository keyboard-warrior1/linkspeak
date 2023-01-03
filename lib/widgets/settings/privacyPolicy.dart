import 'package:flutter/material.dart';
import '../../general.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy();
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final privacy = lang.privacy;
    return Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: SingleChildScrollView(
            child: Text(privacy,
                softWrap: true,
                maxLines: 10000,
                style: const TextStyle(color: Colors.black))));
  }
}
