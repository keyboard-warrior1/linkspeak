import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/alerts/notificationTile.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen();
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> getNotifs;
  removeAllNotification() async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    final postLikesNotifsCollection = firestore
        .collection('Users')
        .doc('${_myProfile.getUsername}')
        .collection('PostLikesNotifs')
        .get();
    final postCommentsNotifsCollection = firestore
        .collection('Users')
        .doc('${_myProfile.getUsername}')
        .collection('PostCommentsNotifs')
        .get();
    final newLinksNotifsCollection = firestore
        .collection('Users')
        .doc('${_myProfile.getUsername}')
        .collection('NewLinksNotifs')
        .get();
    final newLinkedNotifsCollection = firestore
        .collection('Users')
        .doc('${_myProfile.getUsername}')
        .collection('NewLinkedNotifs')
        .get();
    final linkRequestsNotifsCollection = firestore
        .collection('Users')
        .doc('${_myProfile.getUsername}')
        .collection('LinkRequestsNotifs')
        .get();
    final commentRepliesNotifsCollection = firestore
        .collection('Users')
        .doc('${_myProfile.getUsername}')
        .collection('CommentRepliesNotifs')
        .get();
    final mentionBox = firestore
        .collection('Users')
        .doc('${_myProfile.getUsername}')
        .collection('Mention Box')
        .get();
    firestore.collection('Users').doc('${_myProfile.getUsername}').update({
      'numOfNewLinksNotifs': 0,
      'numOfNewLinkedNotifs': 0,
      'numOfLinkRequestsNotifs': 0,
      'numOfPostLikesNotifs': 0,
      'numOfPostCommentsNotifs': 0,
      'numOfCommentRepliesNotifs': 0,
      'PostsRemoved': 0,
      'CommentsRemoved': 0,
      'repliesRemoved': 0,
      'numOfMentions': 0,
    });

    postLikesNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });

    postCommentsNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    newLinksNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    newLinkedNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    linkRequestsNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    commentRepliesNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    mentionBox.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    _myProfile.zero();
  }

  Future<void> getNotifications({
    required String myUsername,
    required dynamic setNumOfNewLinksNotifs,
    required dynamic setNumOfNewLinkedNotifs,
    required dynamic setNumOfLinkRequestNotifs,
    required dynamic setNumOfPostLikesNotifs,
    required dynamic setNumOfPostCommentsNotifs,
    required dynamic setNumOfCommentRepliesNotifs,
    required dynamic setmyNumOfPostsRemovedNotifs,
    required dynamic setNumOfCommentsRemovedNotifs,
    required dynamic setNumOfRepliesRemovedNotifs,
    required dynamic setNumOfMentions,
  }) async {
    final myUser = await firestore.collection('Users').doc('$myUsername').get();
    final numOfNewLinksNotifs = myUser.get('numOfNewLinksNotifs');
    setNumOfNewLinksNotifs(numOfNewLinksNotifs);
    final numOfNewLinkedNotifs = myUser.get('numOfNewLinkedNotifs');
    setNumOfNewLinkedNotifs(numOfNewLinkedNotifs);
    final numOfLinkRequestsNotifs = myUser.get('numOfLinkRequestsNotifs');
    setNumOfLinkRequestNotifs(numOfLinkRequestsNotifs);
    final numOfPostLikesNotifs = myUser.get('numOfPostLikesNotifs');
    setNumOfPostLikesNotifs(numOfPostLikesNotifs);
    final numOfPostCommentsNotifs = myUser.get('numOfPostCommentsNotifs');
    setNumOfPostCommentsNotifs(numOfPostCommentsNotifs);
    final numOfCommentRepliesNotifs = myUser.get('numOfCommentRepliesNotifs');
    setNumOfCommentRepliesNotifs(numOfCommentRepliesNotifs);
    final postsRemoved = myUser.get('PostsRemoved');
    setmyNumOfPostsRemovedNotifs(postsRemoved);
    final commentsRemoved = myUser.get('CommentsRemoved');
    setNumOfCommentsRemovedNotifs(commentsRemoved);
    final repliesRemoved = myUser.get('repliesRemoved');
    setNumOfRepliesRemovedNotifs(repliesRemoved);
    final newMentions = myUser.get('numOfMentions');
    setNumOfMentions(newMentions);
  }

  @override
  void initState() {
    final MyProfile myProfileNo =
        Provider.of<MyProfile>(context, listen: false);
    final String _myUsername = myProfileNo.getUsername;
    final void Function(int) setNumOfNewLinksNotifs =
        myProfileNo.setNumOfNewLinksNotifs;
    final void Function(int) setNumOfNewLinkedNotifs =
        myProfileNo.setNumOfNewLinkedNotifs;
    final void Function(int) setNumOfLinkRequestNotifs =
        myProfileNo.setNumOfLinkRequestNotifs;
    final void Function(int) setNumOfPostLikesNotifs =
        myProfileNo.setNumOfPostLikesNotifs;
    final void Function(int) setNumOfPostCommentsNotifs =
        myProfileNo.setNumOfPostCommentsNotifs;
    final void Function(int) setNumOfCommentRepliesNotifs =
        myProfileNo.setNumOfCommentRepliesNotifs;
    final void Function(int) setNumOfCommentsRemovedNotifs =
        myProfileNo.setNumOfCommentsRemovedNotifs;
    final void Function(int) setmyNumOfPostsRemovedNotifs =
        myProfileNo.setmyNumOfPostsRemovedNotifs;
    final void Function(int) setNumOfRepliesRemoved =
        myProfileNo.setMyNumOfRepliessRemovedNotifs;
    final void Function(int) setNumOfMentions = myProfileNo.setNumOfNewMentions;
    getNotifs = getNotifications(
      myUsername: _myUsername,
      setNumOfNewLinksNotifs: setNumOfNewLinksNotifs,
      setNumOfNewLinkedNotifs: setNumOfNewLinkedNotifs,
      setNumOfLinkRequestNotifs: setNumOfLinkRequestNotifs,
      setNumOfPostLikesNotifs: setNumOfPostLikesNotifs,
      setNumOfPostCommentsNotifs: setNumOfPostCommentsNotifs,
      setNumOfCommentRepliesNotifs: setNumOfCommentRepliesNotifs,
      setmyNumOfPostsRemovedNotifs: setmyNumOfPostsRemovedNotifs,
      setNumOfCommentsRemovedNotifs: setNumOfCommentsRemovedNotifs,
      setNumOfRepliesRemovedNotifs: setNumOfRepliesRemoved,
      setNumOfMentions: setNumOfMentions,
    );
    super.initState();
  }

  void _showDialog(dynamic lang) {
    showDialog(
        context: context,
        builder: (_) {
          return Center(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 150.0, maxWidth: 150.0),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(lang.screens_notifications1,
                                softWrap: false,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                    fontFamily: 'Roboto',
                                    fontSize: 19.0,
                                    color: Colors.black)),
                            const Divider(
                                thickness: 1.0, indent: 0.0, endIndent: 0.0),
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () async {
                                        await removeAllNotification();
                                        Navigator.pop(context);
                                      },
                                      child: Text(lang.clubs_alerts3,
                                          style: const TextStyle(
                                              color: Colors.red))),
                                  TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(lang.clubs_alerts4,
                                          style: const TextStyle(
                                              color: Colors.red)))
                                ])
                          ]))));
        });
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final ThemeData _theme = Theme.of(context);
    final Color _primarySwatch = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final MyProfile myProfileNo =
        Provider.of<MyProfile>(context, listen: false);
    final String _myUsername = myProfileNo.getUsername;
    final void Function(int) setNumOfNewLinksNotifs =
        myProfileNo.setNumOfNewLinksNotifs;
    final void Function(int) setNumOfNewLinkedNotifs =
        myProfileNo.setNumOfNewLinkedNotifs;
    final void Function(int) setNumOfLinkRequestNotifs =
        myProfileNo.setNumOfLinkRequestNotifs;
    final void Function(int) setNumOfPostLikesNotifs =
        myProfileNo.setNumOfPostLikesNotifs;
    final void Function(int) setNumOfPostCommentsNotifs =
        myProfileNo.setNumOfPostCommentsNotifs;
    final void Function(int) setNumOfCommentRepliesNotifs =
        myProfileNo.setNumOfCommentRepliesNotifs;
    final void Function(int) setNumOfCommentsRemovedNotifs =
        myProfileNo.setNumOfCommentsRemovedNotifs;
    final void Function(int) setmyNumOfPostsRemovedNotifs =
        myProfileNo.setmyNumOfPostsRemovedNotifs;
    final void Function(int) setNumOfRepliesRemoved =
        myProfileNo.setMyNumOfRepliessRemovedNotifs;
    final void Function(int) setMyNumOfMentions =
        myProfileNo.setNumOfNewMentions;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 7.0),
                child: FutureBuilder(
                    future: getNotifs,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SettingsBar(lang.screens_notifications2),
                              const Spacer(),
                              const Icon(Icons.notifications_outlined),
                              const Spacer(),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SettingsBar(lang.screens_notifications2),
                              const Spacer(),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      lang.clubs_adminScreen2,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(width: 15.0),
                                    TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color?>(
                                          _primarySwatch,
                                        ),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry?>(
                                          const EdgeInsets.all(0.0),
                                        ),
                                        shape: MaterialStateProperty.all<
                                            OutlinedBorder?>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      onPressed: () => setState(() {
                                        getNotifs = getNotifications(
                                          myUsername: _myUsername,
                                          setNumOfNewLinksNotifs:
                                              setNumOfNewLinksNotifs,
                                          setNumOfNewLinkedNotifs:
                                              setNumOfNewLinkedNotifs,
                                          setNumOfLinkRequestNotifs:
                                              setNumOfLinkRequestNotifs,
                                          setNumOfPostLikesNotifs:
                                              setNumOfPostLikesNotifs,
                                          setNumOfPostCommentsNotifs:
                                              setNumOfPostCommentsNotifs,
                                          setNumOfCommentRepliesNotifs:
                                              setNumOfCommentRepliesNotifs,
                                          setmyNumOfPostsRemovedNotifs:
                                              setmyNumOfPostsRemovedNotifs,
                                          setNumOfCommentsRemovedNotifs:
                                              setNumOfCommentsRemovedNotifs,
                                          setNumOfRepliesRemovedNotifs:
                                              setNumOfRepliesRemoved,
                                          setNumOfMentions: setMyNumOfMentions,
                                        );
                                      }),
                                      child: Center(
                                        child: Text(
                                          lang.clubs_adminScreen3,
                                          style: TextStyle(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        );
                      }
                      final MyProfile myProfile =
                          Provider.of<MyProfile>(context);
                      final int myNumOfNewLinksNotifs =
                          myProfile.myNumOfNewLinksNotifs;
                      final int myNumOfNewLinkedNotifs =
                          myProfile.myNumOfNewLinkedNotifs;
                      final int myNumOfRepliesRemoved =
                          myProfile.myNumOfRepliesRemovedNotifs;
                      final int myNumOfLinkRequestNotifs =
                          myProfile.myNumOfLinkRequestNotifs;
                      final int myNumOfPostLikesNotifs =
                          myProfile.myNumOfPostLikesNotifs;
                      final int myNumOfPostCommentsNotifs =
                          myProfile.myNumOfPostCommentsNotifs;
                      final int myNumOfCommentRepliesNotifs =
                          myProfile.myNumOfCommentRepliesNotifs;
                      final int myNumOfCommentsRemovedNotifs =
                          myProfile.myNumOfCommentsRemovedNotifs;
                      final int myNumOfPostsRemovedNotifs =
                          myProfile.myNumOfPostsRemovedNotifs;
                      final int myNumOfMentions = myProfile.myNumOfMentions;
                      final bool hasNotifications =
                          myNumOfNewLinksNotifs != 0 ||
                              myNumOfNewLinkedNotifs != 0 ||
                              myNumOfLinkRequestNotifs != 0 ||
                              myNumOfPostLikesNotifs != 0 ||
                              myNumOfPostCommentsNotifs != 0 ||
                              myNumOfCommentRepliesNotifs != 0 ||
                              myNumOfCommentsRemovedNotifs != 0 ||
                              myNumOfPostsRemovedNotifs != 0 ||
                              myNumOfRepliesRemoved != 0 ||
                              myNumOfMentions != 0;

                      return Center(
                        child: Column(
                          children: <Widget>[
                            SettingsBar(lang.screens_notifications2),
                            if (hasNotifications)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () => {},
                                    icon: const Icon(
                                      Icons.settings,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      _showDialog(lang);
                                    },
                                    child: Center(
                                      child: Text(
                                        lang.screens_notifications3,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 23,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context,
                                        RouteGenerator
                                            .notificationSettingScreen),
                                    icon: const Icon(
                                      Icons.settings,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            Expanded(
                              child: SizedBox(
                                height: _deviceHeight * 91,
                                width: double.infinity,
                                child: (!hasNotifications)
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Center(
                                            child: const Icon(
                                              Icons.notifications,
                                              size: 45.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15.0,
                                          ),
                                          Center(
                                            child: Text(
                                              lang.screens_notifications4,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 25.0),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Noglow(
                                        child: ListView(
                                          children: <Widget>[
                                            if (myNumOfPostLikesNotifs != 0)
                                              NotificationTile(
                                                title:
                                                    lang.screens_notifications5,
                                                mykey: null,
                                                badgeColor: Colors
                                                    .lightGreenAccent.shade700,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfPostLikesNotifs)}',
                                                navigate: true,
                                                routeName: RouteGenerator
                                                    .postLikesNotifScreen,
                                                enabled: true,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                            if (myNumOfMentions != 0)
                                              NotificationTile(
                                                title:
                                                    lang.screens_notifications6,
                                                mykey: null,
                                                badgeColor: Colors
                                                    .lightGreenAccent.shade700,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfMentions)}',
                                                navigate: true,
                                                routeName: RouteGenerator
                                                    .mentionsScreen,
                                                enabled: true,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                            if (myNumOfNewLinksNotifs != 0)
                                              NotificationTile(
                                                title:
                                                    lang.screens_notifications7,
                                                mykey: null,
                                                badgeColor: Colors
                                                    .lightGreenAccent.shade700,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfNewLinksNotifs)}',
                                                navigate: true,
                                                routeName: RouteGenerator
                                                    .linksNotifsScreen,
                                                enabled: true,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                            if (myNumOfLinkRequestNotifs != 0)
                                              NotificationTile(
                                                title:
                                                    lang.screens_notifications8,
                                                mykey: null,
                                                badgeColor: Colors
                                                    .lightGreenAccent.shade700,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfLinkRequestNotifs)}',
                                                navigate: true,
                                                routeName: RouteGenerator
                                                    .linkRequestScreen,
                                                enabled: true,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                            if (myNumOfNewLinkedNotifs != 0)
                                              NotificationTile(
                                                title:
                                                    lang.screens_notifications9,
                                                mykey: null,
                                                badgeColor: Colors
                                                    .lightGreenAccent.shade700,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfNewLinkedNotifs)}',
                                                navigate: true,
                                                routeName: RouteGenerator
                                                    .linkedNotifScreen,
                                                enabled: true,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                            if (myNumOfPostCommentsNotifs != 0)
                                              NotificationTile(
                                                title: lang
                                                    .screens_notifications10,
                                                mykey: null,
                                                badgeColor: Colors
                                                    .lightGreenAccent.shade700,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfPostCommentsNotifs)}',
                                                navigate: true,
                                                routeName: RouteGenerator
                                                    .postCommentsNotifScreen,
                                                enabled: true,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                            if (myNumOfCommentRepliesNotifs !=
                                                0)
                                              NotificationTile(
                                                title: lang
                                                    .screens_notifications11,
                                                mykey: null,
                                                badgeColor: Colors
                                                    .lightGreenAccent.shade700,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfCommentRepliesNotifs)}',
                                                navigate: true,
                                                routeName: RouteGenerator
                                                    .commentRepliesNotifScreen,
                                                enabled: true,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                            if (myNumOfCommentsRemovedNotifs !=
                                                0)
                                              NotificationTile(
                                                title: lang
                                                    .screens_notifications12,
                                                mykey: null,
                                                badgeColor: Colors.red,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfCommentsRemovedNotifs)}',
                                                navigate: false,
                                                routeName: null,
                                                enabled: false,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                            if (myNumOfPostsRemovedNotifs != 0)
                                              NotificationTile(
                                                title: lang
                                                    .screens_notifications13,
                                                mykey: null,
                                                badgeColor: Colors.red,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfPostsRemovedNotifs)}',
                                                navigate: false,
                                                routeName: null,
                                                enabled: false,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                            if (myNumOfRepliesRemoved != 0)
                                              NotificationTile(
                                                title: lang
                                                    .screens_notifications14,
                                                mykey: null,
                                                badgeColor: Colors.red,
                                                badgeText:
                                                    '${General.topicNumber(myNumOfRepliesRemoved)}',
                                                navigate: false,
                                                routeName: null,
                                                enabled: false,
                                                isClub: false,
                                                isFlare: false,
                                                username: '',
                                                clubName: '',
                                                decreaseNotifs: () {},
                                                addMembers: () {},
                                              ),
                                          ],
                                        ),
                                      ),
                              ),
                            )
                          ],
                        ),
                      );
                    }))));
  }
}
