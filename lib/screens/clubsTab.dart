import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/postsLoading.dart';
import '../models/post.dart';
import '../models/posterProfile.dart';
import '../models/profile.dart';
import '../providers/appBarProvider.dart';
import '../providers/clubTabProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/misc/ads.dart';
import '../widgets/misc/suggestedWidget.dart';
import '../widgets/post/postWidget.dart';
import 'feedScreen.dart';

class ClubsTab extends StatefulWidget {
  const ClubsTab();
  @override
  _ClubsTabState createState() => _ClubsTabState();
}

class _ClubsTabState extends State<ClubsTab>
    with AutomaticKeepAliveClientMixin {
  static const Widget _suggested = const SuggestedWidget(true, false, false);
  final ScrollController scrollController = FeedScreen.clubScrollController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Post> feedPosts = [];
  List<String> clubListString = [];
  late Future _getPosts;
  bool noPostsFound = false;
  bool isLoading = false;
  void initializePost({required List<Post> tempPosts, required String postID}) {
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
        isClubPost: true,
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
  }

  Future<void> getPosts(void Function(List<Post>) setPosts, bool clearPosts,
      void Function() clear) async {
    List<Post> tempPosts = [];
    if (clearPosts) {
      clear();
      clubListString.clear();
      feedPosts.clear();
    }
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final usersCollection = firestore.collection('Users');
    final myUser = usersCollection.doc(myUsername);
    for (var i = 0; i < 2; i++) {
      if (clubListString.isEmpty) {
        final clubList = await myUser
            .collection('Joined Clubs')
            .orderBy('date', descending: true)
            .limit(10)
            .get();
        final clubListDocs = clubList.docs;
        final List<String> currentClubs = [];
        if (clubListDocs.isNotEmpty) {
          clubListDocs.forEach((element) {
            final id = element.id;
            clubListString.add(id);
            currentClubs.add(id);
          });
          final clubPosts = await firestore
              .collection('Posts')
              .where('clubName', whereIn: currentClubs)
              .orderBy('date', descending: true)
              .limit(20)
              .get();
          final clubPostDocs = clubPosts.docs;
          if (clubPostDocs.isNotEmpty) {
            for (var post in clubPostDocs) {
              final postID = post.id;
              if (!feedPosts.any((post) => post.postID == postID)) {
                if (!tempPosts.any((post) => post.postID == postID)) {
                  initializePost(tempPosts: tempPosts, postID: postID);
                }
              }
            }
          }
        }
      } else {
        final lastID = clubListString.last;
        final getLastClub = await usersCollection
            .doc(myUsername)
            .collection('Joined Clubs')
            .doc(lastID)
            .get();
        final getNextClubs = await usersCollection
            .doc(myUsername)
            .collection('Joined Clubs')
            .orderBy('date', descending: true)
            .startAfterDocument(getLastClub)
            .limit(10)
            .get();
        final docs = getNextClubs.docs;
        final List<String> currentClubs = [];
        if (docs.isNotEmpty) {
          docs.forEach((element) {
            final id = element.id;
            clubListString.add(id);
            currentClubs.add(id);
          });
          final clubPosts = await firestore
              .collection('Posts')
              .where('clubName', whereIn: currentClubs)
              .orderBy('date', descending: true)
              .limit(20)
              .get();
          final clubPostDocs = clubPosts.docs;
          if (clubPostDocs.isNotEmpty) {
            for (var post in clubPostDocs) {
              final postID = post.id;
              if (!feedPosts.any((post) => post.postID == postID)) {
                if (!tempPosts.any((post) => post.postID == postID)) {
                  initializePost(tempPosts: tempPosts, postID: postID);
                }
              }
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
      if (clubListString.isNotEmpty) {
        for (var i = 0; i < 2; i++) {
          final lastID = clubListString.last;
          final getLastClub = await usersCollection
              .doc(myUsername)
              .collection('Joined Clubs')
              .doc(lastID)
              .get();
          final getNextClubs = await usersCollection
              .doc(myUsername)
              .collection('Joined Clubs')
              .orderBy('date', descending: true)
              .startAfterDocument(getLastClub)
              .limit(10)
              .get();
          final docs = getNextClubs.docs;
          final List<String> currentClubs = [];
          if (docs.isNotEmpty) {
            docs.forEach((element) {
              final id = element.id;
              clubListString.add(id);
              currentClubs.add(id);
            });
            final clubPosts = await firestore
                .collection('Posts')
                .where('clubName', whereIn: currentClubs)
                .orderBy('date', descending: true)
                .limit(20)
                .get();
            final clubPostDocs = clubPosts.docs;
            if (clubPostDocs.isNotEmpty) {
              for (var post in clubPostDocs) {
                final postID = post.id;
                if (!feedPosts.any((post) => post.postID == postID)) {
                  if (!tempPosts.any((post) => post.postID == postID)) {
                    initializePost(tempPosts: tempPosts, postID: postID);
                  }
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
            () => FeedScreen.scrollDown(_speedFactor, true));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final void Function(List<Post>) setPosts =
        Provider.of<ClubTabProvider>(context, listen: false).setPosts;
    final void Function() clearPosts =
        Provider.of<ClubTabProvider>(context, listen: false).clearPosts;
    _getPosts = getPosts(setPosts, false, clearPosts);
    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (!isLoading) {
            getMorePosts(setPosts);
          }
        }
      }
    });
  }

  Future<void> _pullRefresh(
    void Function(List<Post>) setPosts,
    void Function() clear,
  ) async {
    setState(() {
      _getPosts = getPosts(setPosts, true, clear);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    const String _logoAddress = 'assets/images/noposts.svg';
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    const ScrollPhysics _always = const AlwaysScrollableScrollPhysics();
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final void Function() clearPosts =
        Provider.of<ClubTabProvider>(context, listen: false).clearPosts;
    final void Function(List<Post>) setPosts =
        Provider.of<ClubTabProvider>(context, listen: false).setPosts;
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    super.build(context);
    return FutureBuilder(
      key: PageStorageKey<String>('FUTUREClubFeeed'),
      future: _getPosts,
      builder: (context, snapshot) {
        final _posts = Provider.of<ClubTabProvider>(context).posts;
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
                          Text(lang.clubs_members2,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17.0)),
                          const SizedBox(width: 10.0),
                          Container(
                              width: 100.0,
                              padding: const EdgeInsets.all(5.0),
                              child: TextButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                          const EdgeInsets.symmetric(
                                              vertical: 1.0, horizontal: 5.0)),
                                      enableFeedback: false,
                                      shape: MaterialStateProperty.all<OutlinedBorder?>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color?>(
                                              _primarySwatch)),
                                  onPressed: () {
                                    _pullRefresh(setPosts, clearPosts);
                                  },
                                  child: Text(lang.clubs_members3,
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
                  onRefresh: () => _pullRefresh(setPosts, clearPosts),
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
                                      child: Text(lang.screens_clubTab,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 25.0)))),
                              _suggested,
                              const Spacer()
                            ]))
                  ])));

        final Widget _feedList = ListView.separated(
          key: PageStorageKey<String>('ClubFeedStore'),
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
                  isInClubFeed: true,
                  isInLike: false,
                  isInFav: false,
                  isInTab: false,
                  isInMyTab: false,
                  isInOtherTab: false,
                  isInClubPosts: false,
                  isInFavClubs: false,
                  isInLikedClubs: false,
                  isInPeopleTopics: false,
                  isInClubTopics: false,
                  isInPeoplePlaces: false,
                  isInClubPlaces: false,
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
            onRefresh: () => _pullRefresh(setPosts, clearPosts),
            child: _feedList);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
