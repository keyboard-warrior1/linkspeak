import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/miniProfile.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/chatprofileImage.dart';
import '../widgets/common/noglow.dart';

class FlareViews extends StatefulWidget {
  final String poster;
  final String collectionID;
  final String flareID;
  final int numOfViews;
  const FlareViews(
      {required this.poster,
      required this.collectionID,
      required this.flareID,
      required this.numOfViews});

  @override
  State<FlareViews> createState() => _FlareViewsState();
}

class _FlareViewsState extends State<FlareViews> {
  final _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool userSearchLoading = false;
  bool _clearable = false;
  late Future<void> _getLikers;
  List<MiniProfile> uppers = [];
  List<MiniProfile> userSearchResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> fullLikers = [];
  bool isLoading = false;
  bool isLastPage = false;

  Future<void> getLikers(
      {required String myUsername,
      required int numOfLikes,
      required String poster,
      required String collectionID,
      required String flareID}) async {
    if (numOfLikes == 0) {
      return;
    } else {
      final myLike = await firestore
          .collection('Flares')
          .doc(poster)
          .collection('collections')
          .doc(collectionID)
          .collection('flares')
          .doc(flareID)
          .collection('views')
          .doc(myUsername)
          .get();
      if (myLike.exists) {
        final MiniProfile _liker = MiniProfile(username: myUsername);
        uppers.insert(0, _liker);
      }
      final allPostLikers = await firestore
          .collection('Flares')
          .doc(poster)
          .collection('collections')
          .doc(collectionID)
          .collection('flares')
          .doc(flareID)
          .collection('views')
          .get();
      final allLikeDocs = allPostLikers.docs;
      fullLikers = allLikeDocs;
      final postLikers = await firestore
          .collection('Flares')
          .doc(poster)
          .collection('collections')
          .doc(collectionID)
          .collection('flares')
          .doc(flareID)
          .collection('views')
          .orderBy('date', descending: true)
          .limit(20)
          .get();
      final likersList = postLikers.docs;
      for (var liker in likersList) {
        if (liker.id == myUsername) {
        } else {
          final likerName = liker.id;
          final MiniProfile _liker = MiniProfile(username: likerName);
          uppers.add(_liker);
        }
      }
      if (likersList.length < 20) {
        isLastPage = true;
      }
      setState(() {});
    }
  }

  Future<void> getMoreLikers(
      {required String myUsername,
      required int numOfLikes,
      required String poster,
      required String collectionID,
      required String flareID}) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      final lastLiker = uppers.last.username;
      final getLastLiker = await firestore
          .collection('Flares')
          .doc(poster)
          .collection('collections')
          .doc(collectionID)
          .collection('flares')
          .doc(flareID)
          .collection('views')
          .doc(lastLiker)
          .get();
      final postLikers = await firestore
          .collection('Flares')
          .doc(poster)
          .collection('collections')
          .doc(collectionID)
          .collection('flares')
          .doc(flareID)
          .collection('views')
          .orderBy('date', descending: true)
          .startAfterDocument(getLastLiker)
          .limit(20)
          .get();
      final likersList = postLikers.docs;
      for (var liker in likersList) {
        if (liker.id == myUsername) {
        } else {
          final likerName = liker.id;
          final MiniProfile _liker = MiniProfile(username: likerName);
          uppers.add(_liker);
        }
      }
      if (likersList.length < 20) {
        isLastPage = true;
      }
      isLoading = false;
      setState(() {});
    }
  }

  void getUserResults(String name) {
    final lowerCaseName = name.toLowerCase();
    fullLikers.forEach((doc) {
      if (userSearchResults.length < 20) {
        final String id = doc.id.toString().toLowerCase();
        final String username = doc.id;
        if (id.startsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getLikers = getLikers(
        myUsername: myUsername,
        numOfLikes: widget.numOfViews,
        poster: widget.poster,
        collectionID: widget.collectionID,
        flareID: widget.flareID);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreLikers(
                myUsername: myUsername,
                numOfLikes: widget.numOfViews,
                poster: widget.poster,
                collectionID: widget.collectionID,
                flareID: widget.flareID);
          }
        }
      }
    });
    _textController.addListener(() {
      if (_textController.value.text.isNotEmpty) {
        if (!_clearable)
          setState(() {
            _clearable = true;
          });
      } else {}

      if (_textController.value.text.isEmpty) {
        if (_clearable)
          setState(() {
            _clearable = false;
          });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    _textController.removeListener(() {});
    _textController.dispose();
  }

  Future<void> _pullRefresh(
      {required String myUsername,
      required int numOfLikes,
      required String poster,
      required String collectionID,
      required String flareID}) async {
    setState(() {
      _getLikers = getLikers(
          myUsername: myUsername,
          numOfLikes: numOfLikes,
          poster: poster,
          collectionID: collectionID,
          flareID: flareID);
    });
  }

  void visitProfile(String username, String myUsername) {
    if (username == myUsername) {
      Navigator.pushNamed(context, RouteGenerator.myProfileScreen);
    } else {
      final args = OtherProfileScreenArguments(otherProfileId: username);
      Navigator.pushNamed(context, RouteGenerator.posterProfileScreen,
          arguments: args);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5)),
                        height: 4,
                        width: 50)
                  ]),
              Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.shade200, width: 1))),
                  child: Row(children: <Widget>[
                    const Text('Viewers  ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black)),
                    if (widget.numOfViews > 0)
                      Text('${General.optimisedNumbers(widget.numOfViews)}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),
                    const Spacer(),
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.black))
                  ])),
              Expanded(
                  child: FutureBuilder(
                      future: _getLikers,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const <Widget>[
                                const Center(
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 1.50)),
                              ]);
                        }
                        if (snapshot.hasError) {
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                    'An error has occured, please try again',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18)),
                                const SizedBox(height: 10.0),
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<Color?>(
                                                    _primaryColor),
                                            padding: MaterialStateProperty.all<
                                                    EdgeInsetsGeometry?>(
                                                const EdgeInsets.all(0.0)),
                                            shape: MaterialStateProperty.all<
                                                    OutlinedBorder?>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10.0)))),
                                        onPressed: () {
                                          setState(() {
                                            _getLikers = getLikers(
                                                myUsername: myUsername,
                                                numOfLikes: widget.numOfViews,
                                                poster: widget.poster,
                                                collectionID:
                                                    widget.collectionID,
                                                flareID: widget.flareID);
                                          });
                                        },
                                        child: Center(child: Text('Retry', style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold)))))
                              ]);
                        }
                        int numOfUppers = uppers.length;
                        return (numOfUppers == 0)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    Container(
                                        height: deviceHeight * 0.3,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.play_circle_outline,
                                                  color: Colors.grey.shade400,
                                                  size: 75.0),
                                              const SizedBox(height: 10.0),
                                              Center(
                                                  child: Text(
                                                      "This flare hasn't been viewed yet",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade400,
                                                          fontSize: 25.0)))
                                            ]))
                                  ])
                            : Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 8.0),
                                        child: TextField(
                                            onChanged: (text) async {
                                              if (text.isEmpty) {
                                                if (userSearchResults
                                                    .isNotEmpty)
                                                  userSearchResults.clear();
                                              } else {
                                                if (!userSearchLoading) {
                                                  if (userSearchResults
                                                      .isNotEmpty)
                                                    userSearchResults.clear();
                                                }
                                                if (!userSearchLoading) {
                                                  setState(() {
                                                    userSearchLoading = true;
                                                  });
                                                }
                                                getUserResults(text);
                                                setState(() {
                                                  userSearchLoading = false;
                                                });
                                              }
                                            },
                                            controller: _textController,
                                            decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.search,
                                                    color: Colors.grey),
                                                suffixIcon: (_clearable)
                                                    ? IconButton(
                                                        splashColor:
                                                            Colors.transparent,
                                                        tooltip: 'Clear',
                                                        onPressed: () {
                                                          setState(() {
                                                            _textController
                                                                .clear();
                                                            userSearchResults
                                                                .clear();
                                                            _clearable = false;
                                                          });
                                                        },
                                                        icon: const Icon(
                                                            Icons.clear,
                                                            color: Colors.grey))
                                                    : null,
                                                filled: true,
                                                fillColor: Colors.grey.shade200,
                                                hintText: 'Search viewers',
                                                hintStyle: const TextStyle(
                                                    color: Colors.grey),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        BorderSide.none)))),
                                    if (_textController.value.text.isNotEmpty &&
                                        userSearchResults.isEmpty &&
                                        !userSearchLoading)
                                      Container(
                                          child: const Center(
                                              child: const Text(
                                                  'No results found',
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 49, 49, 49))))),
                                    if (userSearchResults.isNotEmpty &&
                                        !userSearchLoading)
                                      Expanded(
                                          child: Noglow(
                                              child: ListView(
                                                  keyboardDismissBehavior:
                                                      ScrollViewKeyboardDismissBehavior
                                                          .onDrag,
                                                  children: <Widget>[
                                            ...userSearchResults
                                                .take(20)
                                                .map((result) {
                                              final int index =
                                                  userSearchResults
                                                      .indexOf(result);
                                              final current =
                                                  userSearchResults[index];
                                              final username = current.username;
                                              return ListTile(
                                                  key: ValueKey<String>(
                                                      username),
                                                  horizontalTitleGap: 5,
                                                  leading: ChatProfileImage(
                                                      username: username,
                                                      factor: 0.05,
                                                      inEdit: false,
                                                      asset: null),
                                                  title: Text(' $username'),
                                                  onTap: () => visitProfile(
                                                      username, myUsername));
                                            })
                                          ]))),
                                    if (_textController.value.text.isEmpty)
                                      Expanded(
                                          child: RefreshIndicator(
                                              onRefresh: () => _pullRefresh(
                                                  myUsername: myUsername,
                                                  numOfLikes: widget.numOfViews,
                                                  poster: widget.poster,
                                                  collectionID:
                                                      widget.collectionID,
                                                  flareID: widget.flareID),
                                              color: _accentColor,
                                              backgroundColor: _primaryColor,
                                              displacement: 2.0,
                                              child: ListView.builder(
                                                  keyboardDismissBehavior:
                                                      ScrollViewKeyboardDismissBehavior
                                                          .onDrag,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 85.0),
                                                  controller: _scrollController,
                                                  itemCount: uppers.length + 1,
                                                  itemBuilder: (_, index) {
                                                    if (index ==
                                                        uppers.length) {
                                                      if (isLoading) {
                                                        return Center(
                                                            child: SizedBox(
                                                                height: 35.0,
                                                                width: 35.0,
                                                                child: Center(
                                                                    child: const CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            1.50))));
                                                      }
                                                      if (isLastPage) {
                                                        return emptyBox;
                                                      }
                                                    } else {
                                                      final upper =
                                                          uppers[index];
                                                      return ListTile(
                                                          key: ValueKey<String>(
                                                              upper.username),
                                                          horizontalTitleGap: 5,
                                                          leading:
                                                              ChatProfileImage(
                                                                  username: upper
                                                                      .username,
                                                                  factor: 0.05,
                                                                  inEdit: false,
                                                                  asset: null),
                                                          title: Text(
                                                              ' ${upper.username}'),
                                                          onTap: () =>
                                                              visitProfile(
                                                                  upper
                                                                      .username,
                                                                  myUsername));
                                                    }
                                                    return emptyBox;
                                                  })))
                                  ]);
                      }))
            ]));
  }
}
