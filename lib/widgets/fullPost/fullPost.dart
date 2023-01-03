// ignore_for_file: unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../clubs/clubAvatar.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter_switch/flutter_switch.dart';
import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/themeModel.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/postCarouselHelper.dart';
import '../../routes.dart';
import '../common/adaptiveText.dart';
import '../common/additionalAddressButton.dart';
import '../common/chatprofileImage.dart';
import '../common/myLinkify.dart';
import '../common/nestedScroller.dart';
import '../common/noglow.dart';
import '../common/popUpMenuButton.dart';
import '../post/postBaseline.dart';
import 'fullPostCarousel.dart';

class FullPost extends StatefulWidget {
  final ScrollController scrollController;
  final Widget? display;
  final bool upView;
  final bool commentsView;
  final bool topicsView;
  final bool shareView;
  final void Function() upvote;
  final dynamic upButtonHandler;
  final void Function()? commentButtonHandler;
  final void Function()? topicButtonHandler;
  final void Function()? shareButtonHandler;
  final void Function()? likeTextHandler;
  final dynamic previewSetstate;
  final dynamic refreshHandler;
  FullPost(
      {required this.scrollController,
      required this.display,
      required this.upView,
      required this.commentsView,
      required this.topicsView,
      required this.shareView,
      required this.upButtonHandler,
      required this.upvote,
      required this.commentButtonHandler,
      required this.topicButtonHandler,
      required this.shareButtonHandler,
      required this.likeTextHandler,
      required this.previewSetstate,
      required this.refreshHandler});

  @override
  State<FullPost> createState() => _FullPostState();
}

class _FullPostState extends State<FullPost> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TapGestureRecognizer _usernameRecognizer = TapGestureRecognizer();
  final TapGestureRecognizer _clubNameRecognizer = TapGestureRecognizer();

  String postName = '';
  String sessionID = '';
  String myName = '';
  late Future<void> _viewPost;
  late Future<void> _initSession;
  late Future<void> _endSession;

  Future<void> initSession(String myUsername, String post) async {
    final checkExists = await General.checkExists('Posts/$post');
    if (checkExists) {
      var batch = firestore.batch();
      final _rightNow = DateTime.now();
      final postsCollection = firestore.collection('Posts');
      final thisPost = postsCollection.doc(post);
      final sessions = thisPost.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final hasSession = mySession.exists;
      if (!hasSession) {
        final options = SetOptions(merge: true);
        batch.set(sessions.doc(myUsername), {'start': _rightNow}, options);
        batch.set(thisPost, {'sessions': FieldValue.increment(1)}, options);
      }
      return batch.commit();
    }
  }

  Future<void> endSession(String myUsername, String post) async {
    final checkExists = await General.checkExists('Posts/$post');
    if (checkExists) {
      final _rightNow = DateTime.now();
      var batch = firestore.batch();
      final options = SetOptions(merge: true);
      final postsCollection = firestore.collection('Posts');
      final thisPost = postsCollection.doc(post);
      final postViewers = thisPost.collection('Viewers');
      final myPostSessions = postViewers.doc(myUsername).collection('Sessions');
      final thisSession = await myPostSessions.doc(sessionID).get();
      final thisSessionExists = thisSession.exists;
      final sessions = thisPost.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final hasSession = mySession.exists;
      if (hasSession) {
        batch.delete(sessions.doc(myUsername));
        batch.set(thisPost, {'sessions': FieldValue.increment(-1)}, options);
      }
      if (thisSessionExists) {
        batch.set(myPostSessions.doc(sessionID), {'end': _rightNow}, options);
      }
      return batch.commit();
    }
  }

  Future<void> viewPost(String postID, String myUsername, bool isClubPost,
      String clubName) async {
    final checkExists = await General.checkExists('Posts/$postID');
    if (checkExists) {
      var batch = firestore.batch();
      final _rightNow = DateTime.now();
      final _sessionID = _rightNow.toString();
      sessionID = _sessionID;
      final usersCollection = firestore.collection('Users');
      final postsCollection = firestore.collection('Posts');
      final myUser = usersCollection.doc(myUsername);
      final myViewedPosts = myUser.collection('Viewed Posts');
      final thisMyViewed = await myViewedPosts.doc(postID).get();
      final alreadySeen = thisMyViewed.exists;
      final thisPost = postsCollection.doc(postID);
      final postViewers = thisPost.collection('Viewers');
      final myViewerDoc = await postViewers.doc(myUsername).get();
      final isViewed = myViewerDoc.exists;
      final initialData = {
        'postID': postID,
        'clubName': clubName,
        'isClubPost': isClubPost,
        'first viewed': _rightNow,
        'times': FieldValue.increment(1),
        'ID': myUsername,
      };
      final existingData = {
        'times': FieldValue.increment(1),
        'last viewed': _rightNow
      };
      final options = SetOptions(merge: true);
      if (alreadySeen) {
        batch.set(myViewedPosts.doc(postID), existingData, options);
      } else {
        batch.set(myViewedPosts.doc(postID), initialData, options);
        batch.set(myUser, {'seen posts': FieldValue.increment(1)}, options);
      }
      if (isViewed) {
        batch.set(postViewers.doc(myUsername), existingData, options);
        batch.set(
            postViewers.doc(myUsername).collection('Sessions').doc(_sessionID),
            {'start': _rightNow},
            options);
      } else {
        batch.set(postViewers.doc(myUsername), initialData, options);
        batch.set(
            postViewers.doc(myUsername).collection('Sessions').doc(_sessionID),
            {'start': _rightNow},
            options);
        batch.set(thisPost, {'viewers': FieldValue.increment(1)}, options);
      }
      if (isClubPost) {
        Map<String, dynamic> fields = {
          'club post views': FieldValue.increment(1)
        };
        Map<String, dynamic> docFields = {
          'clubName': clubName,
          'date': _rightNow,
          'times': FieldValue.increment(1)
        };
        General.updateControl(
            fields: fields,
            myUsername: myUsername,
            collectionName: 'club post views',
            docID: '$postID',
            docFields: docFields);
      } else {
        Map<String, dynamic> fields = {'post views': FieldValue.increment(1)};
        Map<String, dynamic> docFields = {
          'date': _rightNow,
          'times': FieldValue.increment(1)
        };
        General.updateControl(
            fields: fields,
            myUsername: myUsername,
            collectionName: 'post views',
            docID: '$postID',
            docFields: docFields);
      }
      return batch.commit();
    }
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final String postID = helper.postId;
    final String clubName = helper.clubName;
    final bool isClubPost = helper.isClubPost;
    postName = postID;
    myName = myUsername;
    _viewPost = viewPost(postID, myUsername, isClubPost, clubName);
    _initSession = initSession(myUsername, postID);
  }

  @override
  void dispose() {
    super.dispose();
    _endSession = endSession(myName, postName);
    _usernameRecognizer.dispose();
    _clubNameRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final locale = Provider.of<ThemeModel>(context,listen:false).serverLangCode;
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final String clubName = helper.clubName;
    String displayClubName = clubName;
    if (clubName.length > 15) {
      displayClubName = '${clubName.substring(0, 15)}..';
    }
    final void Function() helperHide = helper.hidePost;
    final void Function() helperDelete = helper.deletePost;
    final void Function() helperUnhide = helper.unhidePost;
    final String postId = helper.postId;
    final DateTime postedDate = helper.postedDate;
    final String title = helper.title;
    String displayUsername = title;
    final bool isClubPost = helper.isClubPost;
    if (isClubPost && title.length > 15) {
      displayUsername = '${title.substring(0, 15)}..';
    }
    final bool isMod = helper.isMod;
    final String description = helper.decription;
    final List<String> postTopics = helper.postTopics;
    final List<String> postImgUrls = helper.postImgUrls;
    final bool _noMedia = postImgUrls.isEmpty;
    final bool _withMedia = postImgUrls.isNotEmpty;
    final bool _noDescription = description.isEmpty;
    final bool _withDescription = description.isNotEmpty;
    final dynamic _postLocation = helper.getLocation;
    final CarouselPhysHelp _carouselInstance = helper.getCarouselInstance;
    const Widget _carousel = const FullPostCarousel();
    void visitProfile() {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: title);
      Navigator.pushNamed(
        context,
        (title == myUsername)
            ? RouteGenerator.myProfileScreen
            : RouteGenerator.posterProfileScreen,
        arguments: (title == myUsername) ? null : args,
      );
    }

    void visitClub() {
      final ClubScreenArgs args = ClubScreenArgs(clubName);
      Navigator.pushNamed(context, RouteGenerator.clubScreen, arguments: args);
    }

    _usernameRecognizer..onTap = visitProfile;
    _clubNameRecognizer..onTap = visitClub;

    return FutureBuilder(
        future: _viewPost,
        builder: (ctx, snapshot) {
          return Noglow(
              child: RefreshIndicator(
                  backgroundColor: _primaryColor,
                  displacement: 2.0,
                  color: _accentColor,
                  onRefresh: widget.refreshHandler,
                  child: ListView(
                      padding: const EdgeInsets.only(top: 50.0),
                      controller: widget.scrollController,
                      children: <Widget>[
                        SizedBox(
                            height: (_noMedia && _withDescription ||
                                    _withMedia && _noDescription)
                                ? _deviceHeight * 0.9
                                : null,
                            child:
                                ChangeNotifierProvider<CarouselPhysHelp>.value(
                                    value: _carouselInstance,
                                    child: Builder(builder: (context) {
                                      return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            const SizedBox(height: 20.0),
                                            // if (!isClubPost)
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      TextButton(
                                                        onPressed: visitProfile,
                                                        child: ChatProfileImage(
                                                          username: title,
                                                          factor: 0.055,
                                                          inEdit: false,
                                                          asset: null,
                                                        ),
                                                      ),
                                                      OptimisedText(
                                                          minWidth:
                                                              _deviceWidth *
                                                                  0.1,
                                                          maxWidth:
                                                              _deviceWidth *
                                                                  0.84,
                                                          minHeight: 50,
                                                          maxHeight: 50,
                                                          fit: BoxFit.scaleDown,
                                                          child: TextButton(
                                                              onPressed: () {},
                                                              style: const ButtonStyle(
                                                                  splashFactory:
                                                                      NoSplash
                                                                          .splashFactory),
                                                              child: RichText(
                                                                  text: TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                            recognizer:
                                                                                _usernameRecognizer,
                                                                            text:
                                                                                displayUsername,
                                                                            style: const TextStyle(
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 18.0)),
                                                                        if (isClubPost)
                                                                          const TextSpan(
                                                                              text: ' x ',
                                                                              style: const TextStyle(color: Colors.black, fontSize: 14.0)),
                                                                        if (isClubPost)
                                                                          TextSpan(
                                                                              recognizer: _clubNameRecognizer,
                                                                              text: displayClubName,
                                                                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18.0))
                                                                      ]),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start))),
                                                      const Spacer(),
                                                      PopupMenuButton(
                                                          tooltip: lang
                                                              .screens_profile,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0)),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.0),
                                                          child: const Icon(
                                                              Icons.more_vert,
                                                              color:
                                                                  Colors.grey),
                                                          itemBuilder: (_) => [
                                                                PopupMenuItem(
                                                                    padding: const EdgeInsets
                                                                            .all(
                                                                        0.0),
                                                                    enabled:
                                                                        true,
                                                                    child: MyPopUpMenuButton(
                                                                        id:
                                                                            postId,
                                                                        postID:
                                                                            postId,
                                                                        clubName:
                                                                            clubName,
                                                                        prohibitClub:
                                                                            () {},
                                                                        isInProfile:
                                                                            false,
                                                                        isInClubScreen:
                                                                            false,
                                                                        isClubPost:
                                                                            isClubPost,
                                                                        isProhibited:
                                                                            false,
                                                                        isBanned:
                                                                            false,
                                                                        isMod:
                                                                            isMod,
                                                                        isFav: context
                                                                            .read<
                                                                                FullHelper>()
                                                                            .isFav,
                                                                        helperFav: helper
                                                                            .fav,
                                                                        postedByMe: title ==
                                                                            context
                                                                                .read<
                                                                                    MyProfile>()
                                                                                .getUsername,
                                                                        postTopics:
                                                                            postTopics,
                                                                        postMedia:
                                                                            postImgUrls,
                                                                        postDate:
                                                                            postedDate,
                                                                        isBlocked:
                                                                            false,
                                                                        isLinkedToMe:
                                                                            false,
                                                                        block:
                                                                            () {},
                                                                        unblock:
                                                                            () {},
                                                                        remove:
                                                                            () {},
                                                                        banUser:
                                                                            () {},
                                                                        unbanUser:
                                                                            () {},
                                                                        hidePost:
                                                                            helperHide,
                                                                        deletePost:
                                                                            helperDelete,
                                                                        unhidePost:
                                                                            helperUnhide,
                                                                        previewSetstate:
                                                                            widget
                                                                                .previewSetstate,
                                                                        isInFlareProfile:
                                                                            false,
                                                                        flareProfileID:
                                                                            ''))
                                                              ])
                                                    ])),
                                            // if (isClubPost)
                                            // ClubTitle(widget.previewSetstate),
                                            Row(children: [
                                              const Spacer(),
                                              Text(
                                                  General.timeStamp(postedDate,locale,context),
                                                  softWrap: false,
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13.0)),
                                              const SizedBox(width: 15)
                                            ]),
                                            const SizedBox(height: 25.0),
                                            if (_withMedia && _withDescription)
                                              WithMediaTextContent(
                                                  description: description,
                                                  controller:
                                                      widget.scrollController),
                                            if (_withMedia && _withDescription)
                                              const SizedBox(height: 10.0),
                                            if (_noMedia && _withDescription)
                                              NoMediaTextContent(
                                                  description: description,
                                                  controller:
                                                      widget.scrollController),
                                            if (_withMedia && _noDescription)
                                              const Spacer(),
                                            if (_noMedia && _withDescription ||
                                                _withMedia && _noDescription)
                                              const Spacer(),
                                            if (_postLocation != '')
                                              const AdditionalAddressButton(
                                                  isInPostScreen: true,
                                                  isInPost: false,
                                                  somethingChanged: null,
                                                  changeAddress: null,
                                                  changeAddressName: null,
                                                  postLocation: null,
                                                  postLocationName: null),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // if (_withMedia && postImgUrls.length > 1)
                                                  //   FlutterSwitch(
                                                  //     showOnOff: true,
                                                  //     activeText: 'stop',
                                                  //     activeTextColor: Colors.white,
                                                  //     inactiveText: 'play',
                                                  //     value:
                                                  //         Provider.of<CarouselPhysHelp>(context)
                                                  //             .carouselPlay,
                                                  //     onToggle: (valu) {
                                                  //       Provider.of<CarouselPhysHelp>(context,
                                                  //               listen: false)
                                                  //           .playCarousel();
                                                  //     },
                                                  //     activeColor: _primaryColor,
                                                  //     activeIcon: Icon(
                                                  //       Icons.pause,
                                                  //     ),
                                                  //     activeToggleColor: _accentColor,
                                                  //     inactiveIcon: Icon(
                                                  //       Icons.play_arrow,
                                                  //     ),
                                                  //   ),
                                                  if (_withMedia &&
                                                      postImgUrls.length > 1)
                                                    Container(
                                                        width: _deviceWidth,
                                                        height: 30.0,
                                                        child: Center(
                                                            child: Noglow(
                                                          child: ListView(
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis
                                                                      .horizontal,
                                                              children:
                                                                  postImgUrls
                                                                      .map(
                                                                          (url) {
                                                                int index =
                                                                    postImgUrls
                                                                        .indexOf(
                                                                            url);
                                                                return Container(
                                                                    width: 8.0,
                                                                    height: 8.0,
                                                                    margin: const EdgeInsets
                                                                            .symmetric(
                                                                        vertical:
                                                                            10.0,
                                                                        horizontal:
                                                                            2.0),
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Provider.of<CarouselPhysHelp>(context).current ==
                                                                                index
                                                                            ? Border.all(
                                                                                color:
                                                                                    _primaryColor)
                                                                            : null,
                                                                        color: Provider.of<CarouselPhysHelp>(context).current ==
                                                                                index
                                                                            ? _accentColor
                                                                            : _primaryColor));
                                                              }).toList()),
                                                        )))
                                                ]),
                                            if (_withMedia && _noDescription)
                                              _carousel,
                                            if (_withMedia && _withDescription)
                                              _carousel,
                                            if (_noMedia ||
                                                _withMedia &&
                                                    _noDescription &&
                                                    postImgUrls.length == 1)
                                              const Spacer()
                                          ]);
                                    }))),
                        PostBar(
                            postID: postId,
                            shareView: widget.shareView,
                            isInFeed: false,
                            isClubPost: isClubPost,
                            upButtonHandler: widget.upButtonHandler,
                            likeTextHandler: widget.likeTextHandler,
                            commentButtonHandler: widget.commentButtonHandler,
                            topicButtonHandler: widget.topicButtonHandler,
                            shareButtonHandler: widget.shareButtonHandler,
                            upView: widget.upView,
                            commentView: widget.commentsView,
                            topicsView: widget.topicsView,
                            isInOtherProfile: false),
                        if (widget.upView ||
                            widget.commentsView ||
                            widget.topicsView ||
                            widget.shareView && widget.display != null)
                          SizedBox(child: widget.display)
                      ])));
        });
  }
}

class NoMediaTextContent extends StatefulWidget {
  const NoMediaTextContent({
    Key? key,
    required this.description,
    required this.controller,
  }) : super(key: key);

  final String? description;
  final ScrollController controller;

  @override
  State<NoMediaTextContent> createState() => _NoMediaTextContentState();
}

class _NoMediaTextContentState extends State<NoMediaTextContent> {
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: _deviceHeight * 0.25,
                maxHeight: _deviceHeight * 0.65,
                minWidth: _deviceWidth * 0.95,
                maxWidth: _deviceWidth * 0.95),
            child: NestedScroller(
                controller: widget.controller,
                child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: MyLinkify(
                        text: '${widget.description!}',
                        maxLines: 1500,
                        style:
                            const TextStyle(fontFamily: 'Roboto', fontSize: 18),
                        textDirection: null)))));
  }
}

class WithMediaTextContent extends StatefulWidget {
  const WithMediaTextContent({
    Key? key,
    required this.description,
    required this.controller,
  }) : super(key: key);

  final String? description;
  final ScrollController controller;

  @override
  State<WithMediaTextContent> createState() => _WithMediaTextContentState();
}

class _WithMediaTextContentState extends State<WithMediaTextContent> {
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: _deviceHeight * 0.20,
                maxHeight: _deviceHeight * 0.55,
                minWidth: _deviceWidth * 0.95,
                maxWidth: _deviceWidth * 0.95),
            child: NestedScroller(
                controller: widget.controller,
                child: SingleChildScrollView(
                    child: MyLinkify(
                        text: '${widget.description!}',
                        maxLines: 1500,
                        style:
                            const TextStyle(fontFamily: 'Roboto', fontSize: 18),
                        textDirection: null)))));
  }
}

class ClubTitle extends StatefulWidget {
  final previewSetstate;
  const ClubTitle(this.previewSetstate);

  @override
  State<ClubTitle> createState() => _ClubTitleState();
}

class _ClubTitleState extends State<ClubTitle> {
  final TapGestureRecognizer _usernameRecognizer = TapGestureRecognizer();
  final TapGestureRecognizer _clubNameRecognizer = TapGestureRecognizer();
  @override
  void dispose() {
    super.dispose();
    _usernameRecognizer.dispose();
    _clubNameRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceWidth = General.widthQuery(context);
    final double _deviceHeight = _sizeQuery.height;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final String clubName = helper.clubName;
    final void Function() helperHide = helper.hidePost;
    final void Function() helperDelete = helper.deletePost;
    final void Function() helperUnhide = helper.unhidePost;
    final String postId = helper.postId;
    final DateTime postedDate = helper.postedDate;
    final String title = helper.title;
    final bool isClubPost = helper.isClubPost;
    final bool isMod = helper.isMod;
    final List<String> postTopics = helper.postTopics;
    final List<String> postImgUrls = helper.postImgUrls;

    void visitProfile() {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: title);
      Navigator.pushNamed(
        context,
        (title == myUsername)
            ? RouteGenerator.myProfileScreen
            : RouteGenerator.posterProfileScreen,
        arguments: (title == myUsername) ? null : args,
      );
    }

    void visitClub() {
      final ClubScreenArgs args = ClubScreenArgs(clubName);
      Navigator.pushNamed(context, RouteGenerator.clubScreen, arguments: args);
    }

    _clubNameRecognizer..onTap = visitClub;

    _usernameRecognizer..onTap = visitProfile;
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        leading: TextButton(
            onPressed: () {},
            child: Stack(children: <Widget>[
              GestureDetector(
                  onTap: visitClub,
                  child: ClubAvatar(
                      clubName: clubName,
                      radius: _deviceHeight * 0.055 / 2,
                      inEdit: false,
                      asset: null,
                      fontSize: 20)),
              Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                      onTap: visitProfile,
                      child: ChatProfileImage(
                          username: title,
                          factor: 0.025,
                          inEdit: false,
                          asset: null)))
            ])),
        title: OptimisedText(
            minWidth: _deviceWidth * 0.1,
            maxWidth: _deviceWidth * 0.84,
            minHeight: 50,
            maxHeight: 50,
            fit: BoxFit.scaleDown,
            child: TextButton(
                onPressed: () {},
                style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                        recognizer: _clubNameRecognizer,
                        text: clubName,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0))))),
        subtitle: OptimisedText(
            minWidth: _deviceWidth * 0.1,
            maxWidth: _deviceWidth * 0.84,
            minHeight: 50,
            maxHeight: 50,
            fit: BoxFit.scaleDown,
            child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                    recognizer: _usernameRecognizer,
                    text: title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 18.0)))),
        trailing: PopupMenuButton(
            tooltip: lang.screens_profile,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            padding: const EdgeInsets.all(0.0),
            child: const Icon(Icons.more_vert, color: Colors.grey),
            itemBuilder: (_) => [
                  PopupMenuItem(
                      padding: const EdgeInsets.all(0.0),
                      enabled: true,
                      child: MyPopUpMenuButton(
                          id: postId,
                          postID: postId,
                          clubName: clubName,
                          prohibitClub: () {},
                          isInProfile: false,
                          isInClubScreen: false,
                          isClubPost: isClubPost,
                          isProhibited: false,
                          isBanned: false,
                          isMod: isMod,
                          isFav: context.read<FullHelper>().isFav,
                          helperFav: helper.fav,
                          postedByMe:
                              title == context.read<MyProfile>().getUsername,
                          postTopics: postTopics,
                          postMedia: postImgUrls,
                          postDate: postedDate,
                          isBlocked: false,
                          isLinkedToMe: false,
                          block: () {},
                          unblock: () {},
                          remove: () {},
                          banUser: () {},
                          unbanUser: () {},
                          hidePost: helperHide,
                          deletePost: helperDelete,
                          unhidePost: helperUnhide,
                          previewSetstate: widget.previewSetstate,
                          isInFlareProfile: false,
                          flareProfileID: ''))
                ]));
  }
}
