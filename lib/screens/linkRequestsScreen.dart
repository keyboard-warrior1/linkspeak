import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:link_speak/providers/myProfileProvider.dart';
import 'package:provider/provider.dart';
import '../widgets/linkRequest.dart';
import '../widgets/settingsBar.dart';

class LinkRequestsScreen extends StatefulWidget {
  const LinkRequestsScreen();

  @override
  _LinkRequestsScreenState createState() => _LinkRequestsScreenState();
}

class _LinkRequestsScreenState extends State<LinkRequestsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _linkRequestFuture;
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLastPage = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> source = [];
  Future<void> getLinkRequests() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    final _linkRequestsCollection = await firestore
        .collection('Users')
        .doc(_myProfile.getUsername.toString())
        .collection('LinkRequestsNotifs')
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
      MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
      final lastRequest = source.last;
      final getLastRequest = await firestore
          .collection('Users')
          .doc(_myProfile.getUsername.toString())
          .collection('LinkRequestsNotifs')
          .doc(lastRequest.id)
          .get();
      if (getLastRequest.exists) {
        final _linkRequestsCollection = await firestore
            .collection('Users')
            .doc(_myProfile.getUsername.toString())
            .collection('LinkRequestsNotifs')
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
            .collection('Users')
            .doc(_myProfile.getUsername.toString())
            .collection('LinkRequestsNotifs')
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

  String _topicNumber(num value) {
    if (value >= 99) {
      return '99+';
    } else {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _num = Provider.of<MyProfile>(context).myNumOfLinkRequestNotifs;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SettingsBar('Requests  ${_topicNumber(_num)}'),
              FutureBuilder(
                future: _linkRequestFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          const Spacer(),
                          const Center(
                            child: const CircularProgressIndicator(),
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
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: source.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == source.length) {
                              if (isLoading) {
                                return Center(
                                  child: Container(
                                    margin: const EdgeInsets.all(10.0),
                                    height: 35.0,
                                    width: 35.0,
                                    child: Center(
                                      child: const CircularProgressIndicator(),
                                    ),
                                  ),
                                );
                              }
                              if (isLastPage) {
                                return emptyBox;
                              }
                            } else {
                              return NewLinkRequest(
                                requestProfile: source[index].id.toString(),
                              );
                            }
                            return emptyBox;
                          },
                        ),
                      );
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
