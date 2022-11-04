import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../loading/postsLoading.dart';
import '../../../models/post.dart';
import '../../../models/posterProfile.dart';
import '../../../models/profile.dart';
import '../../../providers/adminPostsProvider.dart';
import '../../../providers/fullPostHelper.dart';
import '../../../widgets/common/noglow.dart';
import '../../../widgets/post/postWidget.dart';

class AllPostsTab extends StatefulWidget {
  final bool isClub;
  const AllPostsTab(this.isClub);

  @override
  State<AllPostsTab> createState() => _AllPostsTabState();
}

class _AllPostsTabState extends State<AllPostsTab>
    with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late ScrollController scrollController;
  List<Post> posts = [];
  bool isLoading = false;
  bool isLastPage = false;
  late Future<void> getPosts;
  void initPost({required List<Post> tempPosts, required String postID}) {
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
  }

  Future<void> _getPosts(
      {required bool toBeCleared,
      required void Function(List<Post>) setPosts,
      required void Function() clearPosts}) async {
    List<Post> tempPosts = [];
    var query = widget.isClub
        ? await firestore
            .collection('Posts')
            .where('clubName', isNotEqualTo: '')
            // .orderBy('date', descending: true)
            .limit(50)
            .get()
        : await firestore
            .collection('Posts')
            .where('clubName', isEqualTo: '')
            .orderBy('date', descending: true)
            .limit(50)
            .get();
    var docs = query.docs;
    for (var post in docs) {
      final postID = post.id;
      if (!posts.any((post) => post.postID == postID)) {
        if (!tempPosts.any((post) => post.postID == postID)) {
          initPost(tempPosts: tempPosts, postID: postID);
        }
      }
    }
    posts.addAll(tempPosts);
    if (docs.length < 50) isLastPage = true;
    setPosts(posts);
    if (mounted) setState(() {});
  }

  Future<void> _getMorePosts(void Function(List<Post>) setPosts) async {
    if (!isLoading) {
      setState(() => isLoading = true);
      List<Post> tempPosts = [];
      final lastID = posts.last.postID;
      final lastDoc = await firestore.doc('Posts/$lastID').get();
      var query = widget.isClub
          ? await firestore
              .collection('Posts')
              .where('clubName', isNotEqualTo: '')
              // .orderBy('date', descending: true)
              .startAfterDocument(lastDoc)
              .limit(50)
              .get()
          : await firestore
              .collection('Posts')
              .where('clubName', isEqualTo: '')
              .orderBy('date', descending: true)
              .startAfterDocument(lastDoc)
              .limit(50)
              .get();
      var docs = query.docs;
      for (var post in docs) {
        final postID = post.id;
        if (!posts.any((post) => post.postID == postID)) {
          if (!tempPosts.any((post) => post.postID == postID)) {
            initPost(tempPosts: tempPosts, postID: postID);
          }
        }
      }
      posts.addAll(tempPosts);
      if (docs.length < 50) isLastPage = true;
      setPosts(posts);
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _pullRefresh(
      void Function(List<Post>) setPosts, void Function() clearPosts) async {
    setState(() {
      isLastPage = false;
      getPosts = _getPosts(
          setPosts: setPosts, toBeCleared: true, clearPosts: clearPosts);
    });
  }

  @override
  void initState() {
    super.initState();
    final helper = Provider.of<AdminPostsProvider>(context, listen: false);
    var setUsrPosts = helper.setUserPosts;
    var setClubPosts = helper.setClubPosts;
    var userScrollController = helper.userScrollController;
    var clubScrollController = helper.clubScrollController;
    scrollController =
        widget.isClub ? clubScrollController : userScrollController;
    getPosts = _getPosts(
        toBeCleared: false,
        setPosts: widget.isClub ? setClubPosts : setUsrPosts,
        clearPosts: () {});
    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (!isLoading && !isLastPage) {
            _getMorePosts(widget.isClub ? setClubPosts : setUsrPosts);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(() {});
    // scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final _primarySwatch = colorScheme.primary;
    final _accentColor = colorScheme.secondary;
    final helper = Provider.of<AdminPostsProvider>(context, listen: false);
    var setUsrPosts = helper.setUserPosts;
    var setClubPosts = helper.setClubPosts;
    var clearUsrPosts = helper.clearUserPosts;
    var clearClubPosts = helper.clearClubPosts;
    super.build(context);
    return
        // this Expanded causes an exception in release
        // Expanded(
        //     child:
        FutureBuilder(
            key: PageStorageKey<String>(
                'constADminFutures${widget.isClub.toString()}'),
            future: getPosts,
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const PostsLoading(false);
              return Builder(builder: (_) {
                var _helper = Provider.of<AdminPostsProvider>(context);
                final theList =
                    widget.isClub ? _helper.clubPosts : _helper.userPosts;
                return Noglow(
                    child: RefreshIndicator(
                        // key: UniqueKey(),
                        backgroundColor: _primarySwatch,
                        displacement: 40.0,
                        color: _accentColor,
                        onRefresh: () => _pullRefresh(
                            widget.isClub ? setClubPosts : setUsrPosts,
                            widget.isClub ? clearClubPosts : clearUsrPosts),
                        child: ListView.builder(
                            key: PageStorageKey<String>(
                                '${widget.isClub.toString()}adminPosts'),
                            controller: scrollController,
                            itemCount: theList.length,
                            itemBuilder: (ctx, index) =>
                                ChangeNotifierProvider<FullHelper>.value(
                                    value: theList[index].instance,
                                    child: PostWidget(
                                        isInFeed: false,
                                        isInClubFeed: false,
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
                                        isInPeoplePlaces: false,
                                        isInClubPlaces: false,
                                        isInPeopleAdmin: !widget.isClub,
                                        isInClubAdmin: widget.isClub)))));
              });
            });
    // )
  }

  @override
  bool get wantKeepAlive => true;
}
