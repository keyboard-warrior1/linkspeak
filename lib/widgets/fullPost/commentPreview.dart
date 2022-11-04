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

class CommentPreview extends StatefulWidget {
  final String comment;
  final bool isInReply;
  final dynamic handler;
  const CommentPreview(this.comment, this.isInReply, this.handler);

  @override
  _CommentPreviewState createState() => _CommentPreviewState();
}

class _CommentPreviewState extends State<CommentPreview> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool flag = true;
  late String firstHalf;
  late String secondHalf;
  @override
  void initState() {
    super.initState();
    if (widget.comment.length >= 400) {
      firstHalf = widget.comment.substring(0, 200);
      secondHalf = widget.comment.substring(200, widget.comment.length);
    } else {
      firstHalf = widget.comment;
      secondHalf = '';
    }
  }

  void visitProfile(String myUsername, String taggedPerson) {
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
    final myUrls =
        firestore.collection('Users').doc(myUsername).collection('URLs');
    await Clipboard.setData(ClipboardData(text: '$url'));
    await myUrls.add({'url': url, 'date': DateTime.now()});
    EasyLoading.show(
        status: 'Copied',
        dismissOnTap: true,
        indicator: Icon(Icons.copy, color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final themeColors = Theme.of(context).colorScheme;
    final _primaryColor = themeColors.primary;
    final _accentColor = themeColors.secondary;
    return Container(
        child: (secondHalf.isEmpty)
            ? SelectableLinkify(
                linkifiers: [
                    const UrlLinkifier(),
                    const EmailLinkifier(),
                    const UserTagLinkifier()
                  ],
                options: const LinkifyOptions(humanize: false),
                text: firstHalf,
                onTap: () {
                  if (widget.isInReply) widget.handler();
                },
                onOpen: (link) {
                  if (link is UrlElement) {
                    websiteHandler(
                        link.url, myUsername, _primaryColor, _accentColor);
                  } else if (link is UserTagElement) {
                    final text = link.text;
                    final replaceAt = text.replaceFirst('@', '');
                    visitProfile(myUsername, replaceAt);
                  } else {
                    copyHandler(link.url, myUsername);
                  }
                },
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.black),
                linkStyle: TextStyle(
                    color: _primaryColor, decoration: TextDecoration.none))
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SelectableLinkify(
                        options: const LinkifyOptions(humanize: false),
                        linkifiers: [
                          const UrlLinkifier(),
                          const EmailLinkifier(),
                          const UserTagLinkifier()
                        ],
                        text: flag
                            ? (firstHalf + '...')
                            : (firstHalf + secondHalf),
                        onTap: () {
                          if (widget.isInReply) {
                            if (flag) {
                              setState(() {
                                flag = false;
                              });
                            } else {
                              widget.handler();
                            }
                          } else {
                            setState(() {
                              flag = !flag;
                            });
                          }
                        },
                        onOpen: (link) {
                          if (link is UrlElement) {
                            websiteHandler(link.url, myUsername, _primaryColor,
                                _accentColor);
                          } else if (link is UserTagElement) {
                            final text = link.text;
                            final replaceAt = text.replaceFirst('@', '');
                            visitProfile(myUsername, replaceAt);
                          } else {
                            copyHandler(link.url, myUsername);
                          }
                        },
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: Colors.black),
                        linkStyle: TextStyle(
                            color: _primaryColor,
                            decoration: TextDecoration.none)),
                    InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            flag = !flag;
                          });
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(flag ? 'show more' : 'show less',
                                  style: const TextStyle(
                                      color: Colors.lightBlue,
                                      fontStyle: FontStyle.italic))
                            ]))
                  ]));
  }
}
