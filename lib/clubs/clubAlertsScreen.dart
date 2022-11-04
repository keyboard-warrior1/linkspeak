import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../general.dart';
import '../routes.dart';
import '../widgets/alerts/notificationTile.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class ClubAlertsScreen extends StatefulWidget {
  final dynamic clubName;
  final dynamic numOfNewMembers;
  final dynamic numOfRequests;
  final dynamic zeroNotifs;
  final dynamic decreaseNotifs;
  final dynamic addMembers;
  const ClubAlertsScreen(
      {required this.clubName,
      required this.numOfNewMembers,
      required this.numOfRequests,
      required this.zeroNotifs,
      required this.decreaseNotifs,
      required this.addMembers});

  @override
  _ClubAlertsScreenState createState() => _ClubAlertsScreenState();
}

class _ClubAlertsScreenState extends State<ClubAlertsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int _numOfNewMembers = 0;
  int _numOfRequests = 0;

  removeAllNotification() async {
    final requestsCollection = firestore
        .collection('Clubs')
        .doc('${widget.clubName}')
        .collection('JoinRequests')
        .get();
    firestore
        .collection('Clubs')
        .doc('${widget.clubName}')
        .update({'numOfJoinRequests': 0, 'numOfNewMembers': 0});

    requestsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    widget.zeroNotifs();
    setState(() {
      _numOfNewMembers = 0;
      _numOfRequests = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _numOfNewMembers = widget.numOfNewMembers;
    _numOfRequests = widget.numOfRequests;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNotifications = _numOfNewMembers != 0 || _numOfRequests != 0;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    void decreaseNotifs() {
      widget.decreaseNotifs();
      _numOfRequests--;
      setState(() {});
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 7.0),
                child: Center(
                    child: Column(children: <Widget>[
                  const SettingsBar('Club Alerts'),
                  if (hasNotifications)
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: <
                        Widget>[
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (_) {
                                  return Center(
                                      child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minWidth: 150.0, maxWidth: 150.0),
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  color: Colors.white),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    const Text('Clear alerts',
                                                        softWrap: false,
                                                        style: TextStyle(
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
                                                                Colors.black)),
                                                    const Divider(
                                                        thickness: 1.0,
                                                        indent: 0.0,
                                                        endIndent: 0.0),
                                                    Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
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
                                                            child: const Text(
                                                              'Yes',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
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
                                                              child: const Text(
                                                                  'No',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red)))
                                                        ])
                                                  ]))));
                                });
                          },
                          child: const Center(
                              child: const Text('Clear all alerts',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 23)))),
                      const Spacer()
                    ]),
                  Expanded(
                      child: SizedBox(
                          height: _deviceHeight * 91,
                          width: double.infinity,
                          child: (!hasNotifications)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                      Center(
                                          child: const Icon(Icons.notifications,
                                              size: 45.0, color: Colors.grey)),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      Center(
                                          child: const Text(
                                              'Club has no new alerts',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 25.0)))
                                    ])
                              : Noglow(
                                  child: ListView(children: <Widget>[
                                  if (_numOfNewMembers != 0)
                                    NotificationTile(
                                        title: 'New Members',
                                        mykey: null,
                                        badgeColor:
                                            Colors.lightGreenAccent.shade700,
                                        badgeText:
                                            '${General.topicNumber(_numOfNewMembers)}',
                                        navigate: false,
                                        routeName: null,
                                        enabled: false,
                                        isClub: true,
                                        isFlare: false,
                                        username: '',
                                        clubName: '',
                                        decreaseNotifs: () {},
                                        addMembers: () {}),
                                  if (_numOfRequests != 0)
                                    NotificationTile(
                                        title: 'Join Requests',
                                        mykey: null,
                                        badgeColor:
                                            Colors.lightGreenAccent.shade700,
                                        badgeText:
                                            '${General.topicNumber(_numOfRequests)}',
                                        navigate: true,
                                        routeName:
                                            RouteGenerator.clubRequestScreen,
                                        enabled: true,
                                        isClub: true,
                                        isFlare: false,
                                        username: '',
                                        clubName: widget.clubName,
                                        decreaseNotifs: decreaseNotifs,
                                        addMembers: widget.addMembers)
                                ]))))
                ])))));
  }
}
