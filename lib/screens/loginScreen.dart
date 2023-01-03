import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:auth_buttons/auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:o_color_picker/o_color_picker.dart';
// import 'package:dart_ipify/dart_ipify.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:parallax_rain/parallax_rain.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/logHelper.dart';
// import '../providers/myProfileProvider.dart';
import '../providers/regHelper.dart';
// import '../models/screenArguments.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/auth/loginAuth.dart';
import '../widgets/auth/loginThemeChanger.dart';
// import '../widgets/auth/registrationDialog.dart';
import '../widgets/auth/mosaic.dart';
import '../widgets/auth/registrationAuth.dart';
import '../widgets/common/adaptiveText.dart';

enum AuthMode { none, login, signup }

class LoginScreen extends StatefulWidget {
  static AuthMode authMode = AuthMode.none;
  const LoginScreen();
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Widget moses = const Mosaic();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer();
  final TapGestureRecognizer _policyRecognizer = TapGestureRecognizer();
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

  // void _showDialog(IconData icon, Color iconColor, String title, String rule) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => RegistrationDialog(
  //       icon: icon,
  //       iconColor: iconColor,
  //       title: title,
  //       rules: rule,
  //     ),
  //   );
  // }

  @override
  void dispose() {
    super.dispose();
    _termsRecognizer.dispose();
    _policyRecognizer.dispose();
  }

  Widget buildNonStackedConsent() {
    final ThemeData _theme = Theme.of(context);
    final Color _accentColor = _theme.colorScheme.secondary;
    final lang = General.language(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: RichText(
        softWrap: true,
        text: TextSpan(
          children: [
            TextSpan(
              text: lang.screens_login1,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            TextSpan(
              recognizer: _termsRecognizer,
              text: lang.screens_login2,
              style: TextStyle(
                color: _accentColor,
              ),
            ),
            TextSpan(
              text: lang.screens_login3,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            TextSpan(
              recognizer: _policyRecognizer,
              text: lang.screens_login4,
              style: TextStyle(
                color: _accentColor,
              ),
            ),
            TextSpan(
              text: lang.screens_login5,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStackedConsent() {
    final ThemeData _theme = Theme.of(context);
    final Color _accentColor = _theme.colorScheme.secondary;
    final lang = General.language(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Stack(
        children: <Widget>[
          RichText(
            softWrap: true,
            text: TextSpan(
              children: [
                TextSpan(
                  text: lang.screens_login1,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3.00
                      ..color = Colors.black,
                  ),
                ),
                TextSpan(
                  recognizer: _termsRecognizer,
                  text: lang.screens_login2,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3.00
                      ..color = Colors.black,
                  ),
                ),
                TextSpan(
                  text: lang.screens_login3,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3.00
                      ..color = Colors.black,
                  ),
                ),
                TextSpan(
                  recognizer: _policyRecognizer,
                  text: lang.screens_login4,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3.00
                      ..color = Colors.black,
                  ),
                ),
                TextSpan(
                  text: lang.screens_login5,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3.00
                      ..color = Colors.black,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            softWrap: true,
            text: TextSpan(
              children: [
                TextSpan(
                  text: lang.screens_login1,
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  recognizer: _termsRecognizer,
                  text: lang.screens_login2,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: _accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: lang.screens_login3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  recognizer: _policyRecognizer,
                  text: lang.screens_login4,
                  style: TextStyle(
                    color: _accentColor,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: lang.screens_login5,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildButtons() {
  //   final Size _sizeQUery = MediaQuery.of(context).size;
  //   final double _deviceWidth = General.widthQuery(context);
  //   return Container(
  //     margin: (LoginScreen.authMode == AuthMode.none)
  //         ? const EdgeInsets.only(top: 15.0, bottom: 15.0)
  //         : null,
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         if (Platform.isIOS)
  //           AppleAuthButton(
  //             onPressed: () {
  //               //todo SIGN IN WITH APPLE
  //             },
  //             style: AuthButtonStyle(
  //               width: (LoginScreen.authMode == AuthMode.none)
  //                   ? _deviceWidth * 0.90
  //                   : _deviceWidth * 0.85,
  //               elevation: (LoginScreen.authMode == AuthMode.none) ? 15.0 : 0.0,
  //               borderRadius: 25.0,
  //               splashColor: Colors.black12,
  //               padding: const EdgeInsets.all(8.0),
  //             ),
  //             text: 'Log in with Apple     ',
  //             darkMode: false,
  //           ),
  //         if (Platform.isIOS) const SizedBox(height: 10.0),
  //         GoogleAuthButton(
  //           onPressed: () {
  //             signInWithGoogle().then((value) async {
  //               EasyLoading.show(status: 'Verifying', dismissOnTap: false);
  //               final email = value.user!.email;
  //               final getEmail =
  //                   await firestore.collection('Emails').doc(email).get();
  //               if (getEmail.exists) {
  //                 final prefs = await SharedPreferences.getInstance();
  //                 prefs.setString('GMAIL', '${email!}').then((value) {});
  //                 final username = getEmail.get('username');
  //                 await firestore
  //                     .collection('Users')
  //                     .doc('$username')
  //                     .get()
  //                     .then((documentSnapshot) async {
  //                   dynamic getter(String field) {
  //                     return documentSnapshot.get(field);
  //                   }

  //                   final status = getter('Status');
  //                   final email = getter('Email');
  //                   final username = getter('Username');
  //                   if (status == 'Banned') {
  //                     EasyLoading.dismiss();
  //                     _showDialog(
  //                       Icons.help,
  //                       Colors.blue,
  //                       'User banned',
  //                       "This user is currently suspended for violating our Terms & Guidelines policy.",
  //                     );
  //                   } else {
  //                     String _ipAddress = await Ipify.ipv4();
  //                     final token = await fcm.getToken();
  //                     final _users = firestore.collection('Users');
  //                     _users.doc(username).set({
  //                       'Activity': 'Online',
  //                       'IP address': '$_ipAddress',
  //                       'Sign-in': DateTime.now(),
  //                       'fcm': token,
  //                       'logins': FieldValue.increment(1),
  //                     }, SetOptions(merge: true)).then((value) async {
  //                       await General.login(username);
  //                       await firestore
  //                           .collection('Control')
  //                           .doc('Details')
  //                           .update({'online': FieldValue.increment(1)});
  //                       final mySpotlight = await firestore
  //                           .collection('Flares')
  //                           .doc('$username')
  //                           .get();
  //                       final spotlightExists = mySpotlight.exists;
  // General.initializeLogin(
  // documentSnapshot: documentSnapshot,
  // themePrimaryColor: themePrimaryColor,
  // themeAccentColor: themeAccentColor,
  // themeLikeColor: themeLikeColor,
  // setPrimary: setPrimary,
  // setAccent: setAccent,
  // setLikeColor: setLikeColor,
  // context: context,
  // spotlightExists: spotlightExists);
  //                       EasyLoading.dismiss();
  //                       Navigator.pushReplacementNamed(
  //                         context,
  //                         RouteGenerator.feedScreen,
  //                       );
  //                     }).catchError((onError) {
  //                       EasyLoading.dismiss();
  //                       EasyLoading.showError(
  //                         'Failed',
  //                         dismissOnTap: true,
  //                         duration: const Duration(seconds: 2),
  //                       );
  //                       _showDialog(Icons.cancel, Colors.red, 'Error',
  //                           'An error has occured');
  //                     });
  //                   }
  //                 });
  //               } else {
  //                 EasyLoading.dismiss();
  //                 final args = PickNameArgs(email, true);
  //                 Navigator.pushReplacementNamed(
  //                     context, RouteGenerator.pickUsernameScreen,
  //                     arguments: args);
  //               }
  //             }).catchError((_) {
  //               EasyLoading.dismiss();
  //               EasyLoading.showError(
  //                 'Failed',
  //                 dismissOnTap: true,
  //                 duration: const Duration(seconds: 2),
  //               );
  //             });
  //           },
  //           style: AuthButtonStyle(
  //             width: (LoginScreen.authMode == AuthMode.none)
  //                 ? _deviceWidth * 0.90
  //                 : _deviceWidth * 0.85,
  //             elevation: (LoginScreen.authMode == AuthMode.none) ? 15.0 : 0.0,
  //             borderRadius: 25.0,
  //             splashColor: Colors.black12,
  //             padding: const EdgeInsets.all(8.0),
  //           ),
  //           text: 'Log in with Gmail     ',
  //           darkMode: false,
  //         ),
  //         const SizedBox(height: 10.0),
  //         FacebookAuthButton(
  //           text: 'Log in with Facebook',
  //           onPressed: () {
  //             signInWithFacebook().then((value) async {
  //               if (value != null) {
  //                 EasyLoading.show(status: 'Verifying', dismissOnTap: false);
  //                 final email = facebookID!;
  //                 final getEmail =
  //                     await firestore.collection('Emails').doc(email).get();
  //                 if (getEmail.exists) {
  //                   final prefs = await SharedPreferences.getInstance();
  //                   prefs.setString('FB', '$email').then((value) {});
  //                   final username = getEmail.get('username');
  //                   await firestore
  //                       .collection('Users')
  //                       .doc('$username')
  //                       .get()
  //                       .then((documentSnapshot) async {
  //                     dynamic getter(String field) {
  //                       return documentSnapshot.get(field);
  //                     }

  //                     final status = getter('Status');
  //                     final email = getter('Email');
  //                     final username = getter('Username');
  //                     if (status == 'Banned') {
  //                       EasyLoading.dismiss();
  //                       _showDialog(
  //                         Icons.help,
  //                         Colors.blue,
  //                         'User banned',
  //                         "This user is currently suspended for violating our Terms & Guidelines policy.",
  //                       );
  //                     } else {
  //                       String _ipAddress = await Ipify.ipv4();
  //                       final token = await fcm.getToken();
  //                       final _users = firestore.collection('Users');
  //                       _users.doc(username).set({
  //                         'Activity': 'Online',
  //                         'IP address': '$_ipAddress',
  //                         'Sign-in': DateTime.now(),
  //                         'fcm': token,
  //                         'logins': FieldValue.increment(1),
  //                       }, SetOptions(merge: true)).then((value) async {
  //                         await General.login(username);
  //                         await firestore
  //                             .collection('Control')
  //                             .doc('Details')
  //                             .update({'online': FieldValue.increment(1)});
  //                         final mySpotlight = await firestore
  //                             .collection('Flares')
  //                             .doc('$username')
  //                             .get();
  //                         final spotlightExists = mySpotlight.exists;
  //                         General.initializeLogin(
  // documentSnapshot: documentSnapshot,
  // themePrimaryColor: themePrimaryColor,
  // themeAccentColor: themeAccentColor,
  // themeLikeColor: themeLikeColor,
  // setPrimary: setPrimary,
  // setAccent: setAccent,
  // setLikeColor: setLikeColor,
  // context: context,
  // spotlightExists: spotlightExists);
  //                         EasyLoading.dismiss();
  //                         Navigator.pushReplacementNamed(
  //                           context,
  //                           RouteGenerator.feedScreen,
  //                         );
  //                       }).catchError((onError) {
  //                         EasyLoading.dismiss();
  //                         EasyLoading.showError(
  //                           'Failed',
  //                           dismissOnTap: true,
  //                           duration: const Duration(seconds: 2),
  //                         );
  //                         _showDialog(Icons.cancel, Colors.red, 'Error',
  //                             'An error has occured');
  //                       });
  //                     }
  //                   });
  //                 } else {
  //                   EasyLoading.dismiss();
  //                   final args = PickNameArgs(email, false);
  //                   Navigator.pushReplacementNamed(
  //                       context, RouteGenerator.pickUsernameScreen,
  //                       arguments: args);
  //                 }
  //               }
  //             }).catchError((error) {
  //               if (error.toString() ==
  //                   '[firebase_auth/account-exists-with-different-credential] An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.') {
  //                 EasyLoading.showError('Failed');
  //               }
  //             });
  //           },
  //           darkMode: false,
  //           style: AuthButtonStyle(
  //             width: (LoginScreen.authMode == AuthMode.none)
  //                 ? _deviceWidth * 0.90
  //                 : _deviceWidth * 0.85,
  //             elevation: (LoginScreen.authMode == AuthMode.none) ? 15.0 : 0.0,
  //             borderRadius: 25.0,
  //             buttonColor: Colors.white,
  //             splashColor: Colors.black12,
  //             iconType: AuthIconType.secondary,
  //             textStyle: const TextStyle(
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 18.0),
  //             padding: const EdgeInsets.all(8.0),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildTechlr() {
    return MediaQuery.of(context).viewInsets.bottom == 0
        ? Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const LoginThemeChanger(),
              ],
            ),
          )
        : Container();
  }

  Widget buildLinkspeak() {
    final Size _sizeQUery = MediaQuery.of(context).size;
    final double _deviceWidth = General.widthQuery(context);
    final double _deviceHeight = _sizeQUery.height;

    return Center(
        child: OptimisedText(
            minWidth: _deviceWidth * 0.95,
            maxWidth: _deviceWidth * 0.95,
            minHeight: 10,
            maxHeight: _deviceHeight * 0.2,
            fit: BoxFit.scaleDown,
            child: Stack(children: <Widget>[
              Text(General.language(context).logo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 80.0,
                      fontFamily: 'JosefinSans',
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 5.75
                        ..color = Colors.black)),
              Text(General.language(context).logo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 80.0,
                      fontFamily: 'JosefinSans',
                      color: Colors.white))
            ])));
  }

  Widget buildNonStackedHelpButton() {
    final double _deviceWidth = General.widthQuery(context);
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final lang = General.language(context);
    return AnimatedContainer(
      height: ((LoginScreen.authMode == AuthMode.login ||
                  LoginScreen.authMode == AuthMode.none) &&
              MediaQuery.of(context).viewInsets.bottom == 0)
          ? 40.0
          : 0.0,
      duration: LoginScreen.authMode == AuthMode.login
          ? Duration.zero
          : const Duration(milliseconds: 150),
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
                Navigator.of(context).pushNamed(RouteGenerator.helpScreen);
              }
              if (LoginScreen.authMode == AuthMode.none) {
                setState(() {
                  LoginScreen.authMode = AuthMode.login;
                });
              }
            },
            child: Text(
              (LoginScreen.authMode == AuthMode.none)
                  ? lang.screens_login6
                  : lang.screens_login7,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: _accentColor,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStackedHelpButton() {
    final double _deviceWidth = General.widthQuery(context);
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final lang = General.language(context);
    return AnimatedContainer(
      height: ((LoginScreen.authMode == AuthMode.login ||
                  LoginScreen.authMode == AuthMode.none) &&
              MediaQuery.of(context).viewInsets.bottom == 0)
          ? 40.0
          : 0.0,
      duration: LoginScreen.authMode == AuthMode.login
          ? Duration.zero
          : const Duration(milliseconds: 150),
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
                Navigator.of(context).pushNamed(RouteGenerator.helpScreen);
              }
              if (LoginScreen.authMode == AuthMode.none) {
                setState(() {
                  LoginScreen.authMode = AuthMode.login;
                });
              }
            },
            child: Stack(
              children: <Widget>[
                Text(
                  (LoginScreen.authMode == AuthMode.none)
                      ? lang.screens_login6
                      : lang.screens_login7,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3.00
                      ..color = Colors.black,
                  ),
                ),
                Text(
                  (LoginScreen.authMode == AuthMode.none)
                      ? lang.screens_login6
                      : lang.screens_login7,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRegButton() {
    final Size _sizeQUery = MediaQuery.of(context).size;
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final double _deviceHeight = _sizeQUery.height;
    final double _deviceWidth = General.widthQuery(context);
    final lang = General.language(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: TextButton(
        style: ButtonStyle(
          enableFeedback: false,
          elevation: MaterialStateProperty.all<double?>(0.0),
          backgroundColor: MaterialStateProperty.all<Color?>(_accentColor),
          shape: MaterialStateProperty.all<OutlinedBorder?>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(15.0),
                  topLeft: const Radius.circular(15.0),
                  bottomLeft: const Radius.circular(15.0),
                  bottomRight: const Radius.circular(15.0)),
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
          Provider.of<RegHelper>(context, listen: false).reset();
          Provider.of<LogHelper>(context, listen: false).reset();
        },
        child: OptimisedText(
          minWidth: _deviceWidth * 0.7,
          maxWidth: _deviceWidth * 0.7,
          minHeight: _deviceHeight * 0.038,
          maxHeight: _deviceHeight * 0.038,
          fit: BoxFit.scaleDown,
          child: Text(
            (LoginScreen.authMode == AuthMode.login ||
                    LoginScreen.authMode == AuthMode.none)
                ? lang.screens_login8
                : lang.screens_login9,
            style: TextStyle(
              fontSize: 35.0,
              color: _primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNonStackedTheme() {
    final double _deviceWidth = General.widthQuery(context);
    final consent = buildNonStackedConsent();
    // final buttons = buildButtons();
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildTechlr(),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildLinkspeak(),
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
          // if (LoginScreen.authMode == AuthMode.login &&
          //     MediaQuery.of(context).viewInsets.bottom == 0)
          //   buttons,
          const Spacer(),
          if (LoginScreen.authMode != AuthMode.signup) consent,
          // if (LoginScreen.authMode == AuthMode.none &&
          //     MediaQuery.of(context).viewInsets.bottom == 0)
          //   buttons,
          buildNonStackedHelpButton(),
          if ((LoginScreen.authMode == AuthMode.login ||
                  LoginScreen.authMode == AuthMode.none ||
                  LoginScreen.authMode == AuthMode.signup) &&
              MediaQuery.of(context).viewInsets.bottom == 0)
            buildRegButton(),
          if ((LoginScreen.authMode == AuthMode.login ||
                  LoginScreen.authMode == AuthMode.none ||
                  LoginScreen.authMode == AuthMode.signup) &&
              MediaQuery.of(context).viewInsets.bottom == 0)
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget buildMoisaicTheme() {
    final _deviceWidth = General.widthQuery(context);
    // final buttons = buildButtons();
    final consent = buildStackedConsent();
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: moses),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildTechlr(),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  buildLinkspeak(),
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
              // if (LoginScreen.authMode == AuthMode.login &&
              //     MediaQuery.of(context).viewInsets.bottom == 0)
              //   buttons,
              const Spacer(),
              if (LoginScreen.authMode != AuthMode.signup) consent,
              // if (LoginScreen.authMode == AuthMode.none &&
              //     MediaQuery.of(context).viewInsets.bottom == 0)
              //   buttons,
              buildStackedHelpButton(),
              if ((LoginScreen.authMode == AuthMode.login ||
                      LoginScreen.authMode == AuthMode.none ||
                      LoginScreen.authMode == AuthMode.signup) &&
                  MediaQuery.of(context).viewInsets.bottom == 0)
                buildRegButton(),
              if ((LoginScreen.authMode == AuthMode.login ||
                      LoginScreen.authMode == AuthMode.none ||
                      LoginScreen.authMode == AuthMode.signup) &&
                  MediaQuery.of(context).viewInsets.bottom == 0)
                const SizedBox(height: 12)
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRainTheme() {
    var initialPrimaryPalette = primaryColorsPalette.take(19).toList();
    var initialAccentPalette = accentColorsPalette.take(16).toList();
    var _allColors = [...initialPrimaryPalette, ...initialAccentPalette];
    return ParallaxRain(
      trail: true,
      dropColors: _allColors,
      child: buildNonStackedTheme(),
    );
  }

  Widget buildTheme(String themeType) {
    final mosaicTheme = buildMoisaicTheme();
    final rainyTheme = buildRainTheme();
    final noTheme = buildNonStackedTheme();
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
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.colorScheme.primary;
    final String loginTheme = Provider.of<ThemeModel>(context).loginTheme;
    _termsRecognizer
      ..onTap =
          () => Navigator.of(context).pushNamed(RouteGenerator.termScreen);
    _policyRecognizer
      ..onTap = () =>
          Navigator.of(context).pushNamed(RouteGenerator.privacyPolicyScreen);
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
              child: buildTheme(loginTheme),
            ),
          ),
        );
      },
    );
  }
}
