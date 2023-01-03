// ignore_for_file: unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../loading/postsLoading.dart';
import '../../models/post.dart';
import '../../models/posterProfile.dart';
import '../../models/profile.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/placesScreenProvider.dart';
import '../../providers/themeModel.dart';
import '../common/adaptiveText.dart';
import '../common/myFab.dart';
import '../common/noglow.dart';
import '../misc/ads.dart';
import '../misc/suggestedWidget.dart';
import '../post/postWidget.dart';

class PlacePostList extends StatefulWidget {
  final bool isClubTab;
  const PlacePostList(this.isClubTab);

  @override
  _PlacePostListState createState() => _PlacePostListState();
}

class _PlacePostListState extends State<PlacePostList>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  void Function() _disposeScrollController = () {};
  String topicName = '';
  String sessionID = '';
  String myName = '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Post> feedPosts = [];
  bool noPostsFound = false;
  late Future _getPosts;
  late Future<void> _viewPlace;
  late Future<void> _initSession;
  late Future<void> _endSession;
  bool isLoading = false;
  bool isLastPage = false;
  Future<void> initSession(String myUsername, String place) async {
    var batch = firestore.batch();
    final _rightNow = DateTime.now();
    final placesCollection = firestore.collection('Places');
    final thisPlace = placesCollection.doc(place);
    final sessions = thisPlace.collection('Sessions');
    final mySession = await sessions.doc(myUsername).get();
    final hasSession = mySession.exists;
    if (!hasSession) {
      final options = SetOptions(merge: true);
      batch.set(sessions.doc(myUsername), {'start': _rightNow}, options);
      batch.set(thisPlace, {'sessions': FieldValue.increment(1)}, options);
    }
    return batch.commit();
  }

  Future<void> endSession(String myUsername, String place) async {
    final _rightNow = DateTime.now();
    var batch = firestore.batch();
    final options = SetOptions(merge: true);
    final placesCollection = firestore.collection('Places');
    final thisPlace = placesCollection.doc(place);
    final placeViewers = thisPlace.collection('Viewers');
    final myPlaceSessions = placeViewers.doc(myUsername).collection('Sessions');
    final thisSession = await myPlaceSessions.doc(sessionID).get();
    final thisSessionExists = thisSession.exists;
    final sessions = thisPlace.collection('Sessions');
    final mySession = await sessions.doc(myUsername).get();
    final hasSession = mySession.exists;
    if (hasSession) {
      batch.delete(sessions.doc(myUsername));
      batch.set(thisPlace, {'sessions': FieldValue.increment(-1)}, options);
    }
    if (thisSessionExists) {
      batch.set(myPlaceSessions.doc(sessionID), {'end': _rightNow}, options);
    }
    return batch.commit();
  }

  Future<void> viewPlace(String myUsername, String place) async {
    var batch = firestore.batch();
    final _rightNow = DateTime.now();
    final _sessionID = _rightNow.toString();
    sessionID = _sessionID;
    final usersCollection = firestore.collection('Users');
    final placesCollection = firestore.collection('Places');
    final myUser = usersCollection.doc(myUsername);
    final myViewedPlaces = myUser.collection('Viewed Places');
    final thisMyViewed = await myViewedPlaces.doc(place).get();
    final alreadySeen = thisMyViewed.exists;
    final thisPlace = placesCollection.doc(place);
    final placeViewers = thisPlace.collection('Viewers');
    final myViewerDoc = await placeViewers.doc(myUsername).get();
    final isViewed = myViewerDoc.exists;
    final initialData = {
      'place': place,
      'first viewed': _rightNow,
      'times': FieldValue.increment(1),
      'ID': myUsername,
    };
    final existingData = {
      'times': FieldValue.increment(1),
      'last viewed': _rightNow
    };
    final options = SetOptions(merge: true);
    if (alreadySeen) {
      batch.set(myViewedPlaces.doc(place), existingData, options);
    } else {
      batch.set(myViewedPlaces.doc(place), initialData, options);
      batch.set(myUser, {'seen places': FieldValue.increment(1)}, options);
    }
    if (isViewed) {
      batch.set(placeViewers.doc(myUsername), existingData, options);
      batch.set(
          placeViewers.doc(myUsername).collection('Sessions').doc(_sessionID),
          {'start': _rightNow},
          options);
    } else {
      batch.set(placeViewers.doc(myUsername), initialData, options);
      batch.set(
          placeViewers.doc(myUsername).collection('Sessions').doc(_sessionID),
          {'start': _rightNow},
          options);
      batch.set(thisPlace, {'viewers': FieldValue.increment(1)}, options);
    }
    Map<String, dynamic> fields = {'viewed places': FieldValue.increment(1)};
    Map<String, dynamic> docFields = {
      'placeName': place,
      'date': _rightNow,
      'times': FieldValue.increment(1)
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'viewed places',
        docID: place,
        docFields: docFields);
    return batch.commit();
  }

  void initializePost({required String postID, required List<Post> tempPosts}) {
    if (!tempPosts.any((post) => post.postID == postID)) {
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
          clubName: '',
          isClubPost: false,
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
    }
  }

  Future<void> getPosts(String myUsername, String topic) async {
    List<Post> tempPosts = [];
    final postsCollection = widget.isClubTab
        ? await firestore
            .collection('Places')
            .doc(topic)
            .collection('posts')
            .where('clubName', isNotEqualTo: '')
            // .orderBy('date', descending: true)
            .limit(20)
            .get()
        : await firestore
            .collection('Places')
            .doc(topic)
            .collection('posts')
            .where('clubName', isEqualTo: '')
            .orderBy('date', descending: true)
            .limit(20)
            .get();
    final theposts = postsCollection.docs;
    if (theposts.isEmpty) {
      setState(() {
        noPostsFound = true;
      });
    } else {
      for (var postId in theposts) {
        final postID = postId.id;
        initializePost(postID: postID, tempPosts: tempPosts);
      }
      feedPosts.addAll(tempPosts);
      if (theposts.length < 20) {
        isLastPage = true;
      }
      setState(() {});
    }
  }

  Future<void> getMorePosts(String myUsername, String topic) async {
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      List<Post> tempPosts = [];
      final lastPostID = feedPosts.last.postID;
      final getLastDoc =
          await firestore.collection('Posts').doc(lastPostID).get();
      final postsCollection = widget.isClubTab
          ? await firestore
              .collection('Places')
              .doc(topic)
              .collection('posts')
              .where('clubName', isNotEqualTo: '')
              // .orderBy('date', descending: true)
              .startAfterDocument(getLastDoc)
              .limit(20)
              .get()
          : await firestore
              .collection('Places')
              .doc(topic)
              .collection('posts')
              .where('clubName', isEqualTo: '')
              .orderBy('date', descending: true)
              .startAfterDocument(getLastDoc)
              .limit(20)
              .get();
      final theposts = postsCollection.docs;
      if (theposts.isNotEmpty) {
        for (var postId in theposts) {
          final postID = postId.id;
          initializePost(postID: postID, tempPosts: tempPosts);
        }
      }
      feedPosts.addAll(tempPosts);
      if (theposts.length < 20) {
        isLastPage = true;
      }
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final helper = Provider.of<PlacesScreenProvider>(context, listen: false);
    topicName = helper.placeName;
    myName = myUsername;
    if (!widget.isClubTab) _initSession = initSession(myUsername, topicName);
    if (!widget.isClubTab) _viewPlace = viewPlace(myUsername, topicName);
    _getPosts = getPosts(myUsername, topicName);
    _scrollController = widget.isClubTab
        ? helper.getClubController
        : helper.getScrollController;
    _disposeScrollController = widget.isClubTab
        ? helper.disposeClubController
        : helper.disposeScrollController;
    // final mapHandler = helper.mapHandler;
    _scrollController.addListener(() {
      // final direction = _scrollController.position.userScrollDirection;
      // if (direction == ScrollDirection.reverse) mapHandler(false);
      // if (direction == ScrollDirection.forward) mapHandler(true);
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMorePosts(myUsername, topicName);
          }
        }
      }
    });
  }

  Future<void> _pullRefresh(
      String myUsername, void Function() clearPosts, String topic) async {
    isLastPage = false;
    feedPosts.clear();
    clearPosts();
    setState(() {
      _getPosts = getPosts(myUsername, topic);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (!widget.isClubTab) _endSession = endSession(myName, topicName);
    _scrollController.removeListener(() {});
    _disposeScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    const String _logoAddress = 'assets/images/noposts.svg';
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final _suggested = SuggestedWidget(false, false, true);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    const ScrollPhysics _always = const AlwaysScrollableScrollPhysics();
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    final String _topicName =
        Provider.of<PlacesScreenProvider>(context, listen: false).placeName;
    final _clearPosts = widget.isClubTab
        ? Provider.of<PlacesScreenProvider>(context, listen: false)
            .clearClubPosts
        : Provider.of<PlacesScreenProvider>(context, listen: false).clearPosts;
    const emptyBox = SizedBox(height: 0, width: 0);
    super.build(context);
    return FutureBuilder(
      key: PageStorageKey<String>(
          'constPLacesFuture${widget.isClubTab.toString()}'),
      future: _getPosts,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const PostsLoading(false);

        if (snapshot.hasError)
          return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(lang.flares_profile1,
                    style:
                        const TextStyle(color: Colors.black, fontSize: 17.0)),
                const SizedBox(width: 10.0),
                Container(
                    width: 100.0,
                    padding: const EdgeInsets.all(5.0),
                    child: TextButton(
                        style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                    const EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 5.0)),
                            enableFeedback: false,
                            backgroundColor: MaterialStateProperty.all<Color?>(
                                _primarySwatch)),
                        onPressed: () {
                          _pullRefresh(myUsername, _clearPosts, _topicName);
                        },
                        child: Text(lang.flares_profile2,
                            style: TextStyle(
                                fontSize: 19.0, color: _accentColor))))
              ]);

        if (noPostsFound) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                        child: Text(lang.widgets_places1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 25.0)))),
                if (!widget.isClubTab) _suggested,
                const Spacer()
              ]);
        }
        final Widget _feedList = Builder(
          builder: (context) {
            if (widget.isClubTab)
              Provider.of<PlacesScreenProvider>(context, listen: false)
                  .setClubPosts(feedPosts);
            else
              Provider.of<PlacesScreenProvider>(context, listen: false)
                  .setPosts(feedPosts);
            return Builder(
              builder: (context) {
                final _help = Provider.of<PlacesScreenProvider>(context);
                final _posts = widget.isClubTab ? _help.clubPosts : _help.posts;
                final _p =
                    Provider.of<PlacesScreenProvider>(context, listen: false);
                final __clearPosts =
                    widget.isClubTab ? _p.clearClubPosts : _p.clearPosts;
                return Stack(
                  children: <Widget>[
                    RefreshIndicator(
                      backgroundColor: _primarySwatch,
                      displacement: 2.0,
                      color: _accentColor,
                      onRefresh: () =>
                          _pullRefresh(myUsername, __clearPosts, _topicName),
                      child: Noglow(
                        child: ListView.separated(
                          key: PageStorageKey<String>(
                              'placesFeedStore${widget.isClubTab.toString()}'),
                          padding: EdgeInsets.only(
                            bottom: 85.0,
                          ),
                          physics: _always,
                          controller: _scrollController,
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
                            if (!widget.isClubTab && index == 6) _suggested;
                            return emptyBox;
                          },
                          itemBuilder: (context, index) {
                            if (index == _posts.length) {
                              if (isLoading || isLastPage) return emptyBox;
                            } else {
                              final _currentPost = _posts[index];
                              final FullHelper _instance =
                                  _currentPost.instance;
                              PostWidget _post = PostWidget(
                                  isInFeed: false,
                                  isInLike: false,
                                  isInFav: false,
                                  isInTab: false,
                                  isInMyTab: false,
                                  isInOtherTab: false,
                                  isInPeopleTopics: false,
                                  isInClubTopics: false,
                                  isInClubPosts: false,
                                  isInFavClubs: false,
                                  isInLikedClubs: false,
                                  isInClubFeed: false,
                                  isInClubPlaces: widget.isClubTab,
                                  isInPeoplePlaces: !widget.isClubTab,
                                  isInPeopleAdmin: false,
                                  isInClubAdmin: false);
                              return ChangeNotifierProvider<FullHelper>.value(
                                value: _instance,
                                child: _post,
                              );
                            }
                            return emptyBox;
                          },
                        ),
                      ),
                    ),
                    if (selectedAnchorMode)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          child: MyFab(_scrollController),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );

        return _feedList;
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
