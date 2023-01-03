import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as thumb;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../general.dart';
import '../../routes.dart';
import '../loading/flareCollectionSkeleton.dart';
import '../models/flare.dart';
import '../models/flareCollectionModel.dart';
import '../models/screenArguments.dart';
import '../providers/adminFlaresProvider.dart';
import '../providers/flareCollectionHelper.dart';
import '../providers/flareProfileProvider.dart';
import '../providers/flareTabProvider.dart';
import '../providers/fullFlareHelper.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../screens/feedScreen.dart';
import '../widgets/common/chatprofileImage.dart';
import 'addedFlare.dart';
import 'flareBanner.dart';
import 'flareWidget.dart';

enum ViewMode { normal, edit }

class FlareTabWidget extends StatefulWidget {
  final bool isInFeed;
  final bool isInAdmin;
  const FlareTabWidget(this.isInFeed, this.isInAdmin);

  @override
  State<FlareTabWidget> createState() => _FlareTabWidgetState();
}

class _FlareTabWidgetState extends State<FlareTabWidget>
    with AutomaticKeepAliveClientMixin {
  late ScrollController currentController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final _mediaInfo = FlutterVideoInfo();
  List<Flare> toRemove = [];
  List<Flare> toAdd = [];
  List<AssetEntity> assets = [];
  late Future<void> initCollection;
  bool isLoading = false;
  bool hasBanner = false;
  bool stateHidden = false;
  ViewMode viewMode = ViewMode.normal;
  static const _alwaysScrollable = const AlwaysScrollableScrollPhysics();
  static const _bouncy = const BouncingScrollPhysics(parent: _alwaysScrollable);
  void setHasBanner(bool has) {
    setState(() {
      hasBanner = has;
    });
  }

  void visitProfile(String myUsername, String username) {
    if (username != myUsername) {
      final OtherProfileScreenArguments args = OtherProfileScreenArguments(
        otherProfileId: username,
      );
      Navigator.pushNamed(context, RouteGenerator.posterProfileScreen,
          arguments: args);
    } else {
      Navigator.pushNamed(context, RouteGenerator.myProfileScreen);
    }
  }

  void goToFlareProfile(String username) {
    final FlareProfileScreenArgs args = FlareProfileScreenArgs(username);
    Navigator.pushNamed(context, RouteGenerator.flareProfileScreen,
        arguments: args);
  }

  void initFlare(
      {required String poster,
      required String flareID,
      required String collectionID,
      required String collectionName,
      required List<Flare> tempFlares}) {
    if (!tempFlares.any((element) => element.flareID == flareID)) {
      final FlareHelper instance = FlareHelper();
      final flare = Flare(
          instance: instance,
          poster: poster,
          flareID: flareID,
          collectionID: collectionID,
          collectionName: collectionName,
          isAdded: false,
          backgroundColor: Colors.blue,
          gradientColor: Colors.yellow,
          asset: null,
          path: '');
      flare.flareSetter();
      tempFlares.add(flare);
    }
  }

  Future<void> _initCollection(
      {required String posterID,
      required String myUsername,
      required String collectionID,
      required String collectionName,
      required bool isEmptyFlare,
      required dynamic initializeCollection,
      required ScrollController currentController}) async {
    if (isEmptyFlare) {
      return;
    } else {
      List<Flare> tempFlares = [];
      final int limit = widget.isInFeed ? 7 : 60;
      final bool isMyCollection = posterID == myUsername;
      final users = firestore.collection('Users');
      final flares = firestore.collection('Flares');
      final theirUser = users.doc(posterID);
      final getThem = await theirUser.get();
      final status = getThem.get('Status');
      final theirFlare = flares.doc(posterID);
      final thisCollection =
          theirFlare.collection('collections').doc(collectionID);
      final getFlares = await thisCollection
          .collection('flares')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      final docs = getFlares.docs;
      if (docs.isNotEmpty) {
        for (var doc in docs) {
          final flareID = doc.id;
          initFlare(
              poster: posterID,
              collectionID: collectionID,
              flareID: flareID,
              collectionName: collectionName,
              tempFlares: tempFlares);
        }
      }
      final myUser = users.doc(myUsername);
      final myBlocked = await myUser.collection('Blocked').doc(posterID).get();
      final myMuted = await myUser.collection('Muted').doc(posterID).get();
      final theirBlocked =
          await theirUser.collection('Blocked').doc(myUsername).get();
      final theirHidden = await theirFlare
          .collection('Hidden Collections')
          .doc(collectionID)
          .get();
      bool isMuted = myMuted.exists;
      bool isBanned = status == 'Banned';
      bool isBlocked = myBlocked.exists;
      bool imBlocked = theirBlocked.exists;
      bool isHidden = theirHidden.exists;
      stateHidden = isHidden;
      initializeCollection(
          paramposterID: posterID,
          paramCollectionID: collectionID,
          paramcollectionName: collectionName,
          paramflares: tempFlares,
          paramisMyCollection: isMyCollection,
          paramisMuted: isMuted,
          paramIsHidden: isHidden,
          paramisBanned: isBanned,
          paramisBlocked: isBlocked,
          paramimBlocked: imBlocked,
          paramController: currentController,
          paramEmpty: false);
    }
  }

  Future<List<String>> uploadFile(String myUsername, String collectionTitle,
      String flareID, void Function() flag, File file) async {
    final DateTime _rightNow = DateTime.now();
    final String thumbnailID = _rightNow.toString();
    final String filePath = file.absolute.path;
    final appDir = await getApplicationDocumentsDirectory();
    final path = appDir.path;
    final thumbnailInitialPath = '$path/$thumbnailID.jpeg';
    final name = filePath.split('/').last;
    File? thumbnailFile;
    final type = lookupMimeType(name);
    if (type!.startsWith('image')) {
      var recognitions = await FlutterNsfw.getPhotoNSFWScore(filePath);
      if (recognitions > 0.759) {
        flag();
      }
    } else {
      final vidInfo = await _mediaInfo.getVideoInfo(filePath);
      final vidWidth = vidInfo!.width;
      final vidHeight = vidInfo.height;
      final greaterHeight = vidHeight! > 150;
      final greaterWidth = vidWidth! > 110;
      final uint8list = await thumb.VideoThumbnail.thumbnailData(
          video: filePath,
          imageFormat: thumb.ImageFormat.JPEG,
          maxHeight: greaterHeight ? 150 : vidHeight,
          maxWidth: greaterWidth ? 110 : vidWidth,
          quality: 100);
      final thumbnail = File(thumbnailInitialPath);
      thumbnail.writeAsBytesSync(List.from(uint8list!));
      final generatedThumbnail = File(thumbnail.absolute.path);
      thumbnailFile = generatedThumbnail;
      final recognitions = await FlutterNsfw.detectNSFWVideo(
          videoPath: filePath,
          frameWidth: vidWidth,
          frameHeight: vidHeight,
          nsfwThreshold: 0.759,
          durationPerFrame: 1000);
      if (recognitions) {
        flag();
      }
    }
    final String ref = 'Flares/$myUsername/$collectionTitle/$flareID/$name';
    var storageReference = storage.ref(ref);
    var uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() {
      storageReference = storage.ref(ref);
    });
    final mainURL = await storageReference.getDownloadURL();
    if (thumbnailFile != null) {
      var reference =
          'Flares/$myUsername/$collectionTitle/$flareID/$thumbnailID';
      var storageRef = storage.ref(reference);
      var task = storageRef.putFile(thumbnailFile);
      await task.whenComplete(() {
        storageRef = storage.ref(reference);
      });
      final thumbnailURL = await storageRef.getDownloadURL();
      return [mainURL, thumbnailURL];
    } else {
      return [mainURL, mainURL];
    }
  }

  Future<void> addFlare(
      String myUsername,
      WriteBatch batch,
      Flare addedFlare,
      CollectionReference<Map<String, dynamic>> additions,
      DocumentReference<Map<String, dynamic>> myUserCollection,
      DocumentReference<Map<String, dynamic>> currentCollection,
      DocumentReference<Map<String, dynamic>> reviewalDoc) async {
    final _rightNow = DateTime.now();
    final options = SetOptions(merge: true);
    bool hasNSFW = false;
    void flag() => hasNSFW = true;
    final flareID = addedFlare.flareID;
    final collectionID = addedFlare.collectionID;
    final collectionTitle = addedFlare.collectionName;
    final currentFile = await addedFlare.asset!.file;
    final thisAddedFlare = additions.doc(flareID);
    final thisFlare = currentCollection.collection('flares').doc(flareID);
    final thisProfileFlare = myUserCollection.collection('flares').doc(flareID);
    final thisReviewalDoc = reviewalDoc.collection('flares').doc(flareID);
    var urls = await uploadFile(
        myUsername, collectionTitle, flareID, flag, currentFile!);
    final String mediaURL = urls[0];
    final String thumbnail = urls[1];
    final Color backgroundColor = addedFlare.backgroundColor;
    final Color gradientColor = addedFlare.gradientColor;
    final int background = backgroundColor.value;
    final int gradient = gradientColor.value;
    final profileInfo = {
      'poster': myUsername,
      'ID': flareID,
      'collectionID': collectionID,
      'collection': collectionTitle,
      'date': _rightNow
    };
    final flareInfo = {
      'poster': myUsername,
      'ID': flareID,
      'collectionID': collectionID,
      'collection': collectionTitle,
      'date': _rightNow,
      'hasNSFW': hasNSFW,
      'mediaURL': mediaURL,
      'thumbnail': thumbnail,
      'likes': 0,
      'comments': 0,
      'views': 0,
      'background': background,
      'gradient': gradient
    };
    final reviewalInfo = {
      'poster': myUsername,
      'ID': flareID,
      'collectionID': collectionID,
      'flareCollection': collectionTitle,
      'date': _rightNow,
      'isFlare': true,
      'flareID': flareID,
      'isPost': false,
      'isClubPost': false,
      'clubName': ''
    };
    batch.set(thisFlare, flareInfo, options);
    batch.set(thisProfileFlare, profileInfo, options);
    batch.set(thisAddedFlare, {'date': _rightNow, 'flareID': flareID}, options);
    if (hasNSFW) {
      batch.set(thisReviewalDoc, reviewalInfo, options);
      batch.set(reviewalDoc, {'date': _rightNow}, options);
    }
  }

  Future<void> removeFlare(
      String myUsername,
      String username,
      WriteBatch batch,
      Flare removedFlare,
      CollectionReference<Map<String, dynamic>> deletions,
      DocumentReference<Map<String, dynamic>> myUserDoc,
      DocumentReference<Map<String, dynamic>> myFlareDoc,
      DocumentReference<Map<String, dynamic>> myUserCollection,
      DocumentReference<Map<String, dynamic>> currentCollection,
      DocumentReference<Map<String, dynamic>> myUserDeletedCollection) async {
    final _rightNow = DateTime.now();
    final options = SetOptions(merge: true);
    final flareID = removedFlare.flareID;
    final collectionID = removedFlare.collectionID;
    final thisDeletion = deletions.doc(flareID);
    final deletedFlares = firestore.collection('Deleted Flares').doc(flareID);
    final thisFlare = currentCollection.collection('flares').doc(flareID);
    final myDeletedFlares =
        myUserDeletedCollection.collection('flares').doc(flareID);
    final flareDeletedFlares = myFlareDoc
        .collection('deleted')
        .doc(collectionID)
        .collection('flares')
        .doc(flareID);
    final thisProfileFlare = myUserCollection.collection('flares').doc(flareID);
    final getFlare = await thisFlare.get();
    if (getFlare.exists) {
      dynamic getter(String path) => getFlare.get(path);
      int unlikes = 0;
      final viewrs = getter('views');
      final likes = getter('likes');
      final comments = getter('comments');
      Map<String, dynamic> deletedInfo = getFlare.data()!;
      Map<String, dynamic> de = {
        'date deleted': _rightNow,
        'deleted by': myUsername
      };
      deletedInfo.addAll(de);
      if (getFlare.data()!.containsKey('unlikes')) {
        unlikes = getter('unlikes');
      }
      batch.set(
          currentCollection,
          {
            'numOfFlares': FieldValue.increment(-1),
            'deleted': FieldValue.increment(1),
            'likes': FieldValue.increment(-likes),
            'unlikes': FieldValue.increment(-unlikes),
            'comments': FieldValue.increment(-comments),
            'views': FieldValue.increment(-viewrs)
          },
          options);
      final getMyFlareDoc = await myFlareDoc.get();
      if (getMyFlareDoc.exists)
        batch.set(
            myFlareDoc,
            {
              'numOfDeletedFlares': FieldValue.increment(1),
              'numOfFlares': FieldValue.increment(-1),
              'numOfViews': FieldValue.increment(-viewrs),
              'numOfLikes': FieldValue.increment(-likes),
              'numOfUnlikes': FieldValue.increment(-unlikes),
              'numOfComments': FieldValue.increment(-comments),
            },
            options);
      final getMyUserDoc = await myUserDoc.get();
      if (getMyUserDoc.exists)
        batch.set(
            myUserDoc,
            {
              'numOfDeletedFlares': FieldValue.increment(1),
              'numOfFlares': FieldValue.increment(-1)
            },
            options);
      Map<String, dynamic> fields = {
        'flares': FieldValue.increment(-1),
        'deleted flares': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'flarePoster': username,
        'collection': collectionID,
        'flare': flareID,
        'date': _rightNow
      };
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'deleted flares',
          docID: '$flareID',
          docFields: docFields);
      batch.set(flareDeletedFlares, deletedInfo, options);
      batch.set(myDeletedFlares, deletedInfo, options);
      batch.set(deletedFlares, deletedInfo, options);
      batch.set(thisDeletion, deletedInfo, options);
      batch.delete(thisProfileFlare);
      batch.delete(thisFlare);
    }
  }

  Future<void> hideCollection(
      String myUsername, String collectionID, WriteBatch batch) async {
    var now = DateTime.now();
    var thisHiddenCollection =
        firestore.doc('Flares/$myUsername/Hidden Collections/$collectionID');
    Map<String, dynamic> fields = {
      'flare collections hidden': FieldValue.increment(1)
    };
    Map<String, dynamic> docFields = {'date': now, 'collection': collectionID};
    var options = SetOptions(merge: true);
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'Hidden Collections',
        docID: collectionID,
        docFields: docFields);
    batch.set(thisHiddenCollection, fields, options);
  }

  Future<void> unhideCollection(
      String myUsername, String collectionID, WriteBatch batch) async {
    var now = DateTime.now();
    var thisHiddenCollection =
        firestore.doc('Flares/$myUsername/Hidden Collections/$collectionID');
    var getHidden = await thisHiddenCollection.get();
    var data = getHidden.data();
    var thisUnhiddenCollection =
        firestore.doc('Flares/$myUsername/Unhidden Collections/$collectionID');
    Map<String, dynamic> fields = {
      'flare collections hidden': FieldValue.increment(-1),
      'flare collections unhidden': FieldValue.increment(1)
    };
    Map<String, dynamic> docFields = {'date': now, 'collection': collectionID};
    Map<String, dynamic> unhidFields = {
      'date unhidden': now,
      'collection': collectionID
    };
    unhidFields.addAll(data!);
    var options = SetOptions(merge: true);
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'Unhidden Collections',
        docID: collectionID,
        docFields: docFields);
    batch.delete(thisHiddenCollection);
    batch.set(thisUnhiddenCollection, unhidFields, options);
  }

  Future<void> handleModification(
      String username,
      String collectionID,
      String collectionName,
      dynamic initialize,
      ScrollController currentController) async {
    final lang = General.language(context);
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      final String myUsername =
          Provider.of<MyProfile>(context, listen: false).getUsername;
      var batch = firestore.batch();
      final options = SetOptions(merge: true);
      final DateTime _rightNow = DateTime.now();
      final id = _rightNow.toString();
      final myUserDoc = firestore.collection('Users').doc(username);
      final myUserFlares = myUserDoc.collection('My Flares');
      final myUserCollection = myUserFlares.doc(collectionID);
      final myFlareDoc = firestore.collection('Flares').doc(username);
      final myCollections = myFlareDoc.collection('collections');
      final currentCollection = myCollections.doc(collectionID);
      final reviewalDoc = firestore.collection('Review').doc(collectionID);
      final hiddenDoc = await firestore
          .doc('Flares/$username/Hidden Collections/$collectionID')
          .get();
      final alreadyHidden = hiddenDoc.exists;
      final control = firestore.collection('Control').doc('Details');
      final modifications =
          currentCollection.collection('modifications').doc(id);
      final additions = modifications.collection('additions');
      final deletions = modifications.collection('deletions');
      if (toAdd.isNotEmpty) {
        final numAdded = toAdd.length;
        final toAddReversed = toAdd.reversed.toList();
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
        for (var addedFlare in toAddReversed) {
          await addFlare(username, batch, addedFlare, additions,
              myUserCollection, currentCollection, reviewalDoc);
        }
        batch.update(control, {'flares': FieldValue.increment(numAdded)});
        batch.set(myUserDoc, {'numOfFlares': FieldValue.increment(numAdded)},
            options);
        batch.set(myFlareDoc, {'numOfFlares': FieldValue.increment(numAdded)},
            options);
        batch.set(currentCollection, {'added': FieldValue.increment(numAdded)},
            options);
      }
      if (toRemove.isNotEmpty) {
        final myUserDeletionCollection =
            myUserDoc.collection('Deleted Flares').doc(collectionID);
        for (var removedFlare in toRemove) {
          await removeFlare(
              myUsername,
              username,
              batch,
              removedFlare,
              deletions,
              myUserDoc,
              myFlareDoc,
              myUserCollection,
              currentCollection,
              myUserDeletionCollection);
        }
        batch.set(myUserDeletionCollection, {'date': _rightNow}, options);
        batch.set(myFlareDoc.collection('deleted').doc(collectionID),
            {'date': _rightNow}, options);
      }
      batch.set(
          currentCollection,
          {
            'last modified': _rightNow,
            'modifications': FieldValue.increment(1)
          },
          options);
      batch.set(modifications, {'date': _rightNow}, options);
      if (stateHidden && !alreadyHidden) {
        await hideCollection(username, collectionID, batch);
      } else if (!stateHidden && alreadyHidden) {
        await unhideCollection(username, collectionID, batch);
      }
      return batch.commit().then((value) {
        setState(() {
          isLoading = false;
          viewMode = ViewMode.normal;
          assets.clear();
          toAdd.clear();
          toRemove.clear();
          initCollection = _initCollection(
              posterID: username,
              myUsername: myUsername,
              collectionID: collectionID,
              collectionName: collectionName,
              initializeCollection: initialize,
              currentController: currentController,
              isEmptyFlare: false);
        });
        EasyLoading.showSuccess(lang.flares_profile6,
            duration: const Duration(seconds: 1), dismissOnTap: true);
      }).catchError((_) {
        setState(() {
          isLoading = false;
        });
        EasyLoading.showError(lang.flares_profile7,
            duration: const Duration(seconds: 1), dismissOnTap: true);
      });
    }
  }

  Widget giveStacked(String text, bool isSub) => Stack(children: <Widget>[
        Text(text,
            softWrap: isSub,
            style: TextStyle(
                fontSize: isSub ? 13.0 : 15.0,
                fontWeight: isSub ? FontWeight.normal : FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3.00
                  ..color = Colors.black)),
        Text(text,
            softWrap: isSub,
            style: TextStyle(
                fontSize: isSub ? 13.0 : 15.0,
                fontWeight: isSub ? FontWeight.normal : FontWeight.bold,
                color: Colors.white))
      ]);

  Widget giveText(bool doesHave, String text, bool isSub) {
    if (doesHave)
      return giveStacked(text, isSub);
    else
      return Text(text,
          softWrap: isSub,
          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black));
  }

  Widget buildMoreButton(String username) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    return GestureDetector(
        onTap: () => goToFlareProfile(username),
        child: Container(
            height: 50,
            width: 50,
            decoration:
                BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
            child: Center(
                child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Transform.rotate(
                              angle: 225 * pi / 180,
                              child: Icon(Icons.transit_enterexit_rounded,
                                  color: _accentColor))
                        ])))));
  }

  String _generateFlareId(String _username) {
    final DateTime _rightNowUTC = DateTime.now().toUtc();
    final String _postDate = '${DateFormat('dMyHmsS').format(_rightNowUTC)}';
    final String _theID = '(flare)$_username-$_postDate';
    return _theID;
  }

  Future<void> _choose(Color primaryColor, Color accentColor, String myUsername,
      String _collectionID, String _collectionName, dynamic lang) async {
    Navigator.pop(context);
    final int _maxAssets = 60;
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
          var path = result.id;
          assets.add(result);
          final _flareID = _generateFlareId(myUsername);
          final _flare = Flare(
              instance: FlareHelper(),
              poster: myUsername,
              flareID: _flareID,
              collectionID: _collectionID,
              collectionName: _collectionName,
              isAdded: true,
              asset: result,
              backgroundColor: primaryColor,
              gradientColor: accentColor,
              path: path);
          toAdd.add(_flare);
        }
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _chooseCamera(
      Color primaryColor,
      Color accentColor,
      String myUsername,
      String _collectionID,
      String _collectionName,
      dynamic lang) async {
    Navigator.pop(context);
    final AssetEntity? _result = await CameraPicker.pickFromCamera(context,
        pickerConfig: CameraPickerConfig(
            resolutionPreset: ResolutionPreset.high,
            enableRecording: true,
            maximumRecordingDuration: const Duration(seconds: 60),
            textDelegate: lang.cameraPickerDelegate,
            theme: ThemeData(colorScheme: Theme.of(context).colorScheme)));
    if (_result != null && assets.length < 60) {
      var path = _result.id;
      assets.add(_result);
      final _flareID = _generateFlareId(myUsername);
      final _flare = Flare(
          instance: FlareHelper(),
          poster: myUsername,
          flareID: _flareID,
          collectionID: _collectionID,
          collectionName: _collectionName,
          isAdded: true,
          asset: _result,
          backgroundColor: primaryColor,
          gradientColor: accentColor,
          path: path);
      toAdd.add(_flare);
      if (mounted) setState(() {});
    }
  }

  void addMediaHandler(String collectionID, String collectionName) {
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    FocusScope.of(context).unfocus();
    final lang = General.language(context);
    if (isLoading) {
    } else {
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
                onTap: () => _choose(_primarySwatch, _accentColor, myUsername,
                    collectionID, collectionName, lang));
            final ListTile _camera = ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.camera_alt, color: Colors.black),
                title: Text(lang.clubs_newPost21,
                    style: const TextStyle(color: Colors.black)),
                onTap: () {
                  if (assets.length < 60)
                    _chooseCamera(_primarySwatch, _accentColor, myUsername,
                        collectionID, collectionName, lang);
                });

            final Column _choices = Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  if (assets.length < 60 && !kIsWeb) _camera,
                  _choosephotoGallery
                ]);

            final SizedBox _box = SizedBox(child: _choices);
            return _box;
          });
    }
  }

  Widget buildAddButton(String collectionID, String collectionName) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    return GestureDetector(
        onTap: () {
          addMediaHandler(collectionID, collectionName);
        },
        child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(color: _primaryColor),
            child: Center(
                child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add_circle_outline,
                              color: _accentColor, size: 50)
                        ])))));
  }

  Widget buildAddFlare(String collectionID, String collectionName) {
    const Duration dur200 = const Duration(milliseconds: 200);
    const Duration dur300 = const Duration(milliseconds: 300);
    return AnimatedContainer(
        height: viewMode == ViewMode.edit && !kIsWeb ? 150 : 0,
        width: viewMode == ViewMode.edit && !kIsWeb ? 110 : 0,
        duration: viewMode == ViewMode.edit ? dur300 : dur200,
        child: AnimatedScale(
            scale: viewMode == ViewMode.edit && !kIsWeb ? 1 : 0,
            duration: viewMode == ViewMode.edit && !kIsWeb ? dur300 : dur200,
            child: Container(
                height: 150.0,
                width: 110.0,
                margin: const EdgeInsets.only(right: 5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: buildAddButton(collectionID, collectionName)))));
  }

  @override
  void initState() {
    super.initState();
    if (widget.isInFeed) {
      currentController = FeedScreen.spotlightScrollController;
    } else {
      if (widget.isInAdmin) {
        currentController =
            Provider.of<FlareCollectionHelper>(context, listen: false)
                .currentController;
      } else {
        currentController = Provider.of<FlareProfile>(context, listen: false)
            .getCollectionsController;
      }
    }
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final collection =
        Provider.of<FlareCollectionHelper>(context, listen: false);
    final posterID = collection.posterID;
    final collectionID = collection.collectionID;
    final collectionName = collection.collectionName;
    final isEmptyFlare = collection.isEmptyFlare;
    final initialize = collection.initializeCollection;
    initCollection = _initCollection(
        posterID: posterID,
        myUsername: myUsername,
        collectionID: collectionID,
        collectionName: collectionName,
        initializeCollection: initialize,
        currentController: currentController,
        isEmptyFlare: isEmptyFlare);
    final Map<String, dynamic> profileDocData = {
      'shown collections': FieldValue.increment(1)
    };
    final Map<String, dynamic> profileShownData = {
      'posterID': posterID,
      'collectionID': collectionID,
      'times': FieldValue.increment(1),
      'date': DateTime.now()
    };
    General.showItem(
        documentAddress: 'Flares/$posterID/collections/$collectionID',
        itemShownDocAddress:
            'Flares/$posterID/collections/$collectionID/Shown To/$myUsername',
        profileShownDocAddress:
            'Users/$myUsername/Shown Collections/$collectionID',
        profileAddress: 'Users/$myUsername',
        profileShownData: profileShownData,
        profileDocData: profileDocData);
    Map<String, dynamic> fields = {
      'shown collections': FieldValue.increment(1)
    };
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'shown collections',
        docID: '$collectionID',
        docFields: profileShownData);
  }

  List<FlareCollectionModel> giveList() {
    if (widget.isInFeed) {
      return Provider.of<FlareTabProvider>(context).collections;
    } else {
      if (widget.isInAdmin) {
        return Provider.of<AdminFlaresProvider>(context).collections;
      } else {
        return Provider.of<FlareProfile>(context).collections;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textDirection =
        Provider.of<ThemeModel>(context, listen: false).textDirection;
    final bool isRTL = textDirection == TextDirection.rtl;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final bool isManagement = myUsername.startsWith('Linkspeak');
    final argCollections = giveList();
    super.build(context);
    return FutureBuilder(
      future: initCollection,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const FlareCollectionSkeleton();
        if (snapshot.hasError) return const SizedBox(height: 0, width: 0);
        return Builder(
          builder: (context) {
            final FlareCollectionHelper helper =
                Provider.of<FlareCollectionHelper>(context, listen: false);
            final initialize = helper.initializeCollection;
            final String collectionID = helper.collectionID;
            final String poster = helper.posterID;
            final String collectionName = helper.collectionName;
            final int numOfFlares = helper.flares.length;
            final List<Flare> deezFlares = helper.flares;
            List<Flare> allFlares = [...toAdd, ...toRemove, ...deezFlares];
            final bool canAdd = numOfFlares < 60;
            final bool isMyCollection = helper.isMyCollection;
            final bool isMuted = helper.isMuted;
            final bool isBanned = helper.isBanned;
            final bool isBlocked = helper.isBlocked;
            final bool isHidden = helper.isHidden;
            final bool imBlocked = helper.imBlocked;
            final thisIndex = argCollections
                .indexWhere((c) => c.collectionID == collectionID);
            return Opacity(
              opacity: isMuted ? 0.5 : 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  height: ((isBanned ||
                              isBlocked ||
                              imBlocked ||
                              (isHidden && !isMyCollection)) &&
                          !isManagement)
                      ? 0
                      : 320.0,
                  width: ((isBanned ||
                              isBlocked ||
                              imBlocked ||
                              (isHidden && !isMyCollection)) &&
                          !isManagement)
                      ? 0
                      : double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 5.50),
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            if (widget.isInFeed || widget.isInAdmin)
                              Positioned.fill(child: FlareBanner(setHasBanner)),
                            ListTile(
                              contentPadding: EdgeInsets.only(
                                  left: isRTL ? 0 : 10.0,
                                  right: isRTL ? 10 : 0),
                              horizontalTitleGap: 5.0,
                              leading: GestureDetector(
                                onTap: viewMode == ViewMode.edit
                                    ? () {}
                                    : () => visitProfile(myUsername, poster),
                                child: ChatProfileImage(
                                    username: poster,
                                    factor: 0.04,
                                    inEdit: false,
                                    asset: null),
                              ),
                              title: GestureDetector(
                                onTap: viewMode == ViewMode.edit
                                    ? () {}
                                    : () => visitProfile(myUsername, poster),
                                child: giveText(hasBanner, poster, false),
                              ),
                              subtitle: GestureDetector(
                                onTap: widget.isInFeed || widget.isInAdmin
                                    ? () => goToFlareProfile(poster)
                                    : () {},
                                child:
                                    giveText(hasBanner, collectionName, true),
                              ),
                            ),
                            if (viewMode != ViewMode.edit)
                              Align(
                                alignment: isRTL
                                    ? Alignment.topLeft
                                    : Alignment.topRight,
                                child: GestureDetector(
                                  onTap: widget.isInFeed
                                      ? () => goToFlareProfile(poster)
                                      : isMyCollection || isManagement
                                          ? () => setState(() {
                                                viewMode = ViewMode.edit;
                                              })
                                          : () {},
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        right: isRTL ? 0 : 6,
                                        left: isRTL ? 6 : 0),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.isInFeed
                                            ? _primaryColor
                                            : isMyCollection || isManagement
                                                ? _primaryColor
                                                : Colors.transparent),
                                    child: widget.isInFeed
                                        ? Transform.rotate(
                                            angle: 225 * pi / 180,
                                            child: Icon(
                                                Icons.transit_enterexit_rounded,
                                                color: _accentColor,
                                                size: 20))
                                        : isMyCollection || isManagement
                                            ? Icon(Icons.edit,
                                                color: _accentColor, size: 20)
                                            : Container(),
                                  ),
                                ),
                              ),
                            if (viewMode == ViewMode.edit)
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.all(3),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      if (!isLoading)
                                        GestureDetector(
                                            onTap: isLoading
                                                ? () {}
                                                : () => setState(() {
                                                      stateHidden =
                                                          !stateHidden;
                                                    }),
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black),
                                              child: Icon(
                                                  stateHidden
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.white,
                                                  size: 20),
                                            )),
                                      const SizedBox(width: 3),
                                      if (!isLoading)
                                        GestureDetector(
                                          onTap: isLoading
                                              ? () {}
                                              : () => setState(() {
                                                    stateHidden = isHidden;
                                                    viewMode = ViewMode.normal;
                                                    toRemove.clear();
                                                    toAdd.clear();
                                                    assets.clear();
                                                  }),
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red),
                                            child: const Icon(Icons.undo,
                                                color: Colors.white, size: 20),
                                          ),
                                        ),
                                      const SizedBox(width: 3),
                                      GestureDetector(
                                        onTap: isLoading
                                            ? () {}
                                            : () {
                                                handleModification(
                                                    myUsername,
                                                    collectionID,
                                                    collectionName,
                                                    initialize,
                                                    currentController);
                                              },
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors
                                                  .lightGreenAccent.shade400),
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      const CircularProgressIndicator(
                                                          color: Colors.white))
                                              : const Icon(Icons.check,
                                                  color: Colors.white,
                                                  size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.symmetric(horizontal: 5.50),
                        child: ListView(
                          physics:
                              widget.isInFeed ? _bouncy : _alwaysScrollable,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(0),
                          children: [
                            if (!widget.isInFeed && isMyCollection && canAdd)
                              buildAddFlare(collectionID, collectionName),
                            if (viewMode != ViewMode.edit)
                              ...deezFlares.map((flare) {
                                final currentInstance = flare.instance;
                                final currentID = flare.flareID;
                                final currentIndex = deezFlares.indexWhere(
                                    (element) => element.flareID == currentID);
                                return ChangeNotifierProvider.value(
                                    value: currentInstance,
                                    child: Bounce(
                                      onPressed: () {
                                        if (viewMode != ViewMode.edit) {
                                          helper.pickFlare(currentIndex);
                                          CollectionFlareScreenArgs args =
                                              CollectionFlareScreenArgs(
                                                  collections: argCollections,
                                                  index: thisIndex,
                                                  comeFromProfile:
                                                      !widget.isInFeed &&
                                                          !widget.isInAdmin);
                                          Navigator.pushNamed(
                                              context,
                                              RouteGenerator
                                                  .collectionFlareScreen,
                                              arguments: args);
                                        }
                                      },
                                      duration: viewMode == ViewMode.edit
                                          ? Duration.zero
                                          : const Duration(milliseconds: 100),
                                      child: const FlareWidget(),
                                    ));
                              }).toList(),
                            if (viewMode == ViewMode.edit)
                              ...allFlares.map((flare) {
                                AssetEntity? flareAsset;
                                final currentID = flare.flareID;
                                final currentIndex = allFlares.indexOf(flare);
                                final currentInstance = flare.instance;
                                final bool isRemoved = toRemove
                                    .any((flare) => flare.flareID == currentID);
                                final bool isAdded = toAdd
                                    .any((flare) => flare.flareID == currentID);
                                if (isAdded) flareAsset = flare.asset;
                                return Container(
                                  height: isRemoved ? 0 : null,
                                  width: isRemoved ? 0 : null,
                                  child: Stack(
                                    fit: StackFit.passthrough,
                                    children: <Widget>[
                                      Bounce(
                                        onPressed: () {
                                          if (isAdded && !isLoading) {
                                            void saveHandler(Color background,
                                                Color gradient) {
                                              var changeCurrentBackground =
                                                  flare.changeBackground;
                                              var changeCurrentGradient =
                                                  flare.changeGradient;
                                              changeCurrentBackground(
                                                  background);
                                              changeCurrentGradient(gradient);
                                              setState(() {});
                                            }

                                            var args = CustomizeFlareScreenArgs(
                                                asset: flareAsset,
                                                backgroundColor:
                                                    flare.backgroundColor,
                                                gradientColor:
                                                    flare.gradientColor,
                                                saveHandler: saveHandler);
                                            Navigator.pushNamed(
                                                context,
                                                RouteGenerator
                                                    .customizeFlareScreen,
                                                arguments: args);
                                          }
                                        },
                                        duration: viewMode == ViewMode.edit
                                            ? Duration.zero
                                            : const Duration(milliseconds: 100),
                                        child: isAdded
                                            ? AddedFlare(
                                                currentIndex: currentIndex,
                                                isLoading: isLoading,
                                                flareAsset: flareAsset!,
                                                gradientColor:
                                                    flare.gradientColor,
                                                backgroundColor:
                                                    flare.backgroundColor)
                                            : ChangeNotifierProvider.value(
                                                value: currentInstance,
                                                child: const FlareWidget()),
                                      ),
                                      if (viewMode == ViewMode.edit &&
                                          !isRemoved &&
                                          !isLoading)
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: GestureDetector(
                                            onTap: isLoading
                                                ? () {}
                                                : () => setState(() {
                                                      toRemove.add(flare);
                                                      if (isAdded) {
                                                        toAdd.remove(flare);
                                                        assets
                                                            .remove(flareAsset);
                                                      }
                                                    }),
                                            child: const Icon(Icons.cancel,
                                                color: Colors.red, size: 20),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            if (widget.isInFeed) buildMoreButton(poster),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
