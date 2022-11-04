import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/profile.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';

class LinkButton extends StatefulWidget {
  const LinkButton();
  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
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
          firestore.collection('Users').doc(username).collection('Links');
      final targetUser =
          await firestore.collection('Users').doc(username).get();
      final token = targetUser.get('fcm');
      final userLinksNotifs = firestore
          .collection('Users')
          .doc(username)
          .collection('NewLinksNotifs');
      final myLinked =
          firestore.collection('Users').doc(myUsername).collection('Linked');
      batch.set(userLinks.doc(myUsername), {'date': _rightNow});
      batch.set(myLinked.doc(username), {'date': _rightNow});
      final status = targetUser.get('Status');
      if (status != 'Banned') {
        if (targetUser.data()!.containsKey('AllowLinks')) {
          final allowLinks = targetUser.get('AllowLinks');
          if (allowLinks) {
            batch.set(userLinksNotifs.doc(myUsername), {
              'user': myUsername,
              'recipient': username,
              'token': token,
              'date': _rightNow,
            });
            batch.update(firestore.collection('Users').doc(username),
                {'numOfNewLinksNotifs': FieldValue.increment(1)});
          }
        } else {
          batch.set(userLinksNotifs.doc(myUsername), {
            'user': myUsername,
            'recipient': username,
            'token': token,
            'date': _rightNow,
          });
          batch.update(firestore.collection('Users').doc(username),
              {'numOfNewLinksNotifs': FieldValue.increment(1)});
        }
      }
      batch.update(firestore.collection('Users').doc(username),
          {'numOfLinks': FieldValue.increment(1)});
      batch.update(firestore.collection('Users').doc(myUsername),
          {'numOfLinked': FieldValue.increment(1)});
      Map<String, dynamic> fields = {'links': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'date': _rightNow};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'links',
          docID: username,
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
      final checkExists = await General.checkExists('Users/$username');
      var batch = firestore.batch();
      final _now = DateTime.now();
      final userLinks =
          firestore.collection('Users').doc(username).collection('Links');
      final userUnlinks =
          firestore.collection('Users').doc(username).collection('Unlinks');
      final myLinked =
          firestore.collection('Users').doc(myUsername).collection('Linked');
      final myUnlinks =
          firestore.collection('Users').doc(myUsername).collection('Unlinked');
      batch.set(
          userUnlinks.doc(myUsername),
          {'date': _now, 'times': FieldValue.increment(1)},
          SetOptions(merge: true));
      batch.set(
          myUnlinks.doc(username),
          {'date': _now, 'times': FieldValue.increment(1)},
          SetOptions(merge: true));
      batch.delete(userLinks.doc(myUsername));
      batch.update(firestore.collection('Users').doc(username),
          {'numOfLinks': FieldValue.increment(-1)});
      if (checkExists)
        batch.set(firestore.collection('Users').doc(username),
            {'numOfUnlinks': FieldValue.increment(1)}, SetOptions(merge: true));
      batch.delete(myLinked.doc(username));
      batch.update(firestore.collection('Users').doc(myUsername),
          {'numOfLinked': FieldValue.increment(-1)});
      batch.set(firestore.collection('Users').doc(myUsername),
          {'numOfUnlinked': FieldValue.increment(1)}, SetOptions(merge: true));
      Map<String, dynamic> fields = {'links unlinked': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'date': _now};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'links unlinked',
          docID: username,
          docFields: docFields);
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
      final DateTime _rightNow = DateTime.now();
      final targetUser =
          await firestore.collection('Users').doc(username).get();
      final token = targetUser.get('fcm');
      setState(() {
        isLoading = true;
      });
      var batch = firestore.batch();
      final userLinkRequests = firestore
          .collection('Users')
          .doc(username)
          .collection('LinkRequestsNotifs');
      batch.set(userLinkRequests.doc(myUsername), {
        'user': myUsername,
        'recipient': username,
        'token': token,
        'date': _rightNow,
      });
      batch.update(firestore.collection('Users').doc(username),
          {'numOfLinkRequestsNotifs': FieldValue.increment(1)});
      Map<String, dynamic> fields = {'link requests': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'date': _rightNow};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'link requests',
          docID: username,
          docFields: docFields);
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
    final userLinkRequests = firestore
        .collection('Users')
        .doc(username)
        .collection('LinkRequestsNotifs');
    batch.delete(userLinkRequests.doc(myUsername));
    batch.update(firestore.collection('Users').doc(username),
        {'numOfLinkRequestsNotifs': FieldValue.increment(-1)});
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
    final Size _querySize = MediaQuery.of(context).size;
    final double _deviceHeight = _querySize.height;
    final double _deviceWidth = General.widthQuery(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final profileUnlink =
        Provider.of<MyProfile>(context, listen: false).subtractLinked;
    final profileLink =
        Provider.of<MyProfile>(context, listen: false).addLinked;
    final otherProfileFunctions =
        Provider.of<OtherProfile>(context, listen: false);
    final _link = otherProfileFunctions.linkWithUser;
    final unlinkMe = otherProfileFunctions.unlinkWithUser;
    final request = otherProfileFunctions.sendLinkRequest;
    final cancel = otherProfileFunctions.cancelLinkRequest;
    final otherProfile = Provider.of<OtherProfile>(context);
    final username = otherProfile.getUsername;
    final bool imLinkedToThem = otherProfile.imLinkedToThem;
    final bool linkRequestSent = otherProfile.linkRequestSent;
    final bool isPrivate = Provider.of<OtherProfile>(context).getVisibility ==
        TheVisibility.private;
    final bool imBlocked = Provider.of<OtherProfile>(context).imBlocked;
    final bool isBanned = Provider.of<OtherProfile>(context).isBanned;
    final Color _primaryColor = otherProfile.getPrimaryColor;
    final Color _accentColor = otherProfile.getAccentColor;
    Future<void> _unlink() =>
        unlink(username, myUsername, unlinkMe, profileUnlink);
    Future<void> _cancelRequest() =>
        cancelLinkRequest(username, myUsername, cancel);
    return ConstrainedBox(
        constraints: BoxConstraints(
            minWidth:
                ((imBlocked || isBanned) && !myUsername.startsWith('Linkspeak'))
                    ? 0
                    : _deviceWidth * 0.45,
            maxWidth:
                ((imBlocked || isBanned) && !myUsername.startsWith('Linkspeak'))
                    ? 0
                    : _deviceWidth * 0.45,
            minHeight:
                ((imBlocked || isBanned) && !myUsername.startsWith('Linkspeak'))
                    ? 0
                    : _deviceHeight * 0.001,
            maxHeight:
                ((imBlocked || isBanned) && !myUsername.startsWith('Linkspeak'))
                    ? 0
                    : _deviceHeight * 0.10),
        child: Container(
            height:
                ((imBlocked || isBanned) && !myUsername.startsWith('Linkspeak'))
                    ? 0
                    : null,
            width:
                ((imBlocked || isBanned) && !myUsername.startsWith('Linkspeak'))
                    ? 0
                    : null,
            child: TextButton(
                onPressed: () {
                  if (isLoading) {
                  } else {
                    if (imLinkedToThem) {
                      _showDialog('Unlink', _unlink);
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
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
                        backgroundColor: MaterialStateProperty.all<Color?>(_primaryColor))
                    : ButtonStyle(splashFactory: NoSplash.splashFactory, shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(side: BorderSide(color: _primaryColor), borderRadius: BorderRadius.circular(5.0))), backgroundColor: MaterialStateProperty.all<Color?>(Colors.transparent)),
                child: (isLoading)
                    ? CircularProgressIndicator(color: (imLinkedToThem) ? _accentColor : _primaryColor, strokeWidth: 1.50)
                    : Text(
                        (imLinkedToThem)
                            ? 'Linked'
                            : (linkRequestSent)
                                ? 'Requested'
                                : 'Link',
                        style: TextStyle(fontSize: 17.0, color: (imLinkedToThem) ? _accentColor : _primaryColor)))));
  }
}
