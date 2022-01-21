import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../models/screenArguments.dart';
import '../models/miniProfile.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/chatProfileImage.dart';
import '../widgets/load.dart';
import '../routes.dart';

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

  String dateConverter(dynamic date) {
    DateTime myDate = (date).toDate();
    final f = DateFormat('yyyy-MM-dd HH:mm');
    f.format(myDate);
    if (myDate.minute == 0) {
      return "${myDate.hour}:00";
    } else {}
    if (myDate.minute - 10 < 0) {
      return "${myDate.hour}:0${myDate.minute}";
    }
    return "${myDate.hour}:${myDate.minute}";
  }

  Future<String> getProfileImage(String userName) async {
    final profileDocument = await firestore.doc('Users/$userName').get();
    String _avatarString = profileDocument.get('Avatar');
    return _avatarString;
  }

  Future<void> getUserResults(String name, String myUsername) async {
    final myChatsCollection =
        firestore.collection('Users').doc(myUsername).collection('chats');
    final getChatResult = await myChatsCollection.doc(name).get();
    final usersCollection = firestore.collection('Users');
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

  @override
  void initState() {
    super.initState();
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
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
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final double _deviceHeight = MediaQuery.of(context).size.height;
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

    _showSecond(String id) {
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
                    const Text(
                      'Are you sure?',
                      softWrap: false,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        fontFamily: 'Roboto',
                        fontSize: 19.0,
                        color: Colors.black,
                      ),
                    ),
                    const Divider(
                      thickness: 1.0,
                      indent: 0.0,
                      endIndent: 0.0,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TextButton(
                          style: ButtonStyle(
                              splashFactory: NoSplash.splashFactory),
                          onPressed: () async {
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
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              splashFactory: NoSplash.splashFactory),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'No',
                            style: TextStyle(
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

    _showFirst(String id) {
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
                      child: const Text(
                        'Delete chat',
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

    final Widget _resultList = Expanded(
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return false;
        },
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
                              asset: null),
                          title: Row(
                            children: [
                              Text(
                                "${info.id}",
                                style: TextStyle(
                                    fontFamily: "Poppins",
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
                            "${dateConverter(info['lastMessageTime'])}",
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
      padding: EdgeInsets.only(top: _deviceHeight * 0.05, bottom: 50.0),
      child: Container(
        color: Colors.white12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Color(0xfffafafa),
              height: _deviceHeight * 0.059,
              width: double.infinity,
              margin: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
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
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  hintText: "Search",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
              const Center(
                child: Text('Sorry, no results found.'),
              ),
            if (_clearable && userSearchResults.isEmpty && !userSearchLoading)
              const Spacer(),
            if (!_clearable)
              Expanded(
                  child: StreamBuilder<List<DocumentSnapshot<Object?>>>(
                stream: (hasChats) ? _streamController : null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: const CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData && hasChats) {
                    if (snapshot.data!.length >= 1) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: ListView.separated(
                          controller: scrollController,
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final info = snapshot.data![index];
                            final displayMessage = info['displayMessage'];
                            return InkWell(
                              key: UniqueKey(),
                              splashColor: Colors.black45,
                              onLongPress: () {
                                _showFirst(info.id);
                              },
                              onTap: () {
                                final ChatScreenArgs args = ChatScreenArgs(
                                  chatID: info.id,
                                  comeFromProfile: false,
                                );
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
                                    asset: null),
                                title: Row(
                                  children: [
                                    Text(
                                      "${info.id}",
                                      style: TextStyle(
                                          fontFamily: "Poppins",
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
                                  "${dateConverter(info['lastMessageTime'])}",
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
                            alignment: Alignment(0, 0),
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
                                const Text(
                                  'Chats are empty',
                                  style: TextStyle(
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
                            alignment: Alignment(0, 0),
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
                                const Text(
                                  'Chats are empty',
                                  style: TextStyle(
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
                    return Container();
                  }
                },
              )),
          ],
        ),
      ),
    );
  }
}
