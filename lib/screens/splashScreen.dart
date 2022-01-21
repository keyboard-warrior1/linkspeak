import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../routes.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/adaptiveText.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen();
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ignore: avoid_init_to_null
  String? facebookID = null;
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late FirebaseMessaging fcm;
  late User? user;
  bool loading = true;
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

  void handler(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final myBool = prefs.getBool('KeepLogged') ?? false;
    final myGmail = prefs.getString('GMAIL') ?? '';
    final myFacebook = prefs.getString('FB') ?? '';
    if (myBool) {
      final myUsername = prefs.getString('username');
      final myPassword = prefs.getString('password');
      final myDoc = firestore.collection('Users').doc('$myUsername');
      await firestore
          .collection('Users')
          .doc('$myUsername')
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
          Navigator.popUntil(context, (route) {
            return route.isFirst;
          });
          Navigator.pushReplacementNamed(context, RouteGenerator.loginScreen);
        } else {
          auth
              .signInWithEmailAndPassword(email: email, password: myPassword!)
              .then((user) async {
            if (setUp == 'false') {
              Provider.of<MyProfile>(context, listen: false)
                  .setMyUsername(username);
              Navigator.popUntil(context, (route) {
                return route.isFirst;
              });
              Navigator.pushReplacementNamed(
                context,
                RouteGenerator.setupScreen,
              );
            } else if (setUp == 'true') {
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
                    myDoc.collection('LikedPosts').orderBy('date');
                final likedIDsDocs = await likedIDsCollection.get();
                final likedIDs2 = likedIDsDocs.docs;
                final theLikedIDs = likedIDs2.map((liked) => liked.id).toList();
                final reversedLiked = theLikedIDs.reversed.toList();
                final favPostsCollection =
                    myDoc.collection('FavPosts').orderBy('date');
                final favPostIDsDocs = await favPostsCollection.get();
                final favPostIDs2 = favPostIDsDocs.docs;
                final theFavIDs = favPostIDs2.map((fav) => fav.id).toList();
                final reversedFavs = theFavIDs.reversed.toList();
                final hiddenPostsCollection = myDoc.collection('HiddenPosts');
                final hiddenPostIDsDocs = await hiddenPostsCollection.get();
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
                final thePostIDs = myPostIDs2.map((post) => post.id).toList();
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
                if (documentSnapshot.data()!.containsKey('additionalWebsite')) {
                  final actualWebsite = getter('additionalWebsite');
                  additionalWebsite = actualWebsite;
                }
                if (documentSnapshot.data()!.containsKey('additionalEmail')) {
                  final actualEmail = getter('additionalEmail');
                  additionalEmail = actualEmail;
                }
                if (documentSnapshot.data()!.containsKey('additionalNumber')) {
                  final actualNumber = getter('additionalNumber');
                  additionalNumber = actualNumber;
                }
                if (documentSnapshot.data()!.containsKey('additionalAddress')) {
                  final actualAddress = getter('additionalAddress');
                  additionalAddress = actualAddress;
                }
                if (documentSnapshot
                    .data()!
                    .containsKey('additionalAddressName')) {
                  final actualAddressName = getter('additionalAddressName');
                  additionalAddressName = actualAddressName;
                }
                final imgUrl = getter('Avatar');
                final email = getter('Email');
                final bio = getter('Bio');
                final serverTopics = getter('Topics') as List;
                final int numOfLinks = getter('numOfLinks');
                final int numOfLinked = getter('numOfLinked');
                final int numOfPosts = getter('numOfPosts');
                final int numOfNewLinksNotifs = getter('numOfNewLinksNotifs');
                final int numOfNewLinkedNotifs = getter('numOfNewLinkedNotifs');
                final int numOfLinkRequestsNotifs =
                    getter('numOfLinkRequestsNotifs');
                final int numOfPostLikesNotifs = getter('numOfPostLikesNotifs');
                final int numOfPostCommentsNotifs =
                    getter('numOfPostCommentsNotifs');
                final int numOfCommentRepliesNotifs =
                    getter('numOfCommentRepliesNotifs');
                final int numOfPostsRemoved = getter('PostsRemoved');
                final int numOfCommentsRemoved = getter('CommentsRemoved');
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
                Navigator.pushReplacementNamed(
                  context,
                  RouteGenerator.feedScreen,
                );
              });
            }
          }).catchError((e) {
            if (e.code == 'wrong-password' || e.code == 'user-not-found') {
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushNamed(context, RouteGenerator.loginScreen);
            } else {
              setState(() => loading = false);
            }
          });
        }
      }).catchError((_) {
        setState(() => loading = false);
      });
    } else if (myGmail != '') {
      signInWithGoogle().then((value) async {
        final email = value.user!.email;
        final getEmail = await firestore.collection('Emails').doc(email).get();
        if (getEmail.exists) {
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
              GoogleSignIn().signOut().then((value) {
                Navigator.popUntil(context, (route) {
                  return route.isFirst;
                });
                Navigator.pushReplacementNamed(
                    context, RouteGenerator.loginScreen);
              });
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
                final theLikedIDs = likedIDs2.map((liked) => liked.id).toList();
                final reversedLiked = theLikedIDs.reversed.toList();
                final favPostsCollection = myDoc.collection('FavPosts');
                final favPostIDsDocs = await favPostsCollection.get();
                final favPostIDs2 = favPostIDsDocs.docs;
                final theFavIDs = favPostIDs2.map((fav) => fav.id).toList();
                final reversedFavs = theFavIDs.reversed.toList();
                final hiddenPostsCollection = myDoc.collection('HiddenPosts');
                final hiddenPostIDsDocs = await hiddenPostsCollection.get();
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
                final thePostIDs = myPostIDs2.map((post) => post.id).toList();
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
                if (documentSnapshot.data()!.containsKey('additionalWebsite')) {
                  final actualWebsite = getter('additionalWebsite');
                  additionalWebsite = actualWebsite;
                }
                if (documentSnapshot.data()!.containsKey('additionalEmail')) {
                  final actualEmail = getter('additionalEmail');
                  additionalEmail = actualEmail;
                }
                if (documentSnapshot.data()!.containsKey('additionalNumber')) {
                  final actualNumber = getter('additionalNumber');
                  additionalNumber = actualNumber;
                }
                if (documentSnapshot.data()!.containsKey('additionalAddress')) {
                  final actualAddress = getter('additionalAddress');
                  additionalAddress = actualAddress;
                }
                if (documentSnapshot
                    .data()!
                    .containsKey('additionalAddressName')) {
                  final actualAddressName = getter('additionalAddressName');
                  additionalAddressName = actualAddressName;
                }
                final imgUrl = getter('Avatar');
                final bio = getter('Bio');
                final serverTopics = getter('Topics') as List;
                final int numOfLinks = getter('numOfLinks');
                final int numOfLinked = getter('numOfLinked');
                final int numOfPosts = getter('numOfPosts');
                final int numOfNewLinksNotifs = getter('numOfNewLinksNotifs');
                final int numOfNewLinkedNotifs = getter('numOfNewLinkedNotifs');
                final int numOfLinkRequestsNotifs =
                    getter('numOfLinkRequestsNotifs');
                final int numOfPostLikesNotifs = getter('numOfPostLikesNotifs');
                final int numOfPostCommentsNotifs =
                    getter('numOfPostCommentsNotifs');
                final int numOfCommentRepliesNotifs =
                    getter('numOfCommentRepliesNotifs');
                final int numOfPostsRemoved = getter('PostsRemoved');
                final int numOfCommentsRemoved = getter('CommentsRemoved');
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
                Navigator.pushReplacementNamed(
                  context,
                  RouteGenerator.feedScreen,
                );
              }).catchError((onError) {});
            }
          });
        } else {
          final args = PickNameArgs(email, true);
          Navigator.pushReplacementNamed(
              context, RouteGenerator.pickUsernameScreen,
              arguments: args);
        }
      });
    } else if (myFacebook != '') {
      signInWithFacebook().then((value) async {
        final email = facebookID!;
        final getEmail = await firestore.collection('Emails').doc(email).get();
        if (getEmail.exists) {
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
              GoogleSignIn().signOut().then((value) {
                Navigator.popUntil(context, (route) {
                  return route.isFirst;
                });
                Navigator.pushReplacementNamed(
                    context, RouteGenerator.loginScreen);
              });
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
                final theLikedIDs = likedIDs2.map((liked) => liked.id).toList();
                final reversedLiked = theLikedIDs.reversed.toList();
                final favPostsCollection = myDoc.collection('FavPosts');
                final favPostIDsDocs = await favPostsCollection.get();
                final favPostIDs2 = favPostIDsDocs.docs;
                final theFavIDs = favPostIDs2.map((fav) => fav.id).toList();
                final reversedFavs = theFavIDs.reversed.toList();
                final hiddenPostsCollection = myDoc.collection('HiddenPosts');
                final hiddenPostIDsDocs = await hiddenPostsCollection.get();
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
                final thePostIDs = myPostIDs2.map((post) => post.id).toList();
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
                if (documentSnapshot.data()!.containsKey('additionalWebsite')) {
                  final actualWebsite = getter('additionalWebsite');
                  additionalWebsite = actualWebsite;
                }
                if (documentSnapshot.data()!.containsKey('additionalEmail')) {
                  final actualEmail = getter('additionalEmail');
                  additionalEmail = actualEmail;
                }
                if (documentSnapshot.data()!.containsKey('additionalNumber')) {
                  final actualNumber = getter('additionalNumber');
                  additionalNumber = actualNumber;
                }
                if (documentSnapshot.data()!.containsKey('additionalAddress')) {
                  final actualAddress = getter('additionalAddress');
                  additionalAddress = actualAddress;
                }
                if (documentSnapshot
                    .data()!
                    .containsKey('additionalAddressName')) {
                  final actualAddressName = getter('additionalAddressName');
                  additionalAddressName = actualAddressName;
                }
                final imgUrl = getter('Avatar');
                final bio = getter('Bio');
                final serverTopics = getter('Topics') as List;
                final int numOfLinks = getter('numOfLinks');
                final int numOfLinked = getter('numOfLinked');
                final int numOfPosts = getter('numOfPosts');
                final int numOfNewLinksNotifs = getter('numOfNewLinksNotifs');
                final int numOfNewLinkedNotifs = getter('numOfNewLinkedNotifs');
                final int numOfLinkRequestsNotifs =
                    getter('numOfLinkRequestsNotifs');
                final int numOfPostLikesNotifs = getter('numOfPostLikesNotifs');
                final int numOfPostCommentsNotifs =
                    getter('numOfPostCommentsNotifs');
                final int numOfCommentRepliesNotifs =
                    getter('numOfCommentRepliesNotifs');
                final int numOfPostsRemoved = getter('PostsRemoved');
                final int numOfCommentsRemoved = getter('CommentsRemoved');
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
                Navigator.pushReplacementNamed(
                  context,
                  RouteGenerator.feedScreen,
                );
              }).catchError((onError) {});
            }
          });
        } else {
          final args = PickNameArgs(email, false);
          Navigator.pushReplacementNamed(
              context, RouteGenerator.pickUsernameScreen,
              arguments: args);
        }
      }).catchError((_) {});
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacementNamed(context, RouteGenerator.loginScreen);
    }
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() async {
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      fcm = FirebaseMessaging.instance;
      user = auth.currentUser;
      if (user == null) auth.signInAnonymously();
      if (mounted) setState(() {});
      handler(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size _sizeQUery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQUery.height;
    final double _deviceWidth = _sizeQUery.width;
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    final consent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: RichText(
        softWrap: true,
        text: const TextSpan(
          children: const [
            const TextSpan(
              text:
                  'By signing in to Linkspeak you hereby agree to uphold the Terms & Guidelines stated and consent to our Privacy Policy agreement.',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
    return Scaffold(
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 5.0),
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
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: OptimisedText(
                      minWidth: _deviceWidth * 0.95,
                      maxWidth: _deviceWidth * 0.95,
                      minHeight: 10,
                      maxHeight: _deviceHeight * 0.2,
                      fit: BoxFit.scaleDown,
                      child: Stack(
                        children: <Widget>[
                          Text(
                            'Linkspeak',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 80.0,
                              fontFamily: 'JosefinSans',
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 5.75
                                ..color = Colors.black,
                            ),
                          ),
                          const Text(
                            'Linkspeak',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 80.0,
                              fontFamily: 'JosefinSans',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (loading)
                Center(
                  child: Container(
                    height: 25.0,
                    width: 25.0,
                    child: CircularProgressIndicator(color: _accentColor),
                  ),
                ),
              if (loading) consent,
              if (!loading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'An error has occured',
                      style: TextStyle(
                        color: Colors.white,
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
                          backgroundColor: MaterialStateProperty.all<Color?>(
                              Colors.transparent),
                          shape: MaterialStateProperty.all<OutlinedBorder?>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: _accentColor),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() => loading = true);
                          handler(context);
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
        ),
      ),
    );
  }
}
