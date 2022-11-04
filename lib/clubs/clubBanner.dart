import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../general.dart';
import '../providers/clubProvider.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/auth/registrationDialog.dart';
import 'clubSensitiveBanner.dart';

class ClubBanner extends StatefulWidget {
  final bool inEdit;
  const ClubBanner(this.inEdit);

  @override
  State<ClubBanner> createState() => _ClubBannerState();
}

class _ClubBannerState extends State<ClubBanner> {
  final storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool isNSFW = false;
  bool removedImage = false;
  String stateBannerUrl = 'none';
  bool changedImage = false;
  List<AssetEntity> assets = [];
  File? newImageFile;
  Future<void> _choose(String myUsername, Color primaryColor) async {
    const int _maxAssets = 1;
    const _english = const EnglishAssetPickerTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            textDelegate: _english,
            maxAssets: _maxAssets,
            selectedAssets: assets,
            requestType: RequestType.image,
            themeColor: primaryColor));
    if (_result != null) {
      assets = List<AssetEntity>.from(_result);
      final imageFile = await assets[0].originFile;
      newImageFile = imageFile;
      final path = imageFile!.absolute.path;
      final name = path.split('/').last;
      stateBannerUrl = 'Clubs/Club Banners/$myUsername/$name';
      changedImage = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _save({
    required String xAvatar,
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
    required void Function(String newUrl, bool newNSFW) changeBanner,
    required String originalBanner,
    required File? imageFile,
  }) async {
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

    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      EasyLoading.show(status: 'Saving', dismissOnTap: true);
      final reviewalDoc = firestore.collection('Review').doc(myUsername);
      final _rightNow = DateTime.now();
      final modifID = _rightNow.toString();
      if (stateBannerUrl == 'none') {
        if (originalBanner != 'none') {
          // FirebaseStorage.instance
          //     .refFromURL(originalBanner)
          //     .delete()
          //     .then((value) {
          changeBanner('none', false);
          firestore.collection('Clubs').doc(myUsername).set({
            'banner': 'none',
            'bannerNSFW': false,
            'last modified': _rightNow,
            'last modifier': thisAdmin,
            'modifications': FieldValue.increment(1),
          }, SetOptions(merge: true)).then((value) async {
            await firestore
                .collection('Clubs')
                .doc(myUsername)
                .collection('Modifications')
                .doc(modifID)
                .set({
              'xAvatar': xAvatar,
              'xBanner': originalBanner,
              'xBannerNSFW': xBannerNSFW,
              'xVisibility': xVisibility,
              'xAbout': xAbout,
              'xTopics': xtopics,
              'xMembersCanPost': xMembersCanPost,
              'xMaxDailyPosts': xMaxDailyPosts,
              'xAllowQuickJoin': xAllowQuickJoin,
              'xIsDisabled': xIsDisabled,
              'Avatar': xAvatar,
              'Banner': 'none',
              'bannerNSFW': false,
              'Visibility': xVisibility,
              'about': xAbout,
              'topics': xtopics,
              'membersCanPost': xMembersCanPost,
              'maxDailyPosts': xMaxDailyPosts,
              'allowQuickJoin': xAllowQuickJoin,
              'isDisabled': xIsDisabled,
              'modifier': thisAdmin,
              'date': _rightNow,
            }, SetOptions(merge: true));
            setState(() {
              isLoading = false;
              changedImage = false;
            });
            EasyLoading.showSuccess(
              'Saved',
              dismissOnTap: true,
              duration: const Duration(seconds: 1),
            );
          }).catchError((_) {
            EasyLoading.showError(
              'Failed',
              duration: const Duration(seconds: 2),
            );
          });
        }
      } else {
        // if (originalBanner != 'none') {
        //   FirebaseStorage.instance.refFromURL(originalBanner).delete();
        // }
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
            "Banners can be up to 30 MB in size",
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
                isNSFW = true;
              });
            }
            await storage
                .ref(stateBannerUrl)
                .putFile(imageFile)
                .then((value) async {
              final String downloadUrl =
                  await storage.ref(stateBannerUrl).getDownloadURL();
              if (isNSFW)
                await reviewalDoc.set({
                  'date': _rightNow,
                  'poster': '',
                  'clubName': myUsername,
                  'ID': '',
                  'isFlare': false,
                  'flareID': '',
                  'collectionID': '',
                  'isPost': false,
                  'isClubPost': false,
                  'isComment': false,
                  'isFlareComment': false,
                  'isReply': false,
                  'isFlareReply': false,
                  'isProfileBanner': false,
                  'isClubBanner': true,
                  'flarePoster': false,
                  'profile': '',
                  'commentID': '',
                  'replyID': '',
                });
              await firestore
                  .collection('Clubs')
                  .doc(myUsername)
                  .collection('Modifications')
                  .doc(modifID)
                  .set({
                'xAvatar': xAvatar,
                'xBanner': originalBanner,
                'xBannerNSFW': xBannerNSFW,
                'xVisibility': xVisibility,
                'xAbout': xAbout,
                'xTopics': xtopics,
                'xMembersCanPost': xMembersCanPost,
                'xMaxDailyPosts': xMaxDailyPosts,
                'xAllowQuickJoin': xAllowQuickJoin,
                'xIsDisabled': xIsDisabled,
                'Avatar': xAvatar,
                'Banner': downloadUrl,
                'bannerNSFW': isNSFW,
                'Visibility': xVisibility,
                'about': xAbout,
                'topics': xtopics,
                'membersCanPost': xMembersCanPost,
                'maxDailyPosts': xMaxDailyPosts,
                'allowQuickJoin': xAllowQuickJoin,
                'isDisabled': xIsDisabled,
                'modifier': thisAdmin,
                'date': _rightNow,
              }, SetOptions(merge: true));
              await firestore.collection('Clubs').doc(myUsername).set({
                'banner': downloadUrl,
                'bannerNSFW': isNSFW,
                'last modified': _rightNow,
                'last modifier': thisAdmin,
                'modifications': FieldValue.increment(1),
              }, SetOptions(merge: true)).then((value) {
                setState(() {
                  isLoading = false;
                  changedImage = false;
                });
                changeBanner(downloadUrl, isNSFW);
                EasyLoading.showSuccess(
                  'Saved',
                  dismissOnTap: true,
                  duration: const Duration(seconds: 1),
                );
              }).catchError((_) {
                EasyLoading.showError(
                  'Failed',
                  duration: const Duration(seconds: 2),
                );
                setState(() {
                  isLoading = false;
                });
              });
            }).catchError((_) {
              EasyLoading.showError(
                'Failed',
                duration: const Duration(seconds: 2),
              );
            });
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = Provider.of<ClubProvider>(context);
    final xAvatar = club.clubAvatar;
    final xBannerNSFW = club.bannerNSFW;
    final xAbout = club.clubDescription;
    final xAllowQuickJoin = club.allowQuickJoin;
    final xIsDisabled = club.isDisabled;
    final xMaxDailyPosts = club.maxDailyPostsByMembers;
    final xMembersCanPost = club.memberCanPost;
    final xVisibility = General.generateClubVis(club.clubVisibility);
    final xtopics = club.clubTopics;
    final isBanned = club.isBanned;
    final avatar = club.clubBannerUrl;
    final bannerNSFW = club.bannerNSFW;
    final isMember = club.isJoined;
    String originalBannerUrl = club.clubBannerUrl;
    final void Function(String, bool) changeBanner =
        Provider.of<ClubProvider>(context, listen: false).changeBanner;
    final String myUsername = club.clubName;
    final String thisAdmin =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
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
                  if (!kIsWeb)
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _choose(myUsername, _primaryColor);
                        },
                        style: const ButtonStyle(
                            splashFactory: NoSplash.splashFactory),
                        child: const Text('Change banner',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontFamily: 'Roboto',
                                fontSize: 21.0,
                                color: Colors.black))),
                  if (stateBannerUrl != 'none' || originalBannerUrl != 'none')
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          stateBannerUrl = 'none';
                          originalBannerUrl = 'none';
                          changedImage = true;
                          removedImage = true;
                          assets.clear();
                          setState(() {});
                        },
                        style: const ButtonStyle(
                            splashFactory: NoSplash.splashFactory),
                        child: const Text('Remove banner',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontFamily: 'Roboto',
                                fontSize: 21.0,
                                color: Colors.black)))
                ])));
    return (widget.inEdit)
        ? GestureDetector(
            onTap: () => showDialog(
                context: context,
                builder: (ctx) {
                  return _myDialog;
                }),
            child: SizedBox(
                height: _deviceHeight * 0.15,
                width: _deviceWidth,
                child: Stack(children: <Widget>[
                  Positioned.fill(
                      child: Container(
                          margin: (widget.inEdit)
                              ? const EdgeInsets.all(5.0)
                              : null,
                          decoration: BoxDecoration(
                              borderRadius: (widget.inEdit)
                                  ? BorderRadius.circular(10.0)
                                  : BorderRadius.circular(0.0),
                              border: widget.inEdit ? Border.all() : null,
                              color: (originalBannerUrl == 'none')
                                  ? (stateBannerUrl == 'none')
                                      ? Colors.transparent
                                      : Colors.grey.shade200
                                  : Colors.grey.shade200),
                          height: _deviceHeight * 0.15,
                          width: _deviceWidth,
                          child: (widget.inEdit)
                              ? (originalBannerUrl == 'none')
                                  ? (stateBannerUrl == 'none')
                                      ? Container()
                                      : ClipRRect(
                                          borderRadius: (widget.inEdit)
                                              ? BorderRadius.circular(10.0)
                                              : BorderRadius.circular(0.0),
                                          child: Image.file(newImageFile!,
                                              fit: BoxFit.cover))
                                  : (stateBannerUrl == 'none')
                                      ? (removedImage)
                                          ? Container()
                                          : ClipRRect(
                                              borderRadius: (widget.inEdit)
                                                  ? BorderRadius.circular(10.0)
                                                  : BorderRadius.circular(0.0),
                                              child: Image.network(
                                                  originalBannerUrl,
                                                  fit: BoxFit.cover))
                                      : ClipRRect(
                                          borderRadius: (widget.inEdit)
                                              ? BorderRadius.circular(10.0)
                                              : BorderRadius.circular(0.0),
                                          child: Image.file(newImageFile!,
                                              fit: BoxFit.cover))
                              : (originalBannerUrl == 'none')
                                  ? Container()
                                  : ClipRRect(
                                      borderRadius: (widget.inEdit)
                                          ? BorderRadius.circular(10.0)
                                          : BorderRadius.circular(0.0),
                                      child: Image.network(originalBannerUrl,
                                          fit: BoxFit.cover)))),
                  if (widget.inEdit)
                    Positioned(
                        right: 5.0,
                        child: Container(
                            margin: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  if (changedImage)
                                    TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color?>(
                                                  _primaryColor),
                                        ),
                                        child: Text(
                                          'Save',
                                          style: TextStyle(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () {
                                          if (isLoading) {
                                          } else {
                                            _save(
                                                xAvatar: xAvatar,
                                                xAbout: xAbout,
                                                xBannerNSFW: xBannerNSFW,
                                                xAllowQuickJoin:
                                                    xAllowQuickJoin,
                                                xIsDisabled: xIsDisabled,
                                                xMaxDailyPosts: xMaxDailyPosts,
                                                xVisibility: xVisibility,
                                                xMembersCanPost:
                                                    xMembersCanPost,
                                                xtopics: xtopics,
                                                myUsername: myUsername,
                                                thisAdmin: thisAdmin,
                                                changeBanner: changeBanner,
                                                originalBanner:
                                                    originalBannerUrl,
                                                imageFile: newImageFile);
                                          }
                                        }),
                                  IconButton(
                                      onPressed: () => showDialog(
                                          context: context,
                                          builder: (ctx) {
                                            return _myDialog;
                                          }),
                                      icon: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle),
                                          child: Container(
                                              margin: const EdgeInsets.all(5.0),
                                              child: const Icon(Icons.edit,
                                                  color: Colors.white,
                                                  size: 15.0))))
                                ])))
                ])))
        : Stack(children: <Widget>[
            Container(
                height: 150,
                width: double.infinity,
                color: (isBanned || avatar == 'none')
                    ? Colors.transparent
                    : Colors.grey.shade200,
                child: (isBanned || avatar == 'none')
                    ? Container()
                    : Image.network(avatar, fit: BoxFit.cover)),
            if (bannerNSFW && !isBanned && !isMember)
              const ClubSensitiveBanner(false)
          ]);
  }
}
