import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/flareSkeleton.dart';
import '../models/profile.dart';
import '../providers/fullFlareHelper.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';

class FlareWidget extends StatefulWidget {
  const FlareWidget();
  @override
  State<FlareWidget> createState() => _FlareWidgetState();
}

class _FlareWidgetState extends State<FlareWidget>
    with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late Future<void> initFlare;
  Future<void> _initFlare(String poster, String myUsername, String collectionID,
      String collectionName, String flareID, dynamic initializer) async {
    int numOfViewers = 0;
    int numOfLikes = 0;
    int numOfComments = 0;
    String mediaURL = '';
    String thumbNailURL = '';
    bool hasNSFW = false;
    bool isImage = false;
    bool isVid = false;
    DateTime postedDate = DateTime.now();
    bool isMyFlare = poster == myUsername;
    bool likedByMe = false;
    bool viewedByMe = false;
    bool isBanned = false;
    bool isBlocked = false;
    bool imBlocked = false;
    bool isHidden = false;
    bool commentsDisabled = false;
    final users = firestore.collection('Users');
    final flares = firestore.collection('Flares');
    final myUser = users.doc(myUsername);
    final posterUser = users.doc(poster);
    final userLinks =
        await posterUser.collection('Links').doc(myUsername).get();
    final getUser = await posterUser.get();
    final posterVisibility = getUser.get('Visibility');
    final TheVisibility vis = General.convertProfileVis(posterVisibility);
    final status = getUser.get('Status');
    final bool imLinked = userLinks.exists;
    isBanned = status == 'Banned';
    final posterFlare = flares.doc(poster);
    final thisCollection =
        posterFlare.collection('collections').doc(collectionID);
    final thisFlare = thisCollection.collection('flares').doc(flareID);
    final getFlare = await thisFlare.get();
    Color backgroundColor = Colors.black;
    Color gradientColor = Colors.black;
    if (getFlare.exists) {
      final thisHiddenCollection = await firestore
          .doc('Flares/$poster/Hidden Collections/$collectionID')
          .get();
      dynamic getter(String field) => getFlare.get(field);
      final myBlocked = await myUser.collection('Blocked').doc(poster).get();
      final theirBlocked =
          await posterUser.collection('Blocked').doc(myUsername).get();
      isBlocked = myBlocked.exists;
      final myLike = await thisFlare.collection('likes').doc(myUsername).get();
      final myView = await thisFlare.collection('views').doc(myUsername).get();
      viewedByMe = myView.exists;
      likedByMe = myLike.exists;
      imBlocked = theirBlocked.exists;
      isHidden = thisHiddenCollection.exists;
      numOfViewers = getter('views');
      numOfLikes = getter('likes');
      numOfComments = getter('comments');
      postedDate = getter('date').toDate();
      mediaURL = getter('mediaURL');
      thumbNailURL = getter('thumbnail');
      hasNSFW = getter('hasNSFW');
      final ref = storage.refFromURL(mediaURL);
      final fullPath = ref.fullPath;
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
      final type = lookupMimeType(fullPath);
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
      initializer(
          paramposter: poster,
          paramflareID: flareID,
          paramCollectionID: collectionID,
          paramcollectionName: collectionName,
          parampostedDate: postedDate,
          paramnumOfViewers: numOfViewers,
          paramnumOfLikes: numOfLikes,
          paramnumOfComments: numOfComments,
          paramDuration: 0,
          parammediaURL: mediaURL,
          paramthumbNailURL: thumbNailURL,
          paramlikedByMe: likedByMe,
          paramviewedByMe: viewedByMe,
          paramisMyFlare: isMyFlare,
          paramisImage: isImage,
          paramisVid: isVid,
          paramisDeleted: false,
          paramIsBanned: isBanned,
          paramIsBlocked: isBlocked,
          paramImBlocked: imBlocked,
          paramIsHidden: isHidden,
          paramhasNSFW: hasNSFW,
          paramImLinked: imLinked,
          paramCommentsDisabled: commentsDisabled,
          paramBackgroundColor: backgroundColor,
          paramGradientColor: gradientColor,
          paramVis: vis);
    } else {
      initializer(
          paramposter: poster,
          paramflareID: flareID,
          paramCollectionID: collectionID,
          paramcollectionName: collectionName,
          parampostedDate: postedDate,
          paramnumOfViewers: numOfViewers,
          paramnumOfLikes: numOfLikes,
          paramnumOfComments: numOfComments,
          paramDuration: 0,
          parammediaURL: mediaURL,
          paramthumbNailURL: thumbNailURL,
          paramlikedByMe: likedByMe,
          paramviewedByMe: viewedByMe,
          paramisMyFlare: isMyFlare,
          paramisImage: isImage,
          paramisVid: isVid,
          paramisDeleted: true,
          paramIsBanned: isBanned,
          paramIsBlocked: isBlocked,
          paramImBlocked: imBlocked,
          paramIsHidden: isHidden,
          paramhasNSFW: hasNSFW,
          paramImLinked: imLinked,
          paramCommentsDisabled: commentsDisabled,
          paramBackgroundColor: backgroundColor,
          paramGradientColor: gradientColor,
          paramVis: vis);
    }
  }

  @override
  void initState() {
    super.initState();
    final helper = Provider.of<FlareHelper>(context, listen: false);
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final poster = helper.poster;
    final collectionID = helper.collectionID;
    final collectionName = helper.collectionName;
    final flareID = helper.flareID;
    final initializer = helper.initializeThisFlare;
    initFlare = _initFlare(
        poster, myUsername, collectionID, collectionName, flareID, initializer);
    final Map<String, dynamic> profileDocData = {
      'shown flares': FieldValue.increment(1)
    };
    final Map<String, dynamic> profileShownData = {
      'posterID': poster,
      'collectionID': collectionID,
      'flareID': flareID,
      'times': FieldValue.increment(1),
      'date': DateTime.now()
    };
    General.showItem(
        documentAddress:
            'Flares/$poster/collections/$collectionID/flares/$flareID',
        itemShownDocAddress:
            'Flares/$poster/collections/$collectionID/flares/$flareID/Shown To/$myUsername',
        profileShownDocAddress: 'Users/$myUsername/Shown Flares/$flareID',
        profileAddress: 'Users/$myUsername',
        profileShownData: profileShownData,
        profileDocData: profileDocData);
    Map<String, dynamic> fields = {'shown flares': FieldValue.increment(1)};
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: 'shown flares',
        docID: '$flareID',
        docFields: profileShownData);
  }

  Widget buildMedia(
      String thumb, bool isImage, Color backgroundColor, Color gradientColor) {
    final _themeColors = Theme.of(context).colorScheme;
    final _primaryColor = _themeColors.primary;
    final _accentColor = _themeColors.secondary;
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                tileMode: TileMode.clamp,
                colors: [gradientColor, backgroundColor])),
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

  Widget giveStacked(String text) => Stack(children: <Widget>[
        Text(text,
            softWrap: false,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1
                  ..color = Colors.black)),
        Text(text,
            softWrap: false,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13))
      ]);
  Widget buildViewers(String views) => Align(
      alignment: Alignment.bottomLeft,
      child: Container(
          margin: const EdgeInsets.only(left: 2, bottom: 2),
          child: Row(children: <Widget>[
            Container(
                decoration: BoxDecoration(boxShadow: const [
                  const BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0, 0),
                      blurRadius: 15,
                      spreadRadius: 0.5)
                ]),
                child: const Icon(Icons.play_arrow_outlined,
                    size: 20, color: Colors.white)),
            const SizedBox(width: 2),
            giveStacked(views),
          ])));

  @override
  Widget build(BuildContext context) {
    final censorNSFW = Provider.of<ThemeModel>(context).censorMode;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final isManagement = myUsername.startsWith('Linkspeak');
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    super.build(context);
    return FutureBuilder(
        future: initFlare,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const FlareSkeleton();
          if (snapshot.hasError) return const SizedBox(height: 0, width: 0);
          return Builder(builder: (context) {
            final FlareHelper helper = Provider.of<FlareHelper>(context);
            final int numOfViews = helper.numOfViewers;
            final views = General.optimisedNumbers(numOfViews);
            final bool isMyFlare = helper.isMyFlare;
            final bool _viewedByMe = helper.viewedByMe;
            final bool _isDeleted = helper.isDeleted;
            final bool _isBanned = helper.isBanned;
            final bool _isBlocked = helper.isBlocked;
            final bool _imBlocked = helper.imBlocked;
            final bool _isHidden = helper.isHidden;
            final bool _hasNSFW = helper.hasNSFW;
            final String thumbnail = helper.thumbNailURL;
            final bool isImage = helper.isImage;
            final bool imLinked = helper.imLinked;
            final Color backgroundColor = helper.backgorundColor;
            final Color gradientColor = helper.gradientColor;
            final TheVisibility posterVis = helper.posterVisibility;
            final conditiones = (_isDeleted ||
                ((_isBanned || _isBlocked || _imBlocked && !isManagement) ||
                    (_isHidden && !isMyFlare && !isManagement) ||
                    (posterVis == TheVisibility.private &&
                            !imLinked &&
                            !isMyFlare) &&
                        !isManagement));
            return Container(
                height: conditiones ? 0 : 150.0,
                width: conditiones ? 0 : 110.0,
                key: UniqueKey(),
                margin: const EdgeInsets.only(right: 5.0),
                child: Stack(children: <Widget>[
                  Positioned.fill(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: (isMyFlare)
                              ? buildMedia(thumbnail, isImage, backgroundColor,
                                  gradientColor)
                              : (!_hasNSFW)
                                  ? buildMedia(thumbnail, isImage,
                                      backgroundColor, gradientColor)
                                  : (censorNSFW)
                                      ? Blur(
                                          blur: 25,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin:
                                                        Alignment.bottomRight,
                                                    end: Alignment.topLeft,
                                                    tileMode: TileMode.clamp,
                                                    colors: [
                                                  gradientColor,
                                                  backgroundColor
                                                ])),
                                            child: Image.network(thumbnail,
                                                fit: BoxFit.cover),
                                          ))
                                      : buildMedia(thumbnail, isImage,
                                          backgroundColor, gradientColor))),
                  if (!_viewedByMe && !isMyFlare)
                    Align(
                        alignment: Alignment.topRight,
                        child: Container(
                            height: 10.0,
                            width: 10.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _accentColor,
                                border: Border.all(color: _primaryColor)))),
                  if (numOfViews > 0) buildViewers(views)
                ]));
          });
        });
  }

  @override
  bool get wantKeepAlive => true;
}
