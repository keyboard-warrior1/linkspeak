// ignore_for_file: body_might_complete_normally_nullable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../general.dart';
import '../../providers/addPostScreenState.dart';
import '../../providers/appBarProvider.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/load.dart';

class DeleteProfileButton extends StatefulWidget {
  final bool isLoading;
  final void Function() loadIt;
  const DeleteProfileButton(this.isLoading, this.loadIt);

  @override
  State<DeleteProfileButton> createState() => _DeleteProfileButtonState();
}

class _DeleteProfileButtonState extends State<DeleteProfileButton> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  Future<void> eraseCollection(String collectionName) async {
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final address = 'Users/$myUsername/$collectionName';
    final collection = await firestore.collection(address).get();
    final docs = collection.docs;
    if (docs.isNotEmpty)
      for (var doc in docs) firestore.doc('$address/${doc.id}').delete();
  }

  Future<void> eraseFlareCollection(String collectionName) async {
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final address = 'Flares/$myUsername/$collectionName';
    final collection = await firestore.collection(address).get();
    final docs = collection.docs;
    if (docs.isNotEmpty)
      for (var doc in docs) firestore.doc('$address/${doc.id}').delete();
  }

  Future<void> deleteFlareProfileDeletedsCollection(
      String _collectionID, String _myUsername) async {
    final thisCollection =
        firestore.doc('Flares/$_myUsername/deleted/$_collectionID');
    final getCol = await thisCollection.collection('flares').get();
    final flareDocs = getCol.docs;
    if (flareDocs.isNotEmpty)
      for (var doc in flareDocs)
        firestore
            .doc('Flares/$_myUsername/deleted/$_collectionID/flares/${doc.id}')
            .delete();
    thisCollection.delete();
  }

  Future<void> deleteFProfileCollectionSubcollection(
      String _fCollectionID, String _collectionName, String _myUsername) async {
    final address =
        'Flares/$_myUsername/collections/$_fCollectionID/$_collectionName';
    final thisCollection = firestore.collection(address);
    final getColl = await thisCollection.get();
    final docs = getColl.docs;
    if (docs.isNotEmpty)
      for (var doc in docs) firestore.doc('$address/${doc.id}').delete();
  }

  Future<void> deleteFProfileFlareSubcollection(String _fCollectionID,
      String _flareID, String _collectionName, String _myUsername) async {
    final address =
        'Flares/$_myUsername/collections/$_fCollectionID/flares/$_flareID/$_collectionName';
    final thisCollection = firestore.collection(address);
    final getColl = await thisCollection.get();
    final docs = getColl.docs;
    if (docs.isNotEmpty)
      for (var doc in docs) firestore.doc('$address/${doc.id}').delete();
  }

  Future<void> deleteFlareProfileCollections(
      String _collectionID, String _myUsername) async {
    final address =
        firestore.doc('Flares/$_myUsername/collections/$_collectionID');
    deleteFProfileCollectionSubcollection(
        _collectionID, 'Shown To', _myUsername);
    deleteFProfileCollectionSubcollection(
        _collectionID, 'Viewers', _myUsername);
    deleteFProfileCollectionSubcollection(
        _collectionID, 'Deleted comments', _myUsername);
    deleteFProfileCollectionSubcollection(
        _collectionID, 'modifications', _myUsername);
    final getFlareCollection = await address.collection('flares').get();
    final flareDocs = getFlareCollection.docs;
    if (flareDocs.isNotEmpty)
      for (var doc in flareDocs) {
        final _flareID = doc.id;
        deleteFProfileFlareSubcollection(
            _collectionID, _flareID, 'Shown To', _myUsername);
        deleteFProfileFlareSubcollection(
            _collectionID, _flareID, 'Sessions', _myUsername);
        deleteFProfileFlareSubcollection(
            _collectionID, _flareID, 'likes', _myUsername);
        deleteFProfileFlareSubcollection(
            _collectionID, _flareID, 'comments', _myUsername);
        deleteFProfileFlareSubcollection(
            _collectionID, _flareID, 'views', _myUsername);
        deleteFProfileFlareSubcollection(
            _collectionID, _flareID, 'unlikes', _myUsername);
        deleteFProfileFlareSubcollection(
            _collectionID, _flareID, 'Sharers', _myUsername);
        deleteFProfileFlareSubcollection(
            _collectionID, _flareID, 'deleted comments', _myUsername);
        address.collection('flares').doc(_flareID).delete();
      }
    address.delete();
  }

  Future<void> deleteFlareProfile(String _myUsername) async {
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final nw = DateTime.now();
    final id = nw.toString();
    final myFlareProfile = firestore.doc('Flares/$_myUsername');
    final thisDeletedFlareProfile =
        firestore.doc('Deleted Flare Profiles/$_myUsername - $id');
    final getProfile = await myFlareProfile.get();
    final getCollections = await myFlareProfile.collection('collections').get();
    final collectionDocs = getCollections.docs;
    final getDeleteds = await myFlareProfile.collection('deleted').get();
    final deletedsDocs = getDeleteds.docs;
    if (getProfile.exists) {
      Map<String, dynamic> data = getProfile.data()!;
      final Map<String, dynamic> de = {'date deleted': nw};
      data.addAll(de);
      thisDeletedFlareProfile.set(data);
      eraseFlareCollection('CommentNotifs');
      eraseFlareCollection('LikeNotifs');
      eraseFlareCollection('Modifications');
      eraseFlareCollection('Sessions');
      eraseFlareCollection('Viewers');
      eraseFlareCollection('Reported by');
      eraseFlareCollection('Muted by');
      eraseFlareCollection('Unmuted by');
      eraseFlareCollection('Hidden Collections');
      eraseFlareCollection('Unhidden Collections');
      if (collectionDocs.isNotEmpty)
        for (var doc in collectionDocs)
          deleteFlareProfileCollections(doc.id, _myUsername);
      if (deletedsDocs.isNotEmpty)
        for (var doc in deletedsDocs)
          deleteFlareProfileDeletedsCollection(doc.id, _myUsername);
      return myFlareProfile.delete();
    } else {
      return;
    }
  }

  Future<void>? deletePost(String postID, String myUsername) async {
    var batch = firestore.batch();
    final thePost = await firestore.collection('Posts').doc(postID).get();
    if (thePost.exists) {
      final media = thePost.get('imgUrls') as List;
      final List<String> mediaList = media.map((e) => e as String).toList();
      final topics = thePost.get('topics') as List;
      final List<String> topicList = topics.map((e) => e as String).toList();
      // Reference getMediaRef(String url) {
      //   return storage.refFromURL(url);
      // }

      // List<Reference> getRefs(List<String> urls) {
      //   return urls.map((url) => getMediaRef(url)).toList();
      // }
      final _now = DateTime.now();
      final options = SetOptions(merge: true);
      Future<void> deleteTopic(String topic) async {
        var _batch = firestore.batch();
        final topicDoc = firestore.collection('Topics').doc(topic);
        final targetPostDoc = topicDoc.collection('posts').doc(postID);
        final targetDeletedDoc =
            topicDoc.collection('posts deleted').doc(postID);
        _batch.delete(targetPostDoc);
        _batch.update(topicDoc, {'count': FieldValue.increment(-1)});
        _batch.set(targetDeletedDoc, {'date': _now, 'deleted by': myUsername},
            options);
        _batch.set(
            topicDoc, {'posts deleted': FieldValue.increment(1)}, options);
        return _batch.commit();
      }

      Future<void> deleteTopicPost(List<String> topics) async {
        for (var topic in topics) {
          await deleteTopic(topic);
        }
      }

      Future<void> deletePlace(String placeName, dynamic point) async {
        final placeDoc = firestore.collection('Places').doc(placeName);
        final targetPostDoc = placeDoc.collection('posts').doc(postID);
        final targetDeletedDoc =
            placeDoc.collection('posts deleted').doc(postID);
        batch.delete(targetPostDoc);
        batch.update(placeDoc, {'posts': FieldValue.increment(-1)});
        batch.set(targetDeletedDoc,
            {'date': _now, 'deleted by': myUsername, 'point': point}, options);
        batch.set(
            placeDoc, {'posts deleted': FieldValue.increment(1)}, options);
      }

      final targetPost = firestore.collection('Posts').doc(postID);
      final targetDeletedPost =
          firestore.collection('Deleted Posts').doc(postID);
      Map<String, dynamic> postData = thePost.data()!;
      Map<String, dynamic> de = {
        'date deleted': _now,
        'deleted by': myUsername
      };
      postData.addAll(de);
      dynamic getter(String field) => thePost.get(field);
      dynamic location = '';
      String locationName = '';
      if (thePost.data()!.containsKey('location')) {
        final actualLocation = getter('location');
        location = actualLocation;
      }
      if (thePost.data()!.containsKey('locationName')) {
        final actualLocationName = getter('locationName');
        locationName = actualLocationName;
        if (locationName != '') await deletePlace(locationName, location);
      }
      if (thePost.data()!.containsKey('clubName')) {
        final theClubName = getter('clubName');
        if (theClubName != '') {
          final thisClub = firestore.collection('Clubs').doc(theClubName);
          final thisClubPost = thisClub.collection('Posts').doc(postID);
          batch.delete(thisClubPost);
          batch.update(thisClub, {'numOfPosts': FieldValue.increment(-1)});
        }
      }
      batch.set(targetDeletedPost, postData);
      if (mediaList.isNotEmpty) {
        // final references = getRefs(mediaList);
        await deleteTopicPost(topicList);
        // references.forEach((reference) => reference.delete());
        batch.delete(targetPost);
        batch.delete(firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Posts')
            .doc(postID));
      } else {
        await deleteTopicPost(topicList);
        batch.delete(targetPost);
        batch.delete(firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Posts')
            .doc(postID));
      }
    } else {
      batch.delete(firestore
          .collection('Users')
          .doc(myUsername)
          .collection('Posts')
          .doc(postID));
    }
    batch.commit();
  }

  Future<void>? removeUser(String myUsername, String userID) {
    var batch = firestore.batch();
    final theirLinkedCollection =
        firestore.collection('Users').doc(userID).collection('Linked');
    batch.delete(theirLinkedCollection.doc(myUsername));
    batch.update(firestore.collection('Users').doc(userID),
        {'numOfLinked': FieldValue.increment(-1)});
    batch.delete(firestore
        .collection('Users')
        .doc(myUsername)
        .collection('Links')
        .doc(userID));
    batch.commit();
  }

  Future<void> unlink(String userID, String myUsername) async {
    var batch = firestore.batch();
    final userLinks =
        firestore.collection('Users').doc(userID).collection('Links');
    batch.delete(userLinks.doc(myUsername));
    batch.update(firestore.collection('Users').doc(userID),
        {'numOfLinks': FieldValue.increment(-1)});
    batch.delete(firestore
        .collection('Users')
        .doc(myUsername)
        .collection('Linked')
        .doc(userID));
    batch.commit();
  }

  Future<void> leaveClub(String clubName, String myUsername) async {
    var batch = firestore.batch();
    final club = firestore.doc('Clubs/$clubName');
    final clubMember = firestore.doc('Clubs/$clubName/Members/$myUsername');
    final joinedClub =
        firestore.doc('Users/$myUsername/Joined Clubs/$clubName');
    final options = SetOptions(merge: true);
    batch.delete(clubMember);
    batch.set(club, {'numOfMembers': FieldValue.increment(-1)}, options);
    batch.delete(joinedClub);
    batch.commit();
  }

  Future<void> deleteMyClub(String clubName, String myUsername) async {
    var batch = firestore.batch();
    final clubAdmin = firestore.doc('Clubs/$clubName/Moderators/$myUsername');
    final myClub = firestore.doc('Users/$myUsername/My Clubs/$clubName');
    batch.delete(clubAdmin);
    batch.delete(myClub);
    batch.commit();
  }

  Future<void> deleteLikedClubPosts(String postID, String _myUsername) async {
    var batch = firestore.batch();
    final myLike = firestore.doc('Posts/$postID/likers/$_myUsername');
    final myDoc = firestore.doc('Users/$_myUsername/Liked Club Posts/$postID');
    final getMyLike = await myLike.get();
    if (getMyLike.exists) batch.delete(myLike);
    batch.delete(myDoc);
    batch.commit();
  }

  Future<void> deleteLikedPosts(String postID, String _myUsername) async {
    var batch = firestore.batch();
    final myLike = firestore.doc('Posts/$postID/likers/$_myUsername');
    final getMyLike = await myLike.get();
    final myDoc = firestore.doc('Users/$_myUsername/LikedPosts/$postID');
    if (getMyLike.exists) batch.delete(myLike);
    batch.delete(myDoc);
    batch.commit();
  }

  Future<void> deleteLikedComment(String _commentID, String _myUsername) async {
    var batch = firestore.batch();
    final getLikedComment = await firestore
        .doc('Users/$_myUsername/Liked Comments/$_commentID')
        .get();
    final postID = getLikedComment.get('post ID');
    final commentID = getLikedComment.get('comment ID');
    final likedPostComment =
        firestore.doc('Posts/$postID/comments/$commentID/likes/_myUsername');
    final thisOne =
        firestore.doc('Users/$_myUsername/Liked Comments/$_commentID');
    final getLikedPostComment = await likedPostComment.get();
    if (getLikedPostComment.exists) batch.delete(likedPostComment);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteLikedClubComment(
      String _commentID, String _myUsername) async {
    var batch = firestore.batch();
    final getLikedComment = await firestore
        .doc('Users/$_myUsername/Liked Club Comments/$_commentID')
        .get();
    final postID = getLikedComment.get('post ID');
    final commentID = getLikedComment.get('comment ID');
    final likedPostComment =
        firestore.doc('Posts/$postID/comments/$commentID/likes/$_myUsername');
    final thisOne =
        firestore.doc('Users/$_myUsername/Liked Club Comments/$_commentID');
    final getLikedPostComment = await likedPostComment.get();
    if (getLikedPostComment.exists) batch.delete(likedPostComment);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteMyComments(String _commentID, String _myUsername) async {
    var batch = firestore.batch();
    var comment =
        await firestore.doc('Users/$_myUsername/My Comments/$_commentID').get();
    final postID = comment.get('post ID');
    final thePost = firestore.doc('Posts/$postID');
    final theComment = thePost.collection('comments').doc(_commentID);
    final thisOne = firestore.doc('Users/$_myUsername/My Comments/$_commentID');
    final getComment = await theComment.get();
    if (getComment.exists) batch.delete(theComment);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteClubComments(String _commentID, String _myUsername) async {
    var batch = firestore.batch();
    var comment = await firestore
        .doc('Users/$_myUsername/Club Comments/$_commentID')
        .get();
    final postID = comment.get('post ID');
    final thePost = firestore.collection('Posts').doc(postID);
    final theComment = thePost.collection('comments').doc(_commentID);
    final thisOne =
        firestore.doc('Users/$_myUsername/Club Comments/$_commentID');
    final getComment = await theComment.get();
    if (getComment.exists) batch.delete(theComment);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteMyReplies(String _replyID, String _myUsername) async {
    var batch = firestore.batch();
    var reply =
        await firestore.doc('Users/$_myUsername/My Replies/$_replyID').get();
    final thisOne = firestore.doc('Users/$_myUsername/My Replies/$_replyID');
    final postID = reply.get('post ID');
    final commentID = reply.get('comment ID');
    final thePost = firestore.collection('Posts').doc(postID);
    final theComment = thePost.collection('comments').doc(commentID);
    final theReply = theComment.collection('replies').doc(_replyID);
    final getReply = await theReply.get();
    if (getReply.exists) batch.delete(theReply);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteClubReplies(String _replyID, String _myUsername) async {
    var batch = firestore.batch();
    var reply =
        await firestore.doc('Users/$_myUsername/Club Replies/$_replyID').get();
    final thisOne = firestore.doc('Users/$_myUsername/Club Replies/$_replyID');
    final postID = reply.get('post ID');
    final commentID = reply.get('comment ID');
    final thePost = firestore.collection('Posts').doc(postID);
    final theComment = thePost.collection('comments').doc(commentID);
    final theReply = theComment.collection('replies').doc(_replyID);
    final getReply = await theReply.get();
    if (getReply.exists) batch.delete(theReply);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteChatDocs(String _chatID, String _myUsername) async {
    final myprofile = firestore.collection('Users').doc(_myUsername);
    final getMessages = await myprofile
        .collection('chats')
        .doc(_chatID)
        .collection('messages')
        .get();
    final messagesDocs = getMessages.docs;
    for (var message in messagesDocs)
      myprofile
          .collection('chats')
          .doc(_chatID)
          .collection('messages')
          .doc(message.id)
          .delete();
    myprofile.collection('chats').doc(_chatID).delete();
  }

  Future<void> deleteLikedReplies(String _replyID, String _myUsername) async {
    var batch = firestore.batch();
    final getLikedReply = await firestore
        .doc('Users/$_myUsername/Liked Comment Replies/$_replyID')
        .get();
    final postID = getLikedReply.get('post ID');
    final commentID = getLikedReply.get('comment ID');
    final likedreply = firestore.doc(
        'Posts/$postID/comments/$commentID/replies/$_replyID/likes/$_myUsername');
    final thisOne =
        firestore.doc('Users/$_myUsername/Liked Comment Replies/$_replyID');
    final getLike = await likedreply.get();
    if (getLike.exists) batch.delete(likedreply);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteLikedClubReplies(
      String _replyID, String _myUsername) async {
    var batch = firestore.batch();
    final getLikedReply = await firestore
        .doc('Users/$_myUsername/Liked Club Comment Replies/$_replyID')
        .get();
    final postID = getLikedReply.get('post ID');
    final commentID = getLikedReply.get('comment ID');
    final likedreply = firestore.doc(
        'Posts/$postID/comments/$commentID/replies/$_replyID/likes/$_myUsername');
    final thisOne = firestore
        .doc('Users/$_myUsername/Liked Club Comment Replies/$_replyID');
    final getLike = await likedreply.get();
    if (getLike.exists) batch.delete(likedreply);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteLikedFlares(String _flareID, String _myUsername) async {
    var batch = firestore.batch();
    final getLikedFlare =
        await firestore.doc('Users/$_myUsername/Liked Flares/$_flareID').get();
    final poster = getLikedFlare.get('poster');
    final collectionID = getLikedFlare.get('collectionID');
    final flareID = getLikedFlare.get('flareID');
    final likedFlare = firestore.doc(
        'Flares/$poster/collections/$collectionID/flares/$flareID/likes/$_myUsername');
    final thisOne = firestore.doc('Users/$_myUsername/Liked Flares/$_flareID');
    final getLike = await likedFlare.get();
    if (getLike.exists) batch.delete(likedFlare);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteLikedFlareComments(
      String _commentID, String _myUsername) async {
    var batch = firestore.batch();
    final getLikedComment = await firestore
        .doc('Users/$_myUsername/Liked Flare Comments/$_commentID')
        .get();
    final poster = getLikedComment.get('poster');
    final collectionID = getLikedComment.get('collectionID');
    final flareID = getLikedComment.get('flareID');
    final likedComment = firestore.doc(
        'Flares/$poster/collections/$collectionID/flares/$flareID/comments/$_commentID/likes/$_myUsername');
    final thisOne =
        firestore.doc('Users/$_myUsername/Liked Flare Comments/$_commentID');
    final getLike = await likedComment.get();
    if (getLike.exists) batch.delete(likedComment);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteLikedFlareReplies(
      String _replyID, String _myUsername) async {
    var batch = firestore.batch();
    final getLikedReply = await firestore
        .doc('Users/$_myUsername/Liked Flare Replies/$_replyID')
        .get();
    final poster = getLikedReply.get('poster');
    final collectionID = getLikedReply.get('collection ID');
    final flareID = getLikedReply.get('flare ID');
    final commentID = getLikedReply.get('comment ID');
    final likedReply = firestore.doc(
        'Flares/$poster/collections/$collectionID/flares/$flareID/comments/$commentID/replies/$_replyID/likes/$_myUsername');
    final thisOne =
        firestore.doc('Users/$_myUsername/Liked Flare Replies/$_replyID');
    final getLike = await likedReply.get();
    if (getLike.exists) batch.delete(likedReply);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteFlareComments(
      String _commentID, String _myUsername) async {
    var batch = firestore.batch();
    var comment = await firestore
        .doc('Users/$_myUsername/Flare Comments/$_commentID')
        .get();
    final poster = comment.get('flarePoster');
    final collectionID = comment.get('collectionID');
    final flareID = comment.get('flare ID');
    final theComment = firestore.doc(
        'Flares/$poster/collections/$collectionID/flares/$flareID/comments/$_commentID');
    final thisOne =
        firestore.doc('Users/$_myUsername/Flare Comments/$_commentID');
    final getComment = await theComment.get();
    if (getComment.exists) batch.delete(theComment);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteFlareReplies(String _replyID, String _myUsername) async {
    var batch = firestore.batch();
    var reply =
        await firestore.doc('Users/$_myUsername/Flare Replies/$_replyID').get();
    final poster = reply.get('poster');
    final collectionID = reply.get('collectionID');
    final flareID = reply.get('flareID');
    final commentID = reply.get('comment ID');
    final theReply = firestore.doc(
        'Flares/$poster/collections/$collectionID/flares/$flareID/comments/$commentID/replies/$_replyID');
    final thisOne = firestore.doc('Users/$_myUsername/Flare Replies/$_replyID');
    final getReply = await theReply.get();
    if (getReply.exists) batch.delete(theReply);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteViewedFlares(String _flareID, String _myUsername) async {
    var batch = firestore.batch();
    final getFlareView =
        await firestore.doc('Users/$_myUsername/Viewed Flares/$_flareID').get();
    final poster = getFlareView.get('poster');
    final collectionID = getFlareView.get('collectionID');
    final flareID = getFlareView.get('flareID');
    final flareView = firestore.doc(
        'Flares/$poster/collections/$collectionID/flares/$flareID/views/$_myUsername');
    final thisOne = firestore.doc('Users/$_myUsername/Viewed Flares/$_flareID');
    final getView = await flareView.get();
    if (getView.exists) batch.delete(flareView);
    batch.delete(thisOne);
    batch.commit();
  }

  Future<void> deleteShares(String recipient, String _myUsername) async {
    final flareShares = await firestore
        .collection('Users/$_myUsername/Shares/$recipient/flares')
        .get();
    final flareDocs = flareShares.docs;
    final postShares = await firestore
        .collection('Users/$_myUsername/Shares/$recipient/posts')
        .get();
    final postDocs = postShares.docs;
    if (flareDocs.isNotEmpty)
      for (var doc in flareDocs)
        firestore
            .doc('Users/$_myUsername/Shares/$recipient/flares/${doc.id}')
            .delete();
    if (postDocs.isNotEmpty)
      for (var doc in postDocs)
        firestore
            .doc('Users/$_myUsername/Shares/$recipient/posts/${doc.id}')
            .delete();
    final thisOne = firestore.doc('Users/$_myUsername/Shares/$recipient');
    thisOne.delete();
  }

  Future<void> deleteReceivedPosts(String _postID, String _myUsername) async {
    final sendersCollection = await firestore
        .collection('Users/$_myUsername/Received Posts/$_postID/senders')
        .get();
    final senderDocs = sendersCollection.docs;
    if (senderDocs.isNotEmpty)
      for (var doc in senderDocs)
        firestore
            .doc('Users/$_myUsername/Received Posts/$_postID/senders/${doc.id}')
            .delete();
    final thisOne = firestore.doc('Users/$_myUsername/Received Posts/$_postID');
    thisOne.delete();
  }

  Future<void> deleteReceivedFlares(String _flareID, String _myUsername) async {
    final sendersCollection = await firestore
        .collection('Users/$_myUsername/Received Flares/$_flareID/senders')
        .get();
    final senderDocs = sendersCollection.docs;
    if (senderDocs.isNotEmpty)
      for (var doc in senderDocs)
        firestore
            .doc(
                'Users/$_myUsername/Received Flares/$_flareID/senders/${doc.id}')
            .delete();
    final thisOne =
        firestore.doc('Users/$_myUsername/Received Flares/$_flareID');
    thisOne.delete();
  }

  Future<void> deleteMyFlares(String _collectionID, String _myUsername) async {
    final theFlaresColl = await firestore
        .collection('Users/$_myUsername/My Flares/$_collectionID/flares')
        .get();
    final theFlaresDocs = theFlaresColl.docs;
    if (theFlaresDocs.isNotEmpty)
      for (var doc in theFlaresDocs)
        firestore
            .doc('Users/$_myUsername/My Flares/$_collectionID/flares/${doc.id}')
            .delete();
    final thisOne =
        firestore.doc('Users/$_myUsername/My Flares/$_collectionID');
    thisOne.delete();
  }

  Future<void> deleteMyDeletedFlares(
      String _collectionID, String _myUsername) async {
    final theFlaresColl = await firestore
        .collection('Users/$_myUsername/Deleted Flares/$_collectionID/flares')
        .get();
    final theFlaresDocs = theFlaresColl.docs;
    if (theFlaresDocs.isNotEmpty)
      for (var doc in theFlaresDocs)
        firestore
            .doc(
                'Users/$_myUsername/Deleted Flares/$_collectionID/flares/${doc.id}')
            .delete();
    final thisOne =
        firestore.doc('Users/$_myUsername/Deleted Flares/$_collectionID');
    thisOne.delete();
  }

  Future<void> deleteLogins(String dayID, String _myUsername) async {
    final thisDaySessions = await firestore
        .collection('Users/$_myUsername/Logins/$dayID/Sessions')
        .get();
    final sessionDocs = thisDaySessions.docs;
    if (sessionDocs.isNotEmpty)
      for (var doc in sessionDocs)
        firestore
            .doc('Users/$_myUsername/Logins/$dayID/Sessions/${doc.id}')
            .delete();

    firestore.doc('Users/$_myUsername/Logins/$dayID').delete();
  }

  Future<void> thenBlock(String email) async {
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final myprofile = firestore.doc('Users/$_myUsername');
    Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
            String name) async =>
        await myprofile.collection(name).get();
    final getMyClubs = await getCollection('My Clubs');
    final clubDocs = getMyClubs.docs;
    final getJoinedClubs = await getCollection('Joined Clubs');
    final joinedClubDocs = getJoinedClubs.docs;
    final getLikedClubPosts = await getCollection('Liked Club Posts');
    final likedClubPostsDocs = getLikedClubPosts.docs;
    final getMyLikedComments = await getCollection('Liked Comments');
    final likedCommentDocs = getMyLikedComments.docs;
    final getMyLikedClubComments = await getCollection('Liked Club Comments');
    final myLikedClubCommentDocs = getMyLikedClubComments.docs;
    final getMyUserComments = await getCollection('My Comments');
    final mycommentDocs = getMyUserComments.docs;
    final getMyClubComments = await getCollection('Club Comments');
    final myClubCommentDocs = getMyClubComments.docs;
    final getMyUserReplies = await getCollection('My Replies');
    final myReplyDocs = getMyUserReplies.docs;
    final getMyClubReplies = await getCollection('Club Replies');
    final myClubReplyDocs = getMyClubReplies.docs;
    final getpostIDs = await getCollection('Posts');
    final postIDdocs = getpostIDs.docs;
    final List<String> postIDs = postIDdocs.map((post) => post.id).toList();
    final getLinksIDs = await getCollection('Linked');
    final linkIDdocs = getLinksIDs.docs;
    final List<String> linkIDs = linkIDdocs.map((e) => e.id).toList();
    final getLinkedIDs = await getCollection('Links');
    final linkedIDdocs = getLinkedIDs.docs;
    final List<String> linkedIDs = linkedIDdocs.map((e) => e.id).toList();
    final getChats = await getCollection('chats');
    final chatDocs = getChats.docs;
    final getLikedPosts = await getCollection('LikedPosts');
    final likedDocs = getLikedPosts.docs;
    final getLikedReplies = await getCollection('Liked Comment Replies');
    final likedReplyDocs = getLikedReplies.docs;
    final getLikedClubReplies =
        await getCollection('Liked Club Comment Replies');
    final likedClubReplyDocs = getLikedClubReplies.docs;
    final getViewedFlares = await getCollection('Viewed Flares');
    final viewedFlareDocs = getViewedFlares.docs;
    final getFlareComments = await getCollection('Flare Comments');
    final flareCommentDocs = getFlareComments.docs;
    final getFlareReplies = await getCollection('Flare Replies');
    final flareReplyDocs = getFlareReplies.docs;
    final getLikedFlares = await getCollection('Liked Flares');
    final likedFlareDocs = getLikedFlares.docs;
    final getLikedFlareComments = await getCollection('Liked Flare Comments');
    final likedFlareCommentDocs = getLikedFlareComments.docs;
    final getLikedFlareReplies = await getCollection('Liked Flare Replies');
    final likedFlareReplyDocs = getLikedFlareReplies.docs;
    final getReceivedPosts = await getCollection('Received Posts');
    final receivedPostDocs = getReceivedPosts.docs;
    final getReceivedFlares = await getCollection('Received Flares');
    final receivedFlareDocs = getReceivedFlares.docs;
    final getShares = await getCollection('Shares');
    final shareDocs = getShares.docs;
    final getMyFlares = await getCollection('My Flares');
    final myFlareDocs = getMyFlares.docs;
    final getMyDeletedFlares = await getCollection('Deleted Flares');
    final deletedFlareDocs = getMyDeletedFlares.docs;
    final loginsCollection = await getCollection('Logins');
    final loginDocs = loginsCollection.docs;
    final myEmail = firestore.collection('Emails').doc(email);
    var user = auth.currentUser;
    var batch = firestore.batch();
    batch.update(firestore.collection('Control').doc('Details'),
        {'users': FieldValue.increment(-1)});
    batch.update(firestore.collection('Control').doc('Details'),
        {'online': FieldValue.increment(-1)});
    batch.update(firestore.collection('Control').doc('Details'),
        {'deleted': FieldValue.increment(1)});
    General.subtractDailyOnline();
    General.addDailyDeleted();
    batch.delete(myEmail);
    batch.delete(myprofile);
    eraseCollection('Mention Box');
    eraseCollection('Mentioned In');
    eraseCollection('My mentions');
    eraseCollection('My Locations');
    eraseCollection('Fav Club Posts');
    eraseCollection('FavPosts');
    eraseCollection('HiddenPosts');
    eraseCollection('URLs');
    eraseCollection('Banned from');
    eraseCollection('Unbanned from');
    eraseCollection('Revoked Clubs');
    eraseCollection('Muted');
    eraseCollection('Unmuted');
    eraseCollection('Unliked Flares');
    eraseCollection('Unliked Flare Comments');
    eraseCollection('Unliked Flare Replies');
    eraseCollection('Unliked Club Comment Replies');
    eraseCollection('Unliked Comment Replies');
    eraseCollection('Unliked Comments');
    eraseCollection('Unliked Club Comments');
    eraseCollection('Unliked Posts');
    eraseCollection('Unliked Club Posts');
    eraseCollection('Deleted Flare Replies');
    eraseCollection('Deleted Flare Comments');
    eraseCollection('Deleted Comments');
    eraseCollection('Deleted Replies');
    eraseCollection('Deleted Posts');
    eraseCollection('Deleted Club Posts');
    eraseCollection('Flare History');
    eraseCollection('Unlinks');
    eraseCollection('Unlinked');
    eraseCollection('Exclubs');
    eraseCollection('Removed');
    eraseCollection('Removed by');
    eraseCollection('Blocked');
    eraseCollection('Blocked by');
    eraseCollection('Unblocked');
    eraseCollection('Unblocked by');
    eraseCollection('NewLinksNotifs');
    eraseCollection('PostLikesNotifs');
    eraseCollection('LinkRequestsNotifs');
    eraseCollection('NewLinkedNotifs');
    eraseCollection('PostCommentsNotifs');
    eraseCollection('CommentRepliesNotifs');
    eraseCollection('Modifications');
    eraseCollection('Additional Modifications');
    eraseCollection('Suggested Clubs');
    eraseCollection('Suggested Profiles');
    eraseCollection('Suggested To');
    eraseCollection('Denied Requests');
    eraseCollection('Requests Denied');
    eraseCollection('Club requests denied');
    eraseCollection('Screenshots');
    eraseCollection('Shown Posts');
    eraseCollection('Shown Comments');
    eraseCollection('Shown Replies');
    eraseCollection('Shown Collections');
    eraseCollection('Shown Flares');
    eraseCollection('Shown Flare Comments');
    eraseCollection('Shown Flare Replies');
    eraseCollection('Sessions');
    eraseCollection('Viewers');
    eraseCollection('Viewed Places');
    eraseCollection('Viewed Clubs');
    eraseCollection('Viewed Topics');
    eraseCollection('Viewed Profiles');
    eraseCollection('Viewed Posts');
    eraseCollection('Viewed Comments');
    eraseCollection('Viewed Flare Profiles');
    eraseCollection('Viewed Flares');
    eraseCollection('Viewed Flare Comments');
    eraseCollection('Reported by');
    eraseCollection('Reports');

    if (myFlareDocs.isNotEmpty)
      for (var doc in myFlareDocs) await deleteMyFlares(doc.id, _myUsername);
    if (deletedFlareDocs.isNotEmpty)
      for (var doc in deletedFlareDocs)
        await deleteMyDeletedFlares(doc.id, _myUsername);
    if (shareDocs.isNotEmpty)
      for (var doc in shareDocs) await deleteShares(doc.id, _myUsername);
    if (receivedFlareDocs.isNotEmpty)
      for (var doc in receivedFlareDocs)
        await deleteReceivedFlares(doc.id, _myUsername);
    if (receivedPostDocs.isNotEmpty)
      for (var doc in receivedPostDocs)
        await deleteReceivedPosts(doc.id, _myUsername);
    if (viewedFlareDocs.isNotEmpty)
      for (var doc in viewedFlareDocs)
        await deleteViewedFlares(doc.id, _myUsername);
    if (flareCommentDocs.isNotEmpty)
      for (var doc in flareCommentDocs)
        await deleteFlareComments(doc.id, _myUsername);
    if (flareReplyDocs.isNotEmpty)
      for (var doc in flareReplyDocs)
        await deleteFlareReplies(doc.id, _myUsername);
    if (likedFlareDocs.isNotEmpty)
      for (var doc in likedFlareDocs)
        await deleteLikedFlares(doc.id, _myUsername);
    if (likedFlareCommentDocs.isNotEmpty)
      for (var doc in likedFlareCommentDocs)
        await deleteLikedFlareComments(doc.id, _myUsername);
    if (likedFlareReplyDocs.isNotEmpty)
      for (var doc in likedFlareReplyDocs)
        await deleteLikedFlareReplies(doc.id, _myUsername);
    if (likedReplyDocs.isNotEmpty)
      for (var doc in likedReplyDocs)
        await deleteLikedReplies(doc.id, _myUsername);
    if (likedClubReplyDocs.isNotEmpty)
      for (var doc in likedClubReplyDocs)
        await deleteLikedClubReplies(doc.id, _myUsername);
    if (clubDocs.isNotEmpty)
      for (var doc in clubDocs) await deleteMyClub(doc.id, _myUsername);
    if (joinedClubDocs.isNotEmpty)
      for (var doc in joinedClubDocs) await leaveClub(doc.id, _myUsername);
    if (postIDdocs.isNotEmpty)
      for (var id in postIDs) await deletePost(id, _myUsername);
    if (linkIDdocs.isNotEmpty)
      for (var id in linkIDs) await unlink(id, _myUsername);
    if (linkedIDdocs.isNotEmpty)
      for (var id in linkedIDs) await removeUser(_myUsername, id);
    if (likedClubPostsDocs.isNotEmpty)
      for (var doc in likedClubPostsDocs)
        await deleteLikedClubPosts(doc.id, _myUsername);
    if (likedDocs.isNotEmpty)
      for (var doc in likedDocs) await deleteLikedPosts(doc.id, _myUsername);
    if (likedCommentDocs.isNotEmpty)
      for (var doc in likedCommentDocs)
        await deleteLikedComment(doc.id, _myUsername);
    if (myLikedClubCommentDocs.isNotEmpty)
      for (var doc in myLikedClubCommentDocs)
        await deleteLikedClubComment(doc.id, _myUsername);
    if (mycommentDocs.isNotEmpty)
      for (var doc in mycommentDocs)
        await deleteMyComments(doc.id, _myUsername);
    if (myClubCommentDocs.isNotEmpty)
      for (var doc in myClubCommentDocs)
        await deleteClubComments(doc.id, _myUsername);
    if (myReplyDocs.isNotEmpty)
      for (var doc in myReplyDocs) await deleteMyReplies(doc.id, _myUsername);
    if (myClubReplyDocs.isNotEmpty)
      for (var doc in myClubReplyDocs)
        await deleteClubReplies(doc.id, _myUsername);
    if (chatDocs.isNotEmpty)
      for (var doc in chatDocs) await deleteChatDocs(doc.id, _myUsername);
    if (loginDocs.isNotEmpty)
      for (var doc in loginDocs) await deleteLogins(doc.id, _myUsername);
    await deleteFlareProfile(_myUsername);
    batch.commit().then((value) async {
      final prefs = await SharedPreferences.getInstance();
      final myBool = prefs.getBool('KeepLogged') ?? false;
      final myGmail = prefs.getString('GMAIL') ?? '';
      final myFb = prefs.getString('FB') ?? '';
      if (myBool) {
        prefs.setBool('KeepLogged', false).then((value) {});
      }
      if (myGmail != '') {
        prefs.remove('GMAIL').then((value) {
          GoogleSignIn().signIn().then((value) {
            user!.delete().then((value) {
              GoogleSignIn().signOut().then((value) {
                FirebaseAuth.instance.signInAnonymously().then((value) {
                  firestore
                      .collection('Users')
                      .doc('$_myUsername')
                      .delete()
                      .then((value) {
                    Provider.of<MyProfile>(context, listen: false)
                        .resetProfile();
                    Provider.of<AppBarProvider>(context, listen: false).reset();
                    Provider.of<NewPostHelper>(context, listen: false).clear();
                    EasyLoading.dismiss();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacementNamed(
                        context, RouteGenerator.splashScreen);
                  });
                });
              });
            });
          });
        });
      } else if (myFb != '') {
        prefs.remove('FB').then((value) {
          FacebookAuth.instance.login().then((value) {
            user!.delete().then((value) {
              FacebookAuth.instance.logOut().then((value) {
                FirebaseAuth.instance.signInAnonymously().then((value) {
                  firestore
                      .collection('Users')
                      .doc('$_myUsername')
                      .delete()
                      .then((_) {
                    Provider.of<MyProfile>(context, listen: false)
                        .resetProfile();
                    Provider.of<AppBarProvider>(context, listen: false).reset();
                    Provider.of<NewPostHelper>(context, listen: false).clear();
                    EasyLoading.dismiss();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacementNamed(
                        context, RouteGenerator.splashScreen);
                  });
                });
              });
            });
          });
        });
      } else {
        user!.delete().then((value) {
          Provider.of<MyProfile>(context, listen: false).resetProfile();
          Provider.of<AppBarProvider>(context, listen: false).reset();
          Provider.of<NewPostHelper>(context, listen: false).clear();
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacementNamed(context, RouteGenerator.splashScreen);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final _myUsername = Provider.of<MyProfile>(context).getUsername;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                if (widget.isLoading) {
                } else {
                  showDialog(
                      context: context,
                      builder: (_) {
                        void _showIt() {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors.transparent,
                              builder: (_) {
                                return const Load(isDeleteProfile: true);
                              });
                        }

                        return Center(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: 150.0, maxWidth: 150.0),
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        color: Colors.white),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(lang.widgets_profile2,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontFamily: 'Roboto',
                                                  fontSize: 17.0,
                                                  color: Colors.black)),
                                          const Divider(
                                              thickness: 1.0,
                                              indent: 0.0,
                                              endIndent: 0.0),
                                          Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                TextButton(
                                                    style: ButtonStyle(
                                                        splashFactory: NoSplash
                                                            .splashFactory),
                                                    onPressed: () async {
                                                      widget.loadIt();
                                                      _showIt();
                                                      final myprofile = firestore
                                                          .collection('Users')
                                                          .doc('$_myUsername');
                                                      final duplicateProfile =
                                                          firestore
                                                              .collection(
                                                                  'Deleted Users')
                                                              .doc(
                                                                  '$_myUsername - ${DateTime.now().toString()}');
                                                      final getit =
                                                          await myprofile.get();
                                                      Map<String, dynamic>
                                                          myData =
                                                          getit.data()!;
                                                      Map<String, dynamic> de =
                                                          {
                                                        'Date deleted':
                                                            DateTime.now()
                                                      };
                                                      myData.addAll(de);
                                                      dynamic getter(
                                                              String field) =>
                                                          getit.get(field);
                                                      final email =
                                                          getter('Email');
                                                      duplicateProfile
                                                          .set(myData)
                                                          .then((value) {
                                                        thenBlock(email);
                                                      });
                                                    },
                                                    child: Text(
                                                        lang.clubs_alerts3,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.red))),
                                                TextButton(
                                                    style: ButtonStyle(
                                                        splashFactory: NoSplash
                                                            .splashFactory),
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                        lang.clubs_alerts4,
                                                        style: TextStyle(
                                                            color: Colors.red)))
                                              ])
                                        ]))));
                      });
                }
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color?>(Colors.red)),
              child: Center(
                  child: Text(lang.widgets_profile1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)))))
    ]);
  }
}
