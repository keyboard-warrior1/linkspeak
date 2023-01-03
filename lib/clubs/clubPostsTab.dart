import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/postsLoading.dart';
import '../models/post.dart';
import '../models/posterProfile.dart';
import '../models/profile.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/clubProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/nestedScroller.dart';
import '../widgets/common/sortationWidget.dart';
import '../widgets/misc/ads.dart';
import '../widgets/post/postWidget.dart';
import '../widgets/share/shareWidget.dart';
import 'privateClub.dart';

class ClubPosts extends StatefulWidget {
  const ClubPosts();
  static bool shareSheetOpen = false;
  static late PersistentBottomSheetController? _shareController;
  static void sharePost(
      BuildContext context, String postID, String clubName, bool isClubPost) {
    _shareController = showBottomSheet(
      context: context,
      builder: (context) {
        return ShareWidget(
            isInFeed: false,
            bottomSheetController: _shareController,
            postID: postID,
            clubName: clubName,
            isClubPost: isClubPost,
            isFlare: false,
            flarePoster: '',
            collectionID: '',
            flareID: '');
      },
      backgroundColor: Colors.transparent,
    );
    ClubPosts.shareSheetOpen = true;
    _shareController!.closed.then((value) {
      ClubPosts.shareSheetOpen = false;
    });
  }

  @override
  _ClubPostsState createState() => _ClubPostsState();
}

class _ClubPostsState extends State<ClubPosts>
    with AutomaticKeepAliveClientMixin {
  final firestore = FirebaseFirestore.instance;
  late Future<void> _getClubPosts;
  List<Post> myPosts = [];
  bool isLoading = false;
  bool isLastPage = false;
  Sortation sortation = Sortation.newest;
  late final ScrollController _controller;
  late void Function() _disposeController;
  void initializePost(
      {required String clubName,
      required List<Post> tempPosts,
      required String postID}) {
    if (!myPosts.any((post) => post.postID == postID)) {
      final FullHelper _instance = FullHelper();
      final Post _post = Post(
          key: UniqueKey(),
          instance: _instance,
          poster: PosterProfile(
              getUsername: '', getVisibility: TheVisibility.public),
          description: '',
          numOfLikes: 0,
          numOfComments: 0,
          numOfTopics: 0,
          sensitiveContent: false,
          commentsDisabled: false,
          postID: postID,
          postedDate: DateTime.now(),
          topics: [],
          imgUrls: [],
          location: '',
          locationName: '',
          isLiked: false,
          isClubPost: true,
          clubName: clubName,
          isFav: false,
          isHidden: false,
          isMod: false,
          postType: PostType.legacy,
          items: [],
          backgroundColor: Colors.blue,
          gradientColor: Colors.yellow);
      _post.setter();
      myPosts.add(_post);
    }
  }

  Future<void> getClubPosts(
      {required Function(List<Post>) setClubPosts,
      required String myUsername,
      required String clubName,
      required bool isMod}) async {
    List<Post> tempPosts = [];
    final clubPosts = sortation == Sortation.mine
        ? await firestore
            .collection('Posts')
            .where('clubName', isEqualTo: clubName)
            .where('poster', isEqualTo: myUsername)
            .limit(20)
            .get()
        : sortation == Sortation.newest
            ? await firestore
                .collection('Clubs')
                .doc(clubName)
                .collection('Posts')
                .orderBy('date', descending: true)
                .limit(20)
                .get()
            : await firestore
                .collection('Posts')
                .where('clubName', isEqualTo: clubName)
                .orderBy('likes', descending: true)
                .limit(20)
                .get();
    final docs = clubPosts.docs;
    if (docs.isEmpty) {
      return;
    } else {
      for (var post in docs)
        initializePost(
            clubName: clubName, tempPosts: tempPosts, postID: post.id);
      if (docs.length < 20) isLastPage = true;
      // myPosts.addAll(tempPosts);
      setClubPosts(myPosts);
      setState(() {});
    }
  }

  Future<void> getMoreClubPosts(
      {required Function(List<Post>) setClubPosts,
      required String clubName,
      required bool isMod,
      required String myUsername}) async {
    if (isLoading) {
    } else {
      setState(() => isLoading = true);
      List<Post> tempPosts = [];
      final clubpostsCollection =
          firestore.collection('Clubs').doc(clubName).collection('Posts');
      final lastPost = myPosts.last.postID;
      final getLastPost = await clubpostsCollection.doc(lastPost).get();
      final nextPosts = sortation == Sortation.mine
          ? await firestore
              .collection('Posts')
              .where('clubName', isEqualTo: clubName)
              .where('poster', isEqualTo: myUsername)
              .startAfterDocument(getLastPost)
              .limit(20)
              .get()
          : sortation == Sortation.newest
              ? await clubpostsCollection
                  .orderBy('date', descending: true)
                  .startAfterDocument(getLastPost)
                  .limit(20)
                  .get()
              : await firestore
                  .collection('Posts')
                  .where('clubName', isEqualTo: clubName)
                  .orderBy('likes', descending: true)
                  .startAfterDocument(getLastPost)
                  .limit(20)
                  .get();
      final docs = nextPosts.docs;
      for (var post in docs)
        initializePost(
            clubName: clubName, tempPosts: tempPosts, postID: post.id);
      if (docs.length < 20) isLastPage = true;
      isLoading = false;
      // myPosts.addAll(tempPosts);
      setClubPosts(myPosts);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final helper = Provider.of<ClubProvider>(context, listen: false);
    final myProfile = Provider.of<MyProfile>(context, listen: false);
    final bool isMod = helper.isMod;
    final String clubName = helper.clubName;
    final void Function(List<Post>) setClubPosts = helper.setposts;
    _controller = helper.getClubPostsScrollController;
    _disposeController = helper.disposeScrollController;
    final String myUsername = myProfile.getUsername;
    _getClubPosts = getClubPosts(
        setClubPosts: setClubPosts,
        clubName: clubName,
        isMod: isMod,
        myUsername: myUsername);
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreClubPosts(
                setClubPosts: setClubPosts,
                clubName: clubName,
                isMod: isMod,
                myUsername: myUsername);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(() {});
    _disposeController();
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
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final isAdmin = myUsername.startsWith('Linkspeak');
    final String clubName =
        Provider.of<ClubProvider>(context, listen: false).clubName;
    final ScrollController screenController =
        Provider.of<ClubProvider>(context, listen: false)
            .getScreenScrollController;
    final bool isMod = Provider.of<ClubProvider>(context, listen: false).isMod;
    final void Function(List<Post>) setClubPosts =
        Provider.of<ClubProvider>(context, listen: false).setposts;
    final _club = Provider.of<ClubProvider>(context, listen: false);
    final clearPosts = _club.clearPosts;
    final ClubVisibility clubVisibility = _club.clubVisibility;
    final bool isDisabled = _club.isDisabled;
    final bool isBanned = _club.isBanned;
    final bool isProhibited = _club.isProhibited;
    final bool _isPrivate = clubVisibility == ClubVisibility.private;
    final bool _isHidden = clubVisibility == ClubVisibility.hidden;
    final bool isMember = _club.isJoined;
    final Widget privateClub =
        PrivateClub(icon: Icons.lock_outlined, message: lang.clubs_clubPosts1);
    final Widget prohibitedClub = PrivateClub(
        icon: customIcons.MyFlutterApp.radio_1_,
        message: lang.clubs_clubPosts2);
    final Widget disabledClub = PrivateClub(
        icon: customIcons.MyFlutterApp.clubs, message: lang.clubs_clubPosts3);
    final Widget bannedClub = PrivateClub(
        icon: customIcons.MyFlutterApp.no_stopping,
        message: lang.clubs_clubPosts4);
    final Widget hiddenClub = PrivateClub(
        icon: customIcons.MyFlutterApp.hidden, message: lang.clubs_clubPosts5);
    void setSortation(Sortation newSort) {
      clearPosts();
      myPosts.clear();
      setState(() {
        sortation = newSort;
        isLoading = false;
        isLastPage = false;
        _getClubPosts = getClubPosts(
            setClubPosts: setClubPosts,
            clubName: clubName,
            isMod: isMod,
            myUsername: myUsername);
      });
    }

    super.build(context);
    return (isDisabled && !isAdmin)
        ? disabledClub
        : (isProhibited && !isAdmin)
            ? prohibitedClub
            : (isBanned && !isAdmin)
                ? bannedClub
                : (_isPrivate && !isMember && !isAdmin)
                    ? privateClub
                    : (_isHidden && !isMember && !isAdmin)
                        ? hiddenClub
                        : FutureBuilder(
                            future: _getClubPosts,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                return const PostsLoading(false);

                              if (snapshot.hasError)
                                return Container(
                                    color: Colors.white,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Center(
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                Text(lang.clubs_clubPosts6,
                                                    style: const TextStyle(
                                                        color: Colors.grey)),
                                                const SizedBox(width: 15.0),
                                                TextButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty.all<Color?>(
                                                                _primaryColor),
                                                        padding: MaterialStateProperty.all<
                                                                EdgeInsetsGeometry?>(
                                                            const EdgeInsets.all(
                                                                0.0)),
                                                        shape: MaterialStateProperty.all<
                                                                OutlinedBorder?>(
                                                            RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10.0)))),
                                                    onPressed: () => setState(() {
                                                          _getClubPosts =
                                                              getClubPosts(
                                                                  setClubPosts:
                                                                      setClubPosts,
                                                                  clubName:
                                                                      clubName,
                                                                  isMod: isMod,
                                                                  myUsername:
                                                                      myUsername);
                                                        }),
                                                    child: Center(child: Text(lang.clubs_clubPosts7, style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold))))
                                              ]))
                                        ]));

                              return Builder(builder: (context) {
                                final List<Post> _myPosts =
                                    Provider.of<ClubProvider>(context,
                                            listen: false)
                                        .posts;
                                return (_myPosts.isEmpty)
                                    ? Container(
                                        height: _deviceHeight * 0.90,
                                        width: _deviceWidth,
                                        color: Colors.white,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              SortationWidget(
                                                  currentSortation: sortation,
                                                  setSortation: setSortation,
                                                  isComments: false,
                                                  isReplies: false,
                                                  isPosts: true),
                                              const Spacer(),
                                              SvgPicture.asset(_logoAddress,
                                                  height: _deviceHeight * 0.15,
                                                  width: _deviceWidth * 0.15),
                                              OptimisedText(
                                                  minWidth: _deviceWidth * 0.50,
                                                  maxWidth: _deviceWidth * 0.50,
                                                  minHeight:
                                                      _deviceHeight * 0.05,
                                                  maxHeight:
                                                      _deviceHeight * 0.10,
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                      lang.clubs_clubPosts8,
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 35.0))),
                                              const Spacer()
                                            ]))
                                    : Container(
                                        color: Colors.white,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              SortationWidget(
                                                  currentSortation: sortation,
                                                  setSortation: setSortation,
                                                  isComments: false,
                                                  isReplies: false,
                                                  isPosts: true),
                                              Expanded(
                                                child: NestedScroller(
                                                    controller:
                                                        screenController,
                                                    child: ListView.separated(
                                                        padding: const EdgeInsets
                                                            .only(bottom: 85.0),
                                                        key: PageStorageKey<
                                                                String>(
                                                            'storeClubPoPosts'),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            _myPosts.length + 1,
                                                        controller: _controller,
                                                        separatorBuilder:
                                                            (ctx, index) {
                                                          var remainder =
                                                              index % 4;
                                                          if (remainder == 0)
                                                            return Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        0.0,
                                                                    horizontal:
                                                                        10.0),
                                                                child:
                                                                    const NativeAds());
                                                          return emptyBox;
                                                        },
                                                        itemBuilder:
                                                            (_, index) {
                                                          if (index ==
                                                              _myPosts.length) {
                                                            if (isLoading ||
                                                                isLastPage)
                                                              return emptyBox;
                                                          } else {
                                                            final currentPost =
                                                                _myPosts[index];
                                                            final instance =
                                                                currentPost
                                                                    .instance;
                                                            const PostWidget _post = const PostWidget(
                                                                isInFeed: false,
                                                                isInLike: false,
                                                                isInFav: false,
                                                                isInTab: true,
                                                                isInMyTab:
                                                                    false,
                                                                isInOtherTab:
                                                                    false,
                                                                isInClubPosts:
                                                                    true,
                                                                isInFavClubs:
                                                                    false,
                                                                isInLikedClubs:
                                                                    false,
                                                                isInClubFeed:
                                                                    false,
                                                                isInPeopleTopics:
                                                                    false,
                                                                isInClubTopics:
                                                                    false,
                                                                isInPeoplePlaces:
                                                                    false,
                                                                isInClubPlaces:
                                                                    false,
                                                                isInPeopleAdmin:
                                                                    false,
                                                                isInClubAdmin:
                                                                    false);
                                                            return ChangeNotifierProvider<
                                                                    FullHelper>.value(
                                                                value: instance,
                                                                child: _post);
                                                          }
                                                          return emptyBox;
                                                        })),
                                              )
                                            ]));
                              });
                            });
  }

  @override
  bool get wantKeepAlive => true;
}
