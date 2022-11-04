// ignore_for_file: unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/clubSkeleton.dart';
import '../models/clubber.dart';
import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/clubProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/common/myFab.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/popUpMenuButton.dart';
import 'clubAvatar.dart';
import 'clubBanner.dart';
import 'clubJoinButton.dart';
import 'clubQRcode.dart';
import 'clubTabBar.dart';
import 'clubTabs.dart';

class ClubScreen extends StatefulWidget {
  final dynamic clubName;
  const ClubScreen(this.clubName);

  @override
  _ClubScreenState createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen>
    with SingleTickerProviderStateMixin {
  ScrollController? scrollController;
  void Function() disposeScrollController = () {};
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String sessionID = '';
  String myName = '';
  late Future<void> _viewClub;
  late Future<void> _initSession;
  late Future<void> _endSession;
  late Future<void> _getClub;
  late Clubber clubber;
  late final TabController _controller;
  _handleTabSelection() {
    if (_controller.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> initSession(String myUsername, String club) async {
    final checkExists = await General.checkExists('Clubs/$club');
    if (checkExists) {
      var batch = firestore.batch();
      final _rightNow = DateTime.now();
      final clubsCollection = firestore.collection('Clubs');
      final thisClub = clubsCollection.doc(club);
      final sessions = thisClub.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final hasSession = mySession.exists;
      if (!hasSession) {
        final options = SetOptions(merge: true);
        batch.set(sessions.doc(myUsername), {'start': _rightNow}, options);
        batch.set(thisClub, {'sessions': FieldValue.increment(1)}, options);
      }
      return batch.commit();
    }
  }

  Future<void> viewClub(String myUsername, String club) async {
    final checkExists = await General.checkExists('Clubs/$club');
    if (checkExists) {
      var batch = firestore.batch();
      final _rightNow = DateTime.now();
      final _sessionID = _rightNow.toString();
      sessionID = _sessionID;
      final usersCollection = firestore.collection('Users');
      final clubsCollection = firestore.collection('Clubs');
      final myUser = usersCollection.doc(myUsername);
      final myViewedClubs = myUser.collection('Viewed Clubs');
      final thisMyViewed = await myViewedClubs.doc(club).get();
      final alreadySeen = thisMyViewed.exists;
      final thisClub = clubsCollection.doc(club);
      final clubViewers = thisClub.collection('Viewers');
      final myViewerDoc = await clubViewers.doc(myUsername).get();
      final isViewed = myViewerDoc.exists;
      final initialdata = {
        'club': club,
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
        batch.set(myViewedClubs.doc(club), existingData, options);
      } else {
        batch.set(myViewedClubs.doc(club), initialdata, options);
        batch.set(myUser, {'seen clubs': FieldValue.increment(1)}, options);
      }
      if (isViewed) {
        batch.set(clubViewers.doc(myUsername), existingData, options);
        batch.set(
            clubViewers.doc(myUsername).collection('Sessions').doc(_sessionID),
            {'start': _rightNow},
            options);
      } else {
        batch.set(clubViewers.doc(myUsername), initialdata, options);
        batch.set(
            clubViewers.doc(myUsername).collection('Sessions').doc(_sessionID),
            {'start': _rightNow},
            options);
        batch.set(thisClub, {'viewers': FieldValue.increment(1)}, options);
      }
      Map<String, dynamic> fields = {'viewed clubs': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {
        'club': widget.clubName,
        'date': _rightNow,
        'times': FieldValue.increment(1)
      };
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'viewed clubs',
          docID: widget.clubName,
          docFields: docFields);
      return batch.commit();
    }
  }

  Future<void> endSession(String myUsername, String club) async {
    final checkExists = await General.checkExists('Clubs/$club');
    if (checkExists) {
      final _rightNow = DateTime.now();
      var batch = firestore.batch();
      final options = SetOptions(merge: true);
      final clubsCollection = firestore.collection('Clubs');
      final thisClub = clubsCollection.doc(club);
      final clubViewers = thisClub.collection('Viewers');
      final myClubSessions = clubViewers.doc(myUsername).collection('Sessions');
      final thisSession = await myClubSessions.doc(sessionID).get();
      final thisSessionExists = thisSession.exists;
      final sessions = thisClub.collection('Sessions');
      final mySession = await sessions.doc(myUsername).get();
      final hasSession = mySession.exists;
      if (hasSession) {
        batch.delete(sessions.doc(myUsername));
        batch.set(thisClub, {'sessions': FieldValue.increment(-1)}, options);
      }
      if (thisSessionExists) {
        batch.set(myClubSessions.doc(sessionID), {'end': _rightNow}, options);
      }
      return batch.commit();
    }
  }

  Future<void> getClub(String myUsername) async {
    final thisClub = firestore.collection('Clubs').doc(widget.clubName);
    final getClub = await thisClub.get();
    final myMember = await thisClub.collection('Members').doc(myUsername).get();
    final myBanned = await thisClub.collection('Banned').doc(myUsername).get();
    final myMod = await thisClub.collection('Moderators').doc(myUsername).get();
    final myRequest =
        await thisClub.collection('JoinRequests').doc(myUsername).get();
    bool isFounder = false;
    if (myMod.exists) {
      final actualFounder = myMod.get('isFounder');
      isFounder = actualFounder;
    }
    final bool isMod = myMod.exists;
    final bool isBanned = myBanned.exists;
    final bool isMember = myMember.exists;
    final bool isRequested = myRequest.exists;
    if (getClub.exists) {
      getter(String field) => getClub.get(field);
      final vis = getter('Visibility');
      final banner = getter('banner');
      final bannerNSFW = getter('bannerNSFW');
      final serverTopics = getter('topics') as List;
      final List<String> topics = serverTopics.map((e) => e as String).toList();
      final avatar = getter('Avatar');
      final clubName = getter('club name');
      final about = getter('about');
      final maxDailyPosts = getter('maxDailyPosts');
      final numOfPosts = getter('numOfPosts');
      final numOfJoinRequests = getter('numOfJoinRequests');
      final numOfNewMembers = getter('numOfNewMembers');
      final numOfMembers = getter('numOfMembers');
      final numOfBannedMembers = getter('numOfBannedMembers');
      final membersCanPost = getter('membersCanPost');
      final isDisabled = getter('isDisabled');
      final isProhibited = getter('isProhibited');
      final allowQuickJoin = getter('allowQuickJoin');
      final ClubVisibility visibility = General.convertClubVis(vis);
      final ClubProvider instance = ClubProvider();
      clubber = Clubber(
        clubName: clubName,
        clubAvatarURL: avatar,
        clubDescription: about,
        clubBannerUrl: banner,
        clubVisibility: visibility,
        numOfMembers: numOfMembers,
        numOfPosts: numOfPosts,
        numOfJoinRequests: numOfJoinRequests,
        numOfNewMembers: numOfNewMembers,
        maxDailyPostsByMembers: maxDailyPosts,
        numOfBannedMembers: numOfBannedMembers,
        isDisabled: isDisabled,
        isProhibited: isProhibited,
        memberCanPost: membersCanPost,
        bannerNSFW: bannerNSFW,
        isJoined: isMember,
        isRequested: isRequested,
        isMod: isMod,
        isBanned: isBanned,
        isFounder: isFounder,
        clubTopics: topics,
        instance: instance,
        allowQuickJoin: allowQuickJoin,
      );
    } else {
      return;
    }
  }

  Widget buildErrorWidget(Color _primaryColor, Color _accentColor,
      String myUsername, Widget title) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'An error has occured',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Container(
                      width: 100.0,
                      padding: const EdgeInsets.all(5.0),
                      child: TextButton(
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry?>(
                            const EdgeInsets.symmetric(
                              vertical: 1.0,
                              horizontal: 5.0,
                            ),
                          ),
                          enableFeedback: false,
                          backgroundColor:
                              MaterialStateProperty.all<Color?>(_primaryColor),
                        ),
                        onPressed: () {
                          setState(() {
                            _getClub = getClub(myUsername);
                          });
                        },
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 19.0,
                            color: _accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            title,
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    myName = myUsername;
    _getClub = getClub(myUsername);
    _viewClub = viewClub(myUsername, widget.clubName);
    _initSession = initSession(myUsername, widget.clubName);
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    super.dispose();
    _endSession = endSession(myName, widget.clubName);
    disposeScrollController();
    _controller.removeListener(() {});
    _controller.dispose();
  }

  Future<void> _pullRefresh(String myUsername) async {
    setState(() {
      _getClub = getClub(myUsername);
    });
  }

  Widget buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 10.0),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
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
                customIcons.MyFlutterApp.curve_arrow,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    const Widget _heightBox = SizedBox(height: 10.0);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final Widget title = buildBackButton();
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: null,
        extendBodyBehindAppBar: true,
        body: SafeArea(
            child: FutureBuilder(
                future: _getClub,
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ClubLoading();
                  }
                  if (snapshot.hasError) {
                    return buildErrorWidget(
                        _primaryColor, _accentColor, myUsername, title);
                  }
                  return ChangeNotifierProvider.value(
                      value: clubber.instance,
                      child: Builder(builder: (context) {
                        final clubNo =
                            Provider.of<ClubProvider>(context, listen: false);
                        clubNo.setter(
                          clubberbanned: clubber.numOfBannedMembers,
                          clubberisMod: clubber.isMod,
                          clubberbannerNSFW: clubber.bannerNSFW,
                          clubberbannerURL: clubber.clubBannerUrl,
                          clubbercanPost: clubber.memberCanPost,
                          clubberclubDescription: clubber.clubDescription,
                          clubberclubname: clubber.clubName,
                          clubberisBanned: clubber.isBanned,
                          clubberisDisable: clubber.isDisabled,
                          clubberisFounder: clubber.isFounder,
                          clubberisJoined: clubber.isJoined,
                          clubbermax: clubber.maxDailyPostsByMembers,
                          clubbermembers: clubber.numOfNewMembers,
                          clubbernumOFPosts: clubber.numOfPosts,
                          clubbernumOfMembers: clubber.numOfMembers,
                          clubberprohibited: clubber.isProhibited,
                          clubberrequests: clubber.numOfJoinRequests,
                          clubbertopics: clubber.clubTopics,
                          clubberurl: clubber.clubAvatarURL,
                          clubbervis: clubber.clubVisibility,
                          clubberisRequested: clubber.isRequested,
                          clubberQuickJoin: clubber.allowQuickJoin,
                        );
                        return Builder(builder: (context) {
                          scrollController =
                              Provider.of<ClubProvider>(context, listen: false)
                                  .getScreenScrollController;
                          disposeScrollController =
                              Provider.of<ClubProvider>(context, listen: false)
                                  .disposeScreenScrollController;
                          final bool isBanned =
                              Provider.of<ClubProvider>(context, listen: false)
                                  .isBanned;
                          final bool isDisabled =
                              Provider.of<ClubProvider>(context, listen: false)
                                  .isDisabled;
                          final bool isProhibited =
                              Provider.of<ClubProvider>(context, listen: false)
                                  .isProhibited;
                          return Stack(fit: StackFit.expand, children: <Widget>[
                            Noglow(
                                child: RefreshIndicator(
                                    backgroundColor: _primaryColor,
                                    displacement: 2.0,
                                    color: _accentColor,
                                    onRefresh: () => _pullRefresh(myUsername),
                                    child: ListView(
                                        controller: scrollController,
                                        children: <Widget>[
                                          ClubBox(clubber.instance),
                                          if (!isDisabled &&
                                              !isProhibited &&
                                              !isBanned)
                                            const JoinClubButton(),
                                          _heightBox,
                                          ClubTabBar(_controller),
                                          ClubTabs(_controller),
                                        ]))),
                            title,
                            if (selectedAnchorMode)
                              Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: MyFab(scrollController!)))
                          ]);
                        });
                      }));
                })));
  }
}

class ClubBox extends StatelessWidget {
  final instance;
  const ClubBox(this.instance);
  _showDialog(BuildContext context, String clubname) {
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
                  ClubQR(clubname),
                ],
              ),
            ),
          );
        });
  }

  Widget buildButton(Color _primaryColor, dynamic handler(), String label) {
    return TextButton(
      child: Text(
        label,
        style: TextStyle(color: _primaryColor),
      ),
      onPressed: () => handler(),
      style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          shape: MaterialStateProperty.all<OutlinedBorder?>(
              RoundedRectangleBorder(
                  side: BorderSide(color: _primaryColor),
                  borderRadius: BorderRadius.circular(5.0))),
          backgroundColor:
              MaterialStateProperty.all<Color?>(Colors.transparent)),
    );
  }

  Widget? clubVisIcon(ClubVisibility myVis) {
    switch (myVis) {
      case ClubVisibility.public:
        return const Icon(
          customIcons.MyFlutterApp.globe_no_map,
          color: Colors.black,
        );
      case ClubVisibility.private:
        return const Icon(
          Icons.lock_outline,
          color: Colors.black,
        );
      case ClubVisibility.hidden:
        return const Icon(
          customIcons.MyFlutterApp.hidden,
          color: Colors.black,
        );
      default:
        const Icon(customIcons.MyFlutterApp.globe_no_map);
        break;
    }
    return null;
  }

  static const banner = const ClubBanner(false);
  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    const Widget _miniWidthBox = SizedBox(width: 5.0);
    const Widget _heightBox = SizedBox(height: 10.0);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _club = Provider.of<ClubProvider>(context);
    final int _numOfNewMembers = _club.numOfNewMembers;
    final int _numOfRequests = _club.numOfJoinRequests;
    final int numOfMembers = _club.numOfMembers;
    final String clubBanner = _club.clubBannerUrl;
    final String clubAvatarUrl = _club.clubAvatar;
    final String clubName = _club.clubName;
    final String clubAbout = _club.clubDescription;
    final List<String> clubTopics = _club.clubTopics;
    final ClubVisibility clubVis = _club.clubVisibility;
    final int maxDailyPosts = _club.maxDailyPostsByMembers;
    final bool isMod = _club.isMod;
    final bool memberCanPost = _club.memberCanPost;
    final bool isMember = _club.isJoined;
    final bool allowQuickJoin = _club.allowQuickJoin;
    final bool isProhibited = _club.isProhibited;
    final bool isBanned = _club.isBanned;
    final bool isDisabled = _club.isDisabled;
    final prohibitClub =
        Provider.of<ClubProvider>(context, listen: false).prohibitClub;
    final addMembers =
        Provider.of<ClubProvider>(context, listen: false).addMembers;
    final decreaseNotifs =
        Provider.of<ClubProvider>(context, listen: false).decreaseNumOfRequests;
    final zeroNotifs =
        Provider.of<ClubProvider>(context, listen: false).zeroNotifs;
    final bool condition = (!isProhibited && !isBanned && !isDisabled) ||
        myUsername.startsWith('Linkspeak');
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if ((clubBanner != 'none' &&
                  !isProhibited &&
                  !isBanned &&
                  !isDisabled) ||
              (clubBanner != 'none' && myUsername.startsWith('Linkspeak')))
            banner,
          // _heightBox,
          if (condition)
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () => _showDialog(context, clubName),
                      icon: const Icon(Icons.qr_code_2,
                          color: Colors.black, size: 20.0)),
                  clubVisIcon(clubVis)!,
                  PopupMenuButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.all(0.0),
                      child: Icon(Icons.more_vert, color: Colors.grey.shade400),
                      itemBuilder: (_) => [
                            PopupMenuItem(
                                padding: const EdgeInsets.all(0.0),
                                enabled: true,
                                child: MyPopUpMenuButton(
                                    isInClubScreen: true,
                                    id: clubName,
                                    clubName: clubName,
                                    isProhibited: isProhibited,
                                    prohibitClub: prohibitClub,
                                    isInFlareProfile: false,
                                    flareProfileID: '',
                                    isBanned: false,
                                    postID: '',
                                    isMod: false,
                                    isFav: false,
                                    helperFav: () {},
                                    isInProfile: false,
                                    isClubPost: false,
                                    postedByMe: false,
                                    postTopics: [],
                                    postMedia: [],
                                    postDate: DateTime.now(),
                                    isBlocked: false,
                                    isLinkedToMe: false,
                                    block: () {},
                                    unblock: () {},
                                    remove: () {},
                                    banUser: () {},
                                    unbanUser: () {},
                                    hidePost: () {},
                                    deletePost: () {},
                                    unhidePost: () {},
                                    previewSetstate: () {}))
                          ])
                ]),
          // _heightBox,
          if (condition) _heightBox,
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClubAvatar(
                    clubName: clubName,
                    radius: 75,
                    fontSize: 80,
                    inEdit: false,
                    asset: null)
              ]),
          _heightBox,
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                Text(condition ? clubName : 'club',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black)),
                const Spacer()
              ]),
          _heightBox,
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      if (myUsername.startsWith('Linkspeak')) {
                        final ClubMemberScreenArgs args =
                            ClubMemberScreenArgs(clubName);
                        Navigator.pushNamed(
                            context, RouteGenerator.clubMembersScreen,
                            arguments: args);
                      }
                    },
                    child: Text(
                        condition
                            ? '${General.optimisedNumbers(numOfMembers)} members'
                            : '',
                        style: TextStyle(color: Colors.grey)))
              ]),
          // _heightBox,
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (isMod && !isDisabled && !isProhibited && !isBanned)
                      buildButton(_primaryColor, () {
                        final ClubAlertArgs args = ClubAlertArgs(
                            clubName: clubName,
                            numOfNewMembers: _numOfNewMembers,
                            numOfRequests: _numOfRequests,
                            zeroNotifs: zeroNotifs,
                            decreaseNotifs: decreaseNotifs,
                            addMembers: addMembers);
                        Navigator.pushNamed(
                            context, RouteGenerator.clubAlertScreen,
                            arguments: args);
                      }, 'Alerts'),
                    _miniWidthBox,
                    if (isMod && !isProhibited && !isBanned)
                      buildButton(_primaryColor, () {
                        final ManageClubScreenArgs args = ManageClubScreenArgs(
                          clubName: clubName,
                          clubAbout: clubAbout,
                          clubTopics: clubTopics,
                          instance: instance,
                          clubAvatarUrl: clubAvatarUrl,
                          clubVisibility: clubVis,
                          membersCanPost: memberCanPost,
                          allowQuickJoin: allowQuickJoin,
                          maxDailyPosts: maxDailyPosts,
                          isDisabled: isDisabled,
                        );
                        Navigator.pushNamed(
                            context, RouteGenerator.manageClubScreen,
                            arguments: args);
                      }, 'Manage'),
                    _miniWidthBox,
                    if ((!isProhibited &&
                            !isDisabled &&
                            memberCanPost &&
                            isMember &&
                            !isBanned) ||
                        (isMod && !isBanned && !isProhibited && !isDisabled))
                      buildButton(_primaryColor, () {
                        final PublishClubArgs args = PublishClubArgs(instance);
                        Navigator.pushNamed(
                            context, RouteGenerator.addClubPostScreen,
                            arguments: args);
                      }, 'Publish')
                  ]))
        ]);
  }
}
