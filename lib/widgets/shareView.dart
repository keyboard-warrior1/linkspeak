import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/myProfileProvider.dart';
import '../providers/fullPostHelper.dart';
import '../models/miniProfile.dart';
import 'shareTile.dart';

class ShareView extends StatefulWidget {
  const ShareView();

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
  bool _clearable = false;
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
    final double deviceHeight = MediaQuery.of(context).size.height;
    final String postID =
        Provider.of<FullHelper>(context, listen: false).postId;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
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
            return ShareTile(username, img, postID);
          },
        ),
      ),
    );
    return Container(
      height: deviceHeight * 0.35,
      child: FutureBuilder(
        future: getChatters,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                const Center(
                  child: const CircularProgressIndicator(),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Center(
                  child: Text('An unknown error has occured'),
                ),
              ],
            );
          }
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
                            tooltip: 'Clear',
                            splashColor: Colors.transparent,
                            onPressed: () {
                              setState(() {
                                _textController.clear();
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
              if (!loner && !_clearable)
                Expanded(
                  child: ListView.builder(
                    itemCount: existing.length,
                    itemBuilder: (ctx, index) {
                      final username = existing[index].username;
                      final img = existing[index].imgUrl;
                      return ShareTile(username, img, postID);
                    },
                  ),
                ),
              if (loner && !_clearable)
                const Center(
                  child: Text('No ongoing chats found'),
                ),
            ],
          );
        },
      ),
    );
  }
}
