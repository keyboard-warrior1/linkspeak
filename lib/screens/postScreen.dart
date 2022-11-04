import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/post.dart';
import '../models/boardPostItem.dart';
import '../models/posterProfile.dart';
import '../models/profile.dart';
import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcon;
import '../providers/clubProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/myFab.dart';
import '../widgets/common/title.dart';
import '../widgets/post/boardPostWidget.dart';
import '../widgets/post/branchPostWidget.dart';
import '../widgets/fullPost/commentsView.dart';
import '../widgets/fullPost/fullPost.dart';
import '../widgets/fullPost/likesView.dart';
import '../widgets/fullPost/shareView.dart';
import '../widgets/fullPost/topicsView..dart';
import '../widgets/post/boardSections.dart';

enum ViewMode { post, comments, topics, likes, share }

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
  final dynamic viewMode;
  final dynamic instance;
  final dynamic previewSetstate;
  final dynamic isNotif;
  final dynamic postID;
  final dynamic clubName;
  final dynamic section;
  final dynamic singleCommentID;
  const PostScreen(
      {required this.viewMode,
      required this.instance,
      required this.previewSetstate,
      required this.isNotif,
      required this.postID,
      required this.clubName,
      required this.section,
      required this.singleCommentID});
}

class _PostScreenState extends State<PostScreen> {
  late final ScrollController scrollController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ViewMode stateViewMode = ViewMode.post;
  // ignore: avoid_init_to_null
  Future<void>? getPost = null;
  Post? notifPost;
  bool postNotFound = false;
  String _posterName = '';
  ClubVisibility clubVis = ClubVisibility.public;
  TheVisibility posterVis = TheVisibility.public;
  bool _isClubPost = false;
  bool isBanned = false;
  bool imBlocked = false;
  bool imLinkedToThem = false;
  bool isclubBanned = false;
  bool isClubMember = false;
  bool clubIsProhibited = false;
  bool clubIsDisabled = false;
  Future<void> _pullRefresh(String myUsername) async {
    setState(() {
      getPost = _getPost(myUsername);
    });
  }

  Future<void> _getPost(String myUsername) async {
    final DocumentSnapshot<Map<String, dynamic>> post =
        await firestore.collection('Posts').doc(widget.postID).get();
    final usersCollection = firestore.collection('Users');
    final clubsCollection = firestore.collection('Clubs');
    final myUser = usersCollection.doc(myUsername);
    final myLiked = myUser.collection(
        (widget.clubName != '') ? 'Liked Club Posts' : 'LikedPosts');
    final myFavs = myUser
        .collection((widget.clubName != '') ? 'Fav Club Posts' : 'FavPosts');
    final myHidden = myUser.collection('HiddenPosts');
    if (post.exists) {
      final getLiked = await myLiked.doc(widget.postID).get();
      final bool isLiked = getLiked.exists;
      final getFav = await myFavs.doc(widget.postID).get();
      final bool isFav = getFav.exists;
      final getHidden = await myHidden.doc(widget.postID).get();
      final isHidden = getHidden.exists;
      PostType theType = PostType.legacy;
      List<BoardPostItem> paramBoardPostItems = [];
      Color paramBoardPostBackground = Colors.blue;
      Color paramBoardPostGradient = Colors.yellow;
      dynamic getter(String field) => post.get(field);
      final postID = post.id;
      dynamic location = '';
      String locationName = '';
      String clubName = '';
      bool isClubPost = false;
      bool isMod = false;
      bool _isclubBanned = false;
      bool _isClubMember = false;
      bool _clubIsProhibited = false;
      bool _clubIsDisabled = false;
      ClubVisibility _clubVis = ClubVisibility.public;
      if (post.data()!.containsKey('type')) {
        final actualType = getter('type');
        final genType = General.generatePostType(actualType);
        theType = genType;
      }
      if (post.data()!.containsKey('items')) {
        List<BoardPostItem> _stateItems = [];
        final List<dynamic> backendItems = getter('items');
        _stateItems = backendItems.map((e) {
          final isText = e['isText'];
          final description = e['description'];
          final mediaURL = e['mediaURL'];
          return BoardPostItem(
              isText: isText,
              mediaIsAsset: false,
              isInEdit: false,
              description: description,
              mediaURL: mediaURL,
              assetPath: '');
        }).toList();
        paramBoardPostItems = _stateItems;
      }
      if (post.data()!.containsKey('backgroundColor')) {
        final actualColor = getter('backgroundColor');
        if (actualColor != '') {
          Color _stateColor = Color(actualColor);
          paramBoardPostBackground = _stateColor;
        }
      }
      if (post.data()!.containsKey('gradientColor')) {
        final actualGradientColor = getter('gradientColor');
        if (actualGradientColor != '') {
          Color _stateGradientColor = Color(actualGradientColor);
          paramBoardPostGradient = _stateGradientColor;
        }
      }
      if (post.data()!.containsKey('clubName')) {
        final actualClubName = getter('clubName');
        clubName = actualClubName;
        if (actualClubName != '') {
          isClubPost = true;
          final thisClub = clubsCollection.doc(clubName);
          final getThisClub = await thisClub.get();
          final clubVisibility = getThisClub.get('Visibility');
          _clubVis = General.convertClubVis(clubVisibility);
          final clubDisability = getThisClub.get('isDisabled');
          _clubIsDisabled = clubDisability;
          final getProhibition = getThisClub.get('isProhibited');
          _clubIsProhibited = getProhibition;
          final getMyMember =
              await thisClub.collection('Members').doc(myUsername).get();
          _isClubMember = getMyMember.exists;
          final getMyBanned =
              await thisClub.collection('Banned').doc(myUsername).get();
          _isclubBanned = getMyBanned.exists;
          final getIsMod = await firestore
              .collection('Clubs')
              .doc(actualClubName)
              .collection('Moderators')
              .doc(myUsername)
              .get();
          if (getIsMod.exists) {
            isMod = true;
          }
        }
      }
      bool commentsDisabled = false;
      if (post.data()!.containsKey('commentsDisabled')) {
        final actualDisabled = getter('commentsDisabled');
        commentsDisabled = actualDisabled;
      }
      if (post.data()!.containsKey('location')) {
        final actualLocation = getter('location');
        location = actualLocation;
      }
      if (post.data()!.containsKey('locationName')) {
        final actualLocationName = getter('locationName');
        locationName = actualLocationName;
      }
      final String poster = getter('poster');
      final userLinks = await usersCollection
          .doc(poster)
          .collection('Links')
          .doc(myUsername)
          .get();
      final userBlocks = await usersCollection
          .doc(poster)
          .collection('Blocked')
          .doc(myUsername)
          .get();
      final actualBlock = userBlocks.exists;
      final actualLink = userLinks.exists;
      final posterUser = await usersCollection.doc(poster).get();
      final posterVisibility = posterUser.get('Visibility');
      final String posterStatus = posterUser.get('Status');
      final TheVisibility vis = General.convertProfileVis(posterVisibility);
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
      final FullHelper _instance =
          (widget.instance != null) ? widget.instance : FullHelper();
      final key = UniqueKey();
      final PosterProfile _posterProfile =
          PosterProfile(getUsername: poster, getVisibility: vis);
      final Post _post = Post(
          key: key,
          instance: _instance,
          poster: _posterProfile,
          description: description,
          numOfLikes: numOfLikes,
          numOfComments: numOfComments,
          numOfTopics: numOfTopics,
          sensitiveContent: sensitiveContent,
          commentsDisabled: commentsDisabled,
          postID: postID,
          postedDate: serverpostedDate,
          topics: postTopics,
          imgUrls: imgUrls,
          location: location,
          locationName: locationName,
          clubName: clubName,
          isClubPost: isClubPost,
          isLiked: isLiked,
          isFav: isFav,
          isHidden: isHidden,
          isMod: isMod,
          postType: theType,
          items: paramBoardPostItems,
          backgroundColor: paramBoardPostBackground,
          gradientColor: paramBoardPostGradient);
      _post.setter();
      notifPost = _post;
      setState(() {
        _isClubPost = isClubPost;
        _posterName = poster;
        if (posterStatus == 'Banned') {
          isBanned = true;
        } else {
          isBanned = false;
        }
        imBlocked = actualBlock;
        imLinkedToThem = actualLink;
        clubVis = _clubVis;
        posterVis = vis;
        isclubBanned = _isclubBanned;
        isClubMember = _isClubMember;
        clubIsProhibited = _clubIsProhibited;
        clubIsDisabled = _clubIsDisabled;
      });
      bool isManagement = myUsername.startsWith('Linkspeak');
      bool condition = postNotFound ||
          (imBlocked && !isManagement) ||
          (isBanned && !isManagement) ||
          (_isClubPost &&
              !isManagement &&
              _posterName != myUsername &&
              ((clubVis != ClubVisibility.public && !isClubMember) ||
                  clubIsProhibited ||
                  clubIsDisabled ||
                  isclubBanned)) ||
          (!_isClubPost &&
              !isManagement &&
              posterVis != TheVisibility.public &&
              !imLinkedToThem &&
              _posterName != myUsername);
      if (widget.section == Section.single &&
          (theType == PostType.board || theType == PostType.board)) {
        if (condition) {
        } else {
          Future.delayed(const Duration(milliseconds: 500), () {
            final _size = MediaQuery.of(context).size;
            final _height = _size.height;
            final _width = General.widthQuery(context);
            showModalBottomSheet(
                context: context,
                barrierColor: Colors.black,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(10),
                        topRight: const Radius.circular(10))),
                builder: (ctx) => Container(
                    height: _height,
                    width: _width,
                    child: BoardSections(
                      isLikers: false,
                      isComments: true,
                      isTopics: false,
                      topics: [],
                      numOfLikes: numOfLikes,
                      numOfComments: numOfComments,
                      postID: postID,
                      clubName: clubName,
                      instance: _post.instance,
                      isClubPost: isClubPost,
                      section: Section.single,
                      setComments: _post.instance.setComments,
                      singleCommentID: widget.singleCommentID,
                    )));
          });
        }
      }
    } else {
      postNotFound = true;
      if (mounted) setState(() {});
      return;
    }
  }

  final void Function(BuildContext, String, String) _handler =
      (BuildContext context, String posterID, String myUsername) {
    final OtherProfileScreenArguments args =
        OtherProfileScreenArguments(otherProfileId: posterID);
    Navigator.pushNamed(
        context,
        (posterID != myUsername)
            ? RouteGenerator.posterProfileScreen
            : RouteGenerator.myProfileScreen,
        arguments: (posterID != myUsername) ? args : null);
  };

  Widget display(BuildContext context, ViewMode viewMode, double deviceHeight,
      FullHelper theInstance) {
    final FullHelper helper = Provider.of<FullHelper>(context);
    final String postId = helper.postId;
    final bool isClubPost = helper.isClubPost;
    final int numOfTopics = helper.numOfTopics;
    final List<String> topics = helper.postTopics;
    final PostType postType = helper.postType;
    final bool isBoard = postType == PostType.board;
    final bool isBranch = postType == PostType.branch;
    final int numOfLikes = Provider.of<FullHelper>(context).getNumOfLikes;
    final int numOfComments = Provider.of<FullHelper>(context).getNumOfComments;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    const ViewMode _post = ViewMode.post;
    const ViewMode _ups = ViewMode.likes;
    const ViewMode _comments = ViewMode.comments;
    const ViewMode _topics = ViewMode.topics;
    const ViewMode _share = ViewMode.share;
    final bool _upsView = viewMode == ViewMode.likes;
    final bool _commentsView = viewMode == ViewMode.comments;
    final bool _topicsView = viewMode == ViewMode.topics;
    final bool _shareView = viewMode == ViewMode.share;
    Future<void> refreshHandler() async {
      _pullRefresh(myUsername);
    }

    void _upButtonHandler(dynamic likeIt) {
      setState(() {
        if (_commentsView || _topicsView || _shareView) {
          stateViewMode = _ups;
          _down(deviceHeight);
        } else if (_upsView) {
          stateViewMode = _post;
        } else {
          likeIt();
        }
      });
    }

    void _likeTextHandler() {
      setState(() {
        if (_upsView) {
          stateViewMode = _post;
        } else {
          stateViewMode = _ups;
          _down(deviceHeight);
        }
      });
    }

    void _commentButtonHandler() {
      setState(() {
        if (_commentsView) {
          stateViewMode = _post;
        } else {
          stateViewMode = _comments;
          _down(deviceHeight);
        }
      });
    }

    void _topicButtonHandler() {
      setState(() {
        if (_topicsView) {
          stateViewMode = _post;
        } else {
          stateViewMode = _topics;
          _down(deviceHeight);
        }
      });
    }

    void _shareButtonHandler() {
      setState(() {
        if (_shareView) {
          stateViewMode = _post;
        } else {
          stateViewMode = _share;
          _down(deviceHeight);
        }
      });
    }

    Widget? _displayViews() {
      switch (viewMode) {
        case ViewMode.post:
          break;
        case ViewMode.likes:
          return LikesView(numOfLikes, scrollController, _handler, postId);
        case ViewMode.comments:
          return CommentsView(
              numOfComments: numOfComments,
              scrollController: scrollController,
              postId: postId,
              handler: _handler,
              isClubPost: isClubPost,
              section: widget.section,
              singleCommentID: widget.singleCommentID);
        case ViewMode.topics:
          return TopicsView(
              numOfTopics: numOfTopics, topics: topics, postID: postId);
        case ViewMode.share:
          return ShareView(scrollController);
      }
      return null;
    }

    if (isBoard) {
      return BoardPostWidget(
          inPreview: false,
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
          isInPeopleAdmin: false,
          isInClubAdmin: false,
          instance: theInstance);
    } else if (isBranch) {
      return BranchPostWidget(
          inPreview: false,
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
          isInPeopleAdmin: false,
          isInClubAdmin: false,
          instance: theInstance);
    } else {
      switch (viewMode) {
        case ViewMode.post:
          final Widget _fullpost = FullPost(
              scrollController: scrollController,
              display: null,
              upView: _upsView,
              commentsView: _commentsView,
              topicsView: _topicsView,
              shareView: _shareView,
              upButtonHandler: _upButtonHandler,
              likeTextHandler: _likeTextHandler,
              upvote: () {},
              commentButtonHandler: _commentButtonHandler,
              topicButtonHandler: _topicButtonHandler,
              shareButtonHandler: _shareButtonHandler,
              previewSetstate: widget.previewSetstate,
              refreshHandler: refreshHandler);
          return _fullpost;

        case ViewMode.comments:
        case ViewMode.topics:
        case ViewMode.likes:
        case ViewMode.share:
          return FullPost(
              scrollController: scrollController,
              display: _displayViews(),
              upView: _upsView,
              commentsView: _commentsView,
              topicsView: _topicsView,
              shareView: _shareView,
              upButtonHandler: _upButtonHandler,
              likeTextHandler: _likeTextHandler,
              upvote: () {},
              commentButtonHandler: _commentButtonHandler,
              topicButtonHandler: _topicButtonHandler,
              shareButtonHandler: _shareButtonHandler,
              previewSetstate: widget.previewSetstate,
              refreshHandler: refreshHandler);
      }
    }
  }

  void _up() {
    if (scrollController.position.pixels !=
        scrollController.position.minScrollExtent) {
      final double top = scrollController.position.minScrollExtent;
      final double currentPosition = scrollController.position.pixels;
      final double distance = top - currentPosition;
      final double _num = distance / -15;
      final Duration duration = Duration(milliseconds: _num.round());
      scrollController.animateTo(top, duration: duration, curve: Curves.linear);
    }
  }

  void _down(double deviceHeight) => scrollController.animateTo(
      scrollController.position.maxScrollExtent + deviceHeight * 0.3,
      duration: kThemeAnimationDuration,
      curve: Curves.easeOut);
  @override
  void initState() {
    super.initState();
    stateViewMode = widget.viewMode;
    scrollController = ScrollController();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    if (widget.isNotif) getPost = _getPost(myUsername);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final bool isManagement = myUsername.startsWith('Linkspeak');
    return FutureBuilder(
        future: getPost,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                    child: SizedBox(
                        height: _deviceHeight,
                        width: _deviceWidth,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              OptimisedText(
                                  minWidth: _deviceWidth * 0.5,
                                  maxWidth: _deviceWidth * 0.65,
                                  minHeight: 50.0,
                                  maxHeight: 50.0,
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            splashColor: Colors.transparent,
                                            icon: Container(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                child: const Icon(
                                                    customIcon.MyFlutterApp
                                                        .curve_arrow,
                                                    color: Colors.black))),
                                        TextButton(
                                            style: ButtonStyle(
                                                elevation: MaterialStateProperty
                                                    .all<double?>(0.0),
                                                padding:
                                                    MaterialStateProperty.all<
                                                            EdgeInsetsGeometry?>(
                                                        const EdgeInsets.all(
                                                            0.0)),
                                                splashFactory:
                                                    NoSplash.splashFactory,
                                                enableFeedback: false),
                                            onPressed: () {},
                                            child: const MyTitle())
                                      ])),
                              const Spacer(),
                              Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const CircularProgressIndicator(
                                        strokeWidth: 1.50)
                                  ]),
                              const Spacer()
                            ]))));
          }
          if (snapshot.hasError ||
              postNotFound ||
              (imBlocked && !isManagement) ||
              (isBanned && !isManagement) ||
              (_isClubPost &&
                  !isManagement &&
                  _posterName != myUsername &&
                  ((clubVis != ClubVisibility.public && !isClubMember) ||
                      clubIsProhibited ||
                      clubIsDisabled ||
                      isclubBanned)) ||
              (!_isClubPost &&
                  !isManagement &&
                  posterVis != TheVisibility.public &&
                  !imLinkedToThem &&
                  _posterName != myUsername)) {
            return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                    child: SizedBox(
                        height: _deviceHeight,
                        width: _deviceWidth,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              OptimisedText(
                                  minWidth: _deviceWidth * 0.5,
                                  maxWidth: _deviceWidth * 0.65,
                                  minHeight: 50.0,
                                  maxHeight: 50.0,
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            splashColor: Colors.transparent,
                                            icon: Container(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                child: const Icon(
                                                    customIcon.MyFlutterApp
                                                        .curve_arrow,
                                                    color: Colors.black))),
                                        TextButton(
                                            style: ButtonStyle(
                                                elevation: MaterialStateProperty
                                                    .all<double?>(0.0),
                                                padding:
                                                    MaterialStateProperty.all<
                                                            EdgeInsetsGeometry?>(
                                                        const EdgeInsets.all(
                                                            0.0)),
                                                splashFactory:
                                                    NoSplash.splashFactory,
                                                enableFeedback: false),
                                            onPressed: () {},
                                            child: const MyTitle())
                                      ])),
                              const Spacer(),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const <Widget>[
                                    const Icon(Icons.error, size: 50.0)
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const <Widget>[
                                    const Text('Post Unavailable')
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const <Widget>[
                                    const Text(
                                        'This post may have been deleted or removed')
                                  ]),
                              const Spacer()
                            ]))));
          }
          return ChangeNotifierProvider<FullHelper>.value(
              value: (widget.isNotif) ? notifPost!.instance : widget.instance,
              child: Builder(builder: (context) {
                final helper = Provider.of<FullHelper>(context, listen: false);
                final PostType postType = helper.postType;
                final bool isBoard = postType == PostType.board;
                return GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Scaffold(
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.centerFloat,
                        floatingActionButton: (selectedAnchorMode)
                            ? (stateViewMode != ViewMode.post)
                                ? MyFab(scrollController)
                                : null
                            : null,
                        extendBody: true,
                        extendBodyBehindAppBar: true,
                        appBar: null,
                        backgroundColor: Colors.white,
                        body: SafeArea(
                            child: Stack(children: <Widget>[
                          display(
                              context,
                              stateViewMode,
                              _deviceHeight,
                              (widget.isNotif)
                                  ? notifPost!.instance
                                  : widget.instance),
                          if (!isBoard)
                            Align(
                                alignment: Alignment.topLeft,
                                child: OptimisedText(
                                    minWidth: _deviceWidth * 0.5,
                                    maxWidth: _deviceWidth * 0.65,
                                    minHeight: 50.0,
                                    maxHeight: 50.0,
                                    fit: BoxFit.scaleDown,
                                    child: Row(children: <Widget>[
                                      IconButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          splashColor: Colors.transparent,
                                          icon: Container(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                      color: Colors.black)),
                                              child: const Icon(
                                                  customIcon
                                                      .MyFlutterApp.curve_arrow,
                                                  color: Colors.black))),
                                      TextButton(
                                          style: ButtonStyle(
                                              elevation: MaterialStateProperty
                                                  .all<double?>(0.0),
                                              padding:
                                                  MaterialStateProperty.all<
                                                          EdgeInsetsGeometry?>(
                                                      const EdgeInsets.all(
                                                          0.0)),
                                              splashFactory:
                                                  NoSplash.splashFactory,
                                              enableFeedback: false),
                                          onPressed: _up,
                                          child: const MyTitle())
                                    ])))
                        ]))));
              }));
        });
  }
}
