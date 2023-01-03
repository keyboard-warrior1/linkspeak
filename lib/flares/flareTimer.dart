import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';

class FlareTimer extends StatefulWidget {
  const FlareTimer();

  @override
  State<FlareTimer> createState() => _FlareTimerState();
}

class _FlareTimerState extends State<FlareTimer> {
  final CountDownController controller = CountDownController();
  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    return CircularCountDownTimer(
      width: 30,
      height: 30,
      duration: 10,
      controller: controller,
      isReverse: true,
      isTimerTextShown: true,
      textStyle: TextStyle(color: _accentColor, fontWeight: FontWeight.bold),
      onComplete: () {
        controller.restart();
      },
      onStart: () {},
      autoStart: true,
      backgroundColor: _primaryColor,
      ringColor: _primaryColor,
      fillColor: _accentColor,
    );
  }
}
