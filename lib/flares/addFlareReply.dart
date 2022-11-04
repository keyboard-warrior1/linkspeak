import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../general.dart';
// import '../models/reply.dart';
import '../models/miniProfile.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/chatprofileImage.dart';

class AddFlareReply extends StatefulWidget {
  final String flarePoster;
  final String collectionID;
  final String flareID;
  final String commentID;
  final String commenterName;
  final dynamic listHandler;
  const AddFlareReply(
      {required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.commentID,
      required this.commenterName,
      required this.listHandler});

  @override
  State<AddFlareReply> createState() => _AddFlareReplyState();
}

class _AddFlareReplyState extends State<AddFlareReply> {
  bool isLoading = false;
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _key;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late FirebaseStorage storage = FirebaseStorage.instance;
  String _myImgUrl = 'none';
  List<AssetEntity>? assets;
  bool containsMedia = false;
  List<String> mentions = [];
  String? _validateComment(String? value) {
    if ((value!.isEmpty ||
            value.replaceAll(' ', '') == '' ||
            value.trim() == '') &&
        !containsMedia) {
      return 'Please write a reply';
    }
    if (value.length > 1500) {
      return 'Replies can be between 0-1500 characters';
    }
    return null;
  }

  Widget _imageAssetWidget(AssetEntity asset) => Image(
      image: AssetEntityImageProvider(asset, isOriginal: false),
      fit: BoxFit.cover);

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

  void _removeMedia() => setState(() {
        containsMedia = false;
        assets!.removeAt(0);
      });

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
                child: _assetWidgetBuilder(asset))));
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
    const _english = const EnglishAssetPickerTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            maxAssets: _maxAssets,
            textDelegate: _english,
            selectedAssets: assets,
            requestType: RequestType.image));
    if (_result != null) {
      assets = List<AssetEntity>.from(_result);
      _myImgUrl =
          'Flare Replies/${widget.flarePoster}/${widget.collectionID}/${widget.flareID}/${widget.commentID}/$myUsername/$iD';
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

  /*FIX THE ABYSSMAL BUG THAT RUINS THE STATE GAINED BY COMMENTS OR REPLY
      AFTER A COMMENT OR REPLY IS ADDED,
      THE BUG OCCURS IF YOU LIKE OR REPLY TO A COMMENT/REPLY AND THEN ADD OR REMOVE 
      ANOTHER COMMENT/REPLY; THE STATE GAINED FROM LIKING/REPLYING IE: THE ADDED NUM OF LIKES
      OR THE ADDED NUM OF REPLIES IS LOST UPON ADDITION OR REMOVAL OF A COMMENT
      TO THE PREEXISTING LIST OF COMMENTS.*/
  Future<void> addReply(
      String commenter,
      String _username,
      String description,
      // void Function(Reply) _replyComment,
      String posterUsername,
      List<String> finalMentions) async {
    final checkExists = await General.checkExists(
        'Flares/$posterUsername/collections/${widget.collectionID}/flares/${widget.flareID}/comments/${widget.commentID}');
    if (checkExists) {
      setState(() {
        isLoading = true;
      });
      bool isBlocked = false;
      bool isBlockedByCommenter = false;
      final getCommenterBlocked = await firestore
          .collection('Users')
          .doc(commenter)
          .collection('Blocked')
          .doc(_username)
          .get();
      final getPosterBlocked = await firestore
          .collection('Users')
          .doc(posterUsername)
          .collection('Blocked')
          .doc(_username)
          .get();
      isBlockedByCommenter = getCommenterBlocked.exists;
      isBlocked = getPosterBlocked.exists;
      setState(() {});
      final filter = ProfanityFilter();
      final String originalDescription = description;
      String filteredDescription = description;
      if (filter.hasProfanity(originalDescription)) {
        filteredDescription = filter.censor(originalDescription);
      }
      final batch = firestore.batch();
      final theseComments = firestore
          .collection('Flares')
          .doc(widget.flarePoster)
          .collection('collections')
          .doc(widget.collectionID)
          .collection('flares')
          .doc(widget.flareID)
          .collection('comments');

      final currentPostCommentReplies =
          theseComments.doc(widget.commentID).collection('replies');
      final myUser = firestore.collection('Users').doc(_username);
      final myUserReplies = myUser.collection('Flare Replies');
      // final myMiniProfile = MiniProfile(username: _username);
      final DateTime rightNow = DateTime.now();
      final lasthour = rightNow.subtract(const Duration(minutes: 60));
      final myComments = await currentPostCommentReplies
          .where('replier', isEqualTo: _username)
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
      if (isBlocked || isBlockedByCommenter) {
        setState(() {
          isLoading = false;
        });
        if (isBlocked)
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "You are blocked by this flare's publisher.",
          );
        if (isBlockedByCommenter)
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "You are blocked by this commenter.",
          );
      } else {
        if (lastHourComments.length >= 30) {
          setState(() {
            isLoading = false;
          });
          _showDialog(
            Icons.info_outline,
            Colors.blue,
            'Notice',
            "Users can add up to 30 replies hourly to a comment",
          );
        } else {
          final targetUser =
              await firestore.collection('Users').doc(commenter).get();
          final token = targetUser.get('fcm');
          final replyID = General.generateContentID(
              username: _username,
              clubName: '',
              isPost: false,
              isClubPost: false,
              isCollection: false,
              isFlare: false,
              isComment: false,
              isReply: false,
              isFlareComment: false,
              isFlareReply: true);
          final reviewalDoc = firestore.collection('Review').doc(replyID);
          Future<void> mentionHandler(String mentionedUser) async {
            final users = firestore.collection('Users');
            if (mentionedUser != _username) {
              final targetUser = await users.doc(mentionedUser).get();
              final userExists = targetUser.exists;
              if (userExists) {
                final notifDescription =
                    '$_username mentioned you in their reply';
                final token = targetUser.get('fcm');
                final theirBlockDoc = await users
                    .doc(mentionedUser)
                    .collection('Blocked')
                    .doc(_username)
                    .get();
                final myBlockDoc = await users
                    .doc(_username)
                    .collection('Blocked')
                    .doc(mentionedUser)
                    .get();
                final bool imBlocked = theirBlockDoc.exists;
                final bool theyreBlocked = myBlockDoc.exists;
                final myMentions =
                    users.doc(_username).collection('My mentions');
                final mentionBox =
                    users.doc(mentionedUser).collection('Mention Box');
                final theirMentionedIn =
                    users.doc(mentionedUser).collection('Mentioned In');
                final data = {
                  'mentioned user': mentionedUser,
                  'mentioned by': _username,
                  'date': rightNow,
                  'postID': '',
                  'commentID': widget.commentID,
                  'replyID': replyID,
                  'flarePoster': widget.flarePoster,
                  'collectionID': widget.collectionID,
                  'flareID': widget.flareID,
                  'flareCommentID': widget.commentID,
                  'flareReplyID': replyID,
                  'commenterName': _username,
                  'clubName': '',
                  'posterName': posterUsername,
                  'isClubPost': false,
                  'isPost': false,
                  'isComment': false,
                  'isReply': false,
                  'isBio': false,
                  'isFlare': false,
                  'isFlareComment': false,
                  'isFlareReply': true,
                  'isFlaresBio': false,
                };
                final alertData = {
                  'mentioned user': mentionedUser,
                  'mentioned by': _username,
                  'token': token,
                  'description': notifDescription,
                  'date': rightNow,
                  'postID': '',
                  'commentID': widget.commentID,
                  'replyID': replyID,
                  'flarePoster': widget.flarePoster,
                  'collectionID': widget.collectionID,
                  'flareID': widget.flareID,
                  'flareCommentID': widget.commentID,
                  'flareReplyID': replyID,
                  'commenterName': _username,
                  'clubName': '',
                  'posterName': posterUsername,
                  'isClubPost': false,
                  'isPost': false,
                  'isComment': false,
                  'isReply': false,
                  'isBio': false,
                  'isFlare': false,
                  'isFlareComment': false,
                  'isFlareReply': true,
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

          final targetReply = currentPostCommentReplies.doc(replyID);
          final targetComment = theseComments.doc(widget.commentID);
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
            await FlutterNsfw.initNsfw(file.path,
                enableLog: false, isOpenGPU: false, numThreads: 4);
            File? imageFile = await assets![0].originFile;
            final int fileSize = imageFile!.lengthSync();
            if (fileSize > 15000000) {
              setState(() {
                isLoading = false;
              });
              _showDialog(Icons.info_outline, Colors.blue, 'Notice',
                  "Media can be up to 15 MB");
            } else {
              Map<String, dynamic> fields = {
                'flare replies': FieldValue.increment(1)
              };
              Map<String, dynamic> docFields = {
                'poster': widget.flarePoster,
                'collection': widget.collectionID,
                'flare': widget.flareID,
                'commentID': widget.commentID,
                'replyID': replyID,
                'date': rightNow
              };
              General.updateControl(
                  fields: fields,
                  myUsername: _username,
                  collectionName: 'flare replies',
                  docID: '$replyID',
                  docFields: docFields);
              if (filter.hasProfanity(originalDescription)) {
                batch.update(firestore.doc('Profanity/Flare Replies'),
                    {'numOfProfanity': FieldValue.increment(1)});
                batch.set(
                    firestore
                        .collection('Profanity/Flare Replies/Replies')
                        .doc(),
                    {
                      'poster': widget.flarePoster,
                      'collectionID': widget.collectionID,
                      'flareID': widget.flareID,
                      'postID': '',
                      'commentID': widget.commentID,
                      'replyID': replyID,
                      'user': _username,
                      'original': originalDescription,
                      'date': rightNow,
                      'clubName': '',
                    });
              }
              final String filePath = imageFile.absolute.path;
              var recognitions = await FlutterNsfw.getPhotoNSFWScore(filePath);
              if (recognitions > 0.759) {
                setState(() {
                  hasNSFW = true;
                });
              }
              await storage
                  .ref(_myImgUrl)
                  .putFile(imageFile)
                  .then((value) async {
                if (hasNSFW)
                  await reviewalDoc.set({
                    'date': rightNow,
                    'poster': '',
                    'clubName': '',
                    'ID': '',
                    'isFlare': false,
                    'flareID': widget.flareID,
                    'collectionID': widget.collectionID,
                    'isPost': false,
                    'isClubPost': false,
                    'isComment': false,
                    'isFlareComment': false,
                    'isReply': false,
                    'isFlareReply': true,
                    'isProfileBanner': false,
                    'isClubBanner': false,
                    'flarePoster': widget.flarePoster,
                    'profile': '',
                    'commentID': widget.commentID,
                    'replyID': replyID,
                  });
                final String downloadUrl =
                    await storage.ref(_myImgUrl).getDownloadURL();
                batch.set(targetReply, {
                  'date': rightNow,
                  'description': filteredDescription,
                  'likeCount': 0,
                  'replier': _username,
                  'containsMedia': true,
                  'downloadURL': downloadUrl,
                  'hasNSFW': hasNSFW,
                });
                batch.set(myUserReplies.doc(replyID), {
                  'poster': widget.flarePoster,
                  'collectionID': widget.collectionID,
                  'flareID': widget.flareID,
                  'comment ID': widget.commentID,
                  'replier': _username,
                  'commenter': commenter,
                  'description': filteredDescription,
                  'date': rightNow,
                  'containsMedia': true,
                  'downloadURL': downloadUrl,
                  'hasNSFW': hasNSFW,
                });
                batch.set(myUser, {'flare replies': FieldValue.increment(1)},
                    SetOptions(merge: true));
                batch.update(
                    targetComment, {'replyCount': FieldValue.increment(1)});
                await mentionPeople(finalMentions);
                return batch.commit().then((value) async {
                  var secondBatch = firestore.batch();
                  final otherRepliesNotifs = firestore
                      .collection('Users')
                      .doc(commenter)
                      .collection('CommentRepliesNotifs');
                  final status = targetUser.get('Status');
                  if (status != 'Banned') {
                    if (targetUser.data()!.containsKey('AllowReplies')) {
                      final allowReplies = targetUser.get('AllowReplies');
                      if (allowReplies) {
                        if (commenter != _username) {
                          secondBatch.set(otherRepliesNotifs.doc(), {
                            'post': '',
                            'comment': widget.commentID,
                            'reply': replyID,
                            'user': _username,
                            'recipient': commenter,
                            'token': token,
                            'date': rightNow,
                            'clubName': '',
                            'posterName': posterUsername,
                            'isFlare': true,
                            'poster': widget.flarePoster,
                            'collection': widget.collectionID,
                            'flareID': widget.flareID,
                          });
                          secondBatch.update(
                              firestore.collection('Users').doc(commenter), {
                            'numOfCommentRepliesNotifs': FieldValue.increment(1)
                          });
                          secondBatch.commit();
                        }
                      }
                    } else {
                      if (commenter != _username) {
                        secondBatch.set(otherRepliesNotifs.doc(), {
                          'post': '',
                          'comment': widget.commentID,
                          'reply': replyID,
                          'user': _username,
                          'recipient': commenter,
                          'token': token,
                          'date': rightNow,
                          'clubName': '',
                          'posterName': posterUsername,
                          'isFlare': true,
                          'poster': widget.flarePoster,
                          'collection': widget.collectionID,
                          'flareID': widget.flareID,
                        });
                        secondBatch.update(
                            firestore.collection('Users').doc(commenter), {
                          'numOfCommentRepliesNotifs': FieldValue.increment(1)
                        });
                        secondBatch.commit();
                      }
                    }
                  }
                  // final Reply myReply = Reply(
                  //     replier: myMiniProfile,
                  //     reply: filteredDescription,
                  //     replyDate: rightNow,
                  //     replyID: replyID,
                  //     likedByMe: false,
                  //     numOfLikes: 0,
                  //     downloadURL: downloadUrl,
                  //     containsMedia: true,
                  //     hasNSFW: hasNSFW);
                  _controller.clear();
                  assets!.clear();
                  containsMedia = false;
                  // _replyComment(myReply);
                  widget.listHandler();
                  setState(() {
                    isLoading = false;
                  });
                }).catchError((onError) {
                  setState(() {
                    isLoading = false;
                  });
                });
              });
            }
          } else {
            Map<String, dynamic> fields = {
              'flare replies': FieldValue.increment(1)
            };
            Map<String, dynamic> docFields = {
              'poster': widget.flarePoster,
              'collection': widget.collectionID,
              'flare': widget.flareID,
              'commentID': widget.commentID,
              'replyID': replyID,
              'date': rightNow
            };
            General.updateControl(
                fields: fields,
                myUsername: _username,
                collectionName: 'flare replies',
                docID: '$replyID',
                docFields: docFields);
            if (filter.hasProfanity(originalDescription)) {
              batch.update(firestore.doc('Profanity/Flare Replies'),
                  {'numOfProfanity': FieldValue.increment(1)});
              batch.set(
                  firestore.collection('Profanity/Flare Replies/Replies').doc(),
                  {
                    'poster': widget.flarePoster,
                    'collectionID': widget.collectionID,
                    'flareID': widget.flareID,
                    'postID': '',
                    'commentID': widget.commentID,
                    'replyID': replyID,
                    'user': _username,
                    'original': originalDescription,
                    'date': rightNow,
                    'clubName': '',
                  });
            }
            batch.set(targetReply, {
              'date': rightNow,
              'description': filteredDescription,
              'likeCount': 0,
              'replier': _username,
              'containsMedia': false,
              'downloadURL': '',
              'hasNSFW': false,
            });
            batch.set(myUserReplies.doc(replyID), {
              'poster': widget.flarePoster,
              'collectionID': widget.collectionID,
              'flareID': widget.flareID,
              'comment ID': widget.commentID,
              'replier': _username,
              'commenter': commenter,
              'description': filteredDescription,
              'date': rightNow,
              'containsMedia': false,
              'downloadURL': '',
              'hasNSFW': false,
            });
            batch.set(myUser, {'flare replies': FieldValue.increment(1)},
                SetOptions(merge: true));
            batch
                .update(targetComment, {'replyCount': FieldValue.increment(1)});
            await mentionPeople(finalMentions);
            return batch.commit().then((value) async {
              var secondBatch = firestore.batch();
              final otherRepliesNotifs = firestore
                  .collection('Users')
                  .doc(commenter)
                  .collection('CommentRepliesNotifs');
              final status = targetUser.get('Status');
              if (status != 'Banned') {
                if (targetUser.data()!.containsKey('AllowReplies')) {
                  final allowReplies = targetUser.get('AllowReplies');
                  if (allowReplies) {
                    if (commenter != _username) {
                      secondBatch.set(otherRepliesNotifs.doc(), {
                        'post': '',
                        'comment': widget.commentID,
                        'reply': replyID,
                        'user': _username,
                        'recipient': commenter,
                        'token': token,
                        'date': rightNow,
                        'clubName': '',
                        'posterName': posterUsername,
                        'isFlare': true,
                        'poster': widget.flarePoster,
                        'collection': widget.collectionID,
                        'flareID': widget.flareID,
                      });
                      secondBatch.update(
                          firestore.collection('Users').doc(commenter), {
                        'numOfCommentRepliesNotifs': FieldValue.increment(1)
                      });
                      secondBatch.commit();
                    }
                  }
                } else {
                  if (commenter != _username) {
                    secondBatch.set(otherRepliesNotifs.doc(), {
                      'post': '',
                      'comment': widget.commentID,
                      'reply': replyID,
                      'user': _username,
                      'recipient': commenter,
                      'token': token,
                      'date': rightNow,
                      'clubName': '',
                      'posterName': posterUsername,
                      'isFlare': true,
                      'poster': widget.flarePoster,
                      'collection': widget.collectionID,
                      'flareID': widget.flareID,
                    });
                    secondBatch.update(
                        firestore.collection('Users').doc(commenter),
                        {'numOfCommentRepliesNotifs': FieldValue.increment(1)});
                    secondBatch.commit();
                  }
                }
              }
              // final Reply myReply = Reply(
              //     replier: myMiniProfile,
              //     reply: filteredDescription,
              //     replyDate: rightNow,
              //     replyID: replyID,
              //     likedByMe: false,
              //     numOfLikes: 0,
              //     downloadURL: '',
              //     containsMedia: false,
              //     hasNSFW: false);
              _controller.clear();
              // _replyComment(myReply);
              widget.listHandler();
              setState(() {
                isLoading = false;
              });
            }).catchError((onError) {
              setState(() {
                isLoading = false;
              });
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _key = GlobalKey<FormState>();
    final RegExp _exp = RegExp(
      r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
      multiLine: true,
      caseSensitive: false,
      dotAll: true,
    );
    const prefix = '@';
    _controller.addListener(() {
      final text = _controller.text;
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
    _controller.removeListener(() {});
    _controller.dispose();
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
      final RegExp _exp = RegExp(
        r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,30}$',
        multiLine: true,
        caseSensitive: false,
        dotAll: true,
      );
      final cursorLocation = _controller.selection.base.offset;
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
    final oldText = _controller.text;
    final cursorLocation = _controller.selection.base.offset;
    final beginningTillHere = oldText.substring(0, cursorLocation);
    final result = beginningTillHere.split(' ');
    final last = result.lastWhere((element) => element.startsWith(prefix));
    final newUsername = '@${mini.username}';
    final length = newUsername.length;
    final newText = oldText.replaceFirst(last, newUsername);
    mentions.add(mini.username);
    _controller.value = _controller.value.copyWith(text: newText);
    final theIndex = _controller.text.indexOf(newUsername) + length;
    final newPosition = TextPosition(offset: theIndex);
    _controller.selection = TextSelection.fromPosition(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final _myProfile = context.read<MyProfile>();
    final Color _primarySwatch = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final String _username = _myProfile.getUsername;
    // final void Function(Reply) _replyComment =
    //     Provider.of<FullCommentHelper>(context, listen: false).replyComment;
    final ChatProfileImage _userImage = ChatProfileImage(
        username: _username, factor: 0.05, inEdit: false, asset: null);
    final Widget _userInput = Container(
        width: double.infinity,
        child: TypeAheadFormField<MiniProfile>(
            suggestionsCallback: fieldHandler,
            itemBuilder: fieldBuilder,
            onSuggestionSelected: (_) {},
            hideOnEmpty: true,
            hideOnError: true,
            hideOnLoading: true,
            hideSuggestionsOnKeyboardHide: false,
            validator: _validateComment,
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                borderRadius: BorderRadius.circular(15), hasScrollbar: false),
            textFieldConfiguration: TextFieldConfiguration(
                maxLength: 1500,
                controller: _controller,
                decoration: InputDecoration(
                    hintText: 'Add a reply..',
                    counterText: '',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade300))))));
    final Widget _addReply =
        Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      if (containsMedia)
        Container(
            height: 50.0,
            width: 50.0,
            margin: const EdgeInsets.all(5.0),
            child: Stack(children: <Widget>[
              Container(
                  key: UniqueKey(),
                  width: 100.0,
                  height: 100.0,
                  child: _selectedAssetWidget()),
              Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                      onTap: () {
                        if (isLoading) {
                        } else {
                          _removeMedia();
                        }
                      },
                      child:
                          Icon(Icons.cancel, color: Colors.redAccent.shade400)))
            ])),
      if (!containsMedia && !kIsWeb)
        IconButton(
            onPressed: () => _choose(_username),
            icon: const Icon(Icons.image_outlined,
                color: Colors.grey, size: 27.0)),
      const SizedBox(width: 5.0),
      TextButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color?>(_primarySwatch),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                  const EdgeInsets.all(0.0)),
              shape: MaterialStateProperty.all<OutlinedBorder?>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)))),
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (isLoading) {
            } else {
              if (_key.currentState!.validate()) {
                addReply(
                    widget.commenterName,
                    _username,
                    _controller.value.text,
                    // _replyComment,
                    widget.flarePoster,
                    mentions);
              } else {}
            }
          },
          child: (isLoading)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: _accentColor, strokeWidth: 1.50)))
              : Center(
                  child: Text('Reply',
                      style: TextStyle(
                          color: _accentColor, fontWeight: FontWeight.bold))))
    ]);
    final ListTile _preview = ListTile(
        leading: _userImage,
        title: Padding(padding: const EdgeInsets.all(8.0), child: _userInput),
        subtitle: _addReply);
    return Form(
        key: _key,
        child: Container(padding: const EdgeInsets.all(3.0), child: _preview));
  }
}
