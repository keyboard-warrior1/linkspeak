import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/postsLoading.dart';
import '../models/post.dart';
import '../models/posterProfile.dart';
import '../models/profile.dart';
import '../providers/favScreenScrollProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/myFab.dart';
import '../widgets/common/noglow.dart';
import '../widgets/misc/ads.dart';
import '../widgets/post/postWidget.dart';

class FavClubPosts extends StatefulWidget {
  const FavClubPosts();

  @override
  _FavClubPostsState createState() => _FavClubPostsState();
}

class _FavClubPostsState extends State<FavClubPosts>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  late void Function() _disposeScrollController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getLikedPosts;
  late String deletionUsername;
  bool isLoading = false;
  bool isLastPage = false;
  List<Post> likedPosts = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> gottenIDs = [];
  List<String> toRemove = [];
  void initializePost({required List<Post> tempPosts, required String postID}) {
    if (!tempPosts.any((post) => post.postID == postID)) {
      final FullHelper _instance = FullHelper();
      final PosterProfile _posterProfile =
          PosterProfile(getUsername: '', getVisibility: TheVisibility.public);
      final Post _post = Post(
          key: UniqueKey(),
          instance: _instance,
          poster: _posterProfile,
          description: '',
          commentsDisabled: false,
          numOfLikes: 0,
          numOfComments: 0,
          isClubPost: true,
          clubName: '',
          numOfTopics: 0,
          sensitiveContent: false,
          postID: postID,
          postedDate: DateTime.now(),
          topics: [],
          imgUrls: [],
          location: '',
          locationName: '',
          isLiked: false,
          isFav: true,
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

  Future<void> getLikedPosts(
      String myUsername, void Function(List<Post>) setFavPosts) async {
    final postsCollection = firestore.collection('Posts');
    List<Post> tempPosts = [];
    do {
      if (gottenIDs.isEmpty) {
        final likedPostIDs = await firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Fav Club Posts')
            .orderBy('date', descending: true)
            .limit(20)
            .get();
        final likedPostIDsDocs = likedPostIDs.docs;
        if (likedPostIDsDocs.isEmpty) {
          return;
        }
        gottenIDs.addAll(likedPostIDsDocs);
        for (var id in likedPostIDsDocs) {
          final post = await postsCollection.doc(id.id).get();
          if (!post.exists) {
            toRemove.add(id.id);
          } else {
            initializePost(tempPosts: tempPosts, postID: id.id);
          }
        }

        if (likedPostIDsDocs.length < 20) {
          isLastPage = true;
        }
      } else {
        final lastDoc = gottenIDs.last.id;
        final getLastDoc = await firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Fav Club Posts')
            .doc(lastDoc)
            .get();
        final likedPostIDs = await firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Fav Club Posts')
            .orderBy('date', descending: true)
            .startAfterDocument(getLastDoc)
            .limit(20)
            .get();
        final likedPostIDsDocs = likedPostIDs.docs;
        gottenIDs.addAll(likedPostIDsDocs);
        for (var id in likedPostIDsDocs) {
          final post = await postsCollection.doc(id.id).get();
          if (!post.exists) {
            toRemove.add(id.id);
          } else {
            initializePost(tempPosts: tempPosts, postID: id.id);
          }
        }
        if (likedPostIDsDocs.length < 20) {
          isLastPage = true;
        }
      }
    } while (tempPosts.length < 20 && !isLastPage);
    likedPosts.addAll(tempPosts);
    setFavPosts(likedPosts);
    setState(() {});
  }

  Future<void> getMorePosts(
      String myUsername, void Function(List<Post>) setFavPosts) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<Post> tempPosts = [];
      final postsCollection = firestore.collection('Posts');
      do {
        final lastDoc = gottenIDs.last.id;
        final getLastDoc = await firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Fav Club Posts')
            .doc(lastDoc)
            .get();
        final likedPostIDs = await firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Fav Club Posts')
            .orderBy('date', descending: true)
            .startAfterDocument(getLastDoc)
            .limit(20)
            .get();
        final likedPostIDsDocs = likedPostIDs.docs;
        gottenIDs.addAll(likedPostIDsDocs);
        for (var id in likedPostIDsDocs) {
          final post = await postsCollection.doc(id.id).get();
          if (!post.exists) {
            toRemove.add(id.id);
          } else {
            initializePost(tempPosts: tempPosts, postID: id.id);
          }
        }
        if (likedPostIDsDocs.length < 20) {
          isLastPage = true;
        }
      } while (tempPosts.length < 20 && !isLastPage);
      isLoading = false;
      likedPosts.addAll(tempPosts);
      setFavPosts(likedPosts);
      setState(() {});
    }
  }

  Future<void> deleteNonExistant(List<String> _toDelete) async {
    final myFavs = firestore
        .collection('Users')
        .doc(deletionUsername)
        .collection('Fav Club Posts');
    if (_toDelete.isNotEmpty) for (var id in _toDelete) myFavs.doc(id).delete();
  }

  @override
  void initState() {
    super.initState();
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    deletionUsername = myUsername;
    final setFavPosts =
        Provider.of<MyProfile>(context, listen: false).setFavClubPosts;
    _scrollController =
        Provider.of<FavScreenScrollProvider>(context, listen: false)
            .favClubScrollController;
    _disposeScrollController =
        Provider.of<FavScreenScrollProvider>(context, listen: false)
            .disposeFavClubController;
    _getLikedPosts = getLikedPosts(myUsername, setFavPosts);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMorePosts(myUsername, setFavPosts);
          }
        }
      }
    });
  }

  Future<void> _pullRefresh(String myUsername, void Function() clearFavPosts,
      void Function(List<Post>) setFavPosts) async {
    isLastPage = false;
    likedPosts.clear();
    gottenIDs.clear();
    clearFavPosts();
    setState(() {
      _getLikedPosts = getLikedPosts(myUsername, setFavPosts);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _disposeScrollController();
    deleteNonExistant(toRemove);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final lang = General.language(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    const String _logoAddress = 'assets/images/noposts.svg';
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final setFavPosts =
        Provider.of<MyProfile>(context, listen: false).setFavClubPosts;
    final clearFavPosts =
        Provider.of<MyProfile>(context, listen: false).clearFavClubPosts;
    final bool selectedAnchorMode =
        Provider.of<ThemeModel>(context, listen: false).anchorMode;
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    super.build(context);
    return FutureBuilder(
      future: _getLikedPosts,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  lang.flares_commentLikes2,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                SizedBox(
                  height: 35.0,
                  width: 75.0,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(_primaryColor),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                        const EdgeInsets.all(0.0),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder?>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      isLastPage = false;
                      likedPosts.clear();
                      gottenIDs.clear();
                      clearFavPosts();
                      setState(() {
                        _getLikedPosts = getLikedPosts(myUsername, setFavPosts);
                      });
                    },
                    child: Center(
                      child: Text(
                        lang.flares_commentLikes3,
                        style: TextStyle(
                          color: _accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PostsLoading(false);
        }
        return Builder(
          builder: (context) {
            return (likedPosts.isEmpty)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                          child: Text(
                            lang.screens_favClubPosts,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  )
                : Stack(
                    children: <Widget>[
                      RefreshIndicator(
                        backgroundColor: _primaryColor,
                        displacement: 2.0,
                        color: _accentColor,
                        onRefresh: () => _pullRefresh(
                          myUsername,
                          clearFavPosts,
                          setFavPosts,
                        ),
                        child: Noglow(
                          child: ListView.separated(
                            shrinkWrap: true,
                            key: PageStorageKey<String>('FavoriteClubsPosts'),
                            padding: const EdgeInsets.only(bottom: 85.0),
                            itemCount: likedPosts.length + 1,
                            controller: _scrollController,
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
                              if (index == likedPosts.length) {
                                if (isLoading || isLastPage) return emptyBox;
                              } else {
                                final _currentPost = likedPosts[index];
                                final FullHelper _instance =
                                    _currentPost.instance;
                                const PostWidget _post = const PostWidget(
                                    isInFavClubs: true,
                                    isInFav: true,
                                    isInFeed: false,
                                    isInLike: false,
                                    isInTab: false,
                                    isInMyTab: false,
                                    isInOtherTab: false,
                                    isInClubPosts: false,
                                    isInLikedClubs: false,
                                    isInClubFeed: false,
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
  }

  @override
  bool get wantKeepAlive => true;
}
