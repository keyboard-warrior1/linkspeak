// ignore_for_file: unused_field
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/profileSkeleton.dart';
import '../models/profile.dart';
import '../models/profiler.dart';
import '../my_flutter_app_icons.dart' as customIcon;
import '../providers/myProfileProvider.dart';
import '../providers/otherProfileProvider.dart';
import '../providers/themeModel.dart';
import '../widgets/common/myFab.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/popUpMenuButton.dart';
import '../widgets/profile/otherProfileBanner.dart';
import '../widgets/profile/profile.dart' as profWidget;
import '../widgets/profile/profileSensitiveBanner.dart';

class OtherProfileScreen extends StatefulWidget {
  final dynamic userID;

  const OtherProfileScreen({required this.userID});

  @override
  _OtherProfileScreenState createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController? scrollController;
  void Function() disposeScrollController = () {};
  String sessionID = '';
  String myName = '';
  late Profiler profile;
  late Future<void> _getProfile;
  late Future<void> _initSession;
  late Future<void> _endSession;

  @override
  void initState() {
    super.initState();
    final ThemeModel theme = Provider.of<ThemeModel>(context, listen: false);
    final Color _primarySwatch = theme.primary;
    final Color _accentColor = theme.accent;
    final Color _likeColor = theme.likeColor;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    myName = _myUsername;
    _initSession = initSession(_myUsername);
    _getProfile =
        getProfile(_myUsername, _primarySwatch, _accentColor, _likeColor);
  }

  @override
  void dispose() {
    super.dispose();
    disposeScrollController();
    _endSession = endSession(myName);
  }

  Widget buildErrorWidget(String _myUsername, Color _primarySwatch,
      Color _accentColor, Color selectedLikeColor) {
    final lang = General.language(context);
    return SafeArea(
        child: Container(
            color: Colors.white,
            child: Stack(fit: StackFit.expand, children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(lang.clubs_members2,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17.0)),
                          const SizedBox(width: 10.0),
                          Container(
                              width: 100.0,
                              padding: const EdgeInsets.all(5.0),
                              child: TextButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry?>(
                                          const EdgeInsets.symmetric(
                                              vertical: 1.0, horizontal: 5.0)),
                                      enableFeedback: false,
                                      backgroundColor:
                                          MaterialStateProperty.all<Color?>(
                                              _primarySwatch)),
                                  onPressed: () {
                                    setState(() {
                                      _getProfile = getProfile(
                                          _myUsername,
                                          _primarySwatch,
                                          _accentColor,
                                          selectedLikeColor);
                                    });
                                  },
                                  child: Text(lang.clubs_members3,
                                      style: TextStyle(
                                          fontSize: 19.0,
                                          color: _accentColor))))
                        ])
                  ]),
              Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(width: 20.0),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            splashColor: Colors.transparent,
                            icon: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(color: Colors.black)),
                                child: const Icon(
                                    customIcon.MyFlutterApp.curve_arrow,
                                    color: Colors.black)))
                      ]))
            ])));
  }

  Future<void> initSession(String myUsername) async {
    final checkExists = await General.checkExists('Users/${widget.userID}');
    if (checkExists) {
      var batch = firestore.batch();
      final _rightNow = DateTime.now();
      final _sessionID = _rightNow.toString();
      sessionID = _sessionID;
      final usersCollection = firestore.collection('Users');
      final thisUser = usersCollection.doc(widget.userID);
      final sessions = thisUser.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final hasSession = mySession.exists;
      if (!hasSession) {
        final options = SetOptions(merge: true);
        batch.set(sessions.doc(myUsername), {'start': _rightNow}, options);
        batch.set(thisUser, {'sessions': FieldValue.increment(1)}, options);
      }
      return batch.commit();
    }
  }

  Future<void> endSession(String myUsername) async {
    final checkExists = await General.checkExists('Users/${widget.userID}');
    if (checkExists) {
      final _rightNow = DateTime.now();
      var batch = firestore.batch();
      final options = SetOptions(merge: true);
      final usersCollection = firestore.collection('Users');
      final thisUser = usersCollection.doc(widget.userID);
      final userViewers = thisUser.collection('Viewers');
      final myUserSessions = userViewers.doc(myUsername).collection('Sessions');
      final thisSession = await myUserSessions.doc(sessionID).get();
      final thisSessionExists = thisSession.exists;
      final sessions = thisUser.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final hasSession = mySession.exists;
      if (hasSession) {
        batch.delete(sessions.doc(myUsername));
        batch.set(thisUser, {'sessions': FieldValue.increment(-1)}, options);
      }
      if (thisSessionExists) {
        batch.set(myUserSessions.doc(sessionID), {'end': _rightNow}, options);
      }
      return batch.commit();
    }
  }

  Future<void> getProfile(String _myUsername, Color themePrimaryColor,
      Color themeAccentColor, Color themeLikeColor) async {
    final _rightNow = DateTime.now();
    final myViewedProfiles = firestore
        .collection('Users')
        .doc(_myUsername)
        .collection('Viewed Profiles');
    final profileViewers =
        firestore.collection('Users').doc(widget.userID).collection('Viewers');
    var batch = firestore.batch();
    batch.set(myViewedProfiles.doc(), {
      'ID': widget.userID,
      'date': _rightNow,
    });
    batch.set(profileViewers.doc(), {
      'ID': _myUsername,
      'date': _rightNow,
    });
    final _theUser = firestore.collection('Users').doc(widget.userID);
    final _theFlarer = firestore.collection('Flares').doc(widget.userID);
    final _thisUser = await _theUser.get();
    if (_thisUser.exists) {
      Map<String, dynamic> fields = {
        'viewed profiles': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'user': widget.userID,
        'date': _rightNow,
        'times': FieldValue.increment(1)
      };
      General.updateControl(
          fields: fields,
          myUsername: _myUsername,
          collectionName: 'viewed profiles',
          docID: widget.userID,
          docFields: docFields);
      await batch.commit();
      final userLinks =
          await _theUser.collection('Links').doc(_myUsername).get();
      final userSpotlight = await _theFlarer.get();
      final hasSpotlight = userSpotlight.exists;
      bool hasUnseenCollection = false;
      if (hasSpotlight) {
        if (userSpotlight.data()!.containsKey('currentlyShowcasing')) {
          final name = userSpotlight.get('currentlyShowcasing');
          final currentlyShowcasing = await _theFlarer
              .collection('collections')
              .where('title', isEqualTo: name)
              .get();
          final docs = currentlyShowcasing.docs;
          if (docs.isNotEmpty) {
            final theDoc = docs[0];
            final myView = await _theFlarer
                .collection('collections')
                .doc(theDoc.id)
                .collection('Viewers')
                .doc(_myUsername)
                .get();
            final isSeen = myView.exists;
            hasUnseenCollection = !isSeen;
          }
        }
      }
      final userBlocks =
          await _theUser.collection('Blocked').doc(_myUsername).get();
      final userRequests = await _theUser
          .collection('LinkRequestsNotifs')
          .doc(_myUsername)
          .get();
      final myLinks = await firestore
          .collection('Users')
          .doc(_myUsername)
          .collection('Links')
          .doc(widget.userID)
          .get();
      final myBlocked = await firestore
          .collection('Users')
          .doc(_myUsername)
          .collection('Blocked')
          .doc(widget.userID)
          .get();
      final imLinkedToThem = userLinks.exists;
      final imBlocked = userBlocks.exists;
      final requestSent = userRequests.exists;
      final isLinked = myLinks.exists;
      final isBlocked = myBlocked.exists;
      getter(String field) => _thisUser.get(field);
      final String activity = getter('Activity');
      final String serverVis = getter('Visibility');
      final TheVisibility vis = General.convertProfileVis(serverVis);
      final String username = getter('Username');
      final String imgUrl = getter('Avatar');
      String bannerUrl = 'None';
      bool bannerNSFW = false;
      bool showColors = true;
      String additionalWebsite = '';
      String additionalEmail = '';
      String additionalNumber = '';
      dynamic additionalAddress = '';
      String additionalAddressName = '';
      Color otherPrimaryColor = themePrimaryColor;
      Color otherAccentColor = themeAccentColor;
      Color otherLikeColor = themeLikeColor;
      if (_thisUser.data()!.containsKey('Banner')) {
        final actualBanner = getter('Banner');
        bannerUrl = actualBanner;
      }
      if (_thisUser.data()!.containsKey('bannerNSFW')) {
        final actualNSFW = getter('bannerNSFW');
        bannerNSFW = actualNSFW;
      }
      if (_thisUser.data()!.containsKey('additionalWebsite')) {
        final actualWebsite = getter('additionalWebsite');
        additionalWebsite = actualWebsite;
      }
      if (_thisUser.data()!.containsKey('additionalEmail')) {
        final actualEmail = getter('additionalEmail');
        additionalEmail = actualEmail;
      }
      if (_thisUser.data()!.containsKey('additionalNumber')) {
        final actualNumber = getter('additionalNumber');
        additionalNumber = actualNumber;
      }
      if (_thisUser.data()!.containsKey('additionalAddress')) {
        final actualAddress = getter('additionalAddress');
        additionalAddress = actualAddress;
      }
      if (_thisUser.data()!.containsKey('additionalAddressName')) {
        final actualAddressName = getter('additionalAddressName');
        additionalAddressName = actualAddressName;
      }
      if (_thisUser.data()!.containsKey('showColors')) {
        final actualPreference = getter('showColors');
        showColors = actualPreference;
      }
      if (_thisUser.data()!.containsKey('PrimaryColor')) {
        final actualPrimary = getter('PrimaryColor');
        if (showColors) otherPrimaryColor = Color(actualPrimary);
      }
      if (_thisUser.data()!.containsKey('AccentColor')) {
        final actualAccent = getter('AccentColor');
        if (showColors) otherAccentColor = Color(actualAccent);
      }
      if (_thisUser.data()!.containsKey('LikeColor')) {
        final actualLike = getter('LikeColor');
        if (showColors) otherLikeColor = Color(actualLike);
      }
      final String bio = getter('Bio');
      final int numOfLinks = getter('numOfLinks');
      final int numOfLinkedTo = getter('numOfLinked');
      final int numOfPosts = getter('numOfPosts');
      final int joinedClubs = getter('joinedClubs');
      final String status = getter('Status');
      final serverTopics = getter('Topics') as List;
      final List<String> topics =
          serverTopics.map((topic) => topic as String).toList();
      final OtherProfile instance = OtherProfile();
      profile = Profiler(
        imLinkedtoThem: imLinkedToThem,
        isBlocked: isBlocked,
        imBlocked: imBlocked,
        linkedToMe: isLinked,
        status: status,
        linkRequestSent: requestSent,
        otherProfileProvider: instance,
        visibility: vis,
        username: username,
        additionalWebsite: additionalWebsite,
        additionalEmail: additionalEmail,
        additionalNumber: additionalNumber,
        additionalAddress: additionalAddress,
        additionalAddressName: additionalAddressName,
        imgUrl: imgUrl,
        bannerUrl: bannerUrl,
        bannerNSFW: bannerNSFW,
        hasSpotlight: hasSpotlight,
        hasUnseenCollection: hasUnseenCollection,
        bio: bio,
        numOfLinks: numOfLinks,
        numOfLinkedTo: numOfLinkedTo,
        numOfPosts: numOfPosts,
        joinedClubs: joinedClubs,
        topics: topics,
        posts: [],
        activityStatus: activity,
        primaryColor: otherPrimaryColor,
        accentColor: otherAccentColor,
        likeColor: otherLikeColor,
      );
    } else {
      _thisUser.get('dfijwefiu');
    }
  }

  Future<void> _pullRefresh(String myUsername, Color primarySwatch,
      Color accentColor, Color likeColor) async {
    setState(() {
      _getProfile =
          getProfile(myUsername, primarySwatch, accentColor, likeColor);
    });
  }

  Widget build(BuildContext context) {
    final ThemeModel theme = Provider.of<ThemeModel>(context);
    final bool selectedAnchorMode = theme.anchorMode;
    final bool selectedCensorMode = theme.censorMode;
    final Color selectedLikeColor = theme.likeColor;
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final lang = General.language(context);
    return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: null,
        extendBodyBehindAppBar: true,
        body: FutureBuilder(
            future: _getProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return SafeArea(
                    child: Container(
                        color: Colors.transparent,
                        child: const ProfileLoading()));

              if (snapshot.hasError)
                return buildErrorWidget(_myUsername, _primarySwatch,
                    _accentColor, selectedLikeColor);

              return SafeArea(
                  child: ChangeNotifierProvider.value(
                      value: profile.otherProfileProvider,
                      child: Builder(builder: (context) {
                        final OtherProfile profileNo =
                            Provider.of<OtherProfile>(context, listen: false);
                        profileNo.setter(
                            additionalWebsite: profile.additionalWebsite,
                            additionalEmail: profile.additionalEmail,
                            additionalNumber: profile.additionalNumber,
                            additionalAddress: profile.additionalAddress,
                            additionalAddressName:
                                profile.additionalAddressName,
                            hasSpotlight: profile.hasSpotlight,
                            doesHaveUnseen: profile.hasUnseenCollection,
                            linkedToThem: profile.imLinkedtoThem,
                            linkedTOMe: profile.linkedToMe,
                            imBlocked: profile.imBlocked,
                            isBlocked: profile.isBlocked,
                            requestSent: profile.linkRequestSent,
                            vis: profile.visibility,
                            imgUrl: profile.imgUrl,
                            bannerUrl: profile.bannerUrl,
                            bannerNSFW: profile.bannerNSFW,
                            username: profile.username,
                            bio: profile.bio,
                            numOfLinks: profile.numOfLinks,
                            numOfLinked: profile.numOfLinkedTo,
                            joinedClubs: profile.joinedClubs,
                            topics: profile.topics,
                            numOfPosts: profile.numOfPosts,
                            postIDs: profile.posts,
                            activity: profile.activityStatus,
                            primaryColor: profile.primaryColor,
                            accentColor: profile.accentColor,
                            likeColor: profile.likeColor,
                            status: profile.status);
                        return Builder(builder: (context) {
                          final OtherProfile _profile =
                              Provider.of<OtherProfile>(context);
                          final OtherProfile _profileNoListen =
                              Provider.of<OtherProfile>(context, listen: false);
                          scrollController =
                              _profileNoListen.getProfileScrollController;
                          disposeScrollController =
                              _profileNoListen.disposeProfileController;
                          final block = _profileNoListen.block;
                          final unblock = _profileNoListen.unblock;
                          final ban = _profileNoListen.ban;
                          final unban = _profileNoListen.unban;
                          final remove = _profileNoListen.removeThem;
                          final isBlocked = _profile.isBlocked;
                          final isBanned = _profile.isBanned;
                          final isLinkedToMe = _profile.linkedToMe;
                          final dynamic _rightButton = Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Transform.rotate(
                                  angle: 90 * pi / 180,
                                  child: PopupMenuButton(
                                      tooltip: lang.screens_profile,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      padding: const EdgeInsets.all(0.0),
                                      child: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                        size: 31.0,
                                      ),
                                      itemBuilder: (_) => [
                                            PopupMenuItem(
                                                padding:
                                                    const EdgeInsets.all(0.0),
                                                enabled: true,
                                                child: MyPopUpMenuButton(
                                                    id: widget.userID,
                                                    postID: '',
                                                    clubName: '',
                                                    isInFlareProfile: false,
                                                    flareProfileID: '',
                                                    isMod: false,
                                                    isInProfile: true,
                                                    isInClubScreen: false,
                                                    isFav: false,
                                                    helperFav: () {},
                                                    postedByMe: false,
                                                    isClubPost: false,
                                                    isProhibited: false,
                                                    prohibitClub: () {},
                                                    postTopics: [],
                                                    postMedia: [],
                                                    postDate: DateTime.now(),
                                                    isBlocked: isBlocked,
                                                    isBanned: isBanned,
                                                    isLinkedToMe: isLinkedToMe,
                                                    block: block,
                                                    unblock: unblock,
                                                    banUser: ban,
                                                    unbanUser: unban,
                                                    remove: remove,
                                                    hidePost: () {},
                                                    deletePost: () {},
                                                    unhidePost: () {},
                                                    previewSetstate: () {}))
                                          ])));
                          final Widget theprofile = profWidget.Profile(
                              isMyProfile: false,
                              handler: null,
                              rightButton: _rightButton,
                              instance: profile.otherProfileProvider);
                          final bool bannerNSFW = _profile.getBannerNSFW;
                          final bool showBanner = _profile.getShowBanner;
                          return Stack(children: <Widget>[
                            const OtherProfileBanner(),
                            Noglow(
                                child: RefreshIndicator(
                                    backgroundColor: _profile.getPrimaryColor,
                                    displacement: 2.0,
                                    color: _profile.getAccentColor,
                                    onRefresh: () => _pullRefresh(
                                        _myUsername,
                                        _primarySwatch,
                                        _accentColor,
                                        selectedLikeColor),
                                    child: ListView(
                                        controller: scrollController,
                                        children: <Widget>[
                                          SizedBox(
                                              height: _deviceHeight * 0.12,
                                              child: (bannerNSFW &&
                                                      !showBanner &&
                                                      selectedCensorMode)
                                                  ? const ProfileSensitiveBanner()
                                                  : null),
                                          theprofile
                                        ]))),
                            if (selectedAnchorMode)
                              Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: MyFab(scrollController!, true)))
                          ]);
                        });
                      })));
            }));
  }
}
