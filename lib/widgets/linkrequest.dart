import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:link_speak/providers/myProfileProvider.dart';
import '../models/screenArguments.dart';
import '../routes.dart';
import 'chatprofileImage.dart';

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

      ///  My Links
      final _myLinksCollection = firestore
          .collection('Users')
          .doc(_myProfile.getUsername.toString())
          .collection('Links');
      final _myProfileDocument =
          firestore.collection('Users').doc(_myProfile.getUsername.toString());

      /// Add New Link to My Links
      batch.set(_myLinksCollection.doc(widget.requestProfile.toString()),
          {'date': _rightNow});

      /// Increment Number Of My Links
      batch.update(_myProfileDocument, {'numOfLinks': FieldValue.increment(1)});

      /// Remove Link Request Notifs
      batch.update(_myProfileDocument,
          {'numOfLinkRequestsNotifs': FieldValue.increment(-1)});
      batch.delete(_myProfileDocument
          .collection('LinkRequestsNotifs')
          .doc(widget.requestProfile.toString()));

      ///  Other Profile Linked
      final _otherProfileLinkedCollection = firestore
          .collection('Users')
          .doc(widget.requestProfile.toString())
          .collection('Linked');
      final _otherProfileDocument =
          firestore.collection('Users').doc(widget.requestProfile.toString());
      final targetUser = await _otherProfileDocument.get();
      final token = targetUser.get('fcm');

      /// Add New Linked to Other Profile Linked
      batch.set(
          _otherProfileLinkedCollection.doc(_myProfile.getUsername.toString()),
          {'date': _rightNow});

      /// Increment Number Of Other Profile Linked
      batch.update(
          _otherProfileDocument, {'numOfLinked': FieldValue.increment(1)});

      /// Add New Link Notifs Link to Other Profile
      final _newlinkedCollection = firestore
          .collection('Users')
          .doc(widget.requestProfile.toString())
          .collection('NewLinkedNotifs')
          .doc(_myProfile.getUsername.toString());
      if (targetUser.data()!.containsKey('AllowLinked')) {
        final allowLinked = targetUser.get('AllowLinked');
        if (allowLinked) {
          batch.update(_otherProfileDocument,
              {'numOfNewLinkedNotifs': FieldValue.increment(1)});
          batch.set(_newlinkedCollection, {
            'user': _myProfile.getUsername.toString(),
            'token': token,
            'date': _rightNow,
          });
        }
      } else {
        batch.update(_otherProfileDocument,
            {'numOfNewLinkedNotifs': FieldValue.increment(1)});
        batch.set(_newlinkedCollection, {
          'user': _myProfile.getUsername.toString(),
          'token': token,
          'date': _rightNow,
        });
      }
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

      /// My Profile Document
      final _myProfileDocument =
          firestore.collection('Users').doc(_myProfile.getUsername.toString());

      /// Remove Link Request
      batch.update(_myProfileDocument,
          {'numOfLinkRequestsNotifs': FieldValue.increment(-1)});
      batch.delete(_myProfileDocument
          .collection('LinkRequestsNotifs')
          .doc(widget.requestProfile.toString()));
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
    final Color _primaryColor = Theme.of(context).primaryColor;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    void _visitProfile() {
      if ((widget.requestProfile == myUsername)) {
      } else {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: widget.requestProfile);
        Navigator.pushNamed(
          context,
          RouteGenerator.posterProfileScreen,
          arguments: args,
        );
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
          asset: null,
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.requestProfile}',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              recognizer: _recognizer,
            ),
            const TextSpan(
              text: ' wants to link with you',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: (_isLoading || _isAccepted || _isDenied)
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (!_isLoading && !_isAccepted && !_isDenied)
            TextButton(
              onPressed: () => _acceptRequest(context),
              child: const Text(
                'Accept',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder?>(
                  RoundedRectangleBorder(
                    side: BorderSide(color: _primaryColor),
                    borderRadius: BorderRadius.circular(
                      5.0,
                    ),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color?>(
                  _primaryColor,
                ),
              ),
            ),
          if (!_isLoading && !_isAccepted && !_isDenied)
            const SizedBox(
              width: 5.0,
            ),
          if (_isLoading && !_isAccepted && !_isDenied)
            const CircularProgressIndicator(),
          if (!_isLoading && _isAccepted && !_isDenied)
            Container(
              height: 25.0,
              width: 25.0,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: _primaryColor,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  color: _primaryColor,
                ),
              ),
            ),
          if (!_isLoading && !_isAccepted && _isDenied)
            Container(
              height: 25.0,
              width: 25.0,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.red,
                ),
              ),
              child: const Center(
                child: Icon(Icons.cancel_outlined, color: Colors.red),
              ),
            ),
          if (!_isLoading && !_isAccepted && !_isDenied)
            TextButton(
              onPressed: () => _denyRequest(context),
              child: const Text(
                'Deny',
                style: TextStyle(color: Colors.red),
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder?>(
                  RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(
                      5.0,
                    ),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color?>(
                  Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
