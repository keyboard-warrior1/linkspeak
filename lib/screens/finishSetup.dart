import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../general.dart';
import '../models/profile.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/chatProfileImage.dart';
import '../widgets/common/nestedScroller.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/snackbar/visSnack.dart';
import '../widgets/topics/addTopic.dart';
import '../widgets/topics/topicChip.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen();

  @override
  _SetupProfileScreenState createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  bool isLoading = false;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;
  late final ScrollController scrollController;
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _bioController;
  List<String> _newTopicNames = [];
  TheVisibility _newVis = TheVisibility.public;
  String _myImgUrl = 'none';
  List<AssetEntity> assets = [];
  String? _validateBio(String? value) {
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return null;
    } else if (value.length > 1000) {
      return 'Bio can be up to 1000 characters long';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _formKey = GlobalKey<FormState>();
    _bioController = TextEditingController();
    Firebase.initializeApp().whenComplete(() {
      firestore = FirebaseFirestore.instance;
      storage = FirebaseStorage.instance;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bioController.dispose();
    scrollController.dispose();
  }

  Future<void> _choose(String myUsername, Color primaryColor) async {
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
      _myImgUrl = 'Avatars/$myUsername/$name';
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _changeVis(TheVisibility myVis, Color primarySwatch) {
    switch (myVis) {
      case TheVisibility.private:
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(
              seconds: 3,
            ),
            backgroundColor: primarySwatch,
            content: const VisSnack(Icons.lock_outline, 'private', false),
          ),
        );
        break;
      case TheVisibility.public:
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(
              seconds: 3,
            ),
            backgroundColor: primarySwatch,
            content: const VisSnack(
                customIcons.MyFlutterApp.globe_no_map, 'public', false),
          ),
        );
        break;
    }
  }

  Future<void> updateUser(BuildContext context, String myUsername) async {
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
      var batch = firestore.batch();
      final thisTopic = firestore.collection('Topics').doc(topicName);
      final thisTopicProfile = thisTopic.collection('profiles').doc(myUsername);
      batch.set(thisTopic, {'profiles': FieldValue.increment(1)},
          SetOptions(merge: true));
      batch.set(
          thisTopicProfile,
          {'times': FieldValue.increment(1), 'date': DateTime.now()},
          SetOptions(merge: true));
      return batch.commit();
    }

    if (_newTopicNames.length < 5) {
      setState(() {
        isLoading = false;
      });
      _showDialog(
        Icons.info_outline,
        Colors.blue,
        'Notice',
        "Please add at least 5 topics you like",
      );
    } else {
      final users = firestore.collection('Users');
      if (_myImgUrl != 'none') {
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
          EasyLoading.show(
            status: 'Finishing',
            dismissOnTap: false,
          );

          String _ipAddress = await Ipify.ipv4();
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
              EasyLoading.dismiss();
              _showDialog(
                Icons.info_outline,
                Colors.blue,
                'Notice',
                "Image contains content that violates our avatar safety guidelines.",
              );
            } else {
              for (var topicName in _newTopicNames) {
                await handleTopic(topicName);
              }
              await storage
                  .ref(_myImgUrl)
                  .putFile(imageFile)
                  .then((value) async {
                final String downloadUrl =
                    await storage.ref(_myImgUrl).getDownloadURL();
                await users.doc(myUsername).update(
                  {
                    'Activity': 'Online',
                    'Avatar': downloadUrl,
                    'SetupComplete': 'true',
                    'Visibility': '${General.generateProfileVis(_newVis)}',
                    'Bio': '${_bioController.value.text}',
                    'Topics': _newTopicNames,
                    'IP address': '$_ipAddress',
                  },
                ).then((value) async {
                  final MyProfile profile =
                      Provider.of<MyProfile>(context, listen: false);
                  profile.setMyAdditionalWebsite('');
                  profile.setMyAdditionalEmail('');
                  profile.setMyAdditionalNumber('');
                  profile.setMyAdditionalAddress('');
                  profile.setMyAdditionalAddressName('');
                  profile.setMyVis(General.generateProfileVis(_newVis));
                  profile.setMyProfileImage(downloadUrl);
                  profile.setMyProfileBanner('None', false);
                  profile.setMyUsername(myUsername);
                  profile.changeBio(_bioController.value.text);
                  profile.setMyTopics(_newTopicNames);
                  profile.setLikedIDs([]);
                  profile.setFavIDs([]);
                  profile.setHiddenIDs([]);
                  profile.setMyNumOfLinks(0);
                  profile.setMyNumOfLinked(0);
                  profile.setNumOfPosts(0);
                  profile.setNumOfNewLinksNotifs(0);
                  profile.setNumOfNewLinkedNotifs(0);
                  profile.setNumOfLinkRequestNotifs(0);
                  profile.setNumOfPostLikesNotifs(0);
                  profile.setNumOfPostCommentsNotifs(0);
                  profile.setNumOfCommentRepliesNotifs(0);
                  profile.setmyNumOfPostsRemovedNotifs(0);
                  profile.setNumOfCommentsRemovedNotifs(0);
                  profile.setNumOfBlocked(0);
                  EasyLoading.dismiss();
                  Navigator.popUntil(context, (route) {
                    return route.isFirst;
                  });
                  Navigator.pushReplacementNamed(
                    context,
                    RouteGenerator.feedScreen,
                  );
                }).catchError((e) {
                  EasyLoading.showError(
                    'Failed',
                    duration: const Duration(milliseconds: 1000),
                    dismissOnTap: true,
                  );
                });
              }).catchError((e) {
                EasyLoading.showError(
                  'Failed',
                  duration: const Duration(milliseconds: 1000),
                  dismissOnTap: true,
                );
              });
            }
          });
        }
      } else {
        EasyLoading.show(
          status: 'Finishing',
          dismissOnTap: false,
        );
        for (var topicName in _newTopicNames) {
          await handleTopic(topicName);
        }
        String _ipAddress = await Ipify.ipv4();
        await users.doc(myUsername).update(
          {
            'Activity': 'Online',
            'Avatar': _myImgUrl,
            'SetupComplete': 'true',
            'Visibility': '${General.generateProfileVis(_newVis)}',
            'Bio': '${_bioController.value.text}',
            'Topics': _newTopicNames,
            'IP address': '$_ipAddress',
          },
        ).then((value) async {
          final MyProfile profile =
              Provider.of<MyProfile>(context, listen: false);
          profile.setMyAdditionalWebsite('');
          profile.setMyAdditionalEmail('');
          profile.setMyAdditionalNumber('');
          profile.setMyAdditionalAddress('');
          profile.setMyAdditionalAddressName('');
          profile.setMyVis(General.generateProfileVis(_newVis));
          profile.setMyProfileImage(_myImgUrl);
          profile.setMyProfileBanner('None', false);
          profile.setMyUsername(myUsername);
          profile.changeBio(_bioController.value.text);
          profile.setMyTopics(_newTopicNames);
          profile.setLikedIDs([]);
          profile.setFavIDs([]);
          profile.setHiddenIDs([]);
          profile.setMyNumOfLinks(0);
          profile.setMyNumOfLinked(0);
          profile.setNumOfPosts(0);
          profile.setNumOfNewLinksNotifs(0);
          profile.setNumOfNewLinkedNotifs(0);
          profile.setNumOfLinkRequestNotifs(0);
          profile.setNumOfPostLikesNotifs(0);
          profile.setNumOfPostCommentsNotifs(0);
          profile.setNumOfCommentRepliesNotifs(0);
          profile.setmyNumOfPostsRemovedNotifs(0);
          profile.setNumOfCommentsRemovedNotifs(0);
          profile.setNumOfBlocked(0);
          profile.setBlockedUserIDs([]);
          profile.setMyPostIDs([]);
          EasyLoading.dismiss();
          Navigator.popUntil(context, (route) {
            return route.isFirst;
          });
          Navigator.pushReplacementNamed(
            context,
            RouteGenerator.feedScreen,
          );
        }).catchError((e) {
          EasyLoading.showError(
            'Failed',
            duration: const Duration(milliseconds: 1000),
            dismissOnTap: true,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double _deviceWidth = General.widthQuery(context);
    final String myUsername = Provider.of<MyProfile>(context).getUsername;

    const SizedBox _heightBox = SizedBox(
      height: 15.0,
    );

    final Widget _myDialog = Center(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
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
            if (_myImgUrl != 'none')
              TextButton(
                onPressed: () {
                  setState(() {
                    _myImgUrl = 'none';
                  });
                  assets.clear();
                  Navigator.pop(context);
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

    void _changeLocalVis(TheVisibility vis) {
      _changeVis(vis, _primaryColor);
      setState(() {
        _newVis = vis;
      });
    }

    void addTopic(String newTopic) {
      setState(() {
        _newTopicNames.insert(0, newTopic);
      });
    }

    void _removeTopic(int idx) {
      setState(() {
        _newTopicNames.removeAt(idx);
      });
    }

    final Widget _myImage = ChatProfileImage(
        username: myUsername,
        factor: 0.20,
        inEdit: true,
        asset: (_myImgUrl != 'none') ? assets[0] : null,
        editUrl: _myImgUrl);
    final Widget visMenu = DropdownButton(
      onChanged: (_) => setState(() {}),
      underline: Container(color: Colors.transparent),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.grey,
      ),
      value: _newVis,
      items: [
        DropdownMenuItem<TheVisibility>(
          value: TheVisibility.public,
          onTap: () => _changeLocalVis(TheVisibility.public),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                style: TextStyle(color: Colors.black, fontSize: 15.0),
              ),
            ],
          ),
        ),
        DropdownMenuItem<TheVisibility>(
          value: TheVisibility.private,
          onTap: () => _changeLocalVis(TheVisibility.private),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                style: TextStyle(color: Colors.black, fontSize: 15.0),
              ),
            ],
          ),
        ),
      ],
    );
    final Widget _myTopics = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: 150.0,
            maxHeight: 600.0,
            minWidth: _deviceWidth,
            maxWidth: _deviceWidth),
        child: NestedScroller(
          controller: scrollController,
          child: SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          31.0,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      builder: (_) {
                        return AddTopic(
                            addTopic, _newTopicNames, false, false, false);
                      },
                    ),
                    child: TopicChip(
                        'Add topics',
                        Icon(Icons.add, color: _accentColor),
                        () => showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                31.0,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            builder: (_) {
                              final _addTopic = AddTopic(addTopic,
                                  _newTopicNames, false, false, false);
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
                      const Icon(Icons.close, color: Colors.red),
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
    );
    final Widget _saveButton = TextButton(
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
        backgroundColor: MaterialStateProperty.all<Color?>(_primaryColor),
      ),
      onPressed: () {
        bool _isValid = _formKey.currentState!.validate();
        if (_isValid && !isLoading) {
          setState(() {
            isLoading = true;
          });
          updateUser(context, myUsername);
        }
      },
      child: Text(
        'Finish',
        style: TextStyle(
          fontSize: 35.0,
          color: _accentColor,
        ),
      ),
    );
    const Widget _bar = const SettingsBar('Finish Profile', null, false);
    final Widget _stuff = Expanded(
      child: Noglow(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _heightBox,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: visMenu,
              ),
              _heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    style: const ButtonStyle(
                        splashFactory: NoSplash.splashFactory),
                    onPressed: kIsWeb
                        ? () {}
                        : () => showDialog(
                            context: context,
                            builder: (ctx) {
                              return _myDialog;
                            }),
                    child: _myImage,
                  ),
                ],
              ),
              _heightBox,
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NestedScroller(
                      controller: scrollController,
                      child: TextFormField(
                          controller: _bioController,
                          validator: _validateBio,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'bio',
                            counterText: '',
                            hintText: 'Say something about yourself...',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: _primaryColor),
                            ),
                          ),
                          minLines: 5,
                          maxLines: 20,
                          maxLength: 1000))),
              _heightBox,
              _heightBox,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _myTopics,
              ),
            ],
          ),
        ),
      ),
    );
    final Widget _page = GestureDetector(
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
                _bar,
                _stuff,
                _saveButton,
              ],
            ),
          ),
        )),
      ),
    );
    return _page;
  }
}
