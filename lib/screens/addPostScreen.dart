import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:mime/mime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/posterProfile.dart';
import '../providers/addPostScreenState.dart';
import '../providers/feedProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/addTopic.dart';
import '../widgets/topicChip.dart';
import '../widgets/registrationDialog.dart';

class NewPost extends StatefulWidget {
  const NewPost();
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  bool isLoading = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  late final GlobalKey<FormState> _key;
  late final TextEditingController _descriptionController;
  late final ScrollController scrollController;
  final _mediaInfo = FlutterVideoInfo();
  List<AssetEntity> assets = [];
  List<File> files = [];
  bool hasNSFW = false;
  String? _validateDescription(String? value) {
    if ((value!.isEmpty ||
            value.replaceAll(' ', '') == '' ||
            value.trim() == '') &&
        assets.isEmpty) {
      return 'Please provide a description or media';
    }
    if (value.length > 2500) {
      return 'Descriptions can be between 1-2500 characters';
    }
    if ((value.isEmpty ||
            value.replaceAll(' ', '') == '' ||
            value.trim() == '') &&
        assets.isNotEmpty) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _key = GlobalKey<FormState>();
    scrollController = ScrollController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _descriptionController.dispose();
  }

  Widget _imageAssetWidget(AssetEntity asset) {
    return Image(
      image: AssetEntityImageProvider(asset, isOriginal: false),
      fit: BoxFit.cover,
    );
  }

  Widget _videoAssetWidget(AssetEntity asset) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: _imageAssetWidget(asset)),
        ColoredBox(
          color: Colors.white38,
          child: Center(
            child: Icon(
              Icons.play_arrow,
              color: Colors.black,
              size: 24.0,
            ),
          ),
        ),
      ],
    );
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
    const int _maxAssets = 10;
    final _english = EnglishTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(
      context,
      maxAssets: _maxAssets,
      textDelegate: _english,
      selectedAssets: assets,
      requestType: RequestType.common,
      themeColor: primaryColor,
    );
    if (_result != null) {
      assets = List<AssetEntity>.from(_result);

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

  String _generatePostId(String _username) {
    final DateTime _rightNowUTC = DateTime.now().toUtc();
    final String _postDate = '${DateFormat('dMyHmsS').format(_rightNowUTC)}';
    final String _theID = '$_username-$_postDate';
    return _theID;
  }

  Future<File> getFile(AssetEntity asset) async {
    final file = await asset.originFile;
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
    if (type!.startsWith('image')) {
      var recognitions = await FlutterNsfw.getPhotoNSFWScore(filePath);
      if (recognitions > 0.61) {
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
        nsfwThreshold: 0.61,
        durationPerFrame: 1000,
      );
      if (recognitions) {
        setState(() {
          hasNSFW = true;
        });
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
    required String myImgUrl,
    required String myBio,
    required int myNumOfLinks,
    required int myNumOfLinkedTos,
    required myVisibility,
    required List<String> formTopics,
    required List<String> myPostIDs,
    required bool containsSensitiveContent,
    required void Function() clear,
    required void Function() empty,
    required dynamic addPost,
    required void Function(String) profileAddPost,
  }) {
    final String postID = _generatePostId(username);
    final DateTime rightNow = DateTime.now();
    final FullHelper instance = FullHelper();
    bool invalidVid =
        assets.any((asset) => asset.videoDuration > Duration(seconds: 60));

    bool valid = _key.currentState!.validate() && !invalidVid;
    bool canSubmit = valid;

    final PosterProfile myPosterProfile = PosterProfile(
        getUsername: username,
        getProfileImage: myImgUrl,
        getBio: myBio,
        getNumberOflinks: myNumOfLinks,
        getNumberOfLinkedTos: myNumOfLinkedTos,
        getVisibility: myVisibility);

    void _submitPost(List<String> urls) {
      addPost(
        instance: instance,
        myPosterProfile: myPosterProfile,
        myUsername: username,
        postId: postID,
        description: _descriptionController.text,
        postedDate: rightNow,
        images: urls,
        topics: [...formTopics],
        sensitiveContent:
            (assets.isNotEmpty) ? containsSensitiveContent : false,
      );

      profileAddPost(postID);
      _descriptionController.clear();
      formTopics.clear();
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
            "Videos can be up to 150 MB",
          );
        }
        if (invalidSizeIMG.isNotEmpty) {
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "Images can be up to 30 MB",
          );
        }
      } else {
        final DateTime _rightNow = DateTime.now();
        final last24hour = _rightNow.subtract(Duration(minutes: 1440));
        final List<String> last24hrs = [];
        for (var id in myPostIDs) {
          final post = await firestore.collection('Posts').doc(id).get();
          if (post.exists) {
            final date = post.get('date').toDate();
            Duration diff = date.difference(last24hour);
            if (diff.inMinutes >= 0 && diff.inMinutes <= 1440) {
              last24hrs.add(id);
            } else {}
          }
        }
        if (last24hrs.length >= 50) {
          setState(() {
            isLoading = false;
          });
          EasyLoading.dismiss();
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "Users can publish 50 posts daily",
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
          var batch = firestore.batch();
          final myUserDoc = firestore.collection('Users').doc(username);
          final myPostDoc = myUserDoc.collection('Posts').doc(postID);
          final thePostDoc = firestore.collection('Posts').doc(postID);
          final reviewalDoc = firestore.collection('Review').doc(postID);
          Future<void> uploadTopic(String topic) async {
            final targetTopicDoc = firestore.collection('Topics').doc(topic);
            final getTarget =
                await firestore.collection('Topics').doc(topic).get();
            final targetPostDoc =
                targetTopicDoc.collection('posts').doc(postID);
            batch.set(targetPostDoc, {'date': rightNow});
            if (getTarget.exists)
              batch.update(targetTopicDoc, {'count': FieldValue.increment(1)});
            if (!getTarget.exists)
              batch.set(targetTopicDoc, {'count': FieldValue.increment(1)});
          }

          Future<void> addTopicPost(List<String> topics) async {
            for (var topic in topics) {
              await uploadTopic(topic);
            }
          }

          final fileList = await getFiles(assets);
          final fileUrls = await uploadFiles(postID, fileList);
          await addTopicPost(formTopics);
          batch.set(thePostDoc, {
            'poster': username,
            'description': _descriptionController.text,
            'sensitive': (assets.isNotEmpty)
                ? (containsSensitiveContent || hasNSFW)
                    ? true
                    : false
                : false,
            'topics': formTopics,
            'topicCount': formTopics.length,
            'imgUrls': fileUrls,
            'likes': 0,
            'comments': 0,
            'date': rightNow,
          });
          batch.update(myUserDoc, {'numOfPosts': FieldValue.increment(1)});
          batch.set(myPostDoc, {'date': rightNow});
          return batch.commit().then((_) async {
            if (hasNSFW) {
              reviewalDoc.set({'date': rightNow}).then((value) {
                EasyLoading.showSuccess('Published',
                    dismissOnTap: true, duration: const Duration(seconds: 2));
                _submitPost(fileUrls);
                setState(() {
                  isLoading = false;
                  assets.clear();
                });
              }).catchError((onError) {
                EasyLoading.showSuccess('Published',
                    dismissOnTap: true, duration: const Duration(seconds: 2));
                _submitPost(fileUrls);
                setState(() {
                  isLoading = false;
                  assets.clear();
                });
              });
            } else {
              EasyLoading.showSuccess('Published',
                  dismissOnTap: true, duration: const Duration(seconds: 2));
              _submitPost(fileUrls);
              setState(() {
                isLoading = false;
                assets.clear();
              });
            }
          }).catchError((error) {
            EasyLoading.showError(
              'Failed',
              dismissOnTap: true,
              duration: const Duration(seconds: 2),
            );
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
        _showDialog(
          Icons.warning,
          Colors.red,
          'Invalid media',
          "Videos can't be longer than 1 minute",
        );
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final myProfile = context.read<MyProfile>();
    final List<String> _myTopics = myProfile.getTopics;
    final List<String> _myPostIDs = myProfile.getPostIDs;
    final addPost = Provider.of<FeedProvider>(context, listen: false).addPost;
    final profileAddPost =
        Provider.of<MyProfile>(context, listen: false).addPost;
    final Color _primarySwatch = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final _addPostState = Provider.of<NewPostHelper>(context);
    final _postStateNoListen = context.read<NewPostHelper>();
    final bool containsSensitiveContent = _addPostState.containsSensitive;
    final List<String> _formTopics = _addPostState.formTopics;
    final void Function(String) _addTopic = _postStateNoListen.addTopic;
    final void Function(int) _removeTopic = _postStateNoListen.removeTopic;
    final void Function() clear = _postStateNoListen.clear;
    final void Function(List<String>) addMyTopics =
        _postStateNoListen.addMyTopics;
    final void Function() empty =
        Provider.of<NewPostHelper>(context, listen: false).empty;
    final String _username = myProfile.getUsername;
    final String _myImgUrl = myProfile.getProfileImage;
    final String _myBio = myProfile.getBio;
    final int _myNumOfLinks = myProfile.getNumberOflinks;
    final int _myNumOfLinkedTos = myProfile.getNumberOfLinkedTos;
    final _myVisibility = myProfile.getVisibility;

    const _heightBox = SizedBox(
      height: 15.0,
    );
    final Widget _description = NotificationListener<OverscrollNotification>(
      onNotification: (OverscrollNotification value) {
        if (value.overscroll < 0 &&
            scrollController.offset + value.overscroll <= 0) {
          if (scrollController.offset != 0) scrollController.jumpTo(0);
          return true;
        }
        if (scrollController.offset + value.overscroll >=
            scrollController.position.maxScrollExtent) {
          if (scrollController.offset !=
              scrollController.position.maxScrollExtent)
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          return true;
        }
        scrollController.jumpTo(scrollController.offset + value.overscroll);
        return true;
      },
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        controller: _descriptionController,
        validator: _validateDescription,
        cursorColor: _primarySwatch,
        minLines: 5,
        maxLines: 30,
        maxLength: 2500,
        decoration: InputDecoration(
          hintText: 'What would you like to share?',
          counterText: '',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
    final Widget _containsSensitive = ListTile(
      minVerticalPadding: 0.0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      horizontalTitleGap: 5.0,
      leading: Switch(
        inactiveTrackColor: Colors.red.shade200,
        activeTrackColor: Colors.red,
        activeColor: Colors.white,
        value: containsSensitiveContent,
        onChanged: (value) {
          if (isLoading) {
          } else {
            Provider.of<NewPostHelper>(context, listen: false)
                .changeSensitivity(value);
          }
        },
      ),
      title: GestureDetector(
        onTap: () {
          if (isLoading) {
          } else {
            Provider.of<NewPostHelper>(context, listen: false)
                .toggleSensitivity();
          }
        },
        child: Text(
          'Sensitive content',
        ),
      ),
    );
    final Container _media = Container(
      height: 400.0,
      child: NotificationListener<OverscrollNotification>(
        onNotification: (OverscrollNotification value) {
          if (value.overscroll < 0 &&
              scrollController.offset + value.overscroll <= 0) {
            if (scrollController.offset != 0) scrollController.jumpTo(0);
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
          scrollController.jumpTo(scrollController.offset + value.overscroll);
          return true;
        },
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (assets.isEmpty)
              GestureDetector(
                onTap: () {
                  if (isLoading) {
                  } else {
                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            31.0,
                          ),
                        ),
                        backgroundColor: Colors.white,
                        builder: (_) {
                          final ListTile _choosephotoGallery = ListTile(
                            horizontalTitleGap: 5.0,
                            leading: const Icon(
                              Icons.perm_media,
                              color: Colors.black,
                            ),
                            title: const Text(
                              'Gallery',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onTap: () => _choose(_primarySwatch),
                          );

                          final Column _choices = Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _choosephotoGallery,
                            ],
                          );

                          final SizedBox _box = SizedBox(
                            child: _choices,
                          );
                          return _box;
                        });
                  }
                },
                child: Container(
                  height: 400.0,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: Center(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.perm_media,
                            color: Colors.white,
                            size: 65.0,
                          ),
                          Text(
                            'Upload media',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (assets.isNotEmpty)
              Wrap(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (isLoading) {
                      } else {
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                31.0,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            builder: (_) {
                              final ListTile _choosephotoGallery = ListTile(
                                horizontalTitleGap: 5.0,
                                leading: const Icon(
                                  Icons.perm_media,
                                  color: Colors.black,
                                ),
                                title: const Text(
                                  'Gallery',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                onTap: () => _choose(_primarySwatch),
                              );

                              final Column _choices = Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  _choosephotoGallery,
                                ],
                              );

                              final SizedBox _box = SizedBox(
                                child: _choices,
                              );
                              return _box;
                            });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 65.0,
                              ),
                              Text(
                                'Add media',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...assets.map((media) {
                    final int _currentIndex = assets.indexOf(media);
                    return Container(
                      height: 100.0,
                      width: 100.0,
                      margin: const EdgeInsets.all(5.0),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            key: UniqueKey(),
                            width: 100.0,
                            height: 100.0,
                            child: _selectedAssetWidget(
                              _currentIndex,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                if (isLoading) {
                                } else {
                                  _removeMedia(_currentIndex);
                                }
                              },
                              child: Icon(
                                Icons.cancel,
                                color: Colors.redAccent.shade400,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList()
                ],
              ),
          ],
        ),
      ),
    );
    final Container _topicsList = Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade400,
          ),
          bottom: BorderSide(
            color: Colors.grey.shade400,
          ),
        ),
      ),
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            child: GestureDetector(
              onTap: () {
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
                        return AddTopic(_addTopic, _formTopics, false, true);
                      });
                }
              },
              child: TopicChip(
                'New topic',
                Icon(Icons.add, color: _accentColor),
                () {
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
                          return AddTopic(_addTopic, _formTopics, false, true);
                        });
                  }
                },
                _accentColor,
                FontWeight.bold,
              ),
            ),
          ),
          if (_formTopics.isEmpty)
            Container(
              child: GestureDetector(
                onTap: () {
                  if (isLoading) {
                  } else {
                    addMyTopics(_myTopics);
                  }
                },
                child: TopicChip(
                  'add my topics',
                  Icon(Icons.add, color: _accentColor),
                  () {
                    if (isLoading) {
                    } else {
                      addMyTopics(_myTopics);
                    }
                  },
                  _accentColor,
                  FontWeight.bold,
                ),
              ),
            ),
          ..._formTopics.map((topic) {
            int idx = _formTopics.indexOf(topic);
            return TopicChip(
                topic,
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ), () {
              if (isLoading) {
              } else {
                _removeTopic(idx);
              }
            }, Colors.white, FontWeight.normal);
          }).toList()
        ],
      ),
    );

    final Widget _publish = Container(
      height: 55.0,
      width: 50.0,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all<double?>(0.0),
          shape: MaterialStateProperty.all<OutlinedBorder?>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color?>(_primarySwatch),
          shadowColor: MaterialStateProperty.all<Color?>(_primarySwatch),
        ),
        onPressed: () {
          _addPost(
            username: _username,
            myImgUrl: _myImgUrl,
            myBio: _myBio,
            myNumOfLinks: _myNumOfLinks,
            myNumOfLinkedTos: _myNumOfLinkedTos,
            myVisibility: _myVisibility,
            formTopics: _formTopics,
            containsSensitiveContent: containsSensitiveContent,
            clear: clear,
            empty: empty,
            addPost: addPost,
            profileAddPost: profileAddPost,
            myPostIDs: _myPostIDs,
          );
        },
        child: Center(
          child: Text(
            'Publish',
            style: TextStyle(
              color: _accentColor,
              fontSize: 30.0,
            ),
          ),
        ),
      ),
    );

    final Widget _listView = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _description,
        _heightBox,
        _media,
        if (assets.isNotEmpty) _containsSensitive,
        _heightBox,
        _topicsList,
        _heightBox,
        _publish,
      ],
    );
    return Form(
      key: _key,
      child: SizedBox(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return false;
          },
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(top: _deviceHeight * 0.05, bottom: 50.0),
            controller: scrollController,
            children: <Widget>[_listView],
          ),
        ),
      ),
    );
  }
}
