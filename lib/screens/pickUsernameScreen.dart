import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../general.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/settingsBar.dart';

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int? maxLength;
  final IconData icon;
  final TextInputType keyboardType;
  final bool showSuffix;
  final bool obscureText;
  final dynamic handler;
  final FocusNode? focusNode;
  const Field({
    required this.controller,
    required this.label,
    required this.validator,
    required this.maxLength,
    required this.icon,
    required this.keyboardType,
    required this.showSuffix,
    required this.obscureText,
    required this.handler,
    required this.focusNode,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: TextFormField(
        keyboardType: keyboardType,
        focusNode: (focusNode != null) ? focusNode : null,
        maxLength: maxLength,
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightGreenAccent.shade400),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
          filled: true,
          fillColor: Colors.grey.shade200,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          hintText: label,
          suffixIcon: (showSuffix)
              ? IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(icon),
                  onPressed: handler,
                )
              : null,
        ),
      ),
    );
  }
}

class PickUsernameScreen extends StatefulWidget {
  final dynamic emailXid;
  final dynamic isGmail;
  const PickUsernameScreen(this.emailXid, this.isGmail);

  @override
  State<PickUsernameScreen> createState() => _PickUsernameScreenState();
}

class _PickUsernameScreenState extends State<PickUsernameScreen> {
  bool _isLoading = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> usernameDocs = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  final TextEditingController userNameControl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? usernameValidator(String? value) {
    final filter = ProfanityFilter();
    final RegExp _exp = RegExp(r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
        multiLine: true, caseSensitive: false, dotAll: true);
    final RegExp _exp2 = RegExp('linkspeak', caseSensitive: false);
    final RegExp _hitlerexp = RegExp('hitler', caseSensitive: false);
    if (value!.isEmpty || value.replaceAll(' ', '') == '' || value.trim() == '')
      return '* Username is required';
    if (value.length < 2 || value.length > 30)
      return '* Username must be between 2-30 characters';
    if (usernameDocs.isNotEmpty) {
      if (usernameDocs.any((element) => element.id == value))
        return '* Username already taken';
    }
    if (!_exp.hasMatch(value)) return '* Invalid username';
    if (_exp2.hasMatch(value)) return '* Invalid username';
    if (_hitlerexp.hasMatch(value)) return '* Invalid username';
    if (filter.hasProfanity(value)) return '* Invalid username';
    if (_exp.hasMatch(value)) return null;
    return null;
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() async {
      final getUsernames = await firestore.collection('Users').get();
      final usernamesdocs = getUsernames.docs;
      usernameDocs = [...usernamesdocs];
    });
  }

  @override
  void dispose() {
    super.dispose();
    userNameControl.dispose();
  }

  _showDialog(IconData icon, Color iconColor, String title, String rule) {
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
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {});
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const SettingsBar('Pick a username', null, false),
                              const SizedBox(height: 25.0),
                              Field(
                                  label: 'username',
                                  controller: userNameControl,
                                  validator: usernameValidator,
                                  maxLength: 30,
                                  icon: Icons.verified,
                                  keyboardType: TextInputType.visiblePassword,
                                  showSuffix: false,
                                  obscureText: false,
                                  handler: null,
                                  focusNode: null),
                              Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: const Text(
                                      'This username is shown on your profile',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15.0))),
                              const Spacer(),
                              TextButton(
                                  style: ButtonStyle(
                                      enableFeedback: false,
                                      elevation:
                                          MaterialStateProperty.all<double?>(
                                              0.0),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color?>(
                                              _primaryColor),
                                      shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topRight:
                                                  const Radius.circular(15.0),
                                              topLeft: const Radius.circular(
                                                  15.0))))),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (_isLoading) {
                                      } else {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        FocusScope.of(context).unfocus();
                                        final bool isAndroid =
                                            Platform.isAndroid;
                                        final users = await firestore
                                            .collection('Users')
                                            .get();
                                        if (users.docs.any((user) =>
                                            user.id ==
                                            userNameControl.value.text)) {
                                          _showDialog(
                                            Icons.cancel,
                                            Colors.red,
                                            'Username exists',
                                            'This username is already taken',
                                          );
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        } else {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          if (widget.isGmail) {
                                            prefs
                                                .setString('GMAIL',
                                                    '${widget.emailXid}')
                                                .then((value) {});
                                          } else {
                                            prefs
                                                .setString(
                                                    'FB', '${widget.emailXid}')
                                                .then((value) {});
                                          }
                                          String _ipAddress =
                                              await Ipify.ipv4();
                                          final token = await fcm.getToken();
                                          var batch = firestore.batch();
                                          General.addUsers();
                                          batch.set(
                                              firestore
                                                  .collection('Emails')
                                                  .doc('${widget.emailXid}'),
                                              {
                                                'username':
                                                    '${userNameControl.value.text.trim()}'
                                              });
                                          batch.set(
                                              firestore.collection('Users').doc(
                                                  '${userNameControl.value.text.trim()}'),
                                              {
                                                'Email': '${widget.emailXid}',
                                                'SetupComplete': 'true',
                                                'Status': 'Allowed',
                                                'Name': (widget.isGmail)
                                                    ? 'gmail account'
                                                    : 'FB',
                                                'Surname': (widget.isGmail)
                                                    ? 'gmail account'
                                                    : 'FB',
                                                'Age': (widget.isGmail)
                                                    ? 'gmail account'
                                                    : 'FB',
                                                'Gender': (widget.isGmail)
                                                    ? 'gmail account'
                                                    : 'FB',
                                                'Visibility': 'Public',
                                                'Avatar': 'none',
                                                'Username':
                                                    '${userNameControl.value.text}',
                                                'Activity': 'Offline',
                                                'Bio': '',
                                                'Topics': [],
                                                'joinedClubs': 0,
                                                'numOfLinks': 0,
                                                'numOfLinked': 0,
                                                'numOfBlocked': 0,
                                                'numOfPosts': 0,
                                                'numOfMentions': 0,
                                                'numOfNewLinksNotifs': 0,
                                                'numOfNewLinkedNotifs': 0,
                                                'numOfLinkRequestsNotifs': 0,
                                                'numOfPostLikesNotifs': 0,
                                                'numOfPostCommentsNotifs': 0,
                                                'numOfCommentRepliesNotifs': 0,
                                                'PostsRemoved': 0,
                                                'CommentsRemoved': 0,
                                                'repliesRemoved': 0,
                                                'IP address': '$_ipAddress',
                                                'fcm': token,
                                                'Date created': DateTime.now(),
                                                'Platform': (isAndroid)
                                                    ? 'Android'
                                                    : 'IOS',
                                              });
                                          batch.commit().then((value) {
                                            Provider.of<MyProfile>(context,
                                                    listen: false)
                                                .setMyUsername(
                                                    userNameControl.value.text);
                                            Navigator.popUntil(context,
                                                (route) {
                                              return route.isFirst;
                                            });
                                            Navigator.pushReplacementNamed(
                                                context,
                                                RouteGenerator.setupScreen);
                                          });
                                        }
                                      }
                                    }
                                  },
                                  child: OptimisedText(
                                      minWidth: _deviceWidth * 0.5,
                                      maxWidth: _deviceWidth * 0.5,
                                      minHeight: _deviceHeight * 0.038,
                                      maxHeight: _deviceHeight * 0.038,
                                      fit: BoxFit.scaleDown,
                                      child: (_isLoading)
                                          ? CircularProgressIndicator(color: _accentColor, strokeWidth: 1.50)
                                          : Text('Next', style: TextStyle(fontSize: 35.0, color: _accentColor))))
                            ]))))));
  }
}
