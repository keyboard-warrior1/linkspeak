import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cube_transition_plus/cube_transition_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_nsfw/flutter_nsfw.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as thumb;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../general.dart';
import '../models/flare.dart';
import '../models/screenArguments.dart';
import '../providers/fullFlareHelper.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/chatProfileImage.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import 'megaFlare.dart';

class NewFlareCollectionScreen extends StatefulWidget {
  const NewFlareCollectionScreen();

  @override
  State<NewFlareCollectionScreen> createState() =>
      _NewFlareCollectionScreenState();
}

class _NewFlareCollectionScreenState extends State<NewFlareCollectionScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  final PageController cubeController = PageController();
  final _mediaInfo = FlutterVideoInfo();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FocusNode node = FocusNode(canRequestFocus: true);
  bool isLoading = false;
  bool triggerAnimation = false;
  bool disableComments = false;
  int currentViewingIndex = 0;
  List<AssetEntity> assets = [];
  List<Flare> potentialflares = [];
  String subtitleText = '';

  Future<void> _choose(
      Color primaryColor, Color accentColor, dynamic lang) async {
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
        var path = result.id;
        print(path);
        if (!assets.any((element) => element == result)) assets.add(result);
        if (!potentialflares.any((element) => element.path == path))
          potentialflares.add(Flare(
              instance: FlareHelper(),
              poster: '',
              flareID: '',
              collectionID: '',
              collectionName: '',
              backgroundColor: primaryColor,
              gradientColor: accentColor,
              isAdded: false,
              path: path,
              asset: null));
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _chooseCamera(
      Color primaryColor, Color accentColor, dynamic lang) async {
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
      print(path);
      assets.add(_result);
      if (!potentialflares.any((element) => element.path == path))
        potentialflares.add(Flare(
            instance: FlareHelper(),
            poster: '',
            flareID: '',
            collectionID: '',
            collectionName: '',
            backgroundColor: primaryColor,
            gradientColor: accentColor,
            isAdded: false,
            path: path,
            asset: null));
      if (mounted) setState(() {});
    }
  }

  void addMediaHandler() {
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    FocusScope.of(context).unfocus();
    if (isLoading) {
    } else {
      final lang = General.language(context);
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
                onTap: () => _choose(_primarySwatch, _accentColor, lang));
            final ListTile _camera = ListTile(
                horizontalTitleGap: 5.0,
                leading: const Icon(Icons.camera_alt, color: Colors.black),
                title: Text(lang.clubs_newPost21,
                    style: const TextStyle(color: Colors.black)),
                onTap: () {
                  if (assets.length < 60)
                    _chooseCamera(_primarySwatch, _accentColor, lang);
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

  void _removeMedia(index) {
    var id = assets[index].id;
    setState(() {
      if (index == currentViewingIndex && assets.isNotEmpty && index != 0) {
        print('HERE HERE');
        currentViewingIndex = currentViewingIndex - 1;
        cubeController.jumpToPage(currentViewingIndex);
      }
      if (index == 0 && currentViewingIndex == 1) {
        print('IN HERE');
        currentViewingIndex = currentViewingIndex - 1;
        cubeController.jumpToPage(currentViewingIndex);
      }

      if (index == 0 &&
          currentViewingIndex == 0 &&
          assets.isNotEmpty &&
          assets.length == 2) {
        print('REACHED HERE');
        currentViewingIndex = currentViewingIndex + 1;
        cubeController.jumpToPage(currentViewingIndex);
      }
      if (currentViewingIndex != 0 && index < currentViewingIndex) {
        print('heeeeere');
        currentViewingIndex = currentViewingIndex - 1;
        cubeController.jumpToPage(currentViewingIndex);
      }
      assets.removeAt(index);
      potentialflares.removeWhere((element) => element.path == id);
      if (index == 0 && assets.isEmpty) {
        print('last block');
        currentViewingIndex = 0;
      }
    });
    print(currentViewingIndex);
  }

  Widget buildAddButton() {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryColor,
      ),
      child: Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.add_circle_outline, color: _accentColor, size: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAddFlare() {
    return Container(
      height: 150.0,
      width: 110.0,
      margin: const EdgeInsets.only(right: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: buildAddButton(),
      ),
    );
  }

  Widget _imageAssetWidget(AssetEntity asset) {
    return Image(
      image: AssetEntityImageProvider(asset, isOriginal: false),
      fit: BoxFit.contain,
    );
  }

  Widget _videoAssetWidget(AssetEntity asset) => Stack(children: <Widget>[
        Positioned.fill(child: _imageAssetWidget(asset)),
        const ColoredBox(
            color: Colors.white38,
            child: Center(
                child: Icon(Icons.play_arrow, color: Colors.black, size: 24.0)))
      ]);

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

  Widget assetMapper(AssetEntity m) {
    //
    //
    //
    // final _theme = Theme.of(context);
    // final _accentColor =   _theme.colorScheme.secondary;
    final int _currentIndex = assets.indexOf(m);
    final id = m.id;
    final currentFlareInd = potentialflares.indexWhere((f) => f.path == id);
    var currentFlare = potentialflares[currentFlareInd];
    var currentBackground = currentFlare.backgroundColor;
    var currentGradient = currentFlare.gradientColor;
    return GestureDetector(
      // key: UniqueKey(),
      onTap: () {
        setState(() {
          currentViewingIndex = _currentIndex;
        });
        cubeController.jumpToPage(_currentIndex);
      },
      child: Container(
        height: 150.0,
        width: 110.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                tileMode: TileMode.clamp,
                colors: [currentGradient, currentBackground]),
            border: currentViewingIndex == _currentIndex
                ? Border.all(color: Colors.lightGreenAccent.shade400, width: 4)
                : null),
        margin: const EdgeInsets.only(right: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              currentViewingIndex == _currentIndex ? 6.0 : 7),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: _assetWidgetBuilder(m),
              ),
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
                  child: const Icon(Icons.cancel, color: Colors.red, size: 20),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget cubeMapper(AssetEntity e) {
    // final _currentIndex = assets.indexOf(e);
    final id = e.id;
    final currentFlareInd = potentialflares.indexWhere((f) => f.path == id);
    var currentFlare = potentialflares[currentFlareInd];
    var currentBackground = currentFlare.backgroundColor;
    var currentGradient = currentFlare.gradientColor;
    var changeCurrentBackground = currentFlare.changeBackground;
    var changeCurrentGradient = currentFlare.changeGradient;
    void saveHandler(Color background, Color gradient) {
      changeCurrentBackground(background);
      changeCurrentGradient(gradient);
      setState(() {});
    }

    return GestureDetector(
        // key: UniqueKey(),
        onTap: () async {
          FocusScope.of(context).unfocus();
          if (isLoading) {
          } else {
            var args = CustomizeFlareScreenArgs(
                backgroundColor: currentBackground,
                gradientColor: currentGradient,
                saveHandler: saveHandler,
                asset: e);
            Navigator.pushNamed(context, RouteGenerator.customizeFlareScreen,
                arguments: args);
            // final List<AssetEntity>? result =
            //     await AssetPickerViewer.pushToViewer(
            //   context,
            //   currentIndex: _currentIndex,
            //   previewAssets: assets,
            //   themeData: AssetPicker.themeData(Colors.blue),
            // );
            // if (result != null && result != assets) {
            //   assets = List<AssetEntity>.from(result);
            //   if (mounted) {
            //     setState(() {});
            //   }
            // }
          }
        },
        child: RepaintBoundary(
            child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        tileMode: TileMode.clamp,
                        colors: [currentGradient, currentBackground])),
                child: _assetWidgetBuilder(e))));
  }

  Widget giveStacked(String text, bool isSub) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          softWrap: isSub,
          style: TextStyle(
            fontSize: isSub ? 13.0 : 15.0,
            fontWeight: isSub ? FontWeight.normal : FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.00
              ..color = Colors.black,
          ),
        ),
        Text(
          text,
          softWrap: isSub,
          style: TextStyle(
            fontSize: isSub ? 13.0 : 15.0,
            fontWeight: isSub ? FontWeight.normal : FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildCubeView(String myUsername, String displayName) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CubePageView(
            controller: cubeController,
            startPage: 0,
            onPageChanged: (index) {
              setState(() {
                currentViewingIndex = index;
              });
            },
            children: [
              if (assets.isNotEmpty) ...assets.map(cubeMapper).toList(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ListTile(
            horizontalTitleGap: 5,
            leading: ChatProfileImage(
                username: myUsername,
                factor: 0.035,
                inEdit: false,
                asset: null),
            title: giveStacked(displayName, false),
            subtitle: giveStacked(subtitleText, true),
          ),
        )
      ],
    );
  }

  Widget buildReleasedToast() {
    Widget buildIcon(double size) =>
        Icon(Icons.star, color: Colors.white, size: size);
    return SizedBox(
      height: 55,
      width: 72,
      child: Stack(
        children: [
          Align(alignment: Alignment.centerRight, child: buildIcon(20)),
          Align(alignment: Alignment.centerLeft, child: buildIcon(20)),
          Align(alignment: Alignment.center, child: buildIcon(40)),
        ],
      ),
    );
  }

  _showDialog(IconData icon, Color iconColor, String title, String rule) {
    showDialog(
        context: context,
        builder: (_) => RegistrationDialog(
            icon: icon, iconColor: iconColor, title: title, rules: rule));
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

  Future<void> handleSingleFlare(
      WriteBatch batch,
      String myUsername,
      String collectionTitle,
      String collectionID,
      File currentFile,
      String assetID,
      DocumentReference<Map<String, dynamic>> myUserCollection,
      DocumentReference<Map<String, dynamic>> currentCollection) async {
    final DateTime _rightNow = DateTime.now();
    final options = SetOptions(merge: true);
    bool hasNSFW = false;
    void flag() => hasNSFW = true;
    final String flareID = General.generateContentID(
        username: myUsername,
        clubName: '',
        isPost: false,
        isClubPost: false,
        isCollection: false,
        isFlare: true,
        isComment: false,
        isReply: false,
        isFlareComment: false,
        isFlareReply: false);
    final thisFlare = currentCollection.collection('flares').doc(flareID);
    final thisProfileFlare = myUserCollection.collection('flares').doc(flareID);
    final thisReviewalDoc = firestore.collection('Review').doc(flareID);
    var urls = await uploadFile(
        myUsername, collectionTitle, flareID, flag, currentFile);
    final String mediaURL = urls[0];
    final String thumbnail = urls[1];
    var currentFlareInd = potentialflares.indexWhere((f) => f.path == assetID);
    var currentPFlare = potentialflares[currentFlareInd];
    final Color backgroundColor = currentPFlare.backgroundColor;
    final Color gradientColor = currentPFlare.gradientColor;
    final int background = backgroundColor.value;
    final int gradient = gradientColor.value;
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
      'commentsDisabled': disableComments,
      'background': background,
      'gradient': gradient,
    };
    final profileInfo = {
      'poster': myUsername,
      'ID': flareID,
      'collectionID': collectionID,
      'collection': collectionTitle,
      'date': _rightNow
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
      'clubName': '',
    };
    batch.set(thisFlare, flareInfo, options);
    batch.set(thisProfileFlare, profileInfo, options);
    if (hasNSFW) batch.set(thisReviewalDoc, reviewalInfo, options);
  }

  Future<void> releaseFlares(String myUsername, String collectionTitle) async {
    final String collectionID = General.generateContentID(
        username: myUsername,
        clubName: '',
        isPost: false,
        isClubPost: false,
        isCollection: true,
        isFlare: false,
        isComment: false,
        isReply: false,
        isFlareComment: false,
        isFlareReply: false);
    final lang = General.language(context);
    const duration = const Duration(seconds: 60);
    bool invalidVid = assets.any((asset) => asset.videoDuration > duration);
    bool valid = formKey.currentState!.validate() && !invalidVid;
    bool canSubmit = valid;
    final filter = ProfanityFilter();
    Future<void> _submitCollection() async {
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
        node.canRequestFocus = true;
        setState(() {
          isLoading = false;
        });
        EasyLoading.dismiss();
        if (invalidSizeVid.isNotEmpty) {
          _showDialog(Icons.info_outline, Colors.blue, lang.clubs_newPost7,
              lang.flares_newCollection1);
        }
        if (invalidSizeIMG.isNotEmpty) {
          _showDialog(Icons.info_outline, Colors.blue, lang.clubs_newPost7,
              lang.flares_newCollection2);
        }
      } else {
        final DateTime _rightNow = DateTime.now();
        final last24hour = _rightNow.subtract(Duration(minutes: 1440));
        final List<String> last24hrs = [];
        final getLast11 = await firestore
            .collection('Flares')
            .doc(myUsername)
            .collection('collections')
            .orderBy('date', descending: true)
            .limit(11)
            .get();
        final myFlareCollectionIDs = getLast11.docs;
        for (var id in myFlareCollectionIDs) {
          final collection = await firestore
              .collection('Flares')
              .doc(myUsername)
              .collection('collections')
              .doc(id.id)
              .get();
          if (collection.exists) {
            final date = collection.get('date').toDate();
            Duration diff = date.difference(last24hour);
            if (diff.inMinutes >= 0 && diff.inMinutes <= 1440) {
              last24hrs.add(id.id);
            } else {}
          }
        }
        if (last24hrs.length >= 10) {
          node.canRequestFocus = true;
          setState(() {
            isLoading = false;
          });
          EasyLoading.dismiss();
          _showDialog(Icons.info_outline, Colors.blue, lang.clubs_newPost7,
              lang.flares_newCollection3);
        } else {
          final collectionWithSameName = await firestore
              .collection('Flares')
              .doc(myUsername)
              .collection('collections')
              .where('title', isEqualTo: collectionTitle)
              .get();
          final preexisting = collectionWithSameName.docs;
          if (preexisting.length > 0) {
            node.canRequestFocus = true;
            setState(() {
              isLoading = false;
            });
            EasyLoading.dismiss();
            _showDialog(Icons.info_outline, Colors.blue, lang.clubs_newPost7,
                lang.flares_newCollection4);
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
            await FlutterNsfw.initNsfw(file.path,
                enableLog: false, isOpenGPU: false, numThreads: 4);
            var batch = firestore.batch();
            if (filter.hasProfanity(collectionTitle)) {
              batch.update(firestore.doc('Profanity/Flares'),
                  {'numOfProfanity': FieldValue.increment(1)});
              batch.set(firestore.collection('Profanity/Flares/Flares').doc(), {
                'poster': myUsername,
                'collectionID': collectionID,
                'title': collectionTitle,
                'date': _rightNow,
              });
            }
            final myUserDoc = firestore.collection('Users').doc(myUsername);
            final myUserFlares = myUserDoc.collection('My Flares');
            final myUserCollection = myUserFlares.doc(collectionID);
            final myFlareDoc = firestore.collection('Flares').doc(myUsername);
            final myCollections = myFlareDoc.collection('collections');
            final theFlareCollectionDoc = myCollections.doc(collectionID);
            final thisNewFlare =
                firestore.collection('New Flare Collections').doc(collectionID);
            final numOfFlares = assets.length;
            final reversedAssets = assets.reversed.toList();
            final options = SetOptions(merge: true);
            final info = {
              'numOfFlares': FieldValue.increment(numOfFlares),
              'numOfFlareCollections': FieldValue.increment(1),
              'currentlyShowcasing': collectionTitle,
            };
            Map<String, dynamic> controlInfo = {
              'flare collections': FieldValue.increment(1),
              'flares': FieldValue.increment(numOfFlares)
            };
            final collectionInfo = {
              'numOfFlares': numOfFlares,
              'title': collectionTitle,
              'likes': 0,
              'views': 0,
              'comments': 0,
              'date': _rightNow,
              'poster': myUsername,
              'commentsDisabled': disableComments
            };
            General.updateControl(
                fields: controlInfo,
                myUsername: myUsername,
                collectionName: null,
                docID: null,
                docFields: {});
            batch.set(myUserDoc, info, options);
            batch.set(myFlareDoc, info, options);
            batch.set(theFlareCollectionDoc, collectionInfo, options);
            batch.set(
                thisNewFlare,
                {
                  'poster': myUsername,
                  'collectionID': collectionID,
                  'collectionName': collectionTitle,
                  'date': _rightNow
                },
                options);
            batch.set(
                myUserCollection,
                {
                  'date': _rightNow,
                  'title': collectionTitle,
                  'numOfFlares': numOfFlares
                },
                options);
            for (var asset in reversedAssets) {
              final currentFile = await asset.file;
              await handleSingleFlare(
                  batch,
                  myUsername,
                  collectionTitle,
                  collectionID,
                  currentFile!,
                  asset.id,
                  myUserCollection,
                  theFlareCollectionDoc);
            }
            return batch.commit().then((value) {
              Future.delayed(const Duration(milliseconds: 300), () {
                EasyLoading.show(
                    status: lang.flares_newCollection5,
                    dismissOnTap: true,
                    indicator: buildReleasedToast());
              });
              Future.delayed(const Duration(milliseconds: 2000), () {
                EasyLoading.dismiss();
              });
              setState(() {
                triggerAnimation = true;
              });
              Future.delayed(const Duration(milliseconds: 3000), () {
                setState(() {
                  triggerAnimation = false;
                });
              });
              node.canRequestFocus = true;
              controller.clear();
              assets.clear();
              potentialflares.clear();
              setState(() {
                isLoading = false;
              });
            }).catchError((_) {
              EasyLoading.showError(lang.flares_profile7,
                  dismissOnTap: true, duration: const Duration(seconds: 2));
              node.canRequestFocus = true;
              setState(() {
                isLoading = false;
              });
            });
          }
        }
      }
    }

    if (isLoading) {
    } else {
      if (canSubmit && !isLoading) {
        setState(() {
          isLoading = true;
        });
        _submitCollection();
      } else if (invalidVid) {
        setState(() {
          isLoading = false;
        });
        _showDialog(Icons.warning, Colors.red, lang.clubs_newPost13,
            lang.clubs_newPost14);
      } else {}
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      var currentValue = controller.value.text;
      if (subtitleText != currentValue) {
        setState(() {
          subtitleText = currentValue;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(() {});
    controller.dispose();
    cubeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final _theme = Theme.of(context);
    final _size = MediaQuery.of(context).size;
    final _height = _size.height;
    final _width = General.widthQuery(context);
    final _primaryColor = _theme.colorScheme.primary;
    final _accentColor = _theme.colorScheme.secondary;
    const SizedBox _heightBox = const SizedBox(height: 15);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    String displayName = myUsername;
    if (myUsername.length > 15) {
      final cut = myUsername.substring(0, 14);
      displayName = '$cut..';
    }
    String? titleValidation(String? value) {
      if ((value!.isEmpty ||
          value.replaceAll(' ', '') == '' ||
          value.trim() == '')) {
        return lang.flares_newCollection11;
      }
      if (value.length > 75) {
        return lang.flares_newCollection12;
      }
      return null;
    }

    return Scaffold(
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
                child: Stack(children: <Widget>[
              SizedBox(
                  height: _height,
                  width: _width,
                  child: Form(
                      key: formKey,
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SettingsBar(lang.flares_newCollection6),
                            Expanded(
                                child: Noglow(
                                    child: ListView(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: TextFormField(
                                          validator: titleValidation,
                                          controller: controller,
                                          focusNode: node,
                                          minLines: 1,
                                          maxLines: 1,
                                          maxLength: 75,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          decoration: InputDecoration(
                                              border:
                                                  const OutlineInputBorder(),
                                              labelText:
                                                  lang.flares_newCollection7,
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior
                                                      .always))),
                                  ListTile(
                                      minVerticalPadding: 0.0,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                      horizontalTitleGap: 5.0,
                                      leading: Switch(
                                          inactiveTrackColor:
                                              Colors.red.shade200,
                                          activeTrackColor: Colors.red,
                                          activeColor: Colors.white,
                                          value: disableComments,
                                          onChanged: (value) {
                                            if (isLoading) {
                                            } else {
                                              setState(() => disableComments =
                                                  !disableComments);
                                            }
                                          }),
                                      title: GestureDetector(
                                          onTap: () {
                                            if (isLoading) {
                                            } else {
                                              setState(() => disableComments =
                                                  !disableComments);
                                            }
                                          },
                                          child: Text(lang.clubs_newPost17))),
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                            child: Container(
                                                height: _height * 0.5,
                                                width: _width * 0.7,
                                                color: assets.isNotEmpty
                                                    ? Colors.transparent
                                                    : Colors.grey.shade200,
                                                child: buildCubeView(
                                                    myUsername, displayName)))
                                      ]),
                                  _heightBox,
                                  SizedBox(
                                      height: 200,
                                      width: _width,
                                      child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.all(8),
                                          children: <Widget>[
                                            if (assets.length < 60)
                                              GestureDetector(
                                                  onTap: addMediaHandler,
                                                  child: buildAddFlare()),
                                            if (assets.isNotEmpty)
                                              ...assets
                                                  .map(assetMapper)
                                                  .toList()
                                          ]))
                                ]))),
                            Opacity(
                                opacity: 1,
                                child: TextButton(
                                    style: ButtonStyle(
                                        enableFeedback: false,
                                        elevation: MaterialStateProperty.all<double?>(
                                            0.0),
                                        shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight:
                                                    const Radius.circular(15.0),
                                                topLeft: const Radius.circular(
                                                    15.0)))),
                                        backgroundColor: MaterialStateProperty.all<Color?>(
                                            _primaryColor)),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      if (!isLoading) {
                                        if (assets.isNotEmpty) {
                                          setState(() {
                                            node.canRequestFocus = false;
                                          });
                                          final title =
                                              controller.value.text.trim();
                                          releaseFlares(myUsername, title);
                                        } else {
                                          _showDialog(
                                              Icons.warning,
                                              Colors.red,
                                              lang.flares_newCollection8,
                                              lang.flares_newCollection9);
                                        }
                                      }
                                    },
                                    child: (isLoading)
                                        ? CircularProgressIndicator(
                                            color: _accentColor,
                                            strokeWidth: 1.50)
                                        : Text(lang.flares_newCollection10,
                                            style: TextStyle(fontSize: 35.0, color: _accentColor))))
                          ]))),
              MegaFlare(triggerAnimation)
            ]))));
  }
}
