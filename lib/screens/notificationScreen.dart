import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/myProfileProvider.dart';
import '../widgets/notificationTile.dart';
import '../widgets/settingsBar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen();
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> getNotifs;
  String _topicNumber(num value) {
    if (value >= 99) {
      return '99+';
    } else {
      return value.toString();
    }
  }

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

    // set values
    firestore.collection('Users').doc('${_myProfile.getUsername}').update({
      'numOfNewLinksNotifs': 0,
      'numOfNewLinkedNotifs': 0,
      'numOfLinkRequestsNotifs': 0,
      'numOfPostLikesNotifs': 0,
      'numOfPostCommentsNotifs': 0,
      'numOfCommentRepliesNotifs': 0,
    });

    // Delete Notifs Documents Values
    //1
    postLikesNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });

    //2
    postCommentsNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    //3
    newLinksNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    //4
    newLinkedNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    //5
    linkRequestsNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });
    //6
    commentRepliesNotifsCollection.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        doc.reference.delete();
      }
    });

    // Set Provider
    _myProfile.zero();
  }

  Future addCollection(String collectionName) async {
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    await firestore
        .collection('Users')
        .doc('${_myProfile.getUsername}')
        .collection('$collectionName')
        .doc()
        .set({'0': 1});
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
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final ThemeData _theme = Theme.of(context);
    final Color _primarySwatch = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: null,
      body: FutureBuilder(
          future: getNotifs,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SettingsBar('Alerts'),
                        const Spacer(),
                        const CircularProgressIndicator(),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SettingsBar('Alerts'),
                        const Spacer(),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                'An unknown error has occured',
                                style: TextStyle(color: Colors.grey),
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
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                onPressed: () => setState(() {}),
                                child: Center(
                                  child: Text(
                                    'Retry',
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
                  ),
                ),
              );
            }
            final MyProfile myProfile = Provider.of<MyProfile>(context);
            final int myNumOfNewLinksNotifs = myProfile.myNumOfNewLinksNotifs;
            final int myNumOfNewLinkedNotifs = myProfile.myNumOfNewLinkedNotifs;
            final int myNumOfLinkRequestNotifs =
                myProfile.myNumOfLinkRequestNotifs;
            final int myNumOfPostLikesNotifs = myProfile.myNumOfPostLikesNotifs;
            final int myNumOfPostCommentsNotifs =
                myProfile.myNumOfPostCommentsNotifs;
            final int myNumOfCommentRepliesNotifs =
                myProfile.myNumOfCommentRepliesNotifs;
            final int myNumOfCommentsRemovedNotifs =
                myProfile.myNumOfCommentsRemovedNotifs;
            final int myNumOfPostsRemovedNotifs =
                myProfile.myNumOfPostsRemovedNotifs;
            final bool hasNotifications = myNumOfNewLinksNotifs != 0 ||
                myNumOfNewLinkedNotifs != 0 ||
                myNumOfLinkRequestNotifs != 0 ||
                myNumOfPostLikesNotifs != 0 ||
                myNumOfPostCommentsNotifs != 0 ||
                myNumOfCommentRepliesNotifs != 0 ||
                myNumOfCommentsRemovedNotifs != 0 ||
                myNumOfPostsRemovedNotifs != 0;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 7.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      const SettingsBar('Alerts'),
                      if (hasNotifications)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    return Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: 150.0,
                                          maxWidth: 150.0,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              const Text(
                                                'Clear alerts',
                                                softWrap: false,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontFamily: 'Roboto',
                                                  fontSize: 19.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const Divider(
                                                thickness: 1.0,
                                                indent: 0.0,
                                                endIndent: 0.0,
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  TextButton(
                                                    style: ButtonStyle(
                                                        splashFactory: NoSplash
                                                            .splashFactory),
                                                    onPressed: () async {
                                                      await removeAllNotification();
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    style: ButtonStyle(
                                                        splashFactory: NoSplash
                                                            .splashFactory),
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text(
                                                      'No',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Center(
                                child: const Text(
                                  'Clear all alerts',
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
                              onPressed: () => Navigator.pushNamed(context,
                                  RouteGenerator.notificationSettingScreen),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                      child: const Text(
                                        'You have no new alerts',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 25.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : NotificationListener<
                                  OverscrollIndicatorNotification>(
                                  onNotification: (overscroll) {
                                    overscroll.disallowGlow();
                                    return false;
                                  },
                                  child: ListView(
                                    children: <Widget>[
                                      if (myNumOfPostLikesNotifs != 0)
                                        NotificationTile(
                                          title: 'Likes',
                                          mykey: null,
                                          icon: customIcons.MyFlutterApp.upvote,
                                          mainIconColor: _primarySwatch,
                                          badgeColor:
                                              Colors.lightGreenAccent.shade700,
                                          badgeText:
                                              '${_topicNumber(myNumOfPostLikesNotifs)}',
                                          navigate: true,
                                          routeName: RouteGenerator
                                              .postLikesNotifScreen,
                                          enabled: true,
                                        ),
                                      if (myNumOfNewLinksNotifs != 0)
                                        NotificationTile(
                                          title: 'New links',
                                          mykey: null,
                                          icon: Icons.person_add,
                                          mainIconColor: _primarySwatch,
                                          badgeColor:
                                              Colors.lightGreenAccent.shade700,
                                          badgeText:
                                              '${_topicNumber(myNumOfNewLinksNotifs)}',
                                          navigate: true,
                                          routeName:
                                              RouteGenerator.linksNotifsScreen,
                                          enabled: true,
                                        ),
                                      if (myNumOfLinkRequestNotifs != 0)
                                        NotificationTile(
                                          title: 'Link requests',
                                          mykey: null,
                                          icon: Icons.link,
                                          mainIconColor: _primarySwatch,
                                          badgeColor:
                                              Colors.lightGreenAccent.shade700,
                                          badgeText:
                                              '${_topicNumber(myNumOfLinkRequestNotifs)}',
                                          navigate: true,
                                          routeName:
                                              RouteGenerator.linkRequestScreen,
                                          enabled: true,
                                        ),
                                      if (myNumOfNewLinkedNotifs != 0)
                                        NotificationTile(
                                          title: 'Linked',
                                          mykey: null,
                                          icon: Icons.people,
                                          mainIconColor: _primarySwatch,
                                          badgeColor:
                                              Colors.lightGreenAccent.shade700,
                                          badgeText:
                                              '${_topicNumber(myNumOfNewLinkedNotifs)}',
                                          navigate: true,
                                          routeName:
                                              RouteGenerator.linkedNotifScreen,
                                          enabled: true,
                                        ),
                                      if (myNumOfPostCommentsNotifs != 0)
                                        NotificationTile(
                                          title: 'Comments',
                                          mykey: null,
                                          icon: Icons.chat_bubble_rounded,
                                          mainIconColor: _primarySwatch,
                                          badgeColor:
                                              Colors.lightGreenAccent.shade700,
                                          badgeText:
                                              '${_topicNumber(myNumOfPostCommentsNotifs)}',
                                          navigate: true,
                                          routeName: RouteGenerator
                                              .postCommentsNotifScreen,
                                          enabled: true,
                                        ),
                                      if (myNumOfCommentRepliesNotifs != 0)
                                        NotificationTile(
                                          title: 'Replies',
                                          mykey: null,
                                          icon: Icons.reply_all_rounded,
                                          mainIconColor: _primarySwatch,
                                          badgeColor:
                                              Colors.lightGreenAccent.shade700,
                                          badgeText:
                                              '${_topicNumber(myNumOfCommentRepliesNotifs)}',
                                          navigate: true,
                                          routeName: RouteGenerator
                                              .commentRepliesNotifScreen,
                                          enabled: true,
                                        ),
                                      if (myNumOfCommentsRemovedNotifs != 0)
                                        NotificationTile(
                                          title: 'Comments removed',
                                          mykey: null,
                                          icon: Icons.warning,
                                          mainIconColor: Colors.red,
                                          badgeColor: Colors.red,
                                          badgeText:
                                              '${_topicNumber(myNumOfCommentsRemovedNotifs)}',
                                          navigate: false,
                                          routeName: null,
                                          enabled: false,
                                        ),
                                      if (myNumOfPostsRemovedNotifs != 0)
                                        NotificationTile(
                                          title: 'Posts removed',
                                          mykey: null,
                                          icon: Icons.warning,
                                          mainIconColor: Colors.red,
                                          badgeColor: Colors.red,
                                          badgeText:
                                              '${_topicNumber(myNumOfPostsRemovedNotifs)}',
                                          navigate: false,
                                          routeName: null,
                                          enabled: false,
                                        ),
                                    ],
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
