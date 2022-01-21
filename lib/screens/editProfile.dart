import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';
import '../routes.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../models/profile.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/settingsBar.dart';
import '../widgets/addTopic.dart';
import '../widgets/topicChip.dart';
import '../widgets/profileImage.dart';
import '../widgets/visSnack.dart';
import '../widgets/registrationDialog.dart';
import '../widgets/deleteProfileButton.dart';
import '../widgets/myProfileBanner.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen();

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firestore = FirebaseFirestore.instance;
  late FirebaseAuth? auth;
  final storage = FirebaseStorage.instance;

  bool isLoading = false;
  bool changedImage = false;
  bool somethingChanged = false;
  late final ScrollController scrollController;
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _bioController;
  late List<String> _newTopicNames;
  late TheVisibility _newVis;
  late String myImgUrl;
  String? _validateBio(String? value) {
    if (value!.length > 1000) {
      return 'This cannot be more than 1000 characters long.';
    } else {
      return null;
    }
  }

  String _blockedNumber(num value) {
    if (value >= 99) {
      return '99+';
    } else {
      return value.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _formKey = GlobalKey<FormState>();
    final MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    final String _myBio = _myProfile.getBio;
    _bioController = TextEditingController(text: _myBio);
    final List<String> _myTopicNames = _myProfile.getTopics;
    _newVis = _myProfile.getVisibility;
    _newTopicNames = _myTopicNames;
    myImgUrl = _myProfile.getProfileImage;
    _bioController.addListener(() {
      if (_bioController.value.text != _myBio) {
        if (!somethingChanged) {
          if (mounted) {
            setState(() {
              somethingChanged = true;
            });
          }
        }
      } else {}
    });
    Firebase.initializeApp().whenComplete(() {
      auth = FirebaseAuth.instance;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bioController.removeListener(() {});
    _bioController.dispose();
    scrollController.dispose();
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
            content: const VisSnack(
              Icons.lock_outline,
              'private',
            ),
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
              customIcons.MyFlutterApp.globe_no_map,
              'public',
            ),
          ),
        );
        break;
    }
  }

  String generateVis(TheVisibility vis) {
    if (vis == TheVisibility.public) {
      return 'Public';
    } else if (vis == TheVisibility.private) {
      return 'Private';
    }
    return '';
  }

  List<AssetEntity> assets = [];
  Future<void> _choose(String myUsername, Color primaryColor) async {
    const int _maxAssets = 1;
    final _english = EnglishTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(
      context,
      maxAssets: _maxAssets,
      textDelegate: _english,
      selectedAssets: assets,
      requestType: RequestType.image,
      themeColor: primaryColor,
    );
    if (_result != null) {
      assets = List<AssetEntity>.from(_result);
      final imageFile = await assets[0].originFile;
      final path = imageFile!.absolute.path;
      final name = path.split('/').last;
      myImgUrl = 'Avatars/$myUsername/$name';
      somethingChanged = true;
      changedImage = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> updateUser(
    String myUsername,
    String profileImageUrl,
    void Function(String) _changeBio,
    void Function(List<String>) _changeTopics,
    void Function(TheVisibility)? _changeVisibility,
    void Function(String) _changeImage,
  ) async {
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

    final users = firestore.collection('Users');
    if (changedImage) {
      if (myImgUrl != 'none') {
        if (profileImageUrl != 'none') {
          FirebaseStorage.instance.refFromURL(profileImageUrl).delete();
        }
        File? imageFile = await assets[0].originFile;
        final String filePath = imageFile!.absolute.path;
        final int fileSize = imageFile.lengthSync();
        if (fileSize > 15000000) {
          setState(() {
            isLoading = false;
          });
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "Avatars can be up to 15 MB",
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
            if (result > 0.75) {
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
              await storage
                  .ref(myImgUrl)
                  .putFile(imageFile)
                  .then((value) async {
                final String downloadUrl =
                    await storage.ref(myImgUrl).getDownloadURL();
                await users.doc(myUsername).update(
                  {
                    'Avatar': downloadUrl,
                    'Visibility': '${generateVis(_newVis)}',
                    'Bio': '${_bioController.value.text}',
                    'Topics': _newTopicNames,
                  },
                ).then((value) async {
                  EasyLoading.showSuccess('Success',
                      duration: const Duration(seconds: 2), dismissOnTap: true);
                  _changeBio(_bioController.value.text);
                  _changeTopics(_newTopicNames);
                  _changeVisibility!(_newVis);
                  _changeImage(downloadUrl);
                  setState(() {
                    isLoading = false;
                    somethingChanged = false;
                    changedImage = false;
                  });
                }).catchError((_) {
                  EasyLoading.showError(
                    'Failed',
                    duration: const Duration(seconds: 2),
                    dismissOnTap: true,
                  );
                  setState(() {
                    isLoading = false;
                  });
                });
              }).catchError((_) {
                EasyLoading.showError(
                  'Failed',
                  duration: const Duration(seconds: 2),
                  dismissOnTap: true,
                );
                setState(() {
                  isLoading = false;
                });
              });
            }
          });
        }
      } else if (myImgUrl == 'none') {
        if (profileImageUrl != 'none') {
          FirebaseStorage.instance.refFromURL(profileImageUrl).delete();
        }
        await users.doc(myUsername).update(
          {
            'Avatar': 'none',
            'Visibility': '${generateVis(_newVis)}',
            'Bio': '${_bioController.value.text}',
            'Topics': _newTopicNames,
          },
        ).then((value) async {
          EasyLoading.showSuccess('Success',
              duration: const Duration(seconds: 2), dismissOnTap: true);
          _changeBio(_bioController.value.text);
          _changeTopics(_newTopicNames);
          _changeVisibility!(_newVis);
          _changeImage('none');
          setState(() {
            isLoading = false;
            somethingChanged = false;
            changedImage = false;
          });
        }).catchError((_) {
          EasyLoading.showError(
            'Failed',
            duration: const Duration(seconds: 2),
            dismissOnTap: true,
          );
          setState(() {
            isLoading = false;
          });
        });
      }
    } else {
      await users.doc(myUsername).update(
        {
          'Visibility': '${generateVis(_newVis)}',
          'Bio': '${_bioController.value.text}',
          'Topics': _newTopicNames,
        },
      ).then((value) async {
        EasyLoading.showSuccess('Success',
            duration: const Duration(seconds: 2), dismissOnTap: true);
        _changeBio(_bioController.value.text);
        _changeTopics(_newTopicNames);
        _changeVisibility!(_newVis);
        setState(() {
          isLoading = false;
          somethingChanged = false;
        });
      }).catchError((_) {
        EasyLoading.showError(
          'Failed',
          duration: const Duration(seconds: 2),
          dismissOnTap: true,
        );
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final String myUsername = Provider.of<MyProfile>(context).getUsername;
    final String profileImgUrl =
        Provider.of<MyProfile>(context).getProfileImage;
    const SizedBox _heightBox = SizedBox(height: 15.0);
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
            if (myImgUrl != 'none')
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  myImgUrl = 'none';
                  somethingChanged = true;
                  changedImage = true;

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
    final Widget _page = GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Consumer<MyProfile>(builder: (ctx, myProfile, _) {
            final String _myUsername = myProfile.getUsername;

            final void Function(TheVisibility)? _changeVisibility =
                myProfile.setMyVisibilityStatus;
            final int _numOfBlockedUsers = myProfile.myNumOfBlocked;
            void _changeLocalVis(TheVisibility vis) {
              setState(() {
                _newVis = vis;
                somethingChanged = true;
              });
              _changeVis(vis, _primaryColor);
            }

            void addTopic(String newTopic) {
              setState(() {
                _newTopicNames.insert(0, newTopic);
                somethingChanged = true;
              });
            }

            void _removeTopic(int idx) {
              setState(() {
                _newTopicNames.removeAt(idx);
                somethingChanged = true;
              });
            }

            void _changeTopics(List<String> newNames) {
              myProfile.changeTopics(newNames);
            }

            void _changeBio(String newBio) {
              myProfile.changeBio(newBio);
            }

            void _changeImage(String newUrl) {
              myProfile.setMyProfileImage(newUrl);
            }

            final Widget _myImage = ProfileImage(
              username: _myUsername,
              url: myImgUrl,
              factor: 0.20,
              inEdit: true,
              asset:
                  (myImgUrl != 'none' && assets.isNotEmpty) ? assets[0] : null,
            );
            final Widget visMenu = DropdownButton(
              borderRadius: BorderRadius.circular(15.0),
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
            final Widget _myTopics = ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 75.0,
                maxHeight: 500.0,
                minWidth: _deviceWidth,
                maxWidth: _deviceWidth,
              ),
              child: NotificationListener<OverscrollNotification>(
                onNotification: (OverscrollNotification value) {
                  if (value.overscroll < 0 &&
                      scrollController.offset + value.overscroll <= 0) {
                    if (scrollController.offset != 0)
                      scrollController.jumpTo(0);
                    return true;
                  }
                  if (scrollController.offset + value.overscroll >=
                      scrollController.position.maxScrollExtent) {
                    if (scrollController.offset !=
                        scrollController.position.maxScrollExtent)
                      scrollController
                          .jumpTo(scrollController.position.maxScrollExtent);
                    return true;
                  }
                  scrollController
                      .jumpTo(scrollController.offset + value.overscroll);
                  return true;
                },
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
                                  addTopic, _newTopicNames, false, false);
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
                                    final _addTopic = AddTopic(
                                      addTopic,
                                      _newTopicNames,
                                      false,
                                      false,
                                    );
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
                            Icon(
                              Icons.cancel_rounded,
                              color: Colors.red,
                            ),
                            removeTopic,
                            Colors.white,
                            FontWeight.normal);
                        return _chip;
                      }).toList()
                    ],
                  ),
                ),
              ),
            );
            final Widget _deleteProfile = DeleteProfileButton(isLoading, () {
              setState(() {
                isLoading = true;
              });
            });
            final Widget _additionalInfoButton = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (!isLoading) {
                        Navigator.pushNamed(
                            context, RouteGenerator.additionalInfoScreen);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(_primaryColor),
                    ),
                    child: const Center(
                      child: const Text(
                        'Additional details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
            final Widget _saveButton = Opacity(
              opacity: (somethingChanged) ? 1.0 : .65,
              child: TextButton(
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
                  if (_isValid && somethingChanged) {
                    if (isLoading) {
                    } else {
                      setState(() {
                        isLoading = true;
                      });
                      updateUser(
                        myUsername,
                        profileImgUrl,
                        _changeBio,
                        _changeTopics,
                        _changeVisibility!,
                        _changeImage,
                      );
                    }
                  } else {}
                },
                child: (isLoading)
                    ? CircularProgressIndicator(color: _accentColor)
                    : Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 35.0,
                          color: _accentColor,
                        ),
                      ),
              ),
            );
            const Widget _bar = const SettingsBar('Edit Profile');
            final Widget _stuff = Expanded(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowGlow();
                  return false;
                },
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  controller: scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _heightBox,
                      MyProfileBanner(true),
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
                            onPressed: () => showDialog(
                                context: context,
                                builder: (ctx) {
                                  return _myDialog;
                                }),
                            child: _myImage,
                          ),
                        ],
                      ),
                      _heightBox,
                      NotificationListener<OverscrollNotification>(
                        onNotification: (OverscrollNotification value) {
                          if (value.overscroll < 0 &&
                              scrollController.offset + value.overscroll <= 0) {
                            if (scrollController.offset != 0)
                              scrollController.jumpTo(0);
                            return true;
                          }
                          if (scrollController.offset + value.overscroll >=
                              scrollController.position.maxScrollExtent) {
                            if (scrollController.offset !=
                                scrollController.position.maxScrollExtent)
                              scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent);
                            return true;
                          }
                          scrollController.jumpTo(
                              scrollController.offset + value.overscroll);
                          return true;
                        },
                        child: TextFormField(
                          controller: _bioController,
                          validator: _validateBio,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'bio',
                            counterText: '',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: _primaryColor),
                            ),
                          ),
                          minLines: 5,
                          maxLines: 20,
                          maxLength: 1000,
                        ),
                      ),
                      _heightBox,
                      _heightBox,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _myTopics,
                      ),
                      const Divider(),
                      ListTile(
                        onTap: () => Navigator.of(context)
                            .pushNamed(RouteGenerator.blockedUserScreen),
                        horizontalTitleGap: 5.0,
                        leading: Icon(
                          customIcons.MyFlutterApp.no_stopping,
                          color: Colors.black,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              'Blocked users',
                              style: TextStyle(color: Colors.black),
                            ),
                            const SizedBox(width: 10.0),
                            if (_numOfBlockedUsers > 0)
                              Badge(
                                elevation: 0.0,
                                toAnimate: false,
                                badgeContent: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 10.0),
                                  child: Text(
                                    _blockedNumber(_numOfBlockedUsers),
                                    style: const TextStyle(
                                      letterSpacing: 0.85,
                                      fontSize: 15.0,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                badgeColor: Colors.amber,
                                borderRadius: BorderRadius.circular(5.0),
                                shape: BadgeShape.square,
                              ),
                          ],
                        ),
                      ),
                      const Divider(),
                      _additionalInfoButton,
                      _deleteProfile,
                    ],
                  ),
                ),
              ),
            );
            return Form(
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
            );
          }),
        ),
      ),
    );
    return _page;
  }
}
