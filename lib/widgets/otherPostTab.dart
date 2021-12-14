import 'package:flutter/material.dart';
import 'package:link_speak/providers/otherProfileProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/profile.dart';
import '../models/posterProfile.dart';
import '../providers/myProfileProvider.dart';
import '../providers/fullPostHelper.dart';
import 'adaptiveText.dart';
import 'postWidget.dart';

class OtherPostsTab extends StatefulWidget {
  final bool publicProfile;
  final bool imLinkedToThem;
  final ScrollController scrollController;
  const OtherPostsTab(
      {required this.publicProfile, required this.imLinkedToThem,required this.scrollController});
  @override
  _OtherPostsTabState createState() => _OtherPostsTabState();
}

class _OtherPostsTabState extends State<OtherPostsTab>
    with AutomaticKeepAliveClientMixin {
  final firestore = FirebaseFirestore.instance;
  late Future<void> _getMyPosts;
  List<Post> myPosts = [];
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLastPage = false;
  Future<void> getMyPosts({
    required String myUsername,
    required void Function(List<Post>) setMyPosts,
    required String myImg,
    required String myBio,
    required int myNumOfLinks,
    required int myNumOfLinkedTos,
    required TheVisibility myVis,
  }) async {
    List<Post> tempPosts = [];
    final postsCollection = firestore.collection('Posts');
    final myPostIDs = await firestore
        .collection('Users')
        .doc(myUsername)
        .collection('Posts')
        .orderBy('date', descending: true)
        .limit(15)
        .get();
    final myPostIDsDocs = myPostIDs.docs;
    for (var postID in myPostIDsDocs) {
      final getPost = await postsCollection.doc(postID.id).get();
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
    if (myPostIDsDocs.length < 15) {
      isLastPage = true;
    }
    setMyPosts(myPosts);
    setState(() {});
  }

  Future<void> getMorePosts({
    required String myUsername,
    required void Function(List<Post>) setMyPosts,
    required String myImg,
    required String myBio,
    required int myNumOfLinks,
    required int myNumOfLinkedTos,
    required TheVisibility myVis,
  }) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<Post> tempPosts = [];
      final postsCollection = firestore.collection('Posts');
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
          .limit(15)
          .get();
      final myPostIDsDocs = myPostIDs.docs;
      for (var postID in myPostIDsDocs) {
        final getPost = await postsCollection.doc(postID.id).get();
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
      if (myPostIDsDocs.length < 15) {
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
    final myIMG = myProfile.getProfileImage;
    final myBio = myProfile.getBio;
    final myNumOfLinks = myProfile.getNumberOflinks;
    final myNumOfLinkedTos = myProfile.getNumberOfLinkedTos;
    final myVis = myProfile.getVisibility;
    final setMyPosts = myProfile.setOtherPosts;
    _getMyPosts = getMyPosts(
        myUsername: myUsername,
        setMyPosts: setMyPosts,
        myImg: myIMG,
        myBio: myBio,
        myNumOfLinks: myNumOfLinks,
        myNumOfLinkedTos: myNumOfLinkedTos,
        myVis: myVis);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMorePosts(
                myUsername: myUsername,
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
    _scrollController.removeListener(() {});
    _scrollController.dispose();
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
    final bool imBlocked =
        Provider.of<OtherProfile>(context, listen: false).imBlocked;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final Widget theTab = FutureBuilder(
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
                Provider.of<OtherProfile>(context, listen: false).getPosts;
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
                          widget.scrollController.offset + value.overscroll <= 0) {
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
                      widget.scrollController
                          .jumpTo(widget.scrollController.offset + value.overscroll);
                      return true;
                    },
                    child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 85.0),
                        key: PageStorageKey<String>('oreOtherusersPosts'),
                        shrinkWrap: true,
                        itemCount: _myPosts.length + 1,
                        controller: _scrollController,
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
                            final PostWidget _post = PostWidget(
                              isInFeed: false,
                              isInLike: false,
                              isInFav: false,
                              isInTab: true,
                              isInOtherTab: true,
                              isInMyTab: false,
                              isInTopics: false,
                              otherController: _scrollController,
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
    super.build(context);
    return (imBlocked)
        ? (!myUsername.startsWith('Linkspeak'))
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.lock_outline,
                    color: Colors.black,
                    size: _deviceHeight * 0.15,
                  ),
                ],
              )
            : theTab
        : (!widget.publicProfile)
            ? (!widget.imLinkedToThem)
                ? (!myUsername.startsWith('Linkspeak'))
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.lock_outline,
                            color: Colors.black,
                            size: _deviceHeight * 0.15,
                          ),
                        ],
                      )
                    : theTab
                : theTab
            : theTab;
  }

  @override
  bool get wantKeepAlive => true;
}
