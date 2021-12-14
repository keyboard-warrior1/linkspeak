import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/profile.dart';
import '../models/posterProfile.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import 'adaptiveText.dart';
import 'postsTab.dart';
import 'postWidget.dart';

class MyPostsTab extends StatefulWidget {
  final scrollController;
  const MyPostsTab(this.scrollController);
  @override
  _MyPostsTabState createState() => _MyPostsTabState();
}

class _MyPostsTabState extends State<MyPostsTab>
    with AutomaticKeepAliveClientMixin {
  final firestore = FirebaseFirestore.instance;
  late Future<void> _getMyPosts;
  List<Post> myPosts = [];
  bool isLoading = false;
  bool isLastPage = false;
  int iDStart = 0;
  int idEnd = 15;
  Future<void> getMyPosts({
    required List<String> myPostIDs,
    required void Function(List<Post>) setMyPosts,
    required String myImg,
    required String myBio,
    required int myNumOfLinks,
    required int myNumOfLinkedTos,
    required TheVisibility myVis,
  }) async {
    if (myPostIDs.isNotEmpty) {
      List<Post> tempPosts = [];
      final postsCollection = firestore.collection('Posts');
      final int length = myPostIDs.length;
      late List<String> sub;
      if (length >= idEnd) {
        sub = myPostIDs.sublist(iDStart, idEnd);
      } else {
        final int ind = myPostIDs.indexOf(myPostIDs.first);
        sub = myPostIDs.sublist(ind);
      }
      for (var postID in sub) {
        final getPost = await postsCollection.doc(postID).get();
        if (!getPost.exists) {
        } else {
          final FullHelper _instance = FullHelper();
          dynamic getter(String field) => getPost.get(field);
          final theID = getPost.id;
          final String poster = getter('poster');
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
          final PosterProfile _posterProfile = PosterProfile(
              getUsername: poster,
              getProfileImage: myImg,
              getBio: myBio,
              getNumberOflinks: myNumOfLinks,
              getNumberOfLinkedTos: myNumOfLinkedTos,
              getVisibility: myVis);
          final Post _post = Post(
            key: UniqueKey(),
            instance: _instance,
            poster: _posterProfile,
            description: description,
            numOfLikes: numOfLikes,
            numOfComments: numOfComments,
            numOfTopics: numOfTopics,
            sensitiveContent: sensitiveContent,
            postID: theID,
            postedDate: serverpostedDate,
            topics: postTopics,
            imgUrls: imgUrls,
          );
          _post.setter();
          tempPosts.add(_post);
        }
      }
      myPosts.addAll(tempPosts);
      iDStart += 15;
      idEnd += 15;
      if (sub.length < 15) {
        isLastPage = true;
      }
      setMyPosts(myPosts);
      if (mounted) setState(() {});
    }
  }

  Future<void> getMorePosts({
    required List<String> myPostIDs,
    required void Function(List<Post>) setMyPosts,
    required String myImg,
    required String myBio,
    required int myNumOfLinks,
    required int myNumOfLinkedTos,
    required TheVisibility myVis,
  }) async {
    if (isLoading) {
    } else {
      if (mounted)
        setState(() {
          isLoading = true;
        });
      List<Post> tempPosts = [];
      final postsCollection = firestore.collection('Posts');
      final int length = myPostIDs.length;
      late List<String> sub;
      if (length >= idEnd) {
        sub = myPostIDs.sublist(iDStart, idEnd);
      } else {
        final lastPosts = myPosts.last;
        final lastPostID = lastPosts.postID;
        final lastPostIDindex = myPostIDs.indexOf(lastPostID);
        sub = myPostIDs.sublist(lastPostIDindex + 1);
      }
      for (var postID in sub) {
        final getPost = await postsCollection.doc(postID).get();
        if (!getPost.exists) {
        } else {
          final FullHelper _instance = FullHelper();
          dynamic getter(String field) => getPost.get(field);
          final theID = getPost.id;
          final String poster = getter('poster');
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
          final PosterProfile _posterProfile = PosterProfile(
              getUsername: poster,
              getProfileImage: myImg,
              getBio: myBio,
              getNumberOflinks: myNumOfLinks,
              getNumberOfLinkedTos: myNumOfLinkedTos,
              getVisibility: myVis);
          final Post _post = Post(
            key: UniqueKey(),
            instance: _instance,
            poster: _posterProfile,
            description: description,
            numOfLikes: numOfLikes,
            numOfComments: numOfComments,
            numOfTopics: numOfTopics,
            sensitiveContent: sensitiveContent,
            postID: theID,
            postedDate: serverpostedDate,
            topics: postTopics,
            imgUrls: imgUrls,
          );
          _post.setter();
          tempPosts.add(_post);
        }
      }
      myPosts.addAll(tempPosts);
      iDStart += 15;
      idEnd += 15;
      if (sub.length < 15) {
        isLastPage = true;
      }
      isLoading = false;
      setMyPosts(myPosts);
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final MyProfile myProfile = Provider.of<MyProfile>(context, listen: false);
    final myPostIDs = myProfile.getPostIDs;
    final myIMG = myProfile.getProfileImage;
    final myBio = myProfile.getBio;
    final myNumOfLinks = myProfile.getNumberOflinks;
    final myNumOfLinkedTos = myProfile.getNumberOfLinkedTos;
    final myVis = myProfile.getVisibility;
    final setMyPosts = myProfile.setMyPosts;
    _getMyPosts = getMyPosts(
        myPostIDs: myPostIDs,
        setMyPosts: setMyPosts,
        myImg: myIMG,
        myBio: myBio,
        myNumOfLinks: myNumOfLinks,
        myNumOfLinkedTos: myNumOfLinkedTos,
        myVis: myVis);
    PostsTab.scrollController.addListener(() {
      if (PostsTab.scrollController.position.pixels ==
          PostsTab.scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMorePosts(
                myPostIDs: myPostIDs,
                setMyPosts: setMyPosts,
                myImg: myIMG,
                myBio: myBio,
                myNumOfLinks: myNumOfLinks,
                myNumOfLinkedTos: myNumOfLinkedTos,
                myVis: myVis);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    PostsTab.scrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    const _logoAddress = 'assets/images/noposts.svg';
    final Size _querySize = MediaQuery.of(context).size;
    final ThemeData _theme = Theme.of(context);
    final double _deviceHeight = _querySize.height;
    final double _deviceWidth = _querySize.width;
    final Color _primaryColor = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    super.build(context);
    return FutureBuilder(
        future: _getMyPosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                const Center(
                  child: const CircularProgressIndicator(),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'An unknown error has occured',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 15.0),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color?>(
                            _primaryColor,
                          ),
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
                        onPressed: () => setState(() {}),
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
                ),
              ],
            );
          }
          return Builder(builder: (context) {
            final List<Post> _myPosts =
                Provider.of<MyProfile>(context, listen: false).getPosts;
            return (_myPosts.isEmpty)
                ? Column(
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
                            child: const Text(
                              'No posts yet',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 35.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : NotificationListener<OverscrollNotification>(
                    onNotification: (OverscrollNotification value) {
                      if (value.overscroll < 0 &&
                          widget.scrollController.offset + value.overscroll <=
                              0) {
                        if (widget.scrollController.offset != 0)
                          widget.scrollController.jumpTo(0);
                        return true;
                      }
                      if (widget.scrollController.offset + value.overscroll >=
                          widget.scrollController.position.maxScrollExtent) {
                        if (widget.scrollController.offset !=
                            widget.scrollController.position.maxScrollExtent)
                          widget.scrollController.jumpTo(
                              widget.scrollController.position.maxScrollExtent);
                        return true;
                      }
                      widget.scrollController.jumpTo(
                          widget.scrollController.offset + value.overscroll);
                      return true;
                    },
                    child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 85.0),
                        key: PageStorageKey<String>('storeMyPosts'),
                        shrinkWrap: true,
                        itemCount: _myPosts.length + 1,
                        controller: PostsTab.scrollController,
                        itemBuilder: (_, index) {
                          if (index == _myPosts.length) {
                            if (isLoading) {
                              return Center(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  height: 35.0,
                                  width: 35.0,
                                  child: Center(
                                    child: const CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            }
                            if (isLastPage) {
                              return emptyBox;
                            }
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
                              isInTopics: false,
                              otherController: null,
                              topicScreenController: null,
                            );
                            return ChangeNotifierProvider<FullHelper>.value(
                              value: instance,
                              child: _post,
                            );
                          }
                          return emptyBox;
                        }),
                  );
          });
        });
  }

  @override
  bool get wantKeepAlive => true;
}
