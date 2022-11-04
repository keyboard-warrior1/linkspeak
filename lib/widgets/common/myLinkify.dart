import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../models/tagLinkifier.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';

class MyLinkify extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final TextDirection? textDirection;
  const MyLinkify(
      {required this.text,
      required this.style,
      required this.maxLines,
      required this.textDirection});
  void visitProfile(
      String myUsername, String taggedPerson, BuildContext context) {
    if (taggedPerson == myUsername) {
      Navigator.pushNamed(context, RouteGenerator.myProfileScreen);
    } else {
      final args = OtherProfileScreenArguments(otherProfileId: taggedPerson);
      Navigator.pushNamed(context, RouteGenerator.posterProfileScreen,
          arguments: args);
    }
  }

  Future<void> websiteHandler(String url, String myUsername, Color primaryColor,
      Color accentColor) async {
    final firestore = FirebaseFirestore.instance;
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    Future.delayed(const Duration(seconds: 1), () {
      return myUrls.add({'url': url, 'date': DateTime.now()});
    });
    // final BrowserScreenArgs args = BrowserScreenArgs(url);
    // Navigator.pushNamed(context, RouteGenerator.browser, arguments: args);
    General.openBrowser(url, primaryColor, accentColor);
  }

  Future<void> copyHandler(String url, String myUsername) async {
    final firestore = FirebaseFirestore.instance;
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    await Clipboard.setData(ClipboardData(text: '$url'));
    await myUrls.add({'url': url, 'date': DateTime.now()});
    EasyLoading.show(
        status: 'Copied',
        dismissOnTap: true,
        indicator: const Icon(Icons.copy, color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final themeColors = Theme.of(context).colorScheme;
    final _primaryColor = themeColors.primary;
    final _accentColor = themeColors.secondary;
    return Linkify(
        text: text,
        maxLines: 500,
        textAlign: TextAlign.start,
        softWrap: true,
        style: const TextStyle(
            fontFamily: 'Roboto', wordSpacing: 1.5, fontSize: 18.0),
        linkStyle:
            TextStyle(color: _primaryColor, decoration: TextDecoration.none),
        linkifiers: [
          const UrlLinkifier(),
          const EmailLinkifier(),
          const UserTagLinkifier()
        ],
        options: const LinkifyOptions(humanize: false),
        onOpen: (link) {
          if (link is UrlElement) {
            websiteHandler(link.url, myUsername, _primaryColor, _accentColor);
          } else if (link is UserTagElement) {
            final text = link.text;
            final replaceAt = text.replaceFirst('@', '');
            visitProfile(myUsername, replaceAt, context);
          } else {
            copyHandler(link.url, myUsername);
          }
        });
  }
}
