import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile.dart';
import '../models/profiler.dart';
import '../providers/otherProfileProvider.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/adaptiveText.dart';
import '../widgets/title.dart';
import '../widgets/profile.dart' as profWidget;
import '../widgets/popUpMenuButton.dart';
import '../widgets/myFab.dart';
import '../my_flutter_app_icons.dart' as customIcon;

class OtherProfileScreen extends StatefulWidget {
  final dynamic userID;

  const OtherProfileScreen({required this.userID});

  @override
  _OtherProfileScreenState createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final ScrollController scrollController;
  late Profiler profile;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  TheVisibility generateVis(String vis) {
    if (vis == 'Public') {
      return TheVisibility.public;
    } else if (vis == 'Private') {
      return TheVisibility.private;
    }
    return TheVisibility.private;
  }

  Future<void> getProfile(
    String _myUsername,
    List<String> myBlockedIDs,
  ) async {
    final _theUser = firestore.collection('Users').doc(widget.userID);
    final _thisUser = await _theUser.get();
    final userLinks = await _theUser.collection('Links').doc(_myUsername).get();
    final userBlocks =
        await _theUser.collection('Blocked').doc(_myUsername).get();
    final userRequests =
        await _theUser.collection('LinkRequestsNotifs').doc(_myUsername).get();
    final myLinks = await firestore
        .collection('Users')
        .doc(_myUsername)
        .collection('Links')
        .doc(widget.userID)
        .get();
    final imLinkedToThem = userLinks.exists;
    final imBlocked = userBlocks.exists;
    final requestSent = userRequests.exists;
    final isLinked = myLinks.exists;
    final isBlocked = myBlockedIDs.contains(widget.userID);
    getter(String field) => _thisUser.get(field);
    final String activity = getter('Activity');
    final String serverVis = getter('Visibility');
    final TheVisibility vis = generateVis(serverVis);
    final String username = getter('Username');
    final String imgUrl = getter('Avatar');
    final String bio = getter('Bio');
    final int numOfLinks = getter('numOfLinks');
    final int numOfLinkedTo = getter('numOfLinked');
    final int numOfPosts = getter('numOfPosts');
    final serverTopics = getter('Topics') as List;
    final List<String> topics =
        serverTopics.map((topic) => topic as String).toList();
    final OtherProfile instance = OtherProfile();
    profile = Profiler(
      imLinkedtoThem: imLinkedToThem,
      isBlocked: isBlocked,
      imBlocked: imBlocked,
      linkedToMe: isLinked,
      linkRequestSent: requestSent,
      otherProfileProvider: instance,
      visibility: vis,
      username: username,
      imgUrl: imgUrl,
      bio: bio,
      numOfLinks: numOfLinks,
      numOfLinkedTo: numOfLinkedTo,
      numOfPosts: numOfPosts,
      topics: topics,
      posts: [],
      activityStatus: activity,
    );
  }

  Widget build(BuildContext context) {
    final Color _primarySwatch = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final List<String> myBlockedIDs =
        Provider.of<MyProfile>(context, listen: false).getBlockedIDs;
    Future<void> _getProfile = getProfile(_myUsername, myBlockedIDs);

    return Scaffold(
      backgroundColor: Colors.white10,
      floatingActionButton: MyFab(scrollController),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
          future: _getProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SafeArea(
                child: Container(
                  color: Colors.white12,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const CircularProgressIndicator(),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: OptimisedText(
                          minWidth: _deviceWidth * 0.5,
                          maxWidth: _deviceWidth * 0.65,
                          minHeight: 50.0,
                          maxHeight: 50.0,
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: <Widget>[
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
                                    customIcon.MyFlutterApp.curve_arrow,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const MyTitle(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return SafeArea(
                child: Container(
                  color: Colors.white12,
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
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry?>(
                                      const EdgeInsets.symmetric(
                                        vertical: 1.0,
                                        horizontal: 5.0,
                                      ),
                                    ),
                                    enableFeedback: false,
                                    backgroundColor:
                                        MaterialStateProperty.all<Color?>(
                                            _primarySwatch),
                                  ),
                                  onPressed: () {
                                    setState(() {});
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: OptimisedText(
                          minWidth: _deviceWidth * 0.5,
                          maxWidth: _deviceWidth * 0.65,
                          minHeight: 50.0,
                          maxHeight: 50.0,
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: <Widget>[
                              Builder(
                                builder: (context) {
                                  return IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    splashColor: Colors.transparent,
                                    icon: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: const Icon(
                                        customIcon.MyFlutterApp.curve_arrow,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const MyTitle(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final Widget _heightBox = SizedBox(
              height: _deviceHeight * 0.07,
            );
            final Widget _title = Align(
              alignment: Alignment.topLeft,
              child: PreferredSize(
                preferredSize: Size.fromHeight(_deviceHeight * 0.05),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  title: const MyTitle(),
                ),
              ),
            );

            return SafeArea(
              child: ChangeNotifierProvider.value(
                value: profile.otherProfileProvider,
                child: Builder(
                  builder: (context) {
                    final OtherProfile profileNo =
                        Provider.of<OtherProfile>(context, listen: false);
                    profileNo.setter(
                      linkedToThem: profile.imLinkedtoThem,
                      linkedTOMe: profile.linkedToMe,
                      imBlocked: profile.imBlocked,
                      isBlocked: profile.isBlocked,
                      requestSent: profile.linkRequestSent,
                      vis: profile.visibility,
                      imgUrl: profile.imgUrl,
                      username: profile.username,
                      bio: profile.bio,
                      numOfLinks: profile.numOfLinks,
                      numOfLinked: profile.numOfLinkedTo,
                      topics: profile.topics,
                      numOfPosts: profile.numOfPosts,
                      postIDs: profile.posts,
                      activity: profile.activityStatus,
                    );
                    return Builder(
                      builder: (context) {
                        final OtherProfile _profile =
                            Provider.of<OtherProfile>(context);
                        final OtherProfile _profileNoListen =
                            Provider.of<OtherProfile>(context, listen: false);
                        final block = _profileNoListen.block;
                        final unblock = _profileNoListen.unblock;
                        final remove = _profileNoListen.removeThem;
                        final visibility = _profile.getVisibility;
                        final img = _profile.getProfileImage;
                        final username = _profile.getUsername;
                        final bio = _profile.getBio;
                        final numOfLinks = _profile.getNumberOflinks;
                        final numOfLinked = _profile.getNumberOfLinkedTos;
                        final numOfPosts = _profile.getNumberOfPosts;
                        final topics = _profile.getTopics;
                        final imLinkedToThem = profile.imLinkedtoThem;
                        final isBlocked = _profile.isBlocked;
                        final isLinkedToMe = _profile.linkedToMe;
                        final dynamic _rightButton = Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: Transform.rotate(
                            angle: 90 * pi / 180,
                            child: PopupMenuButton(
                              tooltip: 'More',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              padding: const EdgeInsets.all(0.0),
                              child: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 31.0,
                              ),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  padding: const EdgeInsets.all(0.0),
                                  enabled: true,
                                  child: MyPopUpMenuButton(
                                    id: widget.userID,
                                    postID: '',
                                    isInProfile: true,
                                    postedByMe: false,
                                    postTopics: [],
                                    postMedia: [],
                                    postDate: DateTime.now(),
                                    isBlocked: isBlocked,
                                    isLinkedToMe: isLinkedToMe,
                                    block: block,
                                    unblock: unblock,
                                    remove: remove,
                                    hidePost: () {},
                                    deletePost: () {},
                                    unhidePost: () {},
                                    previewSetstate: (){},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        final Widget theprofile = profWidget.Profile(
                          isMyProfile: false,
                          imLinkedToThem: imLinkedToThem,
                          visibility: visibility,
                          imageUrl: img,
                          username: username,
                          bio: bio,
                          numOfLinks: numOfLinks,
                          numOfLinkedTos: numOfLinked,
                          numOfPosts: numOfPosts,
                          addTopic: () {},
                          topicNames: topics,
                          removeTopic: () {},
                          rightButton: _rightButton,
                          handler: null,
                          scrollController: scrollController,
                          instance: profile.otherProfileProvider,
                          imBlocked: profile.imBlocked,
                        );
                        final Widget _otherProfile = NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowGlow();
                            return false;
                          },
                          child: ListView(
                            controller: scrollController,
                            children: <Widget>[
                              _heightBox,
                              theprofile,
                            ],
                          ),
                        );
                        return Stack(
                          children: <Widget>[
                            _title,
                            _otherProfile,
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          }),
    );
  }
}
