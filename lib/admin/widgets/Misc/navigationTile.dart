import 'package:flutter/material.dart';

class NavigationTile extends StatelessWidget {
  final dynamic handler;
  final IconData icon;
  final String screenName;
  const NavigationTile(
      {required this.handler, required this.icon, required this.screenName});

  @override
  Widget build(BuildContext context) => ListTile(
      enabled: true,
      onTap: handler,
      enableFeedback: true,
      horizontalTitleGap: 2,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(screenName, style: const TextStyle(color: Colors.black)));
}
