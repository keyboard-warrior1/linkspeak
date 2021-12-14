import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../models/post.dart';
import '../models/profile.dart';
import '../models/posterProfile.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/fullPostHelper.dart';
import '../screens/postScreen.dart';
import 'miniTitle.dart';
import 'miniDescription.dart';
import 'miniCarousel.dart';
import 'miniLockedPost.dart';

class MiniPost extends StatefulWidget {
  final String postID;
  const MiniPost({required this.postID});

  @override
  _MiniPostState createState() => _MiniPostState();
}

class _MiniPostState extends State<MiniPost> {
  final firestore = FirebaseFirestore.instance;
  bool _showPost = false;
  late final bool imLinkedToThem;
  late final Post _post;
  late final FullHelper _instance;
  late Future<void> _getPost;
  TheVisibility generateVis(String vis) {
    if (vis == 'Public') {
      return TheVisibility.public;
    } else if (vis == 'Private') {
      return TheVisibility.private;
    }
    return TheVisibility.private;
  }

  Future<void> getPost(String myUsername) async {
    final post = await firestore.collection('Posts').doc(widget.postID).get();
    final usersCollection = firestore.collection('Users');
    dynamic getter(String field) => post.get(field);
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
    imLinkedToThem = userLinks.exists;
    final posterUser = await usersCollection.doc(poster).get();
    final posterImg = posterUser.get('Avatar');
    final posterBio = posterUser.get('Bio');
    final posterNumOfLinks = posterUser.get('numOfLinks');
    final posterNumOfLinked = posterUser.get('numOfLinked');
    final posterVisibility = posterUser.get('Visibility');
    final TheVisibility vis = generateVis(posterVisibility);
    _instance = FullHelper();
    final key = UniqueKey();
    final PosterProfile _posterProfile = PosterProfile(
        getUsername: poster,
        getProfileImage: posterImg,
        getBio: posterBio,
        getNumberOflinks: posterNumOfLinks,
        getNumberOfLinkedTos: posterNumOfLinked,
        getVisibility: vis);
    _post = Post(
      key: key,
      instance: _instance,
      poster: _posterProfile,
      description: description,
      numOfLikes: numOfLikes,
      numOfComments: numOfComments,
      numOfTopics: numOfTopics,
      sensitiveContent: sensitiveContent,
      postID: widget.postID,
      postedDate: serverpostedDate,
      topics: postTopics,
      imgUrls: imgUrls,
    );
    _post.setter();
  }

  void showPost() {
    setState(() {
      _showPost = true;
    });
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getPost = getPost(myUsername);
  }

  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceWidth = _sizeQuery.width;
    final double _deviceHeight = _sizeQuery.height;
    final Color _accentColor = Theme.of(context).accentColor;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    void _goToPost(final ViewMode view, FullHelper instance) {
      final PostScreenArguments args = PostScreenArguments(
        instance: instance,
        viewMode: view,
        previewSetstate: () {},
        isNotif: false,
        postID: '',
      );
      Navigator.pushNamed(
        context,
        RouteGenerator.postScreen,
        arguments: args,
      );
    }

    final it = Container(
      // key: UniqueKey(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: _deviceWidth * 0.35,
          maxWidth: _deviceWidth * 0.80,
          minHeight: _deviceHeight * 0.10,
          maxHeight: _deviceHeight * 0.45,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              color: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: _deviceWidth * 0.35,
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
                            icon:
                                const Icon(Icons.refresh, color: Colors.black),
                          ),
                          const SizedBox(height: 5.0),
                          const Text(
                            'An error has occured',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                          )
                        ],
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [const CircularProgressIndicator()],
                      );
                    }
                    return Builder(
                      builder: (context) {
                        return ChangeNotifierProvider.value(
                          value: _instance,
                          child: Builder(
                            builder: (context) {
                              final helper = Provider.of<FullHelper>(context,
                                  listen: false);
                              final String username = helper.posterId;
                              final String postDescription = helper.decription;
                              final List<String> postImgUrls =
                                  helper.postImgUrls;
                              final bool containsSensitive =
                                  helper.sensitiveContent;
                              final bool isPrivate =
                                  helper.visibility == TheVisibility.private;
                              final bool postedByMe = username == myUsername;
                              return (isPrivate &&
                                      !imLinkedToThem &&
                                      !postedByMe)
                                  ? const MiniLockedPost()
                                  : (containsSensitive &&
                                          !_showPost &&
                                          !postedByMe)
                                      ? Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            const Spacer(),
                                            const Icon(
                                              Icons.warning,
                                              color: Colors.grey,
                                              size: 55.0,
                                            ),
                                            const SizedBox(height: 5.0),
                                            const Center(
                                              child: const Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: const Text(
                                                  'This post may contain sensitive or distressing content',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
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
                                              child: const Text(
                                                'View post',
                                                style: TextStyle(
                                                  fontSize: 25.0,
                                                ),
                                              ),
                                              onPressed: showPost,
                                            )
                                          ],
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            Positioned.fill(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const MiniTitle(),
                                                  if (postDescription
                                                      .isNotEmpty)
                                                    const MiniDescriptionPreview(),
                                                  if (postImgUrls.isNotEmpty)
                                                    Expanded(
                                                      child: Stack(
                                                        children: <Widget>[
                                                          const MiniCarousel(),
                                                          if (postImgUrls
                                                                  .length >
                                                              1)
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 4.0,
                                                                  left: 8.0,
                                                                  right: 4.0,
                                                                  bottom: 6.0,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .lightBlueAccent
                                                                      .shade400
                                                                      .withOpacity(
                                                                          0.5),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    bottomLeft:
                                                                        const Radius.circular(
                                                                            15.0),
                                                                  ),
                                                                ),
                                                                child: Icon(
                                                                  customIcons
                                                                      .MyFlutterApp
                                                                      .brochure,
                                                                  color:
                                                                      _accentColor,
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
                                              alignment: Alignment.bottomCenter,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: (postImgUrls
                                                            .isNotEmpty)
                                                        ? Colors.lightBlueAccent
                                                            .shade400
                                                            .withOpacity(0.5)
                                                        : Colors
                                                            .lightBlueAccent,
                                                    border: Border.all(
                                                      color: (postImgUrls
                                                              .isNotEmpty)
                                                          ? _accentColor
                                                          : Colors.transparent,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: IconButton(
                                                    splashColor:
                                                        Colors.lightBlue,
                                                    splashRadius: 50.0,
                                                    onPressed: () => _goToPost(
                                                        ViewMode.post,
                                                        _instance),
                                                    icon: Icon(
                                                      Icons
                                                          .keyboard_arrow_right_outlined,
                                                      color: (postImgUrls
                                                              .isNotEmpty)
                                                          ? _accentColor
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
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
    );
    return it;
  }
}
