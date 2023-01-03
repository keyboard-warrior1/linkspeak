import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import 'newFlareLikes.dart';

class FlareLikeAlerts extends StatefulWidget {
  const FlareLikeAlerts();

  @override
  State<FlareLikeAlerts> createState() => _FlareLikeAlertsState();
}

class _FlareLikeAlertsState extends State<FlareLikeAlerts> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _likesFuture;
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLastPage = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> source = [];
  Future<void> getLikes() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    final _likesCollection = await firestore
        .collection('Flares')
        .doc(_myProfile.getUsername.toString())
        .collection('LikeNotifs')
        .orderBy('date', descending: true)
        .limit(30)
        .get();
    final docs = _likesCollection.docs;
    for (var item in docs) {
      source.add(item);
    }
    if (docs.length < 30) {
      isLastPage = true;
    }

    setState(() {});
  }

  Future<void> getMoreLikes() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      final lastItem = source.last;
      final _likesCollection = await firestore
          .collection('Flares')
          .doc(_myProfile.getUsername.toString())
          .collection('LikeNotifs')
          .orderBy('date', descending: true)
          .startAfterDocument(lastItem)
          .limit(15)
          .get();
      final docs = _likesCollection.docs;
      for (var item in docs) {
        source.add(item);
      }
      if (docs.length < 15) {
        isLastPage = true;
      }
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _likesFuture = getLikes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreLikes();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: SafeArea(
            child: Container(
                height: _deviceHeight,
                width: _deviceWidth,
                color: Colors.white,
                child: Column(mainAxisSize: MainAxisSize.max, children: [
                  // SettingsBar('Likes  ${General.topicNumber(_num)}'),
                  SettingsBar(lang.flares_commentLikes1),
                  FutureBuilder(
                      future: _likesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                const Spacer(),
                                const Center(
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 1.50),
                                ),
                                const Spacer(),
                              ],
                            ),
                          );
                        } else {
                          if (source.length == 0) {
                            return Container();
                          } else {
                            return Expanded(
                                child: Noglow(
                                    child: ListView.builder(
                                        controller: _scrollController,
                                        itemCount: source.length + 1,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          if (index == source.length) {
                                            if (isLoading) {
                                              return Center(
                                                child: Container(
                                                  margin: const EdgeInsets.all(
                                                      10.0),
                                                  height: 35.0,
                                                  width: 35.0,
                                                  child: Center(
                                                    child:
                                                        const CircularProgressIndicator(
                                                            strokeWidth: 1.50),
                                                  ),
                                                ),
                                              );
                                            }
                                            if (isLastPage) {
                                              return emptyBox;
                                            }
                                          } else {
                                            return NewFlareLikes(
                                                userName: source[index]
                                                    .data()['user']
                                                    .toString(),
                                                flareID: source[index]
                                                    .data()['flareID']
                                                    .toString(),
                                                date: source[index]
                                                    .data()['date']
                                                    .toDate(),
                                                collectionID: source[index]
                                                    .data()['collectionID']);
                                          }
                                          return emptyBox;
                                        })));
                          }
                        }
                      })
                ]))));
  }
}
