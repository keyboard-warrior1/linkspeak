import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/flare.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/flareCollectionHelper.dart';
import '../providers/fullFlareHelper.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../widgets/auth/reportDialog.dart';
import '../widgets/share/shareWidget.dart';
import 'flareComments.dart';
import 'flareLikes.dart';
import 'flareViews.dart';
// import 'flareTimer.dart';

class FlareBaseline extends StatefulWidget {
  const FlareBaseline();

  @override
  State<FlareBaseline> createState() => _FlareBaselineState();
}

class _FlareBaselineState extends State<FlareBaseline> {
  late PersistentBottomSheetController? _shareController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool likeLoading = false;

  Future<void> muteProfile(
      String username, String myUsername, void Function(bool) setMute) async {
    setMute(true);
    var batch = firestore.batch();
    final users = firestore.collection('Users');
    final myUser = users.doc(myUsername);
    final myMuted = myUser.collection('Muted').doc(username);
    final now = DateTime.now();
    batch.set(myMuted, {'date': now}, SetOptions(merge: true));
    batch.set(
        myUser, {'muted': FieldValue.increment(1)}, SetOptions(merge: true));
    Map<String, dynamic> fields = {'muted': FieldValue.increment(1)};
    Map<String, dynamic> docFields = {'date': now};
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'muted',
        docID: '$username',
        docFields: docFields);
    final checkExists = await General.checkExists('Flares/$username');
    if (checkExists) {
      var thisFlareUser = firestore.doc('Flares/$username');
      var myMutedBy = firestore.doc('Flares/$username/Muted by/$myUsername');
      var options = SetOptions(merge: true);
      batch.set(thisFlareUser, {'muted by': FieldValue.increment(1)}, options);
      batch.set(myMutedBy, {'date': now}, options);
    }
    return batch.commit().then((value) {}).catchError((_) {
      setMute(false);
    });
  }

  Future<void> unmuteProfile(
      String username, String myUsername, void Function(bool) setMute) async {
    setMute(false);
    var batch = firestore.batch();
    final users = firestore.collection('Users');
    final myUser = users.doc(myUsername);
    final myMuted = myUser.collection('Muted').doc(username);
    final myUnmuted = myUser.collection('Unmuted').doc(username);
    final now = DateTime.now();
    var options = SetOptions(merge: true);
    batch.delete(myMuted);
    batch.set(
        myUnmuted, {'date': now, 'times': FieldValue.increment(1)}, options);
    batch.set(
        myUser,
        {'muted': FieldValue.increment(-1), 'unmuted': FieldValue.increment(1)},
        SetOptions(merge: true));
    Map<String, dynamic> fields = {'unmuted': FieldValue.increment(1)};
    Map<String, dynamic> docFields = {'date': now};
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'unmuted',
        docID: '$username',
        docFields: docFields);
    final checkExists = await General.checkExists('Flares/$username');
    if (checkExists) {
      var thisFlareUser = firestore.doc('Flares/$username');
      var myMutedBy = firestore.doc('Flares/$username/Muted by/$myUsername');
      var myUnmutedBy =
          firestore.doc('Flares/$username/Unmuted by/$myUsername');
      var options = SetOptions(merge: true);
      batch.set(
          thisFlareUser,
          {
            'muted by': FieldValue.increment(-1),
            'unmuted by': FieldValue.increment(1)
          },
          options);
      batch.set(myUnmutedBy, {'date': now, 'times': FieldValue.increment(1)},
          options);
      batch.delete(myMutedBy);
    }
    return batch.commit().then((value) {}).catchError((_) {
      setMute(true);
    });
  }

  Future<void> removeFlare(
      String myUsername, String username, Flare removedFlare) async {
    final lang = General.language(context);
    EasyLoading.show(status: lang.flares_baseline1, dismissOnTap: false);
    var batch = firestore.batch();
    final flareID = removedFlare.flareID;
    final collectionID = removedFlare.collectionID;
    final _rightNow = DateTime.now();
    final timeID = _rightNow.toString();
    final myUserDoc = firestore.collection('Users').doc(username);
    final myUserFlares = myUserDoc.collection('My Flares');
    final myUserCollection = myUserFlares.doc(collectionID);
    final myFlareDoc = firestore.collection('Flares').doc(username);
    final myCollections = myFlareDoc.collection('collections');
    final currentCollection = myCollections.doc(collectionID);
    final modifications =
        currentCollection.collection('modifications').doc(timeID);
    final deletions = modifications.collection('deletions');
    final options = SetOptions(merge: true);
    final thisDeletion = deletions.doc(flareID);
    final deletedFlares = firestore.collection('Deleted Flares').doc(flareID);
    final thisFlare = currentCollection.collection('flares').doc(flareID);
    final myUserDeletionCollection =
        myUserDoc.collection('Deleted Flares').doc(collectionID);
    final myDeletedFlares =
        myUserDeletionCollection.collection('flares').doc(flareID);
    final flareDeletedFlares = myFlareDoc
        .collection('deleted')
        .doc(collectionID)
        .collection('flares')
        .doc(flareID);
    final thisProfileFlare = myUserCollection.collection('flares').doc(flareID);
    final getFlare = await thisFlare.get();
    if (getFlare.exists) {
      dynamic getter(String path) => getFlare.get(path);
      int unlikes = 0;
      final viewrs = getter('views');
      final likes = getter('likes');
      final comments = getter('comments');
      Map<String, dynamic> deletedInfo = getFlare.data()!;
      Map<String, dynamic> de = {
        'date deleted': _rightNow,
        'deleted by': myUsername
      };
      deletedInfo.addAll(de);
      if (getFlare.data()!.containsKey('unlikes')) {
        unlikes = getter('unlikes');
      }
      batch.set(
          currentCollection,
          {
            'numOfFlares': FieldValue.increment(-1),
            'deleted': FieldValue.increment(1),
            'likes': FieldValue.increment(-likes),
            'unlikes': FieldValue.increment(-unlikes),
            'comments': FieldValue.increment(-comments),
            'views': FieldValue.increment(-viewrs)
          },
          options);
      final getMyFlareDoc = await myFlareDoc.get();
      if (getMyFlareDoc.exists)
        batch.set(
            myFlareDoc,
            {
              'numOfDeletedFlares': FieldValue.increment(1),
              'numOfFlares': FieldValue.increment(-1),
              'numOfViews': FieldValue.increment(-viewrs),
              'numOfLikes': FieldValue.increment(-likes),
              'numOfUnlikes': FieldValue.increment(-unlikes),
              'numOfComments': FieldValue.increment(-comments),
            },
            options);
      final getMyUserDoc = await myUserDoc.get();
      if (getMyUserDoc.exists)
        batch.set(
            myUserDoc,
            {
              'numOfDeletedFlares': FieldValue.increment(1),
              'numOfFlares': FieldValue.increment(-1)
            },
            options);
      Map<String, dynamic> fields = {
        'flares': FieldValue.increment(-1),
        'deleted flares': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'flarePoster': username,
        'collection': collectionID,
        'flare': flareID,
        'date': _rightNow
      };
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'deleted flares',
          docID: '$flareID',
          docFields: docFields);
      batch.set(flareDeletedFlares, deletedInfo, options);
      batch.set(myDeletedFlares, deletedInfo, options);
      batch.set(deletedFlares, deletedInfo, options);
      batch.set(thisDeletion, deletedInfo, options);
      batch.delete(thisProfileFlare);
      batch.delete(thisFlare);
      batch.set(myUserDeletionCollection, {'date': _rightNow}, options);
      batch.set(myFlareDoc.collection('deleted').doc(collectionID),
          {'date': _rightNow}, options);
      batch.set(
          currentCollection,
          {
            'last modified': _rightNow,
            'modifications': FieldValue.increment(1)
          },
          options);
      batch.commit().then((value) {
        EasyLoading.showSuccess(lang.flares_baseline2,
            duration: const Duration(seconds: 2), dismissOnTap: true);
      });
    }
  }

  void showMore() {
    final lang = General.language(context);
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final helper = Provider.of<FlareHelper>(context, listen: false);
    final String poster = helper.poster;
    final String collectionID = helper.collectionID;
    final flareID = helper.flareID;
    final colHelper =
        Provider.of<FlareCollectionHelper>(context, listen: false);
    final currentFlare =
        colHelper.flares.indexWhere((element) => element.flareID == flareID);
    final isMuted = colHelper.isMuted;
    final setMute = colHelper.setIsMuted;
    final flareToRemove = colHelper.flares[currentFlare];
    showModalBottomSheet(
        context: context,
        builder: (_) {
          final ListTile _mute = ListTile(
              title: Text(
                  isMuted ? lang.flares_baseline3 : lang.flares_baseline4,
                  style: const TextStyle(color: Colors.black)),
              onTap: () {
                if (isMuted) {
                  Navigator.pop(context);
                  unmuteProfile(poster, myUsername, setMute);
                } else {
                  Navigator.pop(context);
                  muteProfile(poster, myUsername, setMute);
                }
              });
          final ListTile _report = ListTile(
              title: Text(lang.flares_baseline5,
                  style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) {
                      return ReportDialog(
                          id: poster,
                          postID: '',
                          isInProfile: false,
                          isInPost: false,
                          isInComment: false,
                          isInReply: false,
                          commentID: '',
                          isInClubScreen: false,
                          isClubPost: false,
                          clubName: '',
                          flareProfileID: '',
                          isInFlareProfile: false,
                          isInSpotlight: true,
                          spotlightID: flareID,
                          flarePoster: poster,
                          collectionID: collectionID);
                    });
              });
          final ListTile _deleteFlare = ListTile(
              title: Text(lang.flares_baseline6,
                  style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                removeFlare(myUsername, poster, flareToRemove);
              });
          final ListTile _details = ListTile(
              title: Text(lang.flares_baseline7,
                  style: const TextStyle(color: Colors.black)),
              onTap: () {
                var docPath =
                    'Flares/$poster/collections/$collectionID/flares/$flareID';
                General.getAndCopyDetails(docPath, false, context);
              });
          final Column _choices = Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _mute,
                _report,
                if (myUsername.startsWith('Linkspeak')) _details,
                if (myUsername.startsWith('Linkspeak')) _deleteFlare
              ]);

          final SizedBox _box = SizedBox(child: _choices);
          return _box;
        });
  }

  void showTheView(Widget child) {
    final _size = MediaQuery.of(context).size;
    final _height = _size.height;
    final _width = General.widthQuery(context);
    showModalBottomSheet(
        context: context,
        barrierColor: Colors.black,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10))),
        builder: (ctx) => Container(
            height: _height * 0.90,
            width: _width,
            // color: Colors.white,
            child: child));
  }

  Widget giveStacked(
          String text, bool isLikeText, Color likeColor, bool isLiked) =>
      Stack(children: <Widget>[
        Text(text,
            softWrap: false,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.25
                  ..color = Colors.black)),
        Text(text,
            softWrap: false,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLikeText && isLiked ? likeColor : Colors.white))
      ]);

  Widget buildText(String text, Widget child, bool isLikeText, Color likeColor,
          bool isLiked) =>
      GestureDetector(
          onTap: () => showTheView(child),
          child: giveStacked(text, isLikeText, likeColor, isLiked));

  Widget buildHeightBox(Widget child) => GestureDetector(
      onTap: () => showTheView(child), child: const SizedBox(height: 10));

  Widget buildIcon(IconData icon, Widget child, dynamic handler, bool isLiked,
          Widget? iconchild, Color? _likeColor) =>
      GestureDetector(
          onTap: () {
            if (icon == customIcons.MyFlutterApp.right) {
              final helper = Provider.of<FlareHelper>(context, listen: false);
              final String poster = helper.poster;
              final String collectionID = helper.collectionID;
              final flareID = helper.flareID;
              _shareController = showBottomSheet(
                  context: context,
                  builder: (context) => ShareWidget(
                      isInFeed: false,
                      bottomSheetController: _shareController,
                      postID: '',
                      clubName: '',
                      isClubPost: false,
                      isFlare: true,
                      flarePoster: poster,
                      collectionID: collectionID,
                      flareID: flareID),
                  backgroundColor: Colors.transparent);
            } else if (icon == Icons.more_horiz_rounded) {
              showMore();
            } else {
              if (handler != null)
                handler();
              else
                showTheView(child);
            }
          },
          child: Container(
              decoration: BoxDecoration(boxShadow: const [
                const BoxShadow(
                    color: Colors.black38,
                    offset: Offset(-5, 0),
                    blurRadius: 15,
                    spreadRadius: 0.5)
              ]),
              child: iconchild != null
                  ? iconchild
                  : Icon(icon,
                      color: isLiked ? _likeColor : Colors.white, size: 30)));

  Future<void> likeFlare(
      {required String myUsername,
      required String poster,
      required String collectionID,
      required String flareID,
      required void Function() statelike}) async {
    if (!likeLoading) {
      setState(() => likeLoading = true);
      statelike();
      var batch = firestore.batch();
      var notifBatch = firestore.batch();
      final options = SetOptions(merge: true);
      final _rightNow = DateTime.now();
      final users = firestore.collection('Users');
      final flares = firestore.collection('Flares');
      final myUser = users.doc(myUsername);
      final myLiked = myUser.collection('Liked Flares').doc(flareID);
      final myUnliked = myUser.collection('Unliked Flares').doc(flareID);
      final thisFlarer = flares.doc(poster);
      final thisPoster = await users.doc(poster).get();
      final token = thisPoster.get('fcm');
      final likeNotifs = thisFlarer.collection('LikeNotifs').doc();
      final thisColl = thisFlarer.collection('collections').doc(collectionID);
      final thisFlare = thisColl.collection('flares').doc(flareID);
      final thisFlareLikes = thisFlare.collection('likes').doc(myUsername);
      final getMyFlareLike = await thisFlareLikes.get();
      final isLiked = getMyFlareLike.exists;
      final thisFlareUnlikes = thisFlare.collection('unlikes').doc(myUsername);
      final myLikeInfo = {
        'date': _rightNow,
        'flareID': flareID,
        'collectionID': collectionID,
        'poster': poster
      };
      final myUnlikeInfo = {
        'likedFlares': FieldValue.increment(-1),
        'unlikedFlares': FieldValue.increment(1)
      };
      final checkExists = await thisFlare.get();
      if (checkExists.exists) {
        if (!isLiked) {
          Map<String, dynamic> fields = {
            'flare likes': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'poster': poster,
            'collection': collectionID,
            'flare': flareID,
            'date': _rightNow
          };
          General.updateControl(
              fields: fields,
              myUsername: myUsername,
              collectionName: 'flare likes',
              docID: '$flareID',
              docFields: docFields);
          batch.set(myUser, {'likedFlares': FieldValue.increment(1)}, options);
          batch.set(myLiked, myLikeInfo, options);
          batch.set(thisColl, {'likes': FieldValue.increment(1)}, options);
          batch.set(thisFlareLikes, {'date': _rightNow}, options);
          batch.set(thisFlare, {'likes': FieldValue.increment(1)}, options);
          batch.set(
              thisFlarer, {'numOfLikes': FieldValue.increment(1)}, options);
          if (poster != myUsername) {
            final notifData = {
              'recipient': poster,
              'collectionID': '$collectionID',
              'flareID': '$flareID',
              'user': myUsername,
              'token': token,
              'date': _rightNow,
            };
            final status = thisPoster.get('Status');
            if (status != 'Banned') {
              if (thisPoster.data()!.containsKey('AllowFlareLikes')) {
                final allowLikes = thisPoster.get('AllowFlareLikes');
                if (allowLikes) {
                  notifBatch.set(likeNotifs, notifData, options);
                  notifBatch.set(thisFlarer,
                      {'likeNotifs': FieldValue.increment(1)}, options);
                }
              } else {
                notifBatch.set(thisFlarer,
                    {'likeNotifs': FieldValue.increment(1)}, options);
                notifBatch.set(likeNotifs, notifData, options);
              }
            }
          }
        } else {
          batch.set(myUser, myUnlikeInfo, options);
          batch.delete(myLiked);
          batch.set(myUnliked, myLikeInfo, options);

          Map<String, dynamic> fields = {
            'flare likes': FieldValue.increment(-1),
            'flare unlikes': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'poster': poster,
            'collection': collectionID,
            'flare': flareID,
            'date': _rightNow
          };
          General.updateControl(
              fields: fields,
              myUsername: myUsername,
              collectionName: 'flare unlikes',
              docID: '$flareID',
              docFields: docFields);
          batch.delete(thisFlareLikes);
          batch.set(thisColl, {'likes': FieldValue.increment(-1)}, options);
          batch.set(thisColl, {'unlikes': FieldValue.increment(1)}, options);
          batch.set(thisFlareUnlikes, {'date': _rightNow}, options);
          batch.set(
              thisFlare,
              {
                'likes': FieldValue.increment(-1),
                'unlikes': FieldValue.increment(1)
              },
              options);
          batch.set(
              thisFlarer, {'numOfLikes': FieldValue.increment(-1)}, options);
          batch.set(
              thisFlarer, {'numOfUnlikes': FieldValue.increment(1)}, options);
        }
        return batch.commit().then((value) {
          notifBatch.commit();
          setState(() => likeLoading = false);
        }).catchError((_) {
          statelike();
          setState(() => likeLoading = false);
        });
      } else {
        setState(() => likeLoading = false);
      }
    }
  }

  Widget buildIconButton(void Function() likeHandler, bool isLiked,
          File? activePath, File? inactivePath) =>
      IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: likeHandler,
          icon: Image.file(isLiked ? activePath! : inactivePath!));

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final themeHelper = Provider.of<ThemeModel>(context);
    final helper = Provider.of<FlareHelper>(context);
    final helperNo = Provider.of<FlareHelper>(context, listen: false);
    final colHelper =
        Provider.of<FlareCollectionHelper>(context, listen: false);
    final flareID = helper.flareID;
    final currentFlare =
        colHelper.flares.indexWhere((element) => element.flareID == flareID);
    final instance = colHelper.flares[currentFlare].instance;
    final setComments = helperNo.setComments;
    final currentIconName = themeHelper.selectedIconName;
    final currentIcon = themeHelper.themeIcon;
    final active = themeHelper.activeLikeFile;
    final inactive = themeHelper.inactiveLikeFile;
    final _likeColor = themeHelper.likeColor;
    final poster = helper.poster;
    final collectionID = helper.collectionID;
    final isLiked = helper.likedByMe;
    final statelike = helper.like;
    final numOfLikes = helper.numOfLikes;
    final bool hasLikes = numOfLikes > 0;
    final optimLikes = General.optimisedNumbers(numOfLikes);
    final numOfComments = helper.numOfComments;
    final bool hasComments = numOfComments > 0;
    final optimComments = General.optimisedNumbers(numOfComments);
    final numOfViews = helper.numOfViewers;
    final bool hasViews = numOfViews > 0;
    final optimViews = General.optimisedNumbers(numOfViews);
    const _heightBox = const SizedBox(height: 10);
    final flareLikes = FlareLikes(
        poster: poster,
        collectionID: collectionID,
        flareID: flareID,
        numOfLikes: numOfLikes);
    final flareComments = FlareComments(
        poster: poster,
        collectionID: collectionID,
        flareID: flareID,
        numOfComments: numOfComments,
        setComments: setComments,
        instance: instance,
        section: Section.multiple,
        singleCommentID: '');
    final flareViewers = FlareViews(
        poster: poster,
        collectionID: collectionID,
        flareID: flareID,
        numOfViews: numOfViews);
    likeHandler() {
      likeFlare(
          myUsername: myUsername,
          poster: poster,
          collectionID: collectionID,
          flareID: flareID,
          statelike: statelike);
    }

    return Align(
        alignment: Alignment.centerRight,
        child: Container(
            height: _height,
            margin: const EdgeInsets.only(bottom: 230),
            width: 75,
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  buildIcon(
                      currentIcon,
                      flareLikes,
                      likeHandler,
                      isLiked,
                      currentIconName != 'Custom'
                          ? null
                          : buildIconButton(
                              likeHandler, isLiked, active, inactive),
                      _likeColor),
                  buildHeightBox(flareLikes),
                  if (hasLikes)
                    buildText(
                        optimLikes, flareLikes, true, _likeColor, isLiked),
                  _heightBox,
                  buildIcon(Icons.chat_bubble_outline_rounded, flareComments,
                      null, false, null, _likeColor),
                  buildHeightBox(flareComments),
                  if (hasComments)
                    buildText(
                        optimComments, flareComments, false, _likeColor, false),
                  _heightBox,
                  buildIcon(Icons.play_arrow_outlined, flareViewers, null,
                      false, null, _likeColor),
                  buildHeightBox(flareViewers),
                  if (hasViews)
                    buildText(
                        optimViews, flareViewers, false, _likeColor, false),
                  _heightBox,
                  if (myUsername != poster)
                    buildIcon(Icons.more_horiz_rounded, flareViewers, null,
                        false, null, _likeColor),
                  if (myUsername != poster) _heightBox,
                  buildIcon(customIcons.MyFlutterApp.right, flareViewers, null,
                      false, null, _likeColor)
                  // _heightBox,
                  // const FlareTimer(),
                ])));
  }
}
