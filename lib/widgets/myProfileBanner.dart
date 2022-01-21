import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../providers/myProfileProvider.dart';
import 'registrationDialog.dart';

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
  // bool stateNsfw = false;
  bool removedImage = false;
  String stateBannerUrl = 'None';
  bool changedImage = false;
  List<AssetEntity> assets = [];
  File? newImageFile;
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

  @override
  void initState() {
    super.initState();
    final String _originalBannerUrl =
        Provider.of<MyProfile>(context, listen: false).getProfileBanner;
    // stateBannerUrl = _originalBannerUrl;
  }

  Future<void> _save(
      String myUsername,
      void Function(String newUrl) changeBanner,
      String originalBanner,
      File? imageFile) async {
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
      if (stateBannerUrl == 'None') {
        if (originalBanner != 'None') {
          FirebaseStorage.instance
              .refFromURL(originalBanner)
              .delete()
              .then((value) {
            changeBanner('None');
            firestore.collection('Users').doc(myUsername).set({
              'Banner': 'None',
              'bannerNSFW': false,
            }, SetOptions(merge: true)).then((value) {
              setState(() {
                isLoading = false;
                changedImage = false;
              });
              EasyLoading.showSuccess('Saved');
            });
          }).catchError((_) {
            EasyLoading.showError(
              'Failed',
              duration: const Duration(seconds: 2),
            );
          });
        }
      } else {
        if (originalBanner != 'None') {
          FirebaseStorage.instance.refFromURL(originalBanner).delete();
        }
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
            "Banners can be up to 15 MB",
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
            if (result > 0.65) {
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
              }, SetOptions(merge: true)).then((value) {
                setState(() {
                  isLoading = false;
                  changedImage = false;
                });
                changeBanner(downloadUrl);
                EasyLoading.showSuccess('Saved');
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
    String originalBannerUrl = Provider.of<MyProfile>(context).getProfileBanner;
    final void Function(String) changeBanner =
        Provider.of<MyProfile>(context, listen: false).setMyProfileBanner;
    final String myUsername = Provider.of<MyProfile>(context).getUsername;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
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
                'Change banner',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  fontFamily: 'Roboto',
                  fontSize: 21.0,
                  color: Colors.black,
                ),
              ),
            ),
            if (stateBannerUrl != 'None' || originalBannerUrl != 'None')
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  stateBannerUrl = 'None';
                  originalBannerUrl = 'None';
                  changedImage = true;
                  removedImage = true;
                  setState(() {});
                },
                style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                child: const Text(
                  'Remove banner',
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
    return GestureDetector(
      onTap: () => showDialog(
          context: context,
          builder: (ctx) {
            return _myDialog;
          }),
      child: SizedBox(
        height: _deviceHeight * 0.15,
        width: _deviceWidth,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Container(
                margin: (widget.inEdit) ? const EdgeInsets.all(5.0) : null,
                decoration: BoxDecoration(
                  borderRadius: (widget.inEdit)
                      ? BorderRadius.circular(10.0)
                      : BorderRadius.circular(0.0),
                  border: widget.inEdit ? Border.all() : null,
                  color: (originalBannerUrl == 'None')
                      ? (stateBannerUrl == 'None')
                          ? Colors.transparent
                          : Colors.grey.shade300
                      : Colors.grey.shade300,
                ),
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
                                child: Image.file(
                                  newImageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                        : (stateBannerUrl == 'None')
                            ? (removedImage)
                                ? Container()
                                : ClipRRect(
                                    borderRadius: (widget.inEdit)
                                        ? BorderRadius.circular(10.0)
                                        : BorderRadius.circular(0.0),
                                    child: Image.network(
                                      originalBannerUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                            : ClipRRect(
                                borderRadius: (widget.inEdit)
                                    ? BorderRadius.circular(10.0)
                                    : BorderRadius.circular(0.0),
                                child: Image.file(
                                  newImageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                    : (originalBannerUrl == 'None')
                        ? Container()
                        : ClipRRect(
                            borderRadius: (widget.inEdit)
                                ? BorderRadius.circular(10.0)
                                : BorderRadius.circular(0.0),
                            child: Image.network(
                              originalBannerUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
              ),
            ),
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
                            backgroundColor: MaterialStateProperty.all<Color?>(
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
                              _save(myUsername, changeBanner, originalBannerUrl,
                                  newImageFile);
                            }
                          },
                        ),
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
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
