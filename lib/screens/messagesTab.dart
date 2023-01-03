import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../general.dart';
import '../models/miniProfile.dart';
import '../models/screenArguments.dart';
import '../providers/themeModel.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/chatProfileImage.dart';
import '../widgets/common/load.dart';
import '../widgets/common/noglow.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab();

  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _searchNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  List<DocumentSnapshot> products = [];
  bool hasChats = false;
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 15;
  DocumentSnapshot? firstDocument;
  DocumentSnapshot? lastDocument;
  BehaviorSubject<List<DocumentSnapshot>> _controller =
      BehaviorSubject<List<DocumentSnapshot>>();
  Stream<List<DocumentSnapshot>> get _streamController => _controller.stream;
  bool _clearable = false;
  bool userSearchLoading = false;
  List<MiniProfile> userSearchResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> fullChats = [];
  Future<void> getFullChats(String myUsername) async {
    final getChats = await firestore
        .collection('Users')
        .doc(myUsername)
        .collection('chats')
        .get();
    final docs = getChats.docs;
    fullChats = docs;
  }

  Future<void> getProducts(String _myUsername) async {
    if (!hasMore) {
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await firestore
          .collection('Users/$_myUsername/chats')
          .orderBy('lastMessageTime', descending: true)
          .limit(documentLimit)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        firstDocument = querySnapshot.docs[0];
        querySnapshot.docs.forEach((element) {
          if (!products.any((element2) => element2.id == element.id))
            products.add(element);
        });
      }
    } else {
      querySnapshot = await firestore
          .collection('Users/$_myUsername/chats')
          .orderBy('lastMessageTime', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        products.addAll(querySnapshot.docs);
      }
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      _controller.sink.add(products);
    }
    setState(() {
      isLoading = false;
    });
  }

  void onChangeData(List<DocumentChange> documentChanges) {
    documentChanges.forEach((productChange) {
      if (productChange.type == DocumentChangeType.removed) {
        products.removeWhere((product) {
          return productChange.doc.id == product.id;
        });
      } else {
        if (productChange.type == DocumentChangeType.modified) {
          int indexWhere = products.indexWhere((product) {
            return productChange.doc.id == product.id;
          });

          if (indexWhere >= 0) {
            products[indexWhere] = productChange.doc;
          }
        }
      }
    });
    setState(() {});
  }

  String dateConverter(dynamic date, String locale) {
    DateTime myDate = (date).toDate();
    final f = DateFormat('yyyy-MM-dd HH:mm', locale);
    f.format(myDate);
    if (myDate.minute == 0) {
      return "${myDate.hour}:00";
    } else {}
    if (myDate.minute - 10 < 0) {
      return "${myDate.hour}:0${myDate.minute}";
    }
    return "${myDate.hour}:${myDate.minute}";
  }

  // Future<String> getProfileImage(String userName) async {
  //   final profileDocument = await firestore.doc('Users/$userName').get();
  //   String _avatarString = profileDocument.get('Avatar');
  //   return _avatarString;
  // }

  void getUserResults(String name, String myUsername) {
    final lowerCaseName = name.toLowerCase();
    fullChats.forEach((doc) {
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
    setState(() {});
  }

  void _showIt() {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (_) {
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: const Load());
        });
  }

  _showFirst(String id) {
    final lang = General.language(context);
    showDialog(
        context: context,
        builder: (_) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSecond(id);
                    },
                    child: Text(
                      lang.screens_messagesTab1,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  _showSecond(String id) {
    final lang = General.language(context);
    showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 150.0,
              maxWidth: 150.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    lang.screens_messagesTab2,
                    softWrap: false,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                      fontFamily: 'Roboto',
                      fontSize: 19.0,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(thickness: 1.0, indent: 0.0, endIndent: 0.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        style:
                            ButtonStyle(splashFactory: NoSplash.splashFactory),
                        onPressed: () async {
                          final _myUsername =
                              Provider.of<MyProfile>(context, listen: false)
                                  .getUsername;
                          Navigator.pop(context);
                          _showIt();
                          final myMsgsCollec = await firestore
                              .collection('Users/$_myUsername/chats')
                              .doc(id)
                              .collection('messages')
                              .get();
                          final docs = myMsgsCollec.docs;
                          final getDeleted = await firestore
                              .collection('Deleted Chats')
                              .doc('$_myUsername - $id')
                              .get();
                          firestore
                              .collection('Deleted Chats')
                              .doc('$_myUsername - $id')
                              .set(
                                  {'date deleted': DateTime.now()},
                                  SetOptions(
                                      merge: (getDeleted.exists)
                                          ? true
                                          : false)).then((value) {
                            for (var theid in docs) {
                              final docID = theid.id;
                              final date = theid.get('date').toDate();
                              final description = theid.get('description');
                              final isRead = theid.get('isRead');
                              final isDeleted = theid.get('isDeleted');
                              final isPost = theid.get('isPost');
                              final isMedia = theid.get('isMedia');
                              final sender = theid.get('user');
                              final token = theid.get('token');
                              final isClubPost = theid.get('isClubPost');
                              final postID = theid.get('postID');
                              final isAudio = theid.get('isAudio');
                              final isSpotlight = theid.get('isSpotlight');
                              final mediaURL = theid.get('mediaURL');
                              final audioURL = theid.get('audioURL');
                              final spotlightID = theid.get('spotlightID');
                              final isLocation = theid.get('isLocation');
                              final locationName = theid.get('locationName');
                              final location = theid.get('location');
                              final poster = theid.get('poster');
                              final collection = theid.get('collection');
                              firestore
                                  .collection('Deleted Chats')
                                  .doc('$_myUsername - $id')
                                  .collection('messages')
                                  .add({
                                'date': date,
                                'description': description,
                                'isRead': isRead,
                                'isDeleted': isDeleted,
                                'isPost': isPost,
                                'isMedia': isMedia,
                                'user': sender,
                                'token': token,
                                'isClubPost': isClubPost,
                                'postID': postID,
                                'isAudio': isAudio,
                                'isSpotlight': isSpotlight,
                                'mediaURL': mediaURL,
                                'audioURL': audioURL,
                                'spotlightID': spotlightID,
                                'poster': poster,
                                'collection': collection,
                                'isLocation': isLocation,
                                'locationName': locationName,
                                'location': location,
                              });
                              firestore
                                  .collection('Users/$_myUsername/chats')
                                  .doc(id)
                                  .collection('messages')
                                  .doc(docID)
                                  .delete();
                            }
                            firestore
                                .collection('Users/$_myUsername/chats')
                                .doc(id)
                                .delete()
                                .then((value) => Navigator.pop(context));
                          });
                        },
                        child: Text(
                          lang.clubs_alerts3,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      TextButton(
                        style:
                            ButtonStyle(splashFactory: NoSplash.splashFactory),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          lang.clubs_alerts4,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    getFullChats(_myUsername);
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
    firestore.collection('Users/$_myUsername/chats').get().then((value) {
      if (value.docs.isNotEmpty) {
        hasChats = true;
        getProducts(_myUsername);
      }
    });
    firestore
        .collection('Users/$_myUsername/chats')
        .snapshots()
        .listen((event) {
      onChangeData(event.docChanges);
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (!hasMore) {
        } else {
          if (!isLoading) {
            getProducts(_myUsername);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _searchNode.dispose();
    _textController.dispose();
    scrollController.removeListener(() {});
    scrollController.dispose();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final langCode =
        Provider.of<ThemeModel>(context, listen: false).serverLangCode;
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final Widget _resultList = Expanded(
      child: Noglow(
        child: ListView.builder(
          itemCount: userSearchResults.length,
          itemBuilder: (ctx, index) {
            final current = userSearchResults[index];
            final username = current.username;
            return StreamBuilder<Object>(
                stream: firestore
                    .collection('Users/$_myUsername/chats')
                    .doc(username)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.hasError) {
                    return Container();
                  } else {
                    final info = snapshot.data!
                        as DocumentSnapshot<Map<String, dynamic>>;
                    if (info.exists) {
                      final displayMessage = info['displayMessage'];
                      String displayName = info.id;
                      if (info.id.length > 15) {
                        displayName = '${info.id.substring(0, 15)}..';
                      }
                      return InkWell(
                        splashColor: Colors.black45,
                        onLongPress: () {
                          _showFirst(info.id);
                        },
                        onTap: () {
                          final ChatScreenArgs args = ChatScreenArgs(
                            chatID: username,
                            comeFromProfile: false,
                          );
                          Navigator.pushNamed(
                              context, RouteGenerator.chatScreen,
                              arguments: args);
                        },
                        child: ListTile(
                          leading: ChatProfileImage(
                              username: username,
                              factor: 0.060,
                              inEdit: false,
                              asset: null,
                              editUrl: ''),
                          title: Row(
                            children: [
                              Text(
                                "$displayName",
                                style: TextStyle(
                                    fontWeight: info['isRead'] as bool
                                        ? FontWeight.w400
                                        : FontWeight.bold),
                              ),
                              SizedBox(width: 5),
                              info['isRead'] as bool
                                  ? Container()
                                  : Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green),
                                    )
                            ],
                          ),
                          subtitle: Text(
                            (displayMessage.length > 150)
                                ? displayMessage.substring(0, 130)
                                : displayMessage,
                            style: TextStyle(
                                fontWeight: info['isRead'] as bool
                                    ? FontWeight.w400
                                    : FontWeight.bold),
                          ),
                          trailing: Text(
                            "${dateConverter(info['lastMessageTime'], langCode)}",
                            style: TextStyle(
                                fontWeight: info['isRead'] as bool
                                    ? FontWeight.w400
                                    : FontWeight.bold),
                          ),
                        ),
                      );
                    }
                    return Container();
                  }
                });
          },
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: _deviceHeight * 0.05, bottom: 85.0),
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                top: 10.0,
                bottom: 10.0,
              ),
              padding: const EdgeInsets.only(
                top: 5.0,
                left: 15.0,
                right: 15.0,
              ),
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  if (text.isEmpty) {
                    if (userSearchResults.isNotEmpty) userSearchResults.clear();
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
                focusNode: _searchNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  hintText: lang.screens_messagesTab3,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: (_clearable)
                      ? IconButton(
                          tooltip: lang.clubs_banMember4,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              _textController.clear();
                              _clearable = false;
                            });
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (_clearable && userSearchResults.isEmpty && !userSearchLoading)
              const Spacer(),
            if (_clearable &&
                userSearchResults.isNotEmpty &&
                !userSearchLoading)
              _resultList,
            if (_clearable && userSearchResults.isEmpty && !userSearchLoading)
              Center(child: Text(lang.clubs_banMember7)),
            if (_clearable && userSearchResults.isEmpty && !userSearchLoading)
              const Spacer(),
            if (!_clearable)
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot<Object?>>>(
                  stream: (hasChats) ? _streamController : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child:
                            const CircularProgressIndicator(strokeWidth: 1.50),
                      );
                    } else if (snapshot.hasData && hasChats) {
                      if (snapshot.data!.length >= 1) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: ListView.separated(
                            controller: scrollController,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final info = snapshot.data![index];
                              final displayMessage = info['displayMessage'];
                              String displayName = info.id;
                              if (info.id.length > 15) {
                                displayName = '${info.id.substring(0, 15)}..';
                              }
                              return InkWell(
                                key: UniqueKey(),
                                splashColor: Colors.black45,
                                onLongPress: () {
                                  _showFirst(info.id);
                                },
                                onTap: () {
                                  final ChatScreenArgs args = ChatScreenArgs(
                                      chatID: info.id, comeFromProfile: false);
                                  Navigator.pushNamed(
                                      context, RouteGenerator.chatScreen,
                                      arguments: args);
                                },
                                child: ListTile(
                                  key: UniqueKey(),
                                  leading: ChatProfileImage(
                                      username: info.id,
                                      factor: 0.060,
                                      inEdit: false,
                                      asset: null,
                                      editUrl: ''),
                                  title: Row(
                                    children: [
                                      Text(
                                        "$displayName",
                                        style: TextStyle(
                                            fontWeight: info['isRead'] as bool
                                                ? FontWeight.w400
                                                : FontWeight.bold),
                                      ),
                                      SizedBox(width: 5),
                                      info['isRead'] as bool
                                          ? Container()
                                          : Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.green),
                                            )
                                    ],
                                  ),
                                  subtitle: Text(
                                    (displayMessage.length > 150)
                                        ? displayMessage.substring(0, 130)
                                        : displayMessage,
                                    style: TextStyle(
                                        fontWeight: info['isRead'] as bool
                                            ? FontWeight.w400
                                            : FontWeight.bold),
                                  ),
                                  trailing: Text(
                                    "${dateConverter(info['lastMessageTime'], langCode)}",
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontWeight: info['isRead'] as bool
                                            ? FontWeight.w400
                                            : FontWeight.bold),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else if (!hasChats) {
                        return Stack(
                          children: [
                            Align(
                              alignment: const Alignment(0, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: const Icon(
                                      Icons.mail_outline_rounded,
                                      color: Colors.grey,
                                      size: 57.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 21.0,
                                  ),
                                  Text(
                                    lang.screens_messagesTab4,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 31.0,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Stack(
                          children: [
                            Align(
                              alignment: const Alignment(0, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: const Icon(
                                      Icons.mail_outline_rounded,
                                      color: Colors.grey,
                                      size: 57.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 21.0,
                                  ),
                                  Text(
                                    lang.screens_messagesTab4,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 31.0,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    } else {
                      return Stack(
                        children: [
                          Align(
                            alignment: const Alignment(0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                const Center(
                                  child: const Icon(
                                    Icons.mail_outline_rounded,
                                    color: Colors.grey,
                                    size: 57.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
