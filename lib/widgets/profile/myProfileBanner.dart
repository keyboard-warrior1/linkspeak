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
import '../../providers/myProfileProvider.dart';
import '../auth/registrationDialog.dart';

class MyProfileBanner extends StatefulWidget {
  final bool inEdit;
  const MyProfileBanner(this.inEdit);
  @override
  _MyProfileBannerState createState() => _MyProfileBannerState();
}

class _MyProfileBannerState extends State<MyProfileBanner> {
  final storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool isNSFW = false;
  bool removedImage = false;
  String stateBannerUrl = 'None';
  bool changedImage = false;
  List<AssetEntity> assets = [];
  File? newImageFile;

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
      newImageFile = imageFile;
      final path = imageFile!.absolute.path;
      final name = path.split('/').last;
      stateBannerUrl = 'Banners/$myUsername/$name';
      changedImage = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _save({
    required String myUsername,
    required void Function(String newUrl, bool newNSFW) changeBanner,
    required String originalBanner,
    required File? imageFile,
    required bool xBannerNSFW,
    required String xAvatar,
    required String xVisibility,
    required String xBio,
    required xTopics,
  }) async {
    final lang = General.language(context);
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
      final _now = DateTime.now();
      final modificationID = _now.toString();
      EasyLoading.show(status: lang.widgets_profile15, dismissOnTap: true);
      final reviewalDoc = firestore.collection('Review').doc(myUsername);
      if (stateBannerUrl == 'None') {
        if (originalBanner != 'None') {
          // FirebaseStorage.instance
          //     .refFromURL(originalBanner)
          //     .delete()
          //     .then((value) {
          changeBanner('None', false);
          firestore.collection('Users').doc(myUsername).set({
            'Banner': 'None',
            'bannerNSFW': false,
          }, SetOptions(merge: true)).then((value) async {
            await firestore
                .collection('Users')
                .doc(myUsername)
                .collection('Modifications')
                .doc(modificationID)
                .set({
              'xBanner': originalBanner,
              'xBannerNSFW': xBannerNSFW,
              'Banner': 'None',
              'bannerNSFW': false,
              'xAvatar': xAvatar,
              'xVisibility': xVisibility,
              'xBio': xBio,
              'xTopics': xTopics,
              'Avatar': xAvatar,
              'Visibility': xVisibility,
              'Bio': xBio,
              'Topics': xTopics,
              'date': _now,
            });
            setState(() {
              isLoading = false;
              changedImage = false;
            });
            EasyLoading.showSuccess(lang.flares_customize1,
                dismissOnTap: true, duration: const Duration(seconds: 1));
          }).catchError((_) {
            EasyLoading.showError(
              lang.clubs_manage13,
              duration: const Duration(seconds: 2),
            );
          });
        }
      } else {
        // if (originalBanner != 'None') {
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
            lang.clubs_create8,
            lang.widgets_profile14,
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
              await firestore.collection('Users').doc(myUsername).set({
                'Banner': downloadUrl,
                'bannerNSFW': isNSFW,
              }, SetOptions(merge: true)).then((value) async {
                if (isNSFW)
                  await reviewalDoc.set({
                    'date': _now,
                    'poster': '',
                    'clubName': '',
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
                    'isProfileBanner': true,
                    'isClubBanner': false,
                    'flarePoster': false,
                    'profile': myUsername,
                    'commentID': '',
                    'replyID': '',
                  });
                await firestore
                    .collection('Users')
                    .doc(myUsername)
                    .collection('Modifications')
                    .doc(modificationID)
                    .set({
                  'xBanner': originalBanner,
                  'xBannerNSFW': xBannerNSFW,
                  'Banner': downloadUrl,
                  'bannerNSFW': isNSFW,
                  'xAvatar': xAvatar,
                  'xVisibility': xVisibility,
                  'xBio': xBio,
                  'xTopics': xTopics,
                  'Avatar': xAvatar,
                  'Visibility': xVisibility,
                  'Bio': xBio,
                  'Topics': xTopics,
                  'date': _now,
                });
                setState(() {
                  isLoading = false;
                  changedImage = false;
                });
                changeBanner(downloadUrl, isNSFW);
                EasyLoading.showSuccess(
                  lang.flares_customize1,
                  dismissOnTap: true,
                  duration: const Duration(seconds: 1),
                );
              }).catchError((_) {
                EasyLoading.showError(
                  lang.clubs_manage13,
                  duration: const Duration(seconds: 2),
                );
                setState(() {
                  isLoading = false;
                });
              });
            }).catchError((_) {
              EasyLoading.showError(
                lang.clubs_manage13,
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
    final lang = General.language(context);
    final myProfile = Provider.of<MyProfile>(context);
    String originalBannerUrl = myProfile.getProfileBanner;
    final bool xbannerNSFW = myProfile.getBannerNSFW;
    final String xVisibility =
        General.generateProfileVis(myProfile.getVisibility);
    final String xAvatar = myProfile.getProfileImage;
    final String xBio = myProfile.getBio;
    final xTopics = myProfile.getTopics;
    final void Function(String, bool) changeBanner =
        Provider.of<MyProfile>(context, listen: false).setMyProfileBanner;
    final String myUsername = Provider.of<MyProfile>(context).getUsername;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
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
                  if (!kIsWeb)
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _choose(myUsername, _primaryColor, lang);
                        },
                        style: const ButtonStyle(
                            splashFactory: NoSplash.splashFactory),
                        child: Text(lang.clubs_banner1,
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontFamily: 'Roboto',
                                fontSize: 21.0,
                                color: Colors.black))),
                  if (stateBannerUrl != 'None' || originalBannerUrl != 'None')
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          stateBannerUrl = 'None';
                          originalBannerUrl = 'None';
                          changedImage = true;
                          removedImage = true;
                          assets.clear();
                          setState(() {});
                        },
                        style: const ButtonStyle(
                            splashFactory: NoSplash.splashFactory),
                        child: Text(lang.clubs_banner2,
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontFamily: 'Roboto',
                                fontSize: 21.0,
                                color: Colors.black)))
                ])));
    return GestureDetector(
        onTap: () => showDialog(context: context, builder: (ctx) => _myDialog),
        child: SizedBox(
            height: _deviceHeight * 0.15,
            width: _deviceWidth,
            child: Stack(children: <Widget>[
              Positioned.fill(
                  child: Container(
                      margin:
                          (widget.inEdit) ? const EdgeInsets.all(5.0) : null,
                      decoration: BoxDecoration(
                          borderRadius: (widget.inEdit)
                              ? BorderRadius.circular(10.0)
                              : BorderRadius.circular(0.0),
                          border: widget.inEdit ? Border.all() : null,
                          color: (originalBannerUrl == 'None')
                              ? (stateBannerUrl == 'None')
                                  ? Colors.transparent
                                  : Colors.grey.shade200
                              : Colors.grey.shade200),
                      height: _deviceHeight * 0.15,
                      width: _deviceWidth,
                      child: (widget.inEdit)
                          ? (originalBannerUrl == 'None')
                              ? (stateBannerUrl == 'None')
                                  ? Container()
                                  : ClipRRect(
                                      borderRadius: (widget.inEdit)
                                          ? BorderRadius.circular(10.0)
                                          : BorderRadius.circular(0.0),
                                      child: Image.file(newImageFile!,
                                          fit: BoxFit.cover))
                              : (stateBannerUrl == 'None')
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
                          : (originalBannerUrl == 'None')
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
                                                _primaryColor)),
                                    child: Text(lang.clubs_banner3,
                                        style: TextStyle(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      if (isLoading) {
                                      } else {
                                        _save(
                                            myUsername: myUsername,
                                            changeBanner: changeBanner,
                                            originalBanner: originalBannerUrl,
                                            imageFile: newImageFile,
                                            xBannerNSFW: xbannerNSFW,
                                            xVisibility: xVisibility,
                                            xAvatar: xAvatar,
                                            xBio: xBio,
                                            xTopics: xTopics);
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
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                          margin: const EdgeInsets.all(5.0),
                                          child: const Icon(Icons.edit,
                                              color: Colors.white,
                                              size: 15.0))))
                            ])))
            ])));
  }
}
