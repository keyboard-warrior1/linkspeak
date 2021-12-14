import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../providers/myProfileProvider.dart';
import '../providers/otherProfileProvider.dart';

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
                      message,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        fontFamily: 'Roboto',
                        fontSize: 21.0,
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
                          onPressed: () {
                            Navigator.pop(context);
                            handler();
                          },
                          child: Text(
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
                          child: Text(
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
  }

  Future<void> link(String username, String myUsername, void Function() link,
      void Function() profileLink) async {
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
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
      batch.set(userLinks.doc(myUsername), {'0': 1});
      batch.set(myLinked.doc(username), {'0': 1});
      if (targetUser.data()!.containsKey('AllowLinks')) {
        final allowLinks = targetUser.get('AllowLinks');
        if (allowLinks) {
          batch.set(userLinksNotifs.doc(myUsername), {
            'user': myUsername,
            'token': token,
          });
          batch.update(firestore.collection('Users').doc(username),
              {'numOfNewLinksNotifs': FieldValue.increment(1)});
        }
      } else {
        batch.set(userLinksNotifs.doc(myUsername), {
          'user': myUsername,
          'token': token,
        });
        batch.update(firestore.collection('Users').doc(username),
            {'numOfNewLinksNotifs': FieldValue.increment(1)});
      }
      batch.update(firestore.collection('Users').doc(username),
          {'numOfLinks': FieldValue.increment(1)});
      batch.update(firestore.collection('Users').doc(myUsername),
          {'numOfLinked': FieldValue.increment(1)});
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
      final userLinks =
          firestore.collection('Users').doc(username).collection('Links');
      final myLinked =
          firestore.collection('Users').doc(myUsername).collection('Linked');
      batch.delete(userLinks.doc(myUsername));
      batch.update(firestore.collection('Users').doc(username),
          {'numOfLinks': FieldValue.increment(-1)});
      batch.delete(myLinked.doc(username));
      batch.update(firestore.collection('Users').doc(myUsername),
          {'numOfLinked': FieldValue.increment(-1)});
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
        'token': token,
      });
      batch.update(firestore.collection('Users').doc(username),
          {'numOfLinkRequestsNotifs': FieldValue.increment(1)});
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
    final double _deviceWidth = _querySize.width;
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
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    Future<void> _unlink() =>
        unlink(username, myUsername, unlinkMe, profileUnlink);
    Future<void> _cancelRequest() =>
        cancelLinkRequest(username, myUsername, cancel);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: (imBlocked && !myUsername.startsWith('Linkspeak'))
            ? 0
            : _deviceWidth * 0.45,
        maxWidth: (imBlocked && !myUsername.startsWith('Linkspeak'))
            ? 0
            : _deviceWidth * 0.45,
        minHeight: (imBlocked && !myUsername.startsWith('Linkspeak'))
            ? 0
            : _deviceHeight * 0.001,
        maxHeight: (imBlocked && !myUsername.startsWith('Linkspeak'))
            ? 0
            : _deviceHeight * 0.10,
      ),
      child: Container(
        height: (imBlocked && !myUsername.startsWith('Linkspeak')) ? 0 : null,
        width: (imBlocked && !myUsername.startsWith('Linkspeak')) ? 0 : null,
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
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        15.0,
                      ),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color?>(
                    _primaryColor,
                  ),
                )
              : ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  shape: MaterialStateProperty.all<OutlinedBorder?>(
                    RoundedRectangleBorder(
                      side: BorderSide(color: _primaryColor),
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color?>(
                    Colors.transparent,
                  ),
                ),
          child: (isLoading)
              ? CircularProgressIndicator(
                  color: (imLinkedToThem) ? _accentColor : _primaryColor)
              : Text(
                  (imLinkedToThem)
                      ? 'Linked'
                      : (linkRequestSent)
                          ? 'Requested'
                          : 'Link',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: (imLinkedToThem) ? _accentColor : _primaryColor),
                ),
        ),
      ),
    );
  }
}
