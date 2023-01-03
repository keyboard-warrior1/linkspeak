import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/myProfileProvider.dart';
import '../providers/profileScrollProvider.dart';
import '../providers/themeModel.dart';
import '../widgets/common/myFab.dart';
import '../widgets/common/noglow.dart';
import '../widgets/profile/myProfileBanner.dart';
import '../widgets/profile/profile.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen();
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  ScrollController? scrollController;
  void Function() disposeController = () {};
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final scrollProvider = ProfileScrollProvider();
  Future<void>? _refreshProfile;
  Future<void> refreshProfile(
      String myUsername, dynamic initializeMyProfile) async {
    final getProfile =
        await firestore.collection('Users').doc('$myUsername').get();
    final mySpotlight =
        await firestore.collection('Flares').doc('$myUsername').get();
    final spotlightExists = mySpotlight.exists;
    dynamic getter(String field) {
      return getProfile.get(field);
    }

    final visbility = getter('Visibility');
    String bannerUrl = 'None';
    if (getProfile.data()!.containsKey('Banner')) {
      final currentBanner = getter('Banner');
      bannerUrl = currentBanner;
    }
    String additionalWebsite = '';
    String additionalEmail = '';
    String additionalNumber = '';
    dynamic additionalAddress = '';
    String additionalAddressName = '';
    if (getProfile.data()!.containsKey('additionalWebsite')) {
      final actualWebsite = getter('additionalWebsite');
      additionalWebsite = actualWebsite;
    }
    if (getProfile.data()!.containsKey('additionalEmail')) {
      final actualEmail = getter('additionalEmail');
      additionalEmail = actualEmail;
    }
    if (getProfile.data()!.containsKey('additionalNumber')) {
      final actualNumber = getter('additionalNumber');
      additionalNumber = actualNumber;
    }
    if (getProfile.data()!.containsKey('additionalAddress')) {
      final actualAddress = getter('additionalAddress');
      additionalAddress = actualAddress;
    }
    if (getProfile.data()!.containsKey('additionalAddressName')) {
      final actualAddressName = getter('additionalAddressName');
      additionalAddressName = actualAddressName;
    }
    final username = getter('Username');
    final email = getter('Email');
    final imgUrl = getter('Avatar');
    final bio = getter('Bio');
    final serverTopics = getter('Topics') as List;
    final int numOfLinks = getter('numOfLinks');
    final int numOfLinked = getter('numOfLinked');
    final int numOfPosts = getter('numOfPosts');
    final int numOfNewLinksNotifs = getter('numOfNewLinksNotifs');
    final int numOfNewLinkedNotifs = getter('numOfNewLinkedNotifs');
    final int numOfLinkRequestsNotifs = getter('numOfLinkRequestsNotifs');
    final int numOfPostLikesNotifs = getter('numOfPostLikesNotifs');
    final int numOfPostCommentsNotifs = getter('numOfPostCommentsNotifs');
    final int numOfCommentRepliesNotifs = getter('numOfCommentRepliesNotifs');
    final int numOfPostsRemoved = getter('PostsRemoved');
    final int numOfCommentsRemoved = getter('CommentsRemoved');
    final int numOfRepliesRemoved = getter('repliesRemoved');
    final int numOfBlocked = getter('numOfBlocked');
    final int joinedClubs = getter('joinedClubs');
    final int numOfMentions = getter('numOfMentions');
    final List<String> myTopics =
        serverTopics.map((topic) => topic as String).toList();
    initializeMyProfile(
        joinedClubs: joinedClubs,
        visbility: visbility,
        additionalWebsite: additionalWebsite,
        additionalEmail: additionalEmail,
        additionalNumber: additionalNumber,
        additionalAddress: additionalAddress,
        additionalAddressName: additionalAddressName,
        hasSpotlight: spotlightExists,
        imgUrl: imgUrl,
        bannerUrl: bannerUrl,
        email: email,
        username: username,
        bio: bio,
        myTopics: myTopics,
        numOfLinks: numOfLinks,
        numOfLinked: numOfLinked,
        numOfPosts: numOfPosts,
        numOfMentions: numOfMentions,
        numOfNewLinksNotifs: numOfNewLinksNotifs,
        numOfNewLinkedNotifs: numOfNewLinkedNotifs,
        numOfLinkRequestsNotifs: numOfLinkRequestsNotifs,
        numOfPostLikesNotifs: numOfPostLikesNotifs,
        numOfPostCommentsNotifs: numOfPostCommentsNotifs,
        numOfCommentRepliesNotifs: numOfCommentRepliesNotifs,
        numOfPostsRemoved: numOfPostsRemoved,
        numOfCommentsRemoved: numOfCommentsRemoved,
        numOfRepliesRemoved: numOfRepliesRemoved,
        numOfBlocked: numOfBlocked);
  }

  @override
  void dispose() {
    super.dispose();
    disposeController();
  }

  @override
  Widget build(BuildContext context) {
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final dynamic initProfile =
        Provider.of<MyProfile>(context, listen: false).initializeMyProfile;
    Future<void> _pullRefresh() async {
      setState(() {
        _refreshProfile = refreshProfile(myUsername, initProfile);
      });
    }

    return Directionality(
        textDirection: Provider.of<ThemeModel>(context).textDirection,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: null,
            extendBodyBehindAppBar: true,
            body: SafeArea(
                child: FutureBuilder(
                    future: _refreshProfile,
                    builder: (context, snapshot) {
                      return ChangeNotifierProvider.value(
                          value: scrollProvider,
                          child: Builder(builder: (context) {
                            disposeController =
                                Provider.of<ProfileScrollProvider>(context,
                                        listen: false)
                                    .disposeProfileScrollController;
                            scrollController =
                                Provider.of<ProfileScrollProvider>(context,
                                        listen: false)
                                    .profileScrollController;
                            return Stack(children: <Widget>[
                              const MyProfileBanner(false),
                              Noglow(
                                  child: RefreshIndicator(
                                      backgroundColor: _primaryColor,
                                      displacement: 2.0,
                                      color: _accentColor,
                                      onRefresh: _pullRefresh,
                                      child: ListView(
                                          controller: scrollController,
                                          children: <Widget>[
                                            SizedBox(
                                                height: _deviceHeight * 0.12),
                                            const Profile(
                                                isMyProfile: true,
                                                rightButton: null,
                                                handler: null,
                                                instance: null)
                                          ]))),
                              if (selectedAnchorMode)
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: MyFab(scrollController!)))
                            ]);
                          }));
                    }))));
  }
}
