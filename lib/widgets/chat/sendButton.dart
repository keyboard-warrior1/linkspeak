import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:location/location.dart' as geoloacation;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/themeModel.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../auth/registrationDialog.dart';
import '../common/noglow.dart';
import 'chatAudioStopWatch.dart';

class SendButton extends StatefulWidget {
  final ScrollController scrollController;
  final String chatId;
  const SendButton(this.scrollController, this.chatId);

  @override
  _SendButtonState createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> with WidgetsBindingObserver {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final recorder = Record();
  final storage = FirebaseStorage.instance;
  bool sendingMediaLoading = false;
  bool isRecordingAudio = false;
  bool sendingAudioLoading = false;
  bool isBlocked = false;
  bool imBlocked = false;
  bool stopTimer = false;
  File? currentAudioFile;
  bool exists = false;
  bool _isActiveSendButton = false;
  String currentFilePath = '';
  final _textFieldController = TextEditingController();
  late Future<void> Function() offTyping;
  List<AssetEntity> assets = [];
  Widget _imageAssetWidget(AssetEntity asset) {
    return Image(
        image: AssetEntityImageProvider(asset, isOriginal: false),
        fit: BoxFit.cover);
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
          if (sendingMediaLoading) {
          } else {
            final List<AssetEntity>? result =
                await AssetPickerViewer.pushToViewer(context,
                    currentIndex: index,
                    previewAssets: assets,
                    themeData: AssetPicker.themeData(Colors.blue));
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

  _showDialog(IconData icon, Color iconColor, String title, String rule) {
    showDialog(
        context: context,
        builder: (_) => RegistrationDialog(
            icon: icon, iconColor: iconColor, title: title, rules: rule));
  }

  void _removeMedia(index) {
    setState(() {
      assets.removeAt(index);
    });
  }

  Future<File> getFile(AssetEntity asset) async {
    final file = await asset.originFile;
    return file!;
  }

  Future<List<File>> getFiles(List<AssetEntity> assets) async {
    var files = Future.wait(assets.map((asset) => getFile(asset)).toList());
    return files;
  }

  Future<String> uploadFile(String myUsername, File file) async {
    final String filePath = file.absolute.path;
    final name = filePath.split('/').last;
    final String ref = 'Chats/$myUsername/${widget.chatId}/$name';
    var storageReference = storage.ref(ref);
    var uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() {
      storageReference = storage.ref(ref);
    });
    return await storageReference.getDownloadURL();
  }

  Future<List<String>> uploadFiles(String myUsername, List<File> files) async {
    var mediaURLS = await Future.wait(
        files.map((file) => uploadFile(myUsername, file)).toList());
    return mediaURLS;
  }

  Future<void> _choose(Color primaryColor, dynamic lang) async {
    final int _maxAssets = 10;
    final _english = lang.assetPickerDelegate;
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

  Future<void> _chooseCamera(
      Color primaryColor, Color accentColor, dynamic lang) async {
    final AssetEntity? _result = await CameraPicker.pickFromCamera(context,
        pickerConfig: CameraPickerConfig(
            resolutionPreset: ResolutionPreset.high,
            enableRecording: true,
            maximumRecordingDuration: const Duration(seconds: 60),
            textDelegate: lang.cameraPickerDelegate,
            theme: ThemeData(colorScheme: Theme.of(context).colorScheme)));
    if (_result != null && assets.length < 10) {
      assets.add(_result);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _offTyping(String myUsername) {
    final _myFriend =
        firestore.collection('Users/${widget.chatId}/chats').doc(myUsername);
    return _myFriend.update({'isTyping': false, 'isRecording': false});
  }

  Future<void> pickAddressChatHandler(String myUsername, String shownName,
      dynamic point, String myLangCode) async {
    final lang = General.language(context);
    var batch = firestore.batch();
    final targetUser =
        await firestore.collection('Users').doc(widget.chatId).get();
    String targetLang = 'en';
    if (targetUser.data()!.containsKey('language')) {
      targetLang = targetUser.get('language');
    }
    final String friendMessage = General.giveLocationMessage(targetLang);
    final String myMessage = General.giveLocationMessage(myLangCode);
    final token = targetUser.get('fcm');
    final sameTime = Timestamp.now();
    final _myMessagesCollection = firestore
        .collection('Users/$myUsername/chats/${widget.chatId}/messages');
    final _myFriendCollection = firestore
        .collection('Users/${widget.chatId}/chats/$myUsername/messages');
    final _myFriendChatDocument =
        firestore.doc('Users/${widget.chatId}/chats/$myUsername');
    final _myChatDocument =
        firestore.doc('Users/$myUsername/chats/${widget.chatId}');
    batch.set(_myMessagesCollection.doc(), {
      'date': sameTime,
      'description': myMessage,
      'user': '$myUsername',
      'isRead': false,
      'isDeleted': false,
      'isPost': false,
      'isClubPost': false,
      'postID': '',
      'isMedia': false,
      'isSpotlight': false,
      'poster': '',
      'collection': '',
      'isAudio': false,
      'isLocation': true,
      'locationName': '$shownName',
      'location': point,
      'spotlightID': '',
      'token': '',
      'mediaURL': [],
      'audioURL': ''
    });

    batch.set(_myFriendCollection.doc(), {
      'date': sameTime,
      'description': friendMessage,
      'user': '$myUsername',
      'token': token,
      'isRead': false,
      'isDeleted': false,
      'isPost': false,
      'isClubPost': false,
      'postID': '',
      'isMedia': false,
      'isSpotlight': false,
      'poster': '',
      'collection': '',
      'isAudio': false,
      'isLocation': true,
      'locationName': '$shownName',
      'location': point,
      'mediaURL': [],
      'spotlightID': '',
      'audioURL': ''
    });

    batch.set(_myFriendChatDocument, {
      'displayMessage': friendMessage,
      'isRead': false,
      'lastMessageTime': sameTime,
      'isTyping': false,
      'isRecording': false
    });

    batch.set(_myChatDocument, {
      'displayMessage': myMessage,
      'isRead': true,
      'lastMessageTime': sameTime
    });
    await Future.delayed(
        const Duration(milliseconds: 100),
        () => batch.commit().then((value) {
              Map<String, dynamic> fields = {
                'messages location': FieldValue.increment(1),
                'messages total': FieldValue.increment(1)
              };
              General.updateControl(
                  myUsername: myUsername,
                  fields: fields,
                  collectionName: null,
                  docID: null,
                  docFields: {});
              EasyLoading.dismiss();
              EasyLoading.showSuccess(lang.widgets_chat24,
                  duration: const Duration(seconds: 2), dismissOnTap: true);
              Navigator.pop(context);
            }));
  }

  void mediaButtonHandler(String _myUsername, String myLangCode) {
    final lang = General.language(context);
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    showModalBottomSheet(
        context: context,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(31.0)),
        backgroundColor: Colors.white,
        builder: (_) {
          final ListTile _choosephotoGallery = ListTile(
              horizontalTitleGap: 5.0,
              leading: const Icon(Icons.perm_media, color: Colors.black),
              title: Text(lang.clubs_newPost20,
                  style: const TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _choose(_primaryColor, lang);
              });
          final ListTile _camera = ListTile(
              horizontalTitleGap: 5.0,
              leading: const Icon(Icons.camera_alt, color: Colors.black),
              title: Text(lang.clubs_newPost21,
                  style: const TextStyle(color: Colors.black)),
              onTap: () {
                if (assets.length < 10) {
                  Navigator.pop(context);
                  _chooseCamera(_primaryColor, _accentColor, lang);
                }
              });
          final ListTile _sendCurrentLocation = ListTile(
              horizontalTitleGap: 5.0,
              leading: const Icon(Icons.gps_fixed, color: Colors.black),
              title: Text(lang.widgets_chat25,
                  style: const TextStyle(color: Colors.black)),
              onTap: () async {
                if (isBlocked && !_myUsername.startsWith('Linkspeak') ||
                    (imBlocked && !_myUsername.startsWith('Linkspeak'))) {
                } else {
                  Navigator.pop(context);
                  geoloacation.Location location = geoloacation.Location();
                  PermissionStatus status = await Permission.location.request();
                  if (status == PermissionStatus.granted) {
                    EasyLoading.show(
                        status: lang.widgets_chat26, dismissOnTap: false);
                    var batch = firestore.batch();
                    final myLocations = firestore
                        .collection('Users')
                        .doc(myUsername)
                        .collection('My Locations')
                        .doc();
                    var _locationData = await location.getLocation();
                    final newAddress = GeoPoint(
                        _locationData.latitude!, _locationData.longitude!);
                    final latitude = _locationData.latitude;
                    final longitude = _locationData.longitude;
                    final placemark = await geocoder.placemarkFromCoordinates(
                        latitude!, longitude!);
                    final cityName = placemark[0].locality;
                    final countryName = placemark[0].country;
                    await myLocations.set({
                      'location name': '$cityName, $countryName',
                      'coordinates': newAddress,
                      'date': DateTime.now(),
                      'took in post': false,
                      'took in profile': false,
                      'took in chat': true,
                      'took in place search': false,
                    });
                    final targetUser = await firestore
                        .collection('Users')
                        .doc(widget.chatId)
                        .get();
                    String targetLang = 'en';
                    if (targetUser.data()!.containsKey('language')) {
                      targetLang = targetUser.get('language');
                    }
                    final String friendMessage =
                        General.giveLocationMessage(targetLang);
                    final String myMessage =
                        General.giveLocationMessage(myLangCode);
                    final token = targetUser.get('fcm');
                    final sameTime = Timestamp.now();
                    final _myMessagesCollection = firestore.collection(
                        'Users/$myUsername/chats/${widget.chatId}/messages');

                    final _myFriendCollection = firestore.collection(
                        'Users/${widget.chatId}/chats/$myUsername/messages');

                    final _myFriendChatDocument = firestore
                        .doc('Users/${widget.chatId}/chats/$myUsername');

                    final _myChatDocument = firestore
                        .doc('Users/$myUsername/chats/${widget.chatId}');
                    batch.set(_myMessagesCollection.doc(), {
                      'date': sameTime,
                      'description': myMessage,
                      'user': '$myUsername',
                      'isRead': false,
                      'isDeleted': false,
                      'isPost': false,
                      'isClubPost': false,
                      'postID': '',
                      'isMedia': false,
                      'isSpotlight': false,
                      'poster': '',
                      'collection': '',
                      'isAudio': false,
                      'isLocation': true,
                      'locationName': '$cityName, $countryName',
                      'location': newAddress,
                      'spotlightID': '',
                      'token': '',
                      'mediaURL': [],
                      'audioURL': ''
                    });

                    batch.set(_myFriendCollection.doc(), {
                      'date': sameTime,
                      'description': friendMessage,
                      'user': '$myUsername',
                      'token': token,
                      'isRead': false,
                      'isDeleted': false,
                      'isPost': false,
                      'isClubPost': false,
                      'postID': '',
                      'isMedia': false,
                      'isSpotlight': false,
                      'poster': '',
                      'collection': '',
                      'isAudio': false,
                      'isLocation': true,
                      'locationName': '$cityName, $countryName',
                      'location': newAddress,
                      'mediaURL': [],
                      'spotlightID': '',
                      'audioURL': ''
                    });

                    batch.set(_myFriendChatDocument, {
                      'displayMessage': friendMessage,
                      'isRead': false,
                      'lastMessageTime': sameTime,
                      'isTyping': false,
                      'isRecording': false
                    });
                    batch.set(_myChatDocument, {
                      'displayMessage': myMessage,
                      'isRead': true,
                      'lastMessageTime': sameTime
                    });
                    await Future.delayed(
                        const Duration(milliseconds: 100),
                        () => batch.commit().then((value) {
                              EasyLoading.dismiss();
                              Map<String, dynamic> fields = {
                                'messages location': FieldValue.increment(1),
                                'messages total': FieldValue.increment(1)
                              };
                              General.updateControl(
                                  myUsername: myUsername,
                                  fields: fields,
                                  collectionName: null,
                                  docID: null,
                                  docFields: {});
                              EasyLoading.showSuccess(lang.widgets_chat24,
                                  dismissOnTap: true,
                                  duration: const Duration(seconds: 2));
                            }).catchError((_) {
                              EasyLoading.dismiss();
                              EasyLoading.showError(lang.widgets_chat27,
                                  dismissOnTap: true,
                                  duration: const Duration(seconds: 2));
                            }));
                  } else if (status == PermissionStatus.permanentlyDenied) {
                    openAppSettings();
                  } else {
                    return;
                  }
                }
              });
          // final ListTile _pickAnAddress = ListTile(
          //     horizontalTitleGap: 5.0,
          //     leading: const Icon(Icons.map, color: Colors.black),
          //     title: const Text('Send an address',
          //         style: TextStyle(color: Colors.black)),
          //     onTap: () {
          //       if (isBlocked && !_myUsername.startsWith('Linkspeak') ||
          //           (imBlocked && !_myUsername.startsWith('Linkspeak'))) {
          //       } else {
          //         final ProfilePickAddressScreenArgs args =
          //             ProfilePickAddressScreenArgs(
          //                 isInPost: false,
          //                 isInChat: true,
          //                 somethingChanged: () {},
          //                 changeAddress: (a) {},
          //                 changeAddressName: (a) {},
          //                 changeStateAddressName: (a) {},
          //                 changePoint: (a) {},
          //                 chatHandler: pickAddressChatHandler);
          //         Navigator.pop(context);
          //         Navigator.pushNamed(
          //             context, RouteGenerator.profilePickAddress,
          //             arguments: args);
          //       }
          //     });
          final ListTile _customAddress = ListTile(
              horizontalTitleGap: 5.0,
              leading: const Icon(Icons.map, color: Colors.black),
              title: Text(lang.widgets_chat28,
                  style: const TextStyle(color: Colors.black)),
              onTap: () {
                if (isBlocked && !_myUsername.startsWith('Linkspeak') ||
                    (imBlocked && !_myUsername.startsWith('Linkspeak'))) {
                } else {
                  final ProfilePickAddressScreenArgs args =
                      ProfilePickAddressScreenArgs(
                          isInPost: false,
                          isInChat: true,
                          somethingChanged: () {},
                          changeAddress: (a) {},
                          changeAddressName: (a) {},
                          changeStateAddressName: (a) {},
                          changePoint: (a) {},
                          chatHandler: pickAddressChatHandler);
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, RouteGenerator.customLocationScreen,
                      arguments: args);
                }
              });
          final Column _choices = Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if (assets.length < 10 && !kIsWeb) _camera,
                _choosephotoGallery,
                // _pickAnAddress,
                if (!kIsWeb) _customAddress,
                if (!kIsWeb) _sendCurrentLocation
              ]);

          final SizedBox _box = SizedBox(child: _choices);
          return _box;
        });
  }

  Future<void> uploadMediaHandler(String _myUsername, String myLangCode) async {
    final lang = General.language(context);
    if (!sendingMediaLoading) {
      setState(() {
        sendingMediaLoading = true;
      });
      bool invalidVid =
          assets.any((asset) => asset.videoDuration > Duration(minutes: 10));
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
      if (invalidSizeVid.isNotEmpty ||
          invalidSizeIMG.isNotEmpty ||
          invalidVid) {
        setState(() {
          sendingMediaLoading = false;
        });
        EasyLoading.dismiss();
        if (invalidSizeVid.isNotEmpty) {
          _showDialog(Icons.info_outline, Colors.blue, lang.clubs_create8,
              lang.clubs_newPost4);
        }
        if (invalidSizeIMG.isNotEmpty) {
          _showDialog(Icons.info_outline, Colors.blue, lang.clubs_create8,
              lang.clubs_newPost6);
        }
        if (invalidVid) {
          _showDialog(Icons.warning, Colors.red, lang.widgets_chat29,
              lang.widgets_chat30);
        }
      } else {
        final targetUser =
            await firestore.collection('Users').doc(widget.chatId).get();
        String targetLang = 'en';
        if (targetUser.data()!.containsKey('language')) {
          targetLang = targetUser.get('language');
        }
        final String friendMessage = General.giveMediaMessage(targetLang);
        final String myMessage = General.giveMediaMessage(myLangCode);
        final token = targetUser.get('fcm');
        final retrieveFiles = await getFiles(assets);
        final sendFiles = await uploadFiles(_myUsername, retrieveFiles);
        var batch = firestore.batch();
        final sameTime = Timestamp.now();
        final _myMessagesCollection = firestore
            .collection('Users/$_myUsername/chats/${widget.chatId}/messages');

        final _myFriendCollection = firestore
            .collection('Users/${widget.chatId}/chats/$_myUsername/messages');

        final _myFriendChatDocument =
            firestore.doc('Users/${widget.chatId}/chats/$_myUsername');

        final _myChatDocument =
            firestore.doc('Users/$_myUsername/chats/${widget.chatId}');
        batch.set(_myMessagesCollection.doc(), {
          'date': sameTime,
          'description': myMessage,
          'user': '$_myUsername',
          'isRead': false,
          'isDeleted': false,
          'isPost': false,
          'isClubPost': false,
          'postID': '',
          'isMedia': true,
          'isSpotlight': false,
          'poster': '',
          'collection': '',
          'isAudio': false,
          'isLocation': false,
          'locationName': '',
          'location': '',
          'spotlightID': '',
          'token': '',
          'mediaURL': sendFiles,
          'audioURL': ''
        });

        batch.set(_myFriendCollection.doc(), {
          'date': sameTime,
          'description': friendMessage,
          'user': '$_myUsername',
          'token': token,
          'isRead': false,
          'isDeleted': false,
          'isPost': false,
          'isClubPost': false,
          'postID': '',
          'isMedia': true,
          'isSpotlight': false,
          'poster': '',
          'collection': '',
          'isAudio': false,
          'isLocation': false,
          'locationName': '',
          'location': '',
          'mediaURL': sendFiles,
          'spotlightID': '',
          'audioURL': ''
        });

        batch.set(_myFriendChatDocument, {
          'displayMessage': friendMessage,
          'isRead': false,
          'lastMessageTime': sameTime,
          'isTyping': false,
          'isRecording': false
        });

        batch.set(_myChatDocument, {
          'displayMessage': myMessage,
          'isRead': true,
          'lastMessageTime': sameTime
        });
        final assetsLength = assets.length;
        await Future.delayed(
            const Duration(milliseconds: 100),
            () => batch.commit().then((value) {
                  assets.clear();
                  setState(() => sendingMediaLoading = false);
                  Map<String, dynamic> fields = {
                    'messages media': FieldValue.increment(assetsLength),
                    'messages total': FieldValue.increment(assetsLength)
                  };
                  General.updateControl(
                      myUsername: _myUsername,
                      fields: fields,
                      collectionName: null,
                      docID: null,
                      docFields: {});
                  EasyLoading.showSuccess(lang.widgets_chat31,
                      dismissOnTap: true, duration: const Duration(seconds: 2));
                }).catchError((_) {
                  EasyLoading.showError(lang.widgets_chat32,
                      dismissOnTap: true, duration: const Duration(seconds: 2));
                  setState(() => sendingMediaLoading = false);
                }));
        // if (widget.scrollController.hasClients) if (widget
        //         .scrollController.offset <=
        //     widget.scrollController.position.maxScrollExtent) {
        //   widget.scrollController.animateTo(
        //       widget.scrollController.position.minScrollExtent,
        //       duration: kThemeAnimationDuration,
        //       curve: Curves.linear);
        // }
      }
    }
  }

  Future<void> sendButtonHandler(
      String _myUsername, String controllerText) async {
    final targetUser =
        await firestore.collection('Users').doc(widget.chatId).get();
    final token = targetUser.get('fcm');
    setState(() {
      _isActiveSendButton = false;
    });
    var batch = firestore.batch();
    final String theText = controllerText.trim();
    _textFieldController.clear();
    final sameTime = Timestamp.now();
    final _myMessagesCollection = firestore
        .collection('Users/$_myUsername/chats/${widget.chatId}/messages');

    final _myFriendCollection = firestore
        .collection('Users/${widget.chatId}/chats/$_myUsername/messages');

    final _myFriendChatDocument =
        firestore.doc('Users/${widget.chatId}/chats/$_myUsername');

    final _myChatDocument =
        firestore.doc('Users/$_myUsername/chats/${widget.chatId}');
    batch.set(_myMessagesCollection.doc(), {
      'date': sameTime,
      'description': '$theText',
      'user': '$_myUsername',
      'isRead': false,
      'isDeleted': false,
      'isPost': false,
      'isClubPost': false,
      'postID': '',
      'isMedia': false,
      'isSpotlight': false,
      'poster': '',
      'collection': '',
      'isAudio': false,
      'isLocation': false,
      'locationName': '',
      'location': '',
      'spotlightID': '',
      'token': '',
      'mediaURL': [],
      'audioURL': ''
    });

    batch.set(_myFriendCollection.doc(), {
      'date': sameTime,
      'description': '$theText',
      'user': '$_myUsername',
      'token': token,
      'isRead': false,
      'isDeleted': false,
      'isPost': false,
      'isClubPost': false,
      'postID': '',
      'isMedia': false,
      'isSpotlight': false,
      'poster': '',
      'collection': '',
      'isAudio': false,
      'isLocation': false,
      'locationName': '',
      'location': '',
      'mediaURL': [],
      'spotlightID': '',
      'audioURL': ''
    });

    batch.set(_myFriendChatDocument, {
      'displayMessage': '$theText',
      'isRead': false,
      'lastMessageTime': sameTime,
      'isTyping': false,
      'isRecording': false
    });

    batch.set(_myChatDocument, {
      'displayMessage': '$theText',
      'isRead': true,
      'lastMessageTime': sameTime
    });
    await Future.delayed(
        const Duration(milliseconds: 100),
        () => batch.commit().then((value) {
              Map<String, dynamic> fields = {
                'messages text': FieldValue.increment(1),
                'messages total': FieldValue.increment(1)
              };
              General.updateControl(
                  myUsername: _myUsername,
                  fields: fields,
                  collectionName: null,
                  docID: null,
                  docFields: {});
            }));
    // if (widget.scrollController.hasClients) if (widget
    //         .scrollController.offset <=
    //     widget.scrollController.position.maxScrollExtent) {
    //   widget.scrollController.animateTo(
    //       widget.scrollController.position.minScrollExtent,
    //       duration: kThemeAnimationDuration,
    //       curve: Curves.linear);
    // }
  }

  Future<void> sendAudioHandler(
      String _myUsername, dynamic _myFriend, String myLangCode) async {
    final lang = General.language(context);
    if (!sendingAudioLoading) {
      setState(() {
        sendingAudioLoading = true;
        stopTimer = true;
      });
      final isRecording = await recorder.isRecording();
      File? audioFile;
      if (isRecording) {
        final fileName = await recorder.stop();
        audioFile = File(fileName!);
        currentAudioFile = audioFile;
      } else {
        audioFile = currentAudioFile;
      }
      if (exists) await _myFriend.update({'isRecording': false});
      final sendFile = await uploadFile(_myUsername, audioFile!);
      final targetUser =
          await firestore.collection('Users').doc(widget.chatId).get();
      String targetLang = 'en';
      if (targetUser.data()!.containsKey('language')) {
        targetLang = targetUser.get('language');
      }
      final String friendMessage = General.giveAudioMessage(targetLang);
      final String myMessage = General.giveAudioMessage(myLangCode);
      final token = targetUser.get('fcm');
      var batch = firestore.batch();
      final sameTime = Timestamp.now();
      final _myMessagesCollection = firestore
          .collection('Users/$_myUsername/chats/${widget.chatId}/messages');
      final _myFriendCollection = firestore
          .collection('Users/${widget.chatId}/chats/$_myUsername/messages');
      final _myFriendChatDocument =
          firestore.doc('Users/${widget.chatId}/chats/$_myUsername');
      final _myChatDocument =
          firestore.doc('Users/$_myUsername/chats/${widget.chatId}');
      batch.set(_myMessagesCollection.doc(), {
        'date': sameTime,
        'description': myMessage,
        'user': '$_myUsername',
        'isRead': false,
        'isDeleted': false,
        'isPost': false,
        'isClubPost': false,
        'postID': '',
        'isMedia': false,
        'isSpotlight': false,
        'poster': '',
        'collection': '',
        'isAudio': true,
        'isLocation': false,
        'locationName': '',
        'location': '',
        'spotlightID': '',
        'token': '',
        'mediaURL': [],
        'audioURL': sendFile
      });
      batch.set(_myFriendCollection.doc(), {
        'date': sameTime,
        'description': friendMessage,
        'user': '$_myUsername',
        'token': token,
        'isRead': false,
        'isDeleted': false,
        'isPost': false,
        'isClubPost': false,
        'postID': '',
        'isMedia': false,
        'isSpotlight': false,
        'poster': '',
        'collection': '',
        'isAudio': true,
        'isLocation': false,
        'locationName': '',
        'location': '',
        'mediaURL': [],
        'spotlightID': '',
        'audioURL': sendFile
      });
      batch.set(_myFriendChatDocument, {
        'displayMessage': friendMessage,
        'isRead': false,
        'lastMessageTime': sameTime,
        'isTyping': false,
        'isRecording': false
      });
      batch.set(_myChatDocument, {
        'displayMessage': myMessage,
        'isRead': true,
        'lastMessageTime': sameTime
      });
      await Future.delayed(
          const Duration(milliseconds: 100),
          () => batch.commit().then((value) {
                currentAudioFile = null;
                setState(() {
                  sendingAudioLoading = false;
                  isRecordingAudio = false;
                });
                Map<String, dynamic> fields = {
                  'messages audio': FieldValue.increment(1),
                  'messages total': FieldValue.increment(1)
                };
                General.updateControl(
                    myUsername: _myUsername,
                    fields: fields,
                    collectionName: null,
                    docID: null,
                    docFields: {});
                EasyLoading.showSuccess(lang.widgets_chat33,
                    dismissOnTap: true, duration: const Duration(seconds: 2));
                stopTimer = false;
                // if (widget.scrollController.hasClients) if (widget
                //         .scrollController.offset <=
                //     widget.scrollController.position.maxScrollExtent) {
                //   widget.scrollController.animateTo(
                //       widget.scrollController.position.minScrollExtent,
                //       duration: kThemeAnimationDuration,
                //       curve: Curves.linear);
                // }
              }).catchError((_) {
                EasyLoading.showError(lang.widgets_chat27,
                    dismissOnTap: true, duration: const Duration(seconds: 2));
                setState(() {
                  sendingAudioLoading = false;
                });
              }));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        offTyping();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.resumed:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    firestore
        .collection('Users/$myUsername/chats')
        .doc('${widget.chatId}')
        .get()
        .then((value) {
      if (value.exists) {
        exists = true;
        offTyping = () => _offTyping(myUsername);
        WidgetsBinding.instance.addObserver(this);
        final users = firestore.collection('Users');
        final myBlocked =
            users.doc(myUsername).collection('Blocked').snapshots();
        final theirBlocked =
            users.doc(widget.chatId).collection('Blocked').snapshots();
        myBlocked.listen((event) {
          final info = event.docs;
          final theyBlocked = info.any((id) => id.id == widget.chatId);
          if (theyBlocked) {
            if (!isBlocked) {
              isBlocked = true;
              setState(() {});
            }
          } else {
            if (isBlocked) {
              isBlocked = false;
              setState(() {});
            }
          }
        });
        theirBlocked.listen((event) {
          final info = event.docs;
          final iBlocked = info.any((id) => id.id == myUsername);
          if (iBlocked) {
            if (!imBlocked) {
              imBlocked = true;
              setState(() {});
            }
          } else {
            if (imBlocked) {
              imBlocked = false;
              setState(() {});
            }
          }
        });
      } else {
        firestore
            .collection('Users/$myUsername/chats/${widget.chatId}/messages')
            .snapshots()
            .listen((event) {
          if (event.docs.isNotEmpty) {
            exists = true;
            setState(() {});
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldController.dispose();
    recorder.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final myLangCode =
        Provider.of<ThemeModel>(context, listen: false).serverLangCode;
    final lang = General.language(context);
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _deviceWidth = General.widthQuery(context);
    final _inputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.grey.shade300));
    final _myFriend =
        firestore.collection('Users/${widget.chatId}/chats').doc(_myUsername);
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      AnimatedContainer(
          height: (assets.isEmpty) ? 0 : 75.0,
          width: (assets.isEmpty) ? 0 : _deviceWidth,
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.all(8.0),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Noglow(
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                      ...assets.map((media) {
                        final int _currentIndex = assets.indexOf(media);
                        return Container(
                            height: 50.0,
                            width: 50.0,
                            margin: const EdgeInsets.all(5.0),
                            child: Stack(children: <Widget>[
                              Container(
                                  key: UniqueKey(),
                                  width: 50.0,
                                  height: 50.0,
                                  child: _selectedAssetWidget(_currentIndex)),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        if (sendingMediaLoading) {
                                        } else {
                                          _removeMedia(_currentIndex);
                                        }
                                      },
                                      child: Icon(Icons.cancel,
                                          color: Colors.redAccent.shade400)))
                            ]));
                      }).toList()
                    ]))),
                GestureDetector(
                    onTap: () async {
                      if (isBlocked && !_myUsername.startsWith('Linkspeak') ||
                          (imBlocked && !_myUsername.startsWith('Linkspeak'))) {
                      } else {
                        uploadMediaHandler(_myUsername, myLangCode);
                      }
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircleAvatar(
                            child: (sendingMediaLoading)
                                ? SizedBox(
                                    height: 10.0,
                                    width: 10.0,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.50, color: _accentColor))
                                : Icon(Icons.arrow_upward,
                                    color: _accentColor, size: 18.0),
                            backgroundColor: _primaryColor)))
              ])),
      ConstrainedBox(
          constraints: BoxConstraints(minHeight: 80, maxHeight: 320),
          child: Container(
              padding:
                  const EdgeInsets.only(left: 7.0, right: 7.0, bottom: 15.0),
              child: Row(children: <Widget>[
                Expanded(
                    child: TextField(
                        minLines: 1,
                        maxLines: 5,
                        style: const TextStyle(color: Colors.black),
                        controller: _textFieldController,
                        onChanged: (value) async {
                          if (value.replaceAll(' ', '') == '' ||
                              value.trim() == '') {
                            if (_isActiveSendButton) {
                              setState(() {
                                _isActiveSendButton = false;
                              });
                              if (exists) {
                                if (isBlocked &&
                                        !_myUsername.startsWith('Linkspeak') ||
                                    (imBlocked &&
                                        !_myUsername.startsWith('Linkspeak'))) {
                                } else {
                                  await _myFriend.update({
                                    'isTyping': false,
                                    'isRecording': false,
                                  });
                                }
                              }
                            }
                          }
                          if (value.isNotEmpty) {
                            if (value.replaceAll(' ', '') == '' ||
                                value.trim() == '') {
                              if (_isActiveSendButton) {
                                setState(() {
                                  _isActiveSendButton = false;
                                });
                                if (exists) {
                                  if (isBlocked &&
                                          !_myUsername
                                              .startsWith('Linkspeak') ||
                                      (imBlocked &&
                                          !_myUsername
                                              .startsWith('Linkspeak'))) {
                                  } else {
                                    await _myFriend.update({
                                      'isTyping': false,
                                      'isRecording': false,
                                    });
                                  }
                                }
                              }
                            } else {
                              if (!_isActiveSendButton) {
                                setState(() {
                                  _isActiveSendButton = true;
                                });
                                if (exists) {
                                  if (isBlocked &&
                                          !_myUsername
                                              .startsWith('Linkspeak') ||
                                      (imBlocked &&
                                          !_myUsername
                                              .startsWith('Linkspeak'))) {
                                  } else {
                                    await _myFriend.update({
                                      'isTyping': true,
                                      'isRecording': false,
                                    });
                                  }
                                }
                              }
                            }
                          } else {
                            if (_isActiveSendButton) {
                              setState(() {
                                _isActiveSendButton = false;
                              });
                              if (exists) {
                                if (isBlocked &&
                                        !_myUsername.startsWith('Linkspeak') ||
                                    (imBlocked &&
                                        !_myUsername.startsWith('Linkspeak'))) {
                                } else {
                                  await _myFriend.update({
                                    'isTyping': false,
                                    'isRecording': false
                                  });
                                }
                              }
                            }
                          }
                        },
                        decoration: InputDecoration(
                            suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.all(0.0),
                                      icon: Transform.rotate(
                                          angle: 120 * pi / 180,
                                          child: const Icon(
                                              Icons.attachment_outlined,
                                              size: 25.0,
                                              color: kIsWeb
                                                  ? Colors.transparent
                                                  : Colors.grey)),
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        if (kIsWeb ||
                                            sendingMediaLoading ||
                                            (isBlocked &&
                                                !_myUsername
                                                    .startsWith('Linkspeak')) ||
                                            (imBlocked &&
                                                !_myUsername
                                                    .startsWith('Linkspeak'))) {
                                        } else {
                                          mediaButtonHandler(
                                              _myUsername, myLangCode);
                                        }
                                      }),
                                  IconButton(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(0.0),
                                      onPressed: () async {
                                        final String controllerText =
                                            _textFieldController.value.text;
                                        if (controllerText.isEmpty ||
                                            controllerText.replaceAll(
                                                    ' ', '') ==
                                                '' ||
                                            controllerText.trim() == '' ||
                                            (isBlocked &&
                                                !_myUsername
                                                    .startsWith('Linkspeak')) ||
                                            (imBlocked &&
                                                !_myUsername
                                                    .startsWith('Linkspeak'))) {
                                        } else {
                                          sendButtonHandler(
                                              _myUsername, controllerText);
                                        }
                                      },
                                      icon: Icon(Icons.send,
                                          color: _isActiveSendButton
                                              ? _primaryColor
                                              : Colors.grey,
                                          size: 18.0))
                                ]),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            hintText: lang.widgets_chat34,
                            border: _inputBorder,
                            errorBorder: _inputBorder,
                            enabledBorder: _inputBorder,
                            focusedBorder: _inputBorder,
                            disabledBorder: _inputBorder,
                            hintStyle:
                                const TextStyle(color: Colors.black26)))),
                Container(
                    child: IconButton(
                        icon: kIsWeb
                            ? Container()
                            : (!isRecordingAudio)
                                ? const Icon(Icons.mic, color: Colors.grey)
                                : Container(),
                        onPressed: (isRecordingAudio || kIsWeb)
                            ? () {}
                            : () async {
                                if (isBlocked &&
                                        !_myUsername.startsWith('Linkspeak') ||
                                    (imBlocked &&
                                        !_myUsername.startsWith('Linkspeak'))) {
                                } else {
                                  PermissionStatus status =
                                      await Permission.microphone.request();
                                  if (status == PermissionStatus.granted) {
                                    recorder.start();
                                    if (exists)
                                      await _myFriend.update({
                                        'isRecording': true,
                                        'isTyping': false,
                                      });
                                    setState(() {
                                      isRecordingAudio = true;
                                    });
                                  }
                                }
                              }))
              ]))),
      AnimatedContainer(
          height: isRecordingAudio ? 100.0 : 0.0,
          duration: const Duration(milliseconds: 100),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isRecordingAudio)
                  IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.grey, size: 25.0),
                      iconSize: 25.0,
                      onPressed: () async {
                        if (!sendingAudioLoading) {
                          recorder.stop();
                          if (exists)
                            await _myFriend.update({
                              'isRecording': false,
                              'isTyping': false,
                            });
                          setState(() {
                            isRecordingAudio = false;
                          });
                        }
                      }),
                if (isRecordingAudio)
                  Container(
                      height: 100.0,
                      width: 160.0,
                      padding: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topRight: const Radius.circular(50.0),
                              topLeft: const Radius.circular(50.0)),
                          color: Colors.red),
                      child: Center(
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                            const Icon(Icons.mic,
                                color: Colors.white, size: 30.0),
                            const SizedBox(height: 5.0),
                            ChatAudioStopwatch(stopTimer)
                          ]))),
                if (isRecordingAudio)
                  IconButton(
                      onPressed: () async {
                        if (isBlocked && !_myUsername.startsWith('Linkspeak') ||
                            (imBlocked &&
                                !_myUsername.startsWith('Linkspeak'))) {
                        } else {
                          sendAudioHandler(_myUsername, _myFriend, myLangCode);
                        }
                      },
                      icon: sendingAudioLoading
                          ? const SizedBox(
                              height: 10.0,
                              width: 10.0,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.50, color: Colors.grey))
                          : Icon(Icons.send, color: _primaryColor, size: 25.0),
                      iconSize: 25.0)
              ]))
    ]);
  }
}
