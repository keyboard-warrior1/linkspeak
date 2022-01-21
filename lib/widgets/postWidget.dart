import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:measured_size/measured_size.dart';
import 'package:flip_card/flip_card.dart';
import '../models/screenArguments.dart';
import '../providers/topicScreenProvider.dart';
import '../providers/feedProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/otherProfileProvider.dart';
import '../providers/fullPostHelper.dart';
import '../screens/feedScreen.dart';
import '../screens/likedPostScreen.dart';
import '../screens/favoritePostsScreen.dart';
import '../screens/topicPostsScreen.dart';
import '../screens/postScreen.dart';
import '../routes.dart';
import 'descriptionPreview.dart';
import 'noMediaDescription.dart';
import 'postBaseline.dart';
import 'previewCarousel.dart';
import 'postWidgetButton.dart';
import 'postWidgetTitile.dart';
import 'postsTab.dart';
import 'sensitiveBanner.dart';
import 'postWidgetCarouselStamp.dart';
import 'postBackside.dart';
import '../my_flutter_app_icons.dart' as customIcons;

class PostWidget extends StatefulWidget {
  final bool isInFeed;
  final bool isInLike;
  final bool isInFav;
  final bool isInTab;
  final bool isInMyTab;
  final bool isInOtherTab;
  final bool isInTopics;
  final ScrollController? otherController;
  final ScrollController? topicScreenController;
  const PostWidget({
    required this.isInFeed,
    required this.isInLike,
    required this.isInFav,
    required this.isInTab,
    required this.isInMyTab,
    required this.isInOtherTab,
    required this.isInTopics,
    required this.otherController,
    required this.topicScreenController,
  });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with AutomaticKeepAliveClientMixin {
  double occupiedHeight = 0.0;
  double occupiedWidth = 0.0;
  late FlipCardController flipController;
  static const _carousel = const PostWidgetCarousel();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final void Function(BuildContext, String) feedsharePost =
      FeedScreen.sharePost;
  final void Function(BuildContext, String) tabSharePost = PostsTab.sharePost;
  final void Function(BuildContext, String) favSharePost =
      FavPostScreen.sharePost;
  final void Function(BuildContext, String) likedSharePost =
      LikedPostScreen.sharePost;
  final void Function(BuildContext, String) topicSharePost =
      TopicPostsScreen.sharePost;
  final dynamic showPreview = FeedScreen.showPreview;
  final likedScreenHandler = LikedPostScreen.showMyDialog;
  final favScreenHandler = FavPostScreen.showMyDialog;
  final topicScreenHandler = TopicPostsScreen.showMyDialog;
  void _goToPost(final BuildContext context, final ViewMode view,
      FullHelper instance, dynamic previewSetstate) {
    final PostScreenArguments args = PostScreenArguments(
        instance: instance,
        viewMode: view,
        previewSetstate: previewSetstate,
        isNotif: false,
        postID: '');

    Navigator.pushNamed(
      context,
      RouteGenerator.postScreen,
      arguments: args,
    );
  }

  ScrollController giveController(bool isInFeed, bool isInLike, bool isInFav,
      bool isInTab, bool isInTopic, bool isMyTab, bool isOtherTab) {
    if (isInFeed) {
      return FeedScreen.scrollController;
    }
    if (isInLike) {
      return LikedPostScreen.scrollController;
    }
    if (isInTab && isMyTab) {
      return PostsTab.scrollController;
    }
    if (isInTab && isOtherTab) {
      return widget.otherController!;
    }
    if (isInFav) {
      return FavPostScreen.scrollController;
    }
    if (isInTopic) {
      return widget.topicScreenController!;
    }
    return FeedScreen.scrollController;
  }

  void Function(BuildContext, String) giveShare(bool isInFeed, bool isInLike,
      bool isInFav, bool isInTab, bool isInTopic) {
    if (isInFeed) {
      return feedsharePost;
    }
    if (isInTab) {
      return tabSharePost;
    }
    if (isInLike) {
      return likedSharePost;
    }
    if (isInFav) {
      return favSharePost;
    }
    if (isInTopic) {
      return topicSharePost;
    }
    return feedsharePost;
  }

  void _goProfile(
    final BuildContext context,
    final String title,
  ) {
    final OtherProfileScreenArguments args =
        OtherProfileScreenArguments(otherProfileId: title);
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 150), () {
      Navigator.pushNamed(
        context,
        RouteGenerator.posterProfileScreen,
        arguments: args,
      );
    });
  }

  FullHelper giveInstance(
    BuildContext context,
    String postId,
    bool isInFeed,
    bool isInLike,
    bool isInFav,
    bool isInTab,
    bool myProfile,
    bool otherProfile,
    bool isInTopic,
  ) {
    if (isInFeed) {
      final currentFeedPosts =
          Provider.of<FeedProvider>(context, listen: false).posts;
      final currentFeedPost =
          currentFeedPosts.firstWhere((element) => element.postID == postId);
      final FullHelper feedinstance = currentFeedPost.instance;
      return feedinstance;
    }
    if (isInTopic) {
      final currentTopicPosts =
          Provider.of<TopicScreenProvider>(context, listen: false).posts;
      final currentTopicPost =
          currentTopicPosts.firstWhere((element) => element.postID == postId);
      final FullHelper topicInstance = currentTopicPost.instance;
      return topicInstance;
    }
    if (isInLike) {
      final likedPosts =
          Provider.of<MyProfile>(context, listen: false).getLikedPosts;
      final currentPost =
          likedPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInFav) {
      final favPosts =
          Provider.of<MyProfile>(context, listen: false).getFavPosts;
      final currentPost =
          favPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInTab && myProfile) {
      final myPosts = Provider.of<MyProfile>(context, listen: false).getPosts;
      final currentPost =
          myPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;

      return instance;
    }
    if (isInTab && otherProfile) {
      final otherPosts =
          Provider.of<OtherProfile>(context, listen: false).getPosts;
      final currentPost =
          otherPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    return FullHelper();
  }

  @override
  void initState() {
    super.initState();
    flipController = FlipCardController();
  }

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).primaryColor;
    Color _accentColor = Theme.of(context).accentColor;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final bool measuresGiven = helper.measuresGiven;
    final void Function() helperHide = helper.hidePost;
    final void Function() helperDelete = helper.deletePost;
    final void Function() helperUnhide = helper.unhidePost;
    final DateTime postedDate = helper.postedDate;
    final String postId = helper.postId;
    final String userImageUrl = helper.userImageUrl;
    final String bio = helper.bio;
    final int numOfLinks = helper.numOfLinks;
    final int numOfLinkedTos = helper.numOfLinkedTos;
    final String title = helper.title;
    final String description = helper.decription;
    final List<String> postTopics = helper.postTopics;
    final List<String> postImgUrls = helper.postImgUrls;
    final visibility = helper.visibility;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final bool _noDescription = description.isEmpty;
    final bool _withDescription = description.isNotEmpty;
    final bool _noMedia = postImgUrls.isEmpty;
    final bool _withMedia = postImgUrls.isNotEmpty;
    final bool sensitiveContent = helper.sensitiveContent;
    final bool _showPost = helper.showPost;
    final bool isMyPost = title == _myUsername;
    final List<String> _hiddenPosts =
        Provider.of<MyProfile>(context, listen: false).getHiddenPostIDs;
    final bool helperHidden =
        Provider.of<FullHelper>(context, listen: false).isHidden;
    final bool helperDeleted =
        Provider.of<FullHelper>(context, listen: false).isDeleted;
    final bool postHidden = _hiddenPosts.contains(postId);
    final _stamp = PostCarouselStamp(widget.isInOtherTab);

    if (widget.isInOtherTab) {
      _primaryColor =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    void previewSetStae() {
      setState(() {});
    }

    void _visitPost(ViewMode viewMode) {
      if (sensitiveContent && !_showPost && !isMyPost) {
      } else {
        _goToPost(
          context,
          viewMode,
          giveInstance(
              context,
              postId,
              widget.isInFeed,
              widget.isInLike,
              widget.isInFav,
              widget.isInTab,
              widget.isInMyTab,
              widget.isInOtherTab,
              widget.isInTopics),
          previewSetStae,
        );
      }
    }

    void likedHandler() {
      likedScreenHandler(
        context: context,
        userName: title,
        myUsername: _myUsername,
      );
    }

    void favHandler() {
      favScreenHandler(
          context: context, username: title, myUsername: _myUsername);
    }

    void topicHandler() {
      topicScreenHandler(
          context: context, username: title, myUsername: _myUsername);
    }

    void Function() giveHandler(
        bool isInLike, bool isInFav, bool isInTab, bool isInTopics) {
      if (isInLike) {
        return likedHandler;
      }
      if (isInFav) {
        return favHandler;
      }
      if (isInTab) {
        return () {};
      }
      if (isInTopics) {
        return topicHandler;
      }
      return () {};
    }

    void _visitProfile() {
      _goProfile(context, title);
    }

    void _preview() {
      showPreview(
        context,
        title,
        () => _visitProfile(),
        visibility,
        userImageUrl,
        bio,
        numOfLinks,
        numOfLinkedTos,
        false,
      );
    }

    final Widget _postBar = PostBar(
      postID: postId,
      shareView: false,
      shareButtonHandler: giveShare(widget.isInFeed, widget.isInLike,
          widget.isInFav, widget.isInTab, widget.isInTopics),
      isInFeed: true,
      upButtonHandler: () {},
      commentButtonHandler: () => _visitPost(ViewMode.comments),
      topicButtonHandler: () => _visitPost(ViewMode.topics),
      upView: false,
      commentView: false,
      topicsView: false,
      isInOtherProfile: widget.isInOtherTab,
    );
    final Widget _title = PostWidgetTitle(
      isInTopics: widget.isInTopics,
      isInFav: widget.isInFav,
      isInLikedPosts: widget.isInLike,
      isInTab: widget.isInTab,
      postId: postId,
      title: title,
      userImageUrl: userImageUrl,
      handler: giveHandler(
        widget.isInLike,
        widget.isInFav,
        widget.isInTab,
        widget.isInTopics,
      ),
      postTopics: postTopics,
      postMedia: postImgUrls,
      postDate: postedDate,
      preview: _preview,
      hidePost: helperHide,
      deletePost: helperDelete,
      unhidePost: helperUnhide,
      previewSetstate: previewSetStae,
    );
    super.build(context);
    return FlipCard(
      controller: flipController,
      direction: FlipDirection.VERTICAL,
      flipOnTouch: false,
      front: MeasuredSize(
        onChange: (size) {
          if (!measuresGiven) {
            occupiedHeight = size.height;
            occupiedWidth = size.width;
            Provider.of<FullHelper>(context, listen: false).giveMeasure();
            setState(() {});
          }
        },
        child: AnimatedContainer(
          key: UniqueKey(),
          height: postHidden || helperHidden || helperDeleted ? 0.0 : null,
          duration: kThemeAnimationDuration,
          width: postHidden ? double.infinity : 0.0,
          margin: EdgeInsets.symmetric(
            vertical:
                !postHidden || !helperHidden || !helperDeleted ? 1.0 : 0.0,
            horizontal:
                !postHidden || !helperHidden || !helperDeleted ? 7.0 : 0.0,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey.shade300)),
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all<double>(0.0),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(0.0),
              ),
              backgroundColor:
                  MaterialStateProperty.all<Color?>(Colors.transparent),
              foregroundColor:
                  MaterialStateProperty.all<Color?>(Colors.transparent),
              shadowColor: MaterialStateProperty.all<Color?>(Colors.black54),
              splashFactory: InkRipple.splashFactory,
            ),
            onPressed: () => _visitPost(ViewMode.post),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9.0),
              child: Card(
                borderOnForeground: false,
                margin: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _title,
                    const SizedBox(height: 3.0),
                    Stack(
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (_withDescription && _withMedia)
                              Flexible(
                                fit: FlexFit.loose,
                                child: DescriptionPreview(
                                  description,
                                  giveController(
                                      widget.isInFeed,
                                      widget.isInLike,
                                      widget.isInFav,
                                      widget.isInTab,
                                      widget.isInTopics,
                                      widget.isInMyTab,
                                      widget.isInOtherTab),
                                ),
                              ),
                            if (_withDescription && _noMedia)
                              Flexible(
                                fit: FlexFit.loose,
                                child: NoMediaPostDescriptionPreview(
                                  description,
                                  giveController(
                                      widget.isInFeed,
                                      widget.isInLike,
                                      widget.isInFav,
                                      widget.isInTab,
                                      widget.isInTopics,
                                      widget.isInMyTab,
                                      widget.isInOtherTab),
                                ),
                              ),
                            if (_withDescription && _noMedia)
                              PostWidgetButton(flipController.toggleCard,
                                  widget.isInOtherTab),
                            if (_withDescription && _withMedia)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: _deviceHeight * 0.50,
                                  maxHeight: _deviceHeight * 0.50,
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    _carousel,
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: _stamp,
                                    ),
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
                                            color:
                                                _primaryColor.withOpacity(0.5),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft:
                                                  const Radius.circular(15.0),
                                            ),
                                          ),
                                          child: Icon(
                                            customIcons.MyFlutterApp.brochure,
                                            color: _accentColor,
                                            size: 35.0,
                                          ),
                                        ),
                                      ),
                                    Align(
                                        alignment: Alignment.bottomCenter,
                                        child: PostWidgetButton(
                                            flipController.toggleCard,
                                            widget.isInOtherTab)),
                                  ],
                                ),
                              ),
                            if (_noDescription && _withMedia)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: _deviceHeight * 0.52,
                                  maxHeight: _deviceHeight * 0.52,
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    _carousel,
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: _stamp,
                                    ),
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
                                            color:
                                                _primaryColor.withOpacity(0.5),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15.0),
                                            ),
                                          ),
                                          child: Icon(
                                            customIcons.MyFlutterApp.brochure,
                                            color: _accentColor,
                                            size: 35.0,
                                          ),
                                        ),
                                      ),
                                    Align(
                                        alignment: Alignment.bottomCenter,
                                        child: PostWidgetButton(
                                            flipController.toggleCard,
                                            widget.isInOtherTab)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SensitiveBanner(previewSetStae),
                      ],
                    ),
                    _postBar,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      back: PostBackSide(
        toggleCard: flipController.toggleCard,
        givenHeight: occupiedHeight,
        givenWidth: occupiedWidth,
        controller: giveController(
            widget.isInFeed,
            widget.isInLike,
            widget.isInFav,
            widget.isInTab,
            widget.isInTopics,
            widget.isInMyTab,
            widget.isInOtherTab),
        isInOtherProfile: widget.isInOtherTab,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
