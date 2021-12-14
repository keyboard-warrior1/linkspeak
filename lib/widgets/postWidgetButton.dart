import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fullPostHelper.dart';

class PostWidgetButton extends StatelessWidget {
  final dynamic visitPost;
  const PostWidgetButton({required this.visitPost});
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
    final FullHelper helper = Provider.of<FullHelper>(context);
    final List<String> postImgUrls = helper.postImgUrls;
    final bool withMedia = postImgUrls.isNotEmpty;
    final bool noMedia = postImgUrls.isEmpty;
    final DateTime postedDate = helper.postedDate;
    final Color _primaryColor = Theme.of(context).primaryColor;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: (withMedia)
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (noMedia)
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(bottom: 5.0),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
              ),
            ),
            child: Text(
              timeStamp(postedDate),
              softWrap: false,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19.0,
              ),
            ),
          ),
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: (withMedia)
        //           ? Colors.lightBlueAccent.shade400.withOpacity(0.5)
        //           : Colors.lightBlueAccent,
        //       border: Border.all(
        //         color: (withMedia) ? _accentColor : Colors.transparent,
        //       ),
        //       shape: BoxShape.circle,
        //     ),
        //     child: IconButton(
        //       splashColor: Colors.lightBlue,
        //       splashRadius: 50.0,
        //       onPressed: visitPost,
        //       icon: Icon(
        //         Icons.keyboard_arrow_right_outlined,
        //         color: (withMedia) ? _accentColor : Colors.white,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
