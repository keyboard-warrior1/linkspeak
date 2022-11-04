import 'package:flutter/material.dart';

import 'profileFlares.dart';

class FlareProfileTab extends StatefulWidget {
  final TabController controller;
  const FlareProfileTab(this.controller);

  @override
  State<FlareProfileTab> createState() => _FlareProfileTabState();
}

class _FlareProfileTabState extends State<FlareProfileTab> {
  @override
  Widget build(BuildContext context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.91,
      child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: widget.controller,
          children: const <Widget>[const ProfileFlares()]));
}
