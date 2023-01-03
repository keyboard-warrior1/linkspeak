import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/miniProfile.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/themeModel.dart';
import '../common/chatprofileImage.dart';
import '../common/nestedScroller.dart';
import '../common/noglow.dart';

class LikesView extends StatefulWidget {
  final int numOfLikes;
  final ScrollController scrollController;
  final void Function(BuildContext, String, String) handler;
  final String postID;
  LikesView(this.numOfLikes, this.scrollController, this.handler, this.postID);
  @override
  _LikesViewState createState() => _LikesViewState();
}

class _LikesViewState extends State<LikesView> {
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
  Future<void> getLikers(String myUsername, String myIMG) async {
    if (widget.numOfLikes == 0) {
      return;
    } else {
      final myLike = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
          .doc(myUsername)
          .get();
      if (myLike.exists) {
        final MiniProfile _liker = MiniProfile(username: myUsername);
        uppers.insert(0, _liker);
      }
      final allPostLikers = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
          .get();
      final allLikeDocs = allPostLikers.docs;
      fullLikers = allLikeDocs;
      final postLikers = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
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
      Future.delayed(
          const Duration(milliseconds: 50),
          () => widget.scrollController.animateTo(
                widget.scrollController.position.maxScrollExtent,
                duration: kThemeAnimationDuration,
                curve: Curves.easeOut,
              ));
    }
  }

  Future<void> getMoreLikers(String myUsername) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      final lastLiker = uppers.last.username;
      final getLastLiker = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
          .doc(lastLiker)
          .get();
      final postLikers = await firestore
          .collection('Posts')
          .doc(widget.postID)
          .collection('likers')
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
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    _getLikers = getLikers(myUsername, myIMG);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreLikers(myUsername);
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

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = General.widthQuery(context);
    final themeIconHelper = Provider.of<ThemeModel>(context, listen: false);
    final String currentIconName = themeIconHelper.selectedIconName;
    final IconData currentIcon = themeIconHelper.themeIcon;
    final File? inactiveIconPath = themeIconHelper.inactiveLikeFile;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return FutureBuilder(
        future: _getLikers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container(
                color: Colors.white,
                height: deviceHeight * 0.3,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      const Center(
                          child: const CircularProgressIndicator(
                              strokeWidth: 1.50))
                    ]));

          if (snapshot.hasError)
            return Container(
                color: Colors.white,
                height: deviceHeight * 0.3,
                width: deviceWidth,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(lang.flares_commentLikes2,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 18)),
                      const SizedBox(height: 10.0),
                      TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                                _primaryColor),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry?>(
                              const EdgeInsets.all(0.0),
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder?>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _getLikers = getLikers(myUsername, myIMG);
                            });
                          },
                          child: Center(
                              child: Text(lang.flares_commentLikes3,
                                  style: TextStyle(
                                      color: _accentColor,
                                      fontWeight: FontWeight.bold))))
                    ]));

          int numOfUppers = uppers.length;
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            if (numOfUppers == 0)
              Container(
                  color: Colors.white,
                  height: deviceHeight * 0.3,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentIconName != 'Custom')
                          Icon(currentIcon,
                              color: Colors.grey.shade400, size: 75.0),
                        if (currentIconName == 'Custom')
                          IconButton(
                              padding: const EdgeInsets.all(0.0),
                              onPressed: () {},
                              icon: Image.file(inactiveIconPath!)),
                        const SizedBox(height: 10.0),
                        Center(
                            child: Text(lang.flares_commentLikes4,
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 25.0)))
                      ])),
            if (numOfUppers != 0)
              ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: 10.0, maxHeight: deviceHeight * 0.7),
                  child: Column(
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
                                    if (userSearchResults.isNotEmpty)
                                      userSearchResults.clear();
                                  } else {
                                    if (!userSearchLoading) {
                                      if (userSearchResults.isNotEmpty)
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
                                    prefixIcon: const Icon(Icons.search,
                                        color: Colors.grey),
                                    suffixIcon: (_clearable)
                                        ? IconButton(
                                            splashColor: Colors.transparent,
                                            tooltip: lang.flares_likes3,
                                            onPressed: () {
                                              setState(() {
                                                _textController.clear();
                                                userSearchResults.clear();
                                                _clearable = false;
                                              });
                                            },
                                            icon: const Icon(Icons.clear,
                                                color: Colors.grey))
                                        : null,
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    hintText: lang.flares_likes4,
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide.none)))),
                        if (_textController.value.text.isNotEmpty &&
                            userSearchResults.isEmpty &&
                            !userSearchLoading)
                          Container(
                              child: Center(
                                  child: Text(lang.flares_likes5,
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 49, 49, 49))))),
                        if (userSearchResults.isNotEmpty && !userSearchLoading)
                          Expanded(
                              child: Noglow(
                                  child: ListView(
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      children: <Widget>[
                                ...userSearchResults.take(20).map((result) {
                                  final int index =
                                      userSearchResults.indexOf(result);
                                  final current = userSearchResults[index];
                                  final username = current.username;
                                  return ListTile(
                                      key: ValueKey<String>(username),
                                      horizontalTitleGap: 5,
                                      leading: ChatProfileImage(
                                          username: username,
                                          factor: 0.05,
                                          inEdit: false,
                                          asset: null),
                                      title: Text(' $username'),
                                      onTap: () {
                                        widget.handler(
                                            context, username, myUsername);
                                      });
                                })
                              ]))),
                        if (_textController.value.text.isEmpty)
                          Expanded(
                              child: NestedScroller(
                                  controller: widget.scrollController,
                                  child: ListView.builder(
                                      padding:
                                          const EdgeInsets.only(bottom: 85.0),
                                      controller: _scrollController,
                                      itemCount: uppers.length + 1,
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      itemBuilder: (_, index) {
                                        if (index == uppers.length) {
                                          if (isLoading) {
                                            return Center(
                                                child: SizedBox(
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
                                          final upper = uppers[index];
                                          return ListTile(
                                              key: ValueKey<String>(
                                                  upper.username),
                                              horizontalTitleGap: 5,
                                              leading: ChatProfileImage(
                                                  username: upper.username,
                                                  factor: 0.05,
                                                  inEdit: false,
                                                  asset: null),
                                              title: Text(' ${upper.username}'),
                                              onTap: () {
                                                widget.handler(context,
                                                    upper.username, myUsername);
                                              });
                                        }
                                        return emptyBox;
                                      })))
                      ]))
          ]);
        });
  }
}
