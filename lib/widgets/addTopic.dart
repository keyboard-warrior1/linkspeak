import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/addPostScreenState.dart';

class AddTopic extends StatefulWidget {
  final void Function(String) handler;
  final List<String> topicNames;
  final bool isInProfile;
  final bool isInAddPost;
  const AddTopic(
    this.handler,
    this.topicNames,
    this.isInProfile,
    this.isInAddPost,
  );

  @override
  _AddTopicState createState() => _AddTopicState();
}

class _AddTopicState extends State<AddTopic> {
  final TextEditingController _topicNameController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool isLoading = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _topicNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final Color _primarySwatch = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    final String _myUsername = Provider.of<MyProfile>(context).getUsername;
    String? _validator(String? value) {
      final List<String> _myTopicNames =
          Provider.of<MyProfile>(context, listen: false).getTopics;
      final List<String> _postTopicNames =
          Provider.of<NewPostHelper>(context, listen: false).formTopics;
      final exp = RegExp('${value!.trim()}', caseSensitive: false);
      if (value.replaceAll(' ', '') == '') {
        return 'Please write a topic';
      }
      if (widget.isInAddPost) {
        if (_postTopicNames.any((name) => exp.hasMatch(name)) &&
            (_postTopicNames.any((name) => name == value.trim()) ||
                _postTopicNames.any((name) {
                  final replacedVal = name.replaceAll(value, '');
                  return replacedVal == '';
                }))) {
          return 'Topic already added';
        }
        if (_postTopicNames.length == 150) {
          return 'Limit of 150 topics reached';
        }
      }
      if (widget.isInProfile) {
        if (_myTopicNames.any((name) => exp.hasMatch(name)) &&
            (_myTopicNames.any((name) => name == value.trim()) ||
                _myTopicNames.any((name) {
                  final replacedVal = name.replaceAll(value, '');
                  return replacedVal == '';
                }))) {
          return 'Topic already added';
        }
        if (_myTopicNames.length == 150) {
          return 'Limit of 150 topics reached';
        }
      }
      if (widget.topicNames.any((name) => exp.hasMatch(name)) &&
          (widget.topicNames.any((name) => name == value.trim()) ||
              widget.topicNames.any((name) {
                final replacedVal = name.replaceAll(value, '');
                return replacedVal == '';
              }))) {
        return 'Topic already added';
      }
      if (widget.topicNames.length == 150) {
        return 'Topic already added';
      }
      if (value.length > 30 || value.length < 2) {
        return 'Topics must be between 2-30 characters long';
      }
      if (value.isEmpty) {
        return 'Please write a topic';
      }
      return null;
    }

    void _submit() {
      if (isLoading) {
      } else {
        if (_key.currentState!.validate()) {
          if (widget.isInProfile) {
            setState(() {
              isLoading = true;
            });
            final myUser = firestore.collection('Users').doc('$_myUsername');
            myUser.update({
              'Topics': FieldValue.arrayUnion(
                  ['${_topicNameController.value.text.trim()}'])
            }).then((value) {
              widget.handler(_topicNameController.value.text.trim());
              _topicNameController.clear();
              setState(() {
                isLoading = false;
              });
            }).catchError((_) {
              FocusScope.of(context).unfocus();
              setState(() {
                isLoading = false;
              });
              EasyLoading.showError(
                'Failed',
                dismissOnTap: true,
                duration:const Duration(seconds: 2),
              );
            });
          } else {
            widget.handler(_topicNameController.value.text.trim());
            _topicNameController.clear();
          }
        } else {}
      }
    }

    final Widget _addTopic = Container(
      decoration: BoxDecoration(
        color: _primarySwatch,
        borderRadius: const BorderRadius.only(
          topRight: const Radius.circular(
            31.0,
          ),
          bottomRight: const Radius.circular(
            31.0,
          ),
        ),
      ),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color?>(_primarySwatch),
        ),
        child: (isLoading)
            ? Center(
                child: CircularProgressIndicator(
                    backgroundColor: _primarySwatch, color: _accentColor),
              )
            : Center(
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: _accentColor,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        onPressed: () {
          _submit();
        },
      ),
    );
    final Widget _topicName = TextFormField(
      controller: _topicNameController,
      validator: _validator,
      autofocus: true,
      decoration: const InputDecoration(
        fillColor: null,
        focusColor: null,
        hoverColor: null,
        hintText: 'Topic',
      ),
      onFieldSubmitted: (_) {
        _submit();
      },
    );
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: _topicName,
                ),
              ),
              _addTopic,
            ],
          ),
        ),
      ),
    );
  }
}
