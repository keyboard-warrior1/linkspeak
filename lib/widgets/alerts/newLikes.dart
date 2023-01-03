import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/themeModel.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../../screens/postScreen.dart';
import '../common/chatProfileImage.dart';

class NewLikes extends StatefulWidget {
  final String userName;
  final String postUrl;
  final DateTime date;
  final String clubName;
  const NewLikes(
      {required this.userName,
      required this.postUrl,
      required this.date,
      required this.clubName});

  @override
  _NewLikesState createState() => _NewLikesState();
}

class _NewLikesState extends State<NewLikes> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();

  void _goToPost(final BuildContext context, final ViewMode view,
      dynamic previewSetstate, String clubName) {
    final PostScreenArguments args = PostScreenArguments(
        instance: null,
        viewMode: view,
        previewSetstate: previewSetstate,
        isNotif: true,
        postID: widget.postUrl,
        clubName: clubName,
        section: Section.multiple,
        singleCommentID: '');
    Navigator.pushNamed(context, RouteGenerator.postScreen, arguments: args);
  }

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
            arguments: args);
      }
    }

    _recognizer.onTap = () => _visitProfile(username: widget.userName);
    return ListTile(
        onTap: () => _goToPost(context, ViewMode.likes, () {}, widget.clubName),
        enabled: true,
        key: UniqueKey(),
        leading: GestureDetector(
            onTap: () => _visitProfile(username: widget.userName),
            child: ChatProfileImage(
                username: '${widget.userName}',
                factor: 0.05,
                inEdit: false,
                asset: null,
                editUrl: '')),
        title: RichText(
            softWrap: true,
            text: TextSpan(children: [
              TextSpan(
                  recognizer: _recognizer,
                  text: '${widget.userName} ',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: lang.widgets_alerts6,
                  style: const TextStyle(color: Colors.black))
            ])),
        trailing: Text(General.timeStamp(widget.date, locale, context),
            style: const TextStyle(color: Colors.grey)));
  }
}
