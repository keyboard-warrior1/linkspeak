import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_speak/providers/myProfileProvider.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../models/posterProfile.dart';
import '../models/post.dart';
import '../providers/myProfileProvider.dart';
import '../providers/feedProvider.dart';
import '../providers/fullPostHelper.dart';
import '../screens/feedScreen.dart';
import '../widgets/adaptiveText.dart';
import '../widgets/suggestedWidget.dart';
import '../widgets/postWidget.dart';
import '../widgets/ads.dart';

class Feed extends StatefulWidget {
  const Feed();
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = FeedScreen.scrollController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const Widget _suggested = const SuggestedWidget();
  List<Post> feedPosts = [];
  List<Post> topicPosts = [];
  List<Post> linkedPosts = [];
  List<Post> randomPosts = [];
  late Future _getPosts;
  bool noPostsFound = false;
  bool isLoading = false;
  TheVisibility generateVis(String vis) {
    if (vis == 'Public') {
      return TheVisibility.public;
    } else if (vis == 'Private') {
      return TheVisibility.private;
    }
    return TheVisibility.private;
  }

  List<String> linkedListString = [];

  Future<void> getPosts(
    final List<String> myTopics,
    void Function(List<Post>) setPosts,
    final List<String> myBlockedIDs,
    bool clearPosts,
    void Function() clear,
  ) async {
    List<Post> tempPosts = [];
    if (clearPosts) {
      clear();
      linkedListString.clear();
      feedPosts.clear();
      topicPosts.clear();
      linkedPosts.clear();
      randomPosts.clear();
    }
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final usersCollection = firestore.collection('Users');
    // ignore: avoid_init_to_null
    dynamic topicpostsCollection = null;
    // ignore: avoid_init_to_null
    dynamic thetopicposts = null;
    // ignore: avoid_init_to_null
    dynamic linkedpostsCollection = null;
    // ignore: avoid_init_to_null
    dynamic theLinkedposts = null;
    if (myTopics.isNotEmpty) {
      myTopics.shuffle();
      final newTopics = myTopics.take(10).toList();
      topicpostsCollection = await firestore
          .collection('Posts')
          .where('topics', arrayContainsAny: newTopics)
          .orderBy('date', descending: true)
          .limit(6)
          .get();
      thetopicposts = topicpostsCollection.docs;
    }
    final linkedList = await usersCollection
        .doc(myUsername)
        .collection('Linked')
        .limit(10)
        .get();
    final linkedListDocs = linkedList.docs;
    if (linkedListDocs.isNotEmpty) {
      for (var eleman in linkedList.docs) {
        linkedListString.add(eleman.id.toString());
      }
      linkedpostsCollection = await firestore
          .collection('Posts')
          .where('poster', whereIn: linkedListString)
          .orderBy('date', descending: true)
          .limit(10)
          .get();
      theLinkedposts = linkedpostsCollection.docs;
      if (theLinkedposts.isNotEmpty) {
        for (var post in theLinkedposts) {
          dynamic getter(String field) => post.get(field);
          final postID = post.id;
          final String poster = getter('poster');
          final posterUser = await usersCollection.doc(poster).get();
          final posterVisibility = posterUser.get('Visibility');
          final TheVisibility vis = generateVis(posterVisibility);
          final posterBlockedUser = await usersCollection
              .doc(poster)
              .collection('Blocked')
              .doc(myUsername)
              .get();

          final bool imBlocked = posterBlockedUser.exists;
          if (!feedPosts.any((post) => post.postID == postID)) {
            if (!tempPosts.any((post) => post.postID == postID)) {
              if (!imBlocked && !myBlockedIDs.contains(poster)) {
                final String description = getter('description');
                final serverpostedDate = getter('date').toDate();
                final int numOfLikes = getter('likes');
                final int numOfComments = getter('comments');
                final int numOfTopics = getter('topicCount');
                final bool sensitiveContent = getter('sensitive');
                final serverTopics = getter('topics') as List;
                final List<String> postTopics =
                    serverTopics.map((topic) => topic as String).toList();
                final serverimgUrls = getter('imgUrls') as List;
                final List<String> imgUrls =
                    serverimgUrls.map((url) => url as String).toList();
                final posterImg = posterUser.get('Avatar');
                final posterBio = posterUser.get('Bio');
                final posterNumOfLinks = posterUser.get('numOfLinks');
                final posterNumOfLinked = posterUser.get('numOfLinked');

                final FullHelper _instance = FullHelper();
                final key = UniqueKey();
                final PosterProfile _posterProfile = PosterProfile(
                    getUsername: poster,
                    getProfileImage: posterImg,
                    getBio: posterBio,
                    getNumberOflinks: posterNumOfLinks,
                    getNumberOfLinkedTos: posterNumOfLinked,
                    getVisibility: vis);
                final Post _post = Post(
                  key: key,
                  instance: _instance,
                  poster: _posterProfile,
                  description: description,
                  numOfLikes: numOfLikes,
                  numOfComments: numOfComments,
                  numOfTopics: numOfTopics,
                  sensitiveContent: sensitiveContent,
                  postID: postID,
                  postedDate: serverpostedDate,
                  topics: postTopics,
                  imgUrls: imgUrls,
                );
                _post.setter();
                tempPosts.add(_post);
                linkedPosts.add(_post);
              }
            }
          }
        }
      }
    }
    if (myTopics.isNotEmpty) {
      if (thetopicposts != null || thetopicposts.isNotEmpty) {
        for (var post in thetopicposts) {
          dynamic getter(String field) => post.get(field);
          final postID = post.id;
          final String poster = getter('poster');
          final posterUser = await usersCollection.doc(poster).get();
          final posterVisibility = posterUser.get('Visibility');
          final TheVisibility vis = generateVis(posterVisibility);
          final posterBlockedUser = await usersCollection
              .doc(poster)
              .collection('Blocked')
              .doc(myUsername)
              .get();

          final bool imBlocked = posterBlockedUser.exists;
          if (vis != TheVisibility.private &&
                  !imBlocked &&
                  !myBlockedIDs.contains(poster) ||
              myUsername.startsWith('Linkspeak')) {
            if (!feedPosts.any((post) => post.postID == postID)) {
              if (!tempPosts.any((post) => post.postID == postID)) {
                final String description = getter('description');
                final serverpostedDate = getter('date').toDate();
                final int numOfLikes = getter('likes');
                final int numOfComments = getter('comments');
                final int numOfTopics = getter('topicCount');
                final bool sensitiveContent = getter('sensitive');
                final serverTopics = getter('topics') as List;
                final List<String> postTopics =
                    serverTopics.map((topic) => topic as String).toList();
                final serverimgUrls = getter('imgUrls') as List;
                final List<String> imgUrls =
                    serverimgUrls.map((url) => url as String).toList();

                final posterImg = posterUser.get('Avatar');
                final posterBio = posterUser.get('Bio');
                final posterNumOfLinks = posterUser.get('numOfLinks');
                final posterNumOfLinked = posterUser.get('numOfLinked');

                final FullHelper _instance = FullHelper();
                final key = UniqueKey();
                final PosterProfile _posterProfile = PosterProfile(
                    getUsername: poster,
                    getProfileImage: posterImg,
                    getBio: posterBio,
                    getNumberOflinks: posterNumOfLinks,
                    getNumberOfLinkedTos: posterNumOfLinked,
                    getVisibility: vis);
                final Post _post = Post(
                  key: key,
                  instance: _instance,
                  poster: _posterProfile,
                  description: description,
                  numOfLikes: numOfLikes,
                  numOfComments: numOfComments,
                  numOfTopics: numOfTopics,
                  sensitiveContent: sensitiveContent,
                  postID: postID,
                  postedDate: serverpostedDate,
                  topics: postTopics,
                  imgUrls: imgUrls,
                );
                _post.setter();
                tempPosts.add(_post);
                topicPosts.add(_post);
              }
            }
          }
        }
      }
    }
    if (linkedListDocs.isEmpty && myTopics.isEmpty ||
        ((topicpostsCollection != null && thetopicposts.isEmpty ||
                (thetopicposts == null) ||
                topicpostsCollection == null) &&
            (linkedpostsCollection == null ||
                (linkedpostsCollection != null && theLinkedposts.isEmpty) ||
                theLinkedposts == null))) {
      final postsCollection = await firestore
          .collection('Posts')
          .where('sensitive', isEqualTo: false)
          .limit(16)
          .get();
      final theposts = postsCollection.docs;
      if (theposts.isNotEmpty) {
        for (var post in theposts) {
          dynamic getter(String field) => post.get(field);
          final postID = post.id;
          final String poster = getter('poster');
          final posterUser = await usersCollection.doc(poster).get();
          final posterVisibility = posterUser.get('Visibility');
          final TheVisibility vis = generateVis(posterVisibility);
          final posterBlockedUser = await usersCollection
              .doc(poster)
              .collection('Blocked')
              .doc(myUsername)
              .get();

          final bool imBlocked = posterBlockedUser.exists;
          if (vis != TheVisibility.private &&
                  !imBlocked &&
                  !myBlockedIDs.contains(poster) ||
              myUsername.startsWith('Linkspeak')) {
            if (!feedPosts.any((post) => post.postID == postID)) {
              if (!tempPosts.any((post) => post.postID == postID)) {
                final String description = getter('description');
                final serverpostedDate = getter('date').toDate();
                final int numOfLikes = getter('likes');
                final int numOfComments = getter('comments');
                final int numOfTopics = getter('topicCount');
                final bool sensitiveContent = getter('sensitive');
                final serverTopics = getter('topics') as List;
                final List<String> postTopics =
                    serverTopics.map((topic) => topic as String).toList();
                final serverimgUrls = getter('imgUrls') as List;
                final List<String> imgUrls =
                    serverimgUrls.map((url) => url as String).toList();
                final posterImg = posterUser.get('Avatar');
                final posterBio = posterUser.get('Bio');
                final posterNumOfLinks = posterUser.get('numOfLinks');
                final posterNumOfLinked = posterUser.get('numOfLinked');

                final FullHelper _instance = FullHelper();
                final key = UniqueKey();
                final PosterProfile _posterProfile = PosterProfile(
                    getUsername: poster,
                    getProfileImage: posterImg,
                    getBio: posterBio,
                    getNumberOflinks: posterNumOfLinks,
                    getNumberOfLinkedTos: posterNumOfLinked,
                    getVisibility: vis);
                final Post _post = Post(
                  key: key,
                  instance: _instance,
                  poster: _posterProfile,
                  description: description,
                  numOfLikes: numOfLikes,
                  numOfComments: numOfComments,
                  numOfTopics: numOfTopics,
                  sensitiveContent: sensitiveContent,
                  postID: postID,
                  postedDate: serverpostedDate,
                  topics: postTopics,
                  imgUrls: imgUrls,
                );
                _post.setter();
                tempPosts.add(_post);
                randomPosts.add(_post);
              }
            }
          }
        }
      }
    }
    tempPosts.sort((a, b) {
      final aDate = a.postedDate;
      final bDate = b.postedDate;
      return bDate.compareTo(aDate);
    });
    feedPosts.addAll([...tempPosts]);
    setPosts(feedPosts);
    if (feedPosts.isEmpty) {
      setState(() {
        noPostsFound = true;
      });
    }
  }

  Future<void> getMorePosts(
    final List<String> myTopics,
    void Function(List<Post>) setPosts,
    final List<String> myBlockedIDs,
  ) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<Post> tempPosts = [];
      final myUsername =
          Provider.of<MyProfile>(context, listen: false).getUsername;
      final usersCollection = firestore.collection('Users');
      // ignore: avoid_init_to_null
      dynamic topicpostsCollection = null;
      // ignore: avoid_init_to_null
      dynamic thetopicposts = null;
      // ignore: avoid_init_to_null
      dynamic linkedpostsCollection = null;
      // ignore: avoid_init_to_null
      dynamic theLinkedposts = null;
      List<QueryDocumentSnapshot<Map<String, dynamic>>> newOne = [];
      if (myTopics.isNotEmpty) {
        myTopics.shuffle();
        final newTopics = myTopics.take(10).toList();
        topicpostsCollection = await firestore
            .collection('Posts')
            .where('topics', arrayContainsAny: newTopics)
            .orderBy('date', descending: true)
            .limit(6)
            .get();
        thetopicposts = topicpostsCollection.docs;
      }
      if (linkedListString.isNotEmpty) {
        final lastLinked = linkedListString.last;
        final getLastLinked = await usersCollection
            .doc(myUsername)
            .collection('Linked')
            .doc(lastLinked)
            .get();
        final linkedList = await usersCollection
            .doc(myUsername)
            .collection('Linked')
            .startAfterDocument(getLastLinked)
            .limit(10)
            .get();
        final linkedListDocs = linkedList.docs;
        final List<String> newPeople = [];
        if (linkedListDocs.isNotEmpty) {
          for (var eleman in linkedList.docs) {
            linkedListString.add(eleman.id.toString());
            newPeople.add(eleman.id.toString());
          }
          linkedpostsCollection = await firestore
              .collection('Posts')
              .where('poster', whereIn: newPeople)
              .orderBy('date', descending: true)
              .limit(10)
              .get();
          theLinkedposts = linkedpostsCollection.docs;
          newOne = [...theLinkedposts];
          if (theLinkedposts.isNotEmpty) {
            for (var post in theLinkedposts) {
              dynamic getter(String field) => post.get(field);
              final postID = post.id;
              final String poster = getter('poster');
              final posterUser = await usersCollection.doc(poster).get();
              final posterVisibility = posterUser.get('Visibility');
              final TheVisibility vis = generateVis(posterVisibility);
              final posterBlockedUser = await usersCollection
                  .doc(poster)
                  .collection('Blocked')
                  .doc(myUsername)
                  .get();

              final bool imBlocked = posterBlockedUser.exists;
              if (!feedPosts.any((post) => post.postID == postID)) {
                if (!tempPosts.any((post) =>
                    post.postID == postID &&
                    !imBlocked &&
                    !myBlockedIDs.contains(poster))) {
                  final String description = getter('description');
                  final serverpostedDate = getter('date').toDate();
                  final int numOfLikes = getter('likes');
                  final int numOfComments = getter('comments');
                  final int numOfTopics = getter('topicCount');
                  final bool sensitiveContent = getter('sensitive');
                  final serverTopics = getter('topics') as List;
                  final List<String> postTopics =
                      serverTopics.map((topic) => topic as String).toList();
                  final serverimgUrls = getter('imgUrls') as List;
                  final List<String> imgUrls =
                      serverimgUrls.map((url) => url as String).toList();
                  final posterImg = posterUser.get('Avatar');
                  final posterBio = posterUser.get('Bio');
                  final posterNumOfLinks = posterUser.get('numOfLinks');
                  final posterNumOfLinked = posterUser.get('numOfLinked');

                  final FullHelper _instance = FullHelper();
                  final key = UniqueKey();
                  final PosterProfile _posterProfile = PosterProfile(
                      getUsername: poster,
                      getProfileImage: posterImg,
                      getBio: posterBio,
                      getNumberOflinks: posterNumOfLinks,
                      getNumberOfLinkedTos: posterNumOfLinked,
                      getVisibility: vis);
                  final Post _post = Post(
                    key: key,
                    instance: _instance,
                    poster: _posterProfile,
                    description: description,
                    numOfLikes: numOfLikes,
                    numOfComments: numOfComments,
                    numOfTopics: numOfTopics,
                    sensitiveContent: sensitiveContent,
                    postID: postID,
                    postedDate: serverpostedDate,
                    topics: postTopics,
                    imgUrls: imgUrls,
                  );
                  _post.setter();
                  tempPosts.add(_post);
                  linkedPosts.add(_post);
                }
              }
            }
          }
        }
      }
      if (myTopics.isNotEmpty) {
        if (thetopicposts != null || thetopicposts.isNotEmpty) {
          for (var post in thetopicposts) {
            dynamic getter(String field) => post.get(field);
            final postID = post.id;
            final String poster = getter('poster');
            final posterUser = await usersCollection.doc(poster).get();
            final posterVisibility = posterUser.get('Visibility');
            final TheVisibility vis = generateVis(posterVisibility);
            final posterBlockedUser = await usersCollection
                .doc(poster)
                .collection('Blocked')
                .doc(myUsername)
                .get();

            final bool imBlocked = posterBlockedUser.exists;
            if (vis != TheVisibility.private &&
                    !imBlocked &&
                    !myBlockedIDs.contains(poster) ||
                myUsername.startsWith('Linkspeak')) {
              if (!feedPosts.any((post) => post.postID == postID)) {
                if (!tempPosts.any((post) => post.postID == postID)) {
                  final String description = getter('description');
                  final serverpostedDate = getter('date').toDate();
                  final int numOfLikes = getter('likes');
                  final int numOfComments = getter('comments');
                  final int numOfTopics = getter('topicCount');
                  final bool sensitiveContent = getter('sensitive');
                  final serverTopics = getter('topics') as List;
                  final List<String> postTopics =
                      serverTopics.map((topic) => topic as String).toList();
                  final serverimgUrls = getter('imgUrls') as List;
                  final List<String> imgUrls =
                      serverimgUrls.map((url) => url as String).toList();

                  final posterImg = posterUser.get('Avatar');
                  final posterBio = posterUser.get('Bio');
                  final posterNumOfLinks = posterUser.get('numOfLinks');
                  final posterNumOfLinked = posterUser.get('numOfLinked');

                  final FullHelper _instance = FullHelper();
                  final key = UniqueKey();
                  final PosterProfile _posterProfile = PosterProfile(
                      getUsername: poster,
                      getProfileImage: posterImg,
                      getBio: posterBio,
                      getNumberOflinks: posterNumOfLinks,
                      getNumberOfLinkedTos: posterNumOfLinked,
                      getVisibility: vis);
                  final Post _post = Post(
                    key: key,
                    instance: _instance,
                    poster: _posterProfile,
                    description: description,
                    numOfLikes: numOfLikes,
                    numOfComments: numOfComments,
                    numOfTopics: numOfTopics,
                    sensitiveContent: sensitiveContent,
                    postID: postID,
                    postedDate: serverpostedDate,
                    topics: postTopics,
                    imgUrls: imgUrls,
                  );
                  _post.setter();
                  tempPosts.add(_post);
                  topicPosts.add(_post);
                }
              }
            }
          }
        }
      }

      if (newOne.isEmpty && myTopics.isEmpty ||
          ((topicpostsCollection != null && thetopicposts.isEmpty ||
                  (thetopicposts == null) ||
                  topicpostsCollection == null) &&
              (linkedpostsCollection == null ||
                  (linkedpostsCollection != null && theLinkedposts.isEmpty) ||
                  theLinkedposts == null))) {
        if (randomPosts.isNotEmpty) {
          final lastPostID = randomPosts.last.postID;
          final getLastPost =
              await firestore.collection('Posts').doc(lastPostID).get();
          final postsCollection = await firestore
              .collection('Posts')
              .where('sensitive', isEqualTo: false)
              .startAfterDocument(getLastPost)
              .limit(16)
              .get();
          final theposts = postsCollection.docs;
          if (theposts.isNotEmpty) {
            for (var post in theposts) {
              dynamic getter(String field) => post.get(field);
              final postID = post.id;
              final String poster = getter('poster');
              final posterUser = await usersCollection.doc(poster).get();
              final posterVisibility = posterUser.get('Visibility');
              final TheVisibility vis = generateVis(posterVisibility);
              final posterBlockedUser = await usersCollection
                  .doc(poster)
                  .collection('Blocked')
                  .doc(myUsername)
                  .get();

              final bool imBlocked = posterBlockedUser.exists;
              if (vis != TheVisibility.private &&
                      !imBlocked &&
                      !myBlockedIDs.contains(poster) ||
                  myUsername.startsWith('Linkspeak')) {
                if (!feedPosts.any((post) => post.postID == postID)) {
                  if (!tempPosts.any((post) => post.postID == postID)) {
                    final String description = getter('description');
                    final serverpostedDate = getter('date').toDate();
                    final int numOfLikes = getter('likes');
                    final int numOfComments = getter('comments');
                    final int numOfTopics = getter('topicCount');
                    final bool sensitiveContent = getter('sensitive');
                    final serverTopics = getter('topics') as List;
                    final List<String> postTopics =
                        serverTopics.map((topic) => topic as String).toList();
                    final serverimgUrls = getter('imgUrls') as List;
                    final List<String> imgUrls =
                        serverimgUrls.map((url) => url as String).toList();
                    final posterImg = posterUser.get('Avatar');
                    final posterBio = posterUser.get('Bio');
                    final posterNumOfLinks = posterUser.get('numOfLinks');
                    final posterNumOfLinked = posterUser.get('numOfLinked');

                    final FullHelper _instance = FullHelper();
                    final key = UniqueKey();
                    final PosterProfile _posterProfile = PosterProfile(
                        getUsername: poster,
                        getProfileImage: posterImg,
                        getBio: posterBio,
                        getNumberOflinks: posterNumOfLinks,
                        getNumberOfLinkedTos: posterNumOfLinked,
                        getVisibility: vis);
                    final Post _post = Post(
                      key: key,
                      instance: _instance,
                      poster: _posterProfile,
                      description: description,
                      numOfLikes: numOfLikes,
                      numOfComments: numOfComments,
                      numOfTopics: numOfTopics,
                      sensitiveContent: sensitiveContent,
                      postID: postID,
                      postedDate: serverpostedDate,
                      topics: postTopics,
                      imgUrls: imgUrls,
                    );
                    _post.setter();
                    tempPosts.add(_post);
                    randomPosts.add(_post);
                  }
                }
              }
            }
          }
        } else {
          final postsCollection = await firestore
              .collection('Posts')
              .where('sensitive', isEqualTo: false)
              .limit(16)
              .get();
          final theposts = postsCollection.docs;
          if (theposts.isNotEmpty) {
            for (var post in theposts) {
              dynamic getter(String field) => post.get(field);
              final postID = post.id;
              final String poster = getter('poster');
              final posterUser = await usersCollection.doc(poster).get();
              final posterVisibility = posterUser.get('Visibility');
              final TheVisibility vis = generateVis(posterVisibility);
              final posterBlockedUser = await usersCollection
                  .doc(poster)
                  .collection('Blocked')
                  .doc(myUsername)
                  .get();

              final bool imBlocked = posterBlockedUser.exists;
              if (vis != TheVisibility.private &&
                      !imBlocked &&
                      !myBlockedIDs.contains(poster) ||
                  myUsername.startsWith('Linkspeak')) {
                if (!feedPosts.any((post) => post.postID == postID)) {
                  if (!tempPosts.any((post) => post.postID == postID)) {
                    final String description = getter('description');
                    final serverpostedDate = getter('date').toDate();
                    final int numOfLikes = getter('likes');
                    final int numOfComments = getter('comments');
                    final int numOfTopics = getter('topicCount');
                    final bool sensitiveContent = getter('sensitive');
                    final serverTopics = getter('topics') as List;
                    final List<String> postTopics =
                        serverTopics.map((topic) => topic as String).toList();
                    final serverimgUrls = getter('imgUrls') as List;
                    final List<String> imgUrls =
                        serverimgUrls.map((url) => url as String).toList();
                    final posterImg = posterUser.get('Avatar');
                    final posterBio = posterUser.get('Bio');
                    final posterNumOfLinks = posterUser.get('numOfLinks');
                    final posterNumOfLinked = posterUser.get('numOfLinked');

                    final FullHelper _instance = FullHelper();
                    final key = UniqueKey();
                    final PosterProfile _posterProfile = PosterProfile(
                        getUsername: poster,
                        getProfileImage: posterImg,
                        getBio: posterBio,
                        getNumberOflinks: posterNumOfLinks,
                        getNumberOfLinkedTos: posterNumOfLinked,
                        getVisibility: vis);
                    final Post _post = Post(
                      key: key,
                      instance: _instance,
                      poster: _posterProfile,
                      description: description,
                      numOfLikes: numOfLikes,
                      numOfComments: numOfComments,
                      numOfTopics: numOfTopics,
                      sensitiveContent: sensitiveContent,
                      postID: postID,
                      postedDate: serverpostedDate,
                      topics: postTopics,
                      imgUrls: imgUrls,
                    );
                    _post.setter();
                    tempPosts.add(_post);
                    randomPosts.add(_post);
                  }
                }
              }
            }
          }
        }
      }
      tempPosts.sort((a, b) {
        final aDate = a.postedDate;
        final bDate = b.postedDate;
        return bDate.compareTo(aDate);
      });
      feedPosts.addAll([...tempPosts]);
      setPosts(feedPosts);
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final void Function(List<Post>) setPosts =
        Provider.of<FeedProvider>(context, listen: false).setPosts;
    final void Function() clearPosts =
        Provider.of<FeedProvider>(context, listen: false).clearPosts;
    final List<String> myTopics =
        Provider.of<MyProfile>(context, listen: false).getTopics;
    final List<String> myBlocked =
        Provider.of<MyProfile>(context, listen: false).getBlockedIDs;
    _getPosts = getPosts(myTopics, setPosts, myBlocked, false, clearPosts);
    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (!isLoading) {
            getMorePosts(myTopics, setPosts, myBlocked);
          }
        }
      }
    });
  }

  Future<void> _pullRefresh(
    List<String> myTopics,
    List<String> myBlocked,
    void Function(List<Post>) setPosts,
    void Function() clear,
  ) async {
    setState(() {
      _getPosts = getPosts(myTopics, setPosts, myBlocked, true, clear);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<String> myBlocked =
        Provider.of<MyProfile>(context, listen: false).getBlockedIDs;
    const String _logoAddress = 'assets/images/noposts.svg';
    final Color _primarySwatch = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    const ScrollPhysics _always = const AlwaysScrollableScrollPhysics();
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final void Function() clearPosts =
        Provider.of<FeedProvider>(context, listen: false).clearPosts;
    final void Function(List<Post>) setPosts =
        Provider.of<FeedProvider>(context, listen: false).setPosts;
    final List<String> myTopics =
        Provider.of<MyProfile>(context, listen: false).getTopics;
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    super.build(context);
    return FutureBuilder(
      key: PageStorageKey<String>('FUTURE'),
      future: _getPosts,
      builder: (context, snapshot) {
        final _posts = Provider.of<FeedProvider>(context).posts;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: _deviceHeight,
            width: _deviceWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[const CircularProgressIndicator()],
            ),
          );
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return SizedBox(
            height: _deviceHeight,
            width: _deviceWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'An error has occured',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Container(
                      width: 100.0,
                      padding: const EdgeInsets.all(5.0),
                      child: TextButton(
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry?>(
                            const EdgeInsets.symmetric(
                              vertical: 1.0,
                              horizontal: 5.0,
                            ),
                          ),
                          enableFeedback: false,
                          backgroundColor:
                              MaterialStateProperty.all<Color?>(_primarySwatch),
                        ),
                        onPressed: () {
                          _pullRefresh(
                              myTopics, myBlocked, setPosts, clearPosts);
                        },
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 19.0,
                            color: _accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        if (noPostsFound) {
          return SizedBox(
            height: _deviceHeight,
            width: _deviceWidth,
            child: RefreshIndicator(
              key: UniqueKey(),
              backgroundColor: _primarySwatch,
              displacement: 40.0,
              color: _accentColor,
              onRefresh: () => Future.delayed(
                  const Duration(milliseconds: 1300),
                  () =>
                      _pullRefresh(myTopics, myBlocked, setPosts, clearPosts)),
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Spacer(),
                        Center(
                          child: SvgPicture.asset(
                            _logoAddress,
                            height: _deviceHeight * 0.15,
                            width: _deviceWidth * 0.15,
                          ),
                        ),
                        Center(
                          child: OptimisedText(
                            minWidth: _deviceWidth * 0.50,
                            maxWidth: _deviceWidth * 0.50,
                            minHeight: _deviceHeight * 0.05,
                            maxHeight: _deviceHeight * 0.10,
                            fit: BoxFit.scaleDown,
                            child: const Text(
                              "No Posts found",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                        ),
                        _suggested,
                        const Spacer()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final Widget _feedList = ListView.separated(
          key: PageStorageKey<String>('FeedStore'),
          padding: EdgeInsets.only(
            top: _deviceHeight * 0.05,
            bottom: 85.0,
          ),
          physics: _always,
          controller: scrollController,
          itemCount: _posts.length + 1,
          separatorBuilder: (ctx, index) {
            var remainder = index % 4;
            if (remainder == 0)
              return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 10.0,
                  ),
                  child: const NativeAds());
            return emptyBox;
          },
          itemBuilder: (context, index) {
            if (index == _posts.length) {
              if (isLoading) {
                return Center(
                  child: SizedBox(
                    height: 35.0,
                    width: 35.0,
                    child: Center(
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                );
              }
            } else {
              if (index == 6) {
                return _suggested;
              }
              final _currentPost = _posts[index];
              final FullHelper _instance = _currentPost.instance;
              const PostWidget _post = PostWidget(
                isInFeed: true,
                isInLike: false,
                isInFav: false,
                isInTab: false,
                isInMyTab: false,
                isInOtherTab: false,
                isInTopics: false,
                otherController: null,
                topicScreenController: null,
              );

              return ChangeNotifierProvider<FullHelper>.value(
                value: _instance,
                child: _post,
              );
            }
            return emptyBox;
          },
        );
        return RefreshIndicator(
            backgroundColor: _primarySwatch,
            displacement: 2.0,
            color: _accentColor,
            onRefresh: () => Future.delayed(const Duration(milliseconds: 1300),
                () => _pullRefresh(myTopics, myBlocked, setPosts, clearPosts)),
            child: _feedList);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
