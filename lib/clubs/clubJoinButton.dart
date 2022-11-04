import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/clubProvider.dart';
import '../providers/myProfileProvider.dart';

class JoinClubButton extends StatefulWidget {
  const JoinClubButton();

  @override
  _JoinClubButtonState createState() => _JoinClubButtonState();
}

class _JoinClubButtonState extends State<JoinClubButton> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  _showDialog(String message, Future<void> Function() handler) {
    if (isLoading) {
    } else {
      showDialog(
          context: context,
          builder: (_) {
            return Center(
                child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minWidth: 150.0, maxWidth: 150.0),
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
                              Text(message,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Roboto',
                                      fontSize: 21.0,
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
                                        onPressed: () {
                                          Navigator.pop(context);
                                          handler();
                                        },
                                        child: Text('Yes',
                                            style:
                                                TextStyle(color: Colors.red))),
                                    TextButton(
                                        style: ButtonStyle(
                                            splashFactory:
                                                NoSplash.splashFactory),
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('No',
                                            style:
                                                TextStyle(color: Colors.red)))
                                  ])
                            ]))));
          });
    }
  }

  Future<void> link(String username, String myUsername, void Function() link,
      void Function() profileLink) async {
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      final DateTime _rightNow = DateTime.now();
      var batch = firestore.batch();
      final userLinks =
          firestore.collection('Clubs').doc(username).collection('Members');
      final myLinked = firestore
          .collection('Users')
          .doc(myUsername)
          .collection('Joined Clubs');
      batch.set(userLinks.doc(myUsername), {'date': _rightNow});
      batch.set(myLinked.doc(username), {'date': _rightNow});
      batch.update(firestore.collection('Clubs').doc(username),
          {'numOfMembers': FieldValue.increment(1)});
      batch.update(firestore.collection('Clubs').doc(username),
          {'numOfNewMembers': FieldValue.increment(1)});
      batch.update(firestore.collection('Users').doc(myUsername),
          {'joinedClubs': FieldValue.increment(1)});
      Map<String, dynamic> fields = {'club joins': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {
        'clubName': username,
        'date': _rightNow
      };
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'club joins',
          docID: '$username',
          docFields: docFields);
      batch.commit().then((value) {
        link();
        profileLink();
        setState(() {
          isLoading = false;
        });
      }).catchError((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<void> unlink(String username, String myUsername,
      void Function() unlink, void Function() profileunLink) async {
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      var batch = firestore.batch();
      final _now = DateTime.now();
      final thisClub = firestore.collection('Clubs').doc(username);
      final myUser = firestore.collection('Users').doc(myUsername);
      final clubMembers = thisClub.collection('Members');
      final thisMember = clubMembers.doc(myUsername);
      final exMembers = thisClub.collection('Exmembers');
      final thisExMember = exMembers.doc(myUsername);
      final exClubs = myUser.collection('Exclubs');
      final thisExclub = exClubs.doc(username);
      final myJoined = myUser.collection('Joined Clubs');
      final thisJoined = myJoined.doc(username);
      final options = SetOptions(merge: true);
      Map<String, dynamic> fields = {'club leaves': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'clubName': username, 'date': _now};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'club leaves',
          docID: '$username',
          docFields: docFields);
      batch.delete(thisMember);
      batch.set(thisExMember, {'times': FieldValue.increment(1), 'date': _now},
          options);
      batch.set(
          thisClub,
          {
            'numOfMembers': FieldValue.increment(-1),
            'xMembers': FieldValue.increment(1)
          },
          options);
      batch.delete(thisJoined);
      batch.set(thisExclub, {'times': FieldValue.increment(1), 'date': _now},
          options);
      batch.set(
          myUser,
          {
            'joinedClubs': FieldValue.increment(-1),
            'xClubs': FieldValue.increment(1)
          },
          options);
      return batch.commit().then((_) {
        unlink();
        profileunLink();
        setState(() {
          isLoading = false;
        });
      }).catchError((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<void> sendLinkRequest(String username, String myUsername,
      void Function() sendLinkRequest) async {
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      final DateTime _rightNow = DateTime.now();
      var batch = firestore.batch();
      final userLinkRequests = firestore
          .collection('Clubs')
          .doc(username)
          .collection('JoinRequests');
      batch.set(userLinkRequests.doc(myUsername), {
        'user': myUsername,
        'date': _rightNow,
      });
      batch.update(firestore.collection('Clubs').doc(username),
          {'numOfJoinRequests': FieldValue.increment(1)});
      batch.commit().then((_) {
        sendLinkRequest();
        setState(() {
          isLoading = false;
        });
      }).catchError((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<void> cancelLinkRequest(String username, String myUsername,
      void Function() cancelLinkRequest) async {
    setState(() {
      isLoading = true;
    });
    var batch = firestore.batch();
    final userLinkRequests =
        firestore.collection('Clubs').doc(username).collection('JoinRequests');
    batch.delete(userLinkRequests.doc(myUsername));
    batch.update(firestore.collection('Clubs').doc(username),
        {'numOfJoinRequests': FieldValue.increment(-1)});
    batch.commit().then((_) {
      cancelLinkRequest();
      setState(() {
        isLoading = false;
      });
    }).catchError((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final profileUnlink =
        Provider.of<MyProfile>(context, listen: false).subtractClubs;
    final profileLink = Provider.of<MyProfile>(context, listen: false).addClubs;
    final otherProfileFunctions =
        Provider.of<ClubProvider>(context, listen: false);
    final _link = otherProfileFunctions.joinClub;
    final unlinkMe = otherProfileFunctions.leaveClub;
    final request = otherProfileFunctions.requestJoinClub;
    final cancel = otherProfileFunctions.cancelRequest;
    final otherProfile = Provider.of<ClubProvider>(context);
    final username = otherProfile.clubName;
    final bool imLinkedToThem = otherProfile.isJoined;
    final bool linkRequestSent = otherProfile.isRequested;
    final bool isPrivate = Provider.of<ClubProvider>(context).clubVisibility ==
        ClubVisibility.private;
    final bool imBlocked = Provider.of<ClubProvider>(context).isBanned;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    Future<void> _unlink() =>
        unlink(username, myUsername, unlinkMe, profileUnlink);
    Future<void> _cancelRequest() =>
        cancelLinkRequest(username, myUsername, cancel);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
            height:
                (imBlocked && !myUsername.startsWith('Linkspeak')) ? 0 : null,
            width:
                (imBlocked && !myUsername.startsWith('Linkspeak')) ? 0 : null,
            child: TextButton(
                onPressed: () {
                  if (isLoading) {
                  } else {
                    if (imLinkedToThem) {
                      _showDialog('Leave club', _unlink);
                    }
                    if (linkRequestSent) {
                      _showDialog('Cancel request', _cancelRequest);
                    }
                    if (isPrivate && !imLinkedToThem && !linkRequestSent) {
                      sendLinkRequest(username, myUsername, request);
                    }
                    if (!isPrivate && !imLinkedToThem) {
                      link(username, myUsername, _link, profileLink);
                    }
                  }
                },
                style: (imLinkedToThem)
                    ? ButtonStyle(
                        splashFactory: NoSplash.splashFactory,
                        shape: MaterialStateProperty.all<OutlinedBorder?>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0))),
                        backgroundColor:
                            MaterialStateProperty.all<Color?>(_primaryColor))
                    : ButtonStyle(
                        splashFactory: NoSplash.splashFactory,
                        shape: MaterialStateProperty.all<OutlinedBorder?>(
                            RoundedRectangleBorder(
                                side: BorderSide(color: _primaryColor),
                                borderRadius: BorderRadius.circular(5.0))),
                        backgroundColor: MaterialStateProperty.all<Color?>(
                            Colors.transparent)),
                child: (isLoading)
                    ? CircularProgressIndicator(
                        color: (imLinkedToThem) ? _accentColor : _primaryColor,
                        strokeWidth: 1.50)
                    : Text(
                        (imLinkedToThem)
                            ? 'Joined'
                            : (linkRequestSent)
                                ? 'Requested'
                                : 'Join',
                        style: TextStyle(
                            fontSize: 18.0,
                            color:
                                (imLinkedToThem) ? _accentColor : _primaryColor)))));
  }
}
