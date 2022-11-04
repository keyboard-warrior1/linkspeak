import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings();

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  final firestore = FirebaseFirestore.instance;
  bool flareLikeAlerts = true;
  bool flareCommentAlerts = true;
  bool likeAlerts = true;
  bool replyAlerts = true;
  bool commentAlerts = true;
  bool linksAlert = true;
  bool linkedAlert = true;
  bool mentionAlert = true;
  late Future<void> _getSettings;
  Future<void> getSettings(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    final getMe = await myUser.get();
    if (getMe.data()!.containsKey('AllowFlareLikes')) {
      final value = getMe.get('AllowFlareLikes');
      flareLikeAlerts = value;
    }
    if (getMe.data()!.containsKey('AllowFlareComments')) {
      final value = getMe.get('AllowFlareComments');
      flareCommentAlerts = value;
    }
    if (getMe.data()!.containsKey('AllowLikes')) {
      final value = getMe.get('AllowLikes');
      likeAlerts = value;
    }
    if (getMe.data()!.containsKey('AllowReplies')) {
      final value = getMe.get('AllowReplies');
      replyAlerts = value;
    }
    if (getMe.data()!.containsKey('AllowComments')) {
      final value = getMe.get('AllowComments');
      commentAlerts = value;
    }
    if (getMe.data()!.containsKey('AllowLinks')) {
      final value = getMe.get('AllowLinks');
      linksAlert = value;
    }
    if (getMe.data()!.containsKey('AllowLinked')) {
      final value = getMe.get('AllowLinked');
      linkedAlert = value;
    }

    if (getMe.data()!.containsKey('AllowMentions')) {
      final value = getMe.get('AllowMentions');
      mentionAlert = value;
    }
  }

  Widget giveSwitch(
      {required bool value,
      required Future<void> Function(String) handler,
      required String description,
      required String myUsername,
      required Color primaryColor}) {
    return SwitchListTile(
      activeColor: primaryColor,
      value: value,
      onChanged: (_) => handler(myUsername),
      title: Text(
        description,
        style: TextStyle(
          color: Colors.black,
          fontSize: 15.0,
        ),
      ),
    );
  }

  Future<void> mentionHandler(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    if (mentionAlert) {
      setState(() {
        mentionAlert = false;
      });
      return myUser.set({'AllowMentions': false}, SetOptions(merge: true));
    } else {
      setState(() {
        mentionAlert = true;
      });
      return myUser.set({'AllowMentions': true}, SetOptions(merge: true));
    }
  }

  Future<void> flareLikeHandler(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    if (flareLikeAlerts) {
      setState(() {
        flareLikeAlerts = false;
      });
      return myUser.set({'AllowFlareLikes': false}, SetOptions(merge: true));
    } else {
      setState(() {
        flareLikeAlerts = true;
      });
      return myUser.set({'AllowFlareLikes': true}, SetOptions(merge: true));
    }
  }

  Future<void> flareCommentHandler(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    if (flareCommentAlerts) {
      setState(() {
        flareCommentAlerts = false;
      });
      return myUser.set({'AllowFlareComments': false}, SetOptions(merge: true));
    } else {
      setState(() {
        flareCommentAlerts = true;
      });
      return myUser.set({'AllowFlareComments': true}, SetOptions(merge: true));
    }
  }

  Future<void> likeHandler(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    if (likeAlerts) {
      setState(() {
        likeAlerts = false;
      });
      return myUser.set({'AllowLikes': false}, SetOptions(merge: true));
    } else {
      setState(() {
        likeAlerts = true;
      });
      return myUser.set({'AllowLikes': true}, SetOptions(merge: true));
    }
  }

  Future<void> commentHandler(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    if (commentAlerts) {
      setState(() {
        commentAlerts = false;
      });
      return myUser.set({'AllowComments': false}, SetOptions(merge: true));
    } else {
      setState(() {
        commentAlerts = true;
      });
      return myUser.set({'AllowComments': true}, SetOptions(merge: true));
    }
  }

  Future<void> replyHandler(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    if (replyAlerts) {
      setState(() {
        replyAlerts = false;
      });
      return myUser.set({'AllowReplies': false}, SetOptions(merge: true));
    } else {
      setState(() {
        replyAlerts = true;
      });
      return myUser.set({'AllowReplies': true}, SetOptions(merge: true));
    }
  }

  Future<void> linksHandler(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    if (linksAlert) {
      setState(() {
        linksAlert = false;
      });
      return myUser.set({'AllowLinks': false}, SetOptions(merge: true));
    } else {
      setState(() {
        linksAlert = true;
      });
      return myUser.set({'AllowLinks': true}, SetOptions(merge: true));
    }
  }

  Future<void> linkedHandler(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    if (linkedAlert) {
      setState(() {
        linkedAlert = false;
      });
      return myUser.set({'AllowLinked': false}, SetOptions(merge: true));
    } else {
      setState(() {
        linkedAlert = true;
      });
      return myUser.set({'AllowLinked': true}, SetOptions(merge: true));
    }
  }

  @override
  void initState() {
    super.initState();
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getSettings = getSettings(myUsername);
  }

  @override
  Widget build(BuildContext context) {
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _primarySwatch = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    const Widget _heightBox = const SizedBox(height: 10);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: _getSettings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SettingsBar('Alert settings'),
                    const Spacer(),
                    const CircularProgressIndicator(strokeWidth: 1.50),
                    const Spacer(),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SettingsBar('Alert settings'),
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
                              shape: MaterialStateProperty.all<OutlinedBorder?>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            onPressed: () => setState(() {
                              _getSettings = getSettings(_myUsername);
                            }),
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
              );
            }
            return SizedBox(
              height: _deviceHeight,
              width: _deviceWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SettingsBar('Alert settings'),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Notify me when',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Expanded(
                    child: Noglow(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          giveSwitch(
                            value: mentionAlert,
                            handler: mentionHandler,
                            description: "I'm mentioned",
                            myUsername: _myUsername,
                            primaryColor: _primarySwatch,
                          ),
                          _heightBox,
                          giveSwitch(
                            value: linksAlert,
                            handler: linksHandler,
                            description: 'I get new links',
                            myUsername: _myUsername,
                            primaryColor: _primarySwatch,
                          ),
                          _heightBox,
                          giveSwitch(
                            value: likeAlerts,
                            handler: likeHandler,
                            description: 'My posts are liked',
                            myUsername: _myUsername,
                            primaryColor: _primarySwatch,
                          ),
                          _heightBox,
                          giveSwitch(
                            value: flareLikeAlerts,
                            handler: flareLikeHandler,
                            description: 'My flares are liked',
                            myUsername: _myUsername,
                            primaryColor: _primarySwatch,
                          ),
                          _heightBox,
                          giveSwitch(
                            value: replyAlerts,
                            handler: replyHandler,
                            description: 'My comments are replied to',
                            myUsername: _myUsername,
                            primaryColor: _primarySwatch,
                          ),
                          _heightBox,
                          giveSwitch(
                            value: commentAlerts,
                            handler: commentHandler,
                            description: 'My posts have new comments',
                            myUsername: _myUsername,
                            primaryColor: _primarySwatch,
                          ),
                          _heightBox,
                          giveSwitch(
                            value: flareCommentAlerts,
                            handler: flareCommentHandler,
                            description: 'My flares have new comments',
                            myUsername: _myUsername,
                            primaryColor: _primarySwatch,
                          ),
                          _heightBox,
                          giveSwitch(
                            value: linkedAlert,
                            handler: linkedHandler,
                            description: 'My link requests get accepted',
                            myUsername: _myUsername,
                            primaryColor: _primarySwatch,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
