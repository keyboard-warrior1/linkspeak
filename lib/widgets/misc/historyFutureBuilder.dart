import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/themeModel.dart';
import '../common/myFab.dart';
import '../common/noglow.dart';
import 'historyTileItem.dart';

class HistoryFutureBuilder extends StatefulWidget {
  final bool isPeopleComments;
  final bool isClubComments;
  final bool isFlareComments;
  final bool isPeoplePostReplies;
  final bool isClubPostReplies;
  final bool isFlareReplies;

  const HistoryFutureBuilder(
      {required this.isPeopleComments,
      required this.isClubComments,
      required this.isFlareComments,
      required this.isPeoplePostReplies,
      required this.isClubPostReplies,
      required this.isFlareReplies});

  @override
  State<HistoryFutureBuilder> createState() => _HistoryFutureBuilderState();
}

class _HistoryFutureBuilderState extends State<HistoryFutureBuilder>
    with AutomaticKeepAliveClientMixin {
  final ScrollController controller = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool isLastPage = false;
  late Future<void> getHistory;
  List<QueryDocumentSnapshot> history = [];
  Widget buildEmptyComments() {
    final lang = General.language(context);
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.chat_bubble_outline_rounded,
              color: Colors.black, size: 25),
          Text(lang.flares_comments4,
              style: const TextStyle(color: Colors.grey, fontSize: 19))
        ]);
  }

  Widget buildEmptyReplies() {
    final lang = General.language(context);
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.reply_all_rounded, color: Colors.black, size: 25),
          Text(lang.flares_repliesScreen2,
              style: const TextStyle(color: Colors.grey, fontSize: 19))
        ]);
  }

  Widget buildEmpty() {
    if (widget.isPeopleComments ||
        widget.isClubComments ||
        widget.isFlareComments) return buildEmptyComments();
    return buildEmptyReplies();
  }

  Widget buildLoading() => Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Center(
                child: const CircularProgressIndicator(strokeWidth: 1.50)),
          ]);
  Widget buildError(String myUsername) {
    final lang = General.language(context);
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                Text(lang.flares_commentLikes2,
                    style:
                        const TextStyle(color: Colors.black, fontSize: 15.0)),
                const SizedBox(width: 10.0),
                SizedBox(
                    height: 35.0,
                    width: 75.0,
                    child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                                Theme.of(context).colorScheme.primary),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                    const EdgeInsets.all(0.0)),
                            shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)))),
                        onPressed: () {
                          isLastPage = false;
                          isLoading = false;
                          history.clear();
                          setState(() {
                            getHistory = _getHistory(myUsername);
                          });
                        },
                        child: Center(
                            child: Text(lang.flares_commentLikes3,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold)))))
              ]))
        ]);
  }

  String giveCollectionName() {
    if (widget.isPeopleComments) return 'My Comments';
    if (widget.isClubComments) return 'Club Comments';
    if (widget.isFlareComments) return 'Flare Comments';
    if (widget.isPeoplePostReplies) return 'My Replies';
    if (widget.isClubPostReplies) return 'Club Replies';
    if (widget.isFlareReplies) return 'Flare Replies';
    return '';
  }

  Future<bool> checkExistance(
      {required String flarePoster,
      required String collectionID,
      required String postOrFlareID,
      required String commentID,
      required String itemID}) async {
    String generateDocAddress() {
      if (widget.isPeopleComments || widget.isClubComments)
        return 'Posts/$postOrFlareID/comments/$itemID';
      if (widget.isFlareComments)
        return 'Flares/$flarePoster/collections/$collectionID/flares/$postOrFlareID/comments/$itemID';
      if (widget.isPeoplePostReplies || widget.isClubPostReplies)
        return 'Posts/$postOrFlareID/comments/$commentID/replies/$itemID';
      if (widget.isFlareReplies)
        return 'Flares/$flarePoster/collections/$collectionID/flares/$postOrFlareID/comments/$commentID/replies/$itemID';
      return '';
    }

    final theDoc = firestore.doc(generateDocAddress());
    final getDoc = await theDoc.get();
    return getDoc.exists;
  }

// sort by date
  Future<void> _getHistory(String myUsername) async {
    List<QueryDocumentSnapshot> tempHistory = [];
    final String collectionName = giveCollectionName();
    final theCollection = firestore
        .collection('Users')
        .doc(myUsername)
        .collection(collectionName);
    do {
      if (history.isEmpty) {
        final _getColl = await theCollection
            .orderBy('date', descending: true)
            .limit(30)
            .get();
        final _docs = _getColl.docs;
        if (_docs.isEmpty) {
          return;
        }
        for (var doc in _docs) {
          dynamic getter(String field) => doc.get(field);
          String flarePoster = '';
          String collectionID = '';
          String postOrFlareID = '';
          String commentID = '';
          String itemID = '';
          if (widget.isPeopleComments || widget.isClubComments) {
            postOrFlareID = getter('post ID');
            itemID = doc.id;
          }
          if (widget.isFlareComments) {
            flarePoster = getter('flarePoster');
            collectionID = getter('collectionID');
            postOrFlareID = getter('flare ID');
            itemID = doc.id;
          }
          if (widget.isPeoplePostReplies || widget.isClubPostReplies) {
            postOrFlareID = getter('post ID');
            commentID = getter('comment ID');
            itemID = doc.id;
          }
          if (widget.isFlareReplies) {
            flarePoster = getter('poster');
            collectionID = getter('collectionID');
            postOrFlareID = getter('flareID');
            commentID = getter('comment ID');
            itemID = doc.id;
          }
          bool exists = await checkExistance(
              flarePoster: flarePoster,
              collectionID: collectionID,
              postOrFlareID: postOrFlareID,
              commentID: commentID,
              itemID: itemID);
          if (exists) {
            if (!tempHistory.any((__doc) => __doc.id == doc.id)) {
              tempHistory.add(doc);
            }
          } else {}
        }
        if (_docs.length < 30) {
          isLastPage = true;
        }
      } else {
        final lastDoc = history.last.id;
        final getLastDoc = await theCollection.doc(lastDoc).get();
        final _getColl = await theCollection
            .orderBy('date', descending: true)
            .startAfterDocument(getLastDoc)
            .limit(30)
            .get();
        final _docs = _getColl.docs;
        for (var doc in _docs) {
          dynamic getter(String field) => doc.get(field);
          String flarePoster = '';
          String collectionID = '';
          String postOrFlareID = '';
          String commentID = '';
          String itemID = '';
          if (widget.isPeopleComments || widget.isClubComments) {
            postOrFlareID = getter('post ID');
            itemID = doc.id;
          }
          if (widget.isFlareComments) {
            flarePoster = getter('flarePoster');
            collectionID = getter('collectionID');
            postOrFlareID = getter('flare ID');
            itemID = doc.id;
          }
          if (widget.isPeoplePostReplies || widget.isClubPostReplies) {
            postOrFlareID = getter('post ID');
            commentID = getter('comment ID');
            itemID = doc.id;
          }
          if (widget.isFlareReplies) {
            flarePoster = getter('poster');
            collectionID = getter('collectionID');
            postOrFlareID = getter('flareID');
            commentID = getter('comment ID');
            itemID = doc.id;
          }
          bool exists = await checkExistance(
              flarePoster: flarePoster,
              collectionID: collectionID,
              postOrFlareID: postOrFlareID,
              commentID: commentID,
              itemID: itemID);
          if (exists) {
            if (!tempHistory.any((__doc) => __doc.id == doc.id)) {
              tempHistory.add(doc);
            }
          } else {}
        }
        if (_docs.length < 30) {
          isLastPage = true;
        }
      }
    } while (tempHistory.length < 30 && !isLastPage);
    history.addAll(tempHistory);
    setState(() {});
  }

  Future<void> _getMoreHistory(String myUsername) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<QueryDocumentSnapshot> tempHistory = [];
      final String collectionName = giveCollectionName();
      final theCollection = firestore
          .collection('Users')
          .doc(myUsername)
          .collection(collectionName);
      do {
        final lastDoc = history.last.id;
        final getLastDoc = await theCollection.doc(lastDoc).get();
        final _getColl = await theCollection
            .orderBy('date', descending: true)
            .startAfterDocument(getLastDoc)
            .limit(30)
            .get();
        final _docs = _getColl.docs;
        for (var doc in _docs) {
          dynamic getter(String field) => doc.get(field);
          String flarePoster = '';
          String collectionID = '';
          String postOrFlareID = '';
          String commentID = '';
          String itemID = '';
          if (widget.isPeopleComments || widget.isClubComments) {
            postOrFlareID = getter('post ID');
            itemID = doc.id;
          }
          if (widget.isFlareComments) {
            flarePoster = getter('flarePoster');
            collectionID = getter('collectionID');
            postOrFlareID = getter('flare ID');
            itemID = doc.id;
          }
          if (widget.isPeoplePostReplies || widget.isClubPostReplies) {
            postOrFlareID = getter('post ID');
            commentID = getter('comment ID');
            itemID = doc.id;
          }
          if (widget.isFlareReplies) {
            flarePoster = getter('poster');
            collectionID = getter('collectionID');
            postOrFlareID = getter('flareID');
            commentID = getter('comment ID');
            itemID = doc.id;
          }
          bool exists = await checkExistance(
              flarePoster: flarePoster,
              collectionID: collectionID,
              postOrFlareID: postOrFlareID,
              commentID: commentID,
              itemID: itemID);
          if (exists) {
            if (!tempHistory.any((__doc) => __doc.id == doc.id)) {
              tempHistory.add(doc);
            }
          } else {}
        }
        if (_docs.length < 30) {
          isLastPage = true;
        }
      } while (tempHistory.length < 30 && !isLastPage);
      isLoading = false;
      history.addAll(tempHistory);
      setState(() {});
    }
  }

  Future<void> _pullRefresh(String myUsername) async {
    isLastPage = false;
    isLoading = false;
    history.clear();
    setState(() {
      getHistory = _getHistory(myUsername);
    });
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    getHistory = _getHistory(myUsername);
    controller.addListener(() async {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            _getMoreHistory(myUsername);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(() {});
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: getHistory,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return buildLoading();
          if (snapshot.hasError)
            return buildError(
                Provider.of<MyProfile>(context, listen: false).getUsername);
          return history.isEmpty
              ? buildEmpty()
              : Stack(children: <Widget>[
                  RefreshIndicator(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      displacement: 2.0,
                      color: Theme.of(context).colorScheme.secondary,
                      onRefresh: () => _pullRefresh(
                          Provider.of<MyProfile>(context, listen: false)
                              .getUsername),
                      child: Noglow(
                          child: ListView.builder(
                              controller: controller,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(bottom: 85.0),
                              itemCount: history.length + 1,
                              itemBuilder: (_, index) {
                                if (index == history.length) {
                                  if (isLoading || isLastPage)
                                    return const SizedBox(width: 0, height: 0);
                                } else {
                                  return HistoryTileItem(
                                      item: history[index],
                                      isPeopleComments: widget.isPeopleComments,
                                      isClubComments: widget.isClubComments,
                                      isFlareComments: widget.isFlareComments,
                                      isPeoplePostReplies:
                                          widget.isPeoplePostReplies,
                                      isClubPostReplies:
                                          widget.isClubPostReplies,
                                      isFlareReplies: widget.isFlareReplies);
                                }
                                return const SizedBox(width: 0, height: 0);
                              }))),
                  if (Provider.of<ThemeModel>(context, listen: false)
                      .anchorMode)
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: MyFab(controller)))
                ]);
        });
  }

  @override
  bool get wantKeepAlive => true;
}
