import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/themeModel.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/chatProfileImage.dart';

class NewLinkedWith extends StatefulWidget {
  final String userName;
  final DateTime date;
  const NewLinkedWith({required this.userName, required this.date});

  @override
  _NewLinkedWithState createState() => _NewLinkedWithState();
}

class _NewLinkedWithState extends State<NewLinkedWith> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();

  @override
  void dispose() {
    super.dispose();
    _recognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final myUsername = context.read<MyProfile>().getUsername;
    final locale =
        Provider.of<ThemeModel>(context, listen: false).serverLangCode;
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
          editUrl: '',
        ),
      ),
      title: RichText(
        softWrap: true,
        text: TextSpan(
          children: [
            TextSpan(
              text: lang.widgets_alerts7,
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
        General.timeStamp(widget.date, locale, context),
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
