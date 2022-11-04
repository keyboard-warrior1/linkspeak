import 'package:flutter/material.dart';

import '../common/title.dart';

class TitleButton extends StatelessWidget {
  const TitleButton();
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.topLeft,
      child: Container(
          margin: const EdgeInsets.only(left: 15.0), child: const MyTitle()));
}
