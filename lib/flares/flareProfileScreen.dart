// ignore_for_file: unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/flareProfileSkeleton.dart';
import '../models/flarer.dart';
import '../models/profile.dart';
import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/flareProfileProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/auth/reportDialog.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/chatProfileImage.dart';
import '../widgets/common/myFab.dart';
import '../widgets/common/myLinkify.dart';
import '../widgets/common/noglow.dart';
import '../widgets/profile/qrCode.dart';
import 'flareProfileBanner.dart';
import 'flareProfileTab.dart';

enum ViewMode { normal, edit }

class FlareProfileScreen extends StatefulWidget {
  final dynamic userID;
  const FlareProfileScreen(this.userID);

  @override
  State<FlareProfileScreen> createState() => _FlareProfileScreenState();
}

class _FlareProfileScreenState extends State<FlareProfileScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ViewMode viewMode = ViewMode.normal;
  String sessionID = '';
  String myName = '';
  ScrollController? scrollController;
  void Function() disposeScrollController = () {};
  late final TabController _controller;
  late Flarer flarer;
  late Future<void> getFlareProfile;
  late Future<void> _initSession;
  late Future<void> _endSession;
  late Future<void> viewFlareProfile;

  Widget buildBackButton() => Align(
      alignment: Alignment.topLeft,
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
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
                    border: Border.all(color: Colors.black)),
                child: const Icon(customIcons.MyFlutterApp.curve_arrow,
                    color: Colors.black)))
      ]));

  Widget buildBorderedIcon(IconData icon, bool isOther, dynamic handler) =>
      GestureDetector(
          onTap: () {
            handler();
          },
          child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: isOther ? null : Border.all()),
              child: Icon(icon, color: Colors.black, size: 20)));

  Widget buildNewFlareButton(Color primaryColor, Color _accentColor) => Align(
      alignment: Alignment.bottomRight,
      child: Container(
          margin: const EdgeInsets.only(bottom: 10.0, right: 10),
          child: FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteGenerator.newFlare),
              backgroundColor: primaryColor,
              child: Stack(children: <Widget>[
                Positioned.fill(
                    child: Icon(customIcons.MyFlutterApp.spotlight,
                        color: _accentColor, size: 30.0)),
                Positioned(
                    top: 7.7,
                    right: 7.5,
                    child:
                        Icon(Icons.add_circle, color: _accentColor, size: 18))
              ]))));

  Widget buildCantShow(IconData icon, String description) => Container(
        color: Colors.white,
        child: Stack(fit: StackFit.expand, children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Icon(icon, size: 55, color: Colors.black)]),
                    const SizedBox(height: 10.0),
                    Text(description,
                        softWrap: true,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 17.0))
                  ])),
          Align(
              alignment: Alignment.topLeft,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(width: 20.0),
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
                              border: Border.all(color: Colors.black),
                            ),
                            child: const Icon(
                                customIcons.MyFlutterApp.curve_arrow,
                                color: Colors.black)))
                  ]))
        ]),
      );

  Widget buildErrorWidget(
      Color _primaryColor, Color _accentColor, String myUsername) {
    final lang = General.language(context);
    return Container(
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
                      Text(lang.flares_profile1,
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
                                          _primaryColor)),
                              onPressed: () {
                                setState(() {
                                  getFlareProfile =
                                      _getFlareProfile(myUsername);
                                });
                              },
                              child: Text(lang.flares_profile2,
                                  style: TextStyle(
                                      fontSize: 19.0, color: _accentColor))))
                    ])
              ]),
          Align(
              alignment: Alignment.topLeft,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(width: 20.0),
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
                                border: Border.all(color: Colors.black)),
                            child: const Icon(
                                customIcons.MyFlutterApp.curve_arrow,
                                color: Colors.black)))
                  ]))
        ]));
  }

  Future<void> initSession(String myUsername, String flareUser) async {
    final checkExists = await General.checkExists('Flares/$flareUser');
    if (checkExists) {
      var batch = firestore.batch();
      final _rightNow = DateTime.now();
      final flaresCollection = firestore.collection('Flares');
      final thisFlarer = flaresCollection.doc(flareUser);
      final getFlarer = await thisFlarer.get();
      final exists = getFlarer.exists;
      if (exists) {
        final sessions = thisFlarer.collection('Sessions');
        final mySession = await sessions.doc(myUsername).get();
        final hasSession = mySession.exists;
        if (!hasSession) {
          final options = SetOptions(merge: true);
          batch.set(sessions.doc(myUsername), {'start': _rightNow}, options);
          batch.set(thisFlarer, {'sessions': FieldValue.increment(1)}, options);
        }
      }
      return batch.commit();
    }
  }

  Future<void> endSession(String myUsername, String flareUser) async {
    final checkExists = await General.checkExists('Flares/$flareUser');
    if (checkExists) {
      final _rightNow = DateTime.now();
      var batch = firestore.batch();
      final options = SetOptions(merge: true);
      final flaresCollection = firestore.collection('Flares');
      final thisFlarer = flaresCollection.doc(flareUser);
      final getFlarer = await thisFlarer.get();
      final exists = getFlarer.exists;
      if (exists) {
        final flarerViewers = thisFlarer.collection('Viewers');
        final myFlareSessions =
            flarerViewers.doc(myUsername).collection('Sessions');
        final thisSession = await myFlareSessions.doc(sessionID).get();
        final thisSessionExists = thisSession.exists;
        final sessions = thisFlarer.collection('Sessions');
        final mySession = await sessions.doc(myUsername).get();
        final hasSession = mySession.exists;
        if (hasSession) {
          batch.delete(sessions.doc(myUsername));
          batch.set(
              thisFlarer, {'sessions': FieldValue.increment(-1)}, options);
        }
        if (thisSessionExists) {
          batch.set(
              myFlareSessions.doc(sessionID), {'end': _rightNow}, options);
        }
      }
      return batch.commit();
    }
  }

  Future<void> _viewFlareProfile(String myusername, String flareUser) async {
    final usersCollection = firestore.collection('Users');
    final flaresCollection = firestore.collection('Flares');
    final myUser = usersCollection.doc(myusername);
    final thisFlare = flaresCollection.doc('${widget.userID}');
    final getFlare = await thisFlare.get();
    if (getFlare.exists) {
      var batch = firestore.batch();
      final _rightNow = DateTime.now();
      final _sessionID = _rightNow.toString();
      sessionID = _sessionID;
      final myViewedFlareProfiles = myUser.collection('Viewed Flare Profiles');
      final thisMyViewed = await myViewedFlareProfiles.doc(flareUser).get();
      final alreadySeen = thisMyViewed.exists;
      final flareViewers = thisFlare.collection('Viewers');
      final myViewerDoc = await flareViewers.doc(myusername).get();
      final isViewed = myViewerDoc.exists;
      final initialdata = {
        'flarer': flareUser,
        'first viewed': _rightNow,
        'times': FieldValue.increment(1),
        'ID': myusername,
      };
      final existingData = {
        'times': FieldValue.increment(1),
        'last viewed': _rightNow
      };
      final options = SetOptions(merge: true);
      if (alreadySeen) {
        batch.set(myViewedFlareProfiles.doc(flareUser), existingData, options);
      } else {
        batch.set(myViewedFlareProfiles.doc(flareUser), initialdata, options);
        batch.set(myUser, {'seen flarers': FieldValue.increment(1)}, options);
      }
      if (isViewed) {
        batch.set(flareViewers.doc(myusername), existingData, options);
        batch.set(
            flareViewers.doc(myusername).collection('Sessions').doc(_sessionID),
            {'start': _rightNow},
            options);
      } else {
        batch.set(flareViewers.doc(myusername), existingData, options);
        batch.set(
            flareViewers.doc(myusername).collection('Sessions').doc(_sessionID),
            {'start': _rightNow},
            options);
        batch.set(
            thisFlare, {'numProfileViewers': FieldValue.increment(1)}, options);
      }
      Map<String, dynamic> fields = {
        'viewed flare profiles': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'id': widget.userID,
        'date': _rightNow,
        'times': FieldValue.increment(1)
      };
      General.updateControl(
          fields: fields,
          myUsername: myusername,
          collectionName: 'viewed flare profiles',
          docID: widget.userID,
          docFields: docFields);
      return batch.commit();
    } else {
      return;
    }
  }

  Future<void> _getFlareProfile(String myUsername) async {
    final FlareProfile instance = FlareProfile();
    final usersCollection = firestore.collection('Users');
    final flaresCollection = firestore.collection('Flares');
    final myUser = usersCollection.doc('${widget.userID}');
    final myFlare = flaresCollection.doc('${widget.userID}');
    final getUser = await myUser.get();
    final userStatus = getUser.get('Status');
    final userLinks = await myUser.collection('Links').doc(myUsername).get();
    final imLinked = userLinks.exists;
    final getBlocked = await myUser.collection('Blocked').doc(myUsername).get();
    final imBlocked = getBlocked.exists;
    final getFlare = await myFlare.get();
    TheVisibility visibility = TheVisibility.public;
    String bannerUrl = 'None';
    bool bannerNSFW = false;
    String bio = '';
    String currentlyShowcasing = '';
    int numOfFlares = 0;
    int numOfViews = 0;
    int numOfLikes = 0;
    int numOfLikeNotifs = 0;
    int numOfCommentNotifs = 0;
    final bool flareExists = getFlare.exists;
    final bool isMyProfile = widget.userID == myUsername;
    final vis = getUser.get('Visibility');
    visibility = General.convertProfileVis(vis);
    if (getUser.data()!.containsKey('Banner')) {
      final actualBanner = getUser.get('Banner');
      bannerUrl = actualBanner;
    }
    if (getUser.data()!.containsKey('bannerNSFW')) {
      final actualNSFW = getUser.get('bannerNSFW');
      bannerNSFW = actualNSFW;
    }
    if (flareExists) {
      getter(String field) => getFlare.get(field);
      bool checkContains(String field) => getFlare.data()!.containsKey(field);
      if (checkContains('bio')) bio = getter('bio');
      if (checkContains('currentlyShowcasing'))
        currentlyShowcasing = getter('currentlyShowcasing');
      if (checkContains('numOfFlares')) numOfFlares = getter('numOfFlares');
      if (checkContains('numOfViews')) numOfViews = getter('numOfViews');
      if (checkContains('numOfLikes')) numOfLikes = getter('numOfLikes');
      if (checkContains('likeNotifs')) numOfLikeNotifs = getter('likeNotifs');
      if (checkContains('commentNotifs'))
        numOfCommentNotifs = getter('commentNotifs');
      flarer = Flarer(
          bannerURL: bannerUrl,
          bannerNSFW: bannerNSFW,
          username: widget.userID,
          bio: bio,
          currentlyShowcasing: currentlyShowcasing,
          numOfFlares: numOfFlares,
          numOfViews: numOfViews,
          numOfLikes: numOfLikes,
          numOfLikeNotifs: numOfLikeNotifs,
          numOfCommentNotifs: numOfCommentNotifs,
          isMyProfile: isMyProfile,
          isBanned: userStatus != 'Allowed',
          imBlocked: imBlocked,
          imLinked: imLinked,
          instance: instance,
          visibility: visibility);
    } else {
      flarer = Flarer(
          bannerURL: bannerUrl,
          bannerNSFW: bannerNSFW,
          username: widget.userID,
          bio: bio,
          currentlyShowcasing: currentlyShowcasing,
          numOfFlares: numOfFlares,
          numOfViews: numOfViews,
          numOfLikes: numOfLikes,
          numOfLikeNotifs: numOfLikeNotifs,
          numOfCommentNotifs: numOfCommentNotifs,
          isMyProfile: isMyProfile,
          isBanned: userStatus != 'Allowed',
          imBlocked: imBlocked,
          imLinked: imLinked,
          instance: instance,
          visibility: visibility);
    }
  }

  Future<void> _pullRefresh(String myUsername) async {
    if (viewMode != ViewMode.normal) viewMode = ViewMode.normal;
    setState(() {
      getFlareProfile = _getFlareProfile(myUsername);
    });
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    myName = myUsername;
    getFlareProfile = _getFlareProfile(myUsername);
    viewFlareProfile = _viewFlareProfile(myUsername, widget.userID);
    _initSession = initSession(myUsername, widget.userID);
    _controller = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _endSession = endSession(myName, widget.userID);
    disposeScrollController();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final bool imManagement = myUsername.startsWith('Linkspeak');
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    const _mediumHeightBox = const SizedBox(height: 30);
    return Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
                child: FutureBuilder(
                    future: getFlareProfile,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return const FlareProfileSkeleton();
                      if (snapshot.hasError)
                        return buildErrorWidget(
                            _primaryColor, _accentColor, myUsername);
                      return ChangeNotifierProvider.value(
                          value: flarer.instance,
                          child: Builder(builder: (context) {
                            final profileNo = Provider.of<FlareProfile>(context,
                                listen: false);
                            profileNo.initializeFlareProfile(
                                paramUsername: flarer.username,
                                paramBanner: flarer.bannerURL,
                                paramBio: flarer.bio,
                                paramShowcase: flarer.currentlyShowcasing,
                                paramNumFlares: flarer.numOfFlares,
                                paramNumViews: flarer.numOfViews,
                                paramNumLikes: flarer.numOfLikes,
                                paramLikeNotifs: flarer.numOfLikeNotifs,
                                paramNumOfCommentNotifs:
                                    flarer.numOfCommentNotifs,
                                paramList: [],
                                paramNSFW: flarer.bannerNSFW,
                                paramIsMine: flarer.isMyProfile,
                                paramIsBanned: flarer.isBanned,
                                paramImBlocked: flarer.imBlocked,
                                paramImLinked: flarer.imLinked,
                                paramVisibility: flarer.visibility);
                            return Builder(builder: (context) {
                              final profileNo = Provider.of<FlareProfile>(
                                  context,
                                  listen: false);
                              scrollController =
                                  profileNo.getprofileScrollController;
                              disposeScrollController =
                                  profileNo.disposeProfileScrollController;
                              final bool isMyProfile = profileNo.isMyProfile;
                              final bool isBanned = profileNo.isBanned;
                              final bool imBlocked = profileNo.imBlocked;
                              final bool imLinked = profileNo.imLinked;
                              final TheVisibility flarerVis =
                                  profileNo.profileVis;
                              return isBanned && !imManagement
                                  ? buildCantShow(
                                      Icons.person_off, lang.flares_profile3)
                                  : imBlocked && !imManagement
                                      ? buildCantShow(
                                          customIcons.MyFlutterApp.no_stopping,
                                          '')
                                      : !imLinked &&
                                              !isMyProfile &&
                                              !imManagement &&
                                              flarerVis == TheVisibility.private
                                          ? buildCantShow(Icons.lock_outline,
                                              lang.flares_profile4)
                                          : Stack(
                                              fit: StackFit.expand,
                                              children: <Widget>[
                                                  Noglow(
                                                      child: RefreshIndicator(
                                                          backgroundColor:
                                                              _primaryColor,
                                                          displacement: 2.0,
                                                          color: _accentColor,
                                                          onRefresh: () =>
                                                              _pullRefresh(
                                                                  myUsername),
                                                          child: ListView(
                                                              keyboardDismissBehavior:
                                                                  ScrollViewKeyboardDismissBehavior
                                                                      .onDrag,
                                                              controller:
                                                                  scrollController,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(0),
                                                              children: <
                                                                  Widget>[
                                                                FlareBox(
                                                                    viewMode,
                                                                    () => setState(() => viewMode =
                                                                        ViewMode
                                                                            .normal),
                                                                    () => setState(() =>
                                                                        viewMode =
                                                                            ViewMode.edit)),
                                                                _mediumHeightBox,
                                                                TabBar(
                                                                    controller:
                                                                        _controller,
                                                                    indicatorColor:
                                                                        _primaryColor,
                                                                    unselectedLabelColor:
                                                                        Colors
                                                                            .grey,
                                                                    indicator: UnderlineTabIndicator(
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .grey.shade200)),
                                                                    labelColor:
                                                                        _primaryColor,
                                                                    tabs: [
                                                                      Container(
                                                                          height:
                                                                              45,
                                                                          child:
                                                                              Center(child: Text(lang.flares_profile5, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19.0))))
                                                                    ]),
                                                                FlareProfileTab(
                                                                    _controller)
                                                              ]))),
                                                  buildBackButton(),
                                                  if (selectedAnchorMode &&
                                                      viewMode ==
                                                          ViewMode.normal)
                                                    Align(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom:
                                                                        10.0),
                                                            child: MyFab(
                                                                scrollController!))),
                                                  if (viewMode ==
                                                          ViewMode.edit &&
                                                      !kIsWeb)
                                                    buildNewFlareButton(
                                                        _primaryColor,
                                                        _accentColor)
                                                ]);
                            });
                          }));
                    }))));
  }
}

class FlareBox extends StatefulWidget {
  final viewMode;
  final void Function() changeToNormal;
  final void Function() changeToEdit;
  const FlareBox(this.viewMode, this.changeToNormal, this.changeToEdit);
  @override
  State<FlareBox> createState() => _FlareBoxState();
}

class _FlareBoxState extends State<FlareBox> {
  bool isLoading = false;
  final TextEditingController textController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> updateProfile(String myUsername, String previousBio,
      String newBio, void Function(String changeBio) changeBio) async {
    final lang = General.language(context);
    setState(() {
      isLoading = true;
    });
    final filter = ProfanityFilter();
    var batch = firestore.batch();
    final options = SetOptions(merge: true);
    final DateTime _rightNow = DateTime.now();
    final modID = _rightNow.toString();
    final myFlare = firestore.collection('Flares').doc(myUsername);
    final thisModification = myFlare.collection('Modifications').doc(modID);
    if (filter.hasProfanity(newBio)) {
      batch.update(firestore.doc('Profanity/Flare Profiles'),
          {'numOfProfanity': FieldValue.increment(1)});
      batch.set(
          firestore.collection('Profanity/Flare Profiles/Profiles').doc(), {
        'profile': myUsername,
        'date': _rightNow,
        'new bio': newBio,
        'old Bio': previousBio
      });
    }
    batch.set(myFlare, {'bio': newBio, 'lastModified': _rightNow}, options);
    batch.set(
        thisModification,
        {'new bio': newBio, 'old bio': previousBio, 'date': _rightNow},
        options);
    return batch.commit().then((value) {
      changeBio(newBio);
      setState(() {
        isLoading = false;
        widget.changeToNormal();
      });
      EasyLoading.showSuccess(lang.flares_profile6,
          duration: const Duration(seconds: 1), dismissOnTap: true);
    }).catchError((_) {
      setState(() {
        isLoading = false;
      });
      EasyLoading.showError(lang.flares_profile7,
          duration: const Duration(seconds: 1), dismissOnTap: true);
    });
  }

  _showDialog() => showDialog(
      context: context,
      builder: (_) {
        return Center(
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[const QRcode()])));
      });

  IconData? visIcon(TheVisibility myVis) {
    switch (myVis) {
      case TheVisibility.public:
        return customIcons.MyFlutterApp.globe_no_map;
      case TheVisibility.private:
        return Icons.lock_outline;
      default:
        return customIcons.MyFlutterApp.globe_no_map;
    }
  }

  Widget giveStatWidget(int amount, String description) {
    return OptimisedText(
        minWidth: 50,
        maxWidth: 50,
        minHeight: 100.0,
        maxHeight: 100.0,
        fit: BoxFit.none,
        child: TextButton(
            style: ButtonStyle(splashFactory: NoSplash.splashFactory),
            onPressed: () {},
            child: Column(children: <Widget>[
              Text(description,
                  style: const TextStyle(color: Colors.black, fontSize: 18.0)),
              const SizedBox(height: 5.0),
              Text(General.optimisedNumbers(amount),
                  style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold))
            ])));
  }

  Widget buildBorderedIcon(IconData icon, bool isOther, dynamic handler) =>
      GestureDetector(
          onTap: () {
            handler();
          },
          child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: isOther ? null : Border.all()),
              child: Icon(icon, color: Colors.black, size: 20)));

  Widget buildSaveButton(
          String myUsername, previousBio, void Function(String) changeBio) =>
      GestureDetector(
          onTap: () {
            if (!isLoading)
              updateProfile(myUsername, previousBio,
                  textController.value.text.trim(), changeBio);
          },
          child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightGreenAccent.shade400),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          const CircularProgressIndicator(color: Colors.white))
                  : const Icon(Icons.check, color: Colors.white, size: 20)));

  Widget buildCancelButton(bool isRTL) => GestureDetector(
      onTap: () {
        if (!isLoading) widget.changeToNormal();
      },
      child: Container(
          margin: EdgeInsets.only(right: isRTL ? 0 : 10, left: isRTL ? 10 : 0),
          padding: const EdgeInsets.all(2.0),
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
          child: const Icon(Icons.undo, color: Colors.white, size: 20)));

  void visitProfile(String myUsername, String username) {
    if (widget.viewMode == ViewMode.normal) {
      if (username != myUsername) {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: username);
        Navigator.pushNamed(context, RouteGenerator.posterProfileScreen,
            arguments: args);
      } else {
        Navigator.pushNamed(context, RouteGenerator.myProfileScreen);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<FlareProfile>(context, listen: false);
    final String bio = profile.flaresBio;
    textController.text = bio;
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final profile = Provider.of<FlareProfile>(context);
    final profileNo = Provider.of<FlareProfile>(context, listen: false);
    final changeBio = profileNo.changeBio;
    final zeroNotifs = profileNo.clearNotifs;
    final TheVisibility flarerVis = profile.profileVis;
    final String username = profile.username;
    final String bio = profile.flaresBio;
    final String bannerURL = profile.bannerURL;
    final int numOfFlare = profile.numOfFlares;
    final int numOfViews = profile.numOfViews;
    final int numOfLikes = profile.numOfLikes;
    final int likeNotifs = profile.numOfLikeNotifs;
    final int commentNotifs = profile.numOfCommentNotifs;
    final bool isMyProfile = profile.isMyProfile;
    const SizedBox _widthBox = const SizedBox(width: 30.0);
    const _heightBox = const SizedBox(height: 15);
    const _mediumHeightBox = const SizedBox(height: 30);
    final textDirection =
        Provider.of<ThemeModel>(context, listen: false).textDirection;
    final bool isRTL = textDirection == TextDirection.rtl;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (bannerURL == 'None') _mediumHeightBox,
          if (bannerURL != 'None') const FlareProfileBanner(),
          _heightBox,
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.viewMode == ViewMode.edit)
                  buildSaveButton(username, bio, changeBio),
                const SizedBox(width: 5),
                if (widget.viewMode == ViewMode.edit) buildCancelButton(isRTL),
                if (widget.viewMode == ViewMode.normal && isMyProfile)
                  Container(
                      height: 25.0,
                      width: 25.0,
                      margin: const EdgeInsets.only(right: 10),
                      child: Stack(children: <Widget>[
                        buildBorderedIcon(Icons.notifications_outlined, false,
                            () {
                          final args = FlareAlertScreenArgs(
                              username: username,
                              numOfLikes: likeNotifs,
                              numOfComments: commentNotifs,
                              zeroNotifs: zeroNotifs);
                          Navigator.pushNamed(
                              context, RouteGenerator.flareAlerts,
                              arguments: args);
                        }),
                        if (likeNotifs != 0 || commentNotifs != 0)
                          Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                  height: 10.0,
                                  width: 10.0,
                                  decoration: BoxDecoration(
                                      color: Colors.lightGreenAccent.shade400,
                                      border: Border.all(color: Colors.black),
                                      shape: BoxShape.circle)))
                      ])),
                if (myUsername.startsWith('Linkspeak'))
                  Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: buildBorderedIcon(Icons.details, true, () {
                        General.getAndCopyDetails(
                            'Flares/$username', false, context);
                      })),
                if (widget.viewMode == ViewMode.normal && isMyProfile)
                  Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: buildBorderedIcon(
                          Icons.qr_code_2, false, () => _showDialog())),
                if (widget.viewMode == ViewMode.normal)
                  Container(
                      margin: EdgeInsets.only(right: isMyProfile ? 10 : 0),
                      child: buildBorderedIcon(
                          visIcon(flarerVis)!, !isMyProfile, () {})),
                if (widget.viewMode == ViewMode.normal && isMyProfile)
                  Container(
                      margin: EdgeInsets.only(right: 10, left: isRTL ? 10 : 0),
                      child: buildBorderedIcon(
                          Icons.edit_outlined, false, widget.changeToEdit)),
                if (!isMyProfile)
                  Container(
                      height: 25.0,
                      width: 25.0,
                      margin: const EdgeInsets.only(right: 10),
                      child: buildBorderedIcon(Icons.flag, true, () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ReportDialog(
                                  id: username,
                                  postID: '',
                                  isInProfile: false,
                                  isInPost: false,
                                  isInComment: false,
                                  isInReply: false,
                                  commentID: '',
                                  isInClubScreen: false,
                                  isClubPost: false,
                                  clubName: '',
                                  flareProfileID: username,
                                  isInFlareProfile: true,
                                  isInSpotlight: false,
                                  spotlightID: '',
                                  flarePoster: '',
                                  collectionID: '');
                            });
                      }))
              ]),
          ListTile(
              horizontalTitleGap: 5,
              leading: GestureDetector(
                  onTap: () => visitProfile(myUsername, username),
                  child: ChatProfileImage(
                      username: username,
                      factor: 0.05,
                      inEdit: false,
                      asset: null)),
              title: GestureDetector(
                  onTap: () => visitProfile(myUsername, username),
                  child: Text(username,
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,
                          color: Colors.black)))),
          _heightBox,
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: widget.viewMode == ViewMode.normal
                  ? MyLinkify(
                      text: bio,
                      textDirection: null,
                      style: const TextStyle(),
                      maxLines: 10)
                  : TextField(
                      minLines: 3,
                      maxLines: 10,
                      maxLength: 400,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: textController,
                      decoration: InputDecoration(
                          labelText: lang.flares_profile8,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: _primaryColor))))),
          _heightBox,
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                giveStatWidget(numOfFlare, lang.flares_profile9),
                _widthBox,
                giveStatWidget(numOfLikes, lang.flares_profile10),
                _widthBox,
                giveStatWidget(numOfViews, lang.flares_profile11)
              ])
        ]);
  }
}
