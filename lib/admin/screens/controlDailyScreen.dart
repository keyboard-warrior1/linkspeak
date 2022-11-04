import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/screenArguments.dart';
import '../../routes.dart';
import '../../widgets/common/settingsBar.dart';

class ControlDailyScreen extends StatefulWidget {
  const ControlDailyScreen();

  @override
  State<ControlDailyScreen> createState() => _ControlDailyScreenState();
}

class _ControlDailyScreenState extends State<ControlDailyScreen> {
  List<String> stateDays = [];
  late Future<void> getDays;
  String dateFormatter(DateTime date) => DateFormat('d-M-y').format(date);
  List<DateTime> getDaysInBetween(
      {required DateTime startDate, required DateTime endDate}) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++)
      days.add(startDate.add(Duration(days: i)));
    return days;
  }

  void _getDays() {
    final today = DateTime.now();
    final june20th = DateTime(2022, 6, 20);
    List<DateTime> _days =
        getDaysInBetween(startDate: june20th, endDate: today);
    for (var day in _days) stateDays.add(dateFormatter(day));
    stateDays = stateDays.reversed.toList();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getDays();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: height,
                width: width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SettingsBar('Days'),
                      Expanded(
                          child: ListView.builder(
                              itemCount: stateDays.length,
                              itemBuilder: (ctx, index) {
                                var current = stateDays[index];
                                return TextButton(
                                    key: ValueKey<String>(current),
                                    onPressed: () {
                                      var args = ControlDayScreenArgs(current);
                                      Navigator.pushNamed(
                                          context, RouteGenerator.controlDay,
                                          arguments: args);
                                    },
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[Text(current)]));
                              }))
                    ]))));
  }
}
