// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/misc/videoPlayer.dart';
import 'flareBaseline.dart';

class FullFlare extends StatefulWidget {
  final String poster;
  final String collectionID;
  final String flareID;
  final String mediaURL;
  final bool isShown;
  final bool isImage;
  final Color backgroundColor;
  final Color gradientColor;
  final void Function() viewIt;
  const FullFlare(
      {required this.poster,
      required this.collectionID,
      required this.flareID,
      required this.mediaURL,
      required this.isImage,
      required this.isShown,
      required this.viewIt,
      required this.backgroundColor,
      required this.gradientColor});
  @override
  State<FullFlare> createState() => _FullFlareState();
}

class _FullFlareState extends State<FullFlare> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String sessionID = '';
  String myName = '';
  late Future<void> _viewFlare;
  late Future<void> _initSession;
  late Future<void> _endSession;

  Widget buildAnimatedOpacity(Widget child) => AnimatedOpacity(
      duration: kThemeAnimationDuration,
      opacity: widget.isShown ? 1 : 0,
      child: child);

  Widget buildFlare(String mediaURL, bool isImage) {
    if (isImage)
      return ExtendedImage.network(mediaURL,
          fit: BoxFit.contain,
          printError: false,
          enableLoadState: true,
          handleLoadingProgress: true);
    else
      return Center(
          child: Container(
              color: Colors.black,
              child: MyVideoPlayer(mediaURL, true, false)));
  }

  Future<void> initSession(String myUsername, String poster,
      String collectionID, String flareID) async {
    var batch = firestore.batch();
    final _rightNow = DateTime.now();
    final flaresCollection = firestore.collection('Flares');
    final flarePoster = flaresCollection.doc(poster);
    final thisCollection =
        flarePoster.collection('collections').doc(collectionID);
    final thisFlare = thisCollection.collection('flares').doc(flareID);
    final flareViewr = thisFlare.collection('views').doc(myUsername);
    final getFlare = await thisFlare.get();
    final exists = getFlare.exists;
    if (exists) {
      final sessions = thisFlare.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final myFlareSessions = flareViewr.collection('Sessions');
      final thisSession = myFlareSessions.doc(sessionID);
      final hasSession = mySession.exists;
      final options = SetOptions(merge: true);
      batch.set(
          flareViewr,
          {'last viewed': _rightNow, 'times': FieldValue.increment(1)},
          options);
      if (!hasSession) {
        batch.set(thisSession, {'start': _rightNow}, options);
        batch.set(sessions.doc(myUsername), {'start': _rightNow}, options);
        batch.set(thisFlare, {'sessions': FieldValue.increment(1)}, options);
      }
    }
    return batch.commit();
  }

  Future<void> endSession(String myUsername, String poster, String collectionID,
      String flareID) async {
    final _rightNow = DateTime.now();
    var batch = firestore.batch();
    final options = SetOptions(merge: true);
    final flaresCollection = firestore.collection('Flares');
    final flarePoster = flaresCollection.doc(poster);
    final thisCollection =
        flarePoster.collection('collections').doc(collectionID);
    final thisFlare = thisCollection.collection('flares').doc(flareID);
    final getFlare = await thisFlare.get();
    final exists = getFlare.exists;
    if (exists) {
      final flarerViewers = thisFlare.collection('Viewers');
      final myFlareSessions =
          flarerViewers.doc(myUsername).collection('Sessions');
      final thisSession = await myFlareSessions.doc(sessionID).get();
      final thisSessionExists = thisSession.exists;
      final sessions = thisFlare.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final hasSession = mySession.exists;
      if (hasSession) {
        batch.delete(sessions.doc(myUsername));
        batch.set(thisFlare, {'sessions': FieldValue.increment(-1)}, options);
      }
      if (thisSessionExists) {
        batch.set(myFlareSessions.doc(sessionID), {'end': _rightNow}, options);
      }
    }
    return batch.commit();
  }

  Future<void> viewFlare(String myUsername) async {
    final bool imManagement = myUsername.startsWith('Linkspeak');
    var batch = firestore.batch();
    final options = SetOptions(merge: true);
    final _rightNow = DateTime.now();
    final seshID = _rightNow.toString();
    sessionID = seshID;
    final users = firestore.collection('Users');
    final flares = firestore.collection('Flares');
    final myUser = users.doc(myUsername);
    final flarer = flares.doc('${widget.poster}');
    final coll = flarer.collection('collections').doc('${widget.collectionID}');
    final thisFlare = coll.collection('flares').doc('${widget.flareID}');
    final getFlare = await thisFlare.get();
    final exists = getFlare.exists;
    final collViews = coll.collection('Viewers');
    final myCollView = collViews.doc(myUsername);
    final getCollView = await myCollView.get();
    final seenColl = getCollView.exists;
    final flareViewr = thisFlare.collection('views').doc(myUsername);
    final getView = await flareViewr.get();
    final seen = getView.exists;
    final history = myUser.collection('Flare History').doc(widget.flareID);
    final myViewed = myUser.collection('Viewed Flares').doc(widget.flareID);
    final info = {
      'poster': widget.poster,
      'collectionID': widget.collectionID,
      'flareID': widget.flareID,
      'date': _rightNow,
      'times': FieldValue.increment(1)
    };
    if (exists) {
      if (!seen && widget.poster != myUsername) {
        if (!imManagement) {
          batch.set(flarer, {'numOfViews': FieldValue.increment(1)}, options);
          batch.set(thisFlare, {'views': FieldValue.increment(1)}, options);
          batch.set(flareViewr,
              {'date': _rightNow, 'times': FieldValue.increment(1)}, options);
        }
        if (!seenColl) {
          batch.set(coll, {'views': FieldValue.increment(1)}, options);
          batch.set(myCollView, {'date': _rightNow}, options);
        }
        widget.viewIt();
      }
      batch.set(myUser, {'seen flares': FieldValue.increment(1)}, options);
    }
    batch.set(history, info, options);
    batch.set(myViewed, info, options);
    Map<String, dynamic> fields = {'viewed flares': FieldValue.increment(1)};
    Map<String, dynamic> docFields = {
      'poster': widget.poster,
      'collection': widget.collectionID,
      'flare': widget.flareID,
      'date': _rightNow,
      'times': FieldValue.increment(1)
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'viewed flares',
        docID: widget.flareID,
        docFields: docFields);
    return batch.commit().then((value) {
      _initSession = initSession(
          myUsername, widget.poster, widget.collectionID, widget.flareID);
    });
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    myName = myUsername;
    _viewFlare = viewFlare(myUsername);
  }

  @override
  void dispose() {
    super.dispose();
    _endSession =
        endSession(myName, widget.poster, widget.collectionID, widget.flareID);
  }

  @override
  Widget build(BuildContext context) => Stack(children: <Widget>[
        ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        tileMode: TileMode.clamp,
                        colors: [
                      widget.gradientColor,
                      widget.backgroundColor
                    ])),
                child: buildFlare(widget.mediaURL, widget.isImage))),
        buildAnimatedOpacity(const FlareBaseline())
      ]);
}
