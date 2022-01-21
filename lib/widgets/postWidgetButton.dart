import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fullPostHelper.dart';
import '../providers/otherProfileProvider.dart';

class PostWidgetButton extends StatelessWidget {
  final void Function() toggleCard;
  final bool isInOtherProfile;
  const PostWidgetButton(this.toggleCard, this.isInOtherProfile);
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
      return '~ ${_difference.inMinutes} minutes';
    } else if (_withinHour && _difference.inMinutes == 1) {
      return '~ ${_difference.inMinutes} minute';
    } else if (_withinDay && _difference.inHours > 1) {
      return '~ ${_difference.inHours} hours';
    } else if (_withinDay && _difference.inHours == 1) {
      return '~ ${_difference.inHours} hour';
    } else if (!_withinMinute && !_withinHour && !_withinDay && _withinYear) {
      return '$_dateNoYear';
    } else {
      return '$_datewithYear';
    }
  }

  @override
  Widget build(BuildContext context) {
    final FullHelper helper = Provider.of<FullHelper>(context);
    final List<String> topics = helper.postTopics;
    final List<String> postImgUrls = helper.postImgUrls;
    final dynamic postLocation = helper.getLocation;
    final bool withMedia = postImgUrls.isNotEmpty;
    final bool noMedia = postImgUrls.isEmpty;
    final DateTime postedDate = helper.postedDate;
    Color _primaryColor = Theme.of(context).primaryColor;
    Color _accentColor = Theme.of(context).accentColor;
    if (isInOtherProfile) {
      _primaryColor =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
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
        if (topics.isNotEmpty || postLocation != '')
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: (withMedia)
                    ? _primaryColor.withOpacity(0.5)
                    : _primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => toggleCard(),
                icon: Icon(
                  Icons.info_outline,
                  color: (withMedia) ? _accentColor : Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
