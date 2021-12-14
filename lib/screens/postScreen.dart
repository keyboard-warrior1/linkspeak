import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../my_flutter_app_icons.dart' as customIcon;
import '../models/screenArguments.dart';
import '../models/profile.dart';
import '../models/post.dart';
import '../models/posterProfile.dart';
import '../providers/myProfileProvider.dart';
import '../providers/fullPostHelper.dart';
import '../widgets/adaptiveText.dart';
import '../widgets/title.dart';
import '../widgets/fullPost.dart';
import '../widgets/myFab.dart';
import '../widgets/topicsView..dart';
import '../widgets/commentsView.dart';
import '../widgets/shareView.dart';
import '../widgets/likesView.dart';

enum ViewMode { post, comments, topics, likes, share }

// ignore: must_be_immutable
class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
  late dynamic viewMode;
  final dynamic instance;
  final dynamic previewSetstate;
  final dynamic isNotif;
  final dynamic postID;

  PostScreen({
    required this.viewMode,
    required this.instance,
    required this.previewSetstate,
    required this.isNotif,
    required this.postID,
  });
}

class _PostScreenState extends State<PostScreen> {
  late final ScrollController scrollController;
  late bool hasScrolled;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> getPost;
  late Post? notifPost;
  Future<void> _getPost() async {
    TheVisibility generateVis(String vis) {
      if (vis == 'Public') {
        return TheVisibility.public;
      } else if (vis == 'Private') {
        return TheVisibility.private;
      }
      return TheVisibility.private;
    }

    final post = await firestore.collection('Posts').doc(widget.postID).get();
    final usersCollection = firestore.collection('Users');
    if (post.exists) {
      dynamic getter(String field) => post.get(field);
      final postID = post.id;
      final String poster = getter('poster');
      final posterUser = await usersCollection.doc(poster).get();
      final posterVisibility = posterUser.get('Visibility');
      final TheVisibility vis = generateVis(posterVisibility);
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
      );
      _post.setter();
      notifPost = _post;
    }
  }

  final void Function(
    BuildContext,
    String,
  ) _handler = (
    BuildContext context,
    String posterID,
  ) {
    final OtherProfileScreenArguments args = OtherProfileScreenArguments(
      otherProfileId: posterID,
    );
    Navigator.pushNamed(
      context,
      RouteGenerator.posterProfileScreen,
      arguments: args,
    );
  };

  Widget display(BuildContext context, ViewMode viewMode, double deviceHeight) {
    void _showDialog(
        dynamic handler, String myUsername, String posterUsername) {
      if (myUsername == posterUsername) {
      } else {
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
                        style:
                            ButtonStyle(splashFactory: NoSplash.splashFactory),
                        onPressed: handler,
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

    final FullHelper helper = Provider.of<FullHelper>(context);
    final String postId = helper.postId;
    final String title = helper.title;
    final int numOfTopics = helper.numOfTopics;
    final String _myUsername = context.read<MyProfile>().getUsername;
    final int numOfLikes = Provider.of<FullHelper>(context).getNumOfLikes;
    final int numOfComments = Provider.of<FullHelper>(context).getNumOfComments;

    const ViewMode _post = ViewMode.post;
    const ViewMode _ups = ViewMode.likes;
    const ViewMode _comments = ViewMode.comments;
    const ViewMode _topics = ViewMode.topics;
    const ViewMode _share = ViewMode.share;
    final bool _upsView = viewMode == ViewMode.likes;
    final bool _commentsView = viewMode == ViewMode.comments;
    final bool _topicsView = viewMode == ViewMode.topics;
    final bool _shareView = viewMode == ViewMode.share;
    void _upButtonHandler(dynamic likeIt) {
      setState(() {
        if (_commentsView || _topicsView || _shareView) {
          widget.viewMode = _ups;
        } else if (_upsView) {
          widget.viewMode = _post;
        } else {
          likeIt();
        }
      });
    }

    void _commentButtonHandler() {
      setState(() {
        if (_commentsView) {
          widget.viewMode = _post;
        } else {
          widget.viewMode = _comments;
        }
      });
    }

    void _topicButtonHandler() {
      setState(() {
        if (_topicsView) {
          widget.viewMode = _post;
        } else {
          widget.viewMode = _topics;
        }
      });
    }

    void _shareButtonHandler() {
      setState(() {
        if (_shareView) {
          widget.viewMode = _post;
        } else {
          widget.viewMode = _share;
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
              numOfComments, scrollController, postId, _handler);
        case ViewMode.topics:
          return TopicsView(numOfTopics: numOfTopics, postID: postId);
        case ViewMode.share:
          return const ShareView();
      }
      return null;
    }

    switch (viewMode) {
      case ViewMode.post:
        final Widget _fullpost = FullPost(
          scrollController: scrollController,
          display: null,
          upView: _upsView,
          commentsView: _commentsView,
          topicsView: _topicsView,
          shareView: _shareView,
          handler: () => _showDialog(
            (title == context.read<MyProfile>().getUsername)
                ? () =>
                    Navigator.pushNamed(context, RouteGenerator.myProfileScreen)
                : () => _handler(context, title),
            _myUsername,
            title,
          ),
          upButtonHandler: _upButtonHandler,
          upvote: () {},
          commentButtonHandler: _commentButtonHandler,
          topicButtonHandler: _topicButtonHandler,
          shareButtonHandler: _shareButtonHandler,
          previewSetstate: widget.previewSetstate,
        );
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
          handler: () => _showDialog(
            (title == context.read<MyProfile>().getUsername)
                ? () =>
                    Navigator.pushNamed(context, RouteGenerator.myProfileScreen)
                : () => _handler(context, title),
            _myUsername,
            title,
          ),
          upButtonHandler: _upButtonHandler,
          upvote: () {},
          commentButtonHandler: _commentButtonHandler,
          topicButtonHandler: _topicButtonHandler,
          shareButtonHandler: _shareButtonHandler,
          previewSetstate: widget.previewSetstate,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    getPost = _getPost();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
        future: (widget.isNotif) ? getPost : null,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              splashColor: Colors.transparent,
                              icon: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                ),
                                child: const Icon(
                                  customIcon.MyFlutterApp.curve_arrow,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                elevation:
                                    MaterialStateProperty.all<double?>(0.0),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry?>(
                                  const EdgeInsets.all(0.0),
                                ),
                                splashFactory: NoSplash.splashFactory,
                                enableFeedback: false,
                              ),
                              onPressed: () {},
                              child: const MyTitle(),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const CircularProgressIndicator(),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            Scaffold(
              body: SafeArea(
                child: SizedBox(
                  height: _deviceHeight,
                  width: _deviceWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      OptimisedText(
                        minWidth: _deviceWidth * 0.5,
                        maxWidth: _deviceWidth * 0.65,
                        minHeight: 50.0,
                        maxHeight: 50.0,
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              splashColor: Colors.transparent,
                              icon: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                ),
                                child: const Icon(
                                  customIcon.MyFlutterApp.curve_arrow,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                elevation:
                                    MaterialStateProperty.all<double?>(0.0),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry?>(
                                  const EdgeInsets.all(0.0),
                                ),
                                splashFactory: NoSplash.splashFactory,
                                enableFeedback: false,
                              ),
                              onPressed: () {},
                              child: const MyTitle(),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text('An unknown error has occured'),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          }
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ChangeNotifierProvider<FullHelper>.value(
              value: (widget.isNotif) ? notifPost!.instance : widget.instance,
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: (widget.viewMode != ViewMode.post)
                        ? MyFab(scrollController)
                        : null,
                    extendBody: true,
                    extendBodyBehindAppBar: true,
                    appBar: null,
                    body: SafeArea(
                      child: Stack(
                        children: <Widget>[
                          display(
                            context,
                            widget.viewMode!,
                            _deviceHeight,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: OptimisedText(
                              minWidth: _deviceWidth * 0.5,
                              maxWidth: _deviceWidth * 0.65,
                              minHeight: 50.0,
                              maxHeight: 50.0,
                              fit: BoxFit.scaleDown,
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    splashColor: Colors.transparent,
                                    icon: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: const Icon(
                                        customIcon.MyFlutterApp.curve_arrow,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      elevation:
                                          MaterialStateProperty.all<double?>(
                                              0.0),
                                      padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry?>(
                                        const EdgeInsets.all(0.0),
                                      ),
                                      splashFactory: NoSplash.splashFactory,
                                      enableFeedback: false,
                                    ),
                                    onPressed: _up,
                                    child: const MyTitle(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
