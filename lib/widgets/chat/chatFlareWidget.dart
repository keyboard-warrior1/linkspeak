import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../loading/flareSkeleton.dart';
import '../../models/flare.dart';
import '../../models/flareCollectionModel.dart';
import '../../models/profile.dart';
import '../../models/screenArguments.dart';
import '../../providers/flareCollectionHelper.dart';
import '../../providers/fullFlareHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/themeModel.dart';
import '../../routes.dart';

class ChatFlareWidget extends StatefulWidget {
  final String flarePoster;
  final String collectionID;
  final String flareID;
  final bool isMySide;
  final Widget dateWidget;
  const ChatFlareWidget(
      {required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.isMySide,
      required this.dateWidget});

  @override
  State<ChatFlareWidget> createState() => _ChatFlareWidgetState();
}

class _ChatFlareWidgetState extends State<ChatFlareWidget> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late FlareCollectionHelper currentInstance;
  late Future<void> getFlare;
  bool imBlocked = false;
  bool isBanned = false;
  bool imLinked = false;
  bool isHidden = false;
  bool flareNotFound = false;
  bool _isImage = true;
  bool _hasNSFW = false;
  bool commentsDisabled = false;
  Color stateBackgroundColor = Colors.black;
  Color stateGradientColor = Colors.black;
  String thumbnail = '';
  TheVisibility posterVis = TheVisibility.public;
  Future<void> _getFlare(String myUsername) async {
    final users = firestore.collection('Users');
    final flares = firestore.collection('Flares');
    final thisPoster = users.doc(widget.flarePoster);
    final thisCollection = flares
        .doc(widget.flarePoster)
        .collection('collections')
        .doc(widget.collectionID);
    final thisFlare = thisCollection.collection('flares').doc(widget.flareID);
    final getFlare = await thisFlare.get();
    final getCollection = await thisCollection.get();
    if (getFlare.exists) {
      final thisHiddenCollection = await firestore
          .doc(
              'Flares/${widget.flarePoster}/Hidden Collections/${widget.collectionID}')
          .get();
      dynamic getter(String field) => getFlare.get(field);
      final userLinks =
          await thisPoster.collection('Links').doc(myUsername).get();
      final userBlocks =
          await thisPoster.collection('Blocked').doc(myUsername).get();
      final myLike = await thisFlare.collection('likes').doc(myUsername).get();
      final myView = await thisFlare.collection('views').doc(myUsername).get();
      final viewedByMe = myView.exists;
      final likedByMe = myLike.exists;
      final getPoster = await thisPoster.get();
      final posterVisibility = getPoster.get('Visibility');
      final TheVisibility vis = General.convertProfileVis(posterVisibility);
      final String posterStatus = getPoster.get('Status');
      imBlocked = userBlocks.exists;
      imLinked = userLinks.exists;
      isHidden = thisHiddenCollection.exists;
      posterVis = vis;
      if (posterStatus == 'Banned') {
        isBanned = true;
      } else {
        isBanned = false;
      }
      final collectionTitle = getCollection.get('title');
      final numOfViewers = getter('views');
      final numOfLikes = getter('likes');
      final numOfComments = getter('comments');
      final postedDate = getter('date').toDate();
      final mediaURL = getter('mediaURL');
      final thumbNailURL = getter('thumbnail');
      thumbnail = thumbNailURL;
      final hasNSFW = getter('hasNSFW');
      _hasNSFW = hasNSFW;
      final ref = storage.refFromURL(mediaURL);
      final fullPath = ref.fullPath;
      final type = lookupMimeType(fullPath);
      Color backgroundColor = Colors.black;
      Color gradientColor = Colors.black;
      if (getFlare.data()!.containsKey('background')) {
        final actualBackground = getter('background');
        final color = Color(actualBackground);
        backgroundColor = color;
      }
      if (getFlare.data()!.containsKey('gradient')) {
        final actualGradient = getter('gradient');
        final color = Color(actualGradient);
        gradientColor = color;
      }
      stateBackgroundColor = backgroundColor;
      stateGradientColor = gradientColor;
      bool isImage = false;
      bool isVid = false;
      if (type!.startsWith('image')) {
        isImage = true;
        isVid = false;
        _isImage = true;
      } else {
        isVid = true;
        isImage = false;
        _isImage = false;
      }
      if (getFlare.data()!.containsKey('commentsDisabled')) {
        final actual = getter('commentsDisabled');
        commentsDisabled = actual;
      }
      final FlareHelper instance = FlareHelper();
      instance.initializeThisFlare(
          paramposter: widget.flarePoster,
          paramflareID: widget.flareID,
          paramCollectionID: widget.collectionID,
          paramcollectionName: collectionTitle,
          parampostedDate: postedDate,
          paramnumOfViewers: numOfViewers,
          paramnumOfLikes: numOfLikes,
          paramnumOfComments: numOfComments,
          paramDuration: 0,
          parammediaURL: mediaURL,
          paramthumbNailURL: thumbNailURL,
          paramlikedByMe: likedByMe,
          paramviewedByMe: viewedByMe,
          paramisMyFlare: widget.flarePoster == myUsername,
          paramisImage: isImage,
          paramisVid: isVid,
          paramisDeleted: getFlare.exists,
          paramIsBanned: isBanned,
          paramIsBlocked: false,
          paramImBlocked: imBlocked,
          paramIsHidden: isHidden,
          paramhasNSFW: hasNSFW,
          paramImLinked: imLinked,
          paramCommentsDisabled: commentsDisabled,
          paramBackgroundColor: backgroundColor,
          paramGradientColor: gradientColor,
          paramVis: vis);
      final flare = Flare(
          instance: instance,
          poster: widget.flarePoster,
          flareID: widget.flareID,
          collectionID: widget.collectionID,
          collectionName: collectionTitle,
          backgroundColor: backgroundColor,
          gradientColor: gradientColor,
          isAdded: false,
          path: '',
          asset: null);
      final FlareCollectionHelper _instance = FlareCollectionHelper();
      _instance.initializeCollection(
          paramposterID: widget.flarePoster,
          paramCollectionID: widget.collectionID,
          paramcollectionName: collectionTitle,
          paramflares: [flare],
          paramisMyCollection: widget.flarePoster == myUsername,
          paramisMuted: false,
          paramisBanned: false,
          paramisBlocked: false,
          paramimBlocked: false,
          paramIsHidden: false,
          paramEmpty: false,
          paramController: null);
      // ignore: unused_local_variable
      final FlareCollectionModel model = FlareCollectionModel(
          posterID: widget.flarePoster,
          collectionID: widget.collectionID,
          collectionName: collectionTitle,
          flares: [flare],
          controller: null,
          instance: _instance,
          isEmpty: false);
      currentInstance = _instance;
      setState(() {});
    } else {
      setState(() {
        flareNotFound = true;
      });
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    getFlare = _getFlare(myUsername);
  }

  Widget buildCantShow() {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                const Icon(Icons.error, size: 30.0, color: Colors.black)
              ]),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const <Widget>[
                    const Text('Flare Unavailable',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12))
                  ])),
          const Spacer()
        ]);
  }

  Widget buildMedia(String thumb, bool isImage, Color _stateBackgroundColor,
      Color _stateGradientColor) {
    final _themeColors = Theme.of(context).colorScheme;
    final _primaryColor = _themeColors.primary;
    final _accentColor = _themeColors.secondary;
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                tileMode: TileMode.clamp,
                colors: [_stateGradientColor, _stateBackgroundColor])),
        child: Stack(fit: StackFit.expand, children: <Widget>[
          ExtendedImage.network(thumb,
              fit: BoxFit.cover, printError: false, enableLoadState: false),
          if (!isImage)
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 40.0,
                        width: 40.0,
                        decoration: BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(width: 1, color: _accentColor)),
                        child: Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const <Widget>[
                              const Spacer(),
                              const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 15.0),
                              const Spacer()
                            ])))))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final censorNSFW = Provider.of<ThemeModel>(context).censorMode;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final isMyFlare = widget.flarePoster == myUsername;
    final bool imManageMent = myUsername.startsWith('Linkspeak');
    return Expanded(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: widget.isMySide
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
          Row(
              mainAxisAlignment: widget.isMySide
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: <Widget>[
                // Expanded(
                //   child:
                FutureBuilder(builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const FlareSkeleton();
                  if (snapshot.hasError)
                    return Container(
                        height: 150.0,
                        width: 110.0,
                        key: UniqueKey(),
                        margin: const EdgeInsets.only(right: 5.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                                color: Colors.grey.shade200,
                                child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const Spacer(),
                                      IconButton(
                                          icon: const Icon(Icons.refresh,
                                              color: Colors.white),
                                          onPressed: () {
                                            setState(() {
                                              getFlare = _getFlare(myUsername);
                                            });
                                          }),
                                      const Spacer()
                                    ]))));
                  return Container(
                      height: 150.0,
                      width: 110.0,
                      key: UniqueKey(),
                      margin: const EdgeInsets.only(right: 5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: ((imBlocked && !imManageMent) ||
                                  (isBanned && !imManageMent) ||
                                  flareNotFound ||
                                  (posterVis == TheVisibility.private &&
                                      !imLinked &&
                                      !imManageMent &&
                                      !isMyFlare))
                              ? Border.all(color: Colors.grey.shade200)
                              : null),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: ((imBlocked && !imManageMent) ||
                                  (isBanned && !imManageMent) ||
                                  (isHidden && !imManageMent && !isMyFlare) ||
                                  flareNotFound ||
                                  (posterVis == TheVisibility.private &&
                                      !imLinked &&
                                      !imManageMent &&
                                      !isMyFlare))
                              ? buildCantShow()
                              : Bounce(
                                  onPressed: () {
                                    final args = SingleFlareScreenArgs(
                                        flarePoster: widget.flarePoster,
                                        collectionID: widget.collectionID,
                                        flareID: widget.flareID,
                                        isComment: false,
                                        isLike: false,
                                        section: Section.multiple,
                                        singleCommentID: '');
                                    Navigator.pushNamed(context,
                                        RouteGenerator.singleFlareScreen,
                                        arguments: args);
                                  },
                                  duration: const Duration(milliseconds: 100),
                                  child: (isMyFlare)
                                      ? buildMedia(
                                          thumbnail,
                                          _isImage,
                                          stateBackgroundColor,
                                          stateGradientColor)
                                      : (!_hasNSFW)
                                          ? buildMedia(
                                              thumbnail,
                                              _isImage,
                                              stateBackgroundColor,
                                              stateGradientColor)
                                          : (censorNSFW)
                                              ? Blur(
                                                  blur: 25,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                            begin: Alignment
                                                                .bottomRight,
                                                            end: Alignment
                                                                .topLeft,
                                                            tileMode:
                                                                TileMode.clamp,
                                                            colors: [
                                                          stateGradientColor,
                                                          stateBackgroundColor
                                                        ])),
                                                    child: Image.network(
                                                        thumbnail,
                                                        fit: BoxFit.cover),
                                                  ))
                                              : buildMedia(
                                                  thumbnail,
                                                  _isImage,
                                                  stateBackgroundColor,
                                                  stateGradientColor))));
                })
                // )
              ]),
          const SizedBox(height: 10.0),
          widget.dateWidget
        ]));
  }
}
