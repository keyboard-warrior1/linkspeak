import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:profanity_filter/profanity_filter.dart';

import '../general.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/settingsBar.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen();
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late User? user;
  bool showField1 = false;
  bool showfield2 = false;
  bool emailSent = false;
  bool feedbackSent = false;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedBackController = TextEditingController();
  void _showDialog(IconData icon, Color iconColor, String title, String rule) {
    showDialog(
        context: context,
        builder: (_) => RegistrationDialog(
            icon: icon, iconColor: iconColor, title: title, rules: rule));
  }

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: '* Invalid email address'),
    EmailValidator(errorText: '* Invalid email address'),
    MaxLengthValidator(100,
        errorText: '* Email address can be up to 100 characters long')
  ]);
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

  String? feedbackValidator(String? value) {
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return '* Invalid feedback';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      user = auth.currentUser;
      setState(() {});
    });
  }

  Future<void> _sendResetCode(String email, String username) async {
    setState(() {
      isLoading = true;
    });
    try {
      final users = await firestore.collection('Users').get();
      if (!users.docs.any((user) => user.id == username)) {
        setState(() {
          isLoading = false;
        });
        _showDialog(Icons.cancel, Colors.red, 'Invalid credentials',
            'Incorrect Username or email address');
      } else if (users.docs.any((user) => user.id == username)) {
        await firestore
            .collection('Users')
            .doc('$username')
            .get()
            .then((documentSnapshot) {
          dynamic getter(String field) {
            return documentSnapshot.get(field);
          }

          final _email = getter('Email');
          if (_email != email) {
            setState(() {
              isLoading = false;
            });
            _showDialog(Icons.cancel, Colors.red, 'Invalid credentials',
                'Incorrect username or email address');
          } else if (_email == email) {
            auth.sendPasswordResetEmail(email: email).then((value) {
              setState(() {
                emailSent = true;
                isLoading = false;
              });
              _showDialog(Icons.help, Colors.blue, 'Code sent',
                  'A reset request has been sent to your email address');
            }).catchError((onError) {
              setState(() {
                isLoading = false;
              });
              _showDialog(
                  Icons.cancel, Colors.red, 'Error', 'An error has occured');
            });
          }
        }).catchError((onError) {
          setState(() {
            isLoading = false;
          });
          _showDialog(
              Icons.cancel, Colors.red, 'Error', 'An error has occured');
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showDialog(Icons.cancel, Colors.red, 'Error', 'An error has occured');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _feedBackController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = General.widthQuery(context);
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SettingsBar('Help'),
                if (!showField1 && !showfield2)
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade300)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9.0),
                      child: Card(
                        borderOnForeground: false,
                        margin: const EdgeInsets.all(0.0),
                        child: ListTile(
                          onTap: () => setState(() => showField1 = true),
                          title: const Text(
                            'Reset password',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!showField1 && !showfield2)
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade300)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9.0),
                      child: Card(
                        borderOnForeground: false,
                        margin: const EdgeInsets.all(0.0),
                        child: ListTile(
                          onTap: () => setState(() => showfield2 = true),
                          title: const Text(
                            'Send us your feedback',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showField1)
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _usernameController,
                      validator: usernameValidator,
                      decoration: const InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        hintText: 'Username',
                      ),
                    ),
                  ),
                if (showField1)
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _emailController,
                      validator: emailValidator,
                      decoration: const InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        hintText: 'Email address',
                      ),
                    ),
                  ),
                if (showfield2)
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      minLines: 5,
                      maxLines: 25,
                      maxLength: 1000,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: _feedBackController,
                      validator: feedbackValidator,
                      decoration: const InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        hintText: 'Feedback',
                      ),
                    ),
                  ),
                const Spacer(),
                if (showField1 || showfield2)
                  TextButton(
                    style: ButtonStyle(
                      enableFeedback: false,
                      elevation: MaterialStateProperty.all<double?>(0.0),
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(_primaryColor),
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
                      if (isLoading) {
                      } else {
                        if (showField1) {
                          if (emailSent) {
                            _showDialog(
                              Icons.help,
                              Colors.blue,
                              'Code sent',
                              'A reset code has been sent to your email address',
                            );
                          } else {
                            if (_formKey.currentState!.validate() &&
                                showField1) {
                              _sendResetCode(_emailController.value.text,
                                  _usernameController.value.text);
                            } else {}
                          }
                        } else {
                          if (_formKey.currentState!.validate() && showfield2) {
                            if (feedbackSent) {
                              _showDialog(
                                Icons.help,
                                Colors.blue,
                                'Feedback sent',
                                'Your feedback has been sent succesfully.',
                              );
                            } else {
                              setState(() {
                                isLoading = true;
                              });
                              firestore.collection('Feedback').doc().set(
                                {
                                  'description': _feedBackController.value.text,
                                  'date': DateTime.now(),
                                },
                              ).then((value) {
                                _showDialog(
                                  Icons.help,
                                  Colors.blue,
                                  'Feedback sent',
                                  'Your feedback has been sent successfully.',
                                );
                                setState(() {
                                  isLoading = false;
                                  feedbackSent = true;
                                });
                              });
                            }
                          } else {}
                        }
                      }
                    },
                    child: OptimisedText(
                      minWidth: _deviceWidth * 0.5,
                      maxWidth: _deviceWidth * 0.5,
                      minHeight: 35.0,
                      maxHeight: 55.0,
                      fit: BoxFit.scaleDown,
                      child: (isLoading)
                          ? CircularProgressIndicator(
                              color: _accentColor,
                              strokeWidth: 1.50,
                            )
                          : Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 35.0,
                                color: _accentColor,
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
  }
}
