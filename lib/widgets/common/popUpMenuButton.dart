// ignore_for_file: body_might_complete_normally_nullable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/generalAdmin.dart';
import '../../admin/widgets/Misc/banDialog.dart';
import '../../admin/widgets/Misc/prohibitDialog.dart';
import '../../general.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/myProfileProvider.dart';
import '../auth/reportDialog.dart';
import '../snackbar/blockSnack.dart';
import '../snackbar/deleteSnack.dart';
import '../snackbar/favSnack.dart';
import '../snackbar/hiddenPostSnack.dart';
import '../snackbar/removedSnack.dart';
import 'load.dart';

class MyPopUpMenuButton extends StatefulWidget {
  final String id;
  final String postID;
  final String clubName;
  final bool postedByMe;
  final bool isInProfile;
  final bool isInClubScreen;
  final bool isBlocked;
  final bool isBanned;
  final bool isLinkedToMe;
  final bool isFav;
  final bool isClubPost;
  final bool isMod;
  final bool isInFlareProfile;
  final String flareProfileID;
  final bool isProhibited;
  final List<String> postTopics;
  final List<String> postMedia;
  final DateTime postDate;
  final dynamic block;
  final dynamic banUser;
  final dynamic unbanUser;
  final dynamic unblock;
  final dynamic remove;
  final dynamic hidePost;
  final dynamic deletePost;
  final dynamic prohibitClub;
  final dynamic unhidePost;
  final dynamic helperFav;
  final dynamic previewSetstate;
  const MyPopUpMenuButton(
      {required this.id,
      required this.postID,
      required this.clubName,
      required this.postedByMe,
      required this.isInProfile,
      required this.isInClubScreen,
      required this.prohibitClub,
      required this.isFav,
      required this.isProhibited,
      required this.postTopics,
      required this.postMedia,
      required this.postDate,
      required this.isBlocked,
      required this.isBanned,
      required this.isLinkedToMe,
      required this.isClubPost,
      required this.isInFlareProfile,
      required this.flareProfileID,
      required this.isMod,
      required this.block,
      required this.unblock,
      required this.remove,
      required this.hidePost,
      required this.deletePost,
      required this.unhidePost,
      required this.helperFav,
      required this.previewSetstate,
      required this.banUser,
      required this.unbanUser});

  @override
  _MyPopUpMenuButtonState createState() => _MyPopUpMenuButtonState();
}

class _MyPopUpMenuButtonState extends State<MyPopUpMenuButton> {
  bool linkRemoved = false;
  bool isBlocked = false;
  bool isUnBlocked = false;
  bool isDeleted = false;
  void _showIt(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (_) {
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: const Load());
        });
  }

  Future<void> profileClubDetails() async {
    var firestore = FirebaseFirestore.instance;
    var clubDoc = firestore.doc('Clubs/${widget.id}');
    var userDoc = firestore.doc('Users/${widget.id}');
    var doc = widget.isInClubScreen ? await clubDoc.get() : await userDoc.get();
    GeneralAdmin.displayDocDetails(
        context: context,
        doc: doc,
        actionLabel: '',
        actionHandler: () {},
        docAddress:
            widget.isInClubScreen ? 'Clubs/${widget.id}' : 'Users/${widget.id}',
        resolvedCollection: '',
        resolveDocID: doc.id,
        showActionButton: false,
        showCopyButton: true,
        showDeleteButton: false);
  }

  Future<void> addToWatchlist(String myUsername) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    var usersCollection = firestore.collection('User watchlist').doc(widget.id);
    var clubCollection = firestore.collection('Club watchlist').doc(widget.id);
    var options = SetOptions(merge: true);
    var data = {'date added': DateTime.now(), 'added by': myUsername};
    if (widget.isInClubScreen)
      batch.set(clubCollection, data, options);
    else
      batch.set(usersCollection, data, options);
    return batch.commit().then((value) {
      Navigator.pop(context);
    });
  }

  Future<void> unProhibitClub(
      String myUsername, void Function(bool) unprohibit) async {
    _showIt(context);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final usersCollection = firestore.collection('Clubs');
    final bannedCollection = firestore.collection('Prohibited Clubs');
    final thisUser = usersCollection.doc(widget.id);
    final thisBannedUser = bannedCollection.doc(widget.id);
    Map<String, dynamic> fields = {'prohibited clubs': FieldValue.increment(1)};
    Map<String, dynamic> docFields = {
      'date': DateTime.now(),
      'clubName': widget.id
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'prohibited clubs',
        docID: '${widget.id}',
        docFields: docFields);
    batch.update(thisUser, {'isProhibited': false});
    batch.set(
        thisBannedUser,
        {
          'isBanned': false,
          'unban date': DateTime.now(),
          'unbanned by': myUsername
        },
        SetOptions(merge: true));
    return batch.commit().then((value) {
      Future.delayed(const Duration(milliseconds: 10), () {
        unprohibit(false);
      });
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  Future<void> unbanUser(String myUsername, void Function() unban) async {
    _showIt(context);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final now = DateTime.now();
    final usersCollection = firestore.collection('Users');
    final bannedCollection = firestore.collection('Banned');
    final thisUser = usersCollection.doc(widget.id);
    final thisBannedUser = bannedCollection.doc(widget.id);
    final getBannedUser = await thisBannedUser.get();
    final bannedBy = getBannedUser.get('banned by');
    final reason = getBannedUser.get('reason');
    final banDate = getBannedUser.get('ban date');
    final duration = getBannedUser.get('duration');
    batch.update(thisUser, {'Status': 'Allowed'});
    batch.set(
        thisBannedUser,
        {'isBanned': false, 'unban date': now, 'unbanned by': myUsername},
        SetOptions(merge: true));
    Map<String, dynamic> fields = {
      'banned users': FieldValue.increment(-1),
      'users unbanned': FieldValue.increment(1)
    };
    Map<String, dynamic> docFields = {
      'unban date': now,
      'banned by': bannedBy,
      'reason': reason,
      'ban date': banDate,
      'duration': duration
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'users unbanned',
        docID: widget.id,
        docFields: docFields);
    return batch.commit().then((value) {
      Future.delayed(const Duration(milliseconds: 10), () {
        unban();
      });
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  Future<void>? blockUser(
      BuildContext context,
      String myUsername,
      void Function(String) block,
      void Function() profileBlock,
      bool isNotBlocked) async {
    final lang = General.language(context);
    if (!isBlocked) {
      setState(() {
        isBlocked = true;
      });
      if (isNotBlocked) {
        _showIt(context);
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final checkExists = await General.checkExists('Users/${widget.id}');
        var batch = firestore.batch();
        final _now = DateTime.now();
        final myBlockedCollection =
            firestore.collection('Users').doc(myUsername).collection('Blocked');
        final theirBlockedBy = firestore
            .collection('Users')
            .doc(widget.id)
            .collection('Blocked by');
        batch.set(myBlockedCollection.doc(widget.id), {'date': _now});
        batch.set(
            theirBlockedBy.doc(myUsername),
            {'date': _now, 'times': FieldValue.increment(1)},
            SetOptions(merge: true));
        if (checkExists)
          batch.set(firestore.collection('Users').doc(widget.id),
              {'blocked by': FieldValue.increment(1)}, SetOptions(merge: true));
        batch.update(firestore.collection('Users').doc(myUsername),
            {'numOfBlocked': FieldValue.increment(1)});
        return batch.commit().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.amber,
              content: BlockSnack(lang.widgets_common10)));
          Map<String, dynamic> fields = {
            'users blocked': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'date': _now,
            'times': FieldValue.increment(1)
          };
          General.updateControl(
              fields: fields,
              myUsername: myUsername,
              collectionName: 'users blocked',
              docID: widget.id,
              docFields: docFields);
          Future.delayed(const Duration(milliseconds: 10), () {
            profileBlock();
            block(widget.id);
          });
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {}
    }
  }

  Future<void>? unblockUser(
      BuildContext context,
      String myUsername,
      void Function(String) unblock,
      void Function() profileunBlock,
      bool isMyBlocked) async {
    final lang = General.language(context);
    if (!isUnBlocked) {
      setState(() {
        isUnBlocked = true;
      });
      if (isMyBlocked) {
        _showIt(context);
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final checkExists = await General.checkExists('Users/${widget.id}');
        var batch = firestore.batch();
        final _now = DateTime.now();
        final myBlockedCollection =
            firestore.collection('Users').doc(myUsername).collection('Blocked');
        final myUnblocked = firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Unblocked');
        final theirUnblocked = firestore
            .collection('Users')
            .doc(widget.id)
            .collection('Unblocked by');
        batch.set(
            myUnblocked.doc(widget.id),
            {'date': _now, 'times': FieldValue.increment(1)},
            SetOptions(merge: true));
        batch.set(
            theirUnblocked.doc(myUsername),
            {'date': _now, 'times': FieldValue.increment(1)},
            SetOptions(merge: true));
        batch.delete(myBlockedCollection.doc(widget.id));
        batch.set(
            firestore.collection('Users').doc(myUsername),
            {
              'numOfBlocked': FieldValue.increment(-1),
              'numOfUnBlocked': FieldValue.increment(1)
            },
            SetOptions(merge: true));
        if (checkExists)
          batch.set(
              firestore.collection('Users').doc(widget.id),
              {
                'blocked by': FieldValue.increment(-1),
                'unblocked by': FieldValue.increment(1)
              },
              SetOptions(merge: true));
        return batch.commit().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.amber,
              content: BlockSnack(lang.widgets_common11)));
          Map<String, dynamic> fields = {
            'users unblocked': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'date': _now,
            'times': FieldValue.increment(1)
          };
          General.updateControl(
              fields: fields,
              myUsername: myUsername,
              collectionName: 'users unblocked',
              docID: widget.id,
              docFields: docFields);
          Future.delayed(const Duration(milliseconds: 10), () {
            profileunBlock();
            unblock(widget.id);
          });
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {}
    }
  }

  Future<void>? removeUser(BuildContext context, String myUsername,
      void Function() remove, void Function() subtractTheir) async {
    if (!linkRemoved) {
      setState(() {
        linkRemoved = true;
      });
      if (widget.isLinkedToMe) {
        _showIt(context);
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final checkExists = await General.checkExists('Users/${widget.id}');
        var batch = firestore.batch();
        final _now = DateTime.now();
        final myLinksCollection =
            firestore.collection('Users').doc(myUsername).collection('Links');
        final myRemoved =
            firestore.collection('Users').doc(myUsername).collection('Removed');
        final theirLinkedCollection =
            firestore.collection('Users').doc(widget.id).collection('Linked');
        final theirRemoved = firestore
            .collection('Users')
            .doc(widget.id)
            .collection('Removed by');
        batch.set(
            myRemoved.doc(widget.id),
            {'date': _now, 'times': FieldValue.increment(1)},
            SetOptions(merge: true));
        batch.set(
            theirRemoved.doc(myUsername),
            {'date': _now, 'times': FieldValue.increment(1)},
            SetOptions(merge: true));
        batch.delete(myLinksCollection.doc(widget.id));
        batch.set(
            firestore.collection('Users').doc(myUsername),
            {
              'numOfLinks': FieldValue.increment(-1),
              'removedLinks': FieldValue.increment(1)
            },
            SetOptions(merge: true));
        batch.delete(theirLinkedCollection.doc(myUsername));
        if (checkExists)
          batch.set(
              firestore.collection('Users').doc(widget.id),
              {
                'numOfLinked': FieldValue.increment(-1),
                'timesRemoved': FieldValue.increment(1)
              },
              SetOptions(merge: true));
        Map<String, dynamic> fields = {
          'links removed': FieldValue.increment(1)
        };
        Map<String, dynamic> docFields = {'date': _now};
        General.updateControl(
            fields: fields,
            myUsername: myUsername,
            collectionName: 'links removed',
            docID: widget.id.toString(),
            docFields: docFields);
        return batch.commit().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
              content: const RemovedSnack()));
          Future.delayed(const Duration(milliseconds: 10), () {
            remove();
            subtractTheir();
          });
          Navigator.pop(context);
          Navigator.pop(context);
        }).catchError((_) {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final MyProfile _listenMyProfile = Provider.of<MyProfile>(context);
    final List<String> _likedPosts = _listenMyProfile.getLikedPostIDs;
    final bool uppedByMe = _likedPosts.contains(widget.postID);
    final String myUsername = _listenMyProfile.getUsername;
    final MyProfile _nolistenMyProfile =
        Provider.of<MyProfile>(context, listen: false);
    bool isHidden = _listenMyProfile.getHiddenPostIDs.contains(widget.id);
    final void Function(String) __block = _nolistenMyProfile.blockUser;
    final void Function(String) __unblock = _nolistenMyProfile.unblockUser;
    final void Function(String, bool) profileDelete =
        _nolistenMyProfile.deletePost;
    final bool exists = widget.postedByMe;
    Future<void> favPost(String myUsername) async {
      Navigator.pop(context);
      Future.delayed(
          const Duration(milliseconds: 300), () => widget.helperFav());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: _primaryColor,
          content: const FavSnack(true)));
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final _rightNow = DateTime.now();
      final targetPost = firestore
          .collection('Users')
          .doc(myUsername)
          .collection((widget.isClubPost) ? 'Fav Club Posts' : 'FavPosts')
          .doc(widget.postID);
      Map<String, dynamic> fields = {'posts fav': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'date': _rightNow};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'posts fav',
          docID: '${widget.postID}',
          docFields: docFields);
      final checkExists = await General.checkExists('Posts/${widget.postID}');
      if (checkExists) {
        var batch = firestore.batch();
        var favDoc = firestore.doc('Posts/${widget.postID}/Favs/$myUsername');
        var thePost = firestore.doc('Posts/${widget.postID}');
        var options = SetOptions(merge: true);
        batch.set(
            favDoc,
            {
              'times': FieldValue.increment(1),
              'date': DateTime.now(),
            },
            options);
        batch.set(thePost, {'favs': FieldValue.increment(1)}, options);
        batch.commit();
      }
      return targetPost.set({'date': _rightNow}).catchError((_) {
        widget.helperFav();
      });
    }

    Future<void> unfavPost(String myUsername) async {
      Navigator.pop(context);
      Future.delayed(
          const Duration(milliseconds: 300), () => widget.helperFav());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: _primaryColor,
          content: const FavSnack(false)));
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final targetPost = firestore
          .collection('Users')
          .doc(myUsername)
          .collection((widget.isClubPost) ? 'Fav Club Posts' : 'FavPosts')
          .doc(widget.postID);
      Map<String, dynamic> fields = {'posts unfav': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'date': DateTime.now()};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'posts unfav',
          docID: '${widget.postID}',
          docFields: docFields);
      final checkExists = await General.checkExists('Posts/${widget.postID}');
      if (checkExists) {
        var batch = firestore.batch();
        var unfavDoc =
            firestore.doc('Posts/${widget.postID}/Unfavs/$myUsername');
        var favDoc = firestore.doc('Posts/${widget.postID}/Favs/$myUsername');
        var thePost = firestore.doc('Posts/${widget.postID}');
        var options = SetOptions(merge: true);
        batch.delete(favDoc);
        batch.set(
            unfavDoc,
            {
              'times': FieldValue.increment(1),
              'date': DateTime.now(),
            },
            options);
        batch.set(
            thePost,
            {
              'unfavs': FieldValue.increment(1),
              'favs': FieldValue.increment(-1)
            },
            options);
        batch.commit();
      }
      return targetPost.delete().catchError((_) {
        widget.helperFav();
      });
    }

    Future<void> hide(String myUsername) async {
      Navigator.pop(context);
      widget.hidePost();
      widget.previewSetstate();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.grey.shade800,
          content: HiddenSnack(
              postID: widget.id,
              helperUnhide: widget.unhidePost,
              previewSetstate: widget.previewSetstate)));
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final targetPost = firestore
          .collection('Users')
          .doc(myUsername)
          .collection('HiddenPosts')
          .doc(widget.postID);
      Map<String, dynamic> fields = {'posts hidden': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'date': DateTime.now()};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'posts hidden',
          docID: '${widget.postID}',
          docFields: docFields);
      final checkExists = await General.checkExists('Posts/${widget.postID}');
      if (checkExists) {
        var batch = firestore.batch();
        var hideDoc =
            firestore.doc('Posts/${widget.postID}/Hidden/$myUsername');
        var thePost = firestore.doc('Posts/${widget.postID}');
        var options = SetOptions(merge: true);
        batch.set(
            hideDoc,
            {
              'times': FieldValue.increment(1),
              'date': DateTime.now(),
            },
            options);
        batch.set(thePost, {'hidden': FieldValue.increment(1)}, options);
        batch.commit();
      }
      return targetPost.set({});
    }

    Future<void>? deletePost(String myUsername,
        void Function(String, bool) delete, String clubName) async {
      if (!isDeleted) {
        setState(() => isDeleted = true);
        _showIt(context);
        void _showSnack() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
              content: const DeleteSnack()));
        }

        void _stateDelete(bool isMyPost) {
          Future.delayed(const Duration(milliseconds: 10),
              () => delete(widget.postID, isMyPost));
        }

        void _poppers() {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }

        void _thenHandler(bool isMyPost) {
          _poppers();
          _stateDelete(isMyPost);
          _showSnack();
        }

        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final _now = DateTime.now();
        final options = SetOptions(merge: true);
        // final storage = FirebaseStorage.instance;
        // Reference getMediaRef(String url) {
        //   return storage.refFromURL(url);
        // }
        // List<Reference> getRefs(List<String> urls) {
        //   return urls.map((url) => getMediaRef(url)).toList();
        // }
        var batch = firestore.batch();
        Future<void> deleteTopic(String topic) async {
          var _batch = firestore.batch();
          final topicDoc = firestore.collection('Topics').doc(topic);
          final targetPostDoc = topicDoc.collection('posts').doc(widget.postID);
          final targetDeletedDoc =
              topicDoc.collection('posts deleted').doc(widget.postID);
          _batch.delete(targetPostDoc);
          _batch.update(topicDoc, {'count': FieldValue.increment(-1)});
          _batch.set(targetDeletedDoc, {'date': _now, 'deleted by': myUsername},
              options);
          _batch.set(
              topicDoc, {'posts deleted': FieldValue.increment(1)}, options);
          return _batch.commit();
        }

        Future<void> deletePlace(String placeName, dynamic point) async {
          final placeDoc = firestore.collection('Places').doc(placeName);
          final targetPostDoc = placeDoc.collection('posts').doc(widget.postID);
          final targetDeletedDoc =
              placeDoc.collection('posts deleted').doc(widget.postID);
          batch.delete(targetPostDoc);
          batch.update(placeDoc, {'posts': FieldValue.increment(-1)});
          batch.set(
              targetDeletedDoc,
              {'date': _now, 'deleted by': myUsername, 'point': point},
              options);
          batch.set(
              placeDoc, {'posts deleted': FieldValue.increment(1)}, options);
        }

        Future<void> deleteTopicPost(List<String> topics) async {
          for (var topic in topics) {
            await deleteTopic(topic);
          }
        }

        final targetPost = firestore.collection('Posts').doc(widget.postID);
        final targetDeletedPost = firestore
            .collection(
                (widget.isClubPost) ? 'Deleted Club Posts' : 'Deleted Posts')
            .doc(widget.postID);
        final getPost = await targetPost.get();
        Map<String, dynamic> postData = getPost.data()!;
        Map<String, dynamic> de = {
          'date deleted': _now,
          'deleted by': myUsername
        };
        postData.addAll(de);
        dynamic getter(String field) => getPost.get(field);
        dynamic location = '';
        String locationName = '';
        if (getPost.data()!.containsKey('location')) {
          final actualLocation = getter('location');
          location = actualLocation;
        }
        if (getPost.data()!.containsKey('locationName')) {
          final actualLocationName = getter('locationName');
          locationName = actualLocationName;
          if (locationName != '') await deletePlace(locationName, location);
        }
        if (getPost.data()!.containsKey('clubName')) {
          final theClubName = getter('clubName');
          if (theClubName != '') {
            final thisClub = firestore.collection('Clubs').doc(theClubName);
            final thisClubPost =
                thisClub.collection('Posts').doc(widget.postID);
            batch.delete(thisClubPost);
            batch.update(thisClub, {'numOfPosts': FieldValue.increment(-1)});
          }
        }
        final String poster = getter('poster');
        final serverpostedDate = getter('date').toDate();
        final posterDocument = firestore.collection('Users').doc(poster);
        final getPoster = await posterDocument.get();
        final targetMyPosts =
            posterDocument.collection('Posts').doc(widget.postID);
        final targetMyDeletedPosts =
            posterDocument.collection('Deleted Posts').doc(widget.postID);
        final deletionData = {
          'poster': poster,
          'deleted by': myUsername,
          'date': serverpostedDate,
          'date deleted': _now
        };
        batch.set(targetMyDeletedPosts, deletionData, options);
        batch.set(targetDeletedPost, postData);
        if (getPoster.exists)
          batch.set(posterDocument, {'deleted posts': FieldValue.increment(1)},
              options);
        if (poster != myUsername)
          batch.update(
              posterDocument, {'PostsRemoved': FieldValue.increment(1)});
        if (!widget.isClubPost) {
          Map<String, dynamic> fields = {
            'posts': FieldValue.increment(-1),
            'deleted posts': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {'date': _now};
          General.updateControl(
              fields: fields,
              myUsername: myUsername,
              collectionName: 'deleted posts',
              docID: widget.postID,
              docFields: docFields);
        } else {
          final thisClub = firestore.collection('Clubs').doc(clubName);
          final thisDeletedClubPost =
              thisClub.collection('Deleted Posts').doc(widget.postID);
          final thisClubPostDoc =
              thisClub.collection('Posts').doc(widget.postID);
          batch.delete(thisClubPostDoc);
          batch.set(thisDeletedClubPost, deletionData, options);
          batch.set(
              thisClub,
              {
                'deleted posts': FieldValue.increment(1),
                'numOfPosts': FieldValue.increment(-1)
              },
              options);
          Map<String, dynamic> fields = {
            'club posts': FieldValue.increment(-1),
            'deleted club posts': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {'date': _now, 'clubName': clubName};
          General.updateControl(
              fields: fields,
              myUsername: myUsername,
              collectionName: 'deleted club posts',
              docID: widget.postID,
              docFields: docFields);
        }
        batch.delete(targetPost);
        batch.delete(targetMyPosts);
        batch.update(posterDocument, {'numOfPosts': FieldValue.increment(-1)});
        if (widget.postMedia.isNotEmpty) {
          // final references = getRefs(widget.postMedia);
          await deleteTopicPost(widget.postTopics);
          return batch.commit().then((value) {
            // references.forEach((reference) => reference.delete());
            _thenHandler(poster == myUsername);
          }).catchError((_) {
            _poppers();
          });
        } else {
          await deleteTopicPost(widget.postTopics);
          return batch.commit().then((value) {
            _thenHandler(poster == myUsername);
          }).catchError((_) {
            _poppers();
          });
        }
      }
    }

    void deleteIT(String postID, bool isMyPost) {
      profileDelete(postID, isMyPost);
      // feedDelete(postID);
      widget.deletePost();
      widget.previewSetstate();
    }

    final Widget _report = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ReportDialog(
                        id: widget.id,
                        postID: widget.postID,
                        isInProfile: widget.isInProfile,
                        isInPost: (widget.isInProfile || widget.isInClubScreen)
                            ? false
                            : true,
                        isInComment: false,
                        isInReply: false,
                        commentID: '',
                        isInClubScreen: widget.isInClubScreen,
                        isClubPost: widget.isClubPost,
                        clubName: widget.clubName,
                        flareProfileID: widget.flareProfileID,
                        isInFlareProfile: widget.isInFlareProfile,
                        isInSpotlight: false,
                        spotlightID: '',
                        flarePoster: '',
                        collectionID: '');
                  });
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: Icon(Icons.flag, color: Colors.red.shade700),
                title: Text(lang.flares_baseline5,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _hide = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              hide(myUsername);
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.visibility_off_outlined,
                    color: Colors.black),
                title: Text(lang.widgets_common12,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _block = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              blockUser(context, myUsername, __block, widget.block,
                  !widget.isBlocked);
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(customIcons.MyFlutterApp.no_stopping,
                    color: Colors.amber),
                title: Text(lang.widgets_common13,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _ban = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return BanDialog(widget.banUser, widget.id);
                },
              );
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.person_off, color: Colors.black),
                title: Text(lang.widgets_common14,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _unban = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              unbanUser(myUsername, widget.unbanUser);
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.person_add, color: Colors.black),
                title: Text(lang.widgets_common15,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _addWatchlist = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              addToWatchlist(myUsername);
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.visibility, color: Colors.black),
                title: Text(lang.widgets_common16,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.black)))));
    final Widget _prohibit = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ProhibitDialog(widget.prohibitClub, widget.clubName);
                  });
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.person_off, color: Colors.black),
                title: Text(lang.widgets_common17,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _unProhibit = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              unProhibitClub(myUsername, widget.prohibitClub);
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.person_add, color: Colors.black),
                title: Text(lang.widgets_common18,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _details = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () async {
              final firestore = FirebaseFirestore.instance;
              if (widget.isInClubScreen || widget.isInProfile) {
                profileClubDetails();
              } else {
                final docPath = 'Posts/${widget.postID}';
                var doc = await firestore.doc(docPath).get();
                GeneralAdmin.displayDocDetails(
                    context: context,
                    doc: doc,
                    actionLabel: '',
                    actionHandler: () {},
                    docAddress: docPath,
                    resolvedCollection: '',
                    resolveDocID: doc.id,
                    showActionButton: false,
                    showCopyButton: true,
                    showDeleteButton: false);
              }
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.details, color: Colors.black),
                title: Text(lang.widgets_common19,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _unblock = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              unblockUser(context, myUsername, __unblock, widget.unblock,
                  widget.isBlocked);
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(customIcons.MyFlutterApp.no_stopping,
                    color: Colors.amber),
                title: Text(lang.widgets_common20,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _removeLink = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              removeUser(context, myUsername,
                  _nolistenMyProfile.subtractMyLinks, widget.remove);
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.remove, color: Colors.red),
                title: Text(lang.widgets_common21,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _delete = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return Center(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: 150.0, maxWidth: 150.0),
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.white),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(lang.widgets_common22,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none,
                                              fontFamily: 'Roboto',
                                              fontSize: 21.0,
                                              color: Colors.black)),
                                      const Divider(
                                          thickness: 1.0,
                                          indent: 0.0,
                                          endIndent: 0.0),
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
                                                  deletePost(
                                                      myUsername,
                                                      deleteIT,
                                                      widget.clubName);
                                                },
                                                child: Text(lang.clubs_alerts3,
                                                    style: const TextStyle(
                                                        color: Colors.red))),
                                            TextButton(
                                                style: ButtonStyle(
                                                    splashFactory:
                                                        NoSplash.splashFactory),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(lang.clubs_alerts4,
                                                    style: const TextStyle(
                                                        color: Colors.red)))
                                          ])
                                    ]))));
                  });
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(lang.widgets_common23,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _favorite = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              favPost(myUsername);
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                enabled: false,
                leading: Icon(Icons.star_border, color: _accentColor),
                title: Text(lang.widgets_common24,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Widget _removeFavorite = Container(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              unfavPost(myUsername);
            },
            child: ListTile(
                horizontalTitleGap: 5.0,
                enabled: false,
                leading: Icon(Icons.star, color: _accentColor),
                title: Text(lang.widgets_common21,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.grey)))));
    final Column _menu = Column(
        key: UniqueKey(),
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!widget.isInProfile &&
              !widget.isFav &&
              !isHidden &&
              !widget.isInClubScreen &&
              !widget.isInFlareProfile)
            _favorite,
          if (!widget.isInProfile &&
              widget.isFav &&
              !widget.isInClubScreen &&
              !widget.isInFlareProfile)
            _removeFavorite,
          if (!widget.postedByMe &&
              !widget.isInProfile &&
              !isHidden &&
              !uppedByMe &&
              !widget.isFav &&
              !widget.isInClubScreen &&
              !widget.isInFlareProfile)
            _hide,
          if (widget.isInProfile && widget.isLinkedToMe) _removeLink,
          if (widget.isInProfile && !widget.isBlocked) _block,
          if (widget.isInProfile && widget.isBlocked) _unblock,
          if (widget.isInProfile &&
              myUsername.startsWith('Linkspeak') &&
              !widget.isBanned)
            _ban,
          if (widget.isInProfile &&
              myUsername.startsWith('Linkspeak') &&
              widget.isBanned)
            _unban,
          if (exists ||
              (widget.isClubPost && widget.isMod) ||
              (myUsername.startsWith('Linkspeak') &&
                  !widget.isInProfile &&
                  !widget.isInClubScreen &&
                  !widget.isInFlareProfile))
            _delete,
          if (myUsername.startsWith('Linkspeak')) _details,
          if (!widget.postedByMe && !widget.isFav && !uppedByMe ||
              (widget.isInProfile && !widget.isBlocked) ||
              widget.isInClubScreen ||
              widget.isInFlareProfile)
            _report,
          if (widget.isInClubScreen &&
              myUsername.startsWith('Linkspeak') &&
              !widget.isProhibited)
            _prohibit,
          if (widget.isInClubScreen &&
              myUsername.startsWith('Linkspeak') &&
              widget.isProhibited)
            _unProhibit,
          if ((widget.isInClubScreen || widget.isInProfile) &&
              myUsername.startsWith('Linkspeak'))
            _addWatchlist
        ]);
    return _menu;
  }
}
