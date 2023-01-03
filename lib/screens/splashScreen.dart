import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'package:parallax_rain/parallax_rain.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/auth/mosaic.dart';
import '../widgets/common/adaptiveText.dart';

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

  void handler(BuildContext context, String serverLang) async {
    print(serverLang);
    final prefs = await SharedPreferences.getInstance();
    final myBool = prefs.getBool('KeepLogged') ?? false;
    final myGmail = prefs.getString('GMAIL') ?? '';
    final myFacebook = prefs.getString('FB') ?? '';
    if (myBool) {
      final myUsername = prefs.getString('username');
      final myPassword = prefs.getString('password');
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
              final token = kIsWeb ? '' : await fcm.getToken();
              final _users = firestore.collection('Users');
              _users.doc(username).set({
                'Activity': 'Online',
                'IP address': '$_ipAddress',
                'language': serverLang,
                'Sign-in': DateTime.now(),
                if (!kIsWeb) 'fcm': token,
                'logins': FieldValue.increment(1),
              }, SetOptions(merge: true)).then((value) async {
                await General.login(username);
                await General.addDailyOnline();
                await firestore
                    .collection('Control')
                    .doc('Details')
                    .update({'online': FieldValue.increment(1)});
                final mySpotlight =
                    await firestore.collection('Flares').doc('$username').get();
                final spotlightExists = mySpotlight.exists;
                final Color themePrimaryColor =
                    Theme.of(context).colorScheme.primary;
                final Color themeAccentColor =
                    Theme.of(context).colorScheme.secondary;
                final Color themeLikeColor =
                    Provider.of<ThemeModel>(context, listen: false).likeColor;
                final setPrimary =
                    Provider.of<ThemeModel>(context, listen: false)
                        .setPrimaryColor;
                final setAccent =
                    Provider.of<ThemeModel>(context, listen: false)
                        .setAccentColor;
                final setLikeColor =
                    Provider.of<ThemeModel>(context, listen: false)
                        .setLikeColor;
                General.initializeLogin(
                    documentSnapshot: documentSnapshot,
                    themePrimaryColor: themePrimaryColor,
                    themeAccentColor: themeAccentColor,
                    themeLikeColor: themeLikeColor,
                    setPrimary: setPrimary,
                    setAccent: setAccent,
                    setLikeColor: setLikeColor,
                    context: context,
                    spotlightExists: spotlightExists);
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
          await firestore
              .collection('Users')
              .doc('$username')
              .get()
              .then((documentSnapshot) async {
            dynamic getter(String field) {
              return documentSnapshot.get(field);
            }

            final status = getter('Status');
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
                'language': serverLang,
                'Sign-in': DateTime.now(),
                'fcm': token,
                'logins': FieldValue.increment(1),
              }, SetOptions(merge: true)).then((value) async {
                await General.addDailyOnline();
                await General.login(username);
                await firestore
                    .collection('Control')
                    .doc('Details')
                    .update({'online': FieldValue.increment(1)});
                final mySpotlight =
                    await firestore.collection('Flares').doc('$username').get();
                final spotlightExists = mySpotlight.exists;
                final Color themePrimaryColor =
                    Theme.of(context).colorScheme.primary;
                final Color themeAccentColor =
                    Theme.of(context).colorScheme.secondary;
                final Color themeLikeColor =
                    Provider.of<ThemeModel>(context, listen: false).likeColor;
                final setPrimary =
                    Provider.of<ThemeModel>(context, listen: false)
                        .setPrimaryColor;
                final setAccent =
                    Provider.of<ThemeModel>(context, listen: false)
                        .setAccentColor;
                final setLikeColor =
                    Provider.of<ThemeModel>(context, listen: false)
                        .setLikeColor;
                General.initializeLogin(
                    documentSnapshot: documentSnapshot,
                    themePrimaryColor: themePrimaryColor,
                    themeAccentColor: themeAccentColor,
                    themeLikeColor: themeLikeColor,
                    setPrimary: setPrimary,
                    setAccent: setAccent,
                    setLikeColor: setLikeColor,
                    context: context,
                    spotlightExists: spotlightExists);
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
          await firestore
              .collection('Users')
              .doc('$username')
              .get()
              .then((documentSnapshot) async {
            dynamic getter(String field) {
              return documentSnapshot.get(field);
            }

            final status = getter('Status');
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
                'language': serverLang,
                'Sign-in': DateTime.now(),
                'fcm': token,
                'logins': FieldValue.increment(1),
              }, SetOptions(merge: true)).then((value) async {
                await General.addDailyOnline();
                await General.login(username);
                await firestore
                    .collection('Control')
                    .doc('Details')
                    .update({'online': FieldValue.increment(1)});
                final mySpotlight =
                    await firestore.collection('Flares').doc('$username').get();
                final spotlightExists = mySpotlight.exists;
                final Color themePrimaryColor =
                    Theme.of(context).colorScheme.primary;
                final Color themeAccentColor =
                    Theme.of(context).colorScheme.secondary;
                final Color themeLikeColor =
                    Provider.of<ThemeModel>(context, listen: false).likeColor;
                final setPrimary =
                    Provider.of<ThemeModel>(context, listen: false)
                        .setPrimaryColor;
                final setAccent =
                    Provider.of<ThemeModel>(context, listen: false)
                        .setAccentColor;
                final setLikeColor =
                    Provider.of<ThemeModel>(context, listen: false)
                        .setLikeColor;
                General.initializeLogin(
                    documentSnapshot: documentSnapshot,
                    themePrimaryColor: themePrimaryColor,
                    themeAccentColor: themeAccentColor,
                    themeLikeColor: themeLikeColor,
                    setPrimary: setPrimary,
                    setAccent: setAccent,
                    setLikeColor: setLikeColor,
                    context: context,
                    spotlightExists: spotlightExists);
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
    });
  }

  Widget buildNonStackedConsent() {
    final lang = General.language(context);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: RichText(
            softWrap: true,
            text: TextSpan(children: [
              TextSpan(
                  text: lang.screens_splash1,
                  style: const TextStyle(color: Colors.white))
            ])));
  }

  Widget buildStackedConsent() {
    final lang = General.language(context);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Stack(children: <Widget>[
          RichText(
              softWrap: true,
              text: TextSpan(children: [
                TextSpan(
                    text: lang.screens_login1,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3.00
                          ..color = Colors.black)),
                TextSpan(
                    text: lang.screens_login2,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3.00
                          ..color = Colors.black)),
                TextSpan(
                    text: lang.screens_login3,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3.00
                          ..color = Colors.black)),
                TextSpan(
                    text: lang.screens_login4,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3.00
                          ..color = Colors.black)),
                TextSpan(
                    text: lang.screens_login5,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3.00
                          ..color = Colors.black))
              ])),
          RichText(
              softWrap: true,
              text: TextSpan(children: [
                TextSpan(
                  text: lang.screens_login1,
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                    text: lang.screens_login2,
                    style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: lang.screens_login3,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: lang.screens_login4,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: lang.screens_login5,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold))
              ]))
        ]));
  }

  Widget buildTechlr() {
    return Container(
        margin: const EdgeInsets.only(top: 5.0),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(children: <Widget>[
                Text('TECHLR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3.00
                          ..color = Colors.transparent)),
                const Text('TECHLR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.transparent,
                        fontFamily: 'RobotoCondensed',
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0))
              ])
            ]));
  }

  Widget buildLinkspeak() {
    final Size _sizeQUery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQUery.height;
    final double _deviceWidth = General.widthQuery(context);
    final lang = General.language(context);
    return Column(
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
                  child: Stack(children: <Widget>[
                    Text(lang.logo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 80.0,
                            fontFamily: 'JosefinSans',
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 5.75
                              ..color = Colors.black)),
                    Text(lang.logo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 80.0,
                            fontFamily: 'JosefinSans',
                            color: Colors.white))
                  ])))
        ]);
  }

  Widget buildNonStackedRetry(String serverLang) {
    final ThemeData _theme = Theme.of(context);
    final Color _accentColor = _theme.colorScheme.secondary;
    final lang = General.language(context);
    return AnimatedContainer(
        height: (loading) ? 0 : 100,
        duration: const Duration(milliseconds: 100),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(lang.clubs_members2,
                  style: const TextStyle(color: Colors.white, fontSize: 17.0)),
              const SizedBox(width: 10.0),
              Container(
                  width: 100.0,
                  padding: const EdgeInsets.all(5.0),
                  child: TextButton(
                      style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                  const EdgeInsets.symmetric(
                                      vertical: 1.0, horizontal: 5.0)),
                          enableFeedback: false,
                          backgroundColor: MaterialStateProperty.all<Color?>(
                              Colors.transparent),
                          shape: MaterialStateProperty.all<OutlinedBorder?>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: _accentColor)))),
                      onPressed: () {
                        setState(() => loading = true);
                        handler(context, serverLang);
                      },
                      child: Text(lang.clubs_members3,
                          style:
                              TextStyle(fontSize: 19.0, color: _accentColor))))
            ]));
  }

  Widget buildStackedRetry(String serverLang) {
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final lang = General.language(context);
    return AnimatedContainer(
        height: (loading) ? 0 : 100,
        duration: const Duration(milliseconds: 100),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(children: <Widget>[
                Text(lang.clubs_members2,
                    style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3.00
                          ..color = Colors.black)),
                Text(lang.clubs_members2,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold))
              ]),
              const SizedBox(width: 10.0),
              Container(
                  width: 100.0,
                  padding: const EdgeInsets.all(5.0),
                  child: TextButton(
                      style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                  const EdgeInsets.symmetric(
                                      vertical: 1.0, horizontal: 5.0)),
                          enableFeedback: false,
                          backgroundColor:
                              MaterialStateProperty.all<Color?>(_accentColor),
                          shape: MaterialStateProperty.all<OutlinedBorder?>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Colors.black)))),
                      onPressed: () {
                        setState(() => loading = true);
                        handler(context, serverLang);
                      },
                      child: Text(lang.clubs_members3,
                          style:
                              TextStyle(fontSize: 19.0, color: _primaryColor))))
            ]));
  }

  Widget buildNoneLogin(String serverLang) {
    const spacer = const Spacer();
    final consent = buildNonStackedConsent();
    return SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          buildTechlr(),
          spacer,
          buildLinkspeak(),
          spacer,
          buildNonStackedRetry(serverLang),
          consent
        ]));
  }

  Widget buildMosaicLogin(String serverLang) {
    const spacer = const Spacer();
    final consent = buildStackedConsent();
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: const Mosaic()),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildTechlr(),
                spacer,
                buildLinkspeak(),
                spacer,
                buildStackedRetry(serverLang),
                consent,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRainLogin(String serverLang) {
    var initialPrimaryPalette = primaryColorsPalette.take(19).toList();
    var initialAccentPalette = accentColorsPalette.take(16).toList();
    var _allColors = [...initialPrimaryPalette, ...initialAccentPalette];
    return ParallaxRain(
      trail: true,
      dropColors: _allColors,
      child: buildNoneLogin(serverLang),
    );
  }

  Widget buildTheme(String themeType, String serverLang) {
    final mosaicTheme = buildMosaicLogin(serverLang);
    final rainyTheme = buildRainLogin(serverLang);
    final noTheme = buildNoneLogin(serverLang);
    if (themeType == 'Mosaic') {
      return mosaicTheme;
    } else if (themeType == 'Rainy') {
      return rainyTheme;
    } else {
      return noTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.colorScheme.primary;
    final String loginTheme = Provider.of<ThemeModel>(context).loginTheme;
    final String serverLang = Provider.of<ThemeModel>(context).serverLangCode;
    Future.delayed(const Duration(milliseconds: 100), () {
      handler(context, serverLang);
    });
    return Scaffold(
        body: Container(
            child: buildTheme(loginTheme, serverLang),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    tileMode: TileMode.clamp,
                    colors: [Colors.black, _primaryColor]))));
  }
}
