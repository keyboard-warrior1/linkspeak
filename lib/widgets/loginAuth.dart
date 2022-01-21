import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../routes.dart';
import '../providers/logHelper.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/registrationDialog.dart';

class LogInAuthBox extends StatefulWidget {
  final bool inSwitch;
  final Future<void> Function(String, String)? handler;
  const LogInAuthBox(this.inSwitch, this.handler);
  @override
  _LogInAuthBoxState createState() => _LogInAuthBoxState();
}

class _LogInAuthBoxState extends State<LogInAuthBox> {
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late FirebaseMessaging fcm;
  late User? user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final FocusNode _usernameNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  bool _keepMeLogged = true;
  late void Function() obscureText;

  void _showDialog(IconData icon, Color iconColor, String title, String rule,
      Future<void> Function()? sendEmailVerification) {
    if (mounted)
      showDialog(
        context: context,
        builder: (_) => RegistrationDialog(
          icon: icon,
          iconColor: iconColor,
          title: title,
          rules: rule,
          sendEmailVerification: sendEmailVerification,
        ),
      );
  }

  String? usernameValidator(String? value) {
    final RegExp _exp = RegExp(
      r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,20}$',
      multiLine: true,
      caseSensitive: false,
      dotAll: true,
    );
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return '* Invalid username';
    }
    if (value.length < 3 || value.length > 21) {
      return '* Invalid username';
    }
    if (!_exp.hasMatch(value)) {
      return '* Invalid username';
    }
    if (_exp.hasMatch(value)) {
      return null;
    }
  }

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: '* Password is required'),
  ]);

  Future<void> _signIn(
      BuildContext context, String username, String password) async {
    try {
      final users = await firestore.collection('Users').get();
      final prefs = await SharedPreferences.getInstance();
      if (!users.docs.any((user) => user.id == username)) {
        EasyLoading.dismiss();
        _showDialog(Icons.cancel, Colors.red, 'Invalid credentials',
            'Incorrect username or password', null);
      } else if (users.docs.any((user) => user.id == username)) {
        final myDoc = firestore.collection('Users').doc('$username');
        await firestore
            .collection('Users')
            .doc('$username')
            .get()
            .then((documentSnapshot) {
          dynamic getter(String field) {
            return documentSnapshot.get(field);
          }

          final status = getter('Status');
          final email = getter('Email');
          final setUp = getter('SetupComplete');
          final username = getter('Username');
          if (status == 'Banned') {
            EasyLoading.dismiss();
            _showDialog(
                Icons.help,
                Colors.blue,
                'User banned',
                "This user is currently suspended for violating our Terms & Guidelines policy.",
                null);
          } else {
            auth
                .signInWithEmailAndPassword(email: email, password: password)
                .then((user) async {
              if (!user.user!.emailVerified) {
                EasyLoading.dismiss();
                _showDialog(
                  Icons.help,
                  Colors.blue,
                  'Verify email',
                  'A verification link has been sent to your email address',
                  user.user!.sendEmailVerification,
                );
              } else if (user.user!.emailVerified) {
                if (_keepMeLogged) {
                  if (widget.inSwitch) {
                  } else {
                    prefs.setBool('KeepLogged', true).then((value) {});
                    prefs.setString('username', username).then((value) {});
                    prefs.setString('password', password).then((value) {});
                  }
                }
                if (setUp == 'false') {
                  if (widget.inSwitch) {
                    widget.handler!(username, password);
                    _usernameController.clear();
                    _passController.clear();
                    EasyLoading.showSuccess(
                      'Success',
                      dismissOnTap: true,
                      duration: const Duration(seconds: 1),
                    );
                  } else {
                    Provider.of<MyProfile>(context, listen: false)
                        .setMyUsername(username);
                    Provider.of<MyProfile>(context, listen: false)
                        .setMyEmail(email);
                    EasyLoading.dismiss();
                    Navigator.popUntil(context, (route) {
                      return route.isFirst;
                    });
                    Navigator.pushReplacementNamed(
                      context,
                      RouteGenerator.setupScreen,
                    );
                  }
                } else if (setUp == 'true') {
                  if (widget.inSwitch) {
                    widget.handler!(username, password);
                    _usernameController.clear();
                    _passController.clear();
                    EasyLoading.showSuccess(
                      'Success',
                      dismissOnTap: true,
                      duration: const Duration(seconds: 1),
                    );
                  } else {
                    String _ipAddress = await Ipify.ipv4();
                    final token = await fcm.getToken();
                    final _users = firestore.collection('Users');
                    _users.doc(username).set({
                      'Activity': 'Online',
                      'IP address': '$_ipAddress',
                      'Sign-in': DateTime.now(),
                      'fcm': token,
                    }, SetOptions(merge: true)).then((value) async {
                      final likedIDsCollection = myDoc.collection('LikedPosts');
                      final likedIDsDocs = await likedIDsCollection.get();
                      final likedIDs2 = likedIDsDocs.docs;
                      final theLikedIDs =
                          likedIDs2.map((liked) => liked.id).toList();
                      final reversedLiked = theLikedIDs.reversed.toList();
                      final favPostsCollection = myDoc.collection('FavPosts');
                      final favPostIDsDocs = await favPostsCollection.get();
                      final favPostIDs2 = favPostIDsDocs.docs;
                      final theFavIDs =
                          favPostIDs2.map((fav) => fav.id).toList();
                      final reversedFavs = theFavIDs.reversed.toList();
                      final hiddenPostsCollection =
                          myDoc.collection('HiddenPosts');
                      final hiddenPostIDsDocs =
                          await hiddenPostsCollection.get();
                      final hiddenPostIDs2 = hiddenPostIDsDocs.docs;
                      final theHiddenIDs =
                          hiddenPostIDs2.map((hidden) => hidden.id).toList();
                      final blockedIDsCollection = myDoc.collection('Blocked');
                      final blockedIDsDocs = await blockedIDsCollection.get();
                      final blockedIDs2 = blockedIDsDocs.docs;
                      final theBlockedIDs =
                          blockedIDs2.map((blocked) => blocked.id).toList();
                      final myPostIDsCollection =
                          myDoc.collection('Posts').orderBy('date');
                      final myPostsDocs = await myPostIDsCollection.get();
                      final myPostIDs2 = myPostsDocs.docs;
                      final thePostIDs =
                          myPostIDs2.map((post) => post.id).toList();
                      final reversedPostIDs = thePostIDs.reversed.toList();
                      final mySpotlight =
                          await myDoc.collection('My Spotlight').get();
                      final spotlightDocs = mySpotlight.docs;
                      final MyProfile profile =
                          Provider.of<MyProfile>(context, listen: false);
                      final visbility = getter('Visibility');
                      String bannerUrl = 'None';
                      if (documentSnapshot.data()!.containsKey('Banner')) {
                        final currentBanner = getter('Banner');
                        bannerUrl = currentBanner;
                      }
                      String additionalWebsite = '';
                      String additionalEmail = '';
                      String additionalNumber = '';
                      dynamic additionalAddress = '';
                      String additionalAddressName = '';
                      if (documentSnapshot
                          .data()!
                          .containsKey('additionalWebsite')) {
                        final actualWebsite = getter('additionalWebsite');
                        additionalWebsite = actualWebsite;
                      }
                      if (documentSnapshot
                          .data()!
                          .containsKey('additionalEmail')) {
                        final actualEmail = getter('additionalEmail');
                        additionalEmail = actualEmail;
                      }
                      if (documentSnapshot
                          .data()!
                          .containsKey('additionalNumber')) {
                        final actualNumber = getter('additionalNumber');
                        additionalNumber = actualNumber;
                      }
                      if (documentSnapshot
                          .data()!
                          .containsKey('additionalAddress')) {
                        final actualAddress = getter('additionalAddress');
                        additionalAddress = actualAddress;
                      }
                      if (documentSnapshot
                          .data()!
                          .containsKey('additionalAddressName')) {
                        final actualAddressName =
                            getter('additionalAddressName');
                        additionalAddressName = actualAddressName;
                      }
                      final imgUrl = getter('Avatar');
                      final bio = getter('Bio');
                      final serverTopics = getter('Topics') as List;
                      final int numOfLinks = getter('numOfLinks');
                      final int numOfLinked = getter('numOfLinked');
                      final int numOfPosts = getter('numOfPosts');
                      final int numOfNewLinksNotifs =
                          getter('numOfNewLinksNotifs');
                      final int numOfNewLinkedNotifs =
                          getter('numOfNewLinkedNotifs');
                      final int numOfLinkRequestsNotifs =
                          getter('numOfLinkRequestsNotifs');
                      final int numOfPostLikesNotifs =
                          getter('numOfPostLikesNotifs');
                      final int numOfPostCommentsNotifs =
                          getter('numOfPostCommentsNotifs');
                      final int numOfCommentRepliesNotifs =
                          getter('numOfCommentRepliesNotifs');
                      final int numOfPostsRemoved = getter('PostsRemoved');
                      final int numOfCommentsRemoved =
                          getter('CommentsRemoved');
                      final int numOfBlocked = getter('numOfBlocked');
                      final List<String> myTopics =
                          serverTopics.map((topic) => topic as String).toList();
                      profile.initializeMyProfile(
                          visbility: visbility,
                          additionalWebsite: additionalWebsite,
                          additionalEmail: additionalEmail,
                          additionalNumber: additionalNumber,
                          additionalAddress: additionalAddress,
                          additionalAddressName: additionalAddressName,
                          hasSpotlight: spotlightDocs.isNotEmpty,
                          imgUrl: imgUrl,
                          bannerUrl: bannerUrl,
                          email: email,
                          username: username,
                          bio: bio,
                          myTopics: myTopics,
                          reversedLiked: reversedLiked,
                          reversedFavs: reversedFavs,
                          theHiddenIDs: theHiddenIDs,
                          numOfLinks: numOfLinks,
                          numOfLinked: numOfLinked,
                          numOfPosts: numOfPosts,
                          numOfNewLinksNotifs: numOfNewLinksNotifs,
                          numOfNewLinkedNotifs: numOfNewLinkedNotifs,
                          numOfLinkRequestsNotifs: numOfLinkRequestsNotifs,
                          numOfPostLikesNotifs: numOfPostLikesNotifs,
                          numOfPostCommentsNotifs: numOfPostCommentsNotifs,
                          numOfCommentRepliesNotifs: numOfCommentRepliesNotifs,
                          numOfPostsRemoved: numOfPostsRemoved,
                          numOfCommentsRemoved: numOfCommentsRemoved,
                          numOfBlocked: numOfBlocked,
                          theBlockedIDs: theBlockedIDs,
                          reversedPostIDs: reversedPostIDs);
                      EasyLoading.dismiss();
                      Navigator.pushReplacementNamed(
                        context,
                        RouteGenerator.feedScreen,
                      );
                    }).catchError((onError) {
                      EasyLoading.dismiss();
                      EasyLoading.showError(
                        'Failed',
                        dismissOnTap: true,
                        duration: const Duration(seconds: 2),
                      );
                      _showDialog(Icons.cancel, Colors.red, 'Error',
                          'An error has occured', null);
                    });
                  }
                }
              }
            }).catchError((e) {
              if (e.code == 'wrong-password' || e.code == 'user-not-found') {
                EasyLoading.dismiss();
                EasyLoading.showError(
                  'Failed',
                  dismissOnTap: true,
                  duration: const Duration(seconds: 2),
                );
                _showDialog(Icons.cancel, Colors.red, 'Invalid credentials',
                    'Incorrect username or password', null);
              } else {
                EasyLoading.dismiss();
                _showDialog(Icons.cancel, Colors.red, 'Error',
                    'An error has occured', null);
              }
            });
          }
        });
      }
    } catch (e) {
      EasyLoading.dismiss();
      _showDialog(
          Icons.cancel, Colors.red, 'Error', 'An error has occured', null);
    }
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      fcm = FirebaseMessaging.instance;
      user = auth.currentUser;
      if (!widget.inSwitch && user == null) auth.signInAnonymously();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passController.dispose();
    _usernameNode.dispose();
    _passwordNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color _accentColor = Theme.of(context).accentColor;
    final Color _primaryColor = Theme.of(context).primaryColor;
    final LogHelper logHelper = Provider.of<LogHelper>(context);
    bool _obscureText = logHelper.obscureText;
    obscureText = Provider.of<LogHelper>(context, listen: false).obscurePass;
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
        return false;
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: TextFormField(
                  focusNode: _usernameNode,
                  controller: _usernameController,
                  validator: usernameValidator,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  decoration: const InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    hintText: 'Username',
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: TextFormField(
                  controller: _passController,
                  obscureText: _obscureText,
                  focusNode: _passwordNode,
                  validator: passwordValidator,
                  onFieldSubmitted: (_) {
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.show(
                          status:
                              (widget.inSwitch) ? 'Adding user' : 'Signing in',
                          dismissOnTap: false);
                      _signIn(context, _usernameController.value.text,
                          _passController.value.text);
                    }
                  },
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    border: const OutlineInputBorder(),
                    fillColor: Colors.white,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    hintText: 'password',
                    suffixIcon: IconButton(
                      splashColor: Colors.transparent,
                      onPressed: () {
                        _passwordNode.unfocus();
                        _passwordNode.canRequestFocus = false;

                        obscureText();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _passwordNode.canRequestFocus = true;
                        });
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _usernameNode.canRequestFocus = true;
                        });
                      },
                      icon: Icon(
                        Icons.visibility_outlined,
                        color: _obscureText
                            ? Colors.grey
                            : Colors.lightGreenAccent.shade400,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    if (!widget.inSwitch)
                      Checkbox(
                        side: BorderSide(
                          color:
                              _keepMeLogged ? Colors.transparent : Colors.white,
                        ),
                        overlayColor: MaterialStateProperty.all<Color?>(
                            Colors.transparent),
                        activeColor: _accentColor,
                        checkColor: _primaryColor,
                        value: _keepMeLogged,
                        onChanged: (__) {
                          setState(() {
                            _keepMeLogged = !_keepMeLogged;
                          });
                        },
                      ),
                    if (!widget.inSwitch)
                      TextButton(
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          splashFactory: NoSplash.splashFactory,
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry?>(
                            const EdgeInsets.all(0.0),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _keepMeLogged = !_keepMeLogged;
                          });
                        },
                        child: const Text(
                          'Remember me',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    const Spacer(),
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
                          backgroundColor: MaterialStateProperty.all<Color?>(
                              (!widget.inSwitch)
                                  ? Colors.transparent
                                  : _primaryColor),
                          shape: MaterialStateProperty.all<OutlinedBorder?>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  color: (!widget.inSwitch)
                                      ? _accentColor
                                      : Colors.transparent),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            EasyLoading.show(
                                status: (widget.inSwitch)
                                    ? 'Adding user'
                                    : 'Signing in',
                                dismissOnTap: false);
                            _signIn(context, _usernameController.value.text,
                                _passController.value.text);
                          }
                        },
                        child: Text(
                          (widget.inSwitch) ? 'Add' : 'Sign in',
                          style: TextStyle(
                            fontSize: 19.0,
                            color:
                                (widget.inSwitch) ? Colors.white : _accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
