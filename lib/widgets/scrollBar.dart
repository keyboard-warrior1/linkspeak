import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appBarProvider.dart';
import 'adaptiveText.dart';
import 'startButton.dart';
import 'pauseButton.dart';
import 'reverseButton.dart';
import 'stopButton.dart';
import 'slowerButton.dart';
import 'fasterButton.dart';
import 'speedFactor.dart';

class ScrollBar extends StatelessWidget {
  final void Function() startHandler;
  final void Function() pauseHandler;
  final void Function() reverseHandler;
  final void Function() stopHandler;
  const ScrollBar(
      {required this.startHandler,
      required this.pauseHandler,
      required this.reverseHandler,
      required this.stopHandler});

  @override
  Widget build(BuildContext context) {
    View viewMode = Provider.of<AppBarProvider>(context).viewMode;
    final Size _size = MediaQuery.of(context).size;
    final double _deviceHeight = _size.height;
    Scroll scrollMode = context.watch<AppBarProvider>().scrollMode;
    final Widget _start = StartButton(startHandler);
    final Widget _pause = PauseButton(pauseHandler);
    final Widget _reverse = ReverseButton(reverseHandler);
    final Widget _stop = StopButton(stopHandler);
    const Widget _slower = SlowerButton();
    const Widget speedFactor = SpeedFactor();
    const Widget _faster = FasterButton();
    return Align(
      alignment: Alignment.centerRight,
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
                topLeft: const Radius.circular(15.0),
                bottomLeft: const Radius.circular(15.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (scrollMode == Scroll.paused) _start,
                if (scrollMode == Scroll.paused) _faster,
                if (scrollMode != Scroll.paused) _pause,
                if (scrollMode != Scroll.paused) _reverse,
                speedFactor,
                if (scrollMode == Scroll.paused) _slower,
                _stop,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
