import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:link_speak/providers/myProfileProvider.dart';
import 'package:provider/provider.dart';
import '../widgets/newComments.dart';

import '../widgets/settingsBar.dart';

class PostCommentsNotifScreen extends StatefulWidget {
  const PostCommentsNotifScreen();

  @override
  _PostCommentsNotifScreenState createState() =>
      _PostCommentsNotifScreenState();
}

class _PostCommentsNotifScreenState extends State<PostCommentsNotifScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _commentsFuture;
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLastPage = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> source = [];

  Future<void> getComments() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    final _commentsCollection = await firestore
        .collection('Users')
        .doc(_myProfile.getUsername.toString())
        .collection('PostCommentsNotifs')
        .limit(30)
        .get();

    final docs = _commentsCollection.docs;
    for (var item in docs) {
      source.add(item);
    }
    if (docs.length < 30) {
      isLastPage = true;
    }

    setState(() {});
  }

  Future<void> getMoreComments() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      final lastItem = source.last;
      final _commentsCollection = await firestore
          .collection('Users')
          .doc(_myProfile.getUsername.toString())
          .collection('PostCommentsNotifs')
          .startAfterDocument(lastItem)
          .limit(15)
          .get();

      final docs = _commentsCollection.docs;
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
    _commentsFuture = getComments();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreComments();
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
    final _num = Provider.of<MyProfile>(context).myNumOfPostCommentsNotifs;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Container(
          height: _deviceHeight,
          width: _deviceWidth,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SettingsBar('Comments  ${_topicNumber(_num)}'),
              FutureBuilder(
                future: _commentsFuture,
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
                              return NewComments(
                                commentUserName: source[index].data()['user'].toString(),
                                postUrl:
                                    source[index].data()['post'].toString(),
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
