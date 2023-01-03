import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/themeModel.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/chatprofileImage.dart';

class NewLinks extends StatefulWidget {
  final String userName;
  final DateTime date;
  const NewLinks({required this.userName, required this.date});

  @override
  _NewLinksState createState() => _NewLinksState();
}

class _NewLinksState extends State<NewLinks> {
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
      onTap: () => _visitProfile(username: widget.userName),
      key: UniqueKey(),
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
        softWrap: true,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.userName} ',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: lang.widgets_alerts1,
              style: const TextStyle(color: Colors.black),
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
