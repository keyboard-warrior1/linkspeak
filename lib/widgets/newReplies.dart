import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../models/screenArguments.dart';
import '../routes.dart';
import 'chatprofileImage.dart';

class NewReplies extends StatefulWidget {
  final String commentUserName;
  final String postUrl;
  final String commentID;
  final DateTime date;
  const NewReplies({
    required this.commentUserName,
    required this.postUrl,
    required this.commentID,
    required this.date,
  });

  @override
  _NewRepliesState createState() => _NewRepliesState();
}

class _NewRepliesState extends State<NewReplies> {
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

    final CommentRepliesScreenArguments args = CommentRepliesScreenArguments(
      postID: widget.postUrl,
      commentID: widget.commentID,
      commenterName: widget.commentUserName,
      instance: null,
      isNotif: true,
    );
    _recognizer.onTap = () => _visitProfile(username: widget.commentUserName);
    return ListTile(
      key: UniqueKey(),
      onTap: () {
        Navigator.of(context)
            .pushNamed(RouteGenerator.commentRepliesScreen, arguments: args);
      },
      enabled: true,
      leading: GestureDetector(
        onTap: () => _visitProfile(username: widget.commentUserName),
        child: ChatProfileImage(
          username: '${widget.commentUserName.toString()}',
          factor: 0.05,
          inEdit: false,
          asset: null,
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              recognizer: _recognizer,
              text: '${widget.commentUserName.toString()} ',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: 'Replied to your comment',
              style: TextStyle(color: Colors.black),
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
