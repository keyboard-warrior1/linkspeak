import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import 'adaptiveText.dart';
import 'profileImage.dart';

class ShareTile extends StatefulWidget {
  final String username;
  final String imgUrl;
  final String postID;
  const ShareTile(this.username, this.imgUrl, this.postID);

  @override
  _ShareTileState createState() => _ShareTileState();
}

class _ShareTileState extends State<ShareTile> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isBlocked = true;
  bool isSent = false;
  bool isLoading = true;
  bool notExists = true;
  late Future checkSent;
  Future<void> _checkSent(String myUsername, String postID) async {
    final getUser =
        await firestore.collection('Users').doc(widget.username).get();
    if (getUser.exists) {
      notExists = false;
      final getBlocked = await firestore
          .collection('Users')
          .doc(widget.username)
          .collection('Blocked')
          .doc(myUsername)
          .get();
      final getChat = await firestore
          .collection('Users/$myUsername/chats')
          .doc(widget.username)
          .collection('messages')
          .where('isPost', isEqualTo: true)
          .where('description', isEqualTo: postID)
          .where('isDeleted', isEqualTo: false)
          .get();
      final docs = getChat.docs;
      if (!getBlocked.exists) {
        setState(() {
          isBlocked = false;
        });
      }
      if (docs.isEmpty) {
      } else {
        setState(() {
          isSent = true;
        });
      }
      setState(() {
        isLoading = false;
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    checkSent = _checkSent(myUsername, widget.postID);
  }

  Future<void> sendPost(String _myUsername, String postID) async {
    if (isLoading) {
    } else {
      if (isSent) {
      } else {
        setState(() {
          isLoading = true;
        });
        var batch = firestore.batch();
        final sameTime = Timestamp.now();
        final targetUser =
            await firestore.collection('Users').doc(widget.username).get();
        final token = targetUser.get('fcm');
        final _myMessagesCollection = firestore
            .collection('Users/$_myUsername/chats/${widget.username}/messages');

        final _myFriendCollection = firestore
            .collection('Users/${widget.username}/chats/$_myUsername/messages');

        final _myFriendChatDocument =
            firestore.doc('Users/${widget.username}/chats/$_myUsername');

        final _myChatDocument =
            firestore.doc('Users/$_myUsername/chats/${widget.username}');
        batch.set(_myMessagesCollection.doc(), {
          'date': sameTime,
          'description': 'shared a post',
          'postID': '$postID',
          'isRead': false,
          'isDeleted': false,
          'isPost': true,
          'user': '$_myUsername',
          'token': token,
        });

        batch.set(_myFriendCollection.doc(), {
          'date': sameTime,
          'description': 'shared a post',
          'postID': '$postID',
          'isRead': false,
          'isDeleted': false,
          'isPost': true,
          'user': '$_myUsername',
          'token': '',
        });

        batch.set(_myFriendChatDocument, {
          'displayMessage': 'shared a post',
          'isRead': false,
          'lastMessageTime': sameTime,
          'isTyping': false
        });

        batch.set(_myChatDocument, {
          'displayMessage': 'shared a post',
          'isRead': true,
          'lastMessageTime': sameTime
        });
        await batch.commit().then((value) {
          setState(() {
            isLoading = false;
            isSent = true;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return FutureBuilder(
      future: checkSent,
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return ListTile(
            horizontalTitleGap: 2.0,
            leading: ProfileImage(
              username: widget.username,
              url: widget.imgUrl,
              factor: 0.05,
              inEdit: false,
              asset: null,
            ),
            title: OptimisedText(
              minWidth: _deviceWidth * 0.01,
              maxWidth: _deviceWidth * 0.5,
              minHeight: _deviceHeight * 0.05,
              maxHeight: _deviceHeight * 0.05,
              fit: BoxFit.scaleDown,
              child: Text(
                widget.username,
                textAlign: TextAlign.start,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0,
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          ListTile(
            horizontalTitleGap: 2.0,
            leading: ProfileImage(
              username: widget.username,
              url: widget.imgUrl,
              factor: 0.05,
              inEdit: false,
              asset: null,
            ),
            title: OptimisedText(
              minWidth: _deviceWidth * 0.01,
              maxWidth: _deviceWidth * 0.5,
              minHeight: _deviceHeight * 0.05,
              maxHeight: _deviceHeight * 0.05,
              fit: BoxFit.scaleDown,
              child: Text(
                widget.username,
                textAlign: TextAlign.start,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0,
                ),
              ),
            ),
            trailing: (isBlocked)
                ? Container(
                    height: 0,
                    width: 0,
                  )
                : (!notExists)
                    ? SizedBox(
                        height: 30.0,
                        width: 70.0,
                        child: TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                                _primaryColor),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry?>(
                              const EdgeInsets.all(2.0),
                            ),
                          ),
                          child: SizedBox(
                            height: 15.0,
                            width: 15.0,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: _accentColor),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
          );
        }
        return ListTile(
          horizontalTitleGap: 10.0,
          leading: ProfileImage(
            username: widget.username,
            url: widget.imgUrl,
            factor: 0.05,
            inEdit: false,
            asset: null,
          ),
          title: Text(
            widget.username,
            textAlign: TextAlign.start,
            softWrap: false,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 20.0,
            ),
          ),
          trailing: (isBlocked)
              ? Container(
                  height: 0,
                  width: 0,
                )
              : (!notExists)
                  ? SizedBox(
                      height: 30.0,
                      width: 70.0,
                      child: TextButton(
                        onPressed: () {
                          if (isSent) {
                          } else {
                            if (isLoading) {
                            } else {
                              sendPost(_myUsername, widget.postID);
                            }
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: (isSent)
                              ? MaterialStateProperty.all<Color?>(_accentColor)
                              : MaterialStateProperty.all<Color?>(
                                  _primaryColor),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry?>(
                            const EdgeInsets.all(2.0),
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder?>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: BorderSide(color: _primaryColor),
                            ),
                          ),
                        ),
                        child: (isLoading)
                            ? SizedBox(
                                height: 15.0,
                                width: 15.0,
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: _accentColor),
                                ),
                              )
                            : Text(
                                (isSent) ? 'Sent' : 'Send',
                                style: TextStyle(
                                  color:
                                      (isSent) ? _primaryColor : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              ),
                      ),
                    )
                  : Container(
                      height: 0,
                      width: 0,
                    ),
        );
      },
    );
  }
}
