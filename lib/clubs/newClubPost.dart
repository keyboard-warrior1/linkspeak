import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:mime/mime.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../general.dart';
import '../models/boardPostItem.dart';
import '../models/miniProfile.dart';
import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/addPostScreenState.dart';
import '../providers/clubProvider.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/additionalAddressButton.dart';
import '../widgets/common/chatProfileImage.dart';
import '../widgets/common/nestedScroller.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import '../widgets/topics/addTopic.dart';
import '../widgets/topics/topicChip.dart';

class NewClubPost extends StatefulWidget {
  const NewClubPost();

  @override
  State<NewClubPost> createState() => _NewClubPostState();
}

class _NewClubPostState extends State<NewClubPost>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  late final GlobalKey<FormState> _key;
  late final TextEditingController _descriptionController;
  late final ScrollController scrollController;
  late final TabController _controller;
  final _mediaInfo = FlutterVideoInfo();
  bool clubTopicsAdded = false;
  bool myTopicsAdded = false;
  List<AssetEntity> assets = [];
  List<File> files = [];
  List<String> mentions = [];
  bool hasNSFW = false;
  _handleTabSelection() {
    if (_controller.indexIsChanging) {
      setState(() {});
    }
  }

  String? _validateDescription(String? value) {
    if ((value!.isEmpty ||
            value.replaceAll(' ', '') == '' ||
            value.trim() == '') &&
        assets.isEmpty) return 'Please provide a description or any media file';
    if (value.length > 10000)
      return 'Descriptions can be between 1-10000 characters';
    if ((value.isEmpty ||
            value.replaceAll(' ', '') == '' ||
            value.trim() == '') &&
        assets.isNotEmpty) return null;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _key = GlobalKey<FormState>();
    scrollController = ScrollController();
    _descriptionController = TextEditingController();
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(_handleTabSelection);

    final RegExp _exp = RegExp(
      r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
      multiLine: true,
      caseSensitive: false,
      dotAll: true,
    );
    const prefix = '@';
    _descriptionController.addListener(() {
      final text = _descriptionController.text;
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
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _descriptionController.removeListener(() {});
    _descriptionController.dispose();
    _controller.removeListener(() {});
    _controller.dispose();
  }

  Widget _imageAssetWidget(AssetEntity asset) {
    return Image(
      image: AssetEntityImageProvider(asset, isOriginal: false),
      fit: BoxFit.cover,
    );
  }

  Widget _videoAssetWidget(AssetEntity asset) {
    return Stack(children: <Widget>[
      Positioned.fill(child: _imageAssetWidget(asset)),
      const ColoredBox(
          color: Colors.white38,
          child: Center(
              child: Icon(Icons.play_arrow, color: Colors.black, size: 24.0)))
    ]);
  }

  Widget _assetWidgetBuilder(AssetEntity asset) {
    Widget? widget;
    switch (asset.type) {
      case AssetType.audio:
        break;
      case AssetType.video:
        widget = _videoAssetWidget(asset);
        break;
      case AssetType.image:
      case AssetType.other:
        widget = _imageAssetWidget(asset);
        break;
    }
    return widget!;
  }

  Widget _selectedAssetWidget(int index) {
    final AssetEntity asset = assets.elementAt(index);
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        if (isLoading) {
        } else {
          final List<AssetEntity>? result =
              await AssetPickerViewer.pushToViewer(
            context,
            currentIndex: index,
            previewAssets: assets,
            themeData: AssetPicker.themeData(Colors.blue),
          );
          if (result != null && result != assets) {
            assets = List<AssetEntity>.from(result);
            if (mounted) {
              setState(() {});
            }
          }
        }
      },
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: _assetWidgetBuilder(asset),
        ),
      ),
    );
  }

  Future<void> _choose(Color primaryColor) async {
    final int _maxAssets = 10;
    const _english = const EnglishAssetPickerTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            maxAssets: _maxAssets,
            textDelegate: _english,
            selectedAssets: assets,
            requestType: RequestType.common,
            themeColor: primaryColor));
    if (_result != null) {
      for (var result in _result) {
        if (!assets.any((element) => element == result)) {
          assets.add(result);
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _chooseCamera(Color primaryColor, Color accentColor) async {
    final AssetEntity? _result = await CameraPicker.pickFromCamera(context,
        pickerConfig: CameraPickerConfig(
            resolutionPreset: ResolutionPreset.high,
            enableRecording: true,
            maximumRecordingDuration: const Duration(seconds: 60),
            textDelegate: const EnglishCameraPickerTextDelegate(),
            theme: ThemeData(colorScheme: Theme.of(context).colorScheme)));
    if (_result != null && assets.length < 10) {
      assets.add(_result);
      if (mounted) {
        setState(() {});
      }
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

  void _removeMedia(index) {
    setState(() {
      assets.removeAt(index);
    });
  }

  Future<File> getFile(AssetEntity asset) async {
    final file = await asset.file;
    return file!;
  }

  Future<List<File>> getFiles(List<AssetEntity> assets) async {
    var files = Future.wait(assets.map((asset) => getFile(asset)).toList());
    return files;
  }

  Future<String> uploadFile(String postID, File file) async {
    final String filePath = file.absolute.path;
    final name = filePath.split('/').last;
    final type = lookupMimeType(name);
    if (!kIsWeb) {
      if (type!.startsWith('image')) {
        var recognitions = await FlutterNsfw.getPhotoNSFWScore(filePath);
        if (recognitions > 0.759) {
          setState(() {
            hasNSFW = true;
          });
        }
      } else {
        final vidInfo = await _mediaInfo.getVideoInfo(filePath);
        final vidWidth = vidInfo!.width;
        final vidHeight = vidInfo.height;
        final recognitions = await FlutterNsfw.detectNSFWVideo(
          videoPath: filePath,
          frameWidth: vidWidth!,
          frameHeight: vidHeight!,
          nsfwThreshold: 0.759,
          durationPerFrame: 1000,
        );
        if (recognitions) {
          setState(() {
            hasNSFW = true;
          });
        }
      }
    }
    final String ref = 'Posts/$postID/$name';
    var storageReference = storage.ref(ref);
    var uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() {
      storageReference = storage.ref(ref);
    });
    return await storageReference.getDownloadURL();
  }

  Future<List<String>> uploadFiles(String postID, List<File> files) async {
    var mediaURLS = await Future.wait(
        files.map((file) => uploadFile(postID, file)).toList());
    return mediaURLS;
  }

  void _addPost({
    required String username,
    required myVisibility,
    required List<String> formTopics,
    required bool containsSensitiveContent,
    required bool commentsDisabled,
    required void Function() clear,
    required void Function() empty,
    required void Function(String) profileAddPost,
    required dynamic location,
    required String locationName,
    required String clubName,
    required int maxDailyPosts,
    required List<String> finalMentions,
  }) {
    final filter = ProfanityFilter();
    final String originalDescription = _descriptionController.text;
    String filteredDescription = _descriptionController.text;
    if (filter.hasProfanity(originalDescription)) {
      filteredDescription = filter.censor(originalDescription);
    }
    final String postID = General.generateContentID(
        username: username,
        clubName: clubName,
        isPost: false,
        isClubPost: true,
        isCollection: false,
        isFlare: false,
        isComment: false,
        isReply: false,
        isFlareComment: false,
        isFlareReply: false);
    final DateTime rightNow = DateTime.now();
    bool invalidVid =
        assets.any((asset) => asset.videoDuration > Duration(seconds: 60));

    bool valid = _key.currentState!.validate() && !invalidVid;
    bool canSubmit = valid;

    void _submitPost(List<String> urls) {
      profileAddPost(postID);
      _descriptionController.clear();
      formTopics.clear();
      clubTopicsAdded = false;
      myTopicsAdded = false;
      clear();
      empty();
    }

    Future<void> _sendPost() async {
      var invalidSizeVid = [];
      var invalidSizeIMG = [];
      for (var asset in assets) {
        if (asset.type == AssetType.video) {
          var file = await asset.file;
          var size = file!.lengthSync();
          if (size > 150000000) {
            invalidSizeVid.insert(0, file);
          }
        } else {
          var file = await asset.file;
          var size = file!.lengthSync();
          if (size > 30000000) {
            invalidSizeIMG.insert(0, file);
          }
        }
      }
      setState(() {});
      if (invalidSizeVid.isNotEmpty || invalidSizeIMG.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
        EasyLoading.dismiss();
        if (invalidSizeVid.isNotEmpty) {
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "Videos can be up to 150 MB in size",
          );
        }
        if (invalidSizeIMG.isNotEmpty) {
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "Images can be up to 30 MB in size",
          );
        }
      } else {
        final DateTime _rightNow = DateTime.now();
        final last24hour = _rightNow.subtract(Duration(minutes: 1440));
        final List<String> last24hrs = [];
        final getLast51 = await firestore
            .collection('Posts')
            .where('poster', isEqualTo: username)
            .where('clubName', isEqualTo: clubName)
            .orderBy('date', descending: true)
            .limit(maxDailyPosts + 1)
            .get();
        final myPostIDs = getLast51.docs;
        for (var id in myPostIDs) {
          final post = await firestore.collection('Posts').doc(id.id).get();
          if (post.exists) {
            final date = post.get('date').toDate();
            Duration diff = date.difference(last24hour);
            if (diff.inMinutes >= 0 && diff.inMinutes <= 1440) {
              last24hrs.add(id.id);
            } else {}
          }
        }
        if (last24hrs.length >= maxDailyPosts) {
          setState(() {
            isLoading = false;
          });
          EasyLoading.dismiss();
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "Members can publish up to ${maxDailyPosts.toString()} posts daily",
          );
        } else {
          if (!kIsWeb) {
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
          }
          var batch = firestore.batch();
          final myUserDoc = firestore.collection('Users').doc(username);
          final thisClubDoc = firestore.collection('Clubs').doc(clubName);
          final clubPostsDoc = thisClubDoc.collection('Posts').doc(postID);
          final myPostDoc = myUserDoc.collection('Posts').doc(postID);
          final thePostDoc = firestore.collection('Posts').doc(postID);
          final reviewalDoc = firestore.collection('Review').doc(postID);
          if (filter.hasProfanity(originalDescription)) {
            batch.update(firestore.doc('Profanity/Posts'),
                {'numOfProfanity': FieldValue.increment(1)});
            batch.set(firestore.collection('Profanity/Posts/Posts').doc(), {
              'postID': postID,
              'user': username,
              'original': originalDescription,
              'date': _rightNow,
            });
          }
          Future<void> mentionHandler(String mentionedUser) async {
            final users = firestore.collection('Users');
            if (mentionedUser != username) {
              final targetUser = await users.doc(mentionedUser).get();
              final userExists = targetUser.exists;
              if (userExists) {
                final notifDescription =
                    '$username mentioned you in their post';
                final token = targetUser.get('fcm');
                final theirBlockDoc = await users
                    .doc(mentionedUser)
                    .collection('Blocked')
                    .doc(username)
                    .get();
                final myBlockDoc = await users
                    .doc(username)
                    .collection('Blocked')
                    .doc(mentionedUser)
                    .get();
                final bool imBlocked = theirBlockDoc.exists;
                final bool theyreBlocked = myBlockDoc.exists;
                final myMentions =
                    users.doc(username).collection('My mentions');
                final mentionBox =
                    users.doc(mentionedUser).collection('Mention Box');
                final theirMentionedIn =
                    users.doc(mentionedUser).collection('Mentioned In');
                final data = {
                  'mentioned user': mentionedUser,
                  'mentioned by': username,
                  'date': rightNow,
                  'postID': postID,
                  'commentID': '',
                  'replyID': '',
                  'collectionID': '',
                  'flareID': '',
                  'flareCommentID': '',
                  'flareReplyID': '',
                  'commenterName': '',
                  'clubName': clubName,
                  'posterName': username,
                  'isClubPost': true,
                  'isPost': true,
                  'isComment': false,
                  'isReply': false,
                  'isBio': false,
                  'isFlare': false,
                  'isFlareComment': false,
                  'isFlareReply': false,
                  'isFlaresBio': false,
                };
                final alertData = {
                  'mentioned user': mentionedUser,
                  'mentioned by': username,
                  'token': token,
                  'description': notifDescription,
                  'date': rightNow,
                  'postID': postID,
                  'commentID': '',
                  'replyID': '',
                  'collectionID': '',
                  'flareID': '',
                  'flareCommentID': '',
                  'flareReplyID': '',
                  'commenterName': '',
                  'clubName': clubName,
                  'posterName': username,
                  'isClubPost': true,
                  'isPost': true,
                  'isComment': false,
                  'isReply': false,
                  'isBio': false,
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

          Future<void> uploadTopic(String topic) async {
            var _batch = firestore.batch();
            final targetTopicDoc = firestore.collection('Topics').doc(topic);
            final targetPostDoc =
                targetTopicDoc.collection('posts').doc(postID);
            _batch.set(targetPostDoc, {'date': rightNow, 'clubName': clubName});
            _batch.set(targetTopicDoc, {'count': FieldValue.increment(1)},
                SetOptions(merge: true));
            return _batch.commit();
          }

          Future<void> addTopicPost(List<String> topics) async {
            for (var topic in topics) {
              await uploadTopic(topic);
            }
          }

          Future<void> uploadPlace(String placeName) async {
            final targetPlaceDoc =
                firestore.collection('Places').doc(placeName);
            final targetPostDoc =
                targetPlaceDoc.collection('posts').doc(postID);
            batch.set(
                targetPostDoc,
                {'date': rightNow, 'point': location, 'clubName': clubName},
                SetOptions(merge: true));
            batch.set(
                targetPlaceDoc,
                {'posts': FieldValue.increment(1), 'point': location},
                SetOptions(merge: true));
          }

          final fileList = await getFiles(assets);
          final fileUrls = await uploadFiles(postID, fileList);
          if (locationName != '') await uploadPlace(locationName);
          await mentionPeople(finalMentions);
          await addTopicPost(formTopics);
          batch.set(thePostDoc, {
            'poster': username,
            'description': filteredDescription,
            'sensitive': (assets.isNotEmpty)
                ? (containsSensitiveContent || hasNSFW)
                    ? true
                    : false
                : false,
            'commentsDisabled': commentsDisabled,
            'isEdited': false,
            'topics': formTopics,
            'topicCount': formTopics.length,
            'imgUrls': fileUrls,
            'likes': 0,
            'comments': 0,
            'date': rightNow,
            'editDate': rightNow,
            'location': location,
            'locationName': locationName,
            'clubName': clubName,
            'type': 'legacy',
            'items': [],
            'backgroundColor': '',
            'gradientColor': '',
          });
          batch.update(myUserDoc, {'numOfPosts': FieldValue.increment(1)});
          batch.set(myPostDoc, {'date': rightNow});
          batch.set(clubPostsDoc, {'date': rightNow});
          batch.update(thisClubDoc, {'numOfPosts': FieldValue.increment(1)});
          return batch.commit().then((_) async {
            Map<String, dynamic> fields = {
              'club posts': FieldValue.increment(1)
            };
            Map<String, dynamic> docFields = {
              'date': _rightNow,
              'clubName': clubName
            };
            General.updateControl(
                fields: fields,
                myUsername: username,
                collectionName: 'club posts',
                docID: '$postID',
                docFields: docFields);
            if (hasNSFW) {
              reviewalDoc.set({
                'date': rightNow,
                'poster': username,
                'clubName': clubName,
                'ID': postID,
                'isFlare': false,
                'flareID': '',
                'collectionID': '',
                'isPost': true,
                'isClubPost': true,
                'isComment': false,
                'isFlareComment': false,
                'isReply': false,
                'isFlareReply': false,
                'isProfileBanner': false,
                'isClubBanner': false,
                'flarePoster': false,
                'profile': '',
                'commentID': '',
                'replyID': '',
              }).then((value) {
                EasyLoading.showSuccess('Published',
                    dismissOnTap: true, duration: const Duration(seconds: 1));
                _submitPost(fileUrls);
                setState(() {
                  isLoading = false;
                  hasNSFW = false;
                  assets.clear();
                });
              }).catchError((onError) {
                EasyLoading.showSuccess('Published',
                    dismissOnTap: true, duration: const Duration(seconds: 1));
                _submitPost(fileUrls);
                setState(() {
                  isLoading = false;
                  hasNSFW = false;
                  assets.clear();
                });
              });
            } else {
              EasyLoading.showSuccess('Published',
                  dismissOnTap: true, duration: const Duration(seconds: 1));
              _submitPost(fileUrls);
              setState(() {
                isLoading = false;
                hasNSFW = false;
                assets.clear();
              });
            }
          }).catchError((error) {
            EasyLoading.showError('Failed',
                dismissOnTap: true, duration: const Duration(seconds: 2));
            setState(() {
              isLoading = false;
            });
          });
        }
      }
    }

    if (isLoading) {
    } else {
      if (canSubmit && !isLoading) {
        setState(() {
          isLoading = true;
        });
        EasyLoading.show(status: 'Publishing', dismissOnTap: false);
        _sendPost();
      } else if (invalidVid) {
        setState(() {
          isLoading = false;
        });
        _showDialog(Icons.warning, Colors.red, 'Invalid media',
            "Videos can be up to 1 minute long");
      } else {}
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
        username: username,
        factor: 0.04,
        inEdit: false,
        asset: null,
      ),
      title: Text(
        username,
        textAlign: TextAlign.start,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
      ),
    );
  }

  FutureOr<Iterable<MiniProfile>> fieldHandler(String input) {
    final RegExp atRegexp = atSignRegExp;
    final isTagging = atRegexp.hasMatch(input);
    if (isTagging) {
      final RegExp _exp = RegExp(
        r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
        multiLine: true,
        caseSensitive: false,
        dotAll: true,
      );
      final cursorLocation = _descriptionController.selection.base.offset;
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
    final oldText = _descriptionController.text;
    final cursorLocation = _descriptionController.selection.base.offset;
    final beginningTillHere = oldText.substring(0, cursorLocation);
    final result = beginningTillHere.split(' ');
    final last = result.lastWhere((element) => element.startsWith(prefix));
    final newUsername = '@${mini.username}';
    final length = newUsername.length;
    final newText = oldText.replaceFirst(last, newUsername);
    mentions.add(mini.username);
    _descriptionController.value =
        _descriptionController.value.copyWith(text: newText);
    final theIndex = _descriptionController.text.indexOf(newUsername) + length;
    final newPosition = TextPosition(offset: theIndex);
    _descriptionController.selection = TextSelection.fromPosition(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = General.widthQuery(context);
    final myProfile = context.read<MyProfile>();
    final clubHelper = Provider.of<ClubProvider>(context, listen: false);
    final String clubName = clubHelper.clubName;
    final int maxDailyPosts = clubHelper.maxDailyPostsByMembers;
    final List<String> _clubTopics = clubHelper.clubTopics;
    final List<String> _myTopics = myProfile.getTopics;
    final profileAddPost =
        Provider.of<MyProfile>(context, listen: false).addPost;
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final _addPostState = Provider.of<NewPostHelper>(context);
    final _postStateNoListen = context.read<NewPostHelper>();
    final bool containsSensitiveContent = _addPostState.containsSensitive;
    final bool disabledComments = _addPostState.disabledComments;
    final dynamic helperLocation = _addPostState.getLocation;
    final String helperLocationName = _addPostState.getLocationName;
    final List<String> _formTopics = _addPostState.formTopics;
    final void Function(String) _addTopic = _postStateNoListen.addTopic;
    final void Function(int) _removeTopic = _postStateNoListen.removeTopic;
    final void Function() clear = _postStateNoListen.clear;
    final void Function(List<String>) addMyTopics =
        _postStateNoListen.addMyTopics;
    final dynamic changePostAddress = _postStateNoListen.changeLocation;
    final dynamic changePostAddressName = _postStateNoListen.changeLocationName;
    final postAddress = _addPostState.getLocation;
    final postAddressName = _addPostState.getLocationName;
    final void Function() empty =
        Provider.of<NewPostHelper>(context, listen: false).empty;
    final String _username = myProfile.getUsername;
    final _myVisibility = myProfile.getVisibility;
    const _heightBox = SizedBox(height: 15.0);
    return Scaffold(
        appBar: null,
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
                child: SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Form(
                        key: _key,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const SettingsBar('Publish'),
                              PublishTabBar(_controller),
                              Expanded(
                                  child: TabBarView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      controller: _controller,
                                      children: [
                                    Noglow(
                                        child: ListView(
                                            keyboardDismissBehavior:
                                                ScrollViewKeyboardDismissBehavior
                                                    .onDrag,
                                            padding:
                                                EdgeInsets.only(bottom: 65.0),
                                            controller: scrollController,
                                            children: <Widget>[
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                NewClubPostTextField(
                                                    scrollController,
                                                    fieldHandler,
                                                    fieldBuilder,
                                                    _validateDescription,
                                                    _descriptionController),
                                                _heightBox,
                                                if (!kIsWeb)
                                                  NewClubPostMedia(
                                                      scrollController,
                                                      assets,
                                                      isLoading,
                                                      _choose,
                                                      _chooseCamera,
                                                      _selectedAssetWidget,
                                                      _removeMedia),
                                                if (!kIsWeb)
                                                  AdditionalAddressButton(
                                                    isInPostScreen: false,
                                                    isInPost: true,
                                                    somethingChanged: () {},
                                                    changeAddress:
                                                        changePostAddress,
                                                    changeAddressName:
                                                        changePostAddressName,
                                                    postLocation: postAddress,
                                                    postLocationName:
                                                        postAddressName,
                                                  ),
                                                if (assets.isNotEmpty)
                                                  ListTile(
                                                      minVerticalPadding: 0.0,
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 8.0),
                                                      horizontalTitleGap: 5.0,
                                                      leading: Switch(
                                                          inactiveTrackColor:
                                                              Colors
                                                                  .red.shade200,
                                                          activeTrackColor:
                                                              Colors.red,
                                                          activeColor:
                                                              Colors.white,
                                                          value:
                                                              containsSensitiveContent,
                                                          onChanged: (value) {
                                                            if (isLoading) {
                                                            } else {
                                                              Provider.of<NewPostHelper>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .changeSensitivity(
                                                                      value);
                                                            }
                                                          }),
                                                      title: GestureDetector(
                                                          onTap: () {
                                                            if (isLoading) {
                                                            } else {
                                                              Provider.of<NewPostHelper>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .toggleSensitivity();
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Sensitive content',
                                                          ))),
                                                ListTile(
                                                    minVerticalPadding: 0.0,
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 8.0),
                                                    horizontalTitleGap: 5.0,
                                                    leading: Switch(
                                                        inactiveTrackColor:
                                                            Colors.red.shade200,
                                                        activeTrackColor:
                                                            Colors.red,
                                                        activeColor:
                                                            Colors.white,
                                                        value: disabledComments,
                                                        onChanged: (value) {
                                                          if (isLoading) {
                                                          } else {
                                                            Provider.of<NewPostHelper>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .changeDisabledComments(
                                                                    value);
                                                          }
                                                        }),
                                                    title: GestureDetector(
                                                        onTap: () {
                                                          if (isLoading) {
                                                          } else {
                                                            Provider.of<NewPostHelper>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .toggleDisabledComments();
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Disable comments'))),
                                                _heightBox,
                                                NewClubPostTopics(
                                                    isLoading,
                                                    _addTopic,
                                                    _formTopics,
                                                    _removeTopic,
                                                    _myTopics,
                                                    _clubTopics,
                                                    addMyTopics,
                                                    myTopicsAdded,
                                                    clubTopicsAdded,
                                                    () => setState(() =>
                                                        myTopicsAdded = true),
                                                    () => setState(() =>
                                                        clubTopicsAdded =
                                                            true)),
                                                _heightBox,
                                                Container(
                                                    height: 55.0,
                                                    width: 50.0,
                                                    color: Colors.transparent,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 40.0),
                                                    child: ElevatedButton(
                                                        style: ButtonStyle(
                                                            elevation:
                                                                MaterialStateProperty.all<double?>(
                                                                    0.0),
                                                            shape: MaterialStateProperty.all<OutlinedBorder?>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15.0))),
                                                            backgroundColor:
                                                                MaterialStateProperty.all<Color?>(
                                                                    _primarySwatch),
                                                            shadowColor:
                                                                MaterialStateProperty.all<Color?>(
                                                                    _primarySwatch)),
                                                        onPressed: () {
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          _addPost(
                                                              location:
                                                                  helperLocation,
                                                              locationName:
                                                                  helperLocationName,
                                                              username:
                                                                  _username,
                                                              myVisibility:
                                                                  _myVisibility,
                                                              formTopics:
                                                                  _formTopics,
                                                              containsSensitiveContent:
                                                                  containsSensitiveContent,
                                                              commentsDisabled:
                                                                  disabledComments,
                                                              clear: clear,
                                                              empty: empty,
                                                              profileAddPost:
                                                                  profileAddPost,
                                                              clubName:
                                                                  clubName,
                                                              maxDailyPosts:
                                                                  maxDailyPosts,
                                                              finalMentions:
                                                                  mentions);
                                                        },
                                                        child: Center(child: Text('Publish', style: TextStyle(color: _accentColor, fontSize: 30.0)))))
                                              ])
                                        ])),
                                    const BoardTab(),
                                    const BranchTab()
                                  ]))
                            ]))))));
  }
}

class NewClubPostTextField extends StatelessWidget {
  final dynamic scrollController;
  final dynamic fieldHandler;
  final dynamic fieldBuilder;
  final dynamic _validateDescription;
  final dynamic _descriptionController;
  const NewClubPostTextField(
      this.scrollController,
      this.fieldHandler,
      this.fieldBuilder,
      this._validateDescription,
      this._descriptionController);

  @override
  Widget build(BuildContext context) {
    final _primarySwatch = Theme.of(context).colorScheme.primary;
    return NestedScroller(
        controller: scrollController,
        child: TypeAheadFormField<MiniProfile>(
            suggestionsCallback: fieldHandler,
            itemBuilder: fieldBuilder,
            onSuggestionSelected: (_) {},
            hideOnEmpty: true,
            hideOnError: true,
            hideOnLoading: true,
            hideSuggestionsOnKeyboardHide: false,
            validator: _validateDescription,
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                borderRadius: BorderRadius.circular(15), hasScrollbar: false),
            textFieldConfiguration: TextFieldConfiguration(
              keyboardType: TextInputType.multiline,
              controller: _descriptionController,
              cursorColor: _primarySwatch,
              minLines: 4,
              maxLines: 30,
              decoration: InputDecoration(
                  hintText: 'What would you like to share?',
                  counterText: '',
                  hintStyle: TextStyle(color: Colors.grey.shade400)),
              maxLength: 10000,
            )));
  }
}

class NewClubPostMedia extends StatelessWidget {
  final dynamic scrollController;
  final dynamic assets;
  final dynamic isLoading;
  final dynamic _choose;
  final dynamic _chooseCamera;
  final dynamic _selectedAssetWidget;
  final dynamic _removeMedia;
  const NewClubPostMedia(
      this.scrollController,
      this.assets,
      this.isLoading,
      this._choose,
      this._chooseCamera,
      this._selectedAssetWidget,
      this._removeMedia);

  @override
  Widget build(BuildContext context) {
    final _primarySwatch = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    return Container(
        height: 400.0,
        child: NestedScroller(
            controller: scrollController,
            child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Wrap(children: <Widget>[
                    if (assets.length < 10)
                      GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (isLoading) {
                            } else {
                              showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(31.0)),
                                  backgroundColor: Colors.white,
                                  builder: (_) {
                                    final ListTile _choosephotoGallery =
                                        ListTile(
                                      horizontalTitleGap: 5.0,
                                      leading: const Icon(
                                        Icons.perm_media,
                                        color: Colors.black,
                                      ),
                                      title: const Text('Gallery',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      onTap: () => _choose(_primarySwatch),
                                    );
                                    final ListTile _camera = ListTile(
                                        horizontalTitleGap: 5.0,
                                        leading: const Icon(Icons.camera_alt,
                                            color: Colors.black),
                                        title: const Text('Camera',
                                            style:
                                                TextStyle(color: Colors.black)),
                                        onTap: () {
                                          if (assets.length < 10 && !kIsWeb)
                                            _chooseCamera(
                                                _primarySwatch, _accentColor);
                                        });
                                    final Column _choices = Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          if (assets.length < 10 && !kIsWeb)
                                            _camera,
                                          _choosephotoGallery
                                        ]);
                                    final SizedBox _box =
                                        SizedBox(child: _choices);
                                    return _box;
                                  });
                            }
                          },
                          child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: _primarySwatch,
                                  borderRadius: BorderRadius.circular(10.0)),
                              margin: const EdgeInsets.all(5.0),
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Container(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                    Icon(Icons.image_outlined,
                                        color: _accentColor, size: 65.0)
                                  ]))))),
                    ...assets.map((media) {
                      final int _currentIndex = assets.indexOf(media);
                      return Container(
                          height: 100.0,
                          width: 100.0,
                          margin: const EdgeInsets.all(5.0),
                          child: Stack(children: <Widget>[
                            Container(
                                key: UniqueKey(),
                                width: 100.0,
                                height: 100.0,
                                child: _selectedAssetWidget(_currentIndex)),
                            Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      if (isLoading) {
                                      } else {
                                        _removeMedia(_currentIndex);
                                      }
                                    },
                                    child: Icon(Icons.cancel,
                                        color: Colors.redAccent.shade400)))
                          ]));
                    }).toList()
                  ])
                ])));
  }
}

class NewClubPostTopics extends StatelessWidget {
  final bool isLoading;
  final bool myTopicsAdded;
  final bool clubTopicsAdded;
  final dynamic _addTopic;
  final dynamic _formTopics;
  final dynamic _removeTopic;
  final dynamic _myTopics;
  final dynamic _clubTopics;
  final dynamic addMyTopics;
  final dynamic handler;
  final dynamic clubTopicHandler;
  const NewClubPostTopics(
      this.isLoading,
      this._addTopic,
      this._formTopics,
      this._removeTopic,
      this._myTopics,
      this._clubTopics,
      this.addMyTopics,
      this.myTopicsAdded,
      this.clubTopicsAdded,
      this.handler,
      this.clubTopicHandler);

  @override
  Widget build(BuildContext context) {
    final _accentColor = Theme.of(context).colorScheme.secondary;

    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border(
                top: BorderSide(color: Colors.grey.shade400),
                bottom: BorderSide(color: Colors.grey.shade400))),
        height: 100,
        child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
          Container(
              child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (isLoading) {
                    } else {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(31.0)),
                          backgroundColor: Colors.white,
                          builder: (_) {
                            return AddTopic(
                                _addTopic, _formTopics, false, false, true);
                          });
                    }
                  },
                  child: TopicChip(
                      'New topic', Icon(Icons.add, color: _accentColor), () {
                    if (isLoading) {
                    } else {
                      showModalBottomSheet(
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
                                _addTopic, _formTopics, false, false, true);
                          });
                    }
                  }, _accentColor, FontWeight.bold))),
          if (!clubTopicsAdded)
            Container(
                child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (isLoading) {
                      } else {
                        addMyTopics(_clubTopics);
                        clubTopicHandler();
                      }
                    },
                    child: TopicChip(
                        'add club topics', Icon(Icons.add, color: _accentColor),
                        () {
                      if (isLoading) {
                      } else {
                        addMyTopics(_clubTopics);
                        clubTopicHandler();
                      }
                    }, _accentColor, FontWeight.bold))),
          if (!myTopicsAdded)
            Container(
                child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (isLoading) {
                      } else {
                        addMyTopics(_myTopics);
                        handler();
                      }
                    },
                    child: TopicChip(
                        'add my topics', Icon(Icons.add, color: _accentColor),
                        () {
                      if (isLoading) {
                      } else {
                        addMyTopics(_myTopics);
                        handler();
                      }
                    }, _accentColor, FontWeight.bold))),
          ..._formTopics.map((topic) {
            int idx = _formTopics.indexOf(topic);
            return TopicChip(topic, const Icon(Icons.close, color: Colors.red),
                () {
              if (isLoading) {
              } else {
                _removeTopic(idx);
              }
            }, Colors.white, FontWeight.normal);
          }).toList()
        ]));
  }
}

class PublishTabBar extends StatefulWidget {
  final TabController tabController;
  const PublishTabBar(this.tabController);
  @override
  _PublishTabBar createState() => _PublishTabBar();
}

class _PublishTabBar extends State<PublishTabBar> {
  @override
  Widget build(BuildContext context) {
    final Size _querySize = MediaQuery.of(context).size;
    final double _deviceWidth = _querySize.width;
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Widget _postsTab = Container(
        height: double.infinity,
        child: Center(child: const Icon(customIcons.MyFlutterApp.feed)));
    final Widget _aboutTab = Container(
        height: double.infinity,
        child: const Center(child: const Icon(Icons.rectangle_outlined)));
    final Widget _topicsTab = Container(
        height: double.infinity,
        child: const Center(child: const Icon(Icons.article_outlined)));
    final TabBar _tabbar = TabBar(
        controller: widget.tabController,
        indicatorColor: Colors.transparent,
        unselectedLabelColor: Colors.grey,
        labelColor: _primarySwatch,
        tabs: [_postsTab, _aboutTab, _topicsTab]);
    final Widget bar = Container(
        height: 50,
        width: _deviceWidth,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.transparent))),
        child: _tabbar);
    return bar;
  }
}

class BoardTab extends StatefulWidget {
  const BoardTab();

  @override
  State<BoardTab> createState() => _BoardTabState();
}

class _BoardTabState extends State<BoardTab>
    with AutomaticKeepAliveClientMixin {
  final _mediaInfo = FlutterVideoInfo();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  static const int limit = 20;
  bool isLoading = false;
  bool myTopicsAdded = false;
  bool clubTopicsAdded = false;
  bool isSensitive = false;
  bool commentsDisabled = false;
  Color? stateBackgroundColor = null;
  Color? stateGradientColor = null;
  List<BoardPostItem> _items = [];
  List<String> _topics = [];
  List<AssetEntity> _assets = [];

  Future<void> _choose(Color primaryColor, Color accentColor) async {
    Navigator.pop(context);
    final int _maxAssets = limit - _items.length;
    const _english = const EnglishAssetPickerTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            maxAssets: _maxAssets,
            textDelegate: _english,
            selectedAssets: _assets,
            requestType: RequestType.common,
            themeColor: primaryColor));
    if (_result != null) {
      for (var result in _result) {
        var path = result.id;
        print(path);
        if (!_assets.any((element) => element == result)) _assets.add(result);
        if (!_items.any((element) => element.assetPath == path))
          _items.add(BoardPostItem(
              description: '',
              isInEdit: true,
              isText: false,
              mediaIsAsset: true,
              mediaURL: '',
              assetPath: path));
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _chooseCamera(Color primaryColor, Color accentColor) async {
    Navigator.pop(context);
    final AssetEntity? _result = await CameraPicker.pickFromCamera(context,
        pickerConfig: CameraPickerConfig(
            resolutionPreset: ResolutionPreset.high,
            enableRecording: true,
            maximumRecordingDuration: const Duration(seconds: 60),
            textDelegate: const EnglishCameraPickerTextDelegate(),
            theme: ThemeData(colorScheme: Theme.of(context).colorScheme)));
    var remaining = limit - _items.length;
    if (_result != null && remaining > 0) {
      var path = _result.id;
      print(path);
      _assets.add(_result);
      if (!_items.any((element) => element.assetPath == path))
        _items.add(BoardPostItem(
            description: '',
            isInEdit: true,
            isText: false,
            mediaIsAsset: true,
            mediaURL: '',
            assetPath: path));
      if (mounted) setState(() {});
    }
  }

  void changeStateBackground(Color newColor) =>
      setState(() => stateBackgroundColor = newColor);
  void changeStateGradient(Color newColor) =>
      setState(() => stateGradientColor = newColor);
  Widget buildColorTile(dynamic _allColors, bool isGradient) => GestureDetector(
      onTap: isLoading
          ? () {}
          : () => showDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (_) => GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Material(
                      color: Colors.transparent,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            OColorPicker(
                                selectedColor: isGradient
                                    ? stateGradientColor
                                    : stateBackgroundColor,
                                colors: _allColors,
                                onColorChange: (color) {
                                  if (isGradient) {
                                    if (color != stateBackgroundColor)
                                      changeStateGradient(color);
                                  } else {
                                    if (color != stateGradientColor)
                                      changeStateBackground(color);
                                  }
                                })
                          ])))),
      child: Container(
          height: 40.0,
          width: 40.0,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: isGradient ? stateGradientColor : stateBackgroundColor)));
  Widget buildAdder(
          String description, IconData? icon, void Function() handler) =>
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (isLoading) {
                } else {
                  handler();
                }
              },
              child: Chip(
                  deleteButtonTooltipMessage: '',
                  key: UniqueKey(),
                  onDeleted: () {
                    FocusScope.of(context).unfocus();
                    if (isLoading) {
                    } else {
                      handler();
                    }
                  },
                  deleteIcon:
                      icon != null ? Icon(icon, color: Colors.white) : null,
                  padding: const EdgeInsets.only(
                      left: 3.50, top: 3.50, bottom: 3.50, right: 5),
                  backgroundColor: Colors.black,
                  label: Text(description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal)))));

  Widget buildTopicChip(
          String description, void Function(int) removeTopic, int index) =>
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Chip(
              deleteButtonTooltipMessage: '',
              onDeleted: isLoading ? () {} : () => removeTopic(index),
              deleteIcon: const Icon(Icons.close, color: Colors.red),
              padding: const EdgeInsets.all(3.5),
              backgroundColor: Colors.black,
              label: Text(description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal))));
  Widget buildTextField(String description, dynamic handler) => ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: 10, maxHeight: 400, minWidth: 10, maxWidth: 400),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(children: [
              Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(description,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20))),
              Positioned(
                  top: 1,
                  right: 1,
                  child: GestureDetector(
                      onTap: handler,
                      child:
                          const Icon(Icons.cancel_outlined, color: Colors.red)))
            ])
          ]));
  Widget _imageAssetWidget(AssetEntity asset) => Image(
      image: AssetEntityImageProvider(asset, isOriginal: false),
      fit: BoxFit.cover);

  Widget _videoAssetWidget(AssetEntity asset) => _imageAssetWidget(asset);

  Widget _assetWidgetBuilder(AssetEntity asset) {
    Widget? widget;
    switch (asset.type) {
      case AssetType.audio:
        break;
      case AssetType.video:
        widget = _videoAssetWidget(asset);
        break;
      case AssetType.image:
      case AssetType.other:
        widget = _imageAssetWidget(asset);
        break;
    }
    return widget!;
  }

  Widget _selectedAssetWidget(int index) {
    final AssetEntity asset = _assets.elementAt(index);
    return GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
          if (isLoading) {
          } else {
            final List<AssetEntity>? result =
                await AssetPickerViewer.pushToViewer(context,
                    currentIndex: index,
                    previewAssets: _assets,
                    themeData: AssetPicker.themeData(Colors.blue));
            if (result != null && result != _assets) {
              _assets = List<AssetEntity>.from(result);
              if (mounted) {
                setState(() {});
              }
            }
          }
        },
        child: RepaintBoundary(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: _assetWidgetBuilder(asset))));
  }

  Widget buildMediaItem(int index) =>
      Container(height: 400, width: 400, child: _selectedAssetWidget(index));
  void reset() => setState(() {
        isLoading = false;
        myTopicsAdded = false;
        clubTopicsAdded = false;
        _items.clear();
        _topics.clear();
        _assets.clear();
      });
  _showDialog(IconData icon, Color iconColor, String title, String rule) {
    showDialog(
      context: context,
      builder: (_) => RegistrationDialog(
          icon: icon, iconColor: iconColor, title: title, rules: rule),
    );
  }

  Future<String> uploadFile(String postID, File file, dynamic flagNSFW) async {
    final String filePath = file.absolute.path;
    final name = filePath.split('/').last;
    final type = lookupMimeType(name);
    if (!kIsWeb) {
      if (type!.startsWith('image')) {
        var recognitions = await FlutterNsfw.getPhotoNSFWScore(filePath);
        if (recognitions > 0.759) {
          flagNSFW();
        }
      } else {
        final vidInfo = await _mediaInfo.getVideoInfo(filePath);
        final vidWidth = vidInfo!.width;
        final vidHeight = vidInfo.height;
        final recognitions = await FlutterNsfw.detectNSFWVideo(
            videoPath: filePath,
            frameWidth: vidWidth!,
            frameHeight: vidHeight!,
            nsfwThreshold: 0.759,
            durationPerFrame: 1000);
        if (recognitions) {
          flagNSFW();
        }
      }
    }
    final String ref = 'Posts/$postID/$name';
    var storageReference = storage.ref(ref);
    var uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() {
      storageReference = storage.ref(ref);
    });
    return await storageReference.getDownloadURL();
  }

  Future<Map<String, dynamic>> handleSingleItem(
      {required String username,
      required String postID,
      required WriteBatch batch,
      required ProfanityFilter filter,
      required BoardPostItem item,
      required DateTime rightNow,
      required dynamic flagSensitive,
      required dynamic flagProfanity}) async {
    String originalDescription = item.description;
    String assetPath = item.assetPath;
    String mediaURL = '';
    if (filter.hasProfanity(originalDescription)) {
      flagProfanity();
      originalDescription = filter.censor(originalDescription);
    }
    if (assetPath != '') {
      var currentAssetIndex =
          _assets.indexWhere((element) => element.id == assetPath);
      var currentAsset = _assets[currentAssetIndex];
      var file = await currentAsset.file;
      String serveruploadFile = await uploadFile(postID, file!, flagSensitive);
      mediaURL = serveruploadFile;
    }
    Map<String, dynamic> serverListItem = {
      'isText': originalDescription != '',
      'description': originalDescription,
      'mediaURL': mediaURL
    };
    return serverListItem;
  }

  Future<List<Map<String, dynamic>>> handleItems(
      {required String username,
      required String postID,
      required WriteBatch batch,
      required ProfanityFilter filter,
      required DateTime rightNow,
      required dynamic flagSensitive,
      required dynamic flagProfanity}) async {
    List<Map<String, dynamic>> backendItems = [];
    for (var item in _items) {
      Map<String, dynamic> backendItem = await handleSingleItem(
          username: username,
          postID: postID,
          batch: batch,
          filter: filter,
          item: item,
          rightNow: rightNow,
          flagSensitive: flagSensitive,
          flagProfanity: flagProfanity);
      backendItems.add(backendItem);
    }
    return backendItems;
  }

  Future<void> _addPost(
      {required String username,
      required List<String> formTopics,
      required bool commentsDisabled,
      required void Function(String) profileAddPost,
      required String clubName,
      required int maxDailyPosts}) async {
    bool _hasSensitive = false;
    bool _hasProfanity = false;
    final _filter = ProfanityFilter();
    const duration = const Duration(seconds: 60);
    bool invalidVid = _assets.any((asset) => asset.videoDuration > duration);
    void flagSensitive() => _hasSensitive = true;
    void flagProfanity() => _hasProfanity = true;

    final DateTime rightNow = DateTime.now();
    final String postID = General.generateContentID(
        username: username,
        clubName: clubName,
        isPost: false,
        isClubPost: true,
        isCollection: false,
        isFlare: false,
        isComment: false,
        isReply: false,
        isFlareComment: false,
        isFlareReply: false);
    Future<void> uploadTopic(String topic) async {
      var _batch = firestore.batch();
      final targetTopicDoc = firestore.collection('Topics').doc(topic);
      final targetPostDoc = targetTopicDoc.collection('posts').doc(postID);
      _batch.set(targetPostDoc, {'date': rightNow, 'clubName': ''});
      _batch.set(targetTopicDoc, {'count': FieldValue.increment(1)},
          SetOptions(merge: true));
      return _batch.commit();
    }

    Future<void> addTopicPost(List<String> topics) async {
      for (var topic in topics) {
        await uploadTopic(topic);
      }
    }

    var invalidSizeVid = [];
    var invalidSizeIMG = [];
    for (var asset in _assets) {
      if (asset.type == AssetType.video) {
        var file = await asset.file;
        var size = file!.lengthSync();
        if (size > 150000000) {
          invalidSizeVid.insert(0, file);
        }
      } else {
        var file = await asset.file;
        var size = file!.lengthSync();
        if (size > 30000000) {
          invalidSizeIMG.insert(0, file);
        }
      }
    }
    setState(() {});
    if (invalidSizeVid.isNotEmpty || invalidSizeIMG.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
      EasyLoading.dismiss();
      if (invalidSizeVid.isNotEmpty) {
        _showDialog(Icons.info_outline, Colors.blue, 'Notice',
            "Videos can be up to 150 MB in size");
      }
      if (invalidSizeIMG.isNotEmpty) {
        _showDialog(Icons.info_outline, Colors.blue, 'Notice',
            "Images can be up to 30 MB in size");
      }
    } else {
      final DateTime _rightNow = DateTime.now();
      final last24hour = _rightNow.subtract(Duration(minutes: 1440));
      final List<String> last24hrs = [];
      final getLast51 = await firestore
          .collection('Posts')
          .where('poster', isEqualTo: username)
          .where('clubName', isEqualTo: clubName)
          .orderBy('date', descending: true)
          .limit(maxDailyPosts + 1)
          .get();
      final myPostIDs = getLast51.docs;
      for (var id in myPostIDs) {
        final post = await firestore.collection('Posts').doc(id.id).get();
        if (post.exists) {
          final date = post.get('date').toDate();
          Duration diff = date.difference(last24hour);
          if (diff.inMinutes >= 0 && diff.inMinutes <= 1440) {
            last24hrs.add(id.id);
          } else {}
        }
      }
      if (last24hrs.length >= maxDailyPosts) {
        setState(() {
          isLoading = false;
        });
        EasyLoading.dismiss();
        _showDialog(
          Icons.info_outline,
          Colors.blue,
          'Notice',
          "Members can publish up to ${maxDailyPosts.toString()} posts daily",
        );
      } else {
        if (invalidVid) {
          setState(() {
            isLoading = false;
          });
          _showDialog(Icons.warning, Colors.red, 'Invalid media',
              "Videos can be up to 1 minute long");
        } else {
          if (!kIsWeb) {
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
          }
          var batch = firestore.batch();
          final myUserDoc = firestore.collection('Users').doc(username);
          final myPostDoc = myUserDoc.collection('Posts').doc(postID);
          final thePostDoc = firestore.collection('Posts').doc(postID);
          final reviewalDoc = firestore.collection('Review').doc(postID);
          final thisClubDoc = firestore.collection('Clubs').doc(clubName);
          final clubPostsDoc = thisClubDoc.collection('Posts').doc(postID);

          if (_hasProfanity) {
            batch.update(firestore.doc('Profanity/Posts'),
                {'numOfProfanity': FieldValue.increment(1)});
            batch.set(firestore.collection('Profanity/Posts/Posts').doc(), {
              'postID': postID,
              'user': username,
              'original': '',
              'date': rightNow,
            });
          }
          if (_hasSensitive) {
            batch.set(
                reviewalDoc,
                {
                  'poster': username,
                  'date': rightNow,
                  'ID': postID,
                  'collectionID': '',
                  'flareID': '',
                  'clubName': clubName,
                  'isPost': true,
                  'isClubPost': true,
                  'isFlare': false,
                  'isComment': false,
                  'isFlareComment': false,
                  'isReply': false,
                  'isFlareReply': false,
                  'isProfileBanner': false,
                  'isClubBanner': false,
                  'flarePoster': false,
                  'profile': '',
                  'commentID': '',
                  'replyID': '',
                },
                SetOptions(merge: true));
          }
          if (_topics.isNotEmpty) await addTopicPost(_topics);
          List<Map<String, dynamic>> theITtems = await handleItems(
              username: username,
              postID: postID,
              batch: batch,
              filter: _filter,
              rightNow: rightNow,
              flagSensitive: flagSensitive,
              flagProfanity: flagProfanity);
          batch.set(thePostDoc, {
            'poster': username,
            'description': '',
            'sensitive': (isSensitive || _hasSensitive) ? true : false,
            'commentsDisabled': commentsDisabled,
            'isEdited': false,
            'topics': formTopics,
            'topicCount': formTopics.length,
            'imgUrls': [],
            'likes': 0,
            'comments': 0,
            'date': rightNow,
            'editDate': rightNow,
            'location': '',
            'locationName': '',
            'clubName': clubName,
            'type': 'board',
            'items': theITtems,
            'backgroundColor': stateBackgroundColor!.value,
            'gradientColor': stateGradientColor!.value,
          });
          batch.update(myUserDoc, {'numOfPosts': FieldValue.increment(1)});
          batch.set(clubPostsDoc, {'date': rightNow});
          batch.update(thisClubDoc, {'numOfPosts': FieldValue.increment(1)});
          batch.set(myPostDoc, {'date': rightNow});
          return batch.commit().then((_) async {
            Map<String, dynamic> fields = {'posts': FieldValue.increment(1)};
            Map<String, dynamic> docFields = {'date': _rightNow};
            General.updateControl(
                fields: fields,
                myUsername: username,
                collectionName: 'posts',
                docID: '$postID',
                docFields: docFields);
            EasyLoading.showSuccess('Published',
                dismissOnTap: true, duration: const Duration(seconds: 1));
            profileAddPost(postID);
            reset();
          }).catchError((error) {
            EasyLoading.showError('Failed',
                dismissOnTap: true, duration: const Duration(seconds: 2));
            setState(() => isLoading = false);
          });
        }
      }
    }
  }

  Widget buildListTile(bool isNsfwTile, double deviceWidth) => Container(
      width: deviceWidth,
      color: Colors.white,
      child: ListTile(
          minVerticalPadding: 0.0,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          horizontalTitleGap: 5.0,
          leading: Switch(
              inactiveTrackColor: Colors.red.shade200,
              activeTrackColor: Colors.red,
              activeColor: Colors.white,
              value: isNsfwTile ? isSensitive : commentsDisabled,
              onChanged: (value) {
                if (!isLoading) {
                  if (isNsfwTile)
                    setState(() {
                      isSensitive = value;
                    });
                  else
                    setState(() {
                      commentsDisabled = value;
                    });
                }
              }),
          title: GestureDetector(
              onTap: () {
                if (!isLoading) {
                  if (isNsfwTile)
                    setState(() {
                      isSensitive = !isSensitive;
                    });
                  else
                    setState(() {
                      commentsDisabled = !commentsDisabled;
                    });
                }
              },
              child: Text(
                  isNsfwTile ? 'Sensitive content' : 'Disable comments'))));

  @override
  Widget build(BuildContext context) {
    final myProfile = context.read<MyProfile>();
    final profileAddPost =
        Provider.of<MyProfile>(context, listen: false).addPost;
    final myUsername = myProfile.getUsername;
    final clubHelper = Provider.of<ClubProvider>(context, listen: false);
    final String clubName = clubHelper.clubName;
    final int maxDailyPosts = clubHelper.maxDailyPostsByMembers;
    final List<String> _clubTopics = clubHelper.clubTopics;
    final _deviceWidth = General.widthQuery(context);
    final theme = Theme.of(context);
    int _length = _items.length;
    final bool allowed = _length < limit;
    final systemPrimary = theme.colorScheme.primary;
    final systemSecondary = theme.colorScheme.secondary;
    if (stateGradientColor == null) stateGradientColor = systemSecondary;
    if (stateBackgroundColor == null) stateBackgroundColor = systemPrimary;
    var initialPrimaryPalette = primaryColorsPalette.take(19).toList();
    var initialAccentPalette = accentColorsPalette.take(16).toList();
    var _allColors = [...initialPrimaryPalette, ...initialAccentPalette];
    final List<String> myTopics = Provider.of<MyProfile>(context).getTopics;
    const _heightBox = SizedBox(height: 15.0);
    const _widthBox = SizedBox(width: 15);
    const _divider = Divider(color: Colors.transparent);
    const _side = BorderSide(color: Colors.white, width: 1);
    void _removeTopic(int idx) => setState(() => _topics.removeAt(idx));
    void _addTopic(String topic) => setState(() => _topics.add(topic));
    void _addMyTopics() {
      for (var topic in myTopics)
        if (!_topics.contains(topic)) _topics.add(topic);
      setState(() => myTopicsAdded = true);
    }

    void _addClubTopics() {
      for (var topic in _clubTopics)
        if (!_topics.contains(topic)) _topics.add(topic);
      setState(() => clubTopicsAdded = true);
    }

    super.build(context);
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                tileMode: TileMode.clamp,
                colors: [stateGradientColor!, stateBackgroundColor!])),
        child: Noglow(
            child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: 50,
                              color: Colors.white,
                              width: _deviceWidth,
                              child: Noglow(
                                  child: ListView(
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      scrollDirection: Axis.horizontal,
                                      children: <Widget>[
                                    buildColorTile(_allColors, false),
                                    buildColorTile(_allColors, true),
                                    if (allowed)
                                      buildAdder(
                                          'Add note', Icons.note_outlined, () {
                                        void handler(String desc) {
                                          final noteItem = BoardPostItem(
                                              isText: true,
                                              mediaIsAsset: false,
                                              isInEdit: true,
                                              description: desc,
                                              mediaURL: '',
                                              assetPath: '');
                                          setState(() => _items.add(noteItem));
                                        }

                                        var args = NoteScreenArgs(
                                            handler: handler,
                                            preexistingText: null,
                                            editHandler: (_) {},
                                            isBranch: false);
                                        Navigator.pushNamed(
                                            context, RouteGenerator.noteScreen,
                                            arguments: args);
                                      }),
                                    if (allowed && !kIsWeb)
                                      buildAdder(
                                          'Add media', Icons.image_outlined,
                                          () {
                                        FocusScope.of(context).unfocus();
                                        if (isLoading) {
                                        } else {
                                          showModalBottomSheet(
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          31.0)),
                                              backgroundColor: Colors.white,
                                              builder: (_) {
                                                final ListTile
                                                    _choosephotoGallery =
                                                    ListTile(
                                                        horizontalTitleGap: 5.0,
                                                        leading: const Icon(
                                                            Icons.perm_media,
                                                            color:
                                                                Colors.black),
                                                        title: const Text(
                                                            'Gallery',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black)),
                                                        onTap: () => _choose(
                                                            systemPrimary,
                                                            systemSecondary));
                                                final ListTile _camera =
                                                    ListTile(
                                                        horizontalTitleGap: 5.0,
                                                        leading: const Icon(
                                                            Icons.camera_alt,
                                                            color:
                                                                Colors.black),
                                                        title: const Text(
                                                            'Camera',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black)),
                                                        onTap: () {
                                                          if (allowed)
                                                            _chooseCamera(
                                                                systemPrimary,
                                                                systemSecondary);
                                                        });
                                                final Column _choices = Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      if (allowed && !kIsWeb)
                                                        _camera,
                                                      _choosephotoGallery
                                                    ]);
                                                final SizedBox _box =
                                                    SizedBox(child: _choices);
                                                return _box;
                                              });
                                        }
                                      }),
                                    buildAdder('New topic', Icons.add, () {
                                      if (isLoading) {
                                      } else {
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        31.0)),
                                            backgroundColor: Colors.white,
                                            builder: (_) {
                                              return AddTopic(_addTopic,
                                                  _topics, false, false, false);
                                            });
                                      }
                                    }),
                                    if (!myTopicsAdded)
                                      buildAdder('Add my topics', Icons.add,
                                          _addMyTopics),
                                    if (!clubTopicsAdded)
                                      buildAdder('Add club topics', Icons.add,
                                          _addClubTopics)
                                  ]))),
                          if (_topics.isNotEmpty)
                            Container(
                                height: 50,
                                color: Colors.white,
                                width: _deviceWidth,
                                child: Noglow(
                                    child: ListView(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        scrollDirection: Axis.horizontal,
                                        children: <Widget>[
                                      ..._topics.map((e) {
                                        var index = _topics.indexOf(e);
                                        return buildTopicChip(
                                            e, _removeTopic, index);
                                      }).toList()
                                    ]))),
                          if (_items.isNotEmpty)
                            buildListTile(true, _deviceWidth),
                          if (_items.isNotEmpty)
                            buildListTile(false, _deviceWidth),
                          _divider,
                          _divider,
                          Container(
                              height: 500,
                              width: _deviceWidth,
                              decoration: BoxDecoration(
                                  border:
                                      const Border(bottom: _side, top: _side)),
                              child: Noglow(
                                  child: ListView.separated(
                                      padding: const EdgeInsets.all(8),
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _items.length,
                                      separatorBuilder: (_, __) => _widthBox,
                                      itemBuilder: (ctx, idx) {
                                        var current = _items[idx];
                                        var isText = current.isText;
                                        var currentAssetPath =
                                            isText ? '' : current.assetPath;
                                        var currentAssetIndex = isText
                                            ? 0
                                            : _assets.indexWhere((element) =>
                                                element.id == currentAssetPath);
                                        return isText
                                            ? GestureDetector(
                                                onTap: () {
                                                  if (!isLoading) {
                                                    void editHandler(
                                                        String desc) {
                                                      final noteItem =
                                                          BoardPostItem(
                                                              isText: true,
                                                              mediaIsAsset:
                                                                  false,
                                                              isInEdit: true,
                                                              description: desc,
                                                              mediaURL: '',
                                                              assetPath: '');
                                                      _items.remove(current);
                                                      _items.insert(
                                                          idx, noteItem);
                                                      setState(() {});
                                                    }

                                                    var args = NoteScreenArgs(
                                                        handler: (_) {},
                                                        preexistingText:
                                                            current.description,
                                                        editHandler:
                                                            editHandler,
                                                        isBranch: false);
                                                    Navigator.pushNamed(
                                                        context,
                                                        RouteGenerator
                                                            .noteScreen,
                                                        arguments: args);
                                                  }
                                                },
                                                child: buildTextField(
                                                    current.description, () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  if (isLoading) {
                                                  } else {
                                                    _items.remove(current);
                                                    setState(() {});
                                                  }
                                                }),
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                    Stack(children: [
                                                      _selectedAssetWidget(
                                                          currentAssetIndex),
                                                      Positioned(
                                                          top: 3,
                                                          right: 2,
                                                          child:
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    FocusScope.of(
                                                                            context)
                                                                        .unfocus();
                                                                    if (isLoading) {
                                                                    } else {
                                                                      _items.remove(
                                                                          current);
                                                                      _assets.removeAt(
                                                                          currentAssetIndex);
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .redAccent
                                                                          .shade400)))
                                                    ]),
                                                  ]);
                                      }))),
                          _divider,
                          _heightBox,
                          Container(
                              color: Colors.transparent,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all<double?>(
                                          0.0),
                                      shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0))),
                                      backgroundColor: MaterialStateProperty.all<Color?>(
                                          Colors.black),
                                      shadowColor: MaterialStateProperty.all<Color?>(
                                          Colors.black)),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    if (!isLoading && _items.isNotEmpty) {
                                      setState(() => isLoading = !isLoading);
                                      _addPost(
                                          username: myUsername,
                                          formTopics: _topics,
                                          commentsDisabled: commentsDisabled,
                                          profileAddPost: profileAddPost,
                                          clubName: clubName,
                                          maxDailyPosts: maxDailyPosts);
                                    }
                                  },
                                  child: Center(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: isLoading ? SizedBox(height: 35, width: 35, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 1.50)) : const Text('Publish', style: TextStyle(color: Colors.white, fontSize: 30.0)))))),
                        ])))));
  }

  @override
  bool get wantKeepAlive => true;
}

class BranchTab extends StatefulWidget {
  const BranchTab();

  @override
  State<BranchTab> createState() => _BranchTabState();
}

class _BranchTabState extends State<BranchTab>
    with AutomaticKeepAliveClientMixin {
  final _mediaInfo = FlutterVideoInfo();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  static const int limit = 20;
  bool isLoading = false;
  bool myTopicsAdded = false;
  bool clubTopicsAdded = false;
  bool isSensitive = false;
  bool commentsDisabled = false;
  List<BoardPostItem> _items = [];
  List<String> _topics = [];
  List<AssetEntity> _assets = [];
  Future<void> _choose(Color primaryColor, Color accentColor) async {
    Navigator.pop(context);
    final int _maxAssets = limit - _items.length;
    const _english = const EnglishAssetPickerTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            maxAssets: _maxAssets,
            textDelegate: _english,
            selectedAssets: _assets,
            requestType: RequestType.common,
            themeColor: primaryColor));
    if (_result != null) {
      for (var result in _result) {
        var path = result.id;
        print(path);
        if (!_assets.any((element) => element == result)) _assets.add(result);
        if (!_items.any((element) => element.assetPath == path))
          _items.add(BoardPostItem(
              description: '',
              isInEdit: true,
              isText: false,
              mediaIsAsset: true,
              mediaURL: '',
              assetPath: path));
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _chooseCamera(Color primaryColor, Color accentColor) async {
    Navigator.pop(context);
    final AssetEntity? _result = await CameraPicker.pickFromCamera(context,
        pickerConfig: CameraPickerConfig(
            resolutionPreset: ResolutionPreset.high,
            enableRecording: true,
            maximumRecordingDuration: const Duration(seconds: 60),
            textDelegate: const EnglishCameraPickerTextDelegate(),
            theme: ThemeData(colorScheme: Theme.of(context).colorScheme)));
    var remaining = limit - _items.length;
    if (_result != null && remaining > 0) {
      var path = _result.id;
      print(path);
      _assets.add(_result);
      if (!_items.any((element) => element.assetPath == path))
        _items.add(BoardPostItem(
            description: '',
            isInEdit: true,
            isText: false,
            mediaIsAsset: true,
            mediaURL: '',
            assetPath: path));
      if (mounted) setState(() {});
    }
  }

  Widget buildAdder(
          String description, IconData? icon, void Function() handler) =>
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (isLoading) {
                } else {
                  handler();
                }
              },
              child: Chip(
                  deleteButtonTooltipMessage: '',
                  key: UniqueKey(),
                  onDeleted: () {
                    FocusScope.of(context).unfocus();
                    if (isLoading) {
                    } else {
                      handler();
                    }
                  },
                  deleteIcon: icon != null
                      ? Icon(icon,
                          color: Theme.of(context).colorScheme.secondary)
                      : null,
                  padding: const EdgeInsets.only(
                      left: 3.50, top: 3.50, bottom: 3.50, right: 5),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  label: Text(description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.normal)))));

  Widget buildTopicChip(
          String description, void Function(int) removeTopic, int index) =>
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Chip(
              deleteButtonTooltipMessage: '',
              onDeleted: isLoading ? () {} : () => removeTopic(index),
              deleteIcon: const Icon(Icons.close, color: Colors.red),
              padding: const EdgeInsets.all(3.5),
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text(description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal))));
  Widget buildTextField(String description, dynamic handler) => ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: 10,
          maxHeight: 2000,
          minWidth: 10,
          maxWidth: General.widthQuery(context)),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(children: [
              Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(description,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 17))),
              Positioned(
                  top: 1,
                  right: 1,
                  child: GestureDetector(
                      onTap: handler,
                      child:
                          const Icon(Icons.cancel_outlined, color: Colors.red)))
            ])
          ]));
  Widget _imageAssetWidget(AssetEntity asset) => Image(
      image: AssetEntityImageProvider(asset, isOriginal: false),
      fit: BoxFit.cover);

  Widget _videoAssetWidget(AssetEntity asset) => _imageAssetWidget(asset);

  Widget _assetWidgetBuilder(AssetEntity asset) {
    Widget? widget;
    switch (asset.type) {
      case AssetType.audio:
        break;
      case AssetType.video:
        widget = _videoAssetWidget(asset);
        break;
      case AssetType.image:
      case AssetType.other:
        widget = _imageAssetWidget(asset);
        break;
    }
    return widget!;
  }

  Widget _selectedAssetWidget(int index) {
    final AssetEntity asset = _assets.elementAt(index);
    return GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
          if (isLoading) {
          } else {
            final List<AssetEntity>? result =
                await AssetPickerViewer.pushToViewer(context,
                    currentIndex: index,
                    previewAssets: _assets,
                    themeData: AssetPicker.themeData(Colors.blue));
            if (result != null && result != _assets) {
              _assets = List<AssetEntity>.from(result);
              if (mounted) {
                setState(() {});
              }
            }
          }
        },
        child: RepaintBoundary(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: _assetWidgetBuilder(asset))));
  }

  Widget buildMediaItem(int index) => Container(
      height: 400,
      width: General.widthQuery(context),
      child: _selectedAssetWidget(index));
  void reset() => setState(() {
        isLoading = false;
        myTopicsAdded = false;
        clubTopicsAdded = false;
        _items.clear();
        _topics.clear();
        _assets.clear();
      });
  Widget buildListTile(bool isNsfwTile, double deviceWidth) => Container(
      width: deviceWidth,
      child: ListTile(
          minVerticalPadding: 0.0,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          horizontalTitleGap: 5.0,
          leading: Switch(
              inactiveTrackColor: Colors.red.shade200,
              activeTrackColor: Colors.red,
              activeColor: Colors.white,
              value: isNsfwTile ? isSensitive : commentsDisabled,
              onChanged: (value) {
                if (!isLoading) {
                  if (isNsfwTile)
                    setState(() {
                      isSensitive = value;
                    });
                  else
                    setState(() {
                      commentsDisabled = value;
                    });
                }
              }),
          title: GestureDetector(
              onTap: () {
                if (!isLoading) {
                  if (isNsfwTile)
                    setState(() {
                      isSensitive = !isSensitive;
                    });
                  else
                    setState(() {
                      commentsDisabled = !commentsDisabled;
                    });
                }
              },
              child: Text(
                  isNsfwTile ? 'Sensitive content' : 'Disable comments'))));

  _showDialog(IconData icon, Color iconColor, String title, String rule) {
    showDialog(
      context: context,
      builder: (_) => RegistrationDialog(
          icon: icon, iconColor: iconColor, title: title, rules: rule),
    );
  }

  Future<String> uploadFile(String postID, File file, dynamic flagNSFW) async {
    final String filePath = file.absolute.path;
    final name = filePath.split('/').last;
    final type = lookupMimeType(name);
    if (!kIsWeb) {
      if (type!.startsWith('image')) {
        var recognitions = await FlutterNsfw.getPhotoNSFWScore(filePath);
        if (recognitions > 0.759) {
          flagNSFW();
        }
      } else {
        final vidInfo = await _mediaInfo.getVideoInfo(filePath);
        final vidWidth = vidInfo!.width;
        final vidHeight = vidInfo.height;
        final recognitions = await FlutterNsfw.detectNSFWVideo(
            videoPath: filePath,
            frameWidth: vidWidth!,
            frameHeight: vidHeight!,
            nsfwThreshold: 0.759,
            durationPerFrame: 1000);
        if (recognitions) {
          flagNSFW();
        }
      }
    }
    final String ref = 'Posts/$postID/$name';
    var storageReference = storage.ref(ref);
    var uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() {
      storageReference = storage.ref(ref);
    });
    return await storageReference.getDownloadURL();
  }

  Future<Map<String, dynamic>> handleSingleItem(
      {required String username,
      required String postID,
      required WriteBatch batch,
      required ProfanityFilter filter,
      required BoardPostItem item,
      required DateTime rightNow,
      required dynamic flagSensitive,
      required dynamic flagProfanity}) async {
    String originalDescription = item.description;
    String assetPath = item.assetPath;
    String mediaURL = '';
    if (filter.hasProfanity(originalDescription)) {
      flagProfanity();
      originalDescription = filter.censor(originalDescription);
    }
    if (assetPath != '') {
      var currentAssetIndex =
          _assets.indexWhere((element) => element.id == assetPath);
      var currentAsset = _assets[currentAssetIndex];
      var file = await currentAsset.file;
      String serveruploadFile = await uploadFile(postID, file!, flagSensitive);
      mediaURL = serveruploadFile;
    }
    Map<String, dynamic> serverListItem = {
      'isText': originalDescription != '',
      'description': originalDescription,
      'mediaURL': mediaURL
    };
    return serverListItem;
  }

  Future<List<Map<String, dynamic>>> handleItems(
      {required String username,
      required String postID,
      required WriteBatch batch,
      required ProfanityFilter filter,
      required DateTime rightNow,
      required dynamic flagSensitive,
      required dynamic flagProfanity}) async {
    List<Map<String, dynamic>> backendItems = [];
    for (var item in _items) {
      Map<String, dynamic> backendItem = await handleSingleItem(
          username: username,
          postID: postID,
          batch: batch,
          filter: filter,
          item: item,
          rightNow: rightNow,
          flagSensitive: flagSensitive,
          flagProfanity: flagProfanity);
      backendItems.add(backendItem);
    }
    return backendItems;
  }

  Future<void> _addPost(
      {required String username,
      required List<String> formTopics,
      required bool commentsDisabled,
      required void Function(String) profileAddPost,
      required String clubName,
      required int maxDailyPosts}) async {
    bool _hasSensitive = false;
    bool _hasProfanity = false;
    final _filter = ProfanityFilter();
    const duration = const Duration(seconds: 60);
    bool invalidVid = _assets.any((asset) => asset.videoDuration > duration);
    void flagSensitive() => _hasSensitive = true;
    void flagProfanity() => _hasProfanity = true;

    final DateTime rightNow = DateTime.now();
    final String postID = General.generateContentID(
        username: username,
        clubName: clubName,
        isPost: false,
        isClubPost: true,
        isCollection: false,
        isFlare: false,
        isComment: false,
        isReply: false,
        isFlareComment: false,
        isFlareReply: false);
    Future<void> uploadTopic(String topic) async {
      var _batch = firestore.batch();
      final targetTopicDoc = firestore.collection('Topics').doc(topic);
      final targetPostDoc = targetTopicDoc.collection('posts').doc(postID);
      _batch.set(targetPostDoc, {'date': rightNow, 'clubName': ''});
      _batch.set(targetTopicDoc, {'count': FieldValue.increment(1)},
          SetOptions(merge: true));
      return _batch.commit();
    }

    Future<void> addTopicPost(List<String> topics) async {
      for (var topic in topics) {
        await uploadTopic(topic);
      }
    }

    var invalidSizeVid = [];
    var invalidSizeIMG = [];
    for (var asset in _assets) {
      if (asset.type == AssetType.video) {
        var file = await asset.file;
        var size = file!.lengthSync();
        if (size > 150000000) {
          invalidSizeVid.insert(0, file);
        }
      } else {
        var file = await asset.file;
        var size = file!.lengthSync();
        if (size > 30000000) {
          invalidSizeIMG.insert(0, file);
        }
      }
    }
    setState(() {});
    if (invalidSizeVid.isNotEmpty || invalidSizeIMG.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
      EasyLoading.dismiss();
      if (invalidSizeVid.isNotEmpty) {
        _showDialog(Icons.info_outline, Colors.blue, 'Notice',
            "Videos can be up to 150 MB in size");
      }
      if (invalidSizeIMG.isNotEmpty) {
        _showDialog(Icons.info_outline, Colors.blue, 'Notice',
            "Images can be up to 30 MB in size");
      }
    } else {
      final DateTime _rightNow = DateTime.now();
      final last24hour = _rightNow.subtract(Duration(minutes: 1440));
      final List<String> last24hrs = [];
      final getLast51 = await firestore
          .collection('Posts')
          .where('poster', isEqualTo: username)
          .where('clubName', isEqualTo: clubName)
          .orderBy('date', descending: true)
          .limit(maxDailyPosts + 1)
          .get();
      final myPostIDs = getLast51.docs;
      for (var id in myPostIDs) {
        final post = await firestore.collection('Posts').doc(id.id).get();
        if (post.exists) {
          final date = post.get('date').toDate();
          Duration diff = date.difference(last24hour);
          if (diff.inMinutes >= 0 && diff.inMinutes <= 1440) {
            last24hrs.add(id.id);
          } else {}
        }
      }
      if (last24hrs.length >= maxDailyPosts) {
        setState(() {
          isLoading = false;
        });
        EasyLoading.dismiss();
        _showDialog(
          Icons.info_outline,
          Colors.blue,
          'Notice',
          "Members can publish up to ${maxDailyPosts.toString()} posts daily",
        );
      } else {
        if (invalidVid) {
          setState(() {
            isLoading = false;
          });
          _showDialog(Icons.warning, Colors.red, 'Invalid media',
              "Videos can be up to 1 minute long");
        } else {
          if (!kIsWeb) {
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
          }
          var batch = firestore.batch();
          final myUserDoc = firestore.collection('Users').doc(username);
          final myPostDoc = myUserDoc.collection('Posts').doc(postID);
          final thisClubDoc = firestore.collection('Clubs').doc(clubName);
          final clubPostsDoc = thisClubDoc.collection('Posts').doc(postID);

          final thePostDoc = firestore.collection('Posts').doc(postID);
          final reviewalDoc = firestore.collection('Review').doc(postID);
          if (_hasProfanity) {
            batch.update(firestore.doc('Profanity/Posts'),
                {'numOfProfanity': FieldValue.increment(1)});
            batch.set(firestore.collection('Profanity/Posts/Posts').doc(), {
              'postID': postID,
              'user': username,
              'original': '',
              'date': rightNow,
            });
          }
          if (_hasSensitive) {
            batch.set(
                reviewalDoc,
                {
                  'poster': username,
                  'date': rightNow,
                  'ID': postID,
                  'collectionID': '',
                  'flareID': '',
                  'clubName': clubName,
                  'isPost': true,
                  'isClubPost': true,
                  'isFlare': false,
                  'isComment': false,
                  'isFlareComment': false,
                  'isReply': false,
                  'isFlareReply': false,
                  'isProfileBanner': false,
                  'isClubBanner': false,
                  'flarePoster': false,
                  'profile': '',
                  'commentID': '',
                  'replyID': '',
                },
                SetOptions(merge: true));
          }
          if (_topics.isNotEmpty) await addTopicPost(_topics);
          List<Map<String, dynamic>> theITtems = await handleItems(
              username: username,
              postID: postID,
              batch: batch,
              filter: _filter,
              rightNow: rightNow,
              flagSensitive: flagSensitive,
              flagProfanity: flagProfanity);
          batch.set(thePostDoc, {
            'poster': username,
            'description': '',
            'sensitive': (isSensitive || _hasSensitive) ? true : false,
            'commentsDisabled': commentsDisabled,
            'isEdited': false,
            'topics': formTopics,
            'topicCount': formTopics.length,
            'imgUrls': [],
            'likes': 0,
            'comments': 0,
            'date': rightNow,
            'editDate': rightNow,
            'location': '',
            'locationName': '',
            'clubName': clubName,
            'type': 'branch',
            'items': theITtems,
            'backgroundColor': '',
            'gradientColor': '',
          });
          batch.set(clubPostsDoc, {'date': rightNow});
          batch.update(thisClubDoc, {'numOfPosts': FieldValue.increment(1)});
          batch.update(myUserDoc, {'numOfPosts': FieldValue.increment(1)});
          batch.set(myPostDoc, {'date': rightNow});
          return batch.commit().then((_) async {
            Map<String, dynamic> fields = {'posts': FieldValue.increment(1)};
            Map<String, dynamic> docFields = {'date': _rightNow};
            General.updateControl(
                fields: fields,
                myUsername: username,
                collectionName: 'posts',
                docID: '$postID',
                docFields: docFields);
            EasyLoading.showSuccess('Published',
                dismissOnTap: true, duration: const Duration(seconds: 1));
            profileAddPost(postID);
            reset();
          }).catchError((error) {
            EasyLoading.showError('Failed',
                dismissOnTap: true, duration: const Duration(seconds: 2));
            setState(() => isLoading = false);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myProfile = context.read<MyProfile>();
    final profileAddPost =
        Provider.of<MyProfile>(context, listen: false).addPost;
    final clubHelper = Provider.of<ClubProvider>(context, listen: false);
    final String clubName = clubHelper.clubName;
    final int maxDailyPosts = clubHelper.maxDailyPostsByMembers;
    final List<String> _clubTopics = clubHelper.clubTopics;
    final myUsername = myProfile.getUsername;
    final _deviceWidth = General.widthQuery(context);
    final theme = Theme.of(context);
    int _length = _items.length;
    final bool allowed = _length < limit;
    final systemPrimary = theme.colorScheme.primary;
    final systemSecondary = theme.colorScheme.secondary;
    final List<String> myTopics = Provider.of<MyProfile>(context).getTopics;
    const _heightBox = SizedBox(height: 15.0);
    const _side = BorderSide(color: Colors.white, width: 1);
    void _removeTopic(int idx) => setState(() => _topics.removeAt(idx));
    void _addTopic(String topic) => setState(() => _topics.add(topic));
    void _addMyTopics() {
      for (var topic in myTopics)
        if (!_topics.contains(topic)) _topics.add(topic);
      setState(() => myTopicsAdded = true);
    }

    void _addClubTopics() {
      for (var topic in _clubTopics)
        if (!_topics.contains(topic)) _topics.add(topic);
      setState(() => clubTopicsAdded = true);
    }

    super.build(context);
    return Container(
        child: Column(children: <Widget>[
      Container(
          height: 50,
          width: _deviceWidth,
          child: Noglow(
              child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                if (allowed)
                  buildAdder('Add text', Icons.note_outlined, () {
                    void handler(String desc) {
                      final noteItem = BoardPostItem(
                          isText: true,
                          mediaIsAsset: false,
                          isInEdit: true,
                          description: desc,
                          mediaURL: '',
                          assetPath: '');
                      setState(() => _items.add(noteItem));
                    }

                    var args = NoteScreenArgs(
                        handler: handler,
                        preexistingText: null,
                        editHandler: (_) {},
                        isBranch: true);
                    Navigator.pushNamed(context, RouteGenerator.noteScreen,
                        arguments: args);
                  }),
                if (allowed && !kIsWeb)
                  buildAdder('Add media', Icons.image_outlined, () {
                    FocusScope.of(context).unfocus();
                    if (isLoading) {
                    } else {
                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(31.0)),
                          backgroundColor: Colors.white,
                          builder: (_) {
                            final ListTile _choosephotoGallery = ListTile(
                                horizontalTitleGap: 5.0,
                                leading: const Icon(Icons.perm_media,
                                    color: Colors.black),
                                title: const Text('Gallery',
                                    style: TextStyle(color: Colors.black)),
                                onTap: () =>
                                    _choose(systemPrimary, systemSecondary));
                            final ListTile _camera = ListTile(
                                horizontalTitleGap: 5.0,
                                leading: const Icon(Icons.camera_alt,
                                    color: Colors.black),
                                title: const Text('Camera',
                                    style: TextStyle(color: Colors.black)),
                                onTap: () {
                                  if (allowed)
                                    _chooseCamera(
                                        systemPrimary, systemSecondary);
                                });
                            final Column _choices = Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  if (allowed && !kIsWeb) _camera,
                                  _choosephotoGallery
                                ]);
                            final SizedBox _box = SizedBox(child: _choices);
                            return _box;
                          });
                    }
                  }),
                buildAdder('New topic', Icons.add, () {
                  if (isLoading) {
                  } else {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(31.0)),
                        backgroundColor: Colors.white,
                        builder: (_) {
                          return AddTopic(
                              _addTopic, _topics, false, false, false);
                        });
                  }
                }),
                if (!myTopicsAdded)
                  buildAdder('Add my topics', Icons.add, _addMyTopics),
                if (!clubTopicsAdded)
                  buildAdder('Add club topics', Icons.add, _addClubTopics)
              ]))),
      if (_items.isNotEmpty) buildListTile(true, _deviceWidth),
      if (_items.isNotEmpty) buildListTile(false, _deviceWidth),
      Expanded(
        child: Container(
            decoration:
                BoxDecoration(border: const Border(bottom: _side, top: _side)),
            child: Noglow(
                child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    scrollDirection: Axis.vertical,
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => _heightBox,
                    itemBuilder: (ctx, idx) {
                      var current = _items[idx];
                      var isText = current.isText;
                      var currentAssetPath = isText ? '' : current.assetPath;
                      var currentAssetIndex = isText
                          ? 0
                          : _assets.indexWhere(
                              (element) => element.id == currentAssetPath);
                      return isText
                          ? GestureDetector(
                              onTap: () {
                                if (!isLoading) {
                                  void editHandler(String desc) {
                                    final noteItem = BoardPostItem(
                                        isText: true,
                                        mediaIsAsset: false,
                                        isInEdit: true,
                                        description: desc,
                                        mediaURL: '',
                                        assetPath: '');
                                    _items.remove(current);
                                    _items.insert(idx, noteItem);
                                    setState(() {});
                                  }

                                  var args = NoteScreenArgs(
                                      handler: (_) {},
                                      preexistingText: current.description,
                                      editHandler: editHandler,
                                      isBranch: true);
                                  Navigator.pushNamed(
                                      context, RouteGenerator.noteScreen,
                                      arguments: args);
                                }
                              },
                              child: buildTextField(current.description, () {
                                FocusScope.of(context).unfocus();
                                if (isLoading) {
                                } else {
                                  _items.remove(current);
                                  setState(() {});
                                }
                              }),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Stack(children: [
                                    _selectedAssetWidget(currentAssetIndex),
                                    Positioned(
                                        top: 3,
                                        right: 2,
                                        child: GestureDetector(
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                              if (isLoading) {
                                              } else {
                                                _items.remove(current);
                                                _assets.removeAt(
                                                    currentAssetIndex);
                                                setState(() {});
                                              }
                                            },
                                            child: Icon(Icons.close,
                                                color:
                                                    Colors.redAccent.shade400)))
                                  ]),
                                ]);
                    }))),
      ),
      if (_topics.isNotEmpty)
        Container(
            height: 50,
            width: _deviceWidth,
            child: Noglow(
                child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                  ..._topics.map((e) {
                    var index = _topics.indexOf(e);
                    return buildTopicChip(e, _removeTopic, index);
                  }).toList()
                ]))),
      Container(
          color: Colors.transparent,
          margin: const EdgeInsets.symmetric(horizontal: 40.0),
          child: ElevatedButton(
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all<double?>(0.0),
                  shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0))),
                  backgroundColor: MaterialStateProperty.all<Color?>(
                      Theme.of(context).colorScheme.primary),
                  shadowColor: MaterialStateProperty.all<Color?>(
                      Theme.of(context).colorScheme.primary)),
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (!isLoading && _items.isNotEmpty) {
                  setState(() => isLoading = !isLoading);
                  _addPost(
                      username: myUsername,
                      formTopics: _topics,
                      commentsDisabled: commentsDisabled,
                      profileAddPost: profileAddPost,
                      clubName: clubName,
                      maxDailyPosts: maxDailyPosts);
                }
              },
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: isLoading
                          ? SizedBox(
                              height: 35,
                              width: 35,
                              child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  strokeWidth: 1.50))
                          : Text('Publish',
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 30.0))))))
    ]));
  }

  @override
  bool get wantKeepAlive => true;
}
