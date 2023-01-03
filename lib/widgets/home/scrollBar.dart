import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appBarProvider.dart';
import '../../providers/themeModel.dart';
import '../common/adaptiveText.dart';
import 'fasterButton.dart';
import 'pauseButton.dart';
import 'reverseButton.dart';
import 'slowerButton.dart';
import 'speedFactor.dart';
import 'startButton.dart';
import 'stopButton.dart';

class ScrollBar extends StatelessWidget {
  const ScrollBar();
  @override
  Widget build(BuildContext context) {
    final textDirection =
        Provider.of<ThemeModel>(context, listen: false).textDirection;
    final bool isRTL = textDirection == TextDirection.rtl;
    final View viewMode = Provider.of<AppBarProvider>(context).viewMode;
    final Size _size = MediaQuery.of(context).size;
    final double _deviceHeight = _size.height;
    final Scroll scrollMode = context.watch<AppBarProvider>().scrollMode;
    return Align(
        alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: (viewMode == View.autoScroll) ? 45.0 : 0.0,
            height: (viewMode == View.autoScroll) ? _deviceHeight * 0.5 : 0.0,
            child: OptimisedText(
                minWidth: 45.0,
                maxWidth: 45.0,
                minHeight: _deviceHeight * 0.5,
                maxHeight: _deviceHeight * 0.5,
                fit: BoxFit.scaleDown,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.80),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isRTL ? 0 : 15.0),
                            bottomLeft: Radius.circular(isRTL ? 0 : 15.0),
                            topRight: Radius.circular(isRTL ? 15.0 : 0),
                            bottomRight: Radius.circular(isRTL ? 15.0 : 0))),
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          if (scrollMode == Scroll.paused) const StartButton(),
                          if (scrollMode == Scroll.paused) const FasterButton(),
                          if (scrollMode != Scroll.paused) const PauseButton(),
                          if (scrollMode != Scroll.paused)
                            const ReverseButton(),
                          const SpeedFactor(),
                          if (scrollMode == Scroll.paused) const SlowerButton(),
                          const StopButton()
                        ])))));
  }
}
