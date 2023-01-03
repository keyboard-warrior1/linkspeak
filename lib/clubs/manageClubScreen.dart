import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:path_provider/path_provider.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../clubs/clubAvatar.dart';
import '../clubs/clubBanner.dart';
import '../general.dart';
import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/clubProvider.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/nestedScroller.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/snackbar/visSnack.dart';
import '../widgets/topics/addTopic.dart';
import '../widgets/topics/topicChip.dart';

class ManageClubScreen extends StatefulWidget {
  final dynamic clubName;
  final dynamic clubAbout;
  final dynamic clubTopics;
  final dynamic clubAvatarUrl;
  final dynamic clubVisibility;
  final dynamic instance;
  final dynamic membersCanPost;
  final dynamic allowQuickJoin;
  final dynamic isDisabled;
  final dynamic maxDailyPosts;
  const ManageClubScreen(
      {required this.clubName,
      required this.clubAbout,
      required this.clubTopics,
      required this.clubAvatarUrl,
      required this.instance,
      required this.clubVisibility,
      required this.membersCanPost,
      required this.allowQuickJoin,
      required this.isDisabled,
      required this.maxDailyPosts});

  @override
  _ManageClubScreenState createState() => _ManageClubScreenState();
}

class _ManageClubScreenState extends State<ManageClubScreen> {
  bool isLoading = false;
  bool changedImage = false;
  bool somethingChanged = false;
  bool membersCanPost = false;
  bool allowQuickJoin = false;
  bool disableClub = false;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late FirebaseAuth? auth;
  late final ScrollController scrollController;
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _bioController;
  late TextEditingController _maxDailyPostsController;
  List<String> _newTopicNames = [];
  List<String> removedTopicNames = [];
  List<String> addedTopicNames = [];
  late ClubVisibility _newVis;
  late String myImgUrl;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _formKey = GlobalKey<FormState>();
    final String _myBio = widget.clubAbout;
    final int maxDailyPosts = widget.maxDailyPosts;
    allowQuickJoin = widget.allowQuickJoin;
    membersCanPost = widget.membersCanPost;
    disableClub = widget.isDisabled;
    _maxDailyPostsController =
        TextEditingController(text: maxDailyPosts.toString());
    _bioController = TextEditingController(text: _myBio);
    List<String> _myTopicNames = widget.clubTopics;
    _newVis = widget.clubVisibility;
    _newTopicNames = [..._myTopicNames];
    myImgUrl = widget.clubAvatarUrl;
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
    _maxDailyPostsController.addListener(() {
      if (_maxDailyPostsController.value.text != maxDailyPosts.toString()) {
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
    _maxDailyPostsController.removeListener(() {});
    _maxDailyPostsController.dispose();
    scrollController.dispose();
  }

  void _changeVis(ClubVisibility myVis, Color primarySwatch) {
    final lang = General.language(context);
    switch (myVis) {
      case ClubVisibility.private:
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3),
            backgroundColor: primarySwatch,
            content: VisSnack(Icons.lock_outline, lang.clubs_manage5, true)));
        break;
      case ClubVisibility.public:
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3),
            backgroundColor: primarySwatch,
            content: VisSnack(customIcons.MyFlutterApp.globe_no_map,
                lang.clubs_manage6, true)));
        break;
      case ClubVisibility.hidden:
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3),
            backgroundColor: primarySwatch,
            content: VisSnack(
                customIcons.MyFlutterApp.hidden, lang.clubs_manage7, true)));
        break;
    }
  }

  List<AssetEntity> assets = [];
  Future<void> _choose(String myUsername, Color primaryColor, dynamic lang) async {
    const int _maxAssets = 1;
    final _english = lang.assetPickerDelegate;
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
      myImgUrl = 'Clubs/Club Avatars/$myUsername/$name';
      somethingChanged = true;
      changedImage = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> updateUser(
      {required String xAvatar,
      required String xBanner,
      required bool xBannerNSFW,
      required String xVisibility,
      required String xAbout,
      required xtopics,
      required bool xMembersCanPost,
      required int xMaxDailyPosts,
      required bool xAllowQuickJoin,
      required bool xIsDisabled,
      required String thisAdmin,
      required String myUsername,
      required String profileImageUrl,
      required void Function(String) changeBio,
      required void Function(List<String>) changeTopics,
      required void Function(ClubVisibility)? changeVisibility,
      required void Function(String) changeImage,
      required void Function(int) changeMaxDaily,
      required void Function(bool) changeMemberPost,
      required void Function(bool) changeQuickJoin,
      required void Function(bool) changeDisableClub,
      required void Function() notifyUs}) async {
    final lang = General.language(context);
    final filter = ProfanityFilter();
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

    Future<void> addTopicHandler(String topicName) {
      var _batch = firestore.batch();
      final thisTopic = firestore.collection('Topics').doc(topicName);
      final thisTopicProfile = thisTopic.collection('clubs').doc(myUsername);
      _batch.set(thisTopic, {'clubs': FieldValue.increment(1)},
          SetOptions(merge: true));
      _batch.set(
          thisTopicProfile,
          {'times': FieldValue.increment(1), 'date': DateTime.now()},
          SetOptions(merge: true));
      return _batch.commit();
    }

    Future<void> removeTopicHandler(String topicName) {
      var _batch = firestore.batch();
      final thisTopic = firestore.collection('Topics').doc(topicName);
      final thisTopicProfile =
          thisTopic.collection('clubs removed').doc(myUsername);
      _batch.set(
          thisTopic,
          {
            'clubs': FieldValue.increment(-1),
            'clubs removed': FieldValue.increment(1)
          },
          SetOptions(merge: true));
      _batch.set(
          thisTopicProfile,
          {'times': FieldValue.increment(1), 'date': DateTime.now()},
          SetOptions(merge: true));
      return _batch.commit();
    }

    final users = firestore.collection('Clubs');
    if (changedImage) {
      if (myImgUrl != 'none') {
        // if (profileImageUrl != 'none') {
        //   FirebaseStorage.instance.refFromURL(profileImageUrl).delete();
        // }
        File? imageFile = await assets[0].originFile;
        final String filePath = imageFile!.absolute.path;
        final int fileSize = imageFile.lengthSync();
        if (fileSize > 30000000) {
          setState(() {
            isLoading = false;
          });
          _showDialog(Icons.info_outline, Colors.blue, lang.clubs_manage8,
              lang.clubs_manage9);
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
          await FlutterNsfw.initNsfw(file.path,
              enableLog: false, isOpenGPU: false, numThreads: 4);
          await FlutterNsfw.getPhotoNSFWScore(filePath).then((result) async {
            if (result > 0.759) {
              setState(() {
                isLoading = false;
              });
              EasyLoading.dismiss();
              _showDialog(Icons.info_outline, Colors.blue, lang.clubs_manage10,
                  lang.clubs_manage11);
            } else {
              if (addedTopicNames.isNotEmpty)
                for (var topicName in addedTopicNames)
                  await addTopicHandler(topicName);
              if (removedTopicNames.isNotEmpty)
                for (var topicName in removedTopicNames)
                  await removeTopicHandler(topicName);
              await storage
                  .ref(myImgUrl)
                  .putFile(imageFile)
                  .then((value) async {
                final _rightNow = DateTime.now();
                final modifID = _rightNow.toString();
                final controlDoc =
                    firestore.collection('Control').doc('Details');
                final thisDisabledClub =
                    firestore.collection('Disabled Clubs').doc(myUsername);
                var batch = firestore.batch();
                if (widget.isDisabled && !disableClub) {
                  batch.update(
                      controlDoc, {'disabled clubs': FieldValue.increment(-1)});
                  batch.delete(thisDisabledClub);
                } else if (!widget.isDisabled && disableClub) {
                  batch.update(
                      controlDoc, {'disabled clubs': FieldValue.increment(1)});
                  batch.set(thisDisabledClub, {'date': _rightNow});
                }
                Map<String, dynamic> fields = {
                  'modifications clubs': FieldValue.increment(1)
                };
                Map<String, dynamic> docFields = {
                  'id': modifID,
                  'date': _rightNow,
                  'clubName': myUsername
                };
                General.updateControl(
                    fields: fields,
                    myUsername: thisAdmin,
                    collectionName: 'modifications clubs',
                    docID: modifID,
                    docFields: docFields);
                if (filter.hasProfanity(_bioController.value.text)) {
                  batch.update(firestore.doc('Profanity/Clubs'),
                      {'numOfProfanity': FieldValue.increment(1)});
                  batch.set(
                      firestore.collection('Profanity/Clubs/Clubs').doc(), {
                    'club': myUsername,
                    'date': _rightNow,
                    'new about': _bioController.value.text,
                    'old about': xAbout
                  });
                }
                final String downloadUrl =
                    await storage.ref(myImgUrl).getDownloadURL();
                batch.set(
                    users
                        .doc(myUsername)
                        .collection('Modifications')
                        .doc(modifID),
                    {
                      'xAvatar': xAvatar,
                      'xBanner': xBanner,
                      'xBannerNSFW': xBannerNSFW,
                      'xVisibility': xVisibility,
                      'xAbout': xAbout,
                      'xTopics': xtopics,
                      'xMembersCanPost': xMembersCanPost,
                      'xMaxDailyPosts': xMaxDailyPosts,
                      'xAllowQuickJoin': xAllowQuickJoin,
                      'xIsDisabled': xIsDisabled,
                      'Avatar': downloadUrl,
                      'Banner': xBanner,
                      'bannerNSFW': xBannerNSFW,
                      'Visibility': '${General.generateClubVis(_newVis)}',
                      'about': '${_bioController.value.text}',
                      'topics': _newTopicNames,
                      'membersCanPost': membersCanPost,
                      'maxDailyPosts':
                          int.parse(_maxDailyPostsController.value.text),
                      'allowQuickJoin': allowQuickJoin,
                      'isDisabled': disableClub,
                      'modifier': thisAdmin,
                      'date': _rightNow,
                    },
                    SetOptions(merge: true));
                batch.set(
                    users.doc(myUsername),
                    {
                      'Avatar': downloadUrl,
                      'Visibility': '${General.generateClubVis(_newVis)}',
                      'about': '${_bioController.value.text}',
                      'topics': _newTopicNames,
                      'membersCanPost': membersCanPost,
                      'maxDailyPosts':
                          int.parse(_maxDailyPostsController.value.text),
                      'allowQuickJoin': allowQuickJoin,
                      'isDisabled': disableClub,
                      'last modified': _rightNow,
                      'last modifier': thisAdmin,
                      'modifications': FieldValue.increment(1),
                    },
                    SetOptions(merge: true));
                await batch.commit().then((value) async {
                  EasyLoading.showSuccess(lang.clubs_manage12,
                      duration: const Duration(seconds: 1), dismissOnTap: true);
                  changeBio(_bioController.value.text);
                  changeTopics(_newTopicNames);
                  changeVisibility!(_newVis);
                  changeImage(downloadUrl);
                  changeMaxDaily(
                      int.parse(_maxDailyPostsController.value.text));
                  changeMemberPost(membersCanPost);
                  changeQuickJoin(allowQuickJoin);
                  changeDisableClub(disableClub);
                  notifyUs();
                  if (addedTopicNames.isNotEmpty) addedTopicNames.clear();
                  if (removedTopicNames.isNotEmpty) removedTopicNames.clear();
                  setState(() {
                    isLoading = false;
                    somethingChanged = false;
                    changedImage = false;
                  });
                }).catchError((_) {
                  EasyLoading.showError(lang.clubs_manage13,
                      duration: const Duration(seconds: 2), dismissOnTap: true);
                  setState(() {
                    isLoading = false;
                  });
                });
              }).catchError((_) {
                EasyLoading.showError(lang.clubs_manage14,
                    duration: const Duration(seconds: 2), dismissOnTap: true);
                setState(() {
                  isLoading = false;
                });
              });
            }
          });
        }
      } else if (myImgUrl == 'none') {
        // if (profileImageUrl != 'none') {
        //   FirebaseStorage.instance.refFromURL(profileImageUrl).delete();
        // }
        if (addedTopicNames.isNotEmpty)
          for (var topicName in addedTopicNames)
            await addTopicHandler(topicName);
        if (removedTopicNames.isNotEmpty)
          for (var topicName in removedTopicNames)
            await removeTopicHandler(topicName);
        final _rightNow = DateTime.now();
        final modifID = _rightNow.toString();
        final controlDoc = firestore.collection('Control').doc('Details');
        final thisDisabledClub =
            firestore.collection('Disabled Clubs').doc(myUsername);
        var batch = firestore.batch();
        if (widget.isDisabled && !disableClub) {
          batch
              .update(controlDoc, {'disabled clubs': FieldValue.increment(-1)});
          batch.delete(thisDisabledClub);
        } else if (!widget.isDisabled && disableClub) {
          batch.update(controlDoc, {'disabled clubs': FieldValue.increment(1)});
          batch.set(thisDisabledClub, {'date': _rightNow});
        }
        Map<String, dynamic> fields = {
          'modifications clubs': FieldValue.increment(1)
        };
        Map<String, dynamic> docFields = {
          'id': modifID,
          'date': _rightNow,
          'clubName': myUsername
        };
        General.updateControl(
            fields: fields,
            myUsername: thisAdmin,
            collectionName: 'modifications clubs',
            docID: modifID,
            docFields: docFields);
        if (filter.hasProfanity(_bioController.value.text)) {
          batch.update(firestore.doc('Profanity/Clubs'),
              {'numOfProfanity': FieldValue.increment(1)});
          batch.set(firestore.collection('Profanity/Clubs/Clubs').doc(), {
            'club': myUsername,
            'date': _rightNow,
            'new about': _bioController.value.text,
            'old about': xAbout
          });
        }
        batch.set(
            users.doc(myUsername).collection('Modifications').doc(modifID),
            {
              'xAvatar': xAvatar,
              'xBanner': xBanner,
              'xBannerNSFW': xBannerNSFW,
              'xVisibility': xVisibility,
              'xAbout': xAbout,
              'xTopics': xtopics,
              'xMembersCanPost': xMembersCanPost,
              'xMaxDailyPosts': xMaxDailyPosts,
              'xAllowQuickJoin': xAllowQuickJoin,
              'xIsDisabled': xIsDisabled,
              'Avatar': 'none',
              'Banner': xBanner,
              'bannerNSFW': xBannerNSFW,
              'Visibility': '${General.generateClubVis(_newVis)}',
              'about': '${_bioController.value.text}',
              'topics': _newTopicNames,
              'membersCanPost': membersCanPost,
              'maxDailyPosts': int.parse(_maxDailyPostsController.value.text),
              'allowQuickJoin': allowQuickJoin,
              'isDisabled': disableClub,
              'modifier': thisAdmin,
              'date': _rightNow,
            },
            SetOptions(merge: true));
        batch.set(
            users.doc(myUsername),
            {
              'Avatar': 'none',
              'Visibility': '${General.generateClubVis(_newVis)}',
              'about': '${_bioController.value.text}',
              'topics': _newTopicNames,
              'membersCanPost': membersCanPost,
              'maxDailyPosts': int.parse(_maxDailyPostsController.value.text),
              'allowQuickJoin': allowQuickJoin,
              'isDisabled': disableClub,
              'last modified': _rightNow,
              'last modifier': thisAdmin,
              'modifications': FieldValue.increment(1),
            },
            SetOptions(merge: true));
        await batch.commit().then((value) async {
          EasyLoading.showSuccess(lang.clubs_manage15,
              duration: const Duration(seconds: 1), dismissOnTap: true);
          changeBio(_bioController.value.text);
          changeTopics(_newTopicNames);
          changeVisibility!(_newVis);
          changeImage('none');
          changeMaxDaily(int.parse(_maxDailyPostsController.value.text));
          changeMemberPost(membersCanPost);
          changeQuickJoin(allowQuickJoin);
          changeDisableClub(disableClub);
          notifyUs();
          if (addedTopicNames.isNotEmpty) addedTopicNames.clear();
          if (removedTopicNames.isNotEmpty) removedTopicNames.clear();
          setState(() {
            isLoading = false;
            somethingChanged = false;
            changedImage = false;
          });
        }).catchError((_) {
          EasyLoading.showError(lang.clubs_manage16,
              duration: const Duration(seconds: 2), dismissOnTap: true);
          setState(() {
            isLoading = false;
          });
        });
      }
    } else {
      if (addedTopicNames.isNotEmpty)
        for (var topicName in addedTopicNames) await addTopicHandler(topicName);
      if (removedTopicNames.isNotEmpty)
        for (var topicName in removedTopicNames)
          await removeTopicHandler(topicName);
      final _rightNow = DateTime.now();
      final modifID = _rightNow.toString();
      final controlDoc = firestore.collection('Control').doc('Details');
      final thisDisabledClub =
          firestore.collection('Disabled Clubs').doc(myUsername);
      var batch = firestore.batch();
      if (widget.isDisabled && !disableClub) {
        batch.update(controlDoc, {'disabled clubs': FieldValue.increment(-1)});
        batch.delete(thisDisabledClub);
      } else if (!widget.isDisabled && disableClub) {
        batch.update(controlDoc, {'disabled clubs': FieldValue.increment(1)});
        batch.set(thisDisabledClub, {'date': _rightNow});
      }
      Map<String, dynamic> fields = {
        'modifications clubs': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'id': modifID,
        'date': _rightNow,
        'clubName': myUsername
      };
      General.updateControl(
          fields: fields,
          myUsername: thisAdmin,
          collectionName: 'modifications clubs',
          docID: modifID,
          docFields: docFields);
      if (filter.hasProfanity(_bioController.value.text)) {
        batch.update(firestore.doc('Profanity/Clubs'),
            {'numOfProfanity': FieldValue.increment(1)});
        batch.set(firestore.collection('Profanity/Clubs/Clubs').doc(), {
          'club': myUsername,
          'date': _rightNow,
          'new about': _bioController.value.text,
          'old about': xAbout
        });
      }
      batch.set(
          users.doc(myUsername).collection('Modifications').doc(modifID),
          {
            'xAvatar': xAvatar,
            'xBanner': xBanner,
            'xBannerNSFW': xBannerNSFW,
            'xVisibility': xVisibility,
            'xAbout': xAbout,
            'xTopics': xtopics,
            'xMembersCanPost': xMembersCanPost,
            'xMaxDailyPosts': xMaxDailyPosts,
            'xAllowQuickJoin': xAllowQuickJoin,
            'xIsDisabled': xIsDisabled,
            'Avatar': xAvatar,
            'Banner': xBanner,
            'bannerNSFW': xBannerNSFW,
            'Visibility': '${General.generateClubVis(_newVis)}',
            'about': '${_bioController.value.text}',
            'topics': _newTopicNames,
            'membersCanPost': membersCanPost,
            'maxDailyPosts': int.parse(_maxDailyPostsController.value.text),
            'allowQuickJoin': allowQuickJoin,
            'isDisabled': disableClub,
            'modifier': thisAdmin,
            'date': _rightNow,
          },
          SetOptions(merge: true));
      batch.set(
          users.doc(myUsername),
          {
            'Visibility': '${General.generateClubVis(_newVis)}',
            'about': '${_bioController.value.text}',
            'topics': _newTopicNames,
            'membersCanPost': membersCanPost,
            'maxDailyPosts': int.parse(_maxDailyPostsController.value.text),
            'allowQuickJoin': allowQuickJoin,
            'isDisabled': disableClub,
            'last modified': _rightNow,
            'last modifier': thisAdmin,
            'modifications': FieldValue.increment(1),
          },
          SetOptions(merge: true));
      await batch.commit().then((value) async {
        EasyLoading.showSuccess(lang.clubs_manage17,
            duration: const Duration(seconds: 1), dismissOnTap: true);
        changeBio(_bioController.value.text);
        changeTopics(_newTopicNames);
        changeVisibility!(_newVis);
        changeMaxDaily(int.parse(_maxDailyPostsController.value.text));
        changeMemberPost(membersCanPost);
        changeQuickJoin(allowQuickJoin);
        changeDisableClub(disableClub);
        notifyUs();
        if (addedTopicNames.isNotEmpty) addedTopicNames.clear();
        if (removedTopicNames.isNotEmpty) removedTopicNames.clear();
        setState(() {
          isLoading = false;
          somethingChanged = false;
        });
      }).catchError((_) {
        EasyLoading.showError(lang.clubs_manage18,
            duration: const Duration(seconds: 2), dismissOnTap: true);
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Widget buildMyDialog(Color _primaryColor) {
    final lang = General.language(context);
    return Center(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0), color: Colors.white),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (!kIsWeb)
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _choose(widget.clubName, _primaryColor, lang);
                        },
                        style: const ButtonStyle(
                            splashFactory: NoSplash.splashFactory),
                        child: Text(lang.clubs_manage19,
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontFamily: 'Roboto',
                                fontSize: 21.0,
                                color: Colors.black))),
                  if (myImgUrl != 'none')
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          myImgUrl = 'none';
                          somethingChanged = true;
                          changedImage = true;
                          assets.clear();
                          setState(() {});
                        },
                        style: const ButtonStyle(
                            splashFactory: NoSplash.splashFactory),
                        child: Text(lang.clubs_manage20,
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontFamily: 'Roboto',
                                fontSize: 21.0,
                                color: Colors.black)))
                ])));
  }

  Widget buildAvatar(String _clubName, Color _primaryColor) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        TextButton(
            style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
            onPressed: () => showDialog(
                context: context,
                builder: (ctx) => buildMyDialog(_primaryColor)),
            child: ClubAvatar(
              clubName: _clubName,
              radius: 75,
              inEdit: true,
              asset:
                  (myImgUrl != 'none' && assets.isNotEmpty) ? assets[0] : null,
              editUrl: myImgUrl,
              fontSize: 80,
            ))
      ]);
  DropdownMenuItem<ClubVisibility> buildDropItem(
          dynamic _changeLocalVis,
          Color _primaryColor,
          String label,
          ClubVisibility value,
          IconData icon) =>
      DropdownMenuItem<ClubVisibility>(
          value: value,
          onTap: () => _changeLocalVis(value),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: _primaryColor, size: 25.0),
                const SizedBox(width: 15.0),
                Text(label,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0))
              ]));
  Widget buildDropButton(dynamic _changeLocalVis, Color _primaryColor) {
    final lang = General.language(context);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: DropdownButton(
            borderRadius: BorderRadius.circular(15.0),
            onChanged: (_) => setState(() {}),
            underline: Container(color: Colors.transparent),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            value: _newVis,
            items: [
              buildDropItem(_changeLocalVis, _primaryColor, lang.clubs_manage21,
                  ClubVisibility.public, customIcons.MyFlutterApp.globe_no_map),
              buildDropItem(_changeLocalVis, _primaryColor, lang.clubs_manage22,
                  ClubVisibility.private, Icons.lock_outline),
              buildDropItem(_changeLocalVis, _primaryColor, lang.clubs_manage23,
                  ClubVisibility.hidden, customIcons.MyFlutterApp.hidden)
            ]));
  }

  Widget buildSwitch(Color _primaryColor, bool value, String label,
          void Function(bool)? onChanged) =>
      SwitchListTile(
          activeColor: _primaryColor,
          value: value,
          title: Text(label, style: const TextStyle(color: Colors.black)),
          onChanged: onChanged);
  Widget buildBannedTile(Object? _clubName) {
    final lang = General.language(context);
    return ListTile(
        onTap: () {
          final BannedMemberScreenArgs args = BannedMemberScreenArgs(_clubName);
          Navigator.pushNamed(context, RouteGenerator.bannedMemberScreen,
              arguments: args);
        },
        horizontalTitleGap: 5.0,
        leading: const Icon(Icons.person_off, color: Colors.black),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(lang.clubs_manage24,
                  style: const TextStyle(color: Colors.black))
            ]));
  }

  Widget buildAdminTile(Object? isFounder, Object? _clubName) {
    final lang = General.language(context);
    return ListTile(
        onTap: () {
          final AdminScreenArgs args =
              AdminScreenArgs(isFounder: isFounder, clubName: _clubName);
          Navigator.pushNamed(context, RouteGenerator.clubAdminScreen,
              arguments: args);
        },
        horizontalTitleGap: 5.0,
        leading: const Icon(Icons.people, color: Colors.black),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(lang.clubs_manage25,
                  style: const TextStyle(color: Colors.black))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    const SizedBox _heightBox = SizedBox(height: 15.0);
    String? _validateBio(String? value) {
      if (value!.length > 2000) {
        return lang.clubs_manage1;
      } else {
        return null;
      }
    }

    String? maxDailyValidator(String? value) {
      final RegExp _expression = RegExp(r'^[0-9]');
      if (value!.isEmpty ||
          value.replaceAll(' ', '') == '' ||
          value.trim() == '') return lang.clubs_manage2;
      if (!_expression.hasMatch(value)) return lang.clubs_manage3;
      if (_expression.hasMatch(value) &&
          (int.tryParse(value)! < 1 || int.tryParse(value)! > 50))
        return lang.clubs_manage4;
      if (_expression.hasMatch(value) &&
          int.tryParse(value)! >= 1 &&
          int.tryParse(value)! <= 50) return null;
      return null;
    }

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: ChangeNotifierProvider<ClubProvider>.value(
                    value: widget.instance,
                    child: Builder(builder: (context) {
                      return Consumer<ClubProvider>(builder: (ctx, myClub, _) {
                        final helper = Provider.of<ClubProvider>(context);
                        final xAvatar = helper.clubAvatar;
                        final xBanner = helper.clubBannerUrl;
                        final xBannerNSFW = helper.bannerNSFW;
                        final xAbout = helper.clubDescription;
                        final xAllowQuickJoin = helper.allowQuickJoin;
                        final xIsDisabled = helper.isDisabled;
                        final xMaxDailyPosts = helper.maxDailyPostsByMembers;
                        final xMembersCanPost = helper.memberCanPost;
                        final xVisibility =
                            General.generateClubVis(helper.clubVisibility);
                        final xtopics = helper.clubTopics;
                        final bool isFounder = myClub.isFounder;
                        final String _clubName = myClub.clubName;
                        final String profileImgUrl = myClub.clubAvatar;
                        final void Function(ClubVisibility)? changeVisibility =
                            myClub.changeVisibility;
                        void _changeLocalVis(ClubVisibility vis) {
                          setState(() {
                            _newVis = vis;
                            somethingChanged = true;
                          });
                          _changeVis(vis, _primaryColor);
                        }

                        void addTopic(String newTopic) {
                          setState(() {
                            _newTopicNames.insert(0, newTopic);
                            addedTopicNames.add(newTopic);
                            if (removedTopicNames.contains(newTopic))
                              removedTopicNames.remove(newTopic);
                            somethingChanged = true;
                          });
                        }

                        void _removeTopic(int idx) {
                          setState(() {
                            final thisTopic = _newTopicNames[idx];
                            _newTopicNames.removeAt(idx);
                            if (addedTopicNames.contains(thisTopic)) {
                              addedTopicNames.remove(thisTopic);
                            } else {
                              if (!removedTopicNames.contains(thisTopic))
                                removedTopicNames.add(thisTopic);
                            }
                            somethingChanged = true;
                          });
                        }

                        void changeTopics(List<String> newNames) =>
                            myClub.changeTopics(newNames);

                        void changeBio(String newBio) =>
                            myClub.changeBio(newBio);

                        void changeImage(String newUrl) =>
                            myClub.changeClubAvatar(newUrl);

                        void changeMaxDailyPosts(int newMax) =>
                            myClub.changeMaxDailyPosts(newMax);

                        void _changeAllowUserPosts(bool newRule) =>
                            myClub.changeAllowUserPosts(newRule);

                        void changeQuickJoin(bool newRule) =>
                            myClub.changeAllowQuickJoin(newRule);

                        void changeDisableClub(bool newRule) =>
                            myClub.changeDisableClub(newRule);

                        return Form(
                            key: _formKey,
                            child: SizedBox(
                                height: _deviceHeight,
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      SettingsBar(lang.clubs_manage26),
                                      Expanded(
                                          child: Noglow(
                                              child: SingleChildScrollView(
                                                  keyboardDismissBehavior:
                                                      ScrollViewKeyboardDismissBehavior
                                                          .onDrag,
                                                  controller: scrollController,
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        _heightBox,
                                                        const ClubBanner(true),
                                                        _heightBox,
                                                        buildDropButton(
                                                            _changeLocalVis,
                                                            _primaryColor),
                                                        _heightBox,
                                                        buildAvatar(_clubName,
                                                            _primaryColor),
                                                        _heightBox,
                                                        EditClubTextField(
                                                            scrollController,
                                                            _validateBio,
                                                            _bioController),
                                                        _heightBox,
                                                        EditClubMaxPostField(
                                                            _maxDailyPostsController,
                                                            maxDailyValidator),
                                                        _heightBox,
                                                        _heightBox,
                                                        EditClubTopics(
                                                            scrollController,
                                                            addTopic,
                                                            _newTopicNames,
                                                            _removeTopic),
                                                        buildSwitch(
                                                            _primaryColor,
                                                            membersCanPost,
                                                            lang.clubs_manage27,
                                                            (value) {
                                                          membersCanPost =
                                                              value;
                                                          somethingChanged =
                                                              true;
                                                          setState(() {});
                                                        }),
                                                        buildSwitch(
                                                            _primaryColor,
                                                            allowQuickJoin,
                                                            lang.clubs_manage28,
                                                            (value) {
                                                          allowQuickJoin =
                                                              value;
                                                          somethingChanged =
                                                              true;
                                                          setState(() {});
                                                        }),
                                                        if (isFounder)
                                                          buildSwitch(
                                                              _primaryColor,
                                                              disableClub,
                                                              lang.clubs_manage29,
                                                              (value) {
                                                            disableClub = value;
                                                            somethingChanged =
                                                                true;
                                                            setState(() {});
                                                          }),
                                                        const Divider(),
                                                        buildBannedTile(
                                                            _clubName),
                                                        buildAdminTile(
                                                            isFounder,
                                                            _clubName)
                                                      ])))),
                                      Opacity(
                                          opacity:
                                              (somethingChanged) ? 1.0 : .65,
                                          child: TextButton(
                                              style: ButtonStyle(
                                                  enableFeedback: false,
                                                  elevation: MaterialStateProperty
                                                      .all<double?>(0.0),
                                                  shape: MaterialStateProperty.all<
                                                          OutlinedBorder?>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight:
                                                                      const Radius.circular(
                                                                          15.0),
                                                                  topLeft:
                                                                      const Radius.circular(15.0)))),
                                                  backgroundColor: MaterialStateProperty.all<Color?>(_primaryColor)),
                                              onPressed: () {
                                                bool _isValid = _formKey
                                                    .currentState!
                                                    .validate();
                                                if (_isValid &&
                                                    somethingChanged) {
                                                  if (isLoading) {
                                                  } else {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    updateUser(
                                                      xAbout: xAbout,
                                                      xAllowQuickJoin:
                                                          xAllowQuickJoin,
                                                      xAvatar: xAvatar,
                                                      xBanner: xBanner,
                                                      xBannerNSFW: xBannerNSFW,
                                                      xIsDisabled: xIsDisabled,
                                                      xMaxDailyPosts:
                                                          xMaxDailyPosts,
                                                      xMembersCanPost:
                                                          xMembersCanPost,
                                                      xVisibility: xVisibility,
                                                      xtopics: xtopics,
                                                      thisAdmin: _myUsername,
                                                      myUsername: _clubName,
                                                      profileImageUrl:
                                                          profileImgUrl,
                                                      changeBio: changeBio,
                                                      changeTopics:
                                                          changeTopics,
                                                      changeVisibility:
                                                          changeVisibility!,
                                                      changeImage: changeImage,
                                                      changeMaxDaily:
                                                          changeMaxDailyPosts,
                                                      changeMemberPost:
                                                          _changeAllowUserPosts,
                                                      changeQuickJoin:
                                                          changeQuickJoin,
                                                      changeDisableClub:
                                                          changeDisableClub,
                                                      notifyUs:
                                                          myClub.notifyThem,
                                                    );
                                                  }
                                                } else {}
                                              },
                                              child: (isLoading) ? CircularProgressIndicator(color: _accentColor, strokeWidth: 1.50) : Text(lang.clubs_manage30, style: TextStyle(fontSize: 35.0, color: _accentColor))))
                                    ])));
                      });
                    })))));
  }
}

class EditClubTextField extends StatelessWidget {
  final dynamic scrollController;
  final dynamic _validateBio;
  final dynamic _bioController;
  const EditClubTextField(
      this.scrollController, this._validateBio, this._bioController);

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final lang = General.language(context);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: NestedScroller(
            controller: scrollController,
            child: TextFormField(
                controller: _bioController,
                validator: _validateBio,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    labelText: lang.clubs_manage31,
                    counterText: '',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: _primaryColor))),
                minLines: 5,
                maxLines: 20,
                maxLength: 2000)));
  }
}

class EditClubMaxPostField extends StatelessWidget {
  final dynamic _maxDailyPostsController;
  final dynamic maxDailyValidator;
  const EditClubMaxPostField(
      this._maxDailyPostsController, this.maxDailyValidator);

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final lang = General.language(context);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
            controller: _maxDailyPostsController,
            validator: maxDailyValidator,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                labelText: lang.clubs_manage32,
                counterText: '',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: _primaryColor))),
            minLines: 1,
            maxLines: 1,
            maxLength: 2));
  }
}

class EditClubTopics extends StatelessWidget {
  final dynamic scrollController;
  final dynamic addTopic;
  final dynamic _newTopicNames;
  final dynamic _removeTopic;
  const EditClubTopics(this.scrollController, this.addTopic,
      this._newTopicNames, this._removeTopic);

  @override
  Widget build(BuildContext context) {
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double _deviceWidth = General.widthQuery(context);
    final lang = General.language(context);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: 75.0,
                maxHeight: 500.0,
                minWidth: _deviceWidth,
                maxWidth: _deviceWidth),
            child: NestedScroller(
                controller: scrollController,
                child: SingleChildScrollView(
                    child: Wrap(children: <Widget>[
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: GestureDetector(
                          onTap: () => showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(31.0)),
                              backgroundColor: Colors.white,
                              builder: (_) => AddTopic(addTopic, _newTopicNames,
                                  false, false, false)),
                          child: TopicChip(
                              lang.clubs_manage33,
                              Icon(Icons.add, color: _accentColor),
                              () => showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(31.0)),
                                  backgroundColor: Colors.white,
                                  builder: (_) => AddTopic(addTopic,
                                      _newTopicNames, false, false, false)),
                              _accentColor,
                              FontWeight.bold))),
                  ..._newTopicNames.map((topic) {
                    int idx = _newTopicNames.indexOf(topic);
                    void removeTopic() => _removeTopic(idx);
                    return TopicChip(
                        topic,
                        const Icon(Icons.close, color: Colors.red),
                        removeTopic,
                        Colors.white,
                        FontWeight.normal);
                  }).toList()
                ])))));
  }
}
