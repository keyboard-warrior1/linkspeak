import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../routes.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/regHelper.dart';
import '../providers/logHelper.dart';
import '../providers/themeModel.dart';
import '../widgets/adaptiveText.dart';
import '../widgets/loginAuth.dart';
import '../widgets/registrationAuth.dart';
import '../widgets/registrationDialog.dart';

enum AuthMode { none, login, signup }

class LoginScreen extends StatefulWidget {
  static AuthMode authMode = AuthMode.none;
  const LoginScreen();
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  String? facebookID = null;
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      facebookID = result.accessToken!.userId;
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
    return null;
  }

  void _showDialog(IconData icon, Color iconColor, String title, String rule) {
    showDialog(
      context: context,
      builder: (_) => RegistrationDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        rules: rule,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    final Size _sizeQUery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQUery.height;
    final double _deviceWidth = _sizeQUery.width;
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    final setPrimary =
        Provider.of<ThemeModel>(context, listen: false).setPrimaryColor;
    final setAccent =
        Provider.of<ThemeModel>(context, listen: false).setAccentColor;
    final consent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: RichText(
        softWrap: true,
        text: TextSpan(
          children: [
            const TextSpan(
              text:
                  'By signing in to Linkspeak you hereby agree to uphold the ',
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    Navigator.of(context).pushNamed(RouteGenerator.termScreen),
              text: 'Terms & Guidelines',
              style: TextStyle(
                color: _accentColor,
                decoration: TextDecoration.underline,
                decorationColor: _accentColor,
              ),
            ),
            const TextSpan(
              text: ' stated and consent to our ',
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.of(context)
                    .pushNamed(RouteGenerator.privacyPolicyScreen),
              text: 'Privacy Policy',
              style: TextStyle(
                color: _accentColor,
                decoration: TextDecoration.underline,
                decorationColor: _accentColor,
              ),
            ),
            const TextSpan(
              text: ' agreement.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
    final buttons = Container(
      margin: (LoginScreen.authMode == AuthMode.none)
          ? const EdgeInsets.only(top: 15.0, bottom: 15.0)
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GoogleAuthButton(
            onPressed: () {
              signInWithGoogle().then((value) async {
                EasyLoading.show(status: 'Verifying', dismissOnTap: false);
                final email = value.user!.email;
                final getEmail =
                    await firestore.collection('Emails').doc(email).get();
                if (getEmail.exists) {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString('GMAIL', '${email!}').then((value) {});
                  final username = getEmail.get('username');
                  final myDoc = firestore.collection('Users').doc('$username');
                  await firestore
                      .collection('Users')
                      .doc('$username')
                      .get()
                      .then((documentSnapshot) async {
                    dynamic getter(String field) {
                      return documentSnapshot.get(field);
                    }

                    final status = getter('Status');
                    final email = getter('Email');
                    final username = getter('Username');
                    if (status == 'Banned') {
                      EasyLoading.dismiss();
                      _showDialog(
                        Icons.help,
                        Colors.blue,
                        'User banned',
                        "This user is currently suspended for violating our Terms & Guidelines policy.",
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
                        final likedIDsCollection =
                            myDoc.collection('LikedPosts');
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
                        final blockedIDsCollection =
                            myDoc.collection('Blocked');
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
                        final MyProfile profile =
                            Provider.of<MyProfile>(context, listen: false);
                        final visbility = getter('Visibility');
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
                        final List<String> myTopics = serverTopics
                            .map((topic) => topic as String)
                            .toList();
                        profile.setMyVis(visbility);
                        profile.setMyProfileImage(imgUrl);
                        profile.setMyEmail(email);
                        profile.setMyUsername(username);
                        profile.changeBio(bio);
                        profile.setMyTopics(myTopics);
                        profile.setLikedIDs(reversedLiked);
                        profile.setFavIDs(reversedFavs);
                        profile.setHiddenIDs(theHiddenIDs);
                        profile.setMyNumOfLinks(numOfLinks);
                        profile.setMyNumOfLinked(numOfLinked);
                        profile.setNumOfPosts(numOfPosts);
                        profile.setNumOfNewLinksNotifs(numOfNewLinksNotifs);
                        profile.setNumOfNewLinkedNotifs(numOfNewLinkedNotifs);
                        profile
                            .setNumOfLinkRequestNotifs(numOfLinkRequestsNotifs);
                        profile.setNumOfPostLikesNotifs(numOfPostLikesNotifs);
                        profile.setNumOfPostCommentsNotifs(
                            numOfPostCommentsNotifs);
                        profile.setNumOfCommentRepliesNotifs(
                            numOfCommentRepliesNotifs);
                        profile.setmyNumOfPostsRemovedNotifs(numOfPostsRemoved);
                        profile.setNumOfCommentsRemovedNotifs(
                            numOfCommentsRemoved);
                        profile.setNumOfBlocked(numOfBlocked);
                        profile.setBlockedUserIDs(theBlockedIDs);
                        profile.setMyPostIDs(reversedPostIDs);
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
                            'An error has occured');
                      });
                    }
                  });
                } else {
                  EasyLoading.dismiss();
                  final args = PickNameArgs(email, true);
                  Navigator.pushReplacementNamed(
                      context, RouteGenerator.pickUsernameScreen,
                      arguments: args);
                }
              }).catchError((_) {
                print(_.toString());
                EasyLoading.dismiss();
                EasyLoading.showError(
                  'Failed',
                  dismissOnTap: true,
                  duration: const Duration(seconds: 2),
                );
              });
            },
            style: AuthButtonStyle(
              width: (LoginScreen.authMode == AuthMode.none)
                  ? _deviceWidth * 0.90
                  : _deviceWidth * 0.85,
              elevation: (LoginScreen.authMode == AuthMode.none) ? 15.0 : 0.0,
              borderRadius: 25.0,
              splashColor: Colors.black12,
              padding: const EdgeInsets.all(8.0),
            ),
            text: 'Log in with Gmail     ',
            darkMode: false,
          ),
          const SizedBox(height: 10.0),
          FacebookAuthButton(
            text: 'Log in with Facebook',
            onPressed: () {
              signInWithFacebook().then((value) async {
                if (value != null) {
                  EasyLoading.show(status: 'Verifying', dismissOnTap: false);
                  final email = facebookID!;
                  final getEmail =
                      await firestore.collection('Emails').doc(email).get();
                  if (getEmail.exists) {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('FB', '$email').then((value) {});
                    final username = getEmail.get('username');
                    final myDoc =
                        firestore.collection('Users').doc('$username');
                    await firestore
                        .collection('Users')
                        .doc('$username')
                        .get()
                        .then((documentSnapshot) async {
                      dynamic getter(String field) {
                        return documentSnapshot.get(field);
                      }

                      final status = getter('Status');
                      final email = getter('Email');
                      final username = getter('Username');
                      if (status == 'Banned') {
                        EasyLoading.dismiss();
                        _showDialog(
                          Icons.help,
                          Colors.blue,
                          'User banned',
                          "This user is currently suspended for violating our Terms & Guidelines policy.",
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
                          final likedIDsCollection =
                              myDoc.collection('LikedPosts');
                          final likedIDsDocs = await likedIDsCollection.get();
                          final likedIDs2 = likedIDsDocs.docs;
                          final theLikedIDs =
                              likedIDs2.map((liked) => liked.id).toList();
                          final reversedLiked = theLikedIDs.reversed.toList();
                          final favPostsCollection =
                              myDoc.collection('FavPosts');
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
                          final theHiddenIDs = hiddenPostIDs2
                              .map((hidden) => hidden.id)
                              .toList();
                          final blockedIDsCollection =
                              myDoc.collection('Blocked');
                          final blockedIDsDocs =
                              await blockedIDsCollection.get();
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
                          final MyProfile profile =
                              Provider.of<MyProfile>(context, listen: false);
                          final visbility = getter('Visibility');
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
                          final List<String> myTopics = serverTopics
                              .map((topic) => topic as String)
                              .toList();
                          profile.setMyVis(visbility);
                          profile.setMyProfileImage(imgUrl);
                          profile.setMyEmail(email);
                          profile.setMyUsername(username);
                          profile.changeBio(bio);
                          profile.setMyTopics(myTopics);
                          profile.setLikedIDs(reversedLiked);
                          profile.setFavIDs(reversedFavs);
                          profile.setHiddenIDs(theHiddenIDs);
                          profile.setMyNumOfLinks(numOfLinks);
                          profile.setMyNumOfLinked(numOfLinked);
                          profile.setNumOfPosts(numOfPosts);
                          profile.setNumOfNewLinksNotifs(numOfNewLinksNotifs);
                          profile.setNumOfNewLinkedNotifs(numOfNewLinkedNotifs);
                          profile.setNumOfLinkRequestNotifs(
                              numOfLinkRequestsNotifs);
                          profile.setNumOfPostLikesNotifs(numOfPostLikesNotifs);
                          profile.setNumOfPostCommentsNotifs(
                              numOfPostCommentsNotifs);
                          profile.setNumOfCommentRepliesNotifs(
                              numOfCommentRepliesNotifs);
                          profile
                              .setmyNumOfPostsRemovedNotifs(numOfPostsRemoved);
                          profile.setNumOfCommentsRemovedNotifs(
                              numOfCommentsRemoved);
                          profile.setNumOfBlocked(numOfBlocked);
                          profile.setBlockedUserIDs(theBlockedIDs);
                          profile.setMyPostIDs(reversedPostIDs);
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
                              'An error has occured');
                        });
                      }
                    });
                  } else {
                    EasyLoading.dismiss();
                    final args = PickNameArgs(email, false);
                    Navigator.pushReplacementNamed(
                        context, RouteGenerator.pickUsernameScreen,
                        arguments: args);
                  }
                }
              }).catchError((error) {
                if (error.toString() ==
                    '[firebase_auth/account-exists-with-different-credential] An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.') {
                  EasyLoading.showError('Failed');
                }
              });
            },
            darkMode: false,
            style: AuthButtonStyle(
              width: (LoginScreen.authMode == AuthMode.none)
                  ? _deviceWidth * 0.90
                  : _deviceWidth * 0.85,
              elevation: (LoginScreen.authMode == AuthMode.none) ? 15.0 : 0.0,
              borderRadius: 25.0,
              buttonColor: Colors.white,
              splashColor: Colors.black12,
              iconType: AuthIconType.secondary,
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
              padding: const EdgeInsets.all(8.0),
            ),
          ),
        ],
      ),
    );
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    tileMode: TileMode.clamp,
                    colors: [
                      Colors.black,
                      _primaryColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: const Text(
                          'TECHLR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'RobotoCondensed',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AnimatedContainer(
                            height:
                                (MediaQuery.of(context).viewInsets.bottom == 0)
                                    ? 35.0
                                    : 0.0,
                            width: 70.0,
                            duration: const Duration(milliseconds: 100),
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => showDialog<void>(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (_) => GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            OColorPicker(
                                              selectedColor: _primaryColor,
                                              colors: primaryColorsPalette,
                                              onColorChange: (color) {
                                                if (color == Colors.black ||
                                                    color == Colors.white) {
                                                } else {
                                                  setPrimary(color);
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      shape: BoxShape.circle,
                                      color: _primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3.0),
                                GestureDetector(
                                  onTap: () => showDialog<void>(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (_) => GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            OColorPicker(
                                              selectedColor: _accentColor,
                                              colors: accentColorsPalette,
                                              onColorChange: (color) {
                                                if (color == Colors.black ||
                                                    color == Colors.white) {
                                                } else {
                                                  setAccent(color);
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      shape: BoxShape.circle,
                                      color: _accentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: OptimisedText(
                              minWidth: _deviceWidth*0.95,
                              maxWidth: _deviceWidth*0.95,
                              minHeight: 10,
                              maxHeight: _deviceHeight * 0.2,
                              fit: BoxFit.scaleDown,
                              child: const Text(
                                'Linkspeak',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 80.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          if (LoginScreen.authMode == AuthMode.login)
                            Center(
                              child: Container(
                                width: _deviceWidth,
                                child: const LogInAuthBox(false, null),
                              ),
                            ),
                          if (LoginScreen.authMode == AuthMode.signup)
                            Center(
                              child: Container(
                                width: double.infinity,
                                child: const RegistrationAuthBox(),
                              ),
                            ),
                        ],
                      ),
                      if (LoginScreen.authMode == AuthMode.login &&
                          MediaQuery.of(context).viewInsets.bottom == 0)
                        buttons,
                      const Spacer(),
                      if (LoginScreen.authMode != AuthMode.signup) consent,
                      if (LoginScreen.authMode == AuthMode.none &&
                          MediaQuery.of(context).viewInsets.bottom == 0)
                        buttons,
                      AnimatedContainer(
                        height: ((LoginScreen.authMode == AuthMode.login ||
                                    LoginScreen.authMode == AuthMode.none) &&
                                MediaQuery.of(context).viewInsets.bottom == 0)
                            ? 40.0
                            : 0.0,
                        duration: const Duration(milliseconds: 150),
                        child: Center(
                          child: OptimisedText(
                            minWidth: _deviceWidth * 0.85,
                            maxWidth: _deviceWidth * 0.85,
                            minHeight: 40.0,
                            maxHeight: 40.0,
                            fit: BoxFit.scaleDown,
                            child: TextButton(
                              onPressed: () {
                                if (LoginScreen.authMode == AuthMode.login) {
                                  Navigator.of(context)
                                      .pushNamed(RouteGenerator.helpScreen);
                                }
                                if (LoginScreen.authMode == AuthMode.none) {
                                  setState(() {
                                    LoginScreen.authMode = AuthMode.login;
                                  });
                                }
                              },
                              child: Text(
                                (LoginScreen.authMode == AuthMode.none)
                                    ? 'Already registered'
                                    : 'Trouble logging in?',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: _accentColor,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if ((LoginScreen.authMode == AuthMode.login ||
                              LoginScreen.authMode == AuthMode.none ||
                              LoginScreen.authMode == AuthMode.signup) &&
                          MediaQuery.of(context).viewInsets.bottom == 0)
                        TextButton(
                          style: ButtonStyle(
                            enableFeedback: false,
                            elevation: MaterialStateProperty.all<double?>(0.0),
                            backgroundColor:
                                MaterialStateProperty.all<Color?>(_accentColor),
                            shape: MaterialStateProperty.all<OutlinedBorder?>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: const Radius.circular(15.0),
                                  topLeft: const Radius.circular(15.0),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (LoginScreen.authMode == AuthMode.login ||
                                LoginScreen.authMode == AuthMode.none) {
                              setState(() {
                                LoginScreen.authMode = AuthMode.signup;
                              });
                            } else {
                              setState(() {
                                LoginScreen.authMode = AuthMode.login;
                              });
                            }
                            Provider.of<RegHelper>(context, listen: false)
                                .reset();
                            Provider.of<LogHelper>(context, listen: false)
                                .reset();
                          },
                          child: OptimisedText(
                            minWidth: _deviceWidth * 0.5,
                            maxWidth: _deviceWidth * 0.5,
                            minHeight: _deviceHeight * 0.038,
                            maxHeight: _deviceHeight * 0.038,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              (LoginScreen.authMode == AuthMode.login ||
                                      LoginScreen.authMode == AuthMode.none)
                                  ? 'Sign up now!'
                                  : 'Sign in instead',
                              style: TextStyle(
                                fontSize: 35.0,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
