import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/miniProfile.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/myProfileProvider.dart';
import '../../screens/favoritePostsScreen.dart';
import '../../screens/feedScreen.dart';
import '../../screens/likedPostScreen.dart';
import '../common/noglow.dart';
import '../profile/postsTab.dart';
import 'shareTile.dart';

class ShareWidget extends StatefulWidget {
  final bool isInFeed;
  final PersistentBottomSheetController? bottomSheetController;
  final String postID;
  final String clubName;
  final bool isClubPost;
  final bool isFlare;
  final String flarePoster;
  final String collectionID;
  final String flareID;
  const ShareWidget({
    required this.isInFeed,
    required this.bottomSheetController,
    required this.postID,
    required this.clubName,
    required this.isClubPost,
    required this.isFlare,
    required this.flarePoster,
    required this.collectionID,
    required this.flareID,
  });

  @override
  _ShareWidgetState createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  final TextEditingController _textController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  bool _clearable = false;
  bool loner = false;
  bool userSearchLoading = false;
  late Future getChatters;
  List<MiniProfile> userSearchResults = [];
  List<MiniProfile> existing = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _fullChats = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _fullLinked = [];
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
    final myFullChats =
        await firestore.collection('Users/$myUsername/chats').get();
    final myFullLinked =
        await firestore.collection('Users/$myUsername/Linked').get();
    final fullChatDocs = myFullChats.docs;
    final fullLinkedDocs = myFullLinked.docs;
    _fullChats = fullChatDocs;
    _fullLinked = fullLinkedDocs;
    final docs = myChats.docs;
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
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _bar = Container(
        color: _primarySwatch,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          IconButton(
              splashColor: Colors.transparent,
              tooltip: lang.loading_profile,
              icon: const Icon(customIcons.MyFlutterApp.curve_arrow),
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (widget.isInFeed && widget.bottomSheetController != null) {
                  widget.bottomSheetController!.close();
                  FeedScreen.shareSheetOpen = false;
                  PostsTab.shareSheetOpen = false;
                  LikedPostScreen.shareSheetOpen = false;
                  FavPostScreen.shareSheetOpen = false;
                } else {
                  Navigator.pop(context);
                }
              },
              color: Colors.white),
          const SizedBox(width: 5.0),
          Text(lang.widgets_share3,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 22.0))
        ]));
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
                          postID: widget.postID,
                          isClubPost: widget.isClubPost,
                          clubName: widget.clubName,
                          isSpotlight: widget.isFlare,
                          flarePoster: widget.flarePoster,
                          collectionID: widget.collectionID,
                          flareID: widget.flareID));
                })));
    final Widget _list = Expanded(
        child: Noglow(
            child: ListView.builder(
                itemCount: existing.length,
                itemBuilder: (ctx, index) {
                  final username = existing[index].username;
                  return Container(
                      key: ValueKey<String>(username),
                      child: ShareTile(
                          username: username,
                          postID: widget.postID,
                          isClubPost: widget.isClubPost,
                          clubName: widget.clubName,
                          isSpotlight: widget.isFlare,
                          flarePoster: widget.flarePoster,
                          collectionID: widget.collectionID,
                          flareID: widget.flareID));
                })));
    final Widget _clip = ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(30.0),
            topRight: const Radius.circular(30.0)),
        child: Container(
            color: Colors.white,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: _deviceHeight * 0.50,
                    maxHeight: _deviceHeight * 0.50),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _bar,
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
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
                              controller: _textController,
                              decoration: InputDecoration(
                                  suffixIcon: (_clearable)
                                      ? IconButton(
                                          tooltip: lang.clubs_assignAdmin5,
                                          splashColor: Colors.transparent,
                                          onPressed: () {
                                            setState(() {
                                              _textController.clear();
                                              if (_clearable)
                                                _clearable = false;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  hintText: lang.widgets_fullPost13,
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
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
                        Center(
                          child: Text(lang.clubs_assignAdmin7),
                        ),
                      if (!loner && !_clearable) _list,
                      if (loner && !_clearable)
                        Center(child: Text(lang.widgets_share4))
                    ]))));
    widget.bottomSheetController!.closed
        .then((value) => FeedScreen.shareSheetOpen = false);
    return Padding(
        padding: const EdgeInsets.only(top: 9.0, right: 9.0, left: 9.0),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(30.50),
                    topRight: const Radius.circular(30.50)),
                border: Border.all(width: 0.50)),
            child: FutureBuilder(
                future: getChatters,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: const Radius.circular(30.0),
                            topRight: const Radius.circular(30.0)),
                        child: Container(
                            color: Colors.white,
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: _deviceHeight * 0.50,
                                    maxHeight: _deviceHeight * 0.50),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      _bar,
                                      const Spacer(),
                                      const Center(
                                          child: const Icon(
                                              customIcons.MyFlutterApp.right,
                                              color: Colors.grey)),
                                      const Spacer()
                                    ]))));

                  if (snapshot.hasError)
                    return ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: const Radius.circular(30.0),
                            topRight: const Radius.circular(30.0)),
                        child: Container(
                            color: Colors.white,
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: _deviceHeight * 0.50,
                                    maxHeight: _deviceHeight * 0.50),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      _bar,
                                      const Spacer(),
                                      Center(
                                          child: Text(lang.clubs_adminScreen2)),
                                      const Spacer()
                                    ]))));

                  return _clip;
                })));
  }
}
