import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/flare.dart';
import '../models/flareCollectionModel.dart';
import '../models/profile.dart';
import '../providers/flareCollectionHelper.dart';
import '../providers/fullFlareHelper.dart';
import '../providers/myProfileProvider.dart';
import 'collectionFlareWidget.dart';
import 'flareComments.dart';
import 'flareLikes.dart';

class SingleFlareScreen extends StatefulWidget {
  final dynamic flarePoster;
  final dynamic collectionID;
  final dynamic flareID;
  final dynamic isComment;
  final dynamic isLike;
  final dynamic section;
  final dynamic singleCommentID;
  const SingleFlareScreen(
      {required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.isComment,
      required this.section,
      required this.isLike,
      required this.singleCommentID});

  @override
  State<SingleFlareScreen> createState() => _SingleFlareScreenState();
}

class _SingleFlareScreenState extends State<SingleFlareScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late FlareCollectionHelper currentInstance;
  late Future<void> getFlare;
  bool imBlocked = false;
  bool isBanned = false;
  bool isHidden = false;
  bool imLinked = false;
  bool flareNotFound = false;
  TheVisibility posterVis = TheVisibility.public;
  _showSheet(Widget child) {
    final _size = MediaQuery.of(context).size;
    final _height = _size.height;
    final _width = General.widthQuery(context);
    showModalBottomSheet(
        context: context,
        barrierColor: Colors.black,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10))),
        builder: (ctx) => Container(
            height: _height * 0.90,
            width: _width,
            // color:Colors.white,
            child: child));
  }

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
      bool commentsDisabled = false;
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
      final hasNSFW = getter('hasNSFW');
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

      bool isImage = false;
      bool isVid = false;
      if (type!.startsWith('image')) {
        isImage = true;
        isVid = false;
      } else {
        isVid = true;
        isImage = false;
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
      bool imManageMent = myUsername.startsWith('Linkspeak');
      bool isMyFlare = widget.flarePoster == myUsername;
      bool condition = (imBlocked && !imManageMent) ||
          (isBanned && !imManageMent) ||
          (isHidden && !imManageMent && !isMyFlare) ||
          flareNotFound ||
          (posterVis == TheVisibility.private &&
              !imLinked &&
              !imManageMent &&
              !isMyFlare);
      if (widget.isLike) {
        if (condition) {
        } else {
          _showSheet(FlareLikes(
              poster: widget.flarePoster,
              collectionID: widget.collectionID,
              flareID: widget.flareID,
              numOfLikes: numOfLikes));
        }
      }
      if (widget.section == Section.single) {
        if (condition) {
        } else {
          _showSheet(FlareComments(
              poster: widget.flarePoster,
              collectionID: widget.collectionID,
              flareID: widget.flareID,
              numOfComments: numOfComments,
              setComments: flare.instance.setComments,
              instance: instance,
              section: Section.single,
              singleCommentID: widget.singleCommentID));
        }
      }
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

  Widget buildPopButton() => Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
            const Spacer()
          ]);

  Widget buildCantShow() {
    final lang = General.language(context);
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          buildPopButton(),
          const Spacer(),
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                const Icon(Icons.error, size: 50.0, color: Colors.white)
              ]),
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(lang.flares_singleFlare1,
                    style: const TextStyle(color: Colors.white))
              ]),
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(lang.flares_singleFlare2,
                    style: const TextStyle(color: Colors.white))
              ]),
          const Spacer()
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final ThemeData _theme = Theme.of(context);
    final Color _primarySwatch = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final isMyFlare = widget.flarePoster == myUsername;
    final bool imManageMent = myUsername.startsWith('Linkspeak');
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: FutureBuilder(
                future: getFlare,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          buildPopButton(),
                          const Spacer(),
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Center(
                                    child: const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 1.5))
                              ]),
                          const Spacer()
                        ]);

                  if (snapshot.hasError)
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          buildPopButton(),
                          const Spacer(),
                          Center(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                Text(lang.flares_profileFlares1,
                                    style: const TextStyle(color: Colors.grey)),
                                const SizedBox(width: 15.0),
                                TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color?>(
                                                _primarySwatch),
                                        padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                            const EdgeInsets.all(0.0)),
                                        shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)))),
                                    onPressed: () => setState(() {
                                          getFlare = _getFlare(myUsername);
                                        }),
                                    child: Center(
                                        child: Text(lang.flares_profile2,
                                            style: TextStyle(
                                                color: _accentColor,
                                                fontWeight: FontWeight.bold))))
                              ])),
                          const Spacer()
                        ]);

                  return ((imBlocked && !imManageMent) ||
                          (isBanned && !imManageMent) ||
                          (isHidden && !imManageMent && !isMyFlare) ||
                          flareNotFound ||
                          (posterVis == TheVisibility.private &&
                              !imLinked &&
                              !imManageMent &&
                              !isMyFlare))
                      ? buildCantShow()
                      : ChangeNotifierProvider<FlareCollectionHelper>.value(
                          value: currentInstance,
                          child: const CollectionFlareWidget());
                })));
  }
}
