import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/myProfileProvider.dart';
import '../models/screenArguments.dart';
import '../models/miniProfile.dart';
import '../routes.dart';

class SuggestedWidget extends StatefulWidget {
  const SuggestedWidget();

  @override
  _SuggestedWidgetState createState() => _SuggestedWidgetState();
}

class _SuggestedWidgetState extends State<SuggestedWidget> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future _getSuggested;
  List<MiniProfile> suggesteds = [];
  void _visitProfile({
    required final String username,
    required final String myUsername,
  }) {
    if (username == myUsername) {
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

  Future<void> getSuggested(String myUsername, List<String> myTopics) async {
    final getEmNonEmpty = await firestore
        .collection('Users')
        .where('Topics', isNotEqualTo: [])
        .limit(10)
        .get();
    final getEmDocs = getEmNonEmpty.docs;
    if (getEmDocs.isEmpty) {
      final getEmNormal = await firestore
          .collection('Users')
          .where('Username', isNotEqualTo: myUsername)
          .limit(10)
          .get();
      final docs = getEmNormal.docs;
      for (var doc in docs) {
        final getUser = await firestore.collection('Users').doc(doc.id).get();
        final username = doc.id;
        final userIMG = getUser.get('Avatar');
        final mini = MiniProfile(username: username, imgUrl: userIMG);
        if (username != myUsername) {
          if (suggesteds.any((element) => element.username == username)) {
          } else {
            suggesteds.add(mini);
          }
        }
      }
      setState(() {});
    } else {
      if (getEmDocs.length == 10) {
        for (var doc in getEmDocs) {
          final getUser = await firestore.collection('Users').doc(doc.id).get();
          final username = doc.id;
          final userIMG = getUser.get('Avatar');
          final topcis = getUser.get('Topics') as List;
          final topicNames = topcis.map((e) => e as String).toList();
          final mini = MiniProfile(username: username, imgUrl: userIMG);
          var topicSet = topicNames.toSet();
          var mySet = myTopics.toSet();
          if (topicSet.intersection(mySet).isNotEmpty) {
            if (suggesteds.any((element) => element.username == username)) {
            } else {
              suggesteds.add(mini);
            }
          }
        }
        setState(() {});
      } else if (suggesteds.length < 10) {
        int difference = 10 - suggesteds.length;
        final getEmNormal = await firestore
            .collection('Users')
            .where('Username', isNotEqualTo: myUsername)
            .limit(difference)
            .get();
        final docs = getEmNormal.docs;
        for (var doc in docs) {
          final getUser = await firestore.collection('Users').doc(doc.id).get();
          final username = doc.id;
          final userIMG = getUser.get('Avatar');
          final mini = MiniProfile(username: username, imgUrl: userIMG);
          if (suggesteds.any((element) => element.username == username)) {
          } else {
            suggesteds.add(mini);
          }
        }
        setState(() {});
      } else {
        int difference = 10 - getEmDocs.length;
        final getEmNormal = await firestore
            .collection('Users')
            .where('Username', isNotEqualTo: myUsername)
            .limit(difference)
            .get();
        final docs = getEmNormal.docs;
        for (var doc in docs) {
          final getUser = await firestore.collection('Users').doc(doc.id).get();
          final username = doc.id;
          final userIMG = getUser.get('Avatar');
          final mini = MiniProfile(username: username, imgUrl: userIMG);
          if (suggesteds.any((element) => element.username == username)) {
          } else {
            suggesteds.add(mini);
          }
        }
        setState(() {});
      }
    }
  }

  void removeSuggestion(String username) {
    suggesteds.removeWhere((element) => element.username == username);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final List<String> myTopics =
        Provider.of<MyProfile>(context, listen: false).getTopics;
    _getSuggested = getSuggested(myUsername, myTopics);
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final Color _primarySwatch = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      color: Colors.white12,
      height: _deviceHeight * 0.30,
      width: _deviceWidth,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return false;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: const <Widget>[
                const Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: const Text(
                    'Suggested',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                future: _getSuggested,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      // child: const CircularProgressIndicator(),
                      child: Container(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      // child: const CircularProgressIndicator(),
                      child: Container(),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggesteds.length,
                    itemBuilder: (ctx, index) {
                      final currentProfile = suggesteds[index];
                      final username = currentProfile.username;
                      final userIMG = currentProfile.imgUrl;
                      return Stack(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _visitProfile(
                                  username: username, myUsername: myUsername);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 5.0),
                              height: _deviceHeight * 0.35,
                              width: _deviceWidth * 0.45,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border:
                                      Border.all(color: Colors.grey.shade300)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Card(
                                  margin: const EdgeInsets.all(0),
                                  borderOnForeground: false,
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Stack(
                                          children: <Widget>[
                                            Positioned.fill(
                                              child: Container(
                                                child: (userIMG != 'none')
                                                    ? Image.network(
                                                        '$userIMG',
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                        color: _primarySwatch,
                                                        child: Center(
                                                          child: Text(
                                                            '${username[0]}',
                                                            style: TextStyle(
                                                              color:
                                                                  _accentColor,
                                                              fontSize: 55.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            // Align(
                                            //   alignment: Alignment.topRight,
                                            //   child: Container(
                                            //     margin: const EdgeInsets.only(
                                            //         top: 10.0),
                                            //     padding:
                                            //         const EdgeInsets.all(5.0),
                                            //     decoration: BoxDecoration(
                                            //       color: _primarySwatch
                                            //           .withOpacity(0.5),
                                            //       borderRadius:
                                            //           BorderRadius.only(
                                            //         topLeft:
                                            //             Radius.circular(5.0),
                                            //         bottomLeft:
                                            //             Radius.circular(5.0),
                                            //       ),
                                            //     ),
                                            //     child: Stack(
                                            //       children: <Widget>[
                                            //         Text(
                                            //           'Common topics',
                                            //           softWrap: false,
                                            //           textAlign: TextAlign.end,
                                            //           style: TextStyle(
                                            //             foreground: Paint()
                                            //               ..style =
                                            //                   PaintingStyle
                                            //                       .stroke
                                            //               ..strokeWidth = 1.25
                                            //               ..color =
                                            //                   Colors.black,
                                            //             fontSize: 13.50,
                                            //           ),
                                            //         ),
                                            //         Text(
                                            //           'Common topics',
                                            //           softWrap: false,
                                            //           textAlign: TextAlign.end,
                                            //           style: const TextStyle(
                                            //             color: Colors.white,
                                            //             fontSize: 13.50,
                                            //           ),
                                            //         ),
                                            //       ],
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15.0),
                                            bottomRight: Radius.circular(15.0),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Container(
                                              width: _deviceWidth * 0.25,
                                              height: _deviceHeight * 0.044,
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Center(
                                                  child: Text(
                                                    '$username',
                                                    softWrap: false,
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20.0,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5.0,
                            child: IconButton(
                              onPressed: () {
                                removeSuggestion(username);
                              },
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.redAccent,
                                size: 25.0,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
