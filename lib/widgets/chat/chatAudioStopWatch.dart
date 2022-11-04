import 'dart:async';

import 'package:flutter/material.dart';

class ChatAudioStopwatch extends StatefulWidget {
  final bool stopTimer;
  const ChatAudioStopwatch(this.stopTimer);

  @override
  State<ChatAudioStopwatch> createState() => _ChatAudioStopwatchState();
}

class _ChatAudioStopwatchState extends State<ChatAudioStopwatch> {
  Duration duration = Duration();
  Timer? timer;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer() {
    timer?.cancel();
  }

  Widget buildTime() {
    if (widget.stopTimer) stopTimer();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final int hourDuration = duration.inHours;
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String hours = twoDigits(duration.inHours.remainder(60));
    return Text(
      hourDuration > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 17.0,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) => buildTime();
}
