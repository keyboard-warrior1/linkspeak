import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/boardPostItem.dart';
import '../../models/post.dart';
import '../../models/posterProfile.dart';
import '../../models/profile.dart';
import '../../models/screenArguments.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/themeModel.dart';
import '../../routes.dart';
import '../../screens/postScreen.dart';
import 'miniCarousel.dart';
import 'miniDescription.dart';
import 'miniLockedPost.dart';
import 'miniTitle.dart';

class MiniPost extends StatefulWidget {
  final String postID;
  final Widget dateWidget;
  final bool isMySide;
  const MiniPost(
      {required this.postID, required this.dateWidget, required this.isMySide});

  @override
  _MiniPostState createState() => _MiniPostState();
}

class _MiniPostState extends State<MiniPost> {
  final firestore = FirebaseFirestore.instance;
  bool _showPost = false;
  bool exists = true;
  bool isBanned = false;
  bool imBlocked = false;
  bool imLinkedToThem = false;
  bool isBoard = false;
  bool isBranch = false;
  Post? _post;
  FullHelper? _instance;
  late Future<void> _getPost;
  Widget buildNonLegacyPost(bool _isBoard, dynamic handler) {
    final lang = General.language(context);
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Icon(_isBoard ? Icons.rectangle_outlined : Icons.article_outlined,
              color: Colors.grey, size: 55.0),
          const SizedBox(height: 5.0),
          Center(
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                      _isBoard ? lang.widgets_chat7 : lang.widgets_chat8,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 15.0)))),
          const Spacer(),
          const Divider(color: Colors.grey, indent: 0.0, endIndent: 0.0),
          TextButton(
              child: Text(_isBoard ? lang.widgets_chat9 : lang.widgets_chat10,
                  style: TextStyle(fontSize: 20.0)),
              onPressed: () => handler())
        ]);
  }

  Future<void> getPost(String myUsername) async {
    final post = await firestore.collection('Posts').doc(widget.postID).get();
    if (post.exists) {
      final usersCollection = firestore.collection('Users');
      final myUser = usersCollection.doc(myUsername);
      final myLiked = myUser.collection('LikedPosts');
      final myFavs = myUser.collection('FavPosts');
      final getLiked = await myLiked.doc(widget.postID).get();
      final bool isLiked = getLiked.exists;
      final getFav = await myFavs.doc(widget.postID).get();
      final bool isFav = getFav.exists;
      PostType theType = PostType.legacy;
      List<BoardPostItem> paramBoardPostItems = [];
      Color paramBoardPostBackground = Colors.blue;
      Color paramBoardPostGradient = Colors.yellow;
      dynamic getter(String field) => post.get(field);
      dynamic location = '';
      String locationName = '';
      bool commentsDisabled = false;
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
      imLinkedToThem = userLinks.exists;
      imBlocked = userBlocks.exists;
      final posterUser = await usersCollection.doc(poster).get();
      final posterStatus = posterUser.get('Status');
      if (posterStatus == 'Banned') {
        isBanned = true;
      } else {
        isBanned = false;
      }
      if (theType == PostType.board) {
        isBoard = true;
      } else if (theType == PostType.branch) {
        isBranch = true;
      } else {}
      final posterVisibility = posterUser.get('Visibility');
      final TheVisibility vis = General.convertProfileVis(posterVisibility);
      _instance = FullHelper();
      final key = UniqueKey();
      final PosterProfile _posterProfile =
          PosterProfile(getUsername: poster, getVisibility: vis);
      _post = Post(
          key: key,
          instance: _instance!,
          poster: _posterProfile,
          description: description,
          numOfLikes: numOfLikes,
          numOfComments: numOfComments,
          numOfTopics: numOfTopics,
          sensitiveContent: sensitiveContent,
          commentsDisabled: commentsDisabled,
          postID: widget.postID,
          postedDate: serverpostedDate,
          topics: postTopics,
          imgUrls: imgUrls,
          location: location,
          locationName: locationName,
          clubName: '',
          isClubPost: false,
          isLiked: isLiked,
          isFav: isFav,
          isHidden: false,
          isMod: false,
          postType: theType,
          items: paramBoardPostItems,
          backgroundColor: paramBoardPostBackground,
          gradientColor: paramBoardPostGradient);
      _post!.setter();
    } else {
      exists = false;
    }
    if (mounted) setState(() {});
  }

  void showPost() {
    setState(() {
      _showPost = true;
    });
  }

  Widget giveLockedPost(IconData icon, String message) =>
      MiniLockedPost(icon: icon, message: message);
  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getPost = getPost(myUsername);
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceWidth = General.widthQuery(context);
    final double _deviceHeight = _sizeQuery.height;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final bool imManagement = myUsername.startsWith('Linkspeak');
    final _selectedCensorMode = Provider.of<ThemeModel>(context).censorMode;
    void _goToPost(final ViewMode view, FullHelper instance) {
      final PostScreenArguments args = PostScreenArguments(
          instance: instance,
          viewMode: view,
          previewSetstate: () {},
          isNotif: false,
          postID: '',
          clubName: '',
          section: Section.multiple,
          singleCommentID: '');
      Navigator.pushNamed(context, RouteGenerator.postScreen, arguments: args);
    }

    final it = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            widget.isMySide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: _deviceWidth * 0.80,
              maxWidth: _deviceWidth * 0.80,
              minHeight: _deviceHeight * 0.10,
              maxHeight: _deviceHeight * 0.45,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.50),
                child: Container(
                  color: Colors.white,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: _deviceWidth * 0.80,
                      maxWidth: _deviceWidth * 0.80,
                      minHeight: _deviceHeight * 0.10,
                      maxHeight: _deviceHeight * 0.45,
                    ),
                    child: FutureBuilder(
                      future: _getPost,
                      builder: (ctx, snapshot) {
                        if (snapshot.hasError) {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _getPost = getPost(myUsername);
                                  });
                                },
                                icon: const Icon(Icons.refresh,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                lang.clubs_members2,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                ),
                              )
                            ],
                          );
                        }
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            _instance == null) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [],
                            ),
                          );
                        }
                        return Builder(
                          builder: (context) {
                            return ChangeNotifierProvider.value(
                              value: _instance,
                              child: Builder(
                                builder: (context) {
                                  final helper = Provider.of<FullHelper>(
                                      context,
                                      listen: false);
                                  final String username = helper.posterId;
                                  final String postDescription =
                                      helper.decription;
                                  final List<String> postImgUrls =
                                      helper.postImgUrls;
                                  final bool containsSensitive =
                                      helper.sensitiveContent;
                                  final bool isPrivate = helper.visibility ==
                                      TheVisibility.private;
                                  final bool postedByMe =
                                      username == myUsername;
                                  return (((isPrivate &&
                                                  !imLinkedToThem &&
                                                  !postedByMe) ||
                                              imBlocked) &&
                                          !imManagement)
                                      ? giveLockedPost(
                                          Icons.lock, lang.widgets_chat20)
                                      : isBanned && !imManagement
                                          ? giveLockedPost(Icons.person_off,
                                              lang.widgets_chat21)
                                          : (!exists)
                                              ? giveLockedPost(
                                                  Icons.remove_circle_outline,
                                                  lang.widgets_chat22)
                                              : (containsSensitive &&
                                                      !_showPost &&
                                                      !postedByMe &&
                                                      _selectedCensorMode)
                                                  ? Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        const Spacer(),
                                                        const Icon(
                                                          Icons.warning,
                                                          color: Colors.grey,
                                                          size: 55.0,
                                                        ),
                                                        const SizedBox(
                                                            height: 5.0),
                                                        Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            child: Text(
                                                              lang.widgets_chat18,
                                                              style:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 15.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        const Divider(
                                                          color: Colors.grey,
                                                          indent: 0.0,
                                                          endIndent: 0.0,
                                                        ),
                                                        TextButton(
                                                          child: Text(
                                                            lang.widgets_chat23,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 20.0,
                                                            ),
                                                          ),
                                                          onPressed: showPost,
                                                        )
                                                      ],
                                                    )
                                                  : isBoard
                                                      ? buildNonLegacyPost(
                                                          true,
                                                          () => _goToPost(
                                                              ViewMode.post,
                                                              _instance!))
                                                      : isBranch
                                                          ? buildNonLegacyPost(
                                                              false,
                                                              () => _goToPost(
                                                                  ViewMode.post,
                                                                  _instance!))
                                                          : GestureDetector(
                                                              onTap: () =>
                                                                  _goToPost(
                                                                      ViewMode
                                                                          .post,
                                                                      _instance!),
                                                              child: Stack(
                                                                children: <
                                                                    Widget>[
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        const MiniTitle(),
                                                                        if (postDescription
                                                                            .isNotEmpty)
                                                                          const MiniDescriptionPreview(),
                                                                        if (postImgUrls
                                                                            .isNotEmpty)
                                                                          Expanded(
                                                                            child:
                                                                                Stack(
                                                                              children: <Widget>[
                                                                                const MiniCarousel(),
                                                                                if (postImgUrls.length > 1)
                                                                                  Align(
                                                                                    alignment: Alignment.topRight,
                                                                                    child: Container(
                                                                                      padding: const EdgeInsets.only(
                                                                                        top: 4.0,
                                                                                        left: 8.0,
                                                                                        right: 4.0,
                                                                                        bottom: 6.0,
                                                                                      ),
                                                                                      decoration: BoxDecoration(
                                                                                        color: _primaryColor.withOpacity(0.5),
                                                                                        borderRadius: BorderRadius.only(
                                                                                          bottomLeft: const Radius.circular(15.0),
                                                                                        ),
                                                                                      ),
                                                                                      child: Icon(
                                                                                        // customIcons.MyFlutterApp.brochure,
                                                                                        Icons.view_carousel_rounded,
                                                                                        color: _accentColor,
                                                                                        size: 35.0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    child:
                                                                        Container(
                                                                      margin: const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              8.0),
                                                                      decoration: BoxDecoration(
                                                                          color: (postImgUrls.isEmpty)
                                                                              ? _primaryColor
                                                                              : _primaryColor.withOpacity(
                                                                                  0.65),
                                                                          shape: BoxShape
                                                                              .circle,
                                                                          border: (postImgUrls.isEmpty)
                                                                              ? null
                                                                              : Border.all(color: _accentColor)),
                                                                      child:
                                                                          IconButton(
                                                                        onPressed: () => _goToPost(
                                                                            ViewMode.post,
                                                                            _instance!),
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .keyboard_arrow_right,
                                                                          color: (postImgUrls.isEmpty)
                                                                              ? Colors.white
                                                                              : _accentColor,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          widget.dateWidget,
        ],
      ),
    );
    return it;
  }
}
