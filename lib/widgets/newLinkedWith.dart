import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../models/screenArguments.dart';
import '../widgets/chatProfileImage.dart';
import '../routes.dart';

class NewLinkedWith extends StatefulWidget {
  final String userName;
  final DateTime date;
  const NewLinkedWith({required this.userName, required this.date});

  @override
  _NewLinkedWithState createState() => _NewLinkedWithState();
}

class _NewLinkedWithState extends State<NewLinkedWith> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();
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
  void dispose() {
    super.dispose();
    _recognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUsername = context.read<MyProfile>().getUsername;
    void _visitProfile({required final String username}) {
      if ((username == myUsername)) {
      } else {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: username);
        Navigator.pushNamed(
          context,
          (username == myUsername)
              ? RouteGenerator.myProfileScreen
              : RouteGenerator.posterProfileScreen,
          arguments: args,
        );
      }
    }

    _recognizer.onTap = () => _visitProfile(username: widget.userName);
    return ListTile(
      key: UniqueKey(),
      onTap: () => _visitProfile(username: widget.userName),
      leading: GestureDetector(
        onTap: () => _visitProfile(username: widget.userName),
        child: ChatProfileImage(
          username: '${widget.userName}',
          factor: 0.05,
          inEdit: false,
          asset: null,
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'You are now linked with',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            TextSpan(
              recognizer: _recognizer,
              text: ' ${widget.userName}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      trailing: Text(
        timeStamp(widget.date),
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
