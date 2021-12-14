import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/settingsBar.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings();

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  final firestore = FirebaseFirestore.instance;
  bool likeAlerts = true;
  bool replyAlerts = true;
  bool commentAlerts = true;
  bool linksAlert = true;
  bool linkedAlert = true;
  late Future<void> _getSettings;
  Future<void> getSettings(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    final getMe = await myUser.get();
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
    final _primarySwatch = Theme.of(context).primaryColor;
    final _accentColor = Theme.of(context).accentColor;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    const Widget _heightBox = SizedBox(height: 5.0);
    return Scaffold(
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
                    const CircularProgressIndicator(),
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
                  giveSwitch(
                    value: likeAlerts,
                    handler: likeHandler,
                    description: 'My posts get liked',
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
                    value: replyAlerts,
                    handler: replyHandler,
                    description: 'My comments get replied',
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
                    value: linkedAlert,
                    handler: linkedHandler,
                    description: 'My link requests get accepted',
                    myUsername: _myUsername,
                    primaryColor: _primarySwatch,
                  ),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
