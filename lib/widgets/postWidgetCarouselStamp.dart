import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fullPostHelper.dart';

class PostCarouselStamp extends StatelessWidget {
  const PostCarouselStamp();
  String timeStamp(DateTime postedDate) {
    final String _datewithYear = DateFormat('MMMM d yyyy').format(postedDate);
    final String _dateNoYear = DateFormat('MMMM d').format(postedDate);
    final Duration _difference = DateTime.now().difference(postedDate);
    final bool _withinMinute =
        _difference <= const Duration(seconds: 59, milliseconds: 999);
    final bool _withinHour = _difference <=
        const Duration(minutes: 59, seconds: 59, milliseconds: 999);
    final bool _withinDay = _difference <=
        const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999);
    final bool _withinYear = _difference <=
        const Duration(days: 364, minutes: 59, seconds: 59, milliseconds: 999);

    if (_withinMinute) {
      return 'a few seconds';
    } else if (_withinHour && _difference.inMinutes > 1) {
      return '${_difference.inMinutes} minutes';
    } else if (_withinHour && _difference.inMinutes == 1) {
      return '${_difference.inMinutes} minute';
    } else if (_withinDay && _difference.inHours > 1) {
      return '${_difference.inHours} hours';
    } else if (_withinDay && _difference.inHours == 1) {
      return '${_difference.inHours} hour';
    } else if (!_withinMinute && !_withinHour && !_withinDay && _withinYear) {
      return '$_dateNoYear';
    } else {
      return '$_datewithYear';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).primaryColor;
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final DateTime postedDate = helper.postedDate;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0),
            ),
          ),
          child: Stack(
            children: <Widget>[
              Text(
                timeStamp(postedDate),
                softWrap: false,
                textAlign: TextAlign.end,
                style: TextStyle(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.25
                    ..color = Colors.black,
                  fontSize: 19.0,
                ),
              ),
              Text(
                timeStamp(postedDate),
                softWrap: false,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
