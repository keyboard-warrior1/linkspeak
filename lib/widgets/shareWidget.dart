import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import 'shareTile.dart';
import 'postsTab.dart';
import '../providers/myProfileProvider.dart';
import '../models/miniProfile.dart';
import '../screens/feedScreen.dart';
import '../screens/likedPostScreen.dart';
import '../screens/favoritePostsScreen.dart';

class ShareWidget extends StatefulWidget {
  final bool isInFeed;
  final PersistentBottomSheetController? bottomSheetController;
  final String postID;
  const ShareWidget({
    required this.isInFeed,
    required this.bottomSheetController,
    required this.postID,
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
  Future<void> getUserResults(String name, String myUsername) async {
    final myLinkedCollection =
        firestore.collection('Users').doc(myUsername).collection('Linked');
    final myChatsCollection =
        firestore.collection('Users').doc(myUsername).collection('chats');
    final getLinkedResult = await myLinkedCollection.doc(name).get();
    final getChatResult = await myChatsCollection.doc(name).get();
    final usersCollection = firestore.collection('Users');
    if (getLinkedResult.exists) {
      final getResults = usersCollection.where('Username', isEqualTo: name);
      final results = await getResults.get();
      final docs = results.docs;
      for (var result in docs) {
        final username = result.id;
        final image = result.get('Avatar');
        final MiniProfile mini = MiniProfile(username: username, imgUrl: image);
        if (!userSearchResults.any((result) => result.username == name))
          userSearchResults.add(mini);
      }
    }
    if (getChatResult.exists) {
      final getResults = usersCollection.where('Username', isEqualTo: name);
      final results = await getResults.get();
      final docs = results.docs;
      for (var result in docs) {
        final username = result.id;
        final image = result.get('Avatar');
        final MiniProfile mini = MiniProfile(username: username, imgUrl: image);
        if (!userSearchResults.any((result) => result.username == name))
          userSearchResults.add(mini);
      }
    }
    setState(() {});
  }

  Future<void> _getChatters(String myUsername) async {
    final myChats =
        await firestore.collection('Users/$myUsername/chats').limit(20).get();
    final docs = myChats.docs;
    if (docs.isNotEmpty) {
      for (var doc in docs) {
        final user = await firestore.collection('Users').doc(doc.id).get();
        if (user.exists) {
          final userIMG = user.get('Avatar');
          final mini = MiniProfile(username: doc.id, imgUrl: userIMG);
          existing.add(mini);
        } else {
          final mini = MiniProfile(username: doc.id, imgUrl: '');
          existing.add(mini);
        }
      }
    } else {
      final myLinked = await firestore
          .collection('Users/$myUsername/Linked')
          .limit(20)
          .get();
      final docs = myLinked.docs;
      if (docs.isNotEmpty) {
        for (var doc in docs) {
          final user = await firestore.collection('Users').doc(doc.id).get();
          if (user.exists) {
            final userIMG = user.get('Avatar');
            final mini = MiniProfile(username: doc.id, imgUrl: userIMG);
            existing.add(mini);
          } else {
            final mini = MiniProfile(username: doc.id, imgUrl: '');
            existing.add(mini);
          }
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
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final Color _primarySwatch = Theme.of(context).primaryColor;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _bar = Container(
      color: _primarySwatch,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            splashColor: Colors.transparent,
            tooltip: 'back',
            icon: const Icon(
              customIcons.MyFlutterApp.curve_arrow,
            ),
            onPressed: () {
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
            color: Colors.white,
          ),
          const SizedBox(
            width: 5.0,
          ),
          const Text(
            'Share',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 22.0),
          )
        ],
      ),
    );
    final Widget _resultList = Expanded(
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return false;
        },
        child: ListView.builder(
          itemCount: userSearchResults.length,
          itemBuilder: (ctx, index) {
            final username = userSearchResults[index].username;
            final img = userSearchResults[index].imgUrl;
            return ShareTile(username, img, widget.postID);
          },
        ),
      ),
    );
    final Widget _list = Expanded(
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return false;
        },
        child: ListView.builder(
          itemCount: existing.length,
          itemBuilder: (ctx, index) {
            final username = existing[index].username;
            final img = existing[index].imgUrl;
            return ShareTile(username, img, widget.postID);
          },
        ),
      ),
    );
    final Widget _clip = ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: const Radius.circular(
          30.0,
        ),
        topRight: const Radius.circular(
          30.0,
        ),
      ),
      child: Container(
        color: Colors.white,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: _deviceHeight * 0.50,
            maxHeight: _deviceHeight * 0.50,
          ),
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
                            tooltip: 'Clear',
                            splashColor: Colors.transparent,
                            onPressed: () {
                              setState(() {
                                _textController.clear();
                                if (_clearable) _clearable = false;
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (_clearable &&
                  userSearchResults.isNotEmpty &&
                  !userSearchLoading)
                _resultList,
              if (_clearable && userSearchResults.isEmpty && !userSearchLoading)
                const Center(
                  child: Text('Sorry, no results found.'),
                ),
              if (!loner && !_clearable) _list,
              if (loner && !_clearable)
                const Center(
                  child: Text('No ongoing chats found'),
                ),
            ],
          ),
        ),
      ),
    );
    widget.bottomSheetController!.closed
        .then((value) => FeedScreen.shareSheetOpen = false);
    return Padding(
      padding: const EdgeInsets.only(
        top: 9.0,
        right: 9.0,
        left: 9.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(
              30.50,
            ),
            topRight: const Radius.circular(
              30.50,
            ),
          ),
          border: Border.all(
            width: 0.50,
          ),
        ),
        child: FutureBuilder(
          future: getChatters,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(
                    30.0,
                  ),
                  topRight: const Radius.circular(
                    30.0,
                  ),
                ),
                child: Container(
                  color: Colors.white,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: _deviceHeight * 0.50,
                      maxHeight: _deviceHeight * 0.50,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _bar,
                        const Spacer(),
                        const Center(
                          child: const CircularProgressIndicator(),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              print(snapshot.error);
              return ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(
                    30.0,
                  ),
                  topRight: const Radius.circular(
                    30.0,
                  ),
                ),
                child: Container(
                  color: Colors.white,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: _deviceHeight * 0.50,
                      maxHeight: _deviceHeight * 0.50,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _bar,
                        const Spacer(),
                        const Center(
                          child: Text('An unknown error has occured'),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            }
            return _clip;
          },
        ),
      ),
    );
  }
}
