import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/myProfileProvider.dart';
import '../common/adaptiveText.dart';

class ProfileBackWebsite extends StatefulWidget {
  final String text;
  final String displayWebsite;
  final Color primaryColor;
  final Color accentColor;
  const ProfileBackWebsite(
      this.text, this.displayWebsite, this.primaryColor, this.accentColor);

  @override
  State<ProfileBackWebsite> createState() => _ProfileBackWebsiteState();
}

class _ProfileBackWebsiteState extends State<ProfileBackWebsite> {
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
    final lang = General.language(context);
    final firestore = FirebaseFirestore.instance;
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    await Clipboard.setData(ClipboardData(text: '$url'));
    await myUrls.add({'url': url, 'date': DateTime.now()});
    EasyLoading.show(
        status: lang.widgets_common7,
        dismissOnTap: true,
        indicator: const Icon(Icons.copy, color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = General.widthQuery(context);
    final style = TextStyle(
        fontSize: 15.0,
        color: widget.accentColor,
        decoration: TextDecoration.none,
        decorationColor: widget.accentColor,
        fontWeight: FontWeight.bold);
    return Container(
        margin: const EdgeInsets.only(top: 8.0, right: 25.0, bottom: 5.0),
        decoration: BoxDecoration(
            color: widget.primaryColor,
            borderRadius: BorderRadius.only(
                topRight: const Radius.circular(50.0),
                bottomRight: const Radius.circular(50.0))),
        child: ListTile(
            leading: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const Icon(Icons.public_outlined, color: Colors.white),
                  Text(lang.widgets_profile19,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))
                ]),
            title: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OptimisedText(
                          minHeight: deviceHeight * 0.04,
                          maxHeight: deviceHeight * 0.04,
                          minWidth: deviceWidth * 0.01,
                          maxWidth: deviceWidth * 0.55,
                          fit: BoxFit.scaleDown,
                          child: GestureDetector(
                            onLongPress: () {
                              copyHandler(widget.text, myUsername);
                            },
                            child: Linkify(
                                text: widget.displayWebsite,
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                softWrap: true,
                                style: style,
                                linkStyle: style,
                                onOpen: (_) {
                                  websiteHandler(widget.text, myUsername,
                                      widget.primaryColor, widget.accentColor);
                                },
                                linkifiers: [const UrlLinkifier()]),
                          )))
                ])));
  }
}
