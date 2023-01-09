import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/boardPostItem.dart';
import '../../models/comment.dart';
import '../../models/profile.dart';
import '../../models/screenArguments.dart';
import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/adminPostsProvider.dart';
import '../../providers/clubProvider.dart';
import '../../providers/clubTabProvider.dart';
import '../../providers/feedProvider.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../../providers/placesScreenProvider.dart';
import '../../providers/themeModel.dart';
import '../../providers/topicScreenProvider.dart';
import '../../routes.dart';
import '../../screens/postScreen.dart';
import '../common/chatProfileImage.dart';
import '../common/noglow.dart';
import '../misc/videoPlayer.dart';
import '../share/shareWidget.dart';
import 'boardPostWidget.dart';
import 'boardSections.dart';

class BranchPostWidget extends StatefulWidget {
  final bool inPreview;
  final bool isInFeed;
  final bool isInClubFeed;
  final bool isInLike;
  final bool isInFav;
  final bool isInTab;
  final bool isInMyTab;
  final bool isInOtherTab;
  final bool isInPeopleTopics;
  final bool isInClubTopics;
  final bool isInClubPosts;
  final bool isInFavClubs;
  final bool isInLikedClubs;
  final bool isInPeoplePlaces;
  final bool isInClubPlaces;
  final bool isInPeopleAdmin;
  final bool isInClubAdmin;
  final FullHelper? instance;
  const BranchPostWidget(
      {required this.inPreview,
      required this.isInFeed,
      required this.isInClubFeed,
      required this.isInLike,
      required this.isInFav,
      required this.isInTab,
      required this.isInMyTab,
      required this.isInOtherTab,
      required this.isInPeopleTopics,
      required this.isInClubTopics,
      required this.isInClubPosts,
      required this.isInFavClubs,
      required this.isInLikedClubs,
      required this.isInPeoplePlaces,
      required this.isInClubPlaces,
      required this.isInPeopleAdmin,
      required this.isInClubAdmin,
      required this.instance});

  @override
  State<BranchPostWidget> createState() => _BranchPostWidgetState();
}

class _BranchPostWidgetState extends State<BranchPostWidget> {
  List<String> mediaList = [];
  final ScrollController _controllre = ScrollController();
  final FirebaseStorage storage = FirebaseStorage.instance;
  Widget giveStacked(String text, bool isSub, String _stamp) =>
      Text(!isSub ? text : text + ' ' + _stamp,
          softWrap: isSub,
          style: TextStyle(
              fontSize: isSub
                  ? widget.inPreview
                      ? 15.0
                      : 16.0
                  : 16.0,
              fontWeight: FontWeight.normal,
              color: Colors.black));
  Widget buildTextField(String description) {
    String shownDescription = description;
    if (widget.inPreview && description.length > 200)
      shownDescription = '${description.substring(0, 200)}..';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: 10,
              maxHeight: widget.inPreview ? 400 : 2000,
              minWidth: 10,
              maxWidth: widget.inPreview ? 400 : General.widthQuery(context)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(shownDescription,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 17))),
              ])),
    );
  }

  Widget buildMediaItem(String url, int mediaIndex, double deviceHeight,
      bool hasNSFW, dynamic handler) {
    final reference = storage.refFromURL(url);
    final fullPath = reference.fullPath;
    final type = lookupMimeType(fullPath);
    final bool isImage = type!.startsWith('image');
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              height: widget.inPreview ? 400 : deviceHeight * 0.60,
              width: widget.inPreview
                  ? General.widthQuery(context) * 0.95
                  : General.widthQuery(context),
              margin: const EdgeInsets.only(bottom: 15),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                      color: Colors.transparent,
                      child: isImage
                          ? GestureDetector(
                              onTap: () {
                                if (!widget.inPreview) {
                                  final MediaScreenArgs args = MediaScreenArgs(
                                      mediaUrls: mediaList,
                                      currentIndex: mediaIndex,
                                      isInComment: false);
                                  Navigator.pushNamed(
                                      context, RouteGenerator.mediaScreen,
                                      arguments: args);
                                } else {
                                  handler();
                                }
                              },
                              child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: ExtendedImage.network(url,
                                      fit: BoxFit.contain,
                                      cache: true,
                                      printError: false,
                                      enableLoadState: false,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(8))))
                          : Center(
                              child: Container(
                                  color: Colors.black,
                                  child: MyVideoPlayer(
                                      url,
                                      true,
                                      hasNSFW,
                                      widget.inPreview
                                          ? null
                                          : Align(
                                              alignment: Alignment.bottomRight,
                                              child: IconButton(
                                                  icon: const Icon(
                                                      Icons.fullscreen,
                                                      color: Colors.white,
                                                      size: 30),
                                                  onPressed: () {
                                                    if (!widget.inPreview) {
                                                      final MediaScreenArgs
                                                          args =
                                                          MediaScreenArgs(
                                                              mediaUrls:
                                                                  mediaList,
                                                              currentIndex:
                                                                  mediaIndex,
                                                              isInComment:
                                                                  false);
                                                      Navigator.pushNamed(
                                                          context,
                                                          RouteGenerator
                                                              .mediaScreen,
                                                          arguments: args);
                                                    }
                                                  })))))))),
        ]);
  }

  void visitProfile(String myUsername, String username) {
    if (username != myUsername) {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: username);
      Navigator.pushNamed(context, RouteGenerator.posterProfileScreen,
          arguments: args);
    } else {
      Navigator.pushNamed(context, RouteGenerator.myProfileScreen);
    }
  }

  void visitClub(String clubName) {
    final ClubScreenArgs args = ClubScreenArgs(clubName);
    Navigator.pushNamed(context, RouteGenerator.clubScreen, arguments: args);
  }

  @override
  void initState() {
    super.initState();
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final List<BoardPostItem> items = helper.boardPostItems;
    for (var element in items)
      if (!element.isText) mediaList.add(element.mediaURL);
  }

  FullHelper? giveInstance(
      BuildContext context,
      String postId,
      bool isInFeed,
      bool isInLike,
      bool isInFav,
      bool isInTab,
      bool myProfile,
      bool otherProfile,
      bool isInClubTopics,
      bool isInPeopleTopics,
      bool isInClubPosts,
      bool isInLikedClubs,
      bool isInFavClubs,
      bool isInClubFeed,
      bool isInClubPlaces,
      bool isInPeoplePlaces,
      bool isInPeopleAdmin,
      bool isInClubAdmin) {
    if (isInFeed && !isInClubFeed) {
      final currentFeedPosts =
          Provider.of<FeedProvider>(context, listen: false).posts;
      final currentFeedPost =
          currentFeedPosts.firstWhere((element) => element.postID == postId);
      final FullHelper feedinstance = currentFeedPost.instance;
      return feedinstance;
    }
    if (isInClubFeed) {
      final currentClubFeedPosts =
          Provider.of<ClubTabProvider>(context, listen: false).posts;
      final currentClubFeedPost = currentClubFeedPosts
          .firstWhere((element) => element.postID == postId);
      final FullHelper clubfeedinstance = currentClubFeedPost.instance;
      return clubfeedinstance;
    }
    if (isInPeopleTopics) {
      final currentTopicPosts =
          Provider.of<TopicScreenProvider>(context, listen: false).posts;
      final currentTopicPost =
          currentTopicPosts.firstWhere((element) => element.postID == postId);
      final FullHelper topicInstance = currentTopicPost.instance;
      return topicInstance;
    }
    if (isInClubTopics) {
      final currentTopicPosts =
          Provider.of<TopicScreenProvider>(context, listen: false).clubPosts;
      final currentTopicPost =
          currentTopicPosts.firstWhere((element) => element.postID == postId);
      final FullHelper topicInstance = currentTopicPost.instance;
      return topicInstance;
    }
    if (isInPeoplePlaces) {
      final currentPlacePosts =
          Provider.of<PlacesScreenProvider>(context, listen: false).posts;
      final currentPlacePost =
          currentPlacePosts.firstWhere((element) => element.postID == postId);
      final FullHelper placeInstance = currentPlacePost.instance;
      return placeInstance;
    }
    if (isInClubPlaces) {
      final currentPlacePosts =
          Provider.of<PlacesScreenProvider>(context, listen: false).clubPosts;
      final currentPlacePost =
          currentPlacePosts.firstWhere((element) => element.postID == postId);
      final FullHelper placeInstance = currentPlacePost.instance;
      return placeInstance;
    }
    if (isInLike && !isInLikedClubs) {
      final likedPosts =
          Provider.of<MyProfile>(context, listen: false).getLikedPosts;
      final currentPost =
          likedPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInFav && !isInFavClubs) {
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
    if (isInClubPosts) {
      final clubPosts = Provider.of<ClubProvider>(context, listen: false).posts;
      final currentPosts =
          clubPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPosts.instance;
      return instance;
    }
    if (isInFavClubs && isInFav) {
      final favClubPosts =
          Provider.of<MyProfile>(context, listen: false).getFavClubPosts;
      final currentPost =
          favClubPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInLikedClubs && isInLike) {
      final likedClubPosts =
          Provider.of<MyProfile>(context, listen: false).getLikedClubPosts;
      final currentPost =
          likedClubPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInPeopleAdmin) {
      final peopleAdminPosts =
          Provider.of<AdminPostsProvider>(context, listen: false).userPosts;
      final currentPost =
          peopleAdminPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInClubAdmin) {
      final clubAdminPosts =
          Provider.of<AdminPostsProvider>(context, listen: false).clubPosts;
      final currentPost =
          clubAdminPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    return widget.instance!;
  }

  void _goToPost(final ViewMode view, FullHelper instance,
      dynamic previewSetstate, String clubName, String postID) {
    final PostScreenArguments args = PostScreenArguments(
        instance: instance,
        viewMode: view,
        previewSetstate: previewSetstate,
        isNotif: false,
        postID: postID,
        clubName: clubName,
        section: Section.multiple,
        singleCommentID: '');
    Navigator.pushNamed(context, RouteGenerator.postScreen, arguments: args);
  }

  @override
  void dispose() {
    super.dispose();
    _controllre.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final locale =
        Provider.of<ThemeModel>(context, listen: false).serverLangCode;
    final date = helper.postedDate;
    final stamp = General.timeStamp(date, locale, context);
    final bool isClubPost = helper.isClubPost;
    final String poster = helper.title;
    final String clubName = helper.clubName;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final double _deviceWidth = General.widthQuery(context);
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final List<BoardPostItem> items = helper.boardPostItems;
    final bool sensitiveContent = helper.sensitiveContent;
    final String postId = helper.postId;
    final bool _showPost = helper.showPost;
    final bool isMyPost = poster == myUsername;
    final bool _selectedCensorMode =
        Provider.of<ThemeModel>(context, listen: false).censorMode;
    final nsfwCondition =
        sensitiveContent && !_showPost && !isMyPost && _selectedCensorMode;
    final bool helperDeleted = helper.isDeleted;
    final bool helperHidden = helper.isHidden;
    final List<String> _hiddenPosts =
        Provider.of<MyProfile>(context, listen: false).getHiddenPostIDs;
    final bool postHidden = _hiddenPosts.contains(postId);
    final isManagement = myUsername.startsWith('Linkspeak');
    final bool isBlocked = helper.isBlocked;
    final bool imBlocked = helper.imBlocked;
    final bool isBanned = helper.posterBanned;
    final bool imClubBanned = helper.imClubBanned;
    final bool clubDisabled = helper.clubDisabled;
    final bool clubProhibited = helper.clubProhibited;
    final bool isClubMember = helper.isClubMember;
    final bool imLinked = helper.isLinkedToPoster;
    final bool postExists = helper.postExists;
    final TheVisibility posterVis = helper.visibility;
    final ClubVisibility clubVis = helper.clubVisibility;
    final bool endgame = !postExists ||
        postHidden ||
        helperHidden ||
        helperDeleted ||
        (imBlocked && !isManagement) ||
        (isBanned && !isManagement) ||
        (isBlocked && !isManagement) ||
        (isClubPost &&
            !isManagement &&
            !isMyPost &&
            ((clubVis != ClubVisibility.public && !isClubMember) ||
                clubProhibited ||
                clubDisabled ||
                imClubBanned)) ||
        (!isClubPost &&
            !isManagement &&
            posterVis != TheVisibility.public &&
            !imLinked &&
            !isMyPost);
    final Widget _tile = ListTile(
        horizontalTitleGap: 5.0,
        leading: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                  onTap: () => visitProfile(myUsername, poster),
                  child: ChatProfileImage(
                      username: poster,
                      factor: widget.inPreview ? 0.04 : 0.06,
                      inEdit: false,
                      asset: null)),
            ]),
        title: GestureDetector(
            onTap: () => visitProfile(myUsername, poster),
            child: giveStacked(poster, false, '')),
        subtitle: isClubPost
            ? GestureDetector(
                onTap: () => visitClub(clubName),
                child: giveStacked(clubName, true, stamp))
            : giveStacked(stamp, true, ''),
        trailing: BoardPopupMenu(() => setState(() {}), false));
    return GestureDetector(
        onTap: () {
          if (widget.inPreview && !nsfwCondition) {
            _goToPost(
                ViewMode.post,
                giveInstance(
                    context,
                    postId,
                    widget.isInFeed,
                    widget.isInLike,
                    widget.isInFav,
                    widget.isInTab,
                    widget.isInMyTab,
                    widget.isInOtherTab,
                    widget.isInClubTopics,
                    widget.isInPeopleTopics,
                    widget.isInClubPosts,
                    widget.isInLikedClubs,
                    widget.isInFavClubs,
                    widget.isInClubFeed,
                    widget.isInClubPlaces,
                    widget.isInPeoplePlaces,
                    widget.isInPeopleAdmin,
                    widget.isInClubAdmin)!,
                () => setState(() {}),
                clubName,
                postId);
          }
        },
        child: Container(
            margin: EdgeInsets.symmetric(vertical: endgame ? 0 : 3.50),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: widget.inPreview
                    ? BorderRadius.circular(10.0)
                    : BorderRadius.circular(0)),
            child: widget.inPreview
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: endgame ? 0 : 10,
                        maxHeight: endgame ? 0 : 1800,
                        minWidth: endgame ? 0 : 10,
                        maxWidth: endgame ? 0 : _deviceWidth),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: nsfwCondition
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        crossAxisAlignment: nsfwCondition
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          _tile,
                          if (!nsfwCondition && items.length > 4)
                            ...items.take(4).map((e) {
                              var isText = e.isText;
                              var description = e.description;
                              var mediaURL = e.mediaURL;
                              if (isText) {
                                return buildTextField(description);
                              } else {
                                var currentMediaIndex =
                                    mediaList.indexOf(mediaURL);
                                return buildMediaItem(
                                    mediaURL,
                                    currentMediaIndex,
                                    _deviceHeight,
                                    sensitiveContent,
                                    () => _goToPost(
                                        ViewMode.post,
                                        giveInstance(
                                            context,
                                            postId,
                                            widget.isInFeed,
                                            widget.isInLike,
                                            widget.isInFav,
                                            widget.isInTab,
                                            widget.isInMyTab,
                                            widget.isInOtherTab,
                                            widget.isInClubTopics,
                                            widget.isInPeopleTopics,
                                            widget.isInClubPosts,
                                            widget.isInLikedClubs,
                                            widget.isInFavClubs,
                                            widget.isInClubFeed,
                                            widget.isInClubPlaces,
                                            widget.isInPeoplePlaces,
                                            widget.isInPeopleAdmin,
                                            widget.isInClubAdmin)!,
                                        () => setState(() {}),
                                        clubName,
                                        postId));
                              }
                            }).toList(),
                          if (!nsfwCondition && items.length <= 4)
                            ...items.map((e) {
                              var isText = e.isText;
                              var description = e.description;
                              var mediaURL = e.mediaURL;
                              if (isText) {
                                return buildTextField(description);
                              } else {
                                var currentMediaIndex =
                                    mediaList.indexOf(mediaURL);
                                return buildMediaItem(
                                    mediaURL,
                                    currentMediaIndex,
                                    _deviceHeight,
                                    sensitiveContent,
                                    () => _goToPost(
                                        ViewMode.post,
                                        giveInstance(
                                            context,
                                            postId,
                                            widget.isInFeed,
                                            widget.isInLike,
                                            widget.isInFav,
                                            widget.isInTab,
                                            widget.isInMyTab,
                                            widget.isInOtherTab,
                                            widget.isInClubTopics,
                                            widget.isInPeopleTopics,
                                            widget.isInClubPosts,
                                            widget.isInLikedClubs,
                                            widget.isInFavClubs,
                                            widget.isInClubFeed,
                                            widget.isInClubPlaces,
                                            widget.isInPeoplePlaces,
                                            widget.isInPeopleAdmin,
                                            widget.isInClubAdmin)!,
                                        () => setState(() {}),
                                        clubName,
                                        postId));
                              }
                            }).toList(),
                          if (!nsfwCondition && widget.inPreview ||
                              !widget.inPreview)
                            BranchPostBaseline(
                                isInPreview: widget.inPreview,
                                isInClubAdmin: widget.isInClubAdmin,
                                isInClubFeed: widget.isInClubFeed,
                                isInClubPlaces: widget.isInClubPlaces,
                                isInClubPosts: widget.isInClubPosts,
                                isInClubTopics: widget.isInClubTopics,
                                isInFav: widget.isInFav,
                                isInFavClubs: widget.isInFavClubs,
                                isInFeed: widget.isInFeed,
                                isInLike: widget.isInLike,
                                isInLikedClubs: widget.isInLikedClubs,
                                isInMyTab: widget.isInMyTab,
                                isInOtherTab: widget.isInOtherTab,
                                isInPeopleAdmin: widget.isInPeopleAdmin,
                                isInPeoplePlaces: widget.isInPeoplePlaces,
                                isInPeopleTopics: widget.isInPeopleTopics,
                                isInTab: widget.isInTab,
                                instance: widget.instance),
                          if (nsfwCondition)
                            const Icon(Icons.warning,
                                color: Colors.black, size: 55.0),
                          if (nsfwCondition) const SizedBox(height: 5.0),
                          if (nsfwCondition)
                            Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(lang.widgets_chat18,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0)))),
                          if (nsfwCondition)
                            const Divider(
                                color: Colors.white,
                                indent: 0.0,
                                endIndent: 0.0),
                          if (nsfwCondition)
                            TextButton(
                                child: Text(lang.widgets_chat19,
                                    style: const TextStyle(fontSize: 25.0)),
                                onPressed: () {
                                  Provider.of<FullHelper>(context,
                                          listen: false)
                                      .show();
                                  setState(() {});
                                })
                        ]))
                : Stack(fit: StackFit.passthrough, children: <Widget>[
                    Noglow(
                      child: ListView(
                          padding: const EdgeInsets.only(top: 50.0, bottom: 50),
                          addRepaintBoundaries: false,
                          children: <Widget>[
                            _tile,
                            ...items.map((e) {
                              var isText = e.isText;
                              var description = e.description;
                              var mediaURL = e.mediaURL;
                              if (isText) {
                                return buildTextField(description);
                              } else {
                                var currentMediaIndex =
                                    mediaList.indexOf(mediaURL);
                                return buildMediaItem(
                                    mediaURL,
                                    currentMediaIndex,
                                    _deviceHeight,
                                    sensitiveContent,
                                    () => _goToPost(
                                        ViewMode.post,
                                        giveInstance(
                                            context,
                                            postId,
                                            widget.isInFeed,
                                            widget.isInLike,
                                            widget.isInFav,
                                            widget.isInTab,
                                            widget.isInMyTab,
                                            widget.isInOtherTab,
                                            widget.isInClubTopics,
                                            widget.isInPeopleTopics,
                                            widget.isInClubPosts,
                                            widget.isInLikedClubs,
                                            widget.isInFavClubs,
                                            widget.isInClubFeed,
                                            widget.isInClubPlaces,
                                            widget.isInPeoplePlaces,
                                            widget.isInPeopleAdmin,
                                            widget.isInClubAdmin)!,
                                        () => setState(() {}),
                                        clubName,
                                        postId));
                              }
                            }).toList(),
                          ]),
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: BranchPostBaseline(
                            isInPreview: widget.inPreview,
                            isInClubAdmin: widget.isInClubAdmin,
                            isInClubFeed: widget.isInClubFeed,
                            isInClubPlaces: widget.isInClubPlaces,
                            isInClubPosts: widget.isInClubPosts,
                            isInClubTopics: widget.isInClubTopics,
                            isInFav: widget.isInFav,
                            isInFavClubs: widget.isInFavClubs,
                            isInFeed: widget.isInFeed,
                            isInLike: widget.isInLike,
                            isInLikedClubs: widget.isInLikedClubs,
                            isInMyTab: widget.isInMyTab,
                            isInOtherTab: widget.isInOtherTab,
                            isInPeopleAdmin: widget.isInPeopleAdmin,
                            isInPeoplePlaces: widget.isInPeoplePlaces,
                            isInPeopleTopics: widget.isInPeopleTopics,
                            isInTab: widget.isInTab,
                            instance: widget.instance))
                  ])));
  }
}

class BranchPostBaseline extends StatefulWidget {
  final bool isInPreview;
  final bool isInFeed;
  final bool isInClubFeed;
  final bool isInLike;
  final bool isInFav;
  final bool isInTab;
  final bool isInMyTab;
  final bool isInOtherTab;
  final bool isInPeopleTopics;
  final bool isInClubTopics;
  final bool isInClubPosts;
  final bool isInFavClubs;
  final bool isInLikedClubs;
  final bool isInPeoplePlaces;
  final bool isInClubPlaces;
  final bool isInPeopleAdmin;
  final bool isInClubAdmin;
  final FullHelper? instance;
  const BranchPostBaseline(
      {required this.isInPreview,
      required this.isInFeed,
      required this.isInClubFeed,
      required this.isInLike,
      required this.isInFav,
      required this.isInTab,
      required this.isInMyTab,
      required this.isInOtherTab,
      required this.isInPeopleTopics,
      required this.isInClubTopics,
      required this.isInClubPosts,
      required this.isInFavClubs,
      required this.isInLikedClubs,
      required this.isInPeoplePlaces,
      required this.isInClubPlaces,
      required this.isInPeopleAdmin,
      required this.isInClubAdmin,
      required this.instance});

  @override
  State<BranchPostBaseline> createState() => _BranchPostBaselineState();
}

class _BranchPostBaselineState extends State<BranchPostBaseline> {
  late PersistentBottomSheetController? _shareController;
  bool likeLoading = false;

  void showSections(
      {required bool isLikers,
      required bool isComments,
      required bool isTopics,
      required List<String> topics,
      required int numOfLikes,
      required int numOfComments,
      required String postID,
      required String clubName,
      required bool isClubPost,
      required FullHelper instance,
      required Section section,
      required String singleCommentID,
      required void Function(List<Comment>) setComments}) {
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
              isLikers: isLikers,
              isComments: isComments,
              isTopics: isTopics,
              topics: topics,
              numOfLikes: numOfLikes,
              numOfComments: numOfComments,
              postID: postID,
              clubName: clubName,
              instance: instance,
              isClubPost: isClubPost,
              section: section,
              setComments: setComments,
              singleCommentID: singleCommentID,
            )));
  }

  Future<void> _likeClubPost(
      void Function() helperLike,
      final bool isLiked,
      final String posterUsername,
      final String clubName,
      final String _myUsername,
      final String _myUserImg,
      final String postId) async {
    if (!likeLoading) {
      setState(() {
        likeLoading = true;
      });
      helperLike();
      final DateTime _rightNow = DateTime.now();
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      var likebatch = firestore.batch();
      var unlikeBatch = firestore.batch();
      final posts = firestore.collection('Posts');
      final myUser = firestore.collection('Users').doc(_myUsername);
      final thisPost = posts.doc(postId);
      final myLikedPosts = myUser.collection('Liked Club Posts');
      final myUnlikedPosts = myUser.collection('Unliked Club Posts');
      final postLikers = thisPost.collection('likers');
      final postUnlikers = thisPost.collection('unlikers');
      var thislikedPost = myLikedPosts.doc(postId);
      var thisUnlikedPost = myUnlikedPosts.doc(postId);
      var myLike = postLikers.doc(_myUsername);
      var myUnlike = postUnlikers.doc(_myUsername);
      final options = SetOptions(merge: true);
      likebatch.set(thislikedPost, {
        'date': _rightNow,
        'club name': clubName,
      });

      likebatch.set(myLike, {'date': _rightNow});
      likebatch.update(thisPost, {'likes': FieldValue.increment(1)});
      unlikeBatch.delete(thislikedPost);
      unlikeBatch.delete(myLike);
      unlikeBatch.set(myUnlike,
          {'date': _rightNow, 'times': FieldValue.increment(1)}, options);
      unlikeBatch.set(thisUnlikedPost,
          {'date': _rightNow, 'times': FieldValue.increment(1)}, options);
      unlikeBatch.update(thisPost, {'likes': FieldValue.increment(-1)});
      unlikeBatch.set(
          myUser, {'post unlikes': FieldValue.increment(1)}, options);
      unlikeBatch.set(thisPost, {'unlikes': FieldValue.increment(1)}, options);
      final checkExists = await General.checkExists('Posts/$postId');
      if (checkExists) {
        if (isLiked) {
          Map<String, dynamic> fields = {
            'club post unlikes': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'clubName': clubName,
            'date': _rightNow
          };
          General.updateControl(
              fields: fields,
              myUsername: _myUsername,
              collectionName: 'club post unlikes',
              docID: '$postId',
              docFields: docFields);

          return unlikeBatch.commit().then((_) async {
            setState(() {
              likeLoading = false;
            });
          }).catchError((_) {
            setState(() {
              likeLoading = false;
            });
          });
        } else if (!isLiked) {
          Map<String, dynamic> fields = {
            'club post likes': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'clubName': clubName,
            'date': _rightNow
          };
          General.updateControl(
              fields: fields,
              myUsername: _myUsername,
              collectionName: 'club post likes',
              docID: '$postId',
              docFields: docFields);
          return likebatch.commit().then((_) async {
            final targetUser =
                await firestore.collection('Users').doc(posterUsername).get();
            final token = targetUser.get('fcm');
            var secondBatch = firestore.batch();
            final otherLikesNotifs = firestore
                .collection('Users')
                .doc(posterUsername)
                .collection('PostLikesNotifs');
            final status = targetUser.get('Status');
            if (status != 'Banned') {
              if (targetUser.data()!.containsKey('AllowLikes')) {
                final allowLikes = targetUser.get('AllowLikes');
                if (allowLikes) {
                  if (posterUsername != _myUsername) {
                    secondBatch.set(otherLikesNotifs.doc(), {
                      'post': '$postId',
                      'user': _myUsername,
                      'recipient': posterUsername,
                      'token': token,
                      'date': _rightNow,
                      'clubName': clubName,
                    });
                    secondBatch.update(
                        firestore.collection('Users').doc(posterUsername),
                        {'numOfPostLikesNotifs': FieldValue.increment(1)});
                    secondBatch.commit();
                  }
                }
              } else {
                if (posterUsername != _myUsername) {
                  secondBatch.set(otherLikesNotifs.doc(), {
                    'post': '$postId',
                    'user': _myUsername,
                    'recipient': posterUsername,
                    'token': token,
                    'date': _rightNow,
                    'clubName': clubName,
                  });
                  secondBatch.update(
                      firestore.collection('Users').doc(posterUsername),
                      {'numOfPostLikesNotifs': FieldValue.increment(1)});
                  secondBatch.commit();
                }
              }
            }
            setState(() {
              likeLoading = false;
            });
          }).catchError((onError) {
            setState(() {
              likeLoading = false;
            });
          });
        }
      } else {
        setState(() {
          likeLoading = false;
        });
      }
    }
  }

  Future<void> _upVote(
      void Function() helperLike,
      final bool isLiked,
      final String posterUsername,
      final String _myUsername,
      final String _myUserImg,
      final String postId,
      final String clubName) async {
    if (!likeLoading) {
      setState(() {
        likeLoading = true;
      });
      helperLike();
      final DateTime _rightNow = DateTime.now();
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      var likebatch = firestore.batch();
      var unlikeBatch = firestore.batch();
      final posts = firestore.collection('Posts');
      final myUser = firestore.collection('Users').doc(_myUsername);
      final thisPost = posts.doc(postId);
      final myLikedPosts = myUser.collection('LikedPosts');
      final myUnlikedPosts = myUser.collection('Unliked Posts');
      final postLikers = thisPost.collection('likers');
      final postUnlikers = thisPost.collection('unlikers');
      var thislikedPost = myLikedPosts.doc(postId);
      var thisUnlikedPost = myUnlikedPosts.doc(postId);
      var myLike = postLikers.doc(_myUsername);
      var myUnlike = postUnlikers.doc(_myUsername);
      final options = SetOptions(merge: true);
      likebatch.set(thislikedPost, {'date': _rightNow});
      likebatch.set(myLike, {'date': _rightNow});
      likebatch.update(thisPost, {'likes': FieldValue.increment(1)});
      unlikeBatch.delete(thislikedPost);
      unlikeBatch.delete(myLike);
      unlikeBatch.set(myUnlike,
          {'date': _rightNow, 'times': FieldValue.increment(1)}, options);
      unlikeBatch.set(thisUnlikedPost,
          {'date': _rightNow, 'times': FieldValue.increment(1)}, options);
      unlikeBatch.update(thisPost, {'likes': FieldValue.increment(-1)});
      unlikeBatch.set(
          myUser, {'post unlikes': FieldValue.increment(1)}, options);
      unlikeBatch.set(thisPost, {'unlikes': FieldValue.increment(1)}, options);
      final checkExists = await General.checkExists('Posts/$postId');
      if (checkExists) {
        if (isLiked) {
          Map<String, dynamic> fields = {
            'post unlikes': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {'date': _rightNow};
          General.updateControl(
              fields: fields,
              myUsername: _myUsername,
              collectionName: 'post unlikes',
              docID: '$postId',
              docFields: docFields);
          return unlikeBatch.commit().then((_) async {
            setState(() {
              likeLoading = false;
            });
          }).catchError((_) {
            setState(() {
              likeLoading = false;
            });
          });
        } else if (!isLiked) {
          Map<String, dynamic> fields = {'post likes': FieldValue.increment(1)};
          Map<String, dynamic> docFields = {'date': _rightNow};
          General.updateControl(
              fields: fields,
              myUsername: _myUsername,
              collectionName: 'post likes',
              docID: '$postId',
              docFields: docFields);
          return likebatch.commit().then((_) async {
            final targetUser =
                await firestore.collection('Users').doc(posterUsername).get();
            final token = targetUser.get('fcm');
            var secondBatch = firestore.batch();
            final otherLikesNotifs = firestore
                .collection('Users')
                .doc(posterUsername)
                .collection('PostLikesNotifs');
            final status = targetUser.get('Status');
            if (status != 'Banned') {
              if (targetUser.data()!.containsKey('AllowLikes')) {
                final allowLikes = targetUser.get('AllowLikes');
                if (allowLikes) {
                  if (posterUsername != _myUsername) {
                    secondBatch.set(otherLikesNotifs.doc(), {
                      'post': '$postId',
                      'user': _myUsername,
                      'recipient': posterUsername,
                      'token': token,
                      'date': _rightNow,
                      'clubName': clubName,
                    });
                    secondBatch.update(
                        firestore.collection('Users').doc(posterUsername),
                        {'numOfPostLikesNotifs': FieldValue.increment(1)});
                    secondBatch.commit();
                  }
                }
              } else {
                if (posterUsername != _myUsername) {
                  secondBatch.set(otherLikesNotifs.doc(), {
                    'post': '$postId',
                    'user': _myUsername,
                    'recipient': posterUsername,
                    'token': token,
                    'date': _rightNow,
                    'clubName': clubName,
                  });
                  secondBatch.update(
                      firestore.collection('Users').doc(posterUsername),
                      {'numOfPostLikesNotifs': FieldValue.increment(1)});
                  secondBatch.commit();
                }
              }
            }
            setState(() {
              likeLoading = false;
            });
          }).catchError((onError) {
            setState(() {
              likeLoading = false;
            });
          });
        }
      } else {
        setState(() {
          likeLoading = false;
        });
      }
    }
  }

  FullHelper? giveInstance(
      BuildContext context,
      String postId,
      bool isInFeed,
      bool isInLike,
      bool isInFav,
      bool isInTab,
      bool myProfile,
      bool otherProfile,
      bool isInClubTopics,
      bool isInPeopleTopics,
      bool isInClubPosts,
      bool isInLikedClubs,
      bool isInFavClubs,
      bool isInClubFeed,
      bool isInClubPlaces,
      bool isInPeoplePlaces,
      bool isInPeopleAdmin,
      bool isInClubAdmin) {
    if (isInFeed && !isInClubFeed) {
      final currentFeedPosts =
          Provider.of<FeedProvider>(context, listen: false).posts;
      final currentFeedPost =
          currentFeedPosts.firstWhere((element) => element.postID == postId);
      final FullHelper feedinstance = currentFeedPost.instance;
      return feedinstance;
    }
    if (isInClubFeed) {
      final currentClubFeedPosts =
          Provider.of<ClubTabProvider>(context, listen: false).posts;
      final currentClubFeedPost = currentClubFeedPosts
          .firstWhere((element) => element.postID == postId);
      final FullHelper clubfeedinstance = currentClubFeedPost.instance;
      return clubfeedinstance;
    }
    if (isInPeopleTopics) {
      final currentTopicPosts =
          Provider.of<TopicScreenProvider>(context, listen: false).posts;
      final currentTopicPost =
          currentTopicPosts.firstWhere((element) => element.postID == postId);
      final FullHelper topicInstance = currentTopicPost.instance;
      return topicInstance;
    }
    if (isInClubTopics) {
      final currentTopicPosts =
          Provider.of<TopicScreenProvider>(context, listen: false).clubPosts;
      final currentTopicPost =
          currentTopicPosts.firstWhere((element) => element.postID == postId);
      final FullHelper topicInstance = currentTopicPost.instance;
      return topicInstance;
    }
    if (isInPeoplePlaces) {
      final currentPlacePosts =
          Provider.of<PlacesScreenProvider>(context, listen: false).posts;
      final currentPlacePost =
          currentPlacePosts.firstWhere((element) => element.postID == postId);
      final FullHelper placeInstance = currentPlacePost.instance;
      return placeInstance;
    }
    if (isInClubPlaces) {
      final currentPlacePosts =
          Provider.of<PlacesScreenProvider>(context, listen: false).clubPosts;
      final currentPlacePost =
          currentPlacePosts.firstWhere((element) => element.postID == postId);
      final FullHelper placeInstance = currentPlacePost.instance;
      return placeInstance;
    }
    if (isInLike && !isInLikedClubs) {
      final likedPosts =
          Provider.of<MyProfile>(context, listen: false).getLikedPosts;
      final currentPost =
          likedPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInFav && !isInFavClubs) {
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
    if (isInClubPosts) {
      final clubPosts = Provider.of<ClubProvider>(context, listen: false).posts;
      final currentPosts =
          clubPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPosts.instance;
      return instance;
    }
    if (isInFavClubs && isInFav) {
      final favClubPosts =
          Provider.of<MyProfile>(context, listen: false).getFavClubPosts;
      final currentPost =
          favClubPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInLikedClubs && isInLike) {
      final likedClubPosts =
          Provider.of<MyProfile>(context, listen: false).getLikedClubPosts;
      final currentPost =
          likedClubPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInPeopleAdmin) {
      final peopleAdminPosts =
          Provider.of<AdminPostsProvider>(context, listen: false).userPosts;
      final currentPost =
          peopleAdminPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    if (isInClubAdmin) {
      final clubAdminPosts =
          Provider.of<AdminPostsProvider>(context, listen: false).clubPosts;
      final currentPost =
          clubAdminPosts.firstWhere((element) => element.postID == postId);
      final FullHelper instance = currentPost.instance;
      return instance;
    }
    return widget.instance!;
  }

  void _goToPost(final ViewMode view, FullHelper instance,
      dynamic previewSetstate, String clubName, String postID) {
    final PostScreenArguments args = PostScreenArguments(
        instance: instance,
        viewMode: view,
        previewSetstate: previewSetstate,
        isNotif: false,
        postID: postID,
        clubName: clubName,
        section: Section.multiple,
        singleCommentID: '');
    Navigator.pushNamed(context, RouteGenerator.postScreen, arguments: args);
  }

  void finalVisitPost(String postId, String clubName) {
    _goToPost(
        ViewMode.post,
        giveInstance(
            context,
            postId,
            widget.isInFeed,
            widget.isInLike,
            widget.isInFav,
            widget.isInTab,
            widget.isInMyTab,
            widget.isInOtherTab,
            widget.isInClubTopics,
            widget.isInPeopleTopics,
            widget.isInClubPosts,
            widget.isInLikedClubs,
            widget.isInFavClubs,
            widget.isInClubFeed,
            widget.isInClubPlaces,
            widget.isInPeoplePlaces,
            widget.isInPeopleAdmin,
            widget.isInClubAdmin)!,
        () => setState(() {}),
        clubName,
        postId);
  }

  Widget buildLikeButton(
      {required bool isLiked,
      required int numOfLikes,
      required dynamic likeLogic,
      required String postId,
      required String clubName,
      required int numOfComments,
      required FullHelper instance,
      required bool isClubPost,
      required void Function(List<Comment>) setComments}) {
    final themeProvider = Provider.of<ThemeModel>(context, listen: false);
    final String currentIconName = themeProvider.selectedIconName;
    final IconData currentIcon = themeProvider.themeIcon;
    Color currentIconColor = themeProvider.likeColor;
    final File? inactiveIconPath = themeProvider.inactiveLikeFile;
    final File? activeIconPath = themeProvider.activeLikeFile;
    if (widget.isInOtherTab) {
      final otherProfile = Provider.of<OtherProfile>(context, listen: false);
      currentIconColor = otherProfile.getLikeColor;
    }
    Widget emptyLikes = Container(
        height: 35,
        width: 35,
        margin: const EdgeInsets.only(bottom: 3),
        // decoration:
        //     BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: IconButton(
            padding: const EdgeInsets.all(0),
            icon: (currentIconName != 'Custom')
                ? Icon(currentIcon,
                    size: 22.0,
                    color: isLiked ? currentIconColor : Colors.white)
                : Image.file(isLiked ? activeIconPath! : inactiveIconPath!),
            iconSize: 22,
            onPressed: () {
              likeLogic();
            }));
    Widget fullLikes = ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: 10, maxWidth: 100, minHeight: 35, maxHeight: 35),
        child: Container(
            margin: const EdgeInsets.only(bottom: 3),
            padding: const EdgeInsets.all(5),
            // decoration: BoxDecoration(
            //     color: Colors.black54, borderRadius: BorderRadius.circular(15)),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (currentIconName != 'Custom')
                    GestureDetector(
                        onTap: () {
                          likeLogic();
                        },
                        child: Icon(currentIcon,
                            size: 22.0,
                            color: isLiked ? currentIconColor : Colors.white)),
                  if (currentIconName == 'Custom')
                    IconButton(
                        padding: const EdgeInsets.all(0.0),
                        iconSize: 22,
                        onPressed: () {
                          likeLogic();
                        },
                        icon: Image.file(
                            isLiked ? activeIconPath! : inactiveIconPath!)),
                  GestureDetector(
                      onTap: () {
                        if (widget.isInPreview)
                          finalVisitPost(postId, clubName);
                        Future.delayed(
                            widget.isInPreview
                                ? const Duration(milliseconds: 500)
                                : const Duration(milliseconds: 0), () {
                          showSections(
                            isLikers: true,
                            isComments: false,
                            isTopics: false,
                            topics: [],
                            numOfLikes: numOfLikes,
                            numOfComments: numOfComments,
                            postID: postId,
                            clubName: clubName,
                            instance: instance,
                            isClubPost: isClubPost,
                            setComments: setComments,
                            section: Section.multiple,
                            singleCommentID: '',
                          );
                        });
                      },
                      child: Text("  ${General.optimisedNumbers(numOfLikes)}",
                          textAlign: TextAlign.start,
                          softWrap: false,
                          style: TextStyle(
                              fontSize: 15.0,
                              color:
                                  (isLiked) ? currentIconColor : Colors.white,
                              fontFamily: 'RobotoCondensed')))
                ])));
    return numOfLikes > 0 ? fullLikes : emptyLikes;
  }

  Widget buildCommentsButton(
      {required int numOfComments,
      required String postId,
      required String clubName,
      required int numOfLikes,
      required FullHelper instance,
      required bool isClubPost,
      required void Function(List<Comment>) setComments}) {
    Widget emptyComments = Container(
        height: 35,
        width: 35,
        // margin: const EdgeInsets.only(bottom: 3),
        // decoration:
        //     BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: IconButton(
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                size: 22.0, color: Colors.white),
            onPressed: () {
              if (widget.isInPreview) {
                finalVisitPost(postId, clubName);
              }
              Future.delayed(
                  widget.isInPreview
                      ? const Duration(milliseconds: 500)
                      : const Duration(milliseconds: 0), () {
                showSections(
                  isLikers: false,
                  isComments: true,
                  isTopics: false,
                  topics: [],
                  numOfLikes: numOfLikes,
                  numOfComments: numOfComments,
                  postID: postId,
                  clubName: clubName,
                  instance: instance,
                  isClubPost: isClubPost,
                  setComments: setComments,
                  section: Section.multiple,
                  singleCommentID: '',
                );
              });
            }));
    Widget fullComments = GestureDetector(
        onTap: () {
          if (widget.isInPreview) {
            finalVisitPost(postId, clubName);
          }
          Future.delayed(
              widget.isInPreview
                  ? const Duration(milliseconds: 500)
                  : const Duration(milliseconds: 0), () {
            showSections(
              isLikers: false,
              isComments: true,
              isTopics: false,
              topics: [],
              numOfLikes: numOfLikes,
              numOfComments: numOfComments,
              postID: postId,
              clubName: clubName,
              instance: instance,
              isClubPost: isClubPost,
              setComments: setComments,
              section: Section.multiple,
              singleCommentID: '',
            );
          });
        },
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: 10, maxWidth: 100, minHeight: 35, maxHeight: 35),
            child: Container(
                // margin: const EdgeInsets.only(bottom: 3),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    // color: Colors.black54,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 22.0, color: Colors.white),
                      Text("  ${General.optimisedNumbers(numOfComments)}",
                          textAlign: TextAlign.start,
                          softWrap: false,
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                              fontFamily: 'RobotoCondensed'))
                    ]))));
    return numOfComments > 0 ? fullComments : emptyComments;
  }

  Widget buildShareButton(String postID, String clubName, bool isClubPost) =>
      Container(
          height: 35,
          width: 35,
          // margin: const EdgeInsets.only(bottom: 3),
          // decoration:
          //     BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
          child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: const Icon(customIcons.MyFlutterApp.right,
                  size: 22.0, color: Colors.white),
              onPressed: () {
                _shareController = showBottomSheet(
                    context: context,
                    builder: (context) => ShareWidget(
                        isInFeed: false,
                        bottomSheetController: _shareController,
                        postID: postID,
                        clubName: clubName,
                        isClubPost: isClubPost,
                        isFlare: false,
                        flarePoster: '',
                        collectionID: '',
                        flareID: ''),
                    backgroundColor: Colors.transparent);
              }));
  Widget buildTopicsButton(
      {required List<String> topics,
      required int numOfLikes,
      required int numOfComments,
      required String postID,
      required String clubName,
      required FullHelper instance,
      required bool isClubPost,
      required void Function(List<Comment>) setComments}) {
    final lang = General.language(context);
    return GestureDetector(
        onTap: () {
          showSections(
            isLikers: false,
            isComments: false,
            isTopics: true,
            topics: topics,
            numOfLikes: numOfLikes,
            numOfComments: numOfComments,
            postID: postID,
            clubName: clubName,
            instance: instance,
            isClubPost: isClubPost,
            setComments: setComments,
            section: Section.multiple,
            singleCommentID: '',
          );
        },
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: 10, maxWidth: 100, minHeight: 35, maxHeight: 35),
            child: Container(
                // margin: const EdgeInsets.only(bottom: 3),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    // color: Colors.black54,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(lang.clubs_tabbar3,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 17))
                    ]))));
  }

  @override
  Widget build(BuildContext context) {
    const _widthBox = SizedBox(width: 5);
    var helper = Provider.of<FullHelper>(context);
    final List<String> topics = helper.postTopics;
    final int numOfLiked = helper.getNumOfLikes;
    final int numOfComments = helper.getNumOfComments;
    final bool uppedByMe = helper.isLiked;
    final bool isClubPost = helper.isClubPost;
    final String poster = helper.posterId;
    final String _clubName = helper.clubName;
    final String postID = helper.postId;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String _myUserImg =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    final void Function() helperLikePost =
        Provider.of<FullHelper>(context, listen: false).like;
    final void Function(List<Comment>) setComments =
        Provider.of<FullHelper>(context, listen: false).setComments;
    final FullHelper instance = giveInstance(
        context,
        postID,
        widget.isInFeed,
        widget.isInLike,
        widget.isInFav,
        widget.isInTab,
        widget.isInMyTab,
        widget.isInOtherTab,
        widget.isInClubTopics,
        widget.isInPeopleTopics,
        widget.isInClubPosts,
        widget.isInLikedClubs,
        widget.isInFavClubs,
        widget.isInClubFeed,
        widget.isInClubPlaces,
        widget.isInPeoplePlaces,
        widget.isInPeopleAdmin,
        widget.isInClubAdmin)!;
    void likeLogic() {
      if (isClubPost)
        _likeClubPost(helperLikePost, uppedByMe, poster, _clubName, _myUsername,
            _myUserImg, postID);
      else
        _upVote(helperLikePost, uppedByMe, poster, _myUsername, _myUserImg,
            postID, _clubName);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: 52, maxHeight: 52, minWidth: 10, maxWidth: 350),
      child: Container(
          margin: EdgeInsets.only(
              left: !widget.isInPreview ? 15 : 3,
              bottom: widget.isInPreview ? 0 : 10),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20)),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildLikeButton(
                    isLiked: uppedByMe,
                    numOfLikes: numOfLiked,
                    likeLogic: likeLogic,
                    postId: postID,
                    clubName: _clubName,
                    numOfComments: numOfComments,
                    instance: instance,
                    isClubPost: isClubPost,
                    setComments: setComments),
                _widthBox,
                buildCommentsButton(
                    numOfComments: numOfComments,
                    postId: postID,
                    clubName: _clubName,
                    numOfLikes: numOfLiked,
                    instance: instance,
                    isClubPost: isClubPost,
                    setComments: setComments),
                if (!widget.isInPreview) _widthBox,
                if (!widget.isInPreview)
                  buildTopicsButton(
                      topics: topics,
                      numOfLikes: numOfLiked,
                      numOfComments: numOfComments,
                      postID: postID,
                      instance: instance,
                      isClubPost: isClubPost,
                      clubName: _clubName,
                      setComments: setComments),
                _widthBox,
                buildShareButton(postID, _clubName, isClubPost)
              ])),
    );
  }
}
