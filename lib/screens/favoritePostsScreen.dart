import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../routes.dart';
import '../models/screenArguments.dart';
import '../models/profile.dart';
import '../models/post.dart';
import '../models/posterProfile.dart';
import '../providers/myProfileProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/themeModel.dart';
import '../widgets/settingsBar.dart';
import '../widgets/adaptiveText.dart';
import '../widgets/postWidget.dart';
import '../widgets/myFab.dart';
import '../widgets/shareWidget.dart';
import '../widgets/ads.dart';

class FavPostScreen extends StatefulWidget {
  const FavPostScreen();
  static bool shareSheetOpen = false;
  static ScrollController scrollController = ScrollController();
  static late PersistentBottomSheetController? _shareController;
  static void sharePost(BuildContext context, String postID) {
    _shareController = showBottomSheet(
      context: context,
      builder: (context) {
        return ShareWidget(
          isInFeed: false,
          bottomSheetController: _shareController,
          postID: postID,
        );
      },
      backgroundColor: Colors.transparent,
    );
    FavPostScreen.shareSheetOpen = true;
    _shareController!.closed.then((value) {
      FavPostScreen.shareSheetOpen = false;
    });
  }

  static void showMyDialog(
      {required final BuildContext context,
      required final username,
      required final myUsername}) {
    if ((username == myUsername)) {
    } else {
      void _visitProfile({required final String username}) {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: username);
        Navigator.pushNamed(
          context,
          (username == myUsername)
              ? RouteGenerator.myProfileScreen
              : RouteGenerator.posterProfileScreen,
          arguments: args,
        );
      }

      showDialog(
          context: context,
          builder: (_) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _visitProfile(username: username),
                      child: const Text(
                        'Visit profile',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  @override
  _FavPostScreenState createState() => _FavPostScreenState();
}

class _FavPostScreenState extends State<FavPostScreen> {
  final ScrollController _scrollController = FavPostScreen.scrollController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getLikedPosts;
  bool isLoading = false;
  bool isLastPage = false;
  int iDStart = 0;
  int idEnd = 8;
  TheVisibility generateVis(String vis) {
    if (vis == 'Public') {
      return TheVisibility.public;
    } else if (vis == 'Private') {
      return TheVisibility.private;
    }
    return TheVisibility.private;
  }

  List<Post> likedPosts = [];
  List<String> noShow = [];
  Future<void> getLikedPosts(
    String myUsername,
    List<String> likedPostIDs,
    void Function(List<Post>) setFavPosts,
  ) async {
    if (likedPostIDs.isEmpty) {
      return;
    }
    List<Post> tempPosts = [];
    final int length = likedPostIDs.length;
    final postsCollection = firestore.collection('Posts');
    final usersCollection = firestore.collection('Users');
    late List<String> sub;
    do {
      if (length >= idEnd) {
        sub = likedPostIDs.sublist(iDStart, idEnd);
      } else {
        late int start;
        late String noShowLast;
        late String tempPostLast;
        if (noShow.isNotEmpty) {
          noShowLast = noShow.last;
        }
        if (tempPosts.isNotEmpty) {
          tempPostLast = tempPosts.last.postID;
        }
        if (noShow.isNotEmpty && tempPosts.isNotEmpty) {
          final int lastNoShowIDindex = likedPostIDs.indexOf(noShowLast);
          final int lastPostIDindex = likedPostIDs.indexOf(tempPostLast);
          if (lastNoShowIDindex > lastPostIDindex) {
            start = lastNoShowIDindex;
          }
          if (lastPostIDindex > lastNoShowIDindex) {
            start = lastPostIDindex;
          }
        }
        if (noShow.isEmpty && tempPosts.isNotEmpty) {
          start = likedPostIDs.indexOf(tempPostLast);
        }
        if (tempPosts.isEmpty && noShow.isNotEmpty) {
          start = likedPostIDs.indexOf(noShowLast);
        }
        if (tempPosts.isEmpty && noShow.isEmpty) {
          start = likedPostIDs.indexOf(likedPostIDs.first);
        }
        sub = likedPostIDs.sublist(start);
      }
      for (var id in sub) {
        final post = await postsCollection.doc(id).get();
        if (!post.exists) {
          noShow.add(post.id);
        } else {
          final FullHelper _instance = FullHelper();
          dynamic getter(String field) => post.get(field);
          final postID = post.id;
          if (!tempPosts.any((post) => post.postID == postID)) {
            final String poster = getter('poster');
            final posterUser = await usersCollection.doc(poster).get();
            final posterVisibility = posterUser.get('Visibility');
            final TheVisibility vis = generateVis(posterVisibility);
            final posterBlockedUsers = await usersCollection
                .doc(poster)
                .collection('Blocked')
                .doc(myUsername)
                .get();
            final posterLinksMe = await usersCollection
                .doc(poster)
                .collection('Links')
                .doc(myUsername)
                .get();
            final bool imBlocked = posterBlockedUsers.exists;
            if (imBlocked ||
                (vis == TheVisibility.private &&
                    !posterLinksMe.exists &&
                    poster != myUsername)) {
              noShow.add(postID);
            } else {
              dynamic location = '';
              String locationName = '';
              if (post.data()!.containsKey('location')) {
                final actualLocation = getter('location');
                location = actualLocation;
              }
              if (post.data()!.containsKey('locationName')) {
                final actualLocationName = getter('locationName');
                locationName = actualLocationName;
              }
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

              final PosterProfile _posterProfile = PosterProfile(
                  getUsername: poster,
                  getProfileImage: posterImg,
                  getBio: posterBio,
                  getNumberOflinks: posterNumOfLinks,
                  getNumberOfLinkedTos: posterNumOfLinked,
                  getVisibility: vis);
              final Post _post = Post(
                key: UniqueKey(),
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
                location: location,
                locationName: locationName,
              );
              _post.setter();
              tempPosts.add(_post);
            }
          }
        }
      }
      iDStart += 8;
      idEnd += 8;
      final int total = noShow.length + tempPosts.length;
      final int remainder = length - total;
      if (remainder <= 0) {
        isLastPage = true;
      }
      setState(() {});
    } while (sub.length > tempPosts.length && !isLastPage);
    likedPosts.addAll([...tempPosts]);
    setFavPosts(likedPosts);
    final int total = noShow.length + likedPosts.length;
    final int remainder = length - total;
    if (remainder <= 0) {
      isLastPage = true;
    }
    setState(() {});
  }

  Future<void> getMorePosts(
    String myUsername,
    List<String> likedPostIDs,
    void Function(List<Post>) setFavPosts,
  ) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<Post> tempPosts = [];
      final int length = likedPostIDs.length;
      final postsCollection = firestore.collection('Posts');
      final usersCollection = firestore.collection('Users');
      late final List<String> sub;
      do {
        if (length >= idEnd) {
          sub = likedPostIDs.sublist(iDStart, idEnd);
        } else {
          late int start;
          late String noShowLast;
          late String tempPostLast;
          if (noShow.isNotEmpty) {
            noShowLast = noShow.last;
          }
          if (tempPosts.isNotEmpty) {
            tempPostLast = tempPosts.last.postID;
          }
          if (noShow.isNotEmpty && tempPosts.isNotEmpty) {
            final int lastNoShowIDindex = likedPostIDs.indexOf(noShowLast);
            final int lastPostIDindex = likedPostIDs.indexOf(tempPostLast);
            if (lastNoShowIDindex > lastPostIDindex) {
              start = lastNoShowIDindex;
            }
            if (lastPostIDindex > lastNoShowIDindex) {
              start = lastPostIDindex;
            }
          }
          if (noShow.isEmpty && tempPosts.isNotEmpty) {
            start = likedPostIDs.indexOf(tempPostLast);
          }
          if (tempPosts.isEmpty && noShow.isNotEmpty) {
            start = likedPostIDs.indexOf(noShowLast);
          }
          if (tempPosts.isEmpty && noShow.isEmpty) {
            final String lastID = likedPosts.last.postID;
            start = likedPostIDs.indexOf(lastID);
          }
          sub = likedPostIDs.sublist(start);
        }
        for (var id in sub) {
          final post = await postsCollection.doc(id).get();
          if (!post.exists) {
            noShow.add(post.id);
          } else {
            final FullHelper _instance = FullHelper();
            dynamic getter(String field) => post.get(field);
            final postID = post.id;
            if (!likedPosts.any((post) => post.postID == postID)) {
              final String poster = getter('poster');
              final posterUser = await usersCollection.doc(poster).get();
              final posterVisibility = posterUser.get('Visibility');
              final TheVisibility vis = generateVis(posterVisibility);
              final posterBlockedUsers = await usersCollection
                  .doc(poster)
                  .collection('Blocked')
                  .doc(myUsername)
                  .get();
              final posterLinksMe = await usersCollection
                  .doc(poster)
                  .collection('Links')
                  .doc(myUsername)
                  .get();
              final bool imBlocked = posterBlockedUsers.exists;
              if (imBlocked ||
                  (vis == TheVisibility.private &&
                      !posterLinksMe.exists &&
                      poster != myUsername)) {
                noShow.add(post.id);
              } else {
                dynamic location = '';
                String locationName = '';
                if (post.data()!.containsKey('location')) {
                  final actualLocation = getter('location');
                  location = actualLocation;
                }
                if (post.data()!.containsKey('locationName')) {
                  final actualLocationName = getter('locationName');
                  locationName = actualLocationName;
                }
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

                final PosterProfile _posterProfile = PosterProfile(
                    getUsername: poster,
                    getProfileImage: posterImg,
                    getBio: posterBio,
                    getNumberOflinks: posterNumOfLinks,
                    getNumberOfLinkedTos: posterNumOfLinked,
                    getVisibility: vis);
                final Post _post = Post(
                  key: UniqueKey(),
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
                  location: location,
                  locationName: locationName,
                );
                _post.setter();
                tempPosts.add(_post);
              }
            }
          }
        }
        iDStart += 8;
        idEnd += 8;
        final total = likedPosts.length + noShow.length + tempPosts.length;
        final remainder = length - total;
        if (remainder <= 0) {
          isLastPage = true;
        }
        setState(() {});
      } while (sub.length > tempPosts.length && !isLastPage);
      likedPosts.addAll([...tempPosts]);
      isLoading = false;
      setFavPosts(likedPosts);
      final newtotal = likedPosts.length + noShow.length;
      final newremainder = length - newtotal;
      if (newremainder <= 0) {
        isLastPage = true;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final likedPostIDs =
        Provider.of<MyProfile>(context, listen: false).getfavPostIDs;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final setFavPosts =
        Provider.of<MyProfile>(context, listen: false).setFavPostas;
    _getLikedPosts = getLikedPosts(myUsername, likedPostIDs, setFavPosts);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMorePosts(myUsername, likedPostIDs, setFavPosts);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    const String _logoAddress = 'assets/images/noposts.svg';
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    final likedPostIDs = Provider.of<MyProfile>(context).getfavPostIDs;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final setFavPosts =
        Provider.of<MyProfile>(context, listen: false).setFavPostas;
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    return Scaffold(
      backgroundColor: Colors.white10,
      floatingActionButton:
          (selectedAnchorMode) ? MyFab(_scrollController) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder(
        future: _getLikedPosts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SafeArea(
              child: SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SettingsBar("Favorites"),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'An error has occured, please try again',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                                _primaryColor),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry?>(
                              const EdgeInsets.all(0.0),
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder?>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          onPressed: () =>
                              setState(() => _getLikedPosts = getLikedPosts(
                                    myUsername,
                                    likedPostIDs,
                                    setFavPosts,
                                  )),
                          child: Center(
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: _accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SafeArea(
              child: SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SettingsBar("Favorites"),
                    const Spacer(),
                    const CircularProgressIndicator(),
                    const Spacer(),
                  ],
                ),
              ),
            );
          }
          return Builder(
            builder: (context) {
              return SafeArea(
                child: (likedPosts.isEmpty)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SettingsBar("Favorites"),
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
                                "No favorites found",
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
                    : Column(
                        children: [
                          const SettingsBar("Favorites"),
                          Expanded(
                            child: NotificationListener<
                                OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                                overscroll.disallowGlow();
                                return false;
                              },
                              child: ListView.separated(
                                shrinkWrap: true,
                                key: PageStorageKey<String>('FavoritesPosts'),
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
                                    if (isLoading) {
                                      return Center(
                                        child: SizedBox(
                                          height: 35.0,
                                          width: 35.0,
                                          child: Center(
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                        ),
                                      );
                                    }
                                    if (isLastPage) {
                                      return emptyBox;
                                    }
                                  } else {
                                    final _currentPost = likedPosts[index];
                                    final FullHelper _instance =
                                        _currentPost.instance;
                                    const PostWidget _post = PostWidget(
                                      isInFeed: false,
                                      isInLike: false,
                                      isInFav: true,
                                      isInTab: false,
                                      isInMyTab: false,
                                      isInOtherTab: false,
                                      isInTopics: false,
                                      otherController: null,
                                      topicScreenController: null,
                                    );
                                    return ChangeNotifierProvider<
                                        FullHelper>.value(
                                      value: _instance,
                                      child: _post,
                                    );
                                  }
                                  return emptyBox;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
