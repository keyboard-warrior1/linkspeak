import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../clubs/clubAvatar.dart';
import '../../clubs/clubJoinButton.dart';
import '../../general.dart';
import '../../loading/suggestedSkeleton.dart';
import '../../loading/suggestedsLoading.dart';
import '../../models/clubber.dart';
import '../../models/miniSuggestedProfile.dart';
import '../../models/profile.dart';
import '../../models/profiler.dart';
import '../../models/screenArguments.dart';
import '../../providers/clubProvider.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../../providers/placesScreenProvider.dart';
import '../../providers/themeModel.dart';
import '../../providers/topicScreenProvider.dart';
import '../../routes.dart';
import '../common/adaptiveText.dart';
import '../common/chatProfileImage.dart';
import '../common/noglow.dart';
import '../profile/linkButton.dart';

class SuggestedWidget extends StatefulWidget {
  final bool isClub;
  final bool isInTopic;
  final bool isInPlace;
  const SuggestedWidget(this.isClub, this.isInTopic, this.isInPlace);

  @override
  _SuggestedWidgetState createState() => _SuggestedWidgetState();
}

class _SuggestedWidgetState extends State<SuggestedWidget>
    with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future _getSuggested;
  List<MiniSuggestedProfile> suggesteds = [];
  Future<void> getSuggested(String myUsername, List<String> myTopics) async {
    myTopics.shuffle();
    final newTopics = myTopics.take(10).toList();
    final clubFilter = firestore
        .collection('Clubs')
        .where('Visibility', isNotEqualTo: 'Hidden');
    final profileFilter = firestore
        .collection('Users')
        .where('Username', isNotEqualTo: myUsername);
    final getCommonTopicUsers = widget.isInPlace
        ? await firestore
            .collection('Places')
            .doc(Provider.of<PlacesScreenProvider>(context, listen: false)
                .placeName)
            .collection('current profiles')
            .orderBy('date', descending: true)
            .limit(12)
            .get()
        : widget.isInTopic
            ? widget.isClub
                ? await clubFilter
                    .where('topics', whereIn: [
                      Provider.of<TopicScreenProvider>(context, listen: false)
                          .getTopicName
                    ])
                    .limit(12)
                    .get()
                : await profileFilter
                    .where('Topics', whereIn: [
                      Provider.of<TopicScreenProvider>(context, listen: false)
                          .getTopicName
                    ])
                    .limit(12)
                    .get()
            : widget.isClub
                ? await clubFilter
                    .where('topics', whereIn: newTopics)
                    .limit(12)
                    .get()
                : await profileFilter
                    .where('Topics', whereIn: newTopics)
                    .limit(12)
                    .get();
    final commonTopicDocs = getCommonTopicUsers.docs;
    if (commonTopicDocs.length == 12) {
      for (var doc in commonTopicDocs) {
        final username = doc.id;
        final mini = MiniSuggestedProfile(username);
        if (suggesteds.any((element) => element.username == username)) {
        } else {
          suggesteds.add(mini);
        }
      }
      setState(() {});
    } else {
      int difference = 12 - commonTopicDocs.length;
      final getEmNormal = widget.isClub
          ? await clubFilter.limit(difference).get()
          : await profileFilter.limit(difference).get();
      final docs = getEmNormal.docs;
      for (var doc in docs) {
        final username = doc.id;
        final mini = MiniSuggestedProfile(username);
        if (suggesteds.any((element) => element.username == username)) {
        } else {
          suggesteds.add(mini);
        }
      }
      for (var doc in commonTopicDocs) {
        final username = doc.id;
        final mini = MiniSuggestedProfile(username);
        if (suggesteds.any((element) => element.username == username)) {
        } else {
          suggesteds.add(mini);
        }
      }
      setState(() {});
    }
  }

  void removeSuggestion(String username) {
    suggesteds.removeWhere((element) => element.username == username);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<MyProfile>(context, listen: false);
    final String myUsername = profile.getUsername;
    final List<String> myTopics = profile.getTopics;
    _getSuggested = getSuggested(myUsername, myTopics);
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final profile = Provider.of<MyProfile>(context, listen: false);
    final String myUsername = profile.getUsername;
    final List<String> myTopics = profile.getTopics;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    super.build(context);
    return kIsWeb
        ? Container()
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            color: Colors.white,
            height: _deviceHeight * 0.325,
            width: _deviceWidth,
            child: Noglow(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                  Row(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                            widget.isClub
                                ? lang.widgets_misc6
                                : lang.widgets_misc7,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0)))
                  ]),
                  Expanded(
                      child: FutureBuilder(
                          future: _getSuggested,
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return const SuggestedsLoading();
                            if (snapshot.hasError)
                              return Center(
                                  child: IconButton(
                                      onPressed: () => setState(() {
                                            _getSuggested = getSuggested(
                                                myUsername, myTopics);
                                          }),
                                      icon: const Icon(Icons.refresh,
                                          color: Colors.black, size: 25)));
                            return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: suggesteds.length,
                                padding: const EdgeInsets.only(top: 10),
                                itemBuilder: (ctx, index) {
                                  final currentProfile = suggesteds[index];
                                  final username = currentProfile.username;
                                  return SuggestedItem(
                                      isClub: widget.isClub,
                                      username: username,
                                      clubName: username,
                                      removeSuggestion: removeSuggestion);
                                });
                          }))
                ])));
  }

  @override
  bool get wantKeepAlive => true;
}

class SuggestedItem extends StatefulWidget {
  final bool isClub;
  final String username;
  final String clubName;
  final void Function(String) removeSuggestion;
  const SuggestedItem(
      {required this.isClub,
      required this.username,
      required this.clubName,
      required this.removeSuggestion});

  @override
  State<SuggestedItem> createState() => _SuggestedItemState();
}

class _SuggestedItemState extends State<SuggestedItem>
    with AutomaticKeepAliveClientMixin {
  final firestore = FirebaseFirestore.instance;
  Clubber? clubber;
  Profiler? profiler;
  late Future<void> getFuture;
  // ignore: unused_field
  late Future<void> _addSuggested;
  bool _userIsBanned = false;
  bool _imBlocked = false;
  bool _isBlocked = false;
  bool _clubProhibited = false;
  bool _clubDisabled = false;
  bool _imClubBanned = false;
  Future<void> addSuggested(String myUsername) async {
    var batch = firestore.batch();
    final _now = DateTime.now();
    final users = firestore.collection('Users');
    final myProfile = users.doc(myUsername);
    final target = widget.isClub
        ? firestore.collection('Clubs').doc(widget.clubName)
        : users.doc(widget.username);
    final getTarget = await target.get();
    final options = SetOptions(merge: true);
    if (getTarget.exists) {
      final mySuggested = myProfile
          .collection(widget.isClub ? 'Suggested Clubs' : 'Suggested Profiles');
      final targetMySuggested = widget.isClub
          ? mySuggested.doc(widget.clubName)
          : mySuggested.doc(widget.username);
      final targetSuggestedTo =
          target.collection('Suggested To').doc(myUsername);
      batch.set(target, {'times suggested': FieldValue.increment(1)}, options);
      batch.set(targetSuggestedTo,
          {'times': FieldValue.increment(1), 'date': _now}, options);
      batch.set(
          myProfile,
          {
            if (widget.isClub) 'suggested clubs': FieldValue.increment(1),
            if (!widget.isClub) 'suggested profiles': FieldValue.increment(1)
          },
          options);
      batch.set(targetMySuggested,
          {'times': FieldValue.increment(1), 'date': _now}, options);
      Map<String, dynamic> fields = {
        if (widget.isClub) 'suggested clubs': FieldValue.increment(1),
        if (!widget.isClub) 'suggested users': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'date': _now,
        'times': FieldValue.increment(1)
      };
      String docID = widget.isClub ? widget.clubName : widget.username;
      String collectionName =
          widget.isClub ? 'suggested clubs' : 'suggested users';
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: collectionName,
          docID: docID,
          docFields: docFields);
      return batch.commit();
    }
  }

  Future<void> getUser(
      String username,
      String _myUsername,
      Color themePrimaryColor,
      Color themeAccentColor,
      Color themeLikeColor) async {
    final _theUser = firestore.collection('Users').doc(widget.username);
    final _thisUser = await _theUser.get();
    if (_thisUser.exists) {
      final userLinks =
          await _theUser.collection('Links').doc(_myUsername).get();
      bool hasUnseenCollection = false;
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
          .doc(widget.username)
          .get();
      final myBlocked = await firestore
          .collection('Users')
          .doc(_myUsername)
          .collection('Blocked')
          .doc(widget.username)
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
      _imBlocked = imBlocked;
      _isBlocked = isBlocked;
      _userIsBanned = status != 'Allowed';
      final List<String> topics =
          serverTopics.map((topic) => topic as String).toList();
      final OtherProfile instance = OtherProfile();
      profiler = Profiler(
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
          hasSpotlight: false,
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
          likeColor: otherLikeColor);
    } else {
      _thisUser.get('dfijwefiu');
    }
  }

  Future<void> getClub(String clubName, String myUsername) async {
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
    getter(String field) => getClub.get(field);
    if (getClub.exists) {
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
      _clubProhibited = isProhibited;
      _clubDisabled = isDisabled;
      _imClubBanned = isBanned;
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
          allowQuickJoin: allowQuickJoin);
    } else {
      getter('skjfd');
    }
  }

  void _visitProfile(String username, String myUsername) {
    if (username == myUsername) {
    } else {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: username);
      Navigator.pushNamed(
          context,
          (username == myUsername)
              ? RouteGenerator.myProfileScreen
              : RouteGenerator.posterProfileScreen,
          arguments: args);
    }
  }

  void _visitClub() {
    final args = ClubScreenArgs(widget.clubName);
    Navigator.pushNamed(context, RouteGenerator.clubScreen, arguments: args);
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final ThemeModel theme = Provider.of<ThemeModel>(context, listen: false);
    final Color _primarySwatch = theme.primary;
    final Color _accentColor = theme.accent;
    final Color _likeColor = theme.likeColor;
    getFuture = widget.isClub
        ? getClub(widget.clubName, myUsername)
        : getUser(widget.username, myUsername, _primarySwatch, _accentColor,
            _likeColor);
    _addSuggested = addSuggested(myUsername);
  }

  Widget giveNotifier(Widget child) {
    if (widget.isClub)
      return ChangeNotifierProvider.value(
          value: clubber!.instance, child: child);
    else
      return ChangeNotifierProvider.value(
          value: profiler!.otherProfileProvider, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    String displayName = (widget.isClub) ? widget.clubName : widget.username;
    const emptyBox = const SizedBox(height: 0, width: 0);
    if (displayName.length > 15) {
      final sub = displayName.substring(0, 15);
      displayName = '$sub..';
    }
    super.build(context);
    return FutureBuilder(
        future: getFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const SuggestedSkeleton();
          if (snapshot.hasError) return emptyBox;
          return (_userIsBanned ||
                  _imBlocked ||
                  _isBlocked ||
                  _clubProhibited ||
                  _clubDisabled ||
                  _imClubBanned)
              ? emptyBox
              : giveNotifier(Builder(builder: (context) {
                  if (widget.isClub) {
                    final prov =
                        Provider.of<ClubProvider>(context, listen: false);
                    prov.setter(
                        clubberbanned: clubber!.numOfBannedMembers,
                        clubberisMod: clubber!.isMod,
                        clubberbannerNSFW: clubber!.bannerNSFW,
                        clubberbannerURL: clubber!.clubBannerUrl,
                        clubbercanPost: clubber!.memberCanPost,
                        clubberclubDescription: clubber!.clubDescription,
                        clubberclubname: clubber!.clubName,
                        clubberisBanned: clubber!.isBanned,
                        clubberisDisable: clubber!.isDisabled,
                        clubberisFounder: clubber!.isFounder,
                        clubberisJoined: clubber!.isJoined,
                        clubbermax: clubber!.maxDailyPostsByMembers,
                        clubbermembers: clubber!.numOfNewMembers,
                        clubbernumOFPosts: clubber!.numOfPosts,
                        clubbernumOfMembers: clubber!.numOfMembers,
                        clubberprohibited: clubber!.isProhibited,
                        clubberrequests: clubber!.numOfJoinRequests,
                        clubbertopics: clubber!.clubTopics,
                        clubberurl: clubber!.clubAvatarURL,
                        clubbervis: clubber!.clubVisibility,
                        clubberisRequested: clubber!.isRequested,
                        clubberQuickJoin: clubber!.allowQuickJoin);
                  } else {
                    final prov =
                        Provider.of<OtherProfile>(context, listen: false);
                    prov.setter(
                        additionalWebsite: profiler!.additionalWebsite,
                        additionalEmail: profiler!.additionalEmail,
                        additionalNumber: profiler!.additionalNumber,
                        additionalAddress: profiler!.additionalAddress,
                        additionalAddressName: profiler!.additionalAddressName,
                        hasSpotlight: profiler!.hasSpotlight,
                        doesHaveUnseen: profiler!.hasUnseenCollection,
                        linkedToThem: profiler!.imLinkedtoThem,
                        linkedTOMe: profiler!.linkedToMe,
                        imBlocked: profiler!.imBlocked,
                        isBlocked: profiler!.isBlocked,
                        requestSent: profiler!.linkRequestSent,
                        vis: profiler!.visibility,
                        imgUrl: profiler!.imgUrl,
                        bannerUrl: profiler!.bannerUrl,
                        bannerNSFW: profiler!.bannerNSFW,
                        username: profiler!.username,
                        bio: profiler!.bio,
                        numOfLinks: profiler!.numOfLinks,
                        numOfLinked: profiler!.numOfLinkedTo,
                        joinedClubs: profiler!.joinedClubs,
                        topics: profiler!.topics,
                        numOfPosts: profiler!.numOfPosts,
                        postIDs: profiler!.posts,
                        activity: profiler!.activityStatus,
                        primaryColor: profiler!.primaryColor,
                        accentColor: profiler!.accentColor,
                        likeColor: profiler!.likeColor,
                        status: profiler!.status);
                  }
                  return Builder(
                      key: UniqueKey(),
                      builder: (context) {
                        return GestureDetector(
                            onTap: () => (widget.isClub)
                                ? _visitClub()
                                : _visitProfile(widget.username, myUsername),
                            child: Container(
                                margin: const EdgeInsets.all(5.0),
                                height: _deviceHeight * 0.325,
                                width: _deviceWidth * 0.5,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                        color: Colors.grey.shade100)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Card(
                                        margin: const EdgeInsets.all(0),
                                        borderOnForeground: false,
                                        child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                        onPressed: () => widget
                                                            .removeSuggestion(
                                                                widget.isClub
                                                                    ? widget
                                                                        .clubName
                                                                    : widget
                                                                        .username),
                                                        icon: Icon(Icons.close,
                                                            color: Colors
                                                                .grey.shade200,
                                                            size: 25.0))
                                                  ]),
                                              if (widget.isClub)
                                                ClubAvatar(
                                                    clubName: widget.clubName,
                                                    radius: _deviceHeight *
                                                        0.10 /
                                                        2,
                                                    inEdit: false,
                                                    asset: null,
                                                    fontSize: _deviceHeight *
                                                        0.10 /
                                                        1.75),
                                              if (!widget.isClub)
                                                ChatProfileImage(
                                                    username: widget.username,
                                                    factor: 0.10,
                                                    inEdit: false,
                                                    asset: null),
                                              OptimisedText(
                                                  minHeight:
                                                      _deviceHeight * 0.05,
                                                  maxHeight:
                                                      _deviceHeight * 0.05,
                                                  minWidth: _deviceWidth * 0.45,
                                                  maxWidth: _deviceWidth * 0.45,
                                                  fit: BoxFit.scaleDown,
                                                  child: Center(
                                                      child: Text(displayName,
                                                          softWrap: false,
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 17.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)))),
                                              if (widget.isClub)
                                                const JoinClubButton(),
                                              if (!widget.isClub)
                                                const LinkButton()
                                            ])))));
                      });
                }));
        });
  }

  @override
  bool get wantKeepAlive => true;
}
