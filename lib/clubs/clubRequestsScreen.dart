import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../general.dart';
import '../clubs/clubJoinRequest.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class ClubRequestScreen extends StatefulWidget {
  final dynamic clubName;
  final dynamic addMembers;
  final dynamic decreaseNotifs;
  const ClubRequestScreen(
      {required this.clubName,
      required this.addMembers,
      required this.decreaseNotifs});

  @override
  _ClubRequestScreenState createState() => _ClubRequestScreenState();
}

class _ClubRequestScreenState extends State<ClubRequestScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _linkRequestFuture;
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLastPage = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> source = [];
  Future<void> getLinkRequests() async {
    final _linkRequestsCollection = await firestore
        .collection('Clubs')
        .doc(widget.clubName)
        .collection('JoinRequests')
        .orderBy('date', descending: true)
        .limit(30)
        .get();
    final docs = _linkRequestsCollection.docs;
    for (var item in docs) {
      source.add(item);
    }
    if (docs.length < 30) {
      isLastPage = true;
    }
    setState(() {});
  }

  Future<void> getMoreLinkRequests() async {
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      final lastRequest = source.last;
      final getLastRequest = await firestore
          .collection('Clubs')
          .doc(widget.clubName)
          .collection('JoinRequests')
          .doc(lastRequest.id)
          .get();
      if (getLastRequest.exists) {
        final _linkRequestsCollection = await firestore
            .collection('Clubs')
            .doc(widget.clubName)
            .collection('JoinRequests')
            .orderBy('date', descending: true)
            .startAfterDocument(getLastRequest)
            .limit(30)
            .get();
        final docs = _linkRequestsCollection.docs;
        for (var item in docs) {
          if (!source.any((element) => element.id == item.id)) source.add(item);
        }
        if (docs.length < 30) {
          isLastPage = true;
        }
        isLoading = false;
        setState(() {});
      } else {
        final _linkRequestsCollection = await firestore
            .collection('Clubs')
            .doc(widget.clubName)
            .collection('JoinRequests')
            .orderBy('date', descending: true)
            .limit(35)
            .get();
        final docs = _linkRequestsCollection.docs;
        for (var item in docs) {
          if (!source.any((element) => element.id == item.id)) source.add(item);
        }
        if (docs.length < 35) {
          isLastPage = true;
        }
        isLoading = false;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _linkRequestFuture = getLinkRequests();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreLinkRequests();
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
    // final _num = Provider.of<MyProfile>(context).myNumOfLinkRequestNotifs;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final lang = General.language(context);
    return Scaffold(
        appBar: null,
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Column(mainAxisSize: MainAxisSize.max, children: [
                  // SettingsBar('Requests  ${General.topicNumber(_num)}'),
                  SettingsBar(lang.clubs_requests),
                  FutureBuilder(
                      future: _linkRequestFuture,
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
                                        strokeWidth: 1.50)),
                                const Spacer()
                              ]));
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
                                                      margin:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      height: 35.0,
                                                      width: 35.0,
                                                      child: Center(
                                                          child:
                                                              const CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      1.50))));
                                            }
                                            if (isLastPage) {
                                              return emptyBox;
                                            }
                                          } else {
                                            return NewJoinRequest(
                                              clubName: widget.clubName,
                                              requestProfile:
                                                  source[index].id.toString(),
                                              decreaseNotifs:
                                                  widget.decreaseNotifs,
                                              addMembers: widget.addMembers,
                                            );
                                          }
                                          return emptyBox;
                                        })));
                          }
                        }
                      })
                ]))));
  }
}
