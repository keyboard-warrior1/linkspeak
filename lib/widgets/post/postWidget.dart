import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../admin/screens/allPostsScreen.dart';
import '../../clubs/clubPostsTab.dart';
import '../../general.dart';
import '../../loading/postSkeleton.dart';
import '../../models/profile.dart';
import '../../models/screenArguments.dart';
import '../../models/boardPostItem.dart';
import '../../providers/adminPostsProvider.dart';
import '../../providers/clubProvider.dart';
import '../../providers/clubTabProvider.dart';
import '../../providers/favScreenScrollProvider.dart';
import '../../providers/feedProvider.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/likeScreenScrollProvider.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../../providers/placesScreenProvider.dart';
import '../../providers/profileScrollProvider.dart';
import '../../providers/themeModel.dart';
import '../../providers/topicScreenProvider.dart';
import '../../routes.dart';
import '../../screens/favoritePostsScreen.dart';
import '../../screens/feedScreen.dart';
import '../../screens/likedPostScreen.dart';
import '../../screens/placePostsScreen.dart';
import '../../screens/postScreen.dart';
import '../../screens/topicPostsScreen.dart';
import '../profile/postsTab.dart';
import 'descriptionPreview.dart';
import 'noMediaDescription.dart';
import 'postBackside.dart';
import 'postBaseline.dart';
import 'postWidgetButton.dart';
import 'postWidgetCarouselStamp.dart';
import 'postWidgetTitile.dart';
import 'previewCarousel.dart';
import 'sensitiveBanner.dart';
import 'boardPostWidget.dart';
import 'branchPostWidget.dart';
// import '../../my_flutter_app_icons.dart' as customIcons;

class PostWidget extends StatefulWidget {
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
  const PostWidget(
      {required this.isInFeed,
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
      required this.isInClubAdmin});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with AutomaticKeepAliveClientMixin {
  late final FlipCardController flipController;
  late Future<void> initPost;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final void Function(BuildContext, String, String, bool) feedsharePost =
      FeedScreen.sharePost;
  final void Function(BuildContext, String, String, bool) tabSharePost =
      PostsTab.sharePost;
  final void Function(BuildContext, String, String, bool) clubtabSharePost =
      ClubPosts.sharePost;
  final void Function(BuildContext, String, String, bool) favSharePost =
      FavPostScreen.sharePost;
  final void Function(BuildContext, String, String, bool) likedSharePost =
      LikedPostScreen.sharePost;
  final void Function(BuildContext, String, String, bool) topicSharePost =
      TopicPostsScreen.sharePost;
  final void Function(BuildContext, String, String, bool) placesSharePost =
      PlacePostsScreen.sharePost;
  final void Function(BuildContext, String, String, bool) adminSharePost =
      AllPostsScreen.sharePost;
  void _goToPost(
      final BuildContext context,
      final ViewMode view,
      FullHelper instance,
      dynamic previewSetstate,
      String clubName,
      String postID) {
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

  ScrollController giveController(
      bool isInFeed,
      bool isInLike,
      bool isInFav,
      bool isInTab,
      bool isInPeopleTopics,
      bool isInClubTopics,
      bool isMyTab,
      bool isOtherTab,
      bool isInClubPosts,
      bool isInFavClubs,
      bool isInLikedClubs,
      bool isInClubFeed,
      bool isInPeoplePlaces,
      bool isInClubPlaces,
      bool isInPeopleAdmin,
      bool isInClubAdmin) {
    if (isInFeed && !isInClubFeed) {
      return FeedScreen.scrollController;
    }
    if (isInClubFeed) {
      return FeedScreen.clubScrollController;
    }
    if (isInTab && isMyTab) {
      return Provider.of<ProfileScrollProvider>(context, listen: false)
          .postsScrollController;
    }
    if (isInLike) {
      return Provider.of<LikeScreenScrollProvider>(context, listen: false)
          .likedUserScrollController;
    }
    if (isInLikedClubs) {
      return Provider.of<LikeScreenScrollProvider>(context, listen: false)
          .likedClubScrollController;
    }
    if (isInFav) {
      return Provider.of<FavScreenScrollProvider>(context, listen: false)
          .favUserScrollController;
    }
    if (isInFavClubs) {
      return Provider.of<FavScreenScrollProvider>(context, listen: false)
          .favClubScrollController;
    }
    if (isInTab && isOtherTab) {
      return Provider.of<OtherProfile>(context, listen: false)
          .getProfilePostsScrollController;
    }
    if (isInTab && isInClubPosts) {
      return Provider.of<ClubProvider>(context, listen: false)
          .getClubPostsScrollController;
    }
    if (isInPeopleTopics) {
      return Provider.of<TopicScreenProvider>(context, listen: false)
          .getScrollController;
    }
    if (isInClubTopics) {
      return Provider.of<TopicScreenProvider>(context, listen: false)
          .getClubController;
    }
    if (isInPeoplePlaces) {
      return Provider.of<PlacesScreenProvider>(context, listen: false)
          .getScrollController;
    }
    if (isInClubPlaces) {
      return Provider.of<PlacesScreenProvider>(context, listen: false)
          .getClubController;
    }
    if (isInPeopleAdmin) {
      return Provider.of<AdminPostsProvider>(context, listen: false)
          .userScrollController;
    }
    if (isInClubAdmin) {
      return Provider.of<AdminPostsProvider>(context, listen: false)
          .clubScrollController;
    }
    return FeedScreen.scrollController;
  }

  void Function(BuildContext, String, String, bool) giveShare(
      bool isInFeed,
      bool isInLike,
      bool isInFav,
      bool isInTab,
      bool isInPeopleTopic,
      bool isInClubTopics,
      bool isInClub,
      bool isInPeoplePlaces,
      bool isInClubPlaces,
      bool isInPeopleAdmin,
      bool isInClubAdmin) {
    if (isInFeed) {
      return feedsharePost;
    }
    if (isInTab && !isInClub) {
      return tabSharePost;
    }
    if (isInTab && isInClub) {
      return clubtabSharePost;
    }
    if (isInLike) {
      return likedSharePost;
    }
    if (isInFav) {
      return favSharePost;
    }
    if (isInPeopleTopic || isInClubTopics) {
      return topicSharePost;
    }
    if (isInPeoplePlaces || isInClubPlaces) {
      return placesSharePost;
    }
    if (isInPeopleAdmin || isInClubAdmin) {
      return adminSharePost;
    }
    return feedsharePost;
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
    return null;
  }

  TheVisibility generatePosterVis(String vis) {
    if (vis == 'Public') {
      return TheVisibility.public;
    } else if (vis == 'Private') {
      return TheVisibility.private;
    }
    return TheVisibility.private;
  }

  Future<void> _initPost(
      {required String myUsername,
      required String postID,
      required dynamic initializeThePost}) async {
    final postsCollection = firestore.collection('Posts');
    final getPost = await postsCollection.doc(postID).get();
    final bool postExists = getPost.exists;
    if (!postExists) {
      initializeThePost(
          paramUsername: '',
          paramclubName: '',
          paramdescription: '',
          parampostID: postID,
          paramVisibility: TheVisibility.public,
          paramClubVis: ClubVisibility.public,
          paramnumOfLikes: 0,
          paramnumOfComments: 0,
          paramnumOfTopics: 0,
          paramtopics: [],
          paramimgUrls: [],
          paramBoardPostItems: [],
          paramBoardPostBackground: Colors.blue,
          paramBoardPostGradient: Colors.yellow,
          parampostedDate: DateTime.now(),
          paramlocation: '',
          paramlocationName: '',
          paramsensitiveContent: false,
          paramisLiked: false,
          paramisFav: false,
          paramisHidden: false,
          paramisClubPost: false,
          paramisMod: false,
          paramBlocked: false,
          paramImBlocked: false,
          paramPosterBanned: false,
          paramClubBanned: false,
          paramClubDisabled: false,
          paramClubProhibited: false,
          paramIsClubMember: false,
          paramLinkedToPoster: false,
          paramExists: false,
          paramType: PostType.legacy);
    } else {
      ClubVisibility clubVis = ClubVisibility.public;
      bool isLiked = false;
      bool isFav = false;
      dynamic location = '';
      String locationName = '';
      String clubName = '';
      bool isClubPost = false;
      bool clubDisabled = false;
      bool clubProhibited = false;
      bool imClubBanned = false;
      bool isClubMember = false;
      bool isMod = false;
      PostType theType = PostType.legacy;
      List<BoardPostItem> paramBoardPostItems = [];
      Color paramBoardPostBackground = Colors.blue;
      Color paramBoardPostGradient = Colors.yellow;
      final clubsCollection = firestore.collection('Clubs');
      final usersCollection = firestore.collection('Users');
      final myUser = usersCollection.doc(myUsername);
      final myHidden = myUser.collection('HiddenPosts');
      final myBlocked = myUser.collection('Blocked');
      final myLinked = myUser.collection('Linked');
      final myFavUserPosts = myUser.collection('FavPosts');
      final myFavClubPosts = myUser.collection('Fav Club Posts');
      final myLikedUserPosts = myUser.collection('LikedPosts');
      final myLikedClubPosts = myUser.collection('Liked Club Posts');
      dynamic getter(String field) => getPost.get(field);
      final String poster = getter('poster');
      final getPoster = await usersCollection.doc(poster).get();
      final status = getPoster.get('Status');
      final getPosterVis = getPoster.get('Visibility');
      final posterVis = generatePosterVis(getPosterVis);
      final getIsHidden = await myHidden.doc(postID).get();
      final getMyBlocked = await usersCollection
          .doc(poster)
          .collection('Blocked')
          .doc(myUsername)
          .get();
      final getIsBlocked = await myBlocked.doc(poster).get();
      final linkedUser = await myLinked.doc(poster).get();
      final isBanned = status == 'Banned';
      final isHidden = getIsHidden.exists;
      final isBlocked = getIsBlocked.exists;
      final imBlocked = getMyBlocked.exists;
      final imLinked = linkedUser.exists;
      final actualClubName = getter('clubName');
      clubName = actualClubName;
      bool commentsDisabled = false;
      if (getPost.data()!.containsKey('commentsDisabled')) {
        final actualDisabled = getter('commentsDisabled');
        commentsDisabled = actualDisabled;
      }
      if (getPost.data()!.containsKey('location')) {
        final actualLocation = getter('location');
        location = actualLocation;
      }
      if (getPost.data()!.containsKey('locationName')) {
        final actualLocationName = getter('locationName');
        locationName = actualLocationName;
      }
      if (getPost.data()!.containsKey('type')) {
        final actualType = getter('type');
        final genType = General.generatePostType(actualType);
        theType = genType;
      }
      if (getPost.data()!.containsKey('items')) {
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
      if (getPost.data()!.containsKey('backgroundColor')) {
        final actualColor = getter('backgroundColor');
        if (actualColor != '') {
          Color _stateColor = Color(actualColor);
          paramBoardPostBackground = _stateColor;
        }
      }
      if (getPost.data()!.containsKey('gradientColor')) {
        final actualGradientColor = getter('gradientColor');
        if (actualGradientColor != '') {
          Color _stateGradientColor = Color(actualGradientColor);
          paramBoardPostGradient = _stateGradientColor;
        }
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
      if (actualClubName != '') {
        final thisClub = clubsCollection.doc(actualClubName);
        final getThisClub = await thisClub.get();
        final getClubDisability = getThisClub.get('isDisabled');
        final getClubProhibition = getThisClub.get('isProhibited');
        final getClubVis = getThisClub.get('Visibility');
        clubVis = General.convertClubVis(getClubVis);
        final thisClubMods = thisClub.collection('Moderators');
        final thisClubMembers = thisClub.collection('Members');
        final thisClubBanned = thisClub.collection('Banned');
        final getLiked = await myLikedClubPosts.doc(postID).get();
        final getFav = await myFavClubPosts.doc(postID).get();
        isLiked = getLiked.exists;
        isFav = getFav.exists;
        isClubPost = true;
        final getIsMod = await thisClubMods.doc(myUsername).get();
        final getIsMember = await thisClubMembers.doc(myUsername).get();
        final getIsBanned = await thisClubBanned.doc(myUsername).get();
        isMod = getIsMod.exists;
        isClubMember = getIsMember.exists;
        imClubBanned = getIsBanned.exists;
        clubDisabled = getClubDisability;
        clubProhibited = getClubProhibition;
      } else {
        final getLiked = await myLikedUserPosts.doc(postID).get();
        final getFav = await myFavUserPosts.doc(postID).get();
        isLiked = getLiked.exists;
        isFav = getFav.exists;
        isClubPost = false;
      }
      initializeThePost(
          paramUsername: poster,
          paramclubName: clubName,
          paramdescription: description,
          parampostID: postID,
          paramnumOfLikes: numOfLikes,
          paramnumOfComments: numOfComments,
          paramnumOfTopics: numOfTopics,
          paramtopics: postTopics,
          paramimgUrls: imgUrls,
          parampostedDate: serverpostedDate,
          paramlocation: location,
          paramlocationName: locationName,
          paramsensitiveContent: sensitiveContent,
          paramCommentsDisabled: commentsDisabled,
          paramisLiked: isLiked,
          paramisFav: isFav,
          paramisMod: isMod,
          paramisClubPost: isClubPost,
          paramisHidden: isHidden,
          paramBlocked: isBlocked,
          paramImBlocked: imBlocked,
          paramPosterBanned: isBanned,
          paramClubBanned: imClubBanned,
          paramClubDisabled: clubDisabled,
          paramClubProhibited: clubProhibited,
          paramIsClubMember: isClubMember,
          paramLinkedToPoster: imLinked,
          paramExists: postExists,
          paramVisibility: posterVis,
          paramClubVis: clubVis,
          paramType: theType,
          paramBoardPostItems: paramBoardPostItems,
          paramBoardPostBackground: paramBoardPostBackground,
          paramBoardPostGradient: paramBoardPostGradient);
    }
  }

  @override
  void initState() {
    super.initState();
    flipController = FlipCardController();
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final postID = Provider.of<FullHelper>(context, listen: false).postId;
    final initializeThePost =
        Provider.of<FullHelper>(context, listen: false).initializeThisPost;
    initPost = _initPost(
        myUsername: myUsername,
        postID: postID,
        initializeThePost: initializeThePost);
    final Map<String, dynamic> profileDocData = {
      'shown posts': FieldValue.increment(1)
    };
    final Map<String, dynamic> profileShownData = {
      'postID': postID,
      'times': FieldValue.increment(1),
      'date': DateTime.now()
    };
    General.showItem(
        documentAddress: 'Posts/$postID',
        itemShownDocAddress: 'Posts/$postID/Shown To/$myUsername',
        profileShownDocAddress: 'Users/$myUsername/Shown Posts/$postID',
        profileAddress: 'Users/$myUsername',
        profileDocData: profileDocData,
        profileShownData: profileShownData);
    Map<String, dynamic> fields = {'shown posts': FieldValue.increment(1)};
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'shown posts',
        docID: '$postID',
        docFields: profileShownData);
  }

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    Color _accentColor = Theme.of(context).colorScheme.secondary;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final themeProvider = Provider.of<ThemeModel>(context, listen: false);
    final bool _selectedCensorMode = themeProvider.censorMode;
    super.build(context);
    return FutureBuilder(
        future: initPost,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const PostSkeleton();
          if (snapshot.hasError) {
            print(
                'ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ');
            print(snapshot.error);
            return const SizedBox(height: 0, width: 0);
          }

          return Builder(builder: (context) {
            final FullHelper helper =
                Provider.of<FullHelper>(context, listen: false);
            final ScrollController _giveControler = giveController(
                widget.isInFeed,
                widget.isInLike,
                widget.isInFav,
                widget.isInTab,
                widget.isInPeopleTopics,
                widget.isInClubTopics,
                widget.isInMyTab,
                widget.isInOtherTab,
                widget.isInClubPosts,
                widget.isInFavClubs,
                widget.isInLikedClubs,
                widget.isInClubFeed,
                widget.isInPeoplePlaces,
                widget.isInClubPlaces,
                widget.isInPeopleAdmin,
                widget.isInClubAdmin);
            final bool measuresGiven = helper.measuresGiven;
            final void Function() helperHide = helper.hidePost;
            final void Function() helperDelete = helper.deletePost;
            final void Function() helperUnhide = helper.unhidePost;
            final void Function() helperFav = helper.fav;
            final DateTime postedDate = helper.postedDate;
            final String postId = helper.postId;
            final String title = helper.title;
            final String clubName = helper.clubName;
            final String description = helper.decription;
            final List<String> postTopics = helper.postTopics;
            final dynamic postLocation = helper.getLocation;
            final List<String> postImgUrls = helper.postImgUrls;
            final String _myUsername =
                Provider.of<MyProfile>(context, listen: false).getUsername;
            final bool _noDescription = description.isEmpty;
            final bool _withDescription = description.isNotEmpty;
            final bool _noMedia = postImgUrls.isEmpty;
            final bool _withMedia = postImgUrls.isNotEmpty;
            final bool sensitiveContent = helper.sensitiveContent;
            final bool _showPost = helper.showPost;
            final List<String> _hiddenPosts =
                Provider.of<MyProfile>(context, listen: false).getHiddenPostIDs;
            final bool postHidden = _hiddenPosts.contains(postId);
            final _stamp = PostCarouselStamp(widget.isInOtherTab);
            if (widget.isInOtherTab) {
              _primaryColor = Provider.of<OtherProfile>(context, listen: false)
                  .getPrimaryColor;
              _accentColor = Provider.of<OtherProfile>(context, listen: false)
                  .getAccentColor;
            }
            final bool helperDeleted = helper.isDeleted;
            final bool helperHidden = helper.isHidden;
            final bool isMyPost = title == _myUsername;
            final bool isClubPost = helper.isClubPost;
            final isManagement = _myUsername.startsWith('Linkspeak');
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
            final PostType postType = helper.postType;
            final bool isBoard = postType == PostType.board;
            final bool isBranch = postType == PostType.branch;
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

            void previewSetStae() {
              setState(() {});
            }

            void _visitPost(ViewMode viewMode) {
              if (sensitiveContent &&
                  !_showPost &&
                  !isMyPost &&
                  _selectedCensorMode) {
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
                    previewSetStae,
                    clubName,
                    postId);
              }
            }

            final Widget _postBar = PostBar(
                postID: postId,
                shareView: false,
                shareButtonHandler: giveShare(
                    widget.isInFeed,
                    widget.isInLike,
                    widget.isInFav,
                    widget.isInTab,
                    widget.isInPeopleTopics,
                    widget.isInClubTopics,
                    widget.isInClubPosts,
                    widget.isInPeoplePlaces,
                    widget.isInClubTopics,
                    widget.isInPeopleAdmin,
                    widget.isInClubAdmin),
                isInFeed: true,
                upButtonHandler: () {},
                commentButtonHandler: () => _visitPost(ViewMode.comments),
                topicButtonHandler: () => _visitPost(ViewMode.topics),
                likeTextHandler: () => _visitPost(ViewMode.likes),
                upView: false,
                commentView: false,
                topicsView: false,
                isInOtherProfile: widget.isInOtherTab,
                isClubPost: isClubPost);
            final Widget _title = PostWidgetTitle(
                isInFav: widget.isInFav,
                isInLikedPosts: widget.isInLike,
                isInTab: widget.isInTab,
                inOtherProfile: widget.isInOtherTab,
                postId: postId,
                title: title,
                postTopics: postTopics,
                postMedia: postImgUrls,
                postDate: postedDate,
                hidePost: helperHide,
                deletePost: helperDelete,
                unhidePost: helperUnhide,
                helperFav: helperFav,
                previewSetstate: previewSetStae);
            return Container(
                key: UniqueKey(),
                // margin: EdgeInsets.symmetric(vertical: endgame ? 0 : 7.0),
                margin: EdgeInsets.symmetric(
                    vertical: endgame
                        ? 0
                        : isBoard
                            ? 0
                            : 3.50),
                child: isBoard
                    ? BoardPostWidget(
                        inPreview: true,
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
                        instance: null)
                    : isBranch
                        ? BranchPostWidget(
                            inPreview: true,
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
                            instance: null)
                        : FlipCard(
                            controller: flipController,
                            fill: Fill.fillBack,
                            direction: FlipDirection.VERTICAL,
                            flipOnTouch: false,
                            front: MeasuredSize(
                              onChange: (size) {
                                if ((postLocation != '' ||
                                        postTopics.isNotEmpty) &&
                                    !measuresGiven) {
                                  final double height = size.height;
                                  final double width = size.width;
                                  Provider.of<FullHelper>(context,
                                          listen: false)
                                      .giveOccupiedMeasures(height, width);
                                  Provider.of<FullHelper>(context,
                                          listen: false)
                                      .giveMeasure();
                                  setState(() {});
                                }
                              },
                              child: Bounce(
                                duration: const Duration(milliseconds: 100),
                                onPressed: () => _visitPost(ViewMode.post),
                                child: AnimatedContainer(
                                  height: endgame ? 0.0 : null,
                                  duration: const Duration(milliseconds: 0),
                                  width: postHidden ? double.infinity : 0.0,
                                  margin: EdgeInsets.symmetric(
                                    vertical: !postHidden ||
                                            !helperHidden ||
                                            !helperDeleted
                                        // ? 1.0
                                        ? 0.50
                                        : 0.0,
                                    horizontal: !postHidden ||
                                            !helperHidden ||
                                            !helperDeleted
                                        // ? 7.0
                                        ? 3.50
                                        : 0.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9.0),
                                    child: Card(
                                      borderOnForeground: false,
                                      margin: const EdgeInsets.all(0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          _title,
                                          const SizedBox(height: 3.0),
                                          Stack(
                                            children: <Widget>[
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  if (_withDescription &&
                                                      _withMedia)
                                                    Flexible(
                                                      fit: FlexFit.loose,
                                                      child: DescriptionPreview(
                                                        description,
                                                        _giveControler,
                                                        widget.isInFeed,
                                                        widget.isInClubFeed,
                                                      ),
                                                    ),
                                                  if (_withDescription &&
                                                      _noMedia)
                                                    Flexible(
                                                      fit: FlexFit.loose,
                                                      child:
                                                          NoMediaPostDescriptionPreview(
                                                        description,
                                                        _giveControler,
                                                        widget.isInFeed,
                                                        widget.isInClubFeed,
                                                      ),
                                                    ),
                                                  if (_withDescription &&
                                                      _noMedia)
                                                    PostWidgetButton(
                                                        flipController
                                                            .toggleCard,
                                                        widget.isInOtherTab),
                                                  if (_withDescription &&
                                                      _withMedia)
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        minHeight:
                                                            _deviceHeight *
                                                                0.50,
                                                        maxHeight:
                                                            _deviceHeight *
                                                                0.50,
                                                      ),
                                                      child: Stack(
                                                        children: <Widget>[
                                                          const PostWidgetCarousel(),
                                                          Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: _stamp,
                                                          ),
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
                                                                  color: _primaryColor
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
                                                                  // customIcons.MyFlutterApp
                                                                  // .brochure,
                                                                  Icons
                                                                      .view_carousel_rounded,
                                                                  color:
                                                                      _accentColor,
                                                                  size: 35.0,
                                                                ),
                                                              ),
                                                            ),
                                                          Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: PostWidgetButton(
                                                                  flipController
                                                                      .toggleCard,
                                                                  widget
                                                                      .isInOtherTab)),
                                                        ],
                                                      ),
                                                    ),
                                                  if (_noDescription &&
                                                      _withMedia)
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        minHeight:
                                                            _deviceHeight *
                                                                0.52,
                                                        maxHeight:
                                                            _deviceHeight *
                                                                0.52,
                                                      ),
                                                      child: Stack(
                                                        children: <Widget>[
                                                          const PostWidgetCarousel(),
                                                          Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: _stamp,
                                                          ),
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
                                                                  color: _primaryColor
                                                                      .withOpacity(
                                                                          0.5),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            15.0),
                                                                  ),
                                                                ),
                                                                child: Icon(
                                                                  // customIcons.MyFlutterApp
                                                                  // .brochure,
                                                                  Icons
                                                                      .view_carousel_rounded,
                                                                  color:
                                                                      _accentColor,
                                                                  size: 35.0,
                                                                ),
                                                              ),
                                                            ),
                                                          Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: PostWidgetButton(
                                                                  flipController
                                                                      .toggleCard,
                                                                  widget
                                                                      .isInOtherTab)),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              if (_selectedCensorMode)
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
                                controller: _giveControler,
                                isInOtherProfile: widget.isInOtherTab,
                                isInFeed: widget.isInFeed,
                                isInClubFeed: widget.isInClubFeed)));
          });
        });
  }

  @override
  bool get wantKeepAlive => true;
}
