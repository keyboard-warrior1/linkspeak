import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../loading/postsLoading.dart';
import '../../models/post.dart';
import '../../models/posterProfile.dart';
import '../../models/profile.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../common/adaptiveText.dart';
import '../common/nestedScroller.dart';
import '../post/postWidget.dart';

class OtherPostsTab extends StatefulWidget {
  const OtherPostsTab();
  @override
  _OtherPostsTabState createState() => _OtherPostsTabState();
}

class _OtherPostsTabState extends State<OtherPostsTab>
    with AutomaticKeepAliveClientMixin {
  final firestore = FirebaseFirestore.instance;
  late Future<void> _getMyPosts;
  List<Post> myPosts = [];
  late final ScrollController _scrollController;
  late void Function() _disposeScrollController;
  bool isLoading = false;
  bool isLastPage = false;
  void initializePost({
    required String myUsername,
    required TheVisibility myVis,
    required List<Post> tempPosts,
    required String postID,
  }) {
    if (!tempPosts.any((post) => post.postID == postID)) {
      final FullHelper _instance = FullHelper();
      final PosterProfile _posterProfile =
          PosterProfile(getUsername: myUsername, getVisibility: myVis);
      final Post _post = Post(
          key: UniqueKey(),
          instance: _instance,
          poster: _posterProfile,
          commentsDisabled: false,
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
          isFav: false,
          isLiked: false,
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

  Future<void> getMyPosts({
    required String myUsername,
    required void Function(List<Post>) setMyPosts,
    required TheVisibility myVis,
  }) async {
    List<Post> tempPosts = [];
    final myPostIDs = await firestore
        .collection('Users')
        .doc(myUsername)
        .collection('Posts')
        .orderBy('date', descending: true)
        .limit(20)
        .get();
    final myPostIDsDocs = myPostIDs.docs;
    for (var postID in myPostIDsDocs) {
      initializePost(
          myUsername: myUsername,
          myVis: myVis,
          tempPosts: tempPosts,
          postID: postID.id);
    }
    myPosts.addAll(tempPosts);
    if (myPostIDsDocs.length < 20) {
      isLastPage = true;
    }
    setMyPosts(myPosts);
    setState(() {});
  }

  Future<void> getMorePosts({
    required String myUsername,
    required void Function(List<Post>) setMyPosts,
    required TheVisibility myVis,
  }) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<Post> tempPosts = [];
      final lastPost = myPosts.last.postID;
      final lastPostDoc = await firestore
          .collection('Users')
          .doc(myUsername)
          .collection('Posts')
          .doc(lastPost)
          .get();
      final myPostIDs = await firestore
          .collection('Users')
          .doc(myUsername)
          .collection('Posts')
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(20)
          .get();
      final myPostIDsDocs = myPostIDs.docs;
      for (var postID in myPostIDsDocs) {
        initializePost(
            myUsername: myUsername,
            myVis: myVis,
            tempPosts: tempPosts,
            postID: postID.id);
      }
      myPosts.addAll(tempPosts);
      if (myPostIDsDocs.length < 20) {
        isLastPage = true;
      }
      isLoading = false;
      setMyPosts(myPosts);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final OtherProfile myProfile =
        Provider.of<OtherProfile>(context, listen: false);
    final myUsername = myProfile.getUsername;
    final myVis = myProfile.getVisibility;
    final setMyPosts = myProfile.setOtherPosts;
    _scrollController = myProfile.getProfilePostsScrollController;
    _disposeScrollController = myProfile.disposePostsController;
    _getMyPosts = getMyPosts(
        myUsername: myUsername, setMyPosts: setMyPosts, myVis: myVis);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMorePosts(
                myUsername: myUsername, setMyPosts: setMyPosts, myVis: myVis);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _disposeScrollController();
  }

  @override
  Widget build(BuildContext context) {
    const _logoAddress = 'assets/images/noposts.svg';
    final Size _querySize = MediaQuery.of(context).size;
    final ThemeData _theme = Theme.of(context);
    final double _deviceHeight = _querySize.height;
    final double _deviceWidth = _querySize.width;
    final Color _primaryColor = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final OtherProfile myProfile =
        Provider.of<OtherProfile>(context, listen: false);
    final String otherUsername = myProfile.getUsername;
    final myVis = myProfile.getVisibility;
    final setMyPosts = myProfile.setOtherPosts;
    final bool imBlocked =
        Provider.of<OtherProfile>(context, listen: false).imBlocked;
    final bool publicProfile =
        Provider.of<OtherProfile>(context, listen: false).getVisibility ==
            TheVisibility.public;
    final bool imLinkedToThem =
        Provider.of<OtherProfile>(context, listen: false).imLinkedToThem;
    final ScrollController profileController =
        Provider.of<OtherProfile>(context, listen: false)
            .getProfileScrollController;
    final bool isBanned =
        Provider.of<OtherProfile>(context, listen: false).isBanned;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final Widget theTab = FutureBuilder(
        future: _getMyPosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PostsLoading(false);
          }

          if (snapshot.hasError) {
            return Container(
                color: Colors.white,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                            const Text('An unknown error has occured',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 15.0),
                            TextButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color?>(
                                        _primaryColor),
                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                        const EdgeInsets.all(0.0)),
                                    shape: MaterialStateProperty.all<OutlinedBorder?>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)))),
                                onPressed: () => setState(() {
                                      _getMyPosts = getMyPosts(
                                          myUsername: otherUsername,
                                          setMyPosts: setMyPosts,
                                          myVis: myVis);
                                    }),
                                child: Center(
                                    child: Text('Retry',
                                        style: TextStyle(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold))))
                          ]))
                    ]));
          }
          return Builder(builder: (context) {
            final List<Post> _myPosts =
                Provider.of<OtherProfile>(context, listen: false).getPosts;
            return (_myPosts.isEmpty)
                ? Container(
                    color: Colors.white,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  _logoAddress,
                                  height: _deviceHeight * 0.15,
                                  width: _deviceWidth * 0.15,
                                ),
                                OptimisedText(
                                    minWidth: _deviceWidth * 0.50,
                                    maxWidth: _deviceWidth * 0.50,
                                    minHeight: _deviceHeight * 0.05,
                                    maxHeight: _deviceHeight * 0.10,
                                    fit: BoxFit.scaleDown,
                                    child: const Text('No posts yet',
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 35.0)))
                              ])
                        ]))
                : Container(
                    color: Colors.white,
                    child: NestedScroller(
                        controller: profileController,
                        child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 85.0),
                            key: PageStorageKey<String>('oreOtherusersPosts'),
                            shrinkWrap: true,
                            itemCount: _myPosts.length + 1,
                            controller: _scrollController,
                            itemBuilder: (_, index) {
                              if (index == _myPosts.length) {
                                if (isLoading || isLastPage) return emptyBox;
                              } else {
                                final currentPost = _myPosts[index];
                                final instance = currentPost.instance;
                                const PostWidget _post = const PostWidget(
                                    isInFeed: false,
                                    isInLike: false,
                                    isInFav: false,
                                    isInTab: true,
                                    isInOtherTab: true,
                                    isInMyTab: false,
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
                                    value: instance, child: _post);
                              }
                              return emptyBox;
                            })));
          });
        });
    super.build(context);
    return (imBlocked || isBanned)
        ? (!myUsername.startsWith('Linkspeak'))
            ? Container(
                color: Colors.white,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.lock_outline,
                          color: Colors.black, size: _deviceHeight * 0.15)
                    ]))
            : theTab
        : (!publicProfile)
            ? (!imLinkedToThem)
                ? (!myUsername.startsWith('Linkspeak'))
                    ? Container(
                        color: Colors.white,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.lock_outline,
                                  color: Colors.black,
                                  size: _deviceHeight * 0.15)
                            ]))
                    : theTab
                : theTab
            : theTab;
  }

  @override
  bool get wantKeepAlive => true;
}
