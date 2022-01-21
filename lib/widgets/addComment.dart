import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../models/miniProfile.dart';
import '../providers/commentProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/myProfileProvider.dart';
import 'profileImage.dart';
import 'registrationDialog.dart';

class AddComment extends StatefulWidget {
  const AddComment();
  @override
  _AddCommentState createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late FirebaseStorage storage = FirebaseStorage.instance;
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _key;
  bool isLoading = false;
  bool containsMedia = false;
  String _myImgUrl = 'none';
  List<AssetEntity>? assets;
  String? _validateComment(String? value) {
    if (value!.isEmpty ||
        value.replaceAll(' ', '') == '' ||
        value.trim() == '') {
      return 'Please write a comment';
    }
    if (value.length > 1000) {
      return 'Comments can be between 0-1500 characters long';
    }
    return null;
  }

  Widget _imageAssetWidget(AssetEntity asset) {
    return Image(
      image: AssetEntityImageProvider(asset, isOriginal: false),
      fit: BoxFit.cover,
    );
  }

  Widget _assetWidgetBuilder(AssetEntity asset) {
    Widget? widget;
    switch (asset.type) {
      case AssetType.audio:
        break;
      case AssetType.video:
        break;
      case AssetType.image:
      case AssetType.other:
        widget = _imageAssetWidget(asset);
        break;
    }
    return widget!;
  }

  void _removeMedia() {
    setState(() {
      containsMedia = false;
      assets!.removeAt(0);
    });
  }

  Widget _selectedAssetWidget() {
    final AssetEntity asset = assets!.elementAt(0);
    return GestureDetector(
      onTap: () async {
        if (isLoading) {
        } else {
          final List<AssetEntity>? result =
              await AssetPickerViewer.pushToViewer(
            context,
            currentIndex: 0,
            previewAssets: assets!,
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

  Future<void> _choose(String myUsername) async {
    String _generateCommentId() {
      final DateTime _rightNow = DateTime.now();
      final DateTime _rightNowUTC = _rightNow.toUtc();
      final String _commentDate =
          '${DateFormat('dMyHmsS').format(_rightNowUTC)}';
      final String _theID = '$_commentDate';
      return _theID;
    }

    final String iD = _generateCommentId();

    const int _maxAssets = 1;
    final _english = EnglishTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(
      context,
      maxAssets: _maxAssets,
      textDelegate: _english,
      selectedAssets: assets,
      requestType: RequestType.image,
    );
    if (_result != null) {
      assets = List<AssetEntity>.from(_result);
      _myImgUrl = 'Comments/$myUsername/$iD';
      containsMedia = true;
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

  Future<void> addComment(
    String posterUsername,
    String postID,
    String comment,
    String _username,
    String _myUserImg,
    void Function(Comment) providerAddComment,
  ) async {
    setState(() {
      isLoading = true;
    });
    final currentPostComments =
        firestore.collection('Posts').doc(postID).collection('comments');
    final myUserComments =
        firestore.collection('Users').doc(_username).collection('My Comments');
    var batch = firestore.batch();
    final DateTime _rightNow = DateTime.now();
    final DateTime _rightNowUTC = _rightNow.toUtc();
    String _generateCommentId() {
      final String _commentDate =
          '${DateFormat('dMyHmsS').format(_rightNowUTC)}';
      final String _theID = '$_username-$_commentDate';
      return _theID;
    }

    final FullCommentHelper _instance = FullCommentHelper();

    final String commentID = _generateCommentId();
    final _myMiniProfile = MiniProfile(username: _username, imgUrl: _myUserImg);

    final lasthour = _rightNow.subtract(const Duration(minutes: 60));
    final myComments = await currentPostComments
        .where('commenter', isEqualTo: _username)
        .get();
    final myCommentsHour = myComments.docs;
    var lastHourComments = [];
    for (var comment in myCommentsHour) {
      var commentDate = comment.get('date').toDate();
      Duration diff = commentDate.difference(lasthour);
      if (diff.inMinutes >= 0 && diff.inMinutes <= 60) {
        lastHourComments.add(comment);
      } else {}
    }

    if (lastHourComments.length >= 30) {
      setState(() {
        isLoading = false;
      });
      _showDialog(
        Icons.info_outline,
        Colors.blue,
        'Notice',
        "Users can add up to 30 comments hourly to a post",
      );
    } else {
      final targetUser =
          await firestore.collection('Users').doc(posterUsername).get();
      final token = targetUser.get('fcm');
      if (containsMedia) {
        bool hasNSFW = false;
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
        File? imageFile = await assets![0].originFile;
        final int fileSize = imageFile!.lengthSync();
        if (fileSize > 15000000) {
          setState(() {
            isLoading = false;
          });
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "Media can be up to 15 MB",
          );
        } else {
          final myComment = currentPostComments.doc(commentID);
          final thisPost = firestore.collection('Posts').doc(postID);
          final String filePath = imageFile.absolute.path;
          var recognitions = await FlutterNsfw.getPhotoNSFWScore(filePath);
          if (recognitions > 0.55) {
            setState(() {
              hasNSFW = true;
            });
          }
          await storage.ref(_myImgUrl).putFile(imageFile).then((value) async {
            final String downloadUrl =
                await storage.ref(_myImgUrl).getDownloadURL();
            final Comment _theComment = Comment(
              comment: comment,
              commenter: _myMiniProfile,
              commentDate: _rightNow,
              commentID: commentID,
              numOfReplies: 0,
              instance: _instance,
              containsMedia: containsMedia,
              downloadURL: downloadUrl,
              numOfLikes: 0,
              isLiked: false,
              hasNSFW: hasNSFW,
            );
            batch.set(myComment, {
              'commenter': _username,
              'description': comment,
              'replyCount': 0,
              'likeCount': 0,
              'date': _rightNow,
              'containsMedia': true,
              'downloadURL': downloadUrl,
              'hasNSFW': hasNSFW,
            });
            batch.set(myUserComments.doc(commentID), {
              'post ID': postID,
              'commenter': _username,
              'description': comment,
              'date': _rightNow,
              'containsMedia': true,
              'downloadURL': downloadUrl,
              'hasNSFW': hasNSFW,
            });
            batch.update(thisPost, {'comments': FieldValue.increment(1)});
            return batch.commit().then((value) async {
              var secondBatch = firestore.batch();
              final otherCommentsNotifs = firestore
                  .collection('Users')
                  .doc(posterUsername)
                  .collection('PostCommentsNotifs');

              if (targetUser.data()!.containsKey('AllowComments')) {
                final allowComments = targetUser.get('AllowComments');
                if (allowComments) {
                  if (posterUsername != _username) {
                    secondBatch.set(otherCommentsNotifs.doc(), {
                      'post': postID,
                      'comment': comment,
                      'user': _username,
                      'token': token,
                      'date': _rightNow,
                    });
                    secondBatch.update(
                        firestore.collection('Users').doc(posterUsername),
                        {'numOfPostCommentsNotifs': FieldValue.increment(1)});
                    secondBatch.commit();
                  }
                }
              } else {
                if (posterUsername != _username) {
                  secondBatch.set(otherCommentsNotifs.doc(), {
                    'post': postID,
                    'comment': comment,
                    'user': _username,
                    'token': token,
                    'date': _rightNow,
                  });
                  secondBatch.update(
                      firestore.collection('Users').doc(posterUsername),
                      {'numOfPostCommentsNotifs': FieldValue.increment(1)});
                  secondBatch.commit();
                }
              }
              providerAddComment(_theComment);
              _controller.clear();
              assets!.clear();
              containsMedia = false;
              setState(() => isLoading = false);
            }).catchError((e) {
              setState(() => isLoading = false);
            });
          });
        }
      } else {
        final myComment = currentPostComments.doc(commentID);
        final thisPost = firestore.collection('Posts').doc(postID);
        final Comment _theComment = Comment(
          comment: comment,
          commenter: _myMiniProfile,
          commentDate: _rightNow,
          commentID: commentID,
          numOfReplies: 0,
          instance: _instance,
          containsMedia: containsMedia,
          downloadURL: '',
          numOfLikes: 0,
          isLiked: false,
          hasNSFW: false,
        );
        batch.set(myComment, {
          'commenter': _username,
          'description': comment,
          'replyCount': 0,
          'likeCount': 0,
          'date': _rightNow,
          'containsMedia': false,
          'downloadURL': '',
          'hasNSFW': false,
        });
        batch.set(myUserComments.doc(commentID), {
          'post ID': postID,
          'commenter': _username,
          'description': comment,
          'date': _rightNow,
          'containsMedia': false,
          'downloadURL': '',
          'hasNSFW': false,
        });
        batch.update(thisPost, {'comments': FieldValue.increment(1)});
        return batch.commit().then((value) async {
          var secondBatch = firestore.batch();
          final otherCommentsNotifs = firestore
              .collection('Users')
              .doc(posterUsername)
              .collection('PostCommentsNotifs');
          if (targetUser.data()!.containsKey('AllowComments')) {
            final allowComments = targetUser.get('AllowComments');
            if (allowComments) {
              if (posterUsername != _username) {
                secondBatch.set(otherCommentsNotifs.doc(), {
                  'post': postID,
                  'user': _username,
                  'token': token,
                  'date': _rightNow,
                });
                secondBatch.update(
                    firestore.collection('Users').doc(posterUsername),
                    {'numOfPostCommentsNotifs': FieldValue.increment(1)});
                secondBatch.commit();
              }
            }
          } else {
            if (posterUsername != _username) {
              secondBatch.set(otherCommentsNotifs.doc(), {
                'post': postID,
                'user': _username,
                'token': token,
                'date': _rightNow,
              });
              secondBatch.update(
                  firestore.collection('Users').doc(posterUsername),
                  {'numOfPostCommentsNotifs': FieldValue.increment(1)});
              secondBatch.commit();
            }
          }
          providerAddComment(_theComment);
          _controller.clear();
          setState(() => isLoading = false);
        }).catchError((e) {
          setState(() => isLoading = false);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _key = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final _myProfile = context.read<MyProfile>();
    final Color _primarySwatch = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    final String _image = _myProfile.getProfileImage;
    final String _username = _myProfile.getUsername;
    final String postID = Provider.of<FullHelper>(context).postId;
    final String posterID = Provider.of<FullHelper>(context).posterId;
    final void Function(Comment) providerAddComment =
        Provider.of<FullHelper>(context, listen: false).addComment;
    final ProfileImage _userImage = ProfileImage(
      username: _username,
      url: _image,
      factor: 0.08,
      inEdit: false,
      asset: null,
    );
    final Widget _userInput = Container(
      width: double.infinity,
      child: TextFormField(
        maxLength: 1500,
        controller: _controller,
        validator: _validateComment,
        decoration: InputDecoration(
          hintText: 'Write a comment..',
          counterText: '',
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          filled: true,
          fillColor: Colors.grey.shade300,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        onFieldSubmitted: (_) {
          if (isLoading) {
          } else {
            if (_key.currentState!.validate()) {
              FocusScope.of(context).unfocus();
              addComment(posterID, postID, _controller.value.text, _username,
                  _image, providerAddComment);
            }
          }
        },
      ),
    );
    final Widget _addComment = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (containsMedia)
          Container(
            height: 100.0,
            width: 100.0,
            margin: const EdgeInsets.all(5.0),
            child: Stack(
              children: <Widget>[
                Container(
                  key: UniqueKey(),
                  width: 100.0,
                  height: 100.0,
                  child: _selectedAssetWidget(),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      if (isLoading) {
                      } else {
                        _removeMedia();
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
          ),
        if (!containsMedia)
          IconButton(
            onPressed: () => _choose(_username),
            icon: const Icon(
              Icons.image,
              color: Colors.grey,
              size: 27.0,
            ),
          ),
        const SizedBox(width: 5.0),
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color?>(
              _primarySwatch,
            ),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
              const EdgeInsets.all(0.0),
            ),
            shape: MaterialStateProperty.all<OutlinedBorder?>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          onPressed: () {
            if (isLoading) {
            } else {
              if (_key.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                addComment(posterID, postID, _controller.value.text, _username,
                    _image, providerAddComment);
              }
            }
          },
          child: (isLoading)
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: _accentColor),
                ))
              : Center(
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ],
    );
    final ListTile _preview = ListTile(
      leading: _userImage,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _userInput,
      ),
      subtitle: _addComment,
    );
    return Form(
      key: _key,
      child: Container(
        padding: const EdgeInsets.all(3.0),
        child: _preview,
      ),
    );
  }
}
