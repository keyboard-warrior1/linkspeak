import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/addPostScreenState.dart';
import '../../providers/myProfileProvider.dart';

class AddTopic extends StatefulWidget {
  final void Function(String) handler;
  final List<String> topicNames;
  final bool isInProfile;
  final bool isInAddPost;
  final bool isInClubAddPost;
  const AddTopic(this.handler, this.topicNames, this.isInProfile,
      this.isInAddPost, this.isInClubAddPost);

  @override
  _AddTopicState createState() => _AddTopicState();
}

class _AddTopicState extends State<AddTopic> {
  final TextEditingController _topicNameController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool isLoading = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void _submit(String _myUsername) {
    final lang = General.language(context);
    if (isLoading) {
    } else {
      if (_key.currentState!.validate()) {
        if (widget.isInProfile) {
          setState(() => isLoading = true);
          var batch = firestore.batch();
          final myUser = firestore.collection('Users').doc('$_myUsername');
          final topicName = _topicNameController.value.text.trim();
          final thisTopic = firestore.collection('Topics').doc(topicName);
          final thisTopicProfile =
              thisTopic.collection('profiles').doc(_myUsername);
          batch.update(myUser, {
            'Topics': FieldValue.arrayUnion(['$topicName'])
          });
          batch.set(thisTopic, {'profiles': FieldValue.increment(1)},
              SetOptions(merge: true));
          batch.set(
              thisTopicProfile,
              {'times': FieldValue.increment(1), 'date': DateTime.now()},
              SetOptions(merge: true));
          batch.commit().then((value) {
            widget.handler(topicName);
            _topicNameController.clear();
            setState(() => isLoading = false);
          }).catchError((_) {
            FocusScope.of(context).unfocus();
            setState(() => isLoading = false);
            EasyLoading.showError(lang.clubs_manage13,
                dismissOnTap: true, duration: const Duration(seconds: 2));
          });
        } else {
          widget.handler(_topicNameController.value.text.trim());
          _topicNameController.clear();
        }
      } else {}
    }
  }

  @override
  void dispose() {
    super.dispose();
    _topicNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final ThemeData _theme = Theme.of(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final Color _primarySwatch = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final String _myUsername = Provider.of<MyProfile>(context).getUsername;
    String? _validator(String? value) {
      final List<String> _myTopicNames =
          Provider.of<MyProfile>(context, listen: false).getTopics;
      final List<String> _postTopicNames =
          Provider.of<NewPostHelper>(context, listen: false).formTopics;
      final exp = RegExp('${value!.trim()}', caseSensitive: false);
      if (value.replaceAll(' ', '') == '') {
        return lang.widgets_topics1;
      }
      if (widget.isInAddPost) {
        if (_postTopicNames.any((name) => exp.hasMatch(name)) &&
            (_postTopicNames.any((name) => name == value.trim()) ||
                _postTopicNames.any((name) {
                  final replacedVal = name.replaceAll(value, '');
                  return replacedVal == '';
                }))) {
          return lang.widgets_topics2;
        }
        if (_postTopicNames.length == 150) {
          return lang.widgets_topics3;
        }
      }
      if (widget.isInClubAddPost) {
        if (widget.topicNames.any((name) => exp.hasMatch(name)) &&
            (widget.topicNames.any((name) => name == value.trim()) ||
                widget.topicNames.any((name) {
                  final replacedVal = name.replaceAll(value, '');
                  return replacedVal == '';
                }))) {
          return lang.widgets_topics2;
        }
        if (widget.topicNames.length == 150) {
          return lang.widgets_topics3;
        }
      }
      if (widget.isInProfile) {
        if (_myTopicNames.any((name) => exp.hasMatch(name)) &&
            (_myTopicNames.any((name) => name == value.trim()) ||
                _myTopicNames.any((name) {
                  final replacedVal = name.replaceAll(value, '');
                  return replacedVal == '';
                }))) {
          return lang.widgets_topics2;
        }
        if (_myTopicNames.length == 150) {
          return lang.widgets_topics3;
        }
      }
      if (widget.topicNames.any((name) => exp.hasMatch(name)) &&
          (widget.topicNames.any((name) => name == value.trim()) ||
              widget.topicNames.any((name) {
                final replacedVal = name.replaceAll(value, '');
                return replacedVal == '';
              }))) {
        return lang.widgets_topics2;
      }
      if (widget.topicNames.length == 150) {
        return lang.widgets_topics3;
      }
      if (value.length > 30 || value.length < 2) {
        return lang.widgets_topics4;
      }
      if (value.isEmpty) {
        return lang.widgets_topics1;
      }
      return null;
    }

    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
            height: _deviceHeight * 0.17,
            width: _deviceWidth * 0.77,
            child: Form(
                key: _key,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextFormField(
                                  controller: _topicNameController,
                                  validator: _validator,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                      fillColor: null,
                                      focusColor: null,
                                      hoverColor: null,
                                      hintText: lang.widgets_topics5),
                                  onFieldSubmitted: (_) {
                                    _submit(_myUsername);
                                  }))),
                      Container(
                          decoration: BoxDecoration(
                              color: _primarySwatch,
                              borderRadius: const BorderRadius.only(
                                  topRight: const Radius.circular(31.0),
                                  bottomRight: const Radius.circular(31.0))),
                          child: TextButton(
                              style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color?>(
                                          _primarySwatch)),
                              child: (isLoading)
                                  ? Center(
                                      child: CircularProgressIndicator(
                                          backgroundColor: _primarySwatch,
                                          color: _accentColor,
                                          strokeWidth: 1.50))
                                  : Center(
                                      child: Text(lang.widgets_topics6,
                                          style: TextStyle(
                                              color: _accentColor,
                                              fontSize: 27,
                                              fontWeight: FontWeight.bold))),
                              onPressed: () {
                                _submit(_myUsername);
                              }))
                    ]))));
  }
}
