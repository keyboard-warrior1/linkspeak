import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../routes.dart';
import '../providers/regHelper.dart';
import '../screens/loginScreen.dart';
import 'adaptiveText.dart';
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
        key: UniqueKey(),
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
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
          ),
          errorStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white,
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

class RegistrationAuthBox extends StatefulWidget {
  const RegistrationAuthBox();
  @override
  _RegistrationAuthBoxState createState() => _RegistrationAuthBoxState();
}

class _RegistrationAuthBoxState extends State<RegistrationAuthBox> {
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
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

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: '* Email address is required'),
    EmailValidator(errorText: '* Invalid email address'),
    MaxLengthValidator(100,
        errorText: '* Email address cannot be more than 100 characters long')
  ]);
  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: '* Password is required'),
    MinLengthValidator(7,
        errorText: '* password should be between 7-16 characters'),
    MaxLengthValidator(16,
        errorText: '* password should be between 7-16 characters')
  ]);
  String? confirmPass(String? value) {
    if (value == passwordControl.value.text) {
      return null;
    } else {
      return '* Passwords do not match';
    }
  }

  String? ageValidator(String? value) {
    final RegExp _expression = RegExp(r'^[0-9]{2}');
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return '* Age is required';
    }
    if (!_expression.hasMatch(value)) {
      return '* Invalid age';
    }
    if (_expression.hasMatch(value) && int.tryParse(value)! < 18) {
      return '* You need to be atleast 18 years old to access Linkspeak';
    }

    if (_expression.hasMatch(value) && int.tryParse(value)! >= 18) {
      return null;
    }
  }

  String? nameValidator(String? value) {
    final RegExp _exp2 = RegExp(
      r"^[a-zA-z]+$",
      caseSensitive: false,
    );
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return '* Name is required';
    }

    if (value.length < 2 || value.length > 30) {
      return '* Name must be between 2-30 letters';
    }
    if (!_exp2.hasMatch(value)) {
      return '* Invalid name';
    }
    if (_exp2.hasMatch(value)) {
      return null;
    }
  }

  String? surnameValidator(String? value) {
    final RegExp _exp2 = RegExp(r"^[a-zA-z]+$", caseSensitive: false);
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return '* Surname is required';
    }

    if (value.length < 2 || value.length > 30) {
      return '* Surname must be between 2-30 letters';
    }
    if (!_exp2.hasMatch(value)) {
      return '* Invalid surname';
    }
    if (_exp2.hasMatch(value)) {
      return null;
    }
  }

  String? usernameValidator(String? value) {
    final filter = ProfanityFilter();
    final RegExp _exp = RegExp(
      r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,20}$',
      multiLine: true,
      caseSensitive: false,
      dotAll: true,
    );
    final RegExp _exp2 = RegExp('linkspeak', caseSensitive: false);
    final RegExp _hitlerexp = RegExp('hitler', caseSensitive: false);
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return '* username is required';
    }
    if (value.length < 2 || value.length > 30) {
      return '* username must be between 2-30 characters';
    }
    if (usernameDocs.isNotEmpty) {
      if (usernameDocs.any((element) => element.id == value)) {
        return '* username already taken';
      }
    }
    if (!_exp.hasMatch(value)) {
      return '* Invalid username';
    }
    if (_exp2.hasMatch(value)) {
      return '* Invalid username';
    }
    if (_hitlerexp.hasMatch(value)) {
      return '* Invalid username';
    }
    if (filter.hasProfanity(value)) {
      return '* Invalid username';
    }
    if (_exp.hasMatch(value)) {
      return null;
    }
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
    if (isMale) {
      return 'Male';
    }
    if (isFemale) {
      return 'Female';
    }
    if (isOther) {
      return 'Other';
    }
  }

  late User? user;

  void buttonHandler() async {
    final bool isAndroid = io.Platform.isAndroid;
    if (_showFields == ShowFields.one && _formKey.currentState!.validate()) {
      EasyLoading.show(status: 'loading', dismissOnTap: false);
      try {
        final emails = await firestore.collection('Emails').get();
        if (emails.docs.any((email) => email.id == emailControl.value.text)) {
          EasyLoading.dismiss();
          _showDialog(
            Icons.cancel,
            Colors.red,
            'Email exists',
            'This email address already has an account',
          );
        } else if (!emails.docs
            .any((email) => email.id == emailControl.value.text)) {
          EasyLoading.dismiss();
          showSecond();
        }
      } catch (e) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          'Failed',
          dismissOnTap: true,
          duration: const Duration(seconds: 2),
        );
        _showDialog(Icons.cancel, Colors.red, 'Error', 'An error has occured');
      }
    } else if (_showFields == ShowFields.two &&
        _formKey.currentState!.validate() &&
        (isMale || isFemale || isOther)) {
      showThird();
    } else if (_showFields == ShowFields.three &&
        _formKey.currentState!.validate() &&
        agreeToTerms) {
      EasyLoading.show(status: 'loading', dismissOnTap: false);
      try {
        final users = await firestore.collection('Users').get();
        if (users.docs.any((user) => user.id == userNameControl.value.text)) {
          EasyLoading.dismiss();
          _showDialog(
            Icons.cancel,
            Colors.red,
            'Username exists',
            'This username is already taken',
          );
        } else if (!users.docs
            .any((user) => user.id == userNameControl.value.text)) {
          try {
            await auth
                .createUserWithEmailAndPassword(
              email: emailControl.value.text,
              password: passwordControl.value.text,
            )
                .then((value) async {
              value.user!.sendEmailVerification().then((value) async {
                String _ipAddress = await Ipify.ipv4();
                var batch = firestore.batch();
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
                      'numOfLinks': 0,
                      'numOfLinked': 0,
                      'numOfBlocked': 0,
                      'numOfPosts': 0,
                      'Topics': [],
                      'numOfNewLinksNotifs': 0,
                      'numOfNewLinkedNotifs': 0,
                      'numOfLinkRequestsNotifs': 0,
                      'numOfPostLikesNotifs': 0,
                      'numOfPostCommentsNotifs': 0,
                      'numOfCommentRepliesNotifs': 0,
                      'PostsRemoved': 0,
                      'CommentsRemoved': 0,
                      'IP address': '$_ipAddress',
                      'Date created': DateTime.now(),
                      'Platform': (isAndroid) ? 'Android' : 'IOS',
                    });
                void addCollection(String collectionName) {
                  batch.set(
                      firestore
                          .collection('Users')
                          .doc('${userNameControl.value.text.trim()}')
                          .collection('$collectionName')
                          .doc(),
                      {'0': 1});
                }

                addCollection('Blocked');
                addCollection('Posts');
                addCollection('FavPosts');
                addCollection('LikedPosts');
                addCollection('HiddenPosts');
                batch.commit().then((value) {
                  _showDialog(
                    Icons.verified,
                    Colors.lightGreenAccent.shade400,
                    'Success',
                    'A verification link has been sent to ${emailControl.value.text}',
                  );
                  EasyLoading.dismiss();
                  setState(() {
                    LoginScreen.authMode = AuthMode.login;
                  });
                });
              }).catchError((_) {
                EasyLoading.dismiss();
                EasyLoading.showError(
                  'Failed',
                  dismissOnTap: true,
                  duration: const Duration(seconds: 2),
                );
                _showDialog(
                    Icons.cancel, Colors.red, 'Error', 'An error has occured');
              });
            }).catchError((_) {
              EasyLoading.dismiss();
              EasyLoading.showError(
                'Failed',
                dismissOnTap: true,
                duration: const Duration(seconds: 2),
              );
              _showDialog(
                  Icons.cancel, Colors.red, 'Error', 'An error has occured');
            });
          } catch (e) {
            EasyLoading.dismiss();
            EasyLoading.showError(
              'Failed',
              dismissOnTap: true,
              duration: const Duration(seconds: 2),
            );
            _showDialog(
                Icons.cancel, Colors.red, 'Error', 'An error has occured');
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          'Failed',
          dismissOnTap: true,
          duration: const Duration(seconds: 2),
        );
        _showDialog(Icons.cancel, Colors.red, 'Error', 'An error has occured');
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

  @override
  Widget build(BuildContext context) {
    final RegHelper regHelper = Provider.of<RegHelper>(context);
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
    final Color _primarySwatch = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    const SizedBox _heightBox = SizedBox(
      height: 5.0,
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
        return false;
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const SizedBox(
                height: 10.0,
              ),
              if (_showFields == ShowFields.one)
                Field(
                  label: 'E-mail',
                  controller: emailControl,
                  validator: emailValidator,
                  maxLength: 100,
                  icon: Icons.verified_user,
                  keyboardType: TextInputType.emailAddress,
                  showSuffix: false,
                  obscureText: false,
                  handler: null,
                  focusNode: null,
                ),
              if (_showFields == ShowFields.one) _heightBox,
              if (_showFields == ShowFields.one)
                Field(
                  label: 'Age',
                  controller: ageControl,
                  validator: ageValidator,
                  maxLength: 2,
                  icon: Icons.verified_user,
                  keyboardType: TextInputType.phone,
                  showSuffix: false,
                  obscureText: false,
                  handler: null,
                  focusNode: null,
                ),
              if (_showFields == ShowFields.two)
                Field(
                  label: 'Name',
                  controller: firstNameControl,
                  validator: nameValidator,
                  maxLength: 30,
                  icon: Icons.verified_user,
                  keyboardType: TextInputType.name,
                  showSuffix: false,
                  obscureText: false,
                  handler: null,
                  focusNode: null,
                ),
              if (_showFields == ShowFields.two) _heightBox,
              if (_showFields == ShowFields.two)
                Field(
                  label: 'Surname',
                  controller: lastNameControl,
                  validator: surnameValidator,
                  maxLength: 30,
                  icon: Icons.verified_user,
                  keyboardType: TextInputType.name,
                  showSuffix: false,
                  obscureText: false,
                  handler: null,
                  focusNode: null,
                ),
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
                        onChanged: (_) {
                          Provider.of<RegHelper>(context, listen: false)
                              .maleHandler();
                        },
                      ),
                      Text(
                        'Male',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Checkbox(
                        activeColor: _accentColor,
                        checkColor: _primarySwatch,
                        value: isFemale,
                        onChanged: (_) {
                          Provider.of<RegHelper>(context, listen: false)
                              .femaleHandler();
                        },
                      ),
                      Text(
                        'Female',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Checkbox(
                        activeColor: _accentColor,
                        checkColor: _primarySwatch,
                        value: isOther,
                        onChanged: (_) {
                          Provider.of<RegHelper>(context, listen: false)
                              .otherHandler();
                        },
                      ),
                      Text(
                        'Other',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              if (_showFields == ShowFields.three)
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
                  focusNode: null,
                ),
              if (_showFields == ShowFields.three) _heightBox,
              if (_showFields == ShowFields.three)
                Field(
                  label: 'password',
                  controller: passwordControl,
                  validator: passwordValidator,
                  maxLength: 16,
                  icon: Icons.visibility_outlined,
                  keyboardType: TextInputType.visiblePassword,
                  showSuffix: true,
                  obscureText: obscurePass,
                  handler: passHandler,
                  focusNode: passwordNode,
                ),
              if (_showFields == ShowFields.three) _heightBox,
              if (_showFields == ShowFields.three)
                Field(
                  label: 'confirm password',
                  controller: repeatPass,
                  validator: confirmPass,
                  maxLength: 16,
                  icon: Icons.visibility_outlined,
                  keyboardType: TextInputType.visiblePassword,
                  showSuffix: true,
                  obscureText: obscureRepeat,
                  handler: repeatHandler,
                  focusNode: confirmPasswordNode,
                ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 15.0),
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
                        onChanged: (__) {
                          Provider.of<RegHelper>(context, listen: false)
                              .agreeterms();
                        },
                      ),
                    if (_showFields == ShowFields.three)
                      const SizedBox(width: 5.0),
                    if (_showFields == ShowFields.three)
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.of(context)
                                    .pushNamed(RouteGenerator.termScreen),
                              text: 'terms',
                              style: TextStyle(
                                color: _accentColor,
                                decoration: TextDecoration.underline,
                                decorationColor: _accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        width: 100.0,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry?>(
                              const EdgeInsets.symmetric(
                                vertical: 1.0,
                                horizontal: 5.0,
                              ),
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder?>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            elevation: MaterialStateProperty.all<double?>(0.0),
                            enableFeedback: false,
                            backgroundColor:
                                MaterialStateProperty.all<Color?>(_accentColor),
                          ),
                          onPressed: buttonHandler,
                          child: OptimisedText(
                            minWidth: 75.0,
                            maxWidth: 100.0,
                            minHeight: 25.0,
                            maxHeight: 25.0,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              (_showFields != ShowFields.three)
                                  ? 'Next'
                                  : 'Finish',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: _primarySwatch,
                              ),
                            ),
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
