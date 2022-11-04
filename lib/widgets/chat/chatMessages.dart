import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/myProfileProvider.dart';
import '../common/load.dart';
import 'chatAudioPlayer.dart';
import 'chatFlareWidget.dart';
import 'chatLocationWidget.dart';
import 'chatMediaWidget.dart';
import 'miniClubPost.dart';
import 'miniPost.dart';

class ChatMessages extends StatefulWidget {
  final String chatId;
  final ScrollController scrollController;
  const ChatMessages(this.chatId, this.scrollController);

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> products = [];
  bool exists = false;
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 30;
  DocumentSnapshot? firstDocument;
  DocumentSnapshot? lastDocument;
  StreamController<List<DocumentSnapshot>> _controller =
      StreamController<List<DocumentSnapshot>>();
  Stream<List<DocumentSnapshot>> get _streamController => _controller.stream;
  bool isTyping = false;
  bool isRecording = false;
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
          .collection('Users/$_myUsername/chats/${widget.chatId}/messages')
          .orderBy('date', descending: true)
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
          .collection('Users/$_myUsername/chats/${widget.chatId}/messages')
          .orderBy('date', descending: true)
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

  @override
  void initState() {
    super.initState();
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    firestore
        .collection('Users/$_myUsername/chats')
        .doc('${widget.chatId}')
        .get()
        .then((value) {
      if (value.exists) {
        exists = true;
        getProducts(_myUsername).then((value) {
          if (firstDocument != null) {
            firestore
                .collection(
                    'Users/$_myUsername/chats/${widget.chatId}/messages')
                .orderBy('date', descending: true)
                .endBeforeDocument(firstDocument!)
                .snapshots()
                .listen((event) {
              if (event.docs.isNotEmpty) {
                if (!products.any((element) => element.id == event.docs[0].id))
                  products.insert(0, event.docs[0]);
                setState(() {});
              }
            });
          }
        });
        firestore
            .collection('Users/$_myUsername/chats/${widget.chatId}/messages')
            .orderBy('date', descending: true)
            .snapshots()
            .listen((event) {
          onChangeData(event.docChanges);
        });
        firestore
            .collection('Users/$_myUsername/chats')
            .doc('${widget.chatId}')
            .snapshots()
            .listen((event) {
          if (event.exists) {
            var info = event.data();
            var typing = info!['isTyping'];
            var recording = info['isRecording'];
            if (typing == true) {
              if (!isTyping) {
                isTyping = true;
                if (isRecording) isRecording = false;
                setState(() {});
              }
            } else {
              if (isTyping) {
                isTyping = false;
                setState(() {});
              }
            }
            if (recording == true) {
              if (!isRecording) {
                isRecording = true;
                if (isTyping) isTyping = false;
                setState(() {});
              }
            } else {
              if (isRecording) {
                isRecording = false;
                setState(() {});
              }
            }
          }
        });
        readUnread(_myUsername).then((value) => setState(() {}));
        widget.scrollController.addListener(() {
          if (widget.scrollController.position.pixels ==
              widget.scrollController.position.maxScrollExtent) {
            if (!hasMore) {
            } else {
              if (!isLoading) {
                getProducts(_myUsername);
              }
            }
          }
        });
      } else {
        firestore
            .collection('Users/$_myUsername/chats/${widget.chatId}/messages')
            .limit(1)
            .snapshots()
            .listen((event) {
          if (event.docs.isNotEmpty && firstDocument == null && !exists) {
            exists = true;
            firstDocument = event.docs[0];
            if (!products.any((element) => element.id == event.docs[0].id))
              products.insert(0, event.docs[0]);
            setState(() {});
            firestore
                .collection('Users/$_myUsername/chats')
                .doc('${widget.chatId}')
                .get()
                .then((value) {
              if (value.exists) {
                exists = true;
                getProducts(_myUsername).then((value) {
                  if (firstDocument != null) {
                    firestore
                        .collection(
                            'Users/$_myUsername/chats/${widget.chatId}/messages')
                        .orderBy('date', descending: true)
                        .endBeforeDocument(firstDocument!)
                        .snapshots()
                        .listen((event) {
                      if (event.docs.isNotEmpty) {
                        if (!products
                            .any((element) => element.id == event.docs[0].id))
                          products.insert(0, event.docs[0]);
                        setState(() {});
                      }
                    });
                  }
                });
              }
            });
          }
        });
        firestore
            .collection('Users/$_myUsername/chats/${widget.chatId}/messages')
            .orderBy('date', descending: true)
            .snapshots()
            .listen((event) {
          onChangeData(event.docChanges);
        });
        firestore
            .collection('Users/$_myUsername/chats')
            .doc('${widget.chatId}')
            .snapshots()
            .listen((event) {
          if (event.exists) {
            var info = event.data();
            var typing = info!['isTyping'];
            var recording = info['isRecording'];
            if (typing == true) {
              if (!isTyping) {
                isTyping = true;
                if (isRecording) isRecording = false;
                setState(() {});
              }
            } else {
              if (isTyping) {
                isTyping = false;
                setState(() {});
              }
            }
            if (recording == true) {
              if (!isRecording) {
                isRecording = true;
                if (isTyping) isTyping = false;
                setState(() {});
              }
            } else {
              if (isRecording) {
                isRecording = false;
                setState(() {});
              }
            }
          }
        });
      }
    });
  }

  Future<void> readUnreadMessages(String _myUsername) async {
    var unread = [];
    var unread2 = [];
    final theMessages = firestore
        .collection('Users/$_myUsername/chats/${widget.chatId}/messages');
    final theMessages2 = firestore
        .collection('Users/${widget.chatId}/chats/$_myUsername/messages');
    var unreadMessages = await theMessages
        .where('isRead', isEqualTo: false)
        .where('user', isNotEqualTo: _myUsername)
        .get();
    var unreadMessages2 = await theMessages2
        .where('isRead', isEqualTo: false)
        .where('user', isNotEqualTo: _myUsername)
        .get();
    var docs = unreadMessages.docs;
    var docs2 = unreadMessages2.docs;
    if (docs.isNotEmpty) {
      for (var message in docs) {
        unread.insert(0, message.id);
      }
      for (var message in unread) {
        firestore
            .collection('Users/$_myUsername/chats/${widget.chatId}/messages')
            .doc(message)
            .update({'isRead': true});
      }
    }
    if (docs2.isNotEmpty) {
      for (var message in docs2) {
        unread2.insert(0, message.id);
      }
      for (var message in unread2) {
        firestore
            .collection('Users/${widget.chatId}/chats/$_myUsername/messages')
            .doc(message)
            .update({'isRead': true});
      }
    }
  }

  Future<void> readUnread(String _myUsername) async {
    var unread = [];
    var unread2 = [];
    final theMessages = firestore
        .collection('Users/$_myUsername/chats/${widget.chatId}/messages');
    final theMessages2 = firestore
        .collection('Users/${widget.chatId}/chats/$_myUsername/messages');
    firestore
        .collection('Users/$_myUsername/chats')
        .doc('${widget.chatId}')
        .update({'isRead': true});
    var unreadMessages = await theMessages
        .where('isRead', isEqualTo: false)
        .where('user', isNotEqualTo: _myUsername)
        .get();
    var unreadMessages2 = await theMessages2
        .where('isRead', isEqualTo: false)
        .where('user', isNotEqualTo: _myUsername)
        .get();
    var docs = unreadMessages.docs;
    var docs2 = unreadMessages2.docs;
    if (docs.isNotEmpty) {
      for (var message in docs) {
        unread.insert(0, message.id);
      }
      for (var message in unread) {
        firestore
            .collection('Users/$_myUsername/chats/${widget.chatId}/messages')
            .doc(message)
            .update({'isRead': true});
      }
    }
    if (docs2.isNotEmpty) {
      for (var message in docs2) {
        unread2.insert(0, message.id);
      }
      for (var message in unread2) {
        firestore
            .collection('Users/${widget.chatId}/chats/$_myUsername/messages')
            .doc(message)
            .update({'isRead': true});
      }
    }
  }

  String _dateConverter(dynamic date) {
    DateTime myDate = date.toDate();
    final Duration _difference = DateTime.now().difference(myDate);
    final bool _withinYear = _difference <=
        const Duration(days: 364, minutes: 59, seconds: 59, milliseconds: 999);
    final month = DateFormat('MMMM dd');
    final year = DateFormat('MMMM dd yyyy');
    if (_withinYear) {
      return month.format(myDate);
    } else {
      return year.format(myDate);
    }
  }

  String dateConverter(dynamic date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    DateTime myDate = date.toDate();
    final f = DateFormat('yyyy-MM-dd HH:mm');
    f.format(myDate);
    final hour = twoDigits(myDate.hour);
    final minute = twoDigits(myDate.minute);
    final displayTime = "$hour:$minute";
    return displayTime;
  }

  Widget buildSeperator(dynamic theDate, Color _primaryColor) => Container(
      margin: const EdgeInsets.all(8.0),
      color: Colors.transparent,
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.70),
                    borderRadius: BorderRadius.circular(5.0)),
                child: Container(
                    margin: const EdgeInsets.all(6.75),
                    child: Text("${_dateConverter(theDate)}",
                        style: const TextStyle(color: Colors.white))))
          ]));

  Widget buildAlignedIcon(
          bool isTyping, bool isRecording, Color _primaryColor) =>
      Align(
          alignment: Alignment.bottomLeft,
          child: AnimatedContainer(
              margin: const EdgeInsets.all(8.0),
              height: (isTyping || isRecording) ? 30.0 : 0,
              width: (isTyping || isRecording) ? 30.0 : 0,
              curve: Curves.fastLinearToSlowEaseIn,
              duration: kThemeAnimationDuration,
              child: Icon(isTyping ? customIcons.MyFlutterApp.chat : Icons.mic,
                  color: _primaryColor, size: 37.0)));

  _showSecond(
          {required String myUsername,
          required String id,
          required void Function() showIt}) =>
      showDialog(
          context: context,
          builder: (_) => Center(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 150.0, maxWidth: 150.0),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text('Delete message',
                                softWrap: false,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                    fontFamily: 'Roboto',
                                    fontSize: 19.0,
                                    color: Colors.black)),
                            const Divider(
                                thickness: 1.0, indent: 0.0, endIndent: 0.0),
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        showIt();
                                        var batch = firestore.batch();
                                        final getChat = await firestore
                                            .collection('Users')
                                            .doc(myUsername)
                                            .collection('chats')
                                            .doc('${widget.chatId}')
                                            .get();
                                        final theirChat = await firestore
                                            .collection('Users')
                                            .doc('${widget.chatId}')
                                            .collection('chats')
                                            .doc(myUsername)
                                            .get();

                                        final mycurrentDisplay =
                                            getChat.get('displayMessage');
                                        final myDisplayTime =
                                            getChat.get('lastMessageTime');
                                        final theirCurrentDisplay =
                                            theirChat.get('displayMessage');
                                        final theirDisplayTime =
                                            theirChat.get('lastMessageTime');
                                        final getMessage = await firestore
                                            .collection('Users')
                                            .doc(myUsername)
                                            .collection('chats')
                                            .doc('${widget.chatId}')
                                            .collection('messages')
                                            .doc(id)
                                            .get();
                                        final msgDescription =
                                            getMessage.get('description');
                                        final msgTime = getMessage.get('date');
                                        final theirVersion = await firestore
                                            .collection('Users')
                                            .doc('${widget.chatId}')
                                            .collection('chats')
                                            .doc(myUsername)
                                            .collection('messages')
                                            .where('description',
                                                isEqualTo: msgDescription)
                                            .where('date', isEqualTo: msgTime)
                                            .get();
                                        List<String> versionIDS = [];
                                        final theirdocs = theirVersion.docs;
                                        for (var doc in theirdocs) {
                                          versionIDS.add(doc.id);
                                        }
                                        if (mounted) {
                                          setState(() {});
                                        }
                                        if (msgDescription ==
                                                mycurrentDisplay &&
                                            msgTime == myDisplayTime) {
                                          batch.update(
                                              firestore
                                                  .collection('Users')
                                                  .doc(myUsername)
                                                  .collection('chats')
                                                  .doc('${widget.chatId}'),
                                              {
                                                'displayMessage':
                                                    'This message has been deleted'
                                              });
                                        }

                                        if (msgDescription ==
                                                theirCurrentDisplay &&
                                            msgTime == theirDisplayTime) {
                                          batch.update(
                                              firestore
                                                  .collection('Users')
                                                  .doc('${widget.chatId}')
                                                  .collection('chats')
                                                  .doc(myUsername),
                                              {
                                                'displayMessage':
                                                    'This message has been deleted'
                                              });
                                        }
                                        batch.update(
                                            firestore
                                                .collection('Users')
                                                .doc(myUsername)
                                                .collection('chats')
                                                .doc('${widget.chatId}')
                                                .collection('messages')
                                                .doc(id),
                                            {'isDeleted': true});
                                        batch.update(
                                            firestore
                                                .collection('Users')
                                                .doc('${widget.chatId}')
                                                .collection('chats')
                                                .doc(myUsername)
                                                .collection('messages')
                                                .doc(versionIDS[0]),
                                            {'isDeleted': true});
                                        batch.commit().then(
                                            (value) => Navigator.pop(context));
                                      },
                                      child: const Text('Yes',
                                          style: TextStyle(color: Colors.red))),
                                  TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('No',
                                          style: TextStyle(color: Colors.red)))
                                ])
                          ])))));

  void _showIt() {
    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        builder: (_) {
          return const Load();
        });
  }

  _showFirst(
          {required String id,
          required String myUsername,
          required String description,
          required bool isText,
          required bool isMyMessage}) =>
      showDialog(
          context: context,
          builder: (_) {
            return Center(
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          if (isText)
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Clipboard.setData(
                                      ClipboardData(text: '$description'));
                                },
                                child: const Text('Copy',
                                    style:
                                        const TextStyle(color: Colors.black))),
                          if (isMyMessage)
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showSecond(
                                      myUsername: myUsername,
                                      id: id,
                                      showIt: _showIt);
                                },
                                child: const Text('Delete message',
                                    style:
                                        const TextStyle(color: Colors.black)))
                        ])));
          });

  @override
  void dispose() {
    super.dispose();
    _controller.close();
    widget.scrollController.removeListener(() {});
  }

  Widget giveMini(
      String description, Widget dateWidget, bool isMySide, bool isClubPost) {
    if (isClubPost)
      return MiniClubPost(
          postID: description, dateWidget: dateWidget, isMySide: isMySide);
    else
      return MiniPost(
          postID: description, dateWidget: dateWidget, isMySide: isMySide);
  }

  @override
  Widget build(BuildContext context) {
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final screenWidth = General.widthQuery(context);
    final screenHeigth = MediaQuery.of(context).size.height;
    return Expanded(
      child: StreamBuilder<List<DocumentSnapshot<Object?>>>(
        stream: exists ? _streamController : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: const SizedBox());
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: GroupedListView<dynamic, String>(
                    padding: (isTyping || isRecording)
                        ? const EdgeInsets.only(bottom: 31.0)
                        : const EdgeInsets.all(0.0),
                    controller: widget.scrollController,
                    reverse: true,
                    elements: exists ? snapshot.data!.reversed.toList() : [],
                    groupBy: (element) {
                      final stamp = element.get('date').toDate();
                      final DateFormat myformat = DateFormat('MMMM dd yyyy');
                      return myformat.format(stamp);
                    },
                    groupHeaderBuilder: (groupByValue) {
                      final dynamic theDate = groupByValue.get('date');
                      return buildSeperator(theDate, _primaryColor);
                    },
                    useStickyGroupSeparators: true,
                    floatingHeader: true,
                    order: GroupedListOrder.DESC,
                    indexedItemBuilder: (BuildContext context, _, int index) {
                      final doc = snapshot.data!;
                      final current = doc.elementAt(index);
                      final messageID = current.id;
                      final date = current.get('date');
                      final sender = current.get('user');
                      final isMedia = current.get('isMedia');
                      final mediaURLs = current.get('mediaURL');
                      final isAudio = current.get('isAudio');
                      final audioURL = current.get('audioURL');
                      final isSpotlight = current.get('isSpotlight');
                      final poster = current.get('poster');
                      final collection = current.get('collection');
                      final spotlightID = current.get('spotlightID');
                      final isLocation = current.get('isLocation');
                      final locationName = current.get('locationName');
                      final location = current.get('location');
                      final isPost = current.get('isPost');
                      final isClubPost = current.get('isClubPost');
                      final postID = current.get('postID');
                      final isDeleted = current.get('isDeleted');
                      final isRead = current.get('isRead');
                      final description = current.get('description');
                      final isText = isPost == false &&
                          isDeleted == false &&
                          isMedia == false &&
                          isAudio == false &&
                          isLocation == false &&
                          isSpotlight == false;
                      if (sender == "$_myUsername") {
                        return Align(
                          key: ValueKey<String>(messageID),
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: screenWidth * 0.01,
                              maxWidth: (isPost == false ||
                                      isDeleted == true ||
                                      isAudio == true)
                                  ? screenWidth * 0.6
                                  : screenWidth,
                              minHeight: screenHeigth * 0.01,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: EdgeInsets.only(
                                  right: isText ? 5 : 0, bottom: 10),
                              decoration: BoxDecoration(
                                  color: (isPost == true ||
                                          isAudio == true ||
                                          isMedia == true ||
                                          isSpotlight == true ||
                                          isLocation == true)
                                      ? Colors.transparent
                                      : isRead && isDeleted == false
                                          ? Colors.green
                                          : isDeleted == true
                                              ? _primaryColor
                                              : _primaryColor,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20))),
                              child: InkWell(
                                onLongPress: isDeleted == true
                                    ? () {}
                                    : () => _showFirst(
                                        id: messageID,
                                        myUsername: _myUsername,
                                        description:
                                            (isText) ? "$description" : '',
                                        isText: isText,
                                        isMyMessage: true),
                                splashColor: Colors.black45,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    if (isText)
                                      Flexible(
                                        child: Text(
                                          "$description",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ),
                                    if (isSpotlight == true &&
                                        isDeleted == false)
                                      ChatFlareWidget(
                                          flarePoster: poster,
                                          collectionID: collection,
                                          flareID: spotlightID,
                                          isMySide: true,
                                          dateWidget: Text(
                                            "${dateConverter(date)}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11.50,
                                            ),
                                          )),
                                    if (isLocation == true &&
                                        isDeleted == false)
                                      ChatLocationWidget(
                                          messageID: messageID,
                                          location: location,
                                          locationName: locationName,
                                          isMySide: true,
                                          isRead: isRead,
                                          dateWidget: Text(
                                            "${dateConverter(date)}",
                                            style: TextStyle(
                                              color: isRead == false
                                                  ? _accentColor
                                                  : Colors.black,
                                              fontSize: 11.50,
                                            ),
                                          )),
                                    if (isMedia == true && isDeleted == false)
                                      ChatMediaWidget(
                                          mediaUrls: mediaURLs,
                                          dateWidget: Text(
                                            "${dateConverter(date)}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11.50,
                                            ),
                                          ),
                                          isMySide: true),
                                    if (isAudio == true && isDeleted == false)
                                      ChatAudioPlayer(
                                          audioURL,
                                          true,
                                          isRead,
                                          Text(
                                            "${dateConverter(date)}",
                                            style: TextStyle(
                                              color: isRead == false
                                                  ? _accentColor
                                                  : Colors.black,
                                              fontSize: 11.50,
                                            ),
                                          )),
                                    if (isPost == true && isDeleted == false)
                                      giveMini(
                                          "$postID",
                                          Text(
                                            "${dateConverter(date)}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11.50,
                                            ),
                                          ),
                                          true,
                                          isClubPost),
                                    if (isDeleted == true)
                                      Flexible(
                                        child: Text(
                                          "You deleted this message",
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 15.0,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    if (isPost == false &&
                                        isMedia == false &&
                                        isAudio == false &&
                                        isLocation == false &&
                                        isSpotlight == false)
                                      const SizedBox(width: 10.0),
                                    if (isDeleted == false &&
                                        isPost == false &&
                                        isMedia == false &&
                                        isAudio == false &&
                                        isLocation == false &&
                                        isSpotlight == false)
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          const SizedBox(height: 10.0),
                                          Text(
                                            "${dateConverter(date)}",
                                            style: TextStyle(
                                              color: (isPost == false)
                                                  ? _accentColor
                                                  : Colors.grey,
                                              fontSize: 11.50,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      readUnreadMessages(_myUsername);
                      return Align(
                        key: ValueKey<String>(messageID),
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: screenWidth * 0.01,
                            maxWidth: (isPost == false ||
                                    isDeleted == true ||
                                    isAudio == true)
                                ? screenWidth * 0.6
                                : screenWidth,
                            minHeight: screenHeigth * 0.01,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin: EdgeInsets.only(
                                left: (isText) ? 5.0 : 0, bottom: 5.0),
                            decoration: BoxDecoration(
                                color: (isPost == true ||
                                        isAudio == true ||
                                        isMedia == true ||
                                        isLocation == true ||
                                        isSpotlight == true)
                                    ? Colors.transparent
                                    : Colors.grey[300],
                                borderRadius: const BorderRadius.only(
                                    topRight: const Radius.circular(20),
                                    bottomRight: const Radius.circular(20),
                                    bottomLeft: const Radius.circular(20))),
                            child: InkWell(
                              splashColor: Colors.black45,
                              onLongPress: isDeleted == true
                                  ? () {}
                                  : (isPost == true ||
                                          isAudio == true ||
                                          isMedia == true ||
                                          isLocation == true ||
                                          isSpotlight == true)
                                      ? () {}
                                      : () => _showFirst(
                                          id: messageID,
                                          myUsername: _myUsername,
                                          description:
                                              (isText) ? "$description" : '',
                                          isText: isText,
                                          isMyMessage: false),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  if (isDeleted == false &&
                                      isPost == false &&
                                      isMedia == false &&
                                      isSpotlight == false &&
                                      isAudio == false &&
                                      isLocation == false &&
                                      isSpotlight == false)
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        const SizedBox(height: 10.0),
                                        Text(
                                          "${dateConverter(date)}",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 11.50,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (isPost == false &&
                                      isMedia == false &&
                                      isAudio == false &&
                                      isLocation == false &&
                                      isSpotlight == false)
                                    const SizedBox(width: 10.0),
                                  if (isText)
                                    Flexible(
                                      child: Text(
                                        "$description",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                  if (isSpotlight == true && isDeleted == false)
                                    ChatFlareWidget(
                                        flarePoster: poster,
                                        collectionID: collection,
                                        flareID: spotlightID,
                                        isMySide: false,
                                        dateWidget: Text(
                                          "${dateConverter(date)}",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 11.50,
                                          ),
                                        )),
                                  if (isPost == true && isDeleted == false)
                                    giveMini(
                                        "$postID",
                                        Text(
                                          "${dateConverter(date)}",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 11.50,
                                          ),
                                        ),
                                        false,
                                        isClubPost),
                                  if (isLocation == true && isDeleted == false)
                                    ChatLocationWidget(
                                        messageID: messageID,
                                        location: location,
                                        locationName: locationName,
                                        isMySide: false,
                                        isRead: isRead,
                                        dateWidget: Text(
                                          "${dateConverter(date)}",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 11.50,
                                          ),
                                        )),
                                  if (isMedia == true && isDeleted == false)
                                    ChatMediaWidget(
                                        mediaUrls: mediaURLs,
                                        dateWidget: Text(
                                          "${dateConverter(date)}",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 11.50,
                                          ),
                                        ),
                                        isMySide: false),
                                  if (isAudio == true && isDeleted == false)
                                    ChatAudioPlayer(
                                        audioURL,
                                        false,
                                        isRead,
                                        Text(
                                          "${dateConverter(date)}",
                                          style: TextStyle(
                                            color: _primaryColor,
                                            fontSize: 11.50,
                                          ),
                                        )),
                                  if (isDeleted == true)
                                    Flexible(
                                      child: const Text(
                                        "This message has been deleted",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15.0,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isTyping || isRecording)
                  buildAlignedIcon(isTyping, isRecording, _primaryColor),
              ],
            ),
          );
        },
      ),
    );
  }
}
