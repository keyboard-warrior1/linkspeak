import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/themeModel.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/adaptiveText.dart';
import '../common/chatprofileImage.dart';

class ShareTile extends StatefulWidget {
  final String username;
  final String postID;
  final bool isClubPost;
  final bool isSpotlight;
  final String clubName;
  final String flarePoster;
  final String collectionID;
  final String flareID;
  const ShareTile(
      {required this.username,
      required this.postID,
      required this.isClubPost,
      required this.clubName,
      required this.isSpotlight,
      required this.flarePoster,
      required this.collectionID,
      required this.flareID});

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

  Future<void> sendPost(
      String _myUsername, String postID, String myLangCode) async {
    if (isLoading) {
    } else {
      if (isSent) {
      } else {
        setState(() {
          isLoading = true;
        });
        final sameTime = Timestamp.now();
        var batch = firestore.batch();
        final users = firestore.collection('Users');
        final posts = firestore.collection('Posts');
        final thisPost = posts.doc(postID);
        final getPost = await thisPost.get();
        final exists = getPost.exists;
        if (exists) {
          final myProfile = users.doc(_myUsername);
          final theirProfile = users.doc(widget.username);
          final theirReceivedPosts = theirProfile.collection('Received Posts');
          final thisReceived = theirReceivedPosts.doc(postID);
          final thisReceivedFrom =
              thisReceived.collection('senders').doc(_myUsername);
          final myShares = myProfile.collection('Shares');
          final recipient = myShares.doc(widget.username);
          final recipientPosts = recipient.collection('posts');
          final thisRecipientPost = recipientPosts.doc(postID);
          final sharers = thisPost.collection('Sharers');
          final myShare = sharers.doc(_myUsername);
          final myShareDoc = await myShare.get();
          final myShareExists = myShareDoc.exists;
          final toCollection = myShare.collection('To');
          final to = toCollection.doc(widget.username);
          final getTo = await to.get();
          final sentBefore = getTo.exists;
          final initialDocData = {
            'first shared': sameTime,
            'times': FieldValue.increment(1),
          };
          final existingDocData = {
            'last shared': sameTime,
            if (!sentBefore) 'times': FieldValue.increment(1),
          };
          final options = SetOptions(merge: true);
          batch.set(
              thisRecipientPost,
              {
                'id': postID,
                'times': FieldValue.increment(1),
                'date': sameTime
              },
              options);
          batch.set(
              thisReceived,
              {
                'id': postID,
                'times': FieldValue.increment(1),
                'last sender': _myUsername,
                'last received': sameTime,
              },
              options);
          if (!myShareExists) {
            batch.set(myShare, initialDocData, options);
            batch.set(to, initialDocData, options);
          } else {
            batch.set(myShare, existingDocData, options);
            batch.set(to, initialDocData, options);
          }
          batch.set(thisPost, {'shares': FieldValue.increment(1)}, options);
          batch.set(
              myProfile,
              {
                if (!sentBefore) 'shared posts': FieldValue.increment(1),
                'last shared post': postID,
                'last shared post recipient': widget.username,
                'last shared post date': sameTime
              },
              options);
          batch.set(
              theirProfile,
              {
                'received posts': FieldValue.increment(1),
                'last received post': postID,
                'last post sender': _myUsername,
                'date last received post': sameTime
              },
              options);
          batch.set(thisReceivedFrom,
              {'date': sameTime, 'times': FieldValue.increment(1)}, options);
          batch.set(
              recipient,
              {'last shared post': postID, 'date last shared post': sameTime},
              options);
        }
        final targetUser =
            await firestore.collection('Users').doc(widget.username).get();
        String targetLang = 'en';
        if (targetUser.data()!.containsKey('language')) {
          targetLang = targetUser.get('language');
        }
        final String friendMessage =
            General.giveShareMessage(false, targetLang);
        final String myMessage = General.giveShareMessage(false, myLangCode);
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
          'description': myMessage,
          'postID': '$postID',
          'isRead': false,
          'isDeleted': false,
          'isPost': true,
          'isMedia': false,
          'isSpotlight': widget.isSpotlight,
          'poster': widget.flarePoster,
          'collection': widget.collectionID,
          'spotlightID': '',
          'user': '$_myUsername',
          'token': token,
          'isClubPost': widget.isClubPost,
          'clubName': widget.clubName,
          'mediaURL': [],
          'isAudio': false,
          'isLocation': false,
          'locationName': '',
          'location': '',
          'audioURL': '',
        });

        batch.set(_myFriendCollection.doc(), {
          'date': sameTime,
          'description': friendMessage,
          'postID': '$postID',
          'isRead': false,
          'isDeleted': false,
          'isPost': true,
          'isMedia': false,
          'isSpotlight': widget.isSpotlight,
          'poster': widget.flarePoster,
          'collection': widget.collectionID,
          'spotlightID': '',
          'user': '$_myUsername',
          'token': '',
          'isClubPost': widget.isClubPost,
          'clubName': widget.clubName,
          'mediaURL': [],
          'isAudio': false,
          'isLocation': false,
          'locationName': '',
          'location': '',
          'audioURL': '',
        });

        batch.set(_myFriendChatDocument, {
          'displayMessage': friendMessage,
          'isRead': false,
          'lastMessageTime': sameTime,
          'isTyping': false,
          'isRecording': false,
        });

        batch.set(_myChatDocument, {
          'displayMessage': myMessage,
          'isRead': true,
          'lastMessageTime': sameTime
        });
        await batch.commit().then((value) {
          setState(() {
            isLoading = false;
            isSent = true;
          });
          Map<String, dynamic> fields = {
            'messages posts': FieldValue.increment(1),
            'messages total': FieldValue.increment(1)
          };
          General.updateControl(
              myUsername: _myUsername,
              fields: fields,
              collectionName: null,
              docID: null,
              docFields: {});
          if (widget.isClubPost) {
            Map<String, dynamic> fields = {
              'club post shares': FieldValue.increment(1)
            };
            Map<String, dynamic> docFields = {
              'clubName': widget.clubName,
              'date': sameTime,
              'last shared to': widget.username,
              'times': FieldValue.increment(1)
            };
            General.updateControl(
                fields: fields,
                myUsername: _myUsername,
                collectionName: 'club post shares',
                docID: '${widget.postID}',
                docFields: docFields);
          } else {
            Map<String, dynamic> fields = {
              'post shares': FieldValue.increment(1)
            };
            Map<String, dynamic> docFields = {
              'date': sameTime,
              'last shared to': widget.username,
              'times': FieldValue.increment(1)
            };
            General.updateControl(
                fields: fields,
                myUsername: _myUsername,
                collectionName: 'post shares',
                docID: '${widget.postID}',
                docFields: docFields);
          }
        });
      }
    }
  }

  Future<void> sendFlare(String _myUsername, String posterID,
      String collectionID, String flareID, String myLangCode) async {
    if (isLoading) {
    } else {
      if (isSent) {
      } else {
        setState(() {
          isLoading = true;
        });
        var batch = firestore.batch();
        final sameTime = Timestamp.now();
        final users = firestore.collection('Users');
        final flares = firestore.collection('Flares');
        final thisFlarer = flares.doc(posterID);
        final thisCollection =
            thisFlarer.collection('collections').doc(collectionID);
        final thisFlare = thisCollection.collection('flares').doc(flareID);
        final getFlare = await thisFlare.get();
        final exists = getFlare.exists;
        if (exists) {
          final myProfile = users.doc(_myUsername);
          final theirProfile = users.doc(widget.username);
          final theirReceivedflares =
              theirProfile.collection('Received Flares');
          final thisReceived = theirReceivedflares.doc(flareID);
          final myShares = myProfile.collection('Shares');
          final thisReceivedFrom =
              thisReceived.collection('senders').doc(_myUsername);
          final recipient = myShares.doc(widget.username);
          final recipientFlares = recipient.collection('flares');
          final thisRecipientFlare = recipientFlares.doc(flareID);
          final sharers = thisFlare.collection('Sharers');
          final myShare = sharers.doc(_myUsername);
          final myShareDoc = await myShare.get();
          final myShareExists = myShareDoc.exists;
          final toCollection = myShare.collection('To');
          final to = toCollection.doc(widget.username);
          final getTo = await to.get();
          final sentBefore = getTo.exists;
          final initialDocData = {
            'first shared': sameTime,
            'times': FieldValue.increment(1),
          };
          final existingDocData = {
            'last shared': sameTime,
            if (!sentBefore) 'times': FieldValue.increment(1),
          };
          final options = SetOptions(merge: true);
          batch.set(
              thisRecipientFlare,
              {
                'poster': posterID,
                'collectionID': collectionID,
                'flareID': flareID,
                'times': FieldValue.increment(1),
                'date': sameTime
              },
              options);
          batch.set(
              thisReceived,
              {
                'poster': posterID,
                'collectionID': collectionID,
                'flareID': flareID,
                'times': FieldValue.increment(1),
                'last sender': _myUsername,
                'last received': sameTime,
              },
              options);
          if (!myShareExists) {
            batch.set(myShare, initialDocData, options);
            batch.set(to, initialDocData, options);
            batch.set(
                thisCollection, {'shares': FieldValue.increment(1)}, options);
          } else {
            batch.set(myShare, existingDocData, options);
            batch.set(to, initialDocData, options);
          }
          batch.set(
              thisCollection,
              {'last shared ID': flareID, 'last share date': sameTime},
              options);
          batch.set(thisFlare, {'shares': FieldValue.increment(1)}, options);
          batch.set(
              myProfile,
              {
                if (!sentBefore) 'shared flares': FieldValue.increment(1),
                'last shared flare': flareID,
                'last shared flare recipient': widget.username,
                'last shared flare date': sameTime
              },
              options);
          batch.set(
              theirProfile,
              {
                'received flares': FieldValue.increment(1),
                'last received flare': flareID,
                'last flare sender': _myUsername,
                'date last received flare': sameTime
              },
              options);
          batch.set(thisReceivedFrom,
              {'date': sameTime, 'times': FieldValue.increment(1)}, options);
          batch.set(
              recipient,
              {
                'last shared flare': flareID,
                'date last shared flare': sameTime
              },
              options);
        }
        final targetUser =
            await firestore.collection('Users').doc(widget.username).get();
        String targetLang = 'en';
        if (targetUser.data()!.containsKey('language')) {
          targetLang = targetUser.get('language');
        }
        final String friendMessage = General.giveShareMessage(true, targetLang);
        final String myMessage = General.giveShareMessage(true, myLangCode);

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
          'description': myMessage,
          'postID': '',
          'isRead': false,
          'isDeleted': false,
          'isPost': false,
          'isMedia': false,
          'isSpotlight': true,
          'poster': widget.flarePoster,
          'collection': widget.collectionID,
          'spotlightID': widget.flareID,
          'user': '$_myUsername',
          'token': token,
          'isClubPost': false,
          'clubName': '',
          'mediaURL': [],
          'isAudio': false,
          'isLocation': false,
          'locationName': '',
          'location': '',
          'audioURL': '',
        });

        batch.set(_myFriendCollection.doc(), {
          'date': sameTime,
          'description': friendMessage,
          'postID': '',
          'isRead': false,
          'isDeleted': false,
          'isPost': false,
          'isMedia': false,
          'isSpotlight': true,
          'poster': widget.flarePoster,
          'collection': widget.collectionID,
          'spotlightID': widget.flareID,
          'user': '$_myUsername',
          'token': '',
          'isClubPost': false,
          'clubName': '',
          'mediaURL': [],
          'isAudio': false,
          'isLocation': false,
          'locationName': '',
          'location': '',
          'audioURL': '',
        });

        batch.set(_myFriendChatDocument, {
          'displayMessage': friendMessage,
          'isRead': false,
          'lastMessageTime': sameTime,
          'isTyping': false,
          'isRecording': false,
        });

        batch.set(_myChatDocument, {
          'displayMessage': myMessage,
          'isRead': true,
          'lastMessageTime': sameTime
        });
        await batch.commit().then((value) {
          setState(() {
            isLoading = false;
            isSent = true;
          });
          Map<String, dynamic> fields = {
            'messages flares': FieldValue.increment(1),
            'messages total': FieldValue.increment(1),
            'flare shares': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'poster': widget.flarePoster,
            'collection': widget.collectionID,
            'flare': widget.flareID,
            'date': sameTime,
            'last shared to': widget.username,
            'times': FieldValue.increment(1)
          };
          General.updateControl(
              myUsername: _myUsername,
              fields: fields,
              collectionName: 'flare shares',
              docID: null,
              docFields: docFields);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myLangCode =
        Provider.of<ThemeModel>(context, listen: false).serverLangCode;
    final lang = General.language(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    const emptyBox = const SizedBox(height: 30.0, width: 70.0);
    String displayName = widget.username;
    if (widget.username.length > 15) {
      displayName = '${widget.username.substring(0, 15)}..';
    }
    void visitProfile() {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: widget.username);
      Navigator.pushNamed(
          context,
          (widget.username == _myUsername)
              ? RouteGenerator.myProfileScreen
              : RouteGenerator.posterProfileScreen,
          arguments: (widget.username == _myUsername) ? null : args);
    }

    return FutureBuilder(
        future: checkSent,
        builder: (ctx, snapshot) {
          if (snapshot.hasError)
            return ListTile(
                enabled: true,
                onTap: () => visitProfile(),
                horizontalTitleGap: 2.0,
                leading: ChatProfileImage(
                    username: widget.username,
                    factor: 0.04,
                    inEdit: false,
                    asset: null),
                title: OptimisedText(
                    minWidth: _deviceWidth * 0.01,
                    maxWidth: _deviceWidth * 0.5,
                    minHeight: _deviceHeight * 0.05,
                    maxHeight: _deviceHeight * 0.05,
                    fit: BoxFit.scaleDown,
                    child: Text(displayName,
                        textAlign: TextAlign.start,
                        softWrap: false,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 17.0))),
                trailing: emptyBox);

          // if (snapshot.connectionState == ConnectionState.waiting)
          //   return ListTile(
          //       enabled: true,
          //       onTap: () => visitProfile(),
          //       horizontalTitleGap: 2.0,
          //       leading: ChatProfileImage(
          //           username: widget.username,
          //           factor: 0.04,
          //           inEdit: false,
          //           asset: null),
          //       title: OptimisedText(
          //           minWidth: _deviceWidth * 0.01,
          //           maxWidth: _deviceWidth * 0.5,
          //           minHeight: _deviceHeight * 0.05,
          //           maxHeight: _deviceHeight * 0.05,
          //           fit: BoxFit.scaleDown,
          //           child: Text(displayName,
          //               textAlign: TextAlign.start,
          //               softWrap: false,
          //               style: const TextStyle(
          //                   color: Colors.black,
          //                   fontWeight: FontWeight.w400,
          //                   fontSize: 17.0))),
          //       trailing: emptyBox);

          return ListTile(
              enabled: true,
              onTap: () => visitProfile(),
              horizontalTitleGap: 2.0,
              leading: ChatProfileImage(
                  username: widget.username,
                  factor: 0.04,
                  inEdit: false,
                  asset: null),
              title: Text(displayName,
                  textAlign: TextAlign.start,
                  softWrap: false,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 17.0)),
              trailing: (isBlocked)
                  ? emptyBox
                  : (!notExists)
                      ? SizedBox(
                          height: 30.0,
                          width: 60.0,
                          child: TextButton(
                              onPressed: () {
                                if (isSent) {
                                } else {
                                  if (isLoading) {
                                  } else {
                                    if (widget.isSpotlight) {
                                      sendFlare(
                                          _myUsername,
                                          widget.flarePoster,
                                          widget.collectionID,
                                          widget.flareID,
                                          myLangCode);
                                    } else {
                                      sendPost(_myUsername, widget.postID,
                                          myLangCode);
                                    }
                                  }
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: (isSent)
                                      ? MaterialStateProperty.all<Color?>(
                                          _accentColor)
                                      : MaterialStateProperty.all<Color?>(
                                          _primaryColor),
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                      const EdgeInsets.all(2.0)),
                                  shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      side: BorderSide(color: _primaryColor)))),
                              child: (isLoading)
                                  ? SizedBox(
                                      height: 15.0,
                                      width: 15.0,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              color: _accentColor,
                                              strokeWidth: 1.50)))
                                  : Text((isSent) ? lang.widgets_share1 : lang.widgets_share2, style: TextStyle(color: (isSent) ? _primaryColor : Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0))))
                      : emptyBox);
        });
  }
}
