import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../models/posterProfile.dart';
import '../models/post.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/topicScreenProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/themeModel.dart';
import '../widgets/settingsBar.dart';
import '../widgets/myFab.dart';
import '../widgets/postWidget.dart';
import '../widgets/adaptiveText.dart';
import '../widgets/shareWidget.dart';
import '../widgets/ads.dart';
import '../routes.dart';

class TopicPostsScreen extends StatefulWidget {
  final dynamic topic;
  const TopicPostsScreen(this.topic);
  static bool shareSheetOpen = false;
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
    TopicPostsScreen.shareSheetOpen = true;
    _shareController!.closed.then((value) {
      TopicPostsScreen.shareSheetOpen = false;
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
  _TopicPostsScreenState createState() => _TopicPostsScreenState();
}

class _TopicPostsScreenState extends State<TopicPostsScreen> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Post> feedPosts = [];
  bool noPostsFound = false;
  late Future _getPosts;
  late Future<void> _viewTopic;
  bool isLoading = false;
  bool isLastPage = false;
  TheVisibility generateVis(String vis) {
    if (vis == 'Public') {
      return TheVisibility.public;
    } else if (vis == 'Private') {
      return TheVisibility.private;
    }
    return TheVisibility.private;
  }

  Future<void> viewTopic(String myUsername) async {
    final _rightNow = DateTime.now();
    final myViewedTopics = firestore
        .collection('Users')
        .doc(myUsername)
        .collection('Viewed Topics');
    final topicViewers =
        firestore.collection('Topics').doc(widget.topic).collection('Viewers');
    var batch = firestore.batch();
    batch.set(myViewedTopics.doc(), {
      'topic': widget.topic,
      'date': _rightNow,
    });
    batch.set(topicViewers.doc(), {
      'ID': myUsername,
      'date': _rightNow,
    });
    return batch.commit();
  }

  Future<void> getPosts(String myUsername) async {
    List<Post> tempPosts = [];
    final usersCollection = firestore.collection('Users');
    final postsCollection = await firestore
        .collection('Topics')
        .doc(widget.topic)
        .collection('posts')
        .orderBy('date', descending: true)
        .limit(16)
        .get();
    final theposts = postsCollection.docs;
    if (theposts.isEmpty) {
      setState(() {
        noPostsFound = true;
      });
    } else {
      for (var postId in theposts) {
        final postID = postId.id;
        final post = await firestore.collection('Posts').doc(postID).get();
        if (post.exists) {
          dynamic getter(String field) => post.get(field);
          final String poster = getter('poster');
          final linkedUser = await usersCollection
              .doc(myUsername)
              .collection('Linked')
              .doc(poster)
              .get();
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
          final posterUser = await usersCollection.doc(poster).get();
          final posterImg = posterUser.get('Avatar');
          final posterBio = posterUser.get('Bio');
          final posterNumOfLinks = posterUser.get('numOfLinks');
          final posterNumOfLinked = posterUser.get('numOfLinked');
          final posterVisibility = posterUser.get('Visibility');
          final TheVisibility vis = generateVis(posterVisibility);
          if (vis == TheVisibility.private &&
              !linkedUser.exists &&
              poster != myUsername &&
              !myUsername.startsWith('Linkspeak')) {
          } else {
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
              location: location,
              locationName: locationName,
            );
            _post.setter();
            tempPosts.add(_post);
          }
        }
      }
      feedPosts.addAll([...tempPosts]);
      if (theposts.length < 16) {
        isLastPage = true;
      }
      setState(() {});
    }
  }

  Future<void> getMorePosts(String myUsername) async {
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      List<Post> tempPosts = [];
      final usersCollection = firestore.collection('Users');
      final lastPostID = feedPosts.last.postID;
      final getLastDoc = await firestore
          .collection('Topics')
          .doc(widget.topic)
          .collection('posts')
          .doc(lastPostID)
          .get();
      final postsCollection = await firestore
          .collection('Topics')
          .doc(widget.topic)
          .collection('posts')
          .orderBy('date', descending: true)
          .startAfterDocument(getLastDoc)
          .limit(16)
          .get();
      final theposts = postsCollection.docs;
      if (theposts.isNotEmpty) {
        for (var postId in theposts) {
          final postID = postId.id;
          final post = await firestore.collection('Posts').doc(postID).get();
          if (post.exists) {
            dynamic getter(String field) => post.get(field);
            final String poster = getter('poster');
            final linkedUser = await usersCollection
                .doc(myUsername)
                .collection('Linked')
                .doc(poster)
                .get();
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
            final posterUser = await usersCollection.doc(poster).get();
            final posterImg = posterUser.get('Avatar');
            final posterBio = posterUser.get('Bio');
            final posterNumOfLinks = posterUser.get('numOfLinks');
            final posterNumOfLinked = posterUser.get('numOfLinked');
            final posterVisibility = posterUser.get('Visibility');
            final TheVisibility vis = generateVis(posterVisibility);
            if (vis == TheVisibility.private &&
                !linkedUser.exists &&
                poster != myUsername &&
                !myUsername.startsWith('Linkspeak')) {
            } else {
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
                location: location,
                locationName: locationName,
              );
              _post.setter();
              tempPosts.add(_post);
            }
          }
        }
      }
      feedPosts.addAll([...tempPosts]);
      if (theposts.length < 16) {
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
    _getPosts = getPosts(myUsername);
    _viewTopic = viewTopic(myUsername);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMorePosts(myUsername);
          }
        }
      }
    });
  }

  Future<void> _pullRefresh(
      String myUsername, void Function() clearPosts) async {
    isLastPage = false;
    feedPosts.clear();
    clearPosts();
    setState(() {
      _getPosts = getPosts(myUsername);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String _logoAddress = 'assets/images/noposts.svg';
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final Color _primarySwatch = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    const ScrollPhysics _always = const AlwaysScrollableScrollPhysics();
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    const emptyBox = SizedBox(height: 0, width: 0);
    return Scaffold(
      floatingActionButton:
          (selectedAnchorMode) ? MyFab(_scrollController) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: null,
      body: SafeArea(
          child: ChangeNotifierProvider<TopicScreenProvider>.value(
        value: TopicScreenProvider(),
        child: Builder(
          builder: (context) {
            return FutureBuilder(
              key: PageStorageKey<String>('consttopicsFUTURE'),
              future: _getPosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SettingsBar(widget.topic),
                        const Spacer(),
                        const CircularProgressIndicator(),
                        const Spacer(),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SettingsBar(widget.topic),
                        const Spacer(),
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
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry?>(
                                    const EdgeInsets.symmetric(
                                      vertical: 1.0,
                                      horizontal: 5.0,
                                    ),
                                  ),
                                  enableFeedback: false,
                                  backgroundColor:
                                      MaterialStateProperty.all<Color?>(
                                          _primarySwatch),
                                ),
                                onPressed: () {
                                  _pullRefresh(myUsername, () {});
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
                        const Spacer(),
                      ],
                    ),
                  );
                }
                if (noPostsFound) {
                  return SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SettingsBar(widget.topic),
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
                              "No Posts yet",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                        ),
                        const Spacer()
                      ],
                    ),
                  );
                }
                final Widget _feedList = Builder(
                  builder: (context) {
                    Provider.of<TopicScreenProvider>(context, listen: false)
                        .setPosts(feedPosts);
                    return Builder(
                      builder: (context) {
                        final _posts =
                            Provider.of<TopicScreenProvider>(context).posts;
                        return SizedBox(
                          height: _deviceHeight,
                          width: _deviceWidth,
                          child: Column(
                            children: <Widget>[
                              SettingsBar(widget.topic),
                              Expanded(
                                child: ListView.separated(
                                  key:
                                      PageStorageKey<String>('TOPICSFeedStore'),
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

                                    return emptyBox;
                                  },
                                  itemBuilder: (context, index) {
                                    if (index == _posts.length) {
                                      if (isLoading) {
                                        return Center(
                                          child: Container(
                                            margin: const EdgeInsets.all(10.0),
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
                                      final _currentPost = _posts[index];
                                      final FullHelper _instance =
                                          _currentPost.instance;
                                      final PostWidget _post = PostWidget(
                                        isInFeed: true,
                                        isInLike: false,
                                        isInFav: false,
                                        isInTab: false,
                                        isInMyTab: false,
                                        isInOtherTab: false,
                                        isInTopics: true,
                                        otherController: null,
                                        topicScreenController:
                                            _scrollController,
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
                            ],
                          ),
                        );
                      },
                    );
                  },
                );

                return RefreshIndicator(
                    backgroundColor: _primarySwatch,
                    displacement: 40.0,
                    color: _accentColor,
                    onRefresh: () => Future.delayed(
                        const Duration(milliseconds: 1300),
                        () => _pullRefresh(
                            myUsername,
                            Provider.of<TopicScreenProvider>(context,
                                    listen: false)
                                .clearPosts)),
                    child: _feedList);
              },
            );
          },
        ),
      )),
    );
  }
}
