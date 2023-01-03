import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/settingsBar.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen();

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _feedBackController = TextEditingController();
  bool feedbackSent = false;
  bool isLoading = false;
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
  void dispose() {
    super.dispose();
    _feedBackController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final double _deviceWidth = General.widthQuery(context);
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    String? feedbackValidator(String? value) {
      if (value!.isEmpty ||
          value.replaceAll(' ', '') == '' ||
          value.trim() == '') {
        return lang.screens_feedback1;
      } else {
        return null;
      }
    }

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
                SettingsBar(lang.screens_feedback2),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    minLines: 5,
                    maxLines: 25,
                    maxLength: 1000,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    controller: _feedBackController,
                    validator: feedbackValidator,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      hintText: lang.screens_feedback2,
                    ),
                  ),
                ),
                const Spacer(),
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
                      if (_formKey.currentState!.validate()) {
                        if (feedbackSent) {
                          _showDialog(
                            Icons.help,
                            Colors.blue,
                            lang.screens_feedback3,
                            lang.screens_feedback4,
                          );
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          firestore.collection('Feedback').doc().set(
                            {
                              'description': _feedBackController.value.text,
                              'date': DateTime.now(),
                              'user': _myUsername,
                            },
                          ).then((value) {
                            _showDialog(
                              Icons.help,
                              Colors.blue,
                              lang.screens_feedback3,
                              lang.screens_feedback4,
                            );
                            setState(() {
                              isLoading = false;
                              feedbackSent = true;
                            });
                          });
                        }
                      } else {}
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
                            color: _accentColor, strokeWidth: 1.50)
                        : Text(
                            lang.screens_feedback5,
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
