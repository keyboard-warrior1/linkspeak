import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../loading/postsLoading.dart';
import '../../models/post.dart';
import '../../models/posterProfile.dart';
import '../../models/profile.dart';
import '../../providers/appBarProvider.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/profileScrollProvider.dart';
import '../../screens/feedScreen.dart';
import '../common/adaptiveText.dart';
import '../common/nestedScroller.dart';
import '../post/postWidget.dart';

class MyPostsTab extends StatefulWidget {
  const MyPostsTab();
  @override
  _MyPostsTabState createState() => _MyPostsTabState();
}

class _MyPostsTabState extends State<MyPostsTab>
    with AutomaticKeepAliveClientMixin {
  final firestore = FirebaseFirestore.instance;
  late final ScrollController _postsScrollController;
  late final ScrollController _profileScrollController;
  late void Function() _disposeScrollController;
  late Future<void> _getMyPosts;
  List<Post> myPosts = [];
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
    final MyProfile myProfile = Provider.of<MyProfile>(context, listen: false);
    final myUsername = myProfile.getUsername;
    final myVis = myProfile.getVisibility;
    final setMyPosts = myProfile.setMyPosts;
    _postsScrollController =
        Provider.of<ProfileScrollProvider>(context, listen: false)
            .postsScrollController;
    _profileScrollController =
        Provider.of<ProfileScrollProvider>(context, listen: false)
            .profileScrollController;
    _disposeScrollController =
        Provider.of<ProfileScrollProvider>(context, listen: false)
            .disposeScrollController;
    _getMyPosts = getMyPosts(
        myUsername: myUsername, setMyPosts: setMyPosts, myVis: myVis);
    _postsScrollController.addListener(() {
      if (_postsScrollController.position.pixels ==
          _postsScrollController.position.maxScrollExtent) {
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
    _postsScrollController.removeListener(() {});
    _disposeScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    const _logoAddress = 'assets/images/noposts.svg';
    final Size _querySize = MediaQuery.of(context).size;
    final ThemeData _theme = Theme.of(context);
    final double _deviceHeight = _querySize.height;
    final double _deviceWidth = _querySize.width;
    final Color _primaryColor = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final MyProfile myProfile = Provider.of<MyProfile>(context, listen: false);
    final myUsername = myProfile.getUsername;
    final myVis = myProfile.getVisibility;
    final setMyPosts = myProfile.setMyPosts;
    super.build(context);
    return FutureBuilder(
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
                            Text(lang.clubs_adminScreen2,
                                style: const TextStyle(color: Colors.grey)),
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
                                          myUsername: myUsername,
                                          setMyPosts: setMyPosts,
                                          myVis: myVis);
                                    }),
                                child: Center(
                                    child: Text(lang.clubs_adminScreen3,
                                        style: TextStyle(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold))))
                          ]))
                    ]));
          }
          return Builder(builder: (context) {
            final List<Post> _myPosts =
                Provider.of<MyProfile>(context, listen: false).getPosts;
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
                                    child: Text(lang.clubs_clubPosts8,
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 35.0))),
                                const SizedBox(height: 20.0),
                                Container(
                                    height: 55.0,
                                    width: 250.0,
                                    color: Colors.transparent,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            elevation:
                                                MaterialStateProperty.all<double?>(
                                                    0.0),
                                            shape: MaterialStateProperty.all<OutlinedBorder?>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0))),
                                            backgroundColor:
                                                MaterialStateProperty.all<Color?>(
                                                    _primaryColor),
                                            shadowColor:
                                                MaterialStateProperty.all<Color?>(
                                                    _primaryColor)),
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          Provider.of<AppBarProvider>(context,
                                                  listen: false)
                                              .changeTab(2);
                                          EasyLoading.dismiss();
                                          FeedScreen.pageController
                                              .jumpToPage(2);
                                          FeedScreen.sheetOpen = false;
                                          FeedScreen.shareSheetOpen = false;
                                          Navigator.pop(context);
                                        },
                                        child: Center(child: Text(lang.clubs_screen6, style: TextStyle(color: _accentColor, fontSize: 30.0)))))
                              ])
                        ]))
                : Container(
                    color: Colors.white,
                    child: NestedScroller(
                        controller: _profileScrollController,
                        child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 85.0),
                            key: PageStorageKey<String>('storeMyPosts'),
                            shrinkWrap: true,
                            itemCount: _myPosts.length + 1,
                            controller: _postsScrollController,
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
                                    isInMyTab: true,
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
                                    value: instance, child: _post);
                              }
                              return emptyBox;
                            })));
          });
        });
  }

  @override
  bool get wantKeepAlive => true;
}
