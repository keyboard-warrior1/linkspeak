import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../general.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/clubProvider.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/nestedScroller.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/topics/addTopic.dart';
import '../widgets/topics/topicChip.dart';

class CreateClubScreen extends StatefulWidget {
  final dynamic addClub;
  const CreateClubScreen(this.addClub);

  @override
  _CreateClubScreenState createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {
  bool isLoading = false;
  bool changedImage = false;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final ScrollController scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _clubNameControl = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  List<String> _newTopicNames = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> usernameDocs = [];
  ClubVisibility _newVis = ClubVisibility.public;
  String myImgUrl = 'none';
  String? _validateBio(String? value) {
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return '* Club description is required';
    }
    if (value.length > 2000) {
      return '* Description can be up to 2000 characters long';
    }
    return null;
  }

  String? usernameValidator(String? value) {
    final RegExp _exp = RegExp(r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
        multiLine: true, caseSensitive: false, dotAll: true);
    final RegExp _exp2 = RegExp('linkspeak', caseSensitive: false);
    if (value!.isEmpty || value.replaceAll(' ', '') == '' || value.trim() == '')
      return '* Club name is required';
    if (value.length < 2 || value.length > 30)
      return '* Club name can be between 2-30 characters';
    if (!_exp.hasMatch(value)) return '* Invalid club name';
    if (_exp2.hasMatch(value)) return '* Invalid club name';
    if (usernameDocs.isNotEmpty) {
      if (usernameDocs.any((element) => element.id == value))
        return '* Club name already taken';
    }
    if (_exp.hasMatch(value)) return null;
    return null;
  }

  List<AssetEntity> assets = [];
  Future<void> _choose(String clubName, Color primaryColor) async {
    const int _maxAssets = 1;
    const _english = const EnglishAssetPickerTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            maxAssets: _maxAssets,
            textDelegate: _english,
            selectedAssets: assets,
            requestType: RequestType.image,
            themeColor: primaryColor));
    if (_result != null) {
      assets = List<AssetEntity>.from(_result);
      final imageFile = await assets[0].originFile;
      final path = imageFile!.absolute.path;
      final name = path.split('/').last;
      myImgUrl = name;
      changedImage = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _changeLocalVis(ClubVisibility vis) {
    setState(() {
      _newVis = vis;
    });
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
    _bioController.dispose();
    _clubNameControl.dispose();
    scrollController.dispose();
  }

  void addTopic(String topic) {
    _newTopicNames.add(topic);
    setState(() {});
  }

  void _removeTopic(int idx) {
    _newTopicNames.removeAt(idx);
    setState(() {});
  }

  Future<void> createClub(String myUsername) async {
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

    Future<void> handleTopic(String topicName) {
      var _batch = firestore.batch();
      final thisTopic = firestore.collection('Topics').doc(topicName);
      final thisTopicProfile =
          thisTopic.collection('clubs').doc(_clubNameControl.value.text);
      _batch.set(thisTopic, {'clubs': FieldValue.increment(1)},
          SetOptions(merge: true));
      _batch.set(
          thisTopicProfile,
          {'times': FieldValue.increment(1), 'date': DateTime.now()},
          SetOptions(merge: true));
      return _batch.commit();
    }

    final clubsCollection = firestore.collection('Clubs');
    final usersCollection = firestore.collection('Users');
    final getClubName =
        await clubsCollection.doc(_clubNameControl.value.text).get();
    if (getClubName.exists) {
      _showDialog(
        Icons.info_outline,
        Colors.blue,
        'Notice',
        "This club name is taken",
      );
      setState(() {
        isLoading = false;
      });
    } else {
      final DateTime _rightNow = DateTime.now();
      var batch = firestore.batch();
      final thisClubDoc = clubsCollection.doc(_clubNameControl.value.text);
      final myClubDoc = usersCollection
          .doc(myUsername)
          .collection('My Clubs')
          .doc(_clubNameControl.value.text);
      if (myImgUrl != 'none') {
        var newImgUrl =
            'Clubs/Club Avatars/${_clubNameControl.value.text}/$myImgUrl';
        myImgUrl = newImgUrl;
        File? imageFile = await assets[0].originFile;
        final String filePath = imageFile!.absolute.path;
        final int fileSize = imageFile.lengthSync();
        if (fileSize > 30000000) {
          setState(() {
            isLoading = false;
          });
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "Avatars can be up to 30 MB in size",
          );
        } else {
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          var file = File(appDocPath + "/nsfw.tflite");
          if (!file.existsSync()) {
            var data = await rootBundle.load("assets/nsfw.tflite");
            final buffer = data.buffer;
            await file.writeAsBytes(
                buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
          }
          await FlutterNsfw.initNsfw(
            file.path,
            enableLog: false,
            isOpenGPU: false,
            numThreads: 4,
          );
          await FlutterNsfw.getPhotoNSFWScore(filePath).then((result) async {
            if (result > 0.759) {
              setState(() {
                isLoading = false;
              });
              _showDialog(
                Icons.info_outline,
                Colors.blue,
                'Notice',
                "Image contains content that violates our avatar safety guidelines.",
              );
            } else {
              if (_newTopicNames.isNotEmpty)
                for (var topicName in _newTopicNames) {
                  await handleTopic(topicName);
                }
              await storage
                  .ref(myImgUrl)
                  .putFile(imageFile)
                  .then((value) async {
                final String downloadUrl =
                    await storage.ref(myImgUrl).getDownloadURL();
                Map<String, dynamic> fields = {
                  'clubs': FieldValue.increment(1)
                };
                Map<String, dynamic> docFields = {'date': _rightNow};
                General.updateControl(
                    fields: fields,
                    myUsername: myUsername,
                    collectionName: 'clubs',
                    docID: '${_clubNameControl.value.text}',
                    docFields: docFields);
                batch.set(myClubDoc, {
                  'isMod': true,
                  'isFounder': true,
                  'date': _rightNow,
                });
                batch.set(thisClubDoc, {
                  'Visibility': General.generateClubVis(_newVis),
                  'Avatar': downloadUrl,
                  'club name': _clubNameControl.value.text,
                  'about': _bioController.value.text,
                  'banner': 'none',
                  'bannerNSFW': false,
                  'date created': _rightNow,
                  'creator': myUsername,
                  'maxDailyPosts': 10,
                  'numOfPosts': 0,
                  'numOfJoinRequests': 0,
                  'numOfNewMembers': 0,
                  'numOfMembers': 0,
                  'numOfBannedMembers': 0,
                  'numOfAdmins': 1,
                  'allowQuickJoin': true,
                  'membersCanPost': false,
                  'isDisabled': false,
                  'isProhibited': false,
                  'topics': _newTopicNames,
                  'monetize': false,
                  'earnings': 0.0,
                });
                batch
                    .set(thisClubDoc.collection('Moderators').doc(myUsername), {
                  'isMod': true,
                  'isFounder': true,
                  'date': _rightNow,
                });
                batch.commit().then((value) {
                  widget.addClub(_clubNameControl.value.text);
                  Navigator.pop(context);
                }).catchError((_) {
                  setState(() {
                    isLoading = false;
                  });
                  _showDialog(Icons.cancel, Colors.red, 'Error',
                      'An error has occured');
                });
              }).catchError((_) {
                setState(() {
                  isLoading = false;
                });
                _showDialog(
                    Icons.cancel, Colors.red, 'Error', 'An error has occured');
              });
            }
          });
        }
      } else {
        if (_newTopicNames.isNotEmpty)
          for (var topicName in _newTopicNames) {
            await handleTopic(topicName);
          }
        Map<String, dynamic> fields = {'clubs': FieldValue.increment(1)};
        Map<String, dynamic> docFields = {'date': _rightNow};
        General.updateControl(
            fields: fields,
            myUsername: myUsername,
            collectionName: 'clubs',
            docID: '${_clubNameControl.value.text}',
            docFields: docFields);
        batch.set(myClubDoc, {
          'isMod': true,
          'isFounder': true,
          'date': _rightNow,
        });
        batch.set(thisClubDoc, {
          'Visibility': General.generateClubVis(_newVis),
          'Avatar': 'none',
          'club name': _clubNameControl.value.text,
          'about': _bioController.value.text,
          'banner': 'none',
          'bannerNSFW': false,
          'date created': _rightNow,
          'creator': myUsername,
          'maxDailyPosts': 10,
          'numOfPosts': 0,
          'numOfJoinRequests': 0,
          'numOfNewMembers': 0,
          'numOfMembers': 0,
          'numOfBannedMembers': 0,
          'allowQuickJoin': true,
          'membersCanPost': false,
          'isDisabled': false,
          'isProhibited': false,
          'topics': _newTopicNames,
          'monetize': false,
          'earnings': 0.0,
        });
        batch.set(thisClubDoc.collection('Moderators').doc(myUsername), {
          'isMod': true,
          'isFounder': true,
          'date': _rightNow,
        });
        batch.commit().then((value) {
          widget.addClub(_clubNameControl.value.text);
          Navigator.pop(context);
        }).catchError((_) {
          setState(() {
            isLoading = false;
          });
          _showDialog(
              Icons.cancel, Colors.red, 'Error', 'An error has occured');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final String myUsername = Provider.of<MyProfile>(context).getUsername;
    const SizedBox _heightBox = SizedBox(height: 15.0);
    final Widget _myDialog = Center(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0), color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _choose(myUsername, _primaryColor);
              },
              style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
              child: const Text(
                'Change avatar',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  fontFamily: 'Roboto',
                  fontSize: 21.0,
                  color: Colors.black,
                ),
              ),
            ),
            if (myImgUrl != 'none')
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  myImgUrl = 'none';
                  changedImage = true;
                  assets.clear();
                  setState(() {});
                },
                style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                child: const Text(
                  'Remove photo',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    fontFamily: 'Roboto',
                    fontSize: 21.0,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SizedBox(
              height: _deviceHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SettingsBar('Start a club'),
                  _heightBox,
                  Expanded(
                    child: Noglow(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        controller: scrollController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            DropdownButton(
                              borderRadius: BorderRadius.circular(15.0),
                              onChanged: (_) => setState(() {}),
                              underline: Container(color: Colors.transparent),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              value: _newVis,
                              items: [
                                DropdownMenuItem<ClubVisibility>(
                                  value: ClubVisibility.public,
                                  onTap: () =>
                                      _changeLocalVis(ClubVisibility.public),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        customIcons.MyFlutterApp.globe_no_map,
                                        color: _primaryColor,
                                        size: 25.0,
                                      ),
                                      const SizedBox(
                                        width: 15.0,
                                      ),
                                      const Text(
                                        'Public',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem<ClubVisibility>(
                                  value: ClubVisibility.private,
                                  onTap: () =>
                                      _changeLocalVis(ClubVisibility.private),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.lock_outline,
                                        color: _primaryColor,
                                        size: 25.0,
                                      ),
                                      const SizedBox(
                                        width: 15.0,
                                      ),
                                      const Text(
                                        'Private',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem<ClubVisibility>(
                                  value: ClubVisibility.hidden,
                                  onTap: () =>
                                      _changeLocalVis(ClubVisibility.hidden),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        customIcons.MyFlutterApp.hidden,
                                        color: _primaryColor,
                                        size: 25.0,
                                      ),
                                      const SizedBox(
                                        width: 15.0,
                                      ),
                                      const Text(
                                        'Hidden',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            _heightBox,
                            TextButton(
                              style: const ButtonStyle(
                                  splashFactory: NoSplash.splashFactory),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return _myDialog;
                                  }),
                              child: (assets.isNotEmpty)
                                  ? CircleAvatar(
                                      backgroundColor: Colors.grey.shade300,
                                      radius: _deviceHeight * 0.20 / 2,
                                      backgroundImage: AssetEntityImageProvider(
                                        assets[0],
                                        isOriginal: true,
                                      ),
                                    )
                                  : Container(
                                      height: _deviceHeight * 0.20,
                                      width: _deviceHeight * 0.20,
                                      decoration: BoxDecoration(
                                        color: _primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          (_clubNameControl.text.isNotEmpty)
                                              ? '${_clubNameControl.text[0]}'
                                              : '',
                                          style: TextStyle(
                                            fontSize:
                                                _deviceHeight * 0.20 / 1.75,
                                            color: _accentColor,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            _heightBox,
                            Field(
                              label: 'club name',
                              controller: _clubNameControl,
                              validator: usernameValidator,
                              maxLength: 30,
                              icon: Icons.verified,
                              keyboardType: TextInputType.visiblePassword,
                              showSuffix: false,
                              obscureText: false,
                              handler: null,
                              focusNode: null,
                            ),
                            _heightBox,
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: NestedScroller(
                                    controller: scrollController,
                                    child: TextFormField(
                                        controller: _bioController,
                                        validator: _validateBio,
                                        keyboardType: TextInputType.multiline,
                                        decoration: InputDecoration(
                                          labelText: 'club description',
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: _primaryColor),
                                          ),
                                        ),
                                        minLines: 5,
                                        maxLines: 20,
                                        maxLength: 2000))),
                            _heightBox,
                            _heightBox,
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: 75.0,
                                  maxHeight: 500.0,
                                  minWidth: _deviceWidth,
                                  maxWidth: _deviceWidth),
                              child: NestedScroller(
                                controller: scrollController,
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    children: <Widget>[
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: GestureDetector(
                                          onTap: () => showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          31.0)),
                                              backgroundColor: Colors.white,
                                              builder: (_) {
                                                return AddTopic(
                                                    addTopic,
                                                    _newTopicNames,
                                                    false,
                                                    false,
                                                    false);
                                              }),
                                          child: TopicChip(
                                              'Add topics',
                                              Icon(Icons.add,
                                                  color: _accentColor),
                                              () => showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  context: context,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      31.0,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  builder: (_) {
                                                    final _addTopic = AddTopic(
                                                        addTopic,
                                                        _newTopicNames,
                                                        false,
                                                        false,
                                                        false);
                                                    return _addTopic;
                                                  }),
                                              _accentColor,
                                              FontWeight.bold),
                                        ),
                                      ),
                                      ..._newTopicNames.map((topic) {
                                        int idx = _newTopicNames.indexOf(topic);
                                        void removeTopic() {
                                          _removeTopic(idx);
                                        }

                                        final _chip = TopicChip(
                                            topic,
                                            const Icon(Icons.close,
                                                color: Colors.red),
                                            removeTopic,
                                            Colors.white,
                                            FontWeight.normal);
                                        return _chip;
                                      }).toList()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      enableFeedback: false,
                      elevation: MaterialStateProperty.all<double?>(0.0),
                      shape: MaterialStateProperty.all<OutlinedBorder?>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: const Radius.circular(15.0),
                            topLeft: const Radius.circular(15.0),
                          ),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(_primaryColor),
                    ),
                    onPressed: () {
                      bool _isValid = _formKey.currentState!.validate();
                      if (_isValid) {
                        if (isLoading) {
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          createClub(myUsername);
                        }
                      } else {}
                    },
                    child: (isLoading)
                        ? CircularProgressIndicator(
                            color: _accentColor, strokeWidth: 1.50)
                        : Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 35.0,
                              color: _accentColor,
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
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
