import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/miniProfile.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../common/nestedScroller.dart';
import '../common/noglow.dart';
import '../share/shareTile.dart';

class ShareView extends StatefulWidget {
  final ScrollController scrollController;
  const ShareView(this.scrollController);

  @override
  _ShareViewState createState() => _ShareViewState();
}

class _ShareViewState extends State<ShareView> {
  final TextEditingController _textController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  bool loner = false;
  bool userSearchLoading = false;
  late Future getChatters;
  List<MiniProfile> userSearchResults = [];
  List<MiniProfile> existing = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _fullChats = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _fullLinked = [];
  bool _clearable = false;
  void getUserResults(String name, String myUsername) {
    final lowerCaseName = name.toLowerCase();
    _fullChats.forEach((doc) {
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
    _fullLinked.forEach((doc) {
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

  Future<void> _getChatters(String myUsername) async {
    final myChats =
        await firestore.collection('Users/$myUsername/chats').limit(20).get();
    final docs = myChats.docs;
    final myFullChats =
        await firestore.collection('Users/$myUsername/chats').get();
    final myFullLinked =
        await firestore.collection('Users/$myUsername/Linked').get();
    final fullChatDocs = myFullChats.docs;
    final fullLinkedDocs = myFullLinked.docs;
    _fullChats = fullChatDocs;
    _fullLinked = fullLinkedDocs;
    if (docs.isNotEmpty) {
      for (var doc in docs) {
        final mini = MiniProfile(username: doc.id);
        existing.add(mini);
      }
    } else {
      final myLinked = await firestore
          .collection('Users/$myUsername/Linked')
          .limit(20)
          .get();
      final docs = myLinked.docs;
      if (docs.isNotEmpty) {
        for (var doc in docs) {
          final mini = MiniProfile(username: doc.id);
          existing.add(mini);
        }
      } else {
        setState(() {
          loner = true;
        });
      }
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

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    getChatters = _getChatters(myUsername);
    _textController.addListener(() {
      if (_textController.value.text.isNotEmpty) {
        if (!_clearable) {
          setState(() {
            _clearable = true;
          });
        }
      } else {
        if (_clearable) {
          setState(() {
            _clearable = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textController.removeListener(() {});
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final double deviceHeight = MediaQuery.of(context).size.height;
    final String postID =
        Provider.of<FullHelper>(context, listen: false).postId;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final bool isClubPost =
        Provider.of<FullHelper>(context, listen: false).isClubPost;
    final String clubName =
        Provider.of<FullHelper>(context, listen: false).clubName;
    final Widget _resultList = Expanded(
        child: Noglow(
            child: ListView.builder(
                itemCount: userSearchResults.length,
                itemBuilder: (ctx, index) {
                  final username = userSearchResults[index].username;
                  return Container(
                      key: ValueKey<String>(username),
                      child: ShareTile(
                          username: username,
                          postID: postID,
                          isClubPost: isClubPost,
                          clubName: clubName,
                          isSpotlight: false,
                          flarePoster: '',
                          collectionID: '',
                          flareID: ''));
                })));
    return Container(
        color: Colors.white,
        height: deviceHeight * 0.7,
        child: FutureBuilder(
            future: getChatters,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      const Center(
                          child: const Icon(customIcons.MyFlutterApp.right,
                              color: Colors.grey))
                    ]);

              if (snapshot.hasError)
                return Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(child: Text(lang.clubs_adminScreen2))
                    ]);

              return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                            controller: _textController,
                            onChanged: (text) {
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
                                getUserResults(text, _myUsername);
                                setState(() {
                                  userSearchLoading = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                                suffixIcon: (_clearable)
                                    ? IconButton(
                                        tooltip: lang.clubs_assignAdmin5,
                                        splashColor: Colors.transparent,
                                        onPressed: () {
                                          setState(() {
                                            _textController.clear();
                                            _clearable = false;
                                          });
                                        },
                                        icon: const Icon(Icons.clear,
                                            color: Colors.grey))
                                    : null,
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                hintText: lang.widgets_fullPost13,
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none)))),
                    if (_clearable &&
                        userSearchResults.isNotEmpty &&
                        !userSearchLoading)
                      _resultList,
                    if (_clearable &&
                        userSearchResults.isEmpty &&
                        !userSearchLoading)
                      Center(child: Text(lang.clubs_banMember7)),
                    if (!loner && !_clearable)
                      Expanded(
                          child: NestedScroller(
                              controller: widget.scrollController,
                              child: ListView.builder(
                                  itemCount: existing.length,
                                  itemBuilder: (ctx, index) {
                                    final username = existing[index].username;
                                    return Container(
                                        key: ValueKey<String>(username),
                                        child: ShareTile(
                                            username: username,
                                            postID: postID,
                                            isClubPost: isClubPost,
                                            clubName: clubName,
                                            isSpotlight: false,
                                            flarePoster: '',
                                            collectionID: '',
                                            flareID: ''));
                                  }))),
                    if (loner && !_clearable)
                      Center(child: Text(lang.widgets_fullPost14))
                  ]);
            }));
  }
}
