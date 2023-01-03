import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/themeModel.dart';
import '../common/title.dart';

class TitleButton extends StatelessWidget {
  const TitleButton();
  @override
  Widget build(BuildContext context) {
    final textDirection =
        Provider.of<ThemeModel>(context, listen: false).textDirection;
    final bool isRTL = textDirection == TextDirection.rtl;
    return Align(
        alignment: isRTL ? Alignment.topRight : Alignment.topLeft,
        child: Container(
            margin: EdgeInsets.only(
                left: isRTL ? 0 : 15.0, right: isRTL ? 15.0 : 0),
            child: const MyTitle()));
  }
}
