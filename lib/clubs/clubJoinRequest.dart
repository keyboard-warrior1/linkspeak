import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/chatprofileImage.dart';

class NewJoinRequest extends StatefulWidget {
  final String clubName;
  final String requestProfile;
  final void Function() decreaseNotifs;
  final void Function() addMembers;
  const NewJoinRequest(
      {required this.requestProfile,
      required this.clubName,
      required this.addMembers,
      required this.decreaseNotifs});

  @override
  _NewJoinRequestState createState() => _NewJoinRequestState();
}

class _NewJoinRequestState extends State<NewJoinRequest> {
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
      var batch = firestore.batch();
      final _myLinksCollection = firestore
          .collection('Clubs')
          .doc(widget.clubName)
          .collection('Members');
      final _myProfileDocument =
          firestore.collection('Clubs').doc(widget.clubName);
      final thisMember =
          _myLinksCollection.doc(widget.requestProfile.toString());
      final getMember = await thisMember.get();
      final _otherProfileLinkedCollection = firestore
          .collection('Users')
          .doc(widget.requestProfile.toString())
          .collection('Joined Clubs');
      final clubDoc = _otherProfileLinkedCollection.doc(widget.clubName);
      final getDoc = await clubDoc.get();
      final _otherProfileDocument =
          firestore.collection('Users').doc(widget.requestProfile.toString());
      if (!getMember.exists) {
        batch.set(thisMember, {'date': _rightNow});
        batch.update(
            _myProfileDocument, {'numOfMembers': FieldValue.increment(1)});
      }
      if (!getDoc.exists) {
        batch.set(clubDoc, {'date': _rightNow});
        batch.update(
            _otherProfileDocument, {'joinedClubs': FieldValue.increment(1)});
      }
      batch.update(
          _myProfileDocument, {'numOfJoinRequests': FieldValue.increment(-1)});
      batch.delete(_myProfileDocument
          .collection('JoinRequests')
          .doc(widget.requestProfile.toString()));
      batch.commit().then((value) {
        widget.addMembers();
        widget.decreaseNotifs();
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
      final _now = DateTime.now();
      final options = SetOptions(merge: true);
      final users = firestore.collection('Users');
      final checkExists = await General.checkExists(
          'Users/${widget.requestProfile.toString()}');
      var batch = firestore.batch();
      final _myProfileDocument =
          firestore.collection('Clubs').doc(widget.clubName);
      final _requesterProfile = users.doc(widget.requestProfile.toString());
      final _myDenied = _myProfileDocument
          .collection('Denied Requests')
          .doc(widget.requestProfile.toString());
      final _theirDenied = _requesterProfile
          .collection('Club requests denied')
          .doc(widget.clubName);
      batch.set(_myProfileDocument,
          {'Denied requests': FieldValue.increment(1)}, options);
      if (checkExists)
        batch.set(_requesterProfile,
            {'Club requests denied': FieldValue.increment(1)}, options);
      batch.set(
          _myDenied, {'times': FieldValue.increment(1), 'date': _now}, options);
      batch.set(_theirDenied, {'times': FieldValue.increment(1), 'date': _now},
          options);
      batch.update(
          _myProfileDocument, {'numOfJoinRequests': FieldValue.increment(-1)});
      batch.delete(_myProfileDocument
          .collection('JoinRequests')
          .doc(widget.requestProfile.toString()));
      batch.commit().then((value) {
        widget.decreaseNotifs();
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
    final lang = General.language(context);
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
        key: ValueKey<String>(widget.requestProfile.toString()),
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
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  recognizer: _recognizer),
              TextSpan(
                  text: lang.clubs_request1,
                  style: const TextStyle(color: Colors.black))
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
                    child: Text(lang.clubs_request2,
                        style: const TextStyle(color: Colors.white)),
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
                    child: Text(lang.clubs_request3,
                        style: const TextStyle(color: Colors.red)),
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
