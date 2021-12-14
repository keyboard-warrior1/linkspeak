import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/myProfileProvider.dart';

class SendButton extends StatefulWidget {
  final ScrollController scrollController;
  final String chatId;
  const SendButton(this.scrollController, this.chatId);

  @override
  _SendButtonState createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> with WidgetsBindingObserver {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isBlocked = false;
  bool imBlocked = false;
  bool exists = false;
  bool _isActiveSendButton = false;
  final _textFieldController = TextEditingController();
  late Future<void> Function() offTyping;
  Future<void> _offTyping(String myUsername) {
    final _myFriend =
        firestore.collection('Users/${widget.chatId}/chats').doc(myUsername);
    return _myFriend.update({'isTyping': false});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
        offTyping();
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    firestore
        .collection('Users/$myUsername/chats')
        .doc('${widget.chatId}')
        .get()
        .then((value) {
      if (value.exists) {
        exists = true;
        offTyping = () => _offTyping(myUsername);
        WidgetsBinding.instance!.addObserver(this);

        final users = firestore.collection('Users');
        final myBlocked =
            users.doc(myUsername).collection('Blocked').snapshots();
        final theirBlocked =
            users.doc(widget.chatId).collection('Blocked').snapshots();
        myBlocked.listen((event) {
          final info = event.docs;
          final theyBlocked = info.any((id) => id.id == widget.chatId);
          if (theyBlocked) {
            if (!isBlocked) {
              isBlocked = true;
              setState(() {});
            }
          } else {
            if (isBlocked) {
              isBlocked = false;
              setState(() {});
            }
          }
        });
        theirBlocked.listen((event) {
          final info = event.docs;
          final iBlocked = info.any((id) => id.id == myUsername);
          if (iBlocked) {
            if (!imBlocked) {
              imBlocked = true;
              setState(() {});
            }
          } else {
            if (imBlocked) {
              imBlocked = false;
              setState(() {});
            }
          }
        });
      } else {
        firestore
            .collection('Users/$myUsername/chats/${widget.chatId}/messages')
            .snapshots()
            .listen((event) {
          if (event.docs.isNotEmpty) {
            exists = true;
            setState(() {});
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).primaryColor;
    final _accentColor = Theme.of(context).accentColor;
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _myFriend =
        firestore.collection('Users/${widget.chatId}/chats').doc(_myUsername);
    return Container(
      margin: const EdgeInsets.all(7.0),
      child: TextField(
        minLines: 1,
        maxLines: 7,
        style: const TextStyle(color: Colors.black),
        controller: _textFieldController,
        onChanged: (value) async {
          if (value.replaceAll(' ', '') == '' || value.trim() == '') {
            if (_isActiveSendButton) {
              setState(() {
                _isActiveSendButton = false;
              });
              if (exists) await _myFriend.update({'isTyping': false});
            }
          }
          if (value.isNotEmpty) {
            if (value.replaceAll(' ', '') == '' || value.trim() == '') {
              if (_isActiveSendButton) {
                setState(() {
                  _isActiveSendButton = false;
                });
                if (exists) await _myFriend.update({'isTyping': false});
              }
            } else {
              if (!_isActiveSendButton) {
                setState(() {
                  _isActiveSendButton = true;
                });
                if (exists) await _myFriend.update({'isTyping': true});
              }
            }
          } else {
            if (_isActiveSendButton) {
              setState(() {
                _isActiveSendButton = false;
              });
              if (exists) await _myFriend.update({'isTyping': false});
            }
          }
        },
        decoration: InputDecoration(
          suffixIcon: Opacity(
            opacity: _isActiveSendButton ? 1.0 : 0.5,
            child: GestureDetector(
              onTap: () async {
                final targetUser = await firestore
                    .collection('Users')
                    .doc(widget.chatId)
                    .get();
                final token = targetUser.get('fcm');
                final String controllerText = _textFieldController.value.text;
                if (controllerText.isEmpty ||
                    controllerText.replaceAll(' ', '') == '' ||
                    controllerText.trim() == '' ||
                    (isBlocked && !_myUsername.startsWith('Linkspeak')) ||
                    (imBlocked && !_myUsername.startsWith('Linkspeak'))) {
                } else {
                  setState(() {
                    _isActiveSendButton = false;
                  });
                  var batch = firestore.batch();
                  final String theText = controllerText.trim();
                  _textFieldController.clear();
                  final sameTime = Timestamp.now();
                  final _myMessagesCollection = firestore.collection(
                      'Users/$_myUsername/chats/${widget.chatId}/messages');

                  final _myFriendCollection = firestore.collection(
                      'Users/${widget.chatId}/chats/$_myUsername/messages');

                  final _myFriendChatDocument = firestore
                      .doc('Users/${widget.chatId}/chats/$_myUsername');

                  final _myChatDocument = firestore
                      .doc('Users/$_myUsername/chats/${widget.chatId}');
                  batch.set(_myMessagesCollection.doc(), {
                    'date': sameTime,
                    'description': '$theText',
                    'isRead': false,
                    'isDeleted': false,
                    'isPost': false,
                    'isMedia': false,
                    'user': '$_myUsername',
                    'token': '',
                  });

                  batch.set(_myFriendCollection.doc(), {
                    'date': sameTime,
                    'description': '$theText',
                    'isRead': false,
                    'isDeleted': false,
                    'isPost': false,
                    'isMedia': false,
                    'user': '$_myUsername',
                    'token': token,
                  });

                  batch.set(_myFriendChatDocument, {
                    'displayMessage': '$theText',
                    'isRead': false,
                    'lastMessageTime': sameTime,
                    'isTyping': false
                  });

                  batch.set(_myChatDocument, {
                    'displayMessage': '$theText',
                    'isRead': true,
                    'lastMessageTime': sameTime
                  });
                  await Future.delayed(
                      const Duration(milliseconds: 100), () => batch.commit());
                  if (widget.scrollController.hasClients) if (widget
                          .scrollController.offset <=
                      widget.scrollController.position.maxScrollExtent) {
                    widget.scrollController.animateTo(
                        widget.scrollController.position.minScrollExtent,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  child: Icon(Icons.send, color: _accentColor, size: 18.0),
                  backgroundColor: _primaryColor,
                ),
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: "Write anything..",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          errorBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          disabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          hintStyle: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
