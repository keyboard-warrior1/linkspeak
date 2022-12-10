import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/postsLoading.dart';
import '../models/post.dart';
import '../models/posterProfile.dart';
import '../models/profile.dart';
import '../providers/appBarProvider.dart';
import '../providers/feedProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import '../screens/feedScreen.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/misc/ads.dart';
import '../widgets/misc/suggestedWidget.dart';
import '../widgets/post/postWidget.dart';

class Feed extends StatefulWidget {
  const Feed();
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = FeedScreen.scrollController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const Widget _suggested = const SuggestedWidget(false, false, false);
  List<Post> feedPosts = [];
  List<Post> topicPosts = [];
  List<Post> linkedPosts = [];
  List<Post> randomPosts = [];
  late Future _getPosts;
  bool noPostsFound = false;
  bool isLoading = false;
  List<String> linkedListString = [];
  void initializePost(
      {required bool isLinkedPost,
      required bool isTopicPost,
      required bool isRandomPost,
      required List<Post> tempPosts,
      required String postID}) {
    final FullHelper _instance = FullHelper();
    final key = UniqueKey();
    final PosterProfile _posterProfile =
        PosterProfile(getUsername: '', getVisibility: TheVisibility.public);
    final Post _post = Post(
        key: key,
        instance: _instance,
        commentsDisabled: false,
        poster: _posterProfile,
        description: '',
        numOfLikes: 0,
        numOfComments: 0,
        numOfTopics: 0,
        sensitiveContent: false,
        postID: postID,
        postedDate: DateTime.now(),
        topics: [],
        imgUrls: [],
        location: '',
        locationName: '',
        isClubPost: false,
        clubName: '',
        isLiked: false,
        isFav: false,
        isHidden: false,
        isMod: false,
        postType: PostType.legacy,
        items: [],
        backgroundColor: Colors.blue,
        gradientColor: Colors.yellow);
    _post.setter();
    tempPosts.add(_post);
    if (isLinkedPost) linkedPosts.add(_post);
    if (isTopicPost) topicPosts.add(_post);
    if (isRandomPost) randomPosts.add(_post);
  }

  Future<void> getPosts(
      final List<String> myTopics,
      void Function(List<Post>) setPosts,
      bool clearPosts,
      void Function() clear) async {
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
    // ignore: avoid_init_to_null
    dynamic linkedListDocs = null;

    if (myTopics.isNotEmpty) {
      myTopics.shuffle();
      final newTopics = myTopics.take(10).toList();
      topicpostsCollection = await firestore
          .collection('Posts')
          .where('topics', arrayContainsAny: newTopics)
          .where('clubName', isEqualTo: '')
          .orderBy('date', descending: true)
          .limit(12)
          .get();
      thetopicposts = topicpostsCollection.docs;
    }
    for (var i = 0; i < 2; i++) {
      if (linkedListString.isEmpty) {
        final linkedList = await usersCollection
            .doc(myUsername)
            .collection('Linked')
            .orderBy('date', descending: true)
            .limit(10)
            .get();
        linkedListDocs = linkedList.docs;
        final List<String> currentLinked = [];
        if (linkedListDocs.isNotEmpty) {
          linkedListDocs.forEach((element) {
            final id = element.id;
            linkedListString.add(id);
            currentLinked.add(id);
          });
          linkedpostsCollection = await firestore
              .collection('Posts')
              .where('poster', whereIn: currentLinked)
              .where('clubName', isEqualTo: '')
              .orderBy('date', descending: true)
              .limit(20)
              .get();
          theLinkedposts = linkedpostsCollection.docs;
          if (theLinkedposts.isNotEmpty) {
            for (var post in theLinkedposts) {
              final postID = post.id;
              if (!feedPosts.any((post) => post.postID == postID)) {
                if (!tempPosts.any((post) => post.postID == postID)) {
                  initializePost(
                      isLinkedPost: true,
                      isTopicPost: false,
                      isRandomPost: false,
                      tempPosts: tempPosts,
                      postID: postID);
                }
              }
            }
          }
        }
      } else {
        final lastID = linkedListString.last;
        final getLastLinked = await usersCollection
            .doc(myUsername)
            .collection('Linked')
            .doc(lastID)
            .get();
        final getNextLinked = await usersCollection
            .doc(myUsername)
            .collection('Linked')
            .orderBy('date', descending: true)
            .startAfterDocument(getLastLinked)
            .limit(10)
            .get();
        linkedListDocs = getNextLinked.docs;
        final List<String> currentLinked = [];
        if (linkedListDocs.isNotEmpty) {
          linkedListDocs.forEach((element) {
            final id = element.id;
            linkedListString.add(id);
            currentLinked.add(id);
          });
          linkedpostsCollection = await firestore
              .collection('Posts')
              .where('poster', whereIn: currentLinked)
              .where('clubName', isEqualTo: '')
              .orderBy('date', descending: true)
              .limit(20)
              .get();
          theLinkedposts = linkedpostsCollection.docs;
          if (theLinkedposts.isNotEmpty) {
            for (var post in theLinkedposts) {
              final postID = post.id;
              if (!feedPosts.any((post) => post.postID == postID) &&
                  !tempPosts.any((post) => post.postID == postID)) {
                initializePost(
                    isLinkedPost: true,
                    isTopicPost: false,
                    isRandomPost: false,
                    tempPosts: tempPosts,
                    postID: postID);
              }
            }
          }
        }
      }
    }
    if (myTopics.isNotEmpty) {
      if (thetopicposts != null || thetopicposts.isNotEmpty) {
        for (var post in thetopicposts) {
          final postID = post.id;
          if (!feedPosts.any((post) => post.postID == postID)) {
            if (!tempPosts.any((post) => post.postID == postID)) {
              initializePost(
                  isLinkedPost: false,
                  isTopicPost: true,
                  isRandomPost: false,
                  tempPosts: tempPosts,
                  postID: postID);
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
          .where('clubName', isEqualTo: '')
          .limit(40)
          .get();
      final theposts = postsCollection.docs;
      if (theposts.isNotEmpty) {
        for (var post in theposts) {
          final postID = post.id;
          if (!feedPosts.any((post) => post.postID == postID)) {
            if (!tempPosts.any((post) => post.postID == postID)) {
              initializePost(
                  isLinkedPost: false,
                  isTopicPost: false,
                  isRandomPost: true,
                  tempPosts: tempPosts,
                  postID: postID);
            }
          }
        }
      }
    }
    feedPosts.addAll(tempPosts);
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
            .where('clubName', isEqualTo: '')
            .orderBy('date', descending: true)
            .limit(12)
            .get();
        thetopicposts = topicpostsCollection.docs;
      }
      if (linkedListString.isNotEmpty) {
        for (var i = 0; i < 2; i++) {
          final lastID = linkedListString.last;
          final getLastLinked = await usersCollection
              .doc(myUsername)
              .collection('Linked')
              .doc(lastID)
              .get();
          final getNextLinked = await usersCollection
              .doc(myUsername)
              .collection('Linked')
              .orderBy('date', descending: true)
              .startAfterDocument(getLastLinked)
              .limit(10)
              .get();
          final docs = getNextLinked.docs;
          final List<String> currentLinked = [];
          if (docs.isNotEmpty) {
            docs.forEach((element) {
              final id = element.id;
              linkedListString.add(id);
              currentLinked.add(id);
            });
            linkedpostsCollection = await firestore
                .collection('Posts')
                .where('poster', whereIn: currentLinked)
                .where('clubName', isEqualTo: '')
                .orderBy('date', descending: true)
                .limit(20)
                .get();
            theLinkedposts = linkedpostsCollection.docs;
            newOne = theLinkedposts;
            if (theLinkedposts.isNotEmpty) {
              for (var post in theLinkedposts) {
                final postID = post.id;
                if (!feedPosts.any((post) => post.postID == postID) &&
                    !tempPosts.any((post) => post.postID == postID)) {
                  initializePost(
                      isLinkedPost: true,
                      isTopicPost: false,
                      isRandomPost: false,
                      tempPosts: tempPosts,
                      postID: postID);
                }
              }
            }
          }
        }
      }

      if (myTopics.isNotEmpty) {
        if (thetopicposts != null || thetopicposts.isNotEmpty) {
          for (var post in thetopicposts) {
            final postID = post.id;
            if (!feedPosts.any((post) => post.postID == postID)) {
              if (!tempPosts.any((post) => post.postID == postID)) {
                initializePost(
                    isLinkedPost: false,
                    isTopicPost: true,
                    isRandomPost: false,
                    tempPosts: tempPosts,
                    postID: postID);
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
              .where('clubName', isEqualTo: '')
              .startAfterDocument(getLastPost)
              .limit(40)
              .get();
          final theposts = postsCollection.docs;
          if (theposts.isNotEmpty) {
            for (var post in theposts) {
              final postID = post.id;
              if (!feedPosts.any((post) => post.postID == postID)) {
                if (!tempPosts.any((post) => post.postID == postID)) {
                  initializePost(
                      isLinkedPost: false,
                      isTopicPost: false,
                      isRandomPost: true,
                      tempPosts: tempPosts,
                      postID: postID);
                }
              }
            }
          }
        } else {
          final postsCollection = await firestore
              .collection('Posts')
              .where('sensitive', isEqualTo: false)
              .where('clubName', isEqualTo: '')
              .limit(40)
              .get();
          final theposts = postsCollection.docs;
          if (theposts.isNotEmpty) {
            for (var post in theposts) {
              final postID = post.id;
              if (!feedPosts.any((post) => post.postID == postID)) {
                if (!tempPosts.any((post) => post.postID == postID)) {
                  initializePost(
                      isLinkedPost: false,
                      isTopicPost: false,
                      isRandomPost: true,
                      tempPosts: tempPosts,
                      postID: postID);
                }
              }
            }
          }
        }
      }
      feedPosts.addAll(tempPosts);
      setPosts(feedPosts);
      isLoading = false;
      setState(() {});
      View viewMode =
          Provider.of<AppBarProvider>(context, listen: false).viewMode;
      Scroll scrollMode =
          Provider.of<AppBarProvider>(context, listen: false).scrollMode;
      int _speedFactor =
          Provider.of<AppBarProvider>(context, listen: false).speedFactor;
      if (scrollMode == Scroll.scrolling && viewMode == View.autoScroll) {
        Future.delayed(const Duration(milliseconds: 100),
            () => FeedScreen.scrollDown(_speedFactor, false));
      }
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
    _getPosts = getPosts(myTopics, setPosts, false, clearPosts);
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if(!kIsWeb && Platform.isIOS){
    messaging.requestPermission(alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);}
    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (!isLoading) {
            getMorePosts(myTopics, setPosts);
          }
        }
      }
    });
  }

  Future<void> _pullRefresh(
    List<String> myTopics,
    void Function(List<Post>) setPosts,
    void Function() clear,
  ) async {
    setState(() {
      _getPosts = getPosts(myTopics, setPosts, true, clear);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    const String _logoAddress = 'assets/images/noposts.svg';
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    const ScrollPhysics _always = const AlwaysScrollableScrollPhysics();
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
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
        if (snapshot.connectionState == ConnectionState.waiting)
          return SizedBox(
              height: _deviceHeight,
              width: _deviceWidth,
              child: const PostsLoading(true));

        if (snapshot.hasError)
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
                          const Text('An error has occured',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 17.0)),
                          const SizedBox(width: 10.0),
                          Container(
                              width: 100.0,
                              padding: const EdgeInsets.all(5.0),
                              child: TextButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry?>(
                                        const EdgeInsets.symmetric(
                                            vertical: 1.0, horizontal: 5.0)),
                                    enableFeedback: false,
                                    shape: MaterialStateProperty.all<
                                            OutlinedBorder?>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0))),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color?>(
                                            _primarySwatch),
                                  ),
                                  onPressed: () {
                                    _pullRefresh(
                                        myTopics, setPosts, clearPosts);
                                  },
                                  child: Text('Retry',
                                      style: TextStyle(
                                          fontSize: 19.0,
                                          color: _accentColor))))
                        ])
                  ]));

        if (noPostsFound)
          return SizedBox(
              height: _deviceHeight,
              width: _deviceWidth,
              child: RefreshIndicator(
                  key: UniqueKey(),
                  backgroundColor: _primarySwatch,
                  displacement: 40.0,
                  color: _accentColor,
                  onRefresh: () => _pullRefresh(myTopics, setPosts, clearPosts),
                  child: ListView(children: <Widget>[
                    SizedBox(
                        height: _deviceHeight,
                        width: _deviceWidth,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Spacer(),
                              Center(
                                  child: SvgPicture.asset(_logoAddress,
                                      height: _deviceHeight * 0.15,
                                      width: _deviceWidth * 0.15)),
                              Center(
                                  child: OptimisedText(
                                      minWidth: _deviceWidth * 0.50,
                                      maxWidth: _deviceWidth * 0.50,
                                      minHeight: _deviceHeight * 0.05,
                                      maxHeight: _deviceHeight * 0.10,
                                      fit: BoxFit.scaleDown,
                                      child: const Text("No Posts found",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 25.0)))),
                              _suggested,
                              const Spacer()
                            ]))
                  ])));

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
                      vertical: 0.0, horizontal: 10.0),
                  child: const NativeAds());
            if (index == 6) return _suggested;
            return emptyBox;
          },
          itemBuilder: (context, index) {
            if (index == _posts.length) {
              if (isLoading) return emptyBox;
            } else {
              final _currentPost = _posts[index];
              final FullHelper _instance = _currentPost.instance;
              const PostWidget _post = const PostWidget(
                  isInFeed: true,
                  isInLike: false,
                  isInFav: false,
                  isInTab: false,
                  isInMyTab: false,
                  isInOtherTab: false,
                  isInPeopleTopics: false,
                  isInClubTopics: false,
                  isInPeoplePlaces: false,
                  isInClubPlaces: false,
                  isInClubPosts: false,
                  isInFavClubs: false,
                  isInLikedClubs: false,
                  isInClubFeed: false,
                  isInPeopleAdmin: false,
                  isInClubAdmin: false);

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
            onRefresh: () => _pullRefresh(myTopics, setPosts, clearPosts),
            child: _feedList);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
