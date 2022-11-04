import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/alerts/newMentions.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class MentionsScreen extends StatefulWidget {
  const MentionsScreen();

  @override
  State<MentionsScreen> createState() => _MentionsScreenState();
}

class _MentionsScreenState extends State<MentionsScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _mentionsFuture;
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLastPage = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> source = [];

  Future<void> getMentions() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    final _likesCollection = await firestore
        .collection('Users')
        .doc(_myProfile.getUsername.toString())
        .collection('Mention Box')
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

  Future<void> getMoreMentions() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      final lastItem = source.last;
      final _likesCollection = await firestore
          .collection('Users')
          .doc(_myProfile.getUsername.toString())
          .collection('Mention Box')
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
    _mentionsFuture = getMentions();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreMentions();
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
    // final _num = Provider.of<MyProfile>(context).myNumOfMentions;
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // SettingsBar('Mentions  ${General.topicNumber(_num)}'),
              const SettingsBar('Mentions'),
              FutureBuilder(
                future: _mentionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                            itemBuilder: (BuildContext context, int index) {
                              if (index == source.length) {
                                if (isLoading) {
                                  return Center(
                                    child: Container(
                                      margin: const EdgeInsets.all(10.0),
                                      height: 35.0,
                                      width: 35.0,
                                      child: Center(
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 1.50),
                                      ),
                                    ),
                                  );
                                }
                                if (isLastPage) {
                                  return emptyBox;
                                }
                              } else {
                                return NewMentions(
                                    flarePoster: source[index]
                                        .data()['posterName']
                                        .toString(),
                                    collectionID: source[index]
                                        .data()['collectionID']
                                        .toString(),
                                    userName: source[index]
                                        .data()['mentioned by']
                                        .toString(),
                                    postID: source[index]
                                        .data()['postID']
                                        .toString(),
                                    commentID: source[index]
                                        .data()['commentID']
                                        .toString(),
                                    replyID: source[index]
                                        .data()['replyID']
                                        .toString(),
                                    flareID: source[index]
                                        .data()['flareID']
                                        .toString(),
                                    commenterName: source[index]
                                        .data()['commenterName']
                                        .toString(),
                                    clubName: source[index]
                                        .data()['clubName']
                                        .toString(),
                                    posterName: source[index]
                                        .data()['posterName']
                                        .toString(),
                                    isClubPost:
                                        source[index].data()['isClubPost'],
                                    flareCommentID: source[index]
                                        .data()['flareCommentID']
                                        .toString(),
                                    flareReplyID: source[index]
                                        .data()['flareReplyID']
                                        .toString(),
                                    isPost: source[index].data()['isPost'],
                                    isComment:
                                        source[index].data()['isComment'],
                                    isReply: source[index].data()['isReply'],
                                    isBio: source[index].data()['isBio'],
                                    isFlare: source[index].data()['isFlare'],
                                    isFlareComment:
                                        source[index].data()['isFlareComment'],
                                    isFlareReply:
                                        source[index].data()['isFlareReply'],
                                    isFlaresBio:
                                        source[index].data()['isFlaresBio'],
                                    date:
                                        source[index].data()['date'].toDate());
                              }
                              return emptyBox;
                            },
                          ),
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
