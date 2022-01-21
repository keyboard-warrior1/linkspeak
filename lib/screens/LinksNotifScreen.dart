import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/linkedUsers.dart';
import '../widgets/settingsBar.dart';

class NewLinksScreen extends StatefulWidget {
  const NewLinksScreen();

  @override
  _NewLinksScreenState createState() => _NewLinksScreenState();
}

class _NewLinksScreenState extends State<NewLinksScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _linksFuture;
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLastPage = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> source = [];

  Future<void> getNewLinks() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    final _linksCollection = await firestore
        .collection('Users')
        .doc(_myProfile.getUsername.toString())
        .collection('NewLinksNotifs')
        .limit(30)
        .get();
    final docs = _linksCollection.docs;
    for (var item in docs) {
      source.add(item);
    }
    if (docs.length < 30) {
      isLastPage = true;
    }

    setState(() {});
  }

  Future<void> getMoreLinks() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      final lastItem = source.last;
      final _linkedCollection = await firestore
          .collection('Users')
          .doc(_myProfile.getUsername.toString())
          .collection('NewLinksNotifs')
          .startAfterDocument(lastItem)
          .limit(15)
          .get();
      final docs = _linkedCollection.docs;
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

  String _topicNumber(num value) {
    if (value >= 99) {
      return '99+';
    } else {
      return value.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    _linksFuture = getNewLinks();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreLinks();
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
    final _num = Provider.of<MyProfile>(context).myNumOfNewLinksNotifs;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: _deviceHeight,
          width: _deviceWidth,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SettingsBar('New links  ${_topicNumber(_num)}'),
              FutureBuilder(
                future: _linksFuture,
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
                              return NewLinks(
                                userName: source[index].id,
                                date: source[index].data()['date'].toDate(),
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
