import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/chatprofileImage.dart';

class NewLinkRequest extends StatefulWidget {
  final String requestProfile;
  const NewLinkRequest({required this.requestProfile});

  @override
  _NewLinkRequestState createState() => _NewLinkRequestState();
}

class _NewLinkRequestState extends State<NewLinkRequest> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();
  bool _isLoading = false;
  bool _isAccepted = false;
  bool _isDenied = false;
  Future<void> _acceptRequest(BuildContext context) async {
    if (_isLoading) {
    } else {
      setState(() {
        _isLoading = true;
      });
      final DateTime _rightNow = DateTime.now();
      final _myProfile = context.read<MyProfile>();
      final void Function() decreaseNotifs =
          Provider.of<MyProfile>(context, listen: false).decreaseLinkRequests;
      final void Function() addLinks =
          Provider.of<MyProfile>(context, listen: false).addLinks;
      var batch = firestore.batch();
      final users = firestore.collection('Users');
      final _myProfileDocument = users.doc(_myProfile.getUsername.toString());
      final _myLinksCollection = _myProfileDocument.collection('Links');
      final thisLink = _myLinksCollection.doc(widget.requestProfile.toString());
      final getlink = await thisLink.get();
      final _otherProfileLinkedCollection =
          users.doc(widget.requestProfile.toString()).collection('Linked');
      final myLinkedDoc =
          _otherProfileLinkedCollection.doc(_myProfile.getUsername.toString());
      final getDoc = await myLinkedDoc.get();
      final _otherProfileDocument =
          firestore.collection('Users').doc(widget.requestProfile.toString());
      final targetUser = await _otherProfileDocument.get();
      final token = targetUser.get('fcm');
      if (!getlink.exists) {
        batch.set(thisLink, {'date': _rightNow});
        batch.update(
            _myProfileDocument, {'numOfLinks': FieldValue.increment(1)});
      }
      if (!getDoc.exists) {
        batch.set(myLinkedDoc, {'date': _rightNow});
        batch.update(
            _otherProfileDocument, {'numOfLinked': FieldValue.increment(1)});
      }
      final _newlinkedCollection = firestore
          .collection('Users')
          .doc(widget.requestProfile.toString())
          .collection('NewLinkedNotifs')
          .doc(_myProfile.getUsername.toString());
      batch.delete(_myProfileDocument
          .collection('LinkRequestsNotifs')
          .doc(widget.requestProfile.toString()));
      batch.update(_myProfileDocument,
          {'numOfLinkRequestsNotifs': FieldValue.increment(-1)});
      final status = targetUser.get('Status');
      if (status != 'Banned') {
        if (targetUser.data()!.containsKey('AllowLinked')) {
          final allowLinked = targetUser.get('AllowLinked');
          if (allowLinked) {
            batch.update(_otherProfileDocument,
                {'numOfNewLinkedNotifs': FieldValue.increment(1)});
            batch.set(_newlinkedCollection, {
              'user': _myProfile.getUsername.toString(),
              'recipient': widget.requestProfile.toString(),
              'token': token,
              'date': _rightNow,
            });
          }
        } else {
          batch.update(_otherProfileDocument,
              {'numOfNewLinkedNotifs': FieldValue.increment(1)});
          batch.set(_newlinkedCollection, {
            'user': _myProfile.getUsername.toString(),
            'recipient': widget.requestProfile.toString(),
            'token': token,
            'date': _rightNow,
          });
        }
      }
      Map<String, dynamic> fields = {'links accepted': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'date': _rightNow};
      General.updateControl(
          fields: fields,
          myUsername: _myProfile.getUsername.toString(),
          collectionName: 'links accepted',
          docID: widget.requestProfile.toString(),
          docFields: docFields);
      batch.commit().then((value) {
        addLinks();
        decreaseNotifs();
        setState(() {
          _isAccepted = true;
          _isLoading = false;
        });
      });
    }
  }

  _denyRequest(BuildContext context) async {
    if (_isLoading) {
    } else {
      setState(() {
        _isLoading = true;
      });
      final _myProfile = context.read<MyProfile>();
      final void Function() decreaseNotifs =
          Provider.of<MyProfile>(context, listen: false).decreaseLinkRequests;
      var batch = firestore.batch();
      final _now = DateTime.now();
      final options = SetOptions(merge: true);
      final users = firestore.collection('Users');
      final _myProfileDocument = users.doc(_myProfile.getUsername.toString());
      final _requesterProfile = users.doc(widget.requestProfile.toString());
      final checkExists = await General.checkExists(
          'Users/${widget.requestProfile.toString()}');
      final _myDenied = _myProfileDocument
          .collection('Denied Requests')
          .doc(widget.requestProfile.toString());
      final _theirDenied = _requesterProfile
          .collection('Requests Denied')
          .doc(_myProfile.getUsername.toString());
      batch.set(_myProfileDocument,
          {'Denied requests': FieldValue.increment(1)}, options);
      if (checkExists)
        batch.set(_requesterProfile,
            {'Requests denied': FieldValue.increment(1)}, options);
      batch.set(
          _myDenied, {'times': FieldValue.increment(1), 'date': _now}, options);
      batch.set(_theirDenied, {'times': FieldValue.increment(1), 'date': _now},
          options);
      batch.update(_myProfileDocument,
          {'numOfLinkRequestsNotifs': FieldValue.increment(-1)});
      batch.delete(_myProfileDocument
          .collection('LinkRequestsNotifs')
          .doc(widget.requestProfile.toString()));
      Map<String, dynamic> fields = {'links denied': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'date': _now};
      General.updateControl(
          fields: fields,
          myUsername: _myProfile.getUsername.toString(),
          collectionName: 'links denied',
          docID: widget.requestProfile.toString(),
          docFields: docFields);
      batch.commit().then((value) {
        decreaseNotifs();
        setState(() {
          _isDenied = true;
          _isLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _recognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    void _visitProfile() {
      if ((widget.requestProfile == myUsername)) {
      } else {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: widget.requestProfile);
        Navigator.pushNamed(context, RouteGenerator.posterProfileScreen,
            arguments: args);
      }
    }

    _recognizer..onTap = _visitProfile;
    return ListTile(
        leading: GestureDetector(
            onTap: _visitProfile,
            child: ChatProfileImage(
                username: '${widget.requestProfile}',
                factor: 0.05,
                inEdit: false,
                asset: null)),
        title: RichText(
            softWrap: true,
            text: TextSpan(children: [
              TextSpan(
                  text: '${widget.requestProfile}',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  recognizer: _recognizer),
              const TextSpan(
                  text: ' wants to link with you',
                  style: TextStyle(color: Colors.black))
            ])),
        trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: (_isLoading || _isAccepted || _isDenied)
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (!_isLoading && !_isAccepted && !_isDenied)
                TextButton(
                    onPressed: () => _acceptRequest(context),
                    child: const Text('Accept',
                        style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder?>(
                            RoundedRectangleBorder(
                                side: BorderSide(color: _primaryColor),
                                borderRadius: BorderRadius.circular(5.0))),
                        backgroundColor:
                            MaterialStateProperty.all<Color?>(_primaryColor))),
              if (!_isLoading && !_isAccepted && !_isDenied)
                const SizedBox(width: 5.0),
              if (_isLoading && !_isAccepted && !_isDenied)
                const CircularProgressIndicator(strokeWidth: 1.50),
              if (!_isLoading && _isAccepted && !_isDenied)
                Container(
                    height: 25.0,
                    width: 25.0,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: _primaryColor)),
                    child:
                        Center(child: Icon(Icons.check, color: _primaryColor))),
              if (!_isLoading && !_isAccepted && _isDenied)
                Container(
                    height: 25.0,
                    width: 25.0,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.red)),
                    child: const Center(
                        child: Icon(Icons.cancel_outlined, color: Colors.red))),
              if (!_isLoading && !_isAccepted && !_isDenied)
                TextButton(
                    onPressed: () => _denyRequest(context),
                    child:
                        const Text('Deny', style: TextStyle(color: Colors.red)),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder?>(
                            RoundedRectangleBorder(
                                side: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(5.0))),
                        backgroundColor: MaterialStateProperty.all<Color?>(
                            Colors.transparent)))
            ]));
  }
}
