import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_speak/providers/myProfileProvider.dart';
import 'package:link_speak/widgets/chatProfileImage.dart';
import 'package:provider/provider.dart';
import '../widgets/sendButton.dart';
import '../widgets/chatMenu.dart';
import '../widgets/chatMessages.dart';
import '../models/screenArguments.dart';
import '../routes.dart';

class ChatScreen extends StatefulWidget {
  final dynamic comeFromProfile;
  final dynamic chatId;
  ChatScreen({required this.chatId, required this.comeFromProfile});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future setOnlineFuture;
  late Future setOfflineFuture;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setOfflineFuture = setOffline();
    setOnlineFuture = setOnline();
  }

  Future setOnline() async {
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    await firestore
        .doc('Users/$_myUsername')
        .update({'Activity': 'inChatScreen'});
  }

  Future setOffline() async {
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    await firestore.doc('Users/$_myUsername').update({'Activity': 'Offline'});
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    void _visitProfile({required final String username}) {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: username);
      Navigator.pushNamed(
        context,
        (username == myUsername)
            ? RouteGenerator.myProfileScreen
            : RouteGenerator.posterProfileScreen,
        arguments: args,
      );
    }

    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _myFriendCollection =
        firestore.collection('Users/${widget.chatId}/chats').doc(_myUsername);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeigth = MediaQuery.of(context).size.height;
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    return WillPopScope(
      onWillPop: () async {
        Future.delayed(const Duration(milliseconds: 50), () async {
          await setOffline();
          var col = await _myFriendCollection.get();
          if (col.exists) {
            _myFriendCollection.update({'isTyping': false});
          }
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        });
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white12,
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeigth * 0.075,
                  color: Colors.white12,
                  child: Row(
                    children: [
                      BackButton(
                        onPressed: () async {
                          Future.delayed(const Duration(milliseconds: 50),
                              () async {
                            await setOffline();
                            var col = await _myFriendCollection.get();
                            if (col.exists) {
                              _myFriendCollection.update({'isTyping': false});
                            }
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                          });
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 15.0),
                      GestureDetector(
                        onTap: () {
                          if (!widget.comeFromProfile) {
                            _visitProfile(username: widget.chatId);
                          }
                        },
                        child: ChatProfileImage(
                            username: widget.chatId,
                            factor: 0.04,
                            inEdit: false,
                            asset: null),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!widget.comeFromProfile) {
                                  _visitProfile(username: widget.chatId);
                                }
                              },
                              child: Text("${widget.chatId}",
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20.0,
                                      color: Colors.black)),
                            ),
                            SizedBox(width: 5),
                            StreamBuilder(
                              stream: firestore
                                  .collection('Users')
                                  .doc('${widget.chatId}')
                                  .snapshots(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (widget.chatId == 'Linkspeak') {
                                  return Stack(
                                    children: <Widget>[
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _accentColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: _primaryColor),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.verified,
                                          color: _primaryColor,
                                          size: 17.0,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  if (!snapshot.hasData) {
                                    return Container(
                                        width: 10.0,
                                        height: 10.0,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            shape: BoxShape.circle));
                                  } else {
                                    if (snapshot.data['Activity'] == "Away" ||
                                        snapshot.data['Activity'] ==
                                            "Offline") {
                                      return Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade400,
                                              shape: BoxShape.circle));
                                    } else if (snapshot.data['Activity'] ==
                                            "Online" ||
                                        snapshot.data['Activity'] ==
                                            "inChatScreen") {
                                      return Container(
                                        width: 10.0,
                                        height: 10.0,
                                        decoration: BoxDecoration(
                                            color: Colors
                                                .lightGreenAccent.shade400,
                                            shape: BoxShape.circle),
                                      );
                                    } else {
                                      return Container(
                                          width: 10.0,
                                          height: 10.0,
                                          decoration: BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle));
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      ChatMenu(widget.chatId),
                    ],
                  ),
                ),
                ChatMessages(widget.chatId, _scrollController),
                SendButton(_scrollController, widget.chatId)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
