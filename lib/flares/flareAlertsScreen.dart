import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../general.dart';
import '../routes.dart';
import '../widgets/alerts/notificationTile.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class FlareAlertScreen extends StatefulWidget {
  final dynamic username;
  final dynamic numOfLikes;
  final dynamic numOfComments;
  final dynamic zeroNotifs;
  const FlareAlertScreen(
      {required this.username,
      required this.numOfLikes,
      required this.numOfComments,
      required this.zeroNotifs});

  @override
  State<FlareAlertScreen> createState() => _FlareAlertScreenState();
}

class _FlareAlertScreenState extends State<FlareAlertScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  removeAllNotification() async {
    final likesCollection = firestore
        .collection('Flares')
        .doc('${widget.username}')
        .collection('LikeNotifs')
        .get();
    final commentsCollection = firestore
        .collection('Flares')
        .doc('${widget.username}')
        .collection('CommentNotifs')
        .get();
    firestore
        .collection('Flares')
        .doc('${widget.username}')
        .set({'likeNotifs': 0, 'commentNotifs': 0}, SetOptions(merge: true));

    likesCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    commentsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    widget.zeroNotifs();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final bool hasNotifications =
        widget.numOfLikes != 0 || widget.numOfComments != 0;
    final _size = MediaQuery.of(context).size;
    final _height = _size.height;
    final _width = General.widthQuery(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: _height,
                width: _width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SettingsBar(lang.flares_alerts1),
                      if (hasNotifications)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Spacer(),
                              TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) {
                                        return Center(
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  minWidth: 150.0,
                                                  maxWidth: 150.0,
                                                ),
                                                child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 10.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      color: Colors.white,
                                                    ),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            lang.flares_alerts2,
                                                            softWrap: false,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontSize: 19.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const Divider(
                                                            thickness: 1.0,
                                                            indent: 0.0,
                                                            endIndent: 0.0,
                                                          ),
                                                          Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                TextButton(
                                                                  style: ButtonStyle(
                                                                      splashFactory:
                                                                          NoSplash
                                                                              .splashFactory),
                                                                  onPressed:
                                                                      () async {
                                                                    await removeAllNotification();
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                    lang.flares_alerts3,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                    style: ButtonStyle(
                                                                        splashFactory:
                                                                            NoSplash
                                                                                .splashFactory),
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child: Text(
                                                                        lang
                                                                            .flares_alerts4,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.red)))
                                                              ])
                                                        ]))));
                                      },
                                    );
                                  },
                                  child: Center(
                                      child: Text(lang.flares_alerts5,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 23)))),
                              const Spacer()
                            ]),
                      Expanded(
                          child: SizedBox(
                              height: _height * 91,
                              width: double.infinity,
                              child: (!hasNotifications)
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                          const Center(
                                              child: const Icon(
                                                  Icons.notifications,
                                                  size: 45.0,
                                                  color: Colors.grey)),
                                          const SizedBox(height: 15.0),
                                          Center(
                                              child: Text(lang.flares_alerts6,
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 25.0)))
                                        ])
                                  : Noglow(
                                      child: ListView(children: <Widget>[
                                      if (widget.numOfLikes != 0)
                                        NotificationTile(
                                            title: lang.flares_alerts7,
                                            mykey: null,
                                            badgeColor: Colors
                                                .lightGreenAccent.shade700,
                                            badgeText:
                                                '${General.topicNumber(widget.numOfLikes)}',
                                            navigate: true,
                                            routeName:
                                                RouteGenerator.flareLikeAlers,
                                            enabled: true,
                                            isClub: false,
                                            isFlare: true,
                                            username: widget.username,
                                            clubName: '',
                                            decreaseNotifs: () {},
                                            addMembers: () {}),
                                      if (widget.numOfComments != 0)
                                        NotificationTile(
                                            title: lang.flares_alerts8,
                                            mykey: null,
                                            badgeColor: Colors
                                                .lightGreenAccent.shade700,
                                            badgeText:
                                                '${General.topicNumber(widget.numOfComments)}',
                                            navigate: true,
                                            routeName: RouteGenerator
                                                .flareCommentAlerts,
                                            enabled: true,
                                            isClub: false,
                                            isFlare: true,
                                            username: widget.username,
                                            clubName: '',
                                            decreaseNotifs: () {},
                                            addMembers: () {})
                                    ]))))
                    ]))));
  }
}
