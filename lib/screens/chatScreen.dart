import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/chat/chatMenu.dart';
import '../widgets/chat/chatMessages.dart';
import '../widgets/chat/sendButton.dart';
import '../widgets/common/chatProfileImage.dart';

class ChatScreen extends StatefulWidget {
  final dynamic comeFromProfile;
  final dynamic chatId;
  ChatScreen({required this.chatId, required this.comeFromProfile});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController _scrollController = ScrollController();

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

    var displayChatName = widget.chatId;
    if (widget.chatId.length > 15) {
      displayChatName = "${widget.chatId.substring(0, 15)}..";
    }
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _myFriendCollection =
        firestore.collection('Users/${widget.chatId}/chats').doc(_myUsername);
    final screenWidth = General.widthQuery(context);
    final screenHeigth = MediaQuery.of(context).size.height;

    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    return WillPopScope(
      onWillPop: () async {
        Future.delayed(const Duration(milliseconds: 50), () async {
          var col = await _myFriendCollection.get();
          if (col.exists) {
            _myFriendCollection
                .update({'isTyping': false, 'isRecording': false});
          }
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        });
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeigth * 0.075,
                  color: Colors.white,
                  child: Row(
                    children: [
                      BackButton(
                        onPressed: () async {
                          Future.delayed(const Duration(milliseconds: 50),
                              () async {
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
                      GestureDetector(
                        onTap: () {
                          if (!widget.comeFromProfile) {
                            _visitProfile(username: widget.chatId);
                          }
                        },
                        child: ChatProfileImage(
                            username: widget.chatId,
                            factor: 0.03,
                            inEdit: false,
                            asset: null,
                            editUrl: ''),
                      ),
                      const SizedBox(width: 5.0),
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
                              child: Text(displayChatName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17.0,
                                      color: Colors.black)),
                            ),
                            const SizedBox(width: 5.0),
                            StreamBuilder(
                              stream: firestore
                                  .collection('Users')
                                  .doc('${widget.chatId}')
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.data == null) {
                                  return Container(
                                      width: 10.0,
                                      height: 10.0,
                                      decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle));
                                }
                                if (!snapshot.data!.exists) {
                                  return Container(
                                      width: 10.0,
                                      height: 10.0,
                                      decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle));
                                }
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
                                    if (snapshot.data!['Activity'] == "Away" ||
                                        snapshot.data!['Activity'] ==
                                            "Offline") {
                                      return Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade400,
                                              shape: BoxShape.circle));
                                    } else if (snapshot.data!['Activity'] ==
                                            "Online" ||
                                        snapshot.data!['Activity'] ==
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
                                          decoration: const BoxDecoration(
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
