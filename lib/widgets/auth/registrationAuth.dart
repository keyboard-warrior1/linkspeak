import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/regHelper.dart';
import '../../providers/themeModel.dart';
import '../../routes.dart';
import '../../screens/loginScreen.dart';
import '../common/adaptiveText.dart';
import '../common/noglow.dart';
import 'registrationDialog.dart';

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
  const Field(
      {required this.controller,
      required this.label,
      required this.validator,
      required this.maxLength,
      required this.icon,
      required this.keyboardType,
      required this.showSuffix,
      required this.obscureText,
      required this.handler,
      required this.focusNode});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: TextFormField(
            keyboardType: keyboardType,
            key: UniqueKey(),
            focusNode: (focusNode != null) ? focusNode : null,
            maxLength: maxLength,
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightGreenAccent.shade400)),
                errorBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.redAccent)),
                errorStyle: const TextStyle(
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 20.0)
                    ]),
                filled: true,
                fillColor: Colors.white,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                hintText: label,
                suffixIcon: (showSuffix)
                    ? IconButton(
                        splashColor: Colors.transparent,
                        icon: Icon(icon),
                        onPressed: handler)
                    : null)));
  }
}

class RegistrationAuthBox extends StatefulWidget {
  const RegistrationAuthBox();
  @override
  _RegistrationAuthBoxState createState() => _RegistrationAuthBoxState();
}

class _RegistrationAuthBoxState extends State<RegistrationAuthBox> {
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late FirebaseMessaging fcm;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> usernameDocs = [];
  late ShowFields _showFields;
  late void Function() showSecond;
  late void Function() showThird;
  late bool agreeToTerms;
  late bool isMale;
  late bool isFemale;
  late bool isOther;
  late bool obscurePass;
  late bool obscureRepeat;
  late void Function() obscurePassword;
  late void Function() obscureRepeatPassword;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController firstNameControl;
  late final TextEditingController lastNameControl;
  late final TextEditingController emailControl;
  late final TextEditingController userNameControl;
  late final TextEditingController passwordControl;
  late final TextEditingController repeatPass;
  late final TextEditingController ageControl;
  final FocusNode passwordNode = FocusNode();
  final FocusNode confirmPasswordNode = FocusNode();

  _showDialog(IconData icon, Color iconColor, String title, String rule) {
    showDialog(
        context: context,
        builder: (_) => RegistrationDialog(
            icon: icon, iconColor: iconColor, title: title, rules: rule));
  }

  void passHandler() {
    passwordNode.unfocus();
    confirmPasswordNode.unfocus();
    passwordNode.canRequestFocus = false;
    confirmPasswordNode.canRequestFocus = false;
    obscurePassword();
    Future.delayed(const Duration(milliseconds: 100), () {
      passwordNode.canRequestFocus = true;
      confirmPasswordNode.canRequestFocus = true;
    });
  }

  void repeatHandler() {
    confirmPasswordNode.unfocus();
    passwordNode.unfocus();
    passwordNode.canRequestFocus = false;
    confirmPasswordNode.canRequestFocus = false;
    obscureRepeatPassword();
    Future.delayed(const Duration(milliseconds: 100), () {
      confirmPasswordNode.canRequestFocus = true;
      passwordNode.canRequestFocus = true;
    });
  }

  String? getGender() {
    if (isMale) return 'Male';
    if (isFemale) return 'Female';
    if (isOther) return 'Other';
    return 'Male';
  }

  late User? user;

  void buttonHandler(dynamic lang) async {
    final bool isAndroid = kIsWeb ? false : Platform.isAndroid;
    if (_showFields == ShowFields.one && _formKey.currentState!.validate()) {
      EasyLoading.show(status: lang.flares_comments1, dismissOnTap: false);
      try {
        final emails = await firestore.collection('Emails').get();
        if (emails.docs.any((email) => email.id == emailControl.value.text)) {
          EasyLoading.dismiss();
          _showDialog(Icons.cancel, Colors.red, lang.widgets_auth33,
              lang.widgets_auth34);
        } else if (!emails.docs
            .any((email) => email.id == emailControl.value.text)) {
          EasyLoading.dismiss();
          showSecond();
        }
      } catch (e) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          lang.clubs_manage13,
          dismissOnTap: true,
          duration: const Duration(seconds: 2),
        );
        _showDialog(
            Icons.cancel, Colors.red, lang.screens_help7, lang.clubs_members2);
      }
    } else if (_showFields == ShowFields.two &&
        _formKey.currentState!.validate() &&
        (isMale || isFemale || isOther)) {
      showThird();
    } else if (_showFields == ShowFields.three &&
        _formKey.currentState!.validate() &&
        agreeToTerms) {
      EasyLoading.show(status: lang.flares_comments1, dismissOnTap: false);
      try {
        final users = await firestore.collection('Users').get();
        if (users.docs.any((user) => user.id == userNameControl.value.text)) {
          EasyLoading.dismiss();
          _showDialog(Icons.cancel, Colors.red, lang.widgets_auth35,
              lang.widgets_auth36);
        } else if (!users.docs
            .any((user) => user.id == userNameControl.value.text)) {
          try {
            await auth
                .createUserWithEmailAndPassword(
                    email: emailControl.value.text,
                    password: passwordControl.value.text)
                .then((value) async {
              value.user!.sendEmailVerification().then((value) async {
                String _ipAddress = await Ipify.ipv4();
                final token = kIsWeb ? '' : await fcm.getToken();
                var batch = firestore.batch();
                General.addUsers();
                batch.set(
                    firestore
                        .collection('Emails')
                        .doc('${emailControl.value.text}'),
                    {'username': '${userNameControl.value.text.trim()}'});
                batch.set(
                    firestore
                        .collection('Users')
                        .doc('${userNameControl.value.text.trim()}'),
                    {
                      'Email': '${emailControl.value.text}',
                      'SetupComplete': 'false',
                      'Status': 'Allowed',
                      'Name': '${firstNameControl.value.text}',
                      'Surname': '${lastNameControl.value.text}',
                      'Age': '${ageControl.value.text}',
                      'Gender': '${getGender()}',
                      'Visibility': 'Public',
                      'Avatar': 'none',
                      'Username': '${userNameControl.value.text}',
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
                      'Platform': kIsWeb
                          ? 'Web'
                          : (isAndroid)
                              ? 'Android'
                              : 'IOS'
                    });
                batch.commit().then((value) {
                  _showDialog(
                      Icons.verified,
                      Colors.lightGreenAccent.shade400,
                      lang.clubs_manage12,
                      '${lang.widgets_auth37} ${emailControl.value.text}');
                  EasyLoading.dismiss();
                  setState(() {
                    LoginScreen.authMode = AuthMode.login;
                  });
                });
              }).catchError((_) {
                EasyLoading.dismiss();
                EasyLoading.showError(lang.clubs_manage13,
                    dismissOnTap: true, duration: const Duration(seconds: 2));
                _showDialog(Icons.cancel, Colors.red, lang.screens_help7,
                    lang.clubs_members2);
              });
            }).catchError((_) {
              EasyLoading.dismiss();
              EasyLoading.showError(lang.clubs_manage13,
                  dismissOnTap: true, duration: const Duration(seconds: 2));
              _showDialog(Icons.cancel, Colors.red, lang.screens_help7,
                  lang.clubs_members2);
            });
          } catch (e) {
            EasyLoading.dismiss();
            EasyLoading.showError(lang.clubs_manage13,
                dismissOnTap: true, duration: const Duration(seconds: 2));
            _showDialog(Icons.cancel, Colors.red, lang.screens_help7,
                lang.clubs_members2);
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        EasyLoading.showError(lang.clubs_manage13,
            dismissOnTap: true, duration: const Duration(seconds: 2));
        _showDialog(
            Icons.cancel, Colors.red, lang.screens_help7, lang.clubs_members2);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    firstNameControl = TextEditingController();
    lastNameControl = TextEditingController();
    emailControl = TextEditingController();
    userNameControl = TextEditingController();
    passwordControl = TextEditingController();
    repeatPass = TextEditingController();
    ageControl = TextEditingController();

    Firebase.initializeApp().whenComplete(() async {
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      fcm = FirebaseMessaging.instance;
      final getUsernames = await firestore.collection('Users').get();
      final usernamesdocs = getUsernames.docs;
      usernameDocs = [...usernamesdocs];
      user = auth.currentUser;
      if (user == null) auth.signInAnonymously();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    firstNameControl.dispose();
    lastNameControl.dispose();
    emailControl.dispose();
    userNameControl.dispose();
    passwordControl.dispose();
    repeatPass.dispose();
    ageControl.dispose();
    passwordNode.dispose();
    confirmPasswordNode.dispose();
  }

  Widget buildAgreement(String loginTheme) {
    final lang = General.language(context);
    final ThemeData _theme = Theme.of(context);
    final Color _accentColor = _theme.colorScheme.secondary;
    if (loginTheme == 'Mosaic') {
      return Stack(children: <Widget>[
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: lang.widgets_auth38,
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3.00
                    ..color = Colors.black)),
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    Navigator.of(context).pushNamed(RouteGenerator.termScreen),
              text: lang.widgets_auth39,
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3.00
                    ..color = Colors.black))
        ])),
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: lang.widgets_auth38,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold)),
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    Navigator.of(context).pushNamed(RouteGenerator.termScreen),
              text: lang.widgets_auth39,
              style: TextStyle(
                  color: _accentColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold))
        ]))
      ]);
    } else {
      return RichText(
          text: TextSpan(children: [
        TextSpan(
            text: lang.widgets_auth38,
            style: const TextStyle(color: Colors.white)),
        TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  Navigator.of(context).pushNamed(RouteGenerator.termScreen),
            text: lang.widgets_auth39,
            style: TextStyle(
                color: _accentColor,
                decoration: TextDecoration.underline,
                decorationColor: _accentColor))
      ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final RegHelper regHelper = Provider.of<RegHelper>(context);
    final String loginTheme = Provider.of<ThemeModel>(context).loginTheme;
    final RegHelper _noRegHelper =
        Provider.of<RegHelper>(context, listen: false);
    agreeToTerms = regHelper.agreeToTerms;
    obscurePass = regHelper.obscurePass;
    obscureRepeat = regHelper.obscureRepeat;
    _showFields = regHelper.showFields;
    isMale = regHelper.isMale;
    isFemale = regHelper.isFemale;
    isOther = regHelper.isOther;
    showSecond = _noRegHelper.showSecond;
    showThird = _noRegHelper.showThird;
    obscurePassword = _noRegHelper.obscurePassword;
    obscureRepeatPassword = _noRegHelper.obscureRepeatPassword;
    final ThemeData _theme = Theme.of(context);
    final Color _primarySwatch = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final double _deviceWidth = General.widthQuery(context);
    const SizedBox _heightBox = SizedBox(height: 5.0);
    final emailValidator = MultiValidator([
      RequiredValidator(errorText: lang.widgets_auth40),
      EmailValidator(errorText: lang.widgets_auth41),
      MaxLengthValidator(100, errorText: lang.widgets_auth42)
    ]);
    final passwordValidator = MultiValidator([
      RequiredValidator(errorText: lang.widgets_auth43),
      MinLengthValidator(7, errorText: lang.widgets_auth44),
      MaxLengthValidator(16, errorText: lang.widgets_auth45)
    ]);
    String? ageValidator(String? value) {
      final RegExp _expression = RegExp(r'^[0-9]{2}');
      if (value!.isEmpty ||
          value.replaceAll(' ', '') == '' ||
          value.trim() == '') return lang.widgets_auth20;
      if (!_expression.hasMatch(value)) return lang.widgets_auth21;
      if (_expression.hasMatch(value) && int.tryParse(value)! < 18)
        return lang.widgets_auth22;
      if (_expression.hasMatch(value) && int.tryParse(value)! >= 18)
        return null;
      return null;
    }

    String? nameValidator(String? value) {
      final RegExp _exp2 = RegExp(r"^[a-zA-z ]+$", caseSensitive: false);
      if (value!.isEmpty ||
          value.replaceAll(' ', '') == '' ||
          value.trim() == '') return lang.widgets_auth23;
      if (value.length < 2 || value.length > 30) return lang.widgets_auth24;
      if (!_exp2.hasMatch(value)) return lang.widgets_auth25;
      if (_exp2.hasMatch(value)) return null;
      return null;
    }

    String? surnameValidator(String? value) {
      final RegExp _exp2 = RegExp(r"^[a-zA-z ]+$", caseSensitive: false);
      if (value!.isEmpty ||
          value.replaceAll(' ', '') == '' ||
          value.trim() == '') return lang.widgets_auth26;
      if (value.length < 2 || value.length > 30) return lang.widgets_auth27;
      if (!_exp2.hasMatch(value)) return lang.widgets_auth28;
      if (_exp2.hasMatch(value)) return null;
      return null;
    }

    String? usernameValidator(String? value) {
      final filter = ProfanityFilter();
      final RegExp _exp = RegExp(r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
          multiLine: true, caseSensitive: false, dotAll: true);
      final RegExp _exp2 = RegExp('linkspeak', caseSensitive: false);
      final RegExp _hitlerexp = RegExp('hitler', caseSensitive: false);
      if (value!.isEmpty ||
          value.replaceAll(' ', '') == '' ||
          value.trim() == '') return lang.widgets_auth29;
      if (value.length < 2 || value.length > 30) return lang.widgets_auth30;
      if (usernameDocs.isNotEmpty) {
        if (usernameDocs.any((element) => element.id == value))
          return lang.widgets_auth31;
      }
      if (!_exp.hasMatch(value)) return lang.widgets_auth32;
      if (_exp2.hasMatch(value)) return lang.widgets_auth32;
      if (_hitlerexp.hasMatch(value)) return lang.widgets_auth32;
      if (filter.hasProfanity(value)) return lang.widgets_auth32;
      if (_exp.hasMatch(value)) return null;
      return null;
    }

    String? confirmPass(String? value) {
      if (value == passwordControl.value.text) {
        return null;
      } else {
        return lang.widgets_auth19;
      }
    }

    return Noglow(
        child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      const SizedBox(height: 10.0),
                      if (_showFields == ShowFields.one)
                        Field(
                            label: lang.screens_additional9,
                            controller: emailControl,
                            validator: emailValidator,
                            maxLength: 100,
                            icon: Icons.verified_user,
                            keyboardType: TextInputType.emailAddress,
                            showSuffix: false,
                            obscureText: false,
                            handler: null,
                            focusNode: null),
                      if (_showFields == ShowFields.one) _heightBox,
                      if (_showFields == ShowFields.one)
                        Field(
                            label: lang.widgets_auth46,
                            controller: ageControl,
                            validator: ageValidator,
                            maxLength: 2,
                            icon: Icons.verified_user,
                            keyboardType: TextInputType.phone,
                            showSuffix: false,
                            obscureText: false,
                            handler: null,
                            focusNode: null),
                      if (_showFields == ShowFields.two)
                        Field(
                            label: lang.widgets_auth47,
                            controller: firstNameControl,
                            validator: nameValidator,
                            maxLength: 30,
                            icon: Icons.verified_user,
                            keyboardType: TextInputType.name,
                            showSuffix: false,
                            obscureText: false,
                            handler: null,
                            focusNode: null),
                      if (_showFields == ShowFields.two) _heightBox,
                      if (_showFields == ShowFields.two)
                        Field(
                            label: lang.widgets_auth48,
                            controller: lastNameControl,
                            validator: surnameValidator,
                            maxLength: 30,
                            icon: Icons.verified_user,
                            keyboardType: TextInputType.name,
                            showSuffix: false,
                            obscureText: false,
                            handler: null,
                            focusNode: null),
                      if (_showFields == ShowFields.two) _heightBox,
                      if (_showFields == ShowFields.two)
                        SizedBox(
                            width: _deviceWidth,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const Spacer(),
                                  Checkbox(
                                      activeColor: _accentColor,
                                      checkColor: _primarySwatch,
                                      value: isMale,
                                      side: BorderSide(
                                          color: (loginTheme != 'Mosaic')
                                              ? Colors.white
                                              : Colors.black),
                                      onChanged: (_) {
                                        Provider.of<RegHelper>(context,
                                                listen: false)
                                            .maleHandler();
                                      }),
                                  if (loginTheme == 'Mosaic')
                                    Stack(children: <Widget>[
                                      Text(lang.widgets_auth49,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0,
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 3.00
                                                ..color = Colors.black)),
                                      Text(lang.widgets_auth49,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 15.0))
                                    ]),
                                  if (loginTheme != 'Mosaic')
                                    Text(lang.widgets_auth49,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            shadows: const [
                                              Shadow(
                                                  color: Colors.black,
                                                  blurRadius: 20.0)
                                            ])),
                                  const Spacer(),
                                  Checkbox(
                                      activeColor: _accentColor,
                                      checkColor: _primarySwatch,
                                      value: isFemale,
                                      side: BorderSide(
                                          color: (loginTheme != 'Mosaic')
                                              ? Colors.white
                                              : Colors.black),
                                      onChanged: (_) {
                                        Provider.of<RegHelper>(context,
                                                listen: false)
                                            .femaleHandler();
                                      }),
                                  if (loginTheme == 'Mosaic')
                                    Stack(children: <Widget>[
                                      Text(lang.widgets_auth50,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0,
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 3.00
                                                ..color = Colors.black)),
                                      Text(lang.widgets_auth50,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 15.0))
                                    ]),
                                  if (loginTheme != 'Mosaic')
                                    Text(lang.widgets_auth50,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            shadows: const [
                                              Shadow(
                                                  color: Colors.black,
                                                  blurRadius: 20.0)
                                            ])),
                                  const Spacer(),
                                ])),
                      if (_showFields == ShowFields.three)
                        Field(
                            label: lang.widgets_auth51,
                            controller: userNameControl,
                            validator: usernameValidator,
                            maxLength: 30,
                            icon: Icons.verified,
                            keyboardType: TextInputType.visiblePassword,
                            showSuffix: false,
                            obscureText: false,
                            handler: null,
                            focusNode: null),
                      if (_showFields == ShowFields.three) _heightBox,
                      if (_showFields == ShowFields.three)
                        Field(
                            label: lang.widgets_auth52,
                            controller: passwordControl,
                            validator: passwordValidator,
                            maxLength: 16,
                            icon: Icons.visibility_outlined,
                            keyboardType: TextInputType.visiblePassword,
                            showSuffix: true,
                            obscureText: obscurePass,
                            handler: passHandler,
                            focusNode: passwordNode),
                      if (_showFields == ShowFields.three) _heightBox,
                      if (_showFields == ShowFields.three)
                        Field(
                            label: lang.widgets_auth53,
                            controller: repeatPass,
                            validator: confirmPass,
                            maxLength: 16,
                            icon: Icons.visibility_outlined,
                            keyboardType: TextInputType.visiblePassword,
                            showSuffix: true,
                            obscureText: obscureRepeat,
                            handler: repeatHandler,
                            focusNode: confirmPasswordNode),
                      Padding(
                          padding:
                              const EdgeInsets.only(left: 25.0, right: 15.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                if (_showFields == ShowFields.three)
                                  Checkbox(
                                      activeColor: _accentColor,
                                      checkColor: _primarySwatch,
                                      value: agreeToTerms,
                                      side: BorderSide(
                                          color: (loginTheme != 'Mosaic')
                                              ? Colors.white
                                              : Colors.black),
                                      onChanged: (__) {
                                        Provider.of<RegHelper>(context,
                                                listen: false)
                                            .agreeterms();
                                      }),
                                if (_showFields == ShowFields.three)
                                  const SizedBox(width: 5.0),
                                if (_showFields == ShowFields.three)
                                  buildAgreement(loginTheme),
                                const Spacer(),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Container(
                                        width: 100.0,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                                padding: MaterialStateProperty.all<
                                                        EdgeInsetsGeometry?>(
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1.0,
                                                        horizontal: 5.0)),
                                                shape: MaterialStateProperty.all<OutlinedBorder?>(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(10.0),
                                                        side: BorderSide(color: (loginTheme == 'Mosaic') ? Colors.black : _accentColor))),
                                                elevation: MaterialStateProperty.all<double?>(0.0),
                                                enableFeedback: false,
                                                backgroundColor: MaterialStateProperty.all<Color?>(_accentColor)),
                                            onPressed: () => buttonHandler(lang),
                                            child: OptimisedText(minWidth: 75.0, maxWidth: 100.0, minHeight: 25.0, maxHeight: 25.0, fit: BoxFit.scaleDown, child: Text((_showFields != ShowFields.three) ? 'Next' : 'Finish', style: TextStyle(fontSize: 15.0, color: _primarySwatch))))))
                              ]))
                    ]))));
  }
}
 // Checkbox(
//   activeColor: _accentColor,
                                  //   checkColor: _primarySwatch,
                                  //   value: isOther,
                                  //   side: BorderSide(
                                  //     color: (loginTheme != 'Mosaic')
                                  //         ? Colors.white
                                  //         : Colors.black,
                                  //   ),
                                  //   onChanged: (_) {
                                  //     Provider.of<RegHelper>(context, listen: false)
                                  //         .otherHandler();
                                  //   },
                                  // ),
                                  // if (loginTheme == 'Mosaic')
                                  //   Stack(
                                  //     children: <Widget>[
                                  //       Text(
                                  //         'Other',
                                  //         style: TextStyle(
                                  //           fontWeight: FontWeight.bold,
                                  //           fontSize: 15.0,
                                  //           foreground: Paint()
                                  //             ..style = PaintingStyle.stroke
                                  //             ..strokeWidth = 3.00
                                  //             ..color = Colors.black,
                                  //         ),
                                  //       ),
                                  //       const Text(
                                  //         'Other',
                                  //         style: TextStyle(
                                  //           fontWeight: FontWeight.bold,
                                  //           color: Colors.white,
                                  //           fontSize: 15.0,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // if (loginTheme != 'Mosaic')
                                  //   const Text(
                                  //     'Other',
                                  //     style: TextStyle(
                                  //       color: Colors.white,
                                  //       shadows: const [
                                  //         Shadow(
                                  //           color: Colors.black,
                                  //           blurRadius: 20.0,
                                  //         )
                                  //       ],
                                  //     ),
                                  //   ),
                                  // const Spacer()
