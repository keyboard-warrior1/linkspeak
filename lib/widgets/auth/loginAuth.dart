import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../general.dart';
import '../../providers/logHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/themeModel.dart';
import '../../routes.dart';
import '../common/noglow.dart';
import 'registrationDialog.dart';

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
              sendEmailVerification: sendEmailVerification));
  }

  String? usernameValidator(String? value) {
    final filter = ProfanityFilter();
    final RegExp _exp = RegExp(r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
        multiLine: true, caseSensitive: false, dotAll: true);
    final RegExp _hitlerexp = RegExp('hitler', caseSensitive: false);
    if (value!.isEmpty || value.replaceAll(' ', '') == '' || value.trim() == '')
      return '* Username is required';
    if (value.length < 2 || value.length > 30) return '* Invalid username';
    if (!_exp.hasMatch(value)) return '* Invalid username';
    if (_hitlerexp.hasMatch(value)) return '* Invalid username';
    if (filter.hasProfanity(value)) return '* Invalid username';
    if (_exp.hasMatch(value)) return null;
    return null;
  }

  final passwordValidator =
      MultiValidator([RequiredValidator(errorText: '* Password is required')]);

  Future<void> _signIn(
      BuildContext context,
      String username,
      String password,
      Color themePrimaryColor,
      Color themeAccentColor,
      Color themeLikeColor,
      dynamic setPrimary,
      dynamic setAccent,
      dynamic setLikeColor) async {
    try {
      FocusScope.of(context).unfocus();
      final users = await firestore.collection('Users').get();
      final prefs = await SharedPreferences.getInstance();
      if (!users.docs.any((user) => user.id == username)) {
        EasyLoading.dismiss();
        _showDialog(Icons.cancel, Colors.red, 'Invalid credentials',
            'Incorrect username or password', null);
      } else if (users.docs.any((user) => user.id == username)) {
        // final myDoc = firestore.collection('Users').doc('$username');
        await firestore
            .collection('Users')
            .doc('$username')
            .get()
            .then((documentSnapshot) {
          dynamic getter(String field) {
            return documentSnapshot.get(field);
          }

          final username = getter('Username');
          final status = getter('Status');
          final email = getter('Email');
          final setUp = getter('SetupComplete');
          if (status == 'Banned') {
            EasyLoading.dismiss();
            _showDialog(
                Icons.help,
                Colors.blue,
                'User banned',
                "This user is currently suspended for violating our Terms & Guidelines.",
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
                    user.user!.sendEmailVerification);
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
                    EasyLoading.showSuccess('Success',
                        dismissOnTap: true,
                        duration: const Duration(seconds: 1));
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
                        context, RouteGenerator.setupScreen);
                  }
                } else if (setUp == 'true') {
                  if (widget.inSwitch) {
                    widget.handler!(username, password);
                    _usernameController.clear();
                    _passController.clear();
                    EasyLoading.showSuccess('Success',
                        dismissOnTap: true,
                        duration: const Duration(seconds: 1));
                  } else {
                    String _ipAddress = await Ipify.ipv4();
                    final token = kIsWeb ? '' : await fcm.getToken();
                    final _users = firestore.collection('Users');
                    _users.doc(username).set({
                      'Activity': 'Online',
                      'IP address': '$_ipAddress',
                      'Sign-in': DateTime.now(),
                      if (!kIsWeb) 'fcm': token,
                      'logins': FieldValue.increment(1),
                    }, SetOptions(merge: true)).then((value) async {
                      await General.addDailyOnline();
                      await General.login(username);
                      await firestore
                          .collection('Control')
                          .doc('Details')
                          .update({'online': FieldValue.increment(1)});
                      final mySpotlight = await firestore
                          .collection('Flares')
                          .doc('$username')
                          .get();
                      final spotlightExists = mySpotlight.exists;
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
                      EasyLoading.dismiss();
                      Navigator.pushReplacementNamed(
                          context, RouteGenerator.feedScreen);
                    }).catchError((onError) {
                      EasyLoading.dismiss();
                      EasyLoading.showError('Failed',
                          dismissOnTap: true,
                          duration: const Duration(seconds: 2));
                      _showDialog(Icons.cancel, Colors.red, 'Error',
                          'An error has occured', null);
                    });
                  }
                }
              }
            }).catchError((e) {
              if (e.code == 'wrong-password' || e.code == 'user-not-found') {
                EasyLoading.dismiss();
                EasyLoading.showError('Failed',
                    dismissOnTap: true, duration: const Duration(seconds: 2));
                _showDialog(Icons.cancel, Colors.red, 'Invalid credentials',
                    'Incorrect username or password', null);
              } else {
                EasyLoading.dismiss();
                print(e.toString());
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
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final LogHelper logHelper = Provider.of<LogHelper>(context);
    bool _obscureText = logHelper.obscureText;
    obscureText = Provider.of<LogHelper>(context, listen: false).obscurePass;
    final Color themeLikeColor =
        Provider.of<ThemeModel>(context, listen: false).likeColor;
    final setPrimary =
        Provider.of<ThemeModel>(context, listen: false).setPrimaryColor;
    final setAccent =
        Provider.of<ThemeModel>(context, listen: false).setAccentColor;
    final setLikeColor =
        Provider.of<ThemeModel>(context, listen: false).setLikeColor;
    final loginTheme = Provider.of<ThemeModel>(context).loginTheme;
    return Noglow(
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
                              onEditingComplete: () =>
                                  FocusScope.of(context).nextFocus(),
                              maxLength: 30,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              decoration: const InputDecoration(
                                  filled: true,
                                  counterText: '',
                                  errorStyle: const TextStyle(
                                      color: Colors.white,
                                      shadows: const [
                                        Shadow(
                                            color: Colors.black,
                                            blurRadius: 20.0)
                                      ]),
                                  border: const OutlineInputBorder(),
                                  fillColor: Colors.white,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  hintText: 'Username'))),
                      const SizedBox(height: 10.0),
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
                                      status: (widget.inSwitch)
                                          ? 'Adding user'
                                          : 'Signing in',
                                      dismissOnTap: false);
                                  _signIn(
                                      context,
                                      _usernameController.value.text,
                                      _passController.value.text,
                                      _primaryColor,
                                      _accentColor,
                                      themeLikeColor,
                                      setPrimary,
                                      setAccent,
                                      setLikeColor);
                                }
                              },
                              decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                      color: Colors.white,
                                      shadows: const [
                                        Shadow(
                                            color: Colors.black,
                                            blurRadius: 20.0)
                                      ]),
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
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          _passwordNode.canRequestFocus = true;
                                        });
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          _usernameNode.canRequestFocus = true;
                                        });
                                      },
                                      icon: Icon(Icons.visibility_outlined,
                                          color: _obscureText
                                              ? Colors.grey
                                              : Colors.lightGreenAccent
                                                  .shade400))))),
                      const SizedBox(height: 15.0),
                      Padding(
                          padding:
                              const EdgeInsets.only(left: 25.0, right: 30.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                if (!widget.inSwitch)
                                  Checkbox(
                                      side: BorderSide(
                                          color: (loginTheme != 'Mosaic')
                                              ? Colors.white
                                              : Colors.black),
                                      overlayColor:
                                          MaterialStateProperty.all<Color?>(
                                              Colors.transparent),
                                      activeColor: _accentColor,
                                      checkColor: _primaryColor,
                                      value: _keepMeLogged,
                                      onChanged: (__) {
                                        setState(() {
                                          _keepMeLogged = !_keepMeLogged;
                                        });
                                      }),
                                if (!widget.inSwitch)
                                  TextButton(
                                      style: ButtonStyle(
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          splashFactory: NoSplash.splashFactory,
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsetsGeometry?>(
                                              const EdgeInsets.all(0.0))),
                                      onPressed: () {
                                        setState(() {
                                          _keepMeLogged = !_keepMeLogged;
                                        });
                                      },
                                      child: (loginTheme != 'Mosaic')
                                          ? const Text('Remember me',
                                              style: TextStyle(
                                                  color: Colors.white))
                                          : Stack(children: <Widget>[
                                              Text('Remember me',
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      foreground: Paint()
                                                        ..style =
                                                            PaintingStyle.stroke
                                                        ..strokeWidth = 3.00
                                                        ..color =
                                                            Colors.black)),
                                              const Text('Remember me',
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white))
                                            ])),
                                const Spacer(),
                                Container(
                                    width: 100.0,
                                    padding: const EdgeInsets.all(5.0),
                                    child: TextButton(
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                    EdgeInsetsGeometry?>(
                                                const EdgeInsets.symmetric(
                                                    vertical: 1.0,
                                                    horizontal: 5.0)),
                                            enableFeedback: false,
                                            backgroundColor: MaterialStateProperty
                                                .all<Color?>((!widget.inSwitch)
                                                    ? (loginTheme == 'Mosaic')
                                                        ? _accentColor
                                                        : Colors.transparent
                                                    : _primaryColor),
                                            shape: MaterialStateProperty.all<
                                                    OutlinedBorder?>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    side: BorderSide(
                                                        color: (!widget.inSwitch)
                                                            ? (loginTheme == 'Mosaic')
                                                                ? Colors.black
                                                                : _accentColor
                                                            : Colors.transparent)))),
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            EasyLoading.show(
                                                status: (widget.inSwitch)
                                                    ? 'Adding user'
                                                    : 'Signing in',
                                                dismissOnTap: false);
                                            _signIn(
                                                context,
                                                _usernameController.value.text,
                                                _passController.value.text,
                                                _primaryColor,
                                                _accentColor,
                                                themeLikeColor,
                                                setPrimary,
                                                setAccent,
                                                setLikeColor);
                                          }
                                        },
                                        child: Text((widget.inSwitch) ? 'Add' : 'Sign in',
                                            style: TextStyle(
                                                fontSize: 19.0,
                                                color: (widget.inSwitch)
                                                    ? Colors.white
                                                    : (loginTheme == 'Mosaic')
                                                        ? _primaryColor
                                                        : _accentColor))))
                              ]))
                    ]))));
  }
}
