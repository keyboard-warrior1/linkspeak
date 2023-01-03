import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:path_provider/path_provider.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../general.dart';
import '../models/miniProfile.dart';
import '../models/profile.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/chatProfileImage.dart';
import '../widgets/common/nestedScroller.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/profile/deleteProfileButton.dart';
import '../widgets/profile/myProfileBanner.dart';
import '../widgets/snackbar/visSnack.dart';
import '../widgets/topics/addTopic.dart';
import '../widgets/topics/topicChip.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen();

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isLoading = false;
  bool changedImage = false;
  bool somethingChanged = false;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  List<String> mentions = [];
  late FirebaseAuth? auth;
  late final ScrollController scrollController;
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _bioController;
  List<String> _newTopicNames = [];
  List<String> removedTopicNames = [];
  List<String> addedTopicNames = [];
  late TheVisibility _newVis;
  late String myImgUrl;

  String _blockedNumber(num value) {
    final lang = General.language(context);
    if (value >= 99) {
      return lang.screens_editProfile2;
    } else {
      return value.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _formKey = GlobalKey<FormState>();
    final RegExp _exp = RegExp(r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
        multiLine: true, caseSensitive: false, dotAll: true);
    const prefix = '@';
    final MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    final String _myBio = _myProfile.getBio;
    _bioController = TextEditingController(text: _myBio);
    List<String> _myTopicNames = _myProfile.getTopics;
    _newVis = _myProfile.getVisibility;
    _newTopicNames = [..._myTopicNames];
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
      final text = _bioController.text;
      final result = text.split(' ');
      final last =
          result.where((element) => element.startsWith(prefix)).toList();
      final removAt = last.map((e) => e.replaceFirst('@', '')).toList();
      removAt.forEach((e) {
        if (!mentions.contains(e) && _exp.hasMatch(e) && e.length >= 2)
          mentions.add(e);
      });
      mentions.forEach((element) {
        if (!removAt.contains(element)) {
          mentions.remove(element);
        }
      });
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
    final lang = General.language(context);
    switch (myVis) {
      case TheVisibility.private:
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: primarySwatch,
            content:
                VisSnack(Icons.lock_outline, lang.screens_editProfile3, false),
            duration: const Duration(seconds: 3)));
        break;
      case TheVisibility.public:
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: primarySwatch,
            content: VisSnack(customIcons.MyFlutterApp.globe_no_map,
                lang.screens_editProfile4, false),
            duration: const Duration(seconds: 3)));
        break;
    }
  }

  List<AssetEntity> assets = [];
  Future<void> _choose(
      String myUsername, Color primaryColor, dynamic lang) async {
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
      myImgUrl = 'Avatars/$myUsername/$name';
      somethingChanged = true;
      changedImage = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> updateUser(
      {required String myUsername,
      required String profileImageUrl,
      required void Function(String) changeBio,
      required void Function(List<String>) changeTopics,
      required void Function(TheVisibility)? changeVisibility,
      required void Function(String) changeImage,
      required List<String> finalMentions,
      required String xBanner,
      required bool xBannerNSFW,
      required String xAvatar,
      required String xVisibility,
      required String xBio,
      required xTopics}) async {
    final lang = General.language(context);
    final filter = ProfanityFilter();
    var batch = firestore.batch();
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
    Future<void> mentionHandler(String mentionedUser) async {
      final rightNow = DateTime.now();
      if (mentionedUser != myUsername) {
        final targetUser = await users.doc(mentionedUser).get();
        String targetLang = 'en';
        if (targetUser.data()!.containsKey('language')) {
          targetLang = targetUser.get('language');
        }
        final String friendMessage = General.giveMentionBio(targetLang);
        final userExists = targetUser.exists;
        if (userExists) {
          final notifDescription = '$myUsername $friendMessage';
          final token = targetUser.get('fcm');
          final theirBlockDoc = await users
              .doc(mentionedUser)
              .collection('Blocked')
              .doc(myUsername)
              .get();
          final myBlockDoc = await users
              .doc(myUsername)
              .collection('Blocked')
              .doc(mentionedUser)
              .get();
          final bool imBlocked = theirBlockDoc.exists;
          final bool theyreBlocked = myBlockDoc.exists;
          final myMentions = users.doc(myUsername).collection('My mentions');
          final mentionBox = users.doc(mentionedUser).collection('Mention Box');
          final theirMentionedIn =
              users.doc(mentionedUser).collection('Mentioned In');
          final data = {
            'mentioned user': mentionedUser,
            'mentioned by': myUsername,
            'date': rightNow,
            'postID': '',
            'commentID': '',
            'replyID': '',
            'collectionID': '',
            'flareID': '',
            'flareCommentID': '',
            'flareReplyID': '',
            'commenterName': '',
            'clubName': '',
            'posterName': '',
            'isClubPost': false,
            'isPost': false,
            'isComment': false,
            'isReply': false,
            'isBio': true,
            'isFlare': false,
            'isFlareComment': false,
            'isFlareReply': false,
            'isFlaresBio': false,
          };
          final alertData = {
            'mentioned user': mentionedUser,
            'mentioned by': myUsername,
            'token': token,
            'description': notifDescription,
            'date': rightNow,
            'postID': '',
            'commentID': '',
            'replyID': '',
            'collectionID': '',
            'flareID': '',
            'flareCommentID': '',
            'flareReplyID': '',
            'commenterName': '',
            'clubName': '',
            'posterName': '',
            'isClubPost': false,
            'isPost': false,
            'isComment': false,
            'isReply': false,
            'isBio': true,
            'isFlare': false,
            'isFlareComment': false,
            'isFlareReply': false,
            'isFlaresBio': false,
          };
          batch.set(myMentions.doc(), data);
          batch.set(theirMentionedIn.doc(), data);
          final status = targetUser.get('Status');
          if (!imBlocked && !theyreBlocked && status != 'Banned') {
            if (targetUser.data()!.containsKey('AllowMentions')) {
              final allowMentions = targetUser.get('AllowMentions');
              if (allowMentions) {
                batch.update(users.doc(mentionedUser),
                    {'numOfMentions': FieldValue.increment(1)});
                batch.set(mentionBox.doc(), alertData);
              }
            } else {
              batch.update(users.doc(mentionedUser),
                  {'numOfMentions': FieldValue.increment(1)});
              batch.set(mentionBox.doc(), alertData);
            }
          }
        }
      }
    }

    Future<void> mentionPeople(List<String> _mentions) async {
      if (_mentions.isNotEmpty)
        for (var tag in _mentions) {
          await mentionHandler(tag);
        }
    }

    Future<void> addTopicHandler(String topicName) {
      var _batch = firestore.batch();
      final thisTopic = firestore.collection('Topics').doc(topicName);
      final thisTopicProfile = thisTopic.collection('profiles').doc(myUsername);
      _batch.set(thisTopic, {'profiles': FieldValue.increment(1)},
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
          thisTopic.collection('profiles removed').doc(myUsername);
      _batch.set(
          thisTopic,
          {
            'profiles': FieldValue.increment(-1),
            'profiles removed': FieldValue.increment(1)
          },
          SetOptions(merge: true));
      _batch.set(
          thisTopicProfile,
          {'times': FieldValue.increment(1), 'date': DateTime.now()},
          SetOptions(merge: true));
      return _batch.commit();
    }

    final _now = DateTime.now();
    final modificationID = _now.toString();
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
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            lang.screens_editProfile5,
            lang.screens_editProfile6,
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
              EasyLoading.dismiss();
              _showDialog(Icons.info_outline, Colors.blue,
                  lang.screens_editProfile5, lang.screens_editProfile7);
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
                final String downloadUrl =
                    await storage.ref(myImgUrl).getDownloadURL();
                await users.doc(myUsername).set({
                  'Avatar': downloadUrl,
                  'Visibility': '${General.generateProfileVis(_newVis)}',
                  'Bio': '${_bioController.value.text}',
                  'Topics': _newTopicNames,
                  'last modified': _now,
                  'modifications': FieldValue.increment(1)
                }, SetOptions(merge: true)).then((value) async {
                  Map<String, dynamic> fields = {
                    'modifications': FieldValue.increment(1)
                  };
                  Map<String, dynamic> docFields = {
                    'id': modificationID,
                    'date': _now
                  };
                  General.updateControl(
                      fields: fields,
                      myUsername: myUsername,
                      collectionName: 'modifications',
                      docID: modificationID,
                      docFields: docFields);
                  if (filter.hasProfanity(_bioController.value.text)) {
                    batch.update(firestore.doc('Profanity/Profiles'),
                        {'numOfProfanity': FieldValue.increment(1)});
                    batch.set(
                        firestore
                            .collection('Profanity/Profiles/Profiles')
                            .doc(),
                        {
                          'profile': myUsername,
                          'date': _now,
                          'new bio': _bioController.value.text,
                          'old bio': xBio
                        });
                  }
                  await users
                      .doc(myUsername)
                      .collection('Modifications')
                      .doc(modificationID)
                      .set({
                    'xBanner': xBanner,
                    'xBannerNSFW': xBannerNSFW,
                    'Banner': xBanner,
                    'bannerNSFW': xBannerNSFW,
                    'xAvatar': xAvatar,
                    'xVisibility': xVisibility,
                    'xBio': xBio,
                    'xTopics': xTopics,
                    'Avatar': downloadUrl,
                    'Visibility': '${General.generateProfileVis(_newVis)}',
                    'Bio': '${_bioController.value.text}',
                    'Topics': _newTopicNames,
                    'date': _now,
                  }, SetOptions(merge: true));
                  await mentionPeople(finalMentions);
                  batch.commit();
                  EasyLoading.showSuccess(lang.screens_editProfile8,
                      duration: const Duration(seconds: 1), dismissOnTap: true);
                  changeBio(_bioController.value.text);
                  changeTopics(_newTopicNames);
                  changeVisibility!(_newVis);
                  changeImage(downloadUrl);
                  if (addedTopicNames.isNotEmpty) addedTopicNames.clear();
                  if (removedTopicNames.isNotEmpty) removedTopicNames.clear();
                  setState(() {
                    isLoading = false;
                    somethingChanged = false;
                    changedImage = false;
                  });
                }).catchError((_) {
                  EasyLoading.showError(lang.screens_editProfile9,
                      duration: const Duration(seconds: 2), dismissOnTap: true);
                  setState(() {
                    isLoading = false;
                  });
                });
              }).catchError((_) {
                EasyLoading.showError(lang.screens_editProfile9,
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
        await users.doc(myUsername).set({
          'Avatar': 'none',
          'Visibility': '${General.generateProfileVis(_newVis)}',
          'Bio': '${_bioController.value.text}',
          'Topics': _newTopicNames,
          'last modified': _now,
          'modifications': FieldValue.increment(1)
        }, SetOptions(merge: true)).then((value) async {
          Map<String, dynamic> fields = {
            'modifications': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {'id': modificationID, 'date': _now};
          General.updateControl(
              fields: fields,
              myUsername: myUsername,
              collectionName: 'modifications',
              docID: modificationID,
              docFields: docFields);
          if (filter.hasProfanity(_bioController.value.text)) {
            batch.update(firestore.doc('Profanity/Profiles'),
                {'numOfProfanity': FieldValue.increment(1)});
            batch.set(
                firestore.collection('Profanity/Profiles/Profiles').doc(), {
              'profile': myUsername,
              'date': _now,
              'new bio': _bioController.value.text,
              'old bio': xBio
            });
          }
          await users
              .doc(myUsername)
              .collection('Modifications')
              .doc(modificationID)
              .set({
            'xBanner': xBanner,
            'xBannerNSFW': xBannerNSFW,
            'Banner': xBanner,
            'bannerNSFW': xBannerNSFW,
            'xAvatar': xAvatar,
            'xVisibility': xVisibility,
            'xBio': xBio,
            'xTopics': xTopics,
            'Avatar': 'none',
            'Visibility': '${General.generateProfileVis(_newVis)}',
            'Bio': '${_bioController.value.text}',
            'Topics': _newTopicNames,
            'date': _now,
          }, SetOptions(merge: true));
          await mentionPeople(finalMentions);
          batch.commit();
          EasyLoading.showSuccess(lang.screens_editProfile8,
              duration: const Duration(seconds: 1), dismissOnTap: true);
          changeBio(_bioController.value.text);
          changeTopics(_newTopicNames);
          changeVisibility!(_newVis);
          changeImage('none');
          if (addedTopicNames.isNotEmpty) addedTopicNames.clear();
          if (removedTopicNames.isNotEmpty) removedTopicNames.clear();
          setState(() {
            isLoading = false;
            somethingChanged = false;
            changedImage = false;
          });
        }).catchError((_) {
          EasyLoading.showError(lang.screens_editProfile9,
              duration: const Duration(seconds: 2), dismissOnTap: true);
          setState(() {
            isLoading = false;
          });
        });
      }
    } else {
      Map<String, dynamic> fields = {'modifications': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'id': modificationID, 'date': _now};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'modifications',
          docID: modificationID,
          docFields: docFields);
      if (addedTopicNames.isNotEmpty)
        for (var topicName in addedTopicNames) await addTopicHandler(topicName);
      if (removedTopicNames.isNotEmpty)
        for (var topicName in removedTopicNames)
          await removeTopicHandler(topicName);
      await users.doc(myUsername).set({
        'Visibility': '${General.generateProfileVis(_newVis)}',
        'Bio': '${_bioController.value.text}',
        'Topics': _newTopicNames,
        'last modified': _now,
        'modifications': FieldValue.increment(1)
      }, SetOptions(merge: true)).then((value) async {
        if (filter.hasProfanity(_bioController.value.text)) {
          batch.update(firestore.doc('Profanity/Profiles'),
              {'numOfProfanity': FieldValue.increment(1)});
          batch.set(firestore.collection('Profanity/Profiles/Profiles').doc(), {
            'profile': myUsername,
            'date': _now,
            'new bio': _bioController.value.text,
            'old bio': xBio
          });
        }
        await users
            .doc(myUsername)
            .collection('Modifications')
            .doc(modificationID)
            .set({
          'xBanner': xBanner,
          'xBannerNSFW': xBannerNSFW,
          'Banner': xBanner,
          'bannerNSFW': xBannerNSFW,
          'xAvatar': xAvatar,
          'xVisibility': xVisibility,
          'xBio': xBio,
          'xTopics': xTopics,
          'Avatar': xAvatar,
          'Visibility': '${General.generateProfileVis(_newVis)}',
          'Bio': '${_bioController.value.text}',
          'Topics': _newTopicNames,
          'date': _now,
        }, SetOptions(merge: true));
        await mentionPeople(finalMentions);
        batch.commit();
        EasyLoading.showSuccess(lang.screens_editProfile8,
            duration: const Duration(seconds: 1), dismissOnTap: true);
        if (addedTopicNames.isNotEmpty) addedTopicNames.clear();
        if (removedTopicNames.isNotEmpty) removedTopicNames.clear();
        changeBio(_bioController.value.text);
        changeTopics(_newTopicNames);
        changeVisibility!(_newVis);
        setState(() {
          isLoading = false;
          somethingChanged = false;
        });
      }).catchError((_) {
        EasyLoading.showError(lang.screens_editProfile9,
            duration: const Duration(seconds: 2), dismissOnTap: true);
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<List<MiniProfile>> getSuggestedTags(String newString) async {
    List<MiniProfile> userSearchResults = [];
    final getUsers = await firestore.collection('Users').get();
    final docs = getUsers.docs;
    final lowerCaseName = newString.toLowerCase();
    docs.forEach((doc) {
      if (userSearchResults.length < 25) {
        final String id = doc.id.toString().toLowerCase();
        final String username = doc.id;
        if (id.startsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username) &&
            !mentions.any((element) => element == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username) &&
            !mentions.any((element) => element == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username) &&
            !mentions.any((element) => element == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
      }
    });
    return userSearchResults;
  }

  Widget fieldBuilder(BuildContext _, MiniProfile mini) {
    final username = mini.username;
    return ListTile(
        onTap: () => selectionHandler(mini),
        key: ValueKey<String>(username),
        horizontalTitleGap: 5.0,
        leading: ChatProfileImage(
            username: username, factor: 0.04, inEdit: false, asset: null),
        title: Text(username,
            textAlign: TextAlign.start,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 14.0)));
  }

  FutureOr<Iterable<MiniProfile>> fieldHandler(String input) {
    final RegExp atRegexp = atSignRegExp;
    final isTagging = atRegexp.hasMatch(input);
    if (isTagging) {
      final RegExp _exp = RegExp(r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
          multiLine: true, caseSensitive: false, dotAll: true);
      final cursorLocation = _bioController.selection.base.offset;
      final beginningTillHere = input.substring(0, cursorLocation);
      final lastCharEmpty = beginningTillHere.endsWith(' ');
      if (lastCharEmpty) {
        return [];
      }
      final result = beginningTillHere.split(' ');
      final last = result.lastWhere((element) => element.startsWith('@'));
      final trimmed = last.trim();
      final newString = trimmed.replaceFirst('@', '');
      if (_exp.hasMatch(newString)) {
        return getSuggestedTags(newString);
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  void selectionHandler(MiniProfile mini) {
    const prefix = '@';
    final oldText = _bioController.text;
    final cursorLocation = _bioController.selection.base.offset;
    final beginningTillHere = oldText.substring(0, cursorLocation);
    final result = beginningTillHere.split(' ');
    final last = result.lastWhere((element) => element.startsWith(prefix));
    final newUsername = '@${mini.username}';
    final length = newUsername.length;
    final newText = oldText.replaceFirst(last, newUsername);
    mentions.add(mini.username);
    _bioController.value = _bioController.value.copyWith(text: newText);
    final theIndex = _bioController.text.indexOf(newUsername) + length;
    final newPosition = TextPosition(offset: theIndex);
    _bioController.selection = TextSelection.fromPosition(newPosition);
  }

  Widget buildMyDialog(String myUsername, Color _primaryColor) {
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
                          _choose(myUsername, _primaryColor, lang);
                        },
                        style: const ButtonStyle(
                            splashFactory: NoSplash.splashFactory),
                        child: Text(lang.screens_editProfile10,
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
                        child: Text(lang.screens_editProfile11,
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontFamily: 'Roboto',
                                fontSize: 21.0,
                                color: Colors.black)))
                ])));
  }

  DropdownMenuItem<TheVisibility> buildDropItem(
          dynamic _changeLocalVis,
          Color _primaryColor,
          String label,
          TheVisibility value,
          IconData icon) =>
      DropdownMenuItem<TheVisibility>(
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
              buildDropItem(
                  _changeLocalVis,
                  _primaryColor,
                  lang.screens_editProfile12,
                  TheVisibility.public,
                  customIcons.MyFlutterApp.globe_no_map),
              buildDropItem(
                  _changeLocalVis,
                  _primaryColor,
                  lang.screens_editProfile13,
                  TheVisibility.private,
                  Icons.lock_outline),
            ]));
  }

  Widget buildAdditionalInfoButton(Color _primaryColor) {
    final lang = General.language(context);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (!isLoading)
                  Navigator.pushNamed(
                      context, RouteGenerator.additionalInfoScreen);
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color?>(_primaryColor)),
              child: Center(
                  child: Text(lang.screens_editProfile14,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)))))
    ]);
  }

  Widget buildBlockedButton(int _numOfBlockedUsers) {
    final lang = General.language(context);
    return ListTile(
        onTap: () =>
            Navigator.of(context).pushNamed(RouteGenerator.blockedUserScreen),
        horizontalTitleGap: 5.0,
        leading: const Icon(customIcons.MyFlutterApp.no_stopping,
            color: Colors.black),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(lang.screens_editProfile15,
                  style: const TextStyle(color: Colors.black)),
              const SizedBox(width: 10.0),
              if (_numOfBlockedUsers > 0)
                Badge(
                    elevation: 0.0,
                    toAnimate: false,
                    badgeColor: Colors.amber,
                    borderRadius: BorderRadius.circular(5.0),
                    shape: BadgeShape.square,
                    badgeContent: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 10.0),
                        child: Text(_blockedNumber(_numOfBlockedUsers),
                            style: const TextStyle(
                                letterSpacing: 0.85,
                                fontSize: 15.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w400))))
            ]));
  }

  Widget buildAvatar(dynamic myUsername, Color _primaryColor) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        TextButton(
            style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
            onPressed: () => showDialog(
                context: context,
                builder: (ctx) => buildMyDialog(myUsername, _primaryColor)),
            child: ChatProfileImage(
                username: myUsername,
                factor: 0.20,
                inEdit: true,
                asset: (myImgUrl != 'none' && assets.isNotEmpty)
                    ? assets[0]
                    : null,
                editUrl: myImgUrl))
      ]);
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final myProfile = Provider.of<MyProfile>(context);
    final String myUsername = myProfile.getUsername;
    final String xbanner = myProfile.getProfileBanner;
    final bool xbannerNSFW = myProfile.getBannerNSFW;
    final String xVisibility =
        General.generateProfileVis(myProfile.getVisibility);
    final String xAvatar = myProfile.getProfileImage;
    final String xBio = myProfile.getBio;
    final xTopics = myProfile.getTopics;
    final String profileImgUrl = myProfile.getProfileImage;
    const SizedBox _heightBox = SizedBox(height: 15.0);
    String? _validateBio(String? value) {
      if (value!.length > 1000) {
        return lang.screens_editProfile1;
      } else {
        return null;
      }
    }

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: Consumer<MyProfile>(builder: (ctx, myProfile, _) {
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

              void _changeTopics(List<String> newNames) =>
                  myProfile.changeTopics(newNames);
              void _changeBio(String newBio) => myProfile.changeBio(newBio);
              void _changeImage(String newUrl) =>
                  myProfile.setMyProfileImage(newUrl);
              return Form(
                  key: _formKey,
                  child: SizedBox(
                      height: _deviceHeight,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SettingsBar(lang.screens_editProfile16),
                            Expanded(
                                child: Noglow(
                                    child: SingleChildScrollView(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        controller: scrollController,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              _heightBox,
                                              const MyProfileBanner(true),
                                              _heightBox,
                                              buildDropButton(_changeLocalVis,
                                                  _primaryColor),
                                              _heightBox,
                                              buildAvatar(
                                                  myUsername, _primaryColor),
                                              _heightBox,
                                              EditProfileTextField(
                                                  scrollController,
                                                  fieldHandler,
                                                  fieldBuilder,
                                                  _validateBio,
                                                  _bioController),
                                              _heightBox,
                                              _heightBox,
                                              EditProfileTopics(
                                                  scrollController,
                                                  addTopic,
                                                  _newTopicNames,
                                                  _removeTopic),
                                              const Divider(),
                                              buildBlockedButton(
                                                  _numOfBlockedUsers),
                                              const Divider(),
                                              buildAdditionalInfoButton(
                                                  _primaryColor),
                                              DeleteProfileButton(
                                                  isLoading,
                                                  () => setState(
                                                      () => isLoading = true))
                                            ])))),
                            Opacity(
                                opacity: (somethingChanged) ? 1.0 : .65,
                                child: TextButton(
                                    style: ButtonStyle(
                                        enableFeedback: false,
                                        elevation: MaterialStateProperty.all<double?>(
                                            0.0),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color?>(
                                                _primaryColor),
                                        shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight:
                                                    const Radius.circular(15.0),
                                                topLeft: const Radius.circular(
                                                    15.0))))),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      bool _isValid =
                                          _formKey.currentState!.validate();
                                      if (_isValid && somethingChanged) {
                                        if (isLoading) {
                                        } else {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          updateUser(
                                              myUsername: myUsername,
                                              profileImageUrl: profileImgUrl,
                                              changeBio: _changeBio,
                                              changeTopics: _changeTopics,
                                              changeVisibility:
                                                  _changeVisibility!,
                                              changeImage: _changeImage,
                                              finalMentions: mentions,
                                              xBanner: xbanner,
                                              xBannerNSFW: xbannerNSFW,
                                              xVisibility: xVisibility,
                                              xAvatar: xAvatar,
                                              xBio: xBio,
                                              xTopics: xTopics);
                                        }
                                      } else {}
                                    },
                                    child: (isLoading)
                                        ? CircularProgressIndicator(
                                            color: _accentColor,
                                            strokeWidth: 1.50)
                                        : Text(lang.screens_editProfile17, style: TextStyle(fontSize: 35.0, color: _accentColor))))
                          ])));
            }))));
  }
}

class EditProfileTextField extends StatelessWidget {
  final dynamic scrollController;
  final dynamic fieldHandler;
  final dynamic fieldBuilder;
  final dynamic _validateBio;
  final dynamic _bioController;
  const EditProfileTextField(this.scrollController, this.fieldHandler,
      this.fieldBuilder, this._validateBio, this._bioController);

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: NestedScroller(
            controller: scrollController,
            child: TypeAheadFormField<MiniProfile>(
                suggestionsCallback: fieldHandler,
                itemBuilder: fieldBuilder,
                onSuggestionSelected: (_) {},
                hideOnEmpty: true,
                hideOnError: true,
                hideOnLoading: true,
                hideSuggestionsOnKeyboardHide: false,
                validator: _validateBio,
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    hasScrollbar: false),
                textFieldConfiguration: TextFieldConfiguration(
                    controller: _bioController,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: 20,
                    maxLength: 1000,
                    decoration: InputDecoration(
                        labelText: lang.screens_editProfile18,
                        counterText: '',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: _primaryColor)))))));
  }
}

class EditProfileTopics extends StatelessWidget {
  final dynamic scrollController;
  final dynamic addTopic;
  final dynamic _newTopicNames;
  final dynamic _removeTopic;
  const EditProfileTopics(this.scrollController, this.addTopic,
      this._newTopicNames, this._removeTopic);

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double _deviceWidth = General.widthQuery(context);
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
                              lang.screens_editProfile19,
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
