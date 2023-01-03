import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/flareGridSkeleton.dart';
import '../models/flare.dart';
import '../models/flareCollectionModel.dart';
import '../models/profile.dart';
import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/flareCollectionHelper.dart';
import '../providers/fullFlareHelper.dart';
import '../providers/likedFlareScrollProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/myFab.dart';
import '../widgets/common/noglow.dart';
import 'flareWidget.dart';

class LikedFlares extends StatefulWidget {
  const LikedFlares();

  @override
  State<LikedFlares> createState() => _LikedFlaresState();
}

class _LikedFlaresState extends State<LikedFlares> {
  late final ScrollController _scrollController;
  late void Function() _disposeScrollController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getLikedFlares;
  late String deletionUsername;
  bool isLoading = false;
  bool isLastPage = false;
  List<FlareCollectionModel> likedFlares = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> gottenIDs = [];
  List<String> toRemove = [];
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
          backgroundColor: Colors.black,
          gradientColor: Colors.black,
          path: '',
          asset: null);
      flare.flareSetter();
      tempFlares.add(flare);
    }
  }

  Future<void> getLikedFlares(String myUsername,
      void Function(List<FlareCollectionModel>) setlikedFlares) async {
    List<FlareCollectionModel> tempColls = [];
    final users = firestore.collection('Users');
    final flares = firestore.collection('Flares');
    final myUser = users.doc(myUsername);
    final myLikes = myUser.collection('Liked Flares');
    do {
      if (gottenIDs.isEmpty) {
        final getLikes =
            await myLikes.orderBy('date', descending: true).limit(50).get();
        final docs = getLikes.docs;
        if (docs.isNotEmpty) {
          gottenIDs.addAll(docs);
          for (var doc in docs) {
            List<Flare> tempFlares = [];
            final poster = doc.get('poster');
            final cID = doc.get('collectionID');
            final fID = doc.get('flareID');
            final flarer = flares.doc(poster);
            final col = flarer.collection('collections').doc(cID);
            final fl = await col.collection('flares').doc(fID).get();
            if (fl.exists) {
              final myBlocked =
                  await myUser.collection('Blocked').doc(poster).get();
              final theirBlocked = await users
                  .doc(poster)
                  .collection('Blocked')
                  .doc(myUsername)
                  .get();
              final userLinks = await users
                  .doc(poster)
                  .collection('Links')
                  .doc(myUsername)
                  .get();
              final thisHiddenCollection = await firestore
                  .doc('Flares/$poster/Hidden Collections/$cID')
                  .get();
              final getProfile = await firestore.doc('Users/$poster').get();
              var status = getProfile.get('Status');
              final posterVisibility = getProfile.get('Visibility');
              final TheVisibility posterVis =
                  General.convertProfileVis(posterVisibility);
              final bool imLinked = userLinks.exists;
              bool isMyFlare = poster == myUsername;
              bool isManagement = myUsername.startsWith('Linkspeak');
              bool _isBanned = status == 'Banned';
              bool _isBlocked = myBlocked.exists;
              bool _imBlocked = theirBlocked.exists;
              bool _isHidden = thisHiddenCollection.exists;
              if ((_isBanned || _isBlocked || _imBlocked && !isManagement) ||
                  (_isHidden && !isMyFlare && !isManagement) ||
                  (posterVis == TheVisibility.private &&
                          !imLinked &&
                          !isMyFlare) &&
                      !isManagement) {
              } else {
                final name = fl.get('collection');
                final instance = FlareCollectionHelper();
                initFlare(
                    poster: poster,
                    flareID: fID,
                    collectionID: cID,
                    collectionName: name,
                    tempFlares: tempFlares);
                final thisCollection = FlareCollectionModel(
                  posterID: poster,
                  collectionID: cID,
                  collectionName: name,
                  flares: tempFlares,
                  controller: _scrollController,
                  instance: instance,
                  isEmpty: false,
                );
                thisCollection.collectionSetter();
                tempColls.add(thisCollection);
              }
            } else {
              toRemove.add(doc.id);
            }
          }
          if (docs.length < 50) {
            isLastPage = true;
          }
        } else {
          return;
        }
      } else {
        final lastDoc = gottenIDs.last.id;
        final getLastDoc = await myLikes.doc(lastDoc).get();
        final next = await myLikes
            .orderBy('date', descending: true)
            .startAfterDocument(getLastDoc)
            .limit(50)
            .get();
        final nextDocs = next.docs;
        for (var doc in nextDocs) {
          List<Flare> tempFlares = [];
          final poster = doc.get('poster');
          final cID = doc.get('collectionID');
          final fID = doc.get('flareID');
          final flarer = flares.doc(poster);
          final col = flarer.collection('collections').doc(cID);
          final fl = await col.collection('flares').doc(fID).get();
          if (fl.exists) {
            final myBlocked =
                await myUser.collection('Blocked').doc(poster).get();
            final theirBlocked = await users
                .doc(poster)
                .collection('Blocked')
                .doc(myUsername)
                .get();
            final userLinks = await users
                .doc(poster)
                .collection('Links')
                .doc(myUsername)
                .get();
            final thisHiddenCollection = await firestore
                .doc('Flares/$poster/Hidden Collections/$cID')
                .get();
            final getProfile = await firestore.doc('Users/$poster').get();
            var status = getProfile.get('Status');
            final posterVisibility = getProfile.get('Visibility');
            final TheVisibility posterVis =
                General.convertProfileVis(posterVisibility);
            final bool imLinked = userLinks.exists;
            bool isMyFlare = poster == myUsername;
            bool isManagement = myUsername.startsWith('Linkspeak');
            bool _isBanned = status == 'Banned';
            bool _isBlocked = myBlocked.exists;
            bool _imBlocked = theirBlocked.exists;
            bool _isHidden = thisHiddenCollection.exists;
            if ((_isBanned || _isBlocked || _imBlocked && !isManagement) ||
                (_isHidden && !isMyFlare && !isManagement) ||
                (posterVis == TheVisibility.private &&
                        !imLinked &&
                        !isMyFlare) &&
                    !isManagement) {
            } else {
              final name = fl.get('collection');
              final instance = FlareCollectionHelper();
              initFlare(
                  poster: poster,
                  flareID: fID,
                  collectionID: cID,
                  collectionName: name,
                  tempFlares: tempFlares);
              final thisCollection = FlareCollectionModel(
                posterID: poster,
                collectionID: cID,
                collectionName: name,
                controller: _scrollController,
                flares: tempFlares,
                instance: instance,
                isEmpty: false,
              );
              thisCollection.collectionSetter();
              tempColls.add(thisCollection);
            }
          } else {
            toRemove.add(doc.id);
          }
        }
        if (nextDocs.isEmpty) {
          isLastPage = true;
        }
      }
    } while (tempColls.length < 50 && !isLastPage);
    likedFlares.addAll(tempColls);
    setlikedFlares(likedFlares);
    setState(() {});
  }

  Future<void> getMoreFlares(String myUsername,
      void Function(List<FlareCollectionModel>) setlikedFlares) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<FlareCollectionModel> tempColls = [];
      final users = firestore.collection('Users');
      final flares = firestore.collection('Flares');
      final myUser = users.doc(myUsername);
      final myLikes = myUser.collection('Liked Flares');
      do {
        final lastDoc = gottenIDs.last.id;
        final getLastDoc = await myLikes.doc(lastDoc).get();
        final next = await myLikes
            .orderBy('date')
            .startAfterDocument(getLastDoc)
            .limit(50)
            .get();
        final docs = next.docs;
        gottenIDs.addAll(docs);
        for (var doc in docs) {
          List<Flare> tempFlares = [];
          final poster = doc.get('poster');
          final cID = doc.get('collectionID');
          final fID = doc.get('flareID');
          final flarer = flares.doc(poster);
          final col = flarer.collection('collections').doc(cID);
          final fl = await col.collection('flares').doc(fID).get();
          if (fl.exists) {
            final myBlocked =
                await myUser.collection('Blocked').doc(poster).get();
            final theirBlocked = await users
                .doc(poster)
                .collection('Blocked')
                .doc(myUsername)
                .get();
            final userLinks = await users
                .doc(poster)
                .collection('Links')
                .doc(myUsername)
                .get();
            final thisHiddenCollection = await firestore
                .doc('Flares/$poster/Hidden Collections/$cID')
                .get();
            final getProfile = await firestore.doc('Users/$poster').get();
            var status = getProfile.get('Status');
            final posterVisibility = getProfile.get('Visibility');
            final TheVisibility posterVis =
                General.convertProfileVis(posterVisibility);
            final bool imLinked = userLinks.exists;
            bool isMyFlare = poster == myUsername;
            bool isManagement = myUsername.startsWith('Linkspeak');
            bool _isBanned = status == 'Banned';
            bool _isBlocked = myBlocked.exists;
            bool _imBlocked = theirBlocked.exists;
            bool _isHidden = thisHiddenCollection.exists;
            if ((_isBanned || _isBlocked || _imBlocked && !isManagement) ||
                (_isHidden && !isMyFlare && !isManagement) ||
                (posterVis == TheVisibility.private &&
                        !imLinked &&
                        !isMyFlare) &&
                    !isManagement) {
            } else {
              final name = fl.get('collection');
              final instance = FlareCollectionHelper();
              initFlare(
                  poster: poster,
                  flareID: fID,
                  collectionID: cID,
                  collectionName: name,
                  tempFlares: tempFlares);
              final thisCollection = FlareCollectionModel(
                posterID: poster,
                collectionID: cID,
                collectionName: name,
                controller: _scrollController,
                flares: tempFlares,
                instance: instance,
                isEmpty: false,
              );
              thisCollection.collectionSetter();
              tempColls.add(thisCollection);
            }
          } else {
            toRemove.add(doc.id);
          }
        }
        if (docs.length < 50) {
          isLastPage = true;
        }
      } while (tempColls.length < 50 && !isLastPage);
      isLoading = false;
      likedFlares.addAll(tempColls);
      setlikedFlares(likedFlares);
      setState(() {});
    }
  }

  Future<void> deleteNonExistant(List<String> _toDelete) async {
    final users = firestore.collection('Users');
    final myUser = users.doc(deletionUsername);
    final myHistory = myUser.collection('Liked Flares');
    if (_toDelete.isNotEmpty)
      for (var item in _toDelete) myHistory.doc(item).delete();
  }

  @override
  void initState() {
    super.initState();
    final myProfile = Provider.of<MyProfile>(context, listen: false);
    final scrollProvider =
        Provider.of<LikedFlareScrollProvider>(context, listen: false);
    final myUsername = myProfile.getUsername;
    deletionUsername = myUsername;
    final setLikedFlares = myProfile.setLikedFlares;
    _scrollController = scrollProvider.controller;
    _getLikedFlares = getLikedFlares(myUsername, setLikedFlares);
    _disposeScrollController = scrollProvider.disposeController;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreFlares(myUsername, setLikedFlares);
          }
        }
      }
    });
  }

  Future<void> _pullRefresh(
      String myUsername,
      void Function() clearFlareHistory,
      void Function(List<FlareCollectionModel>) setLikedFlares) async {
    isLastPage = false;
    likedFlares.clear();
    gottenIDs.clear();
    clearFlareHistory();
    setState(() {
      _getLikedFlares = getLikedFlares(myUsername, setLikedFlares);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _disposeScrollController();
    deleteNonExistant(toRemove);
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final bool selectedAnchorMode =
        Provider.of<ThemeModel>(context, listen: false).anchorMode;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final myProfile = Provider.of<MyProfile>(context, listen: false);
    final setLikedFlares = myProfile.setLikedFlares;
    final clearLikedFlares = myProfile.clearLikedFlares;
    final myUsername = myProfile.getUsername;
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    return FutureBuilder(
        future: _getLikedFlares,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const FlareGridSkeleton();
          }
          if (snapshot.hasError) {
            return Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Text(lang.flares_commentLikes2,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 15.0)),
                  const SizedBox(width: 10.0),
                  SizedBox(
                      height: 35.0,
                      width: 75.0,
                      child: TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color?>(
                                  _primaryColor),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                      const EdgeInsets.all(0.0)),
                              shape: MaterialStateProperty.all<OutlinedBorder?>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)))),
                          onPressed: () {
                            isLastPage = false;
                            likedFlares.clear();
                            gottenIDs.clear();
                            clearLikedFlares();
                            setState(() {
                              _getLikedFlares =
                                  getLikedFlares(myUsername, setLikedFlares);
                            });
                          },
                          child: Center(
                              child: Text(lang.flares_commentLikes3,
                                  style: TextStyle(
                                      color: _accentColor,
                                      fontWeight: FontWeight.bold)))))
                ]));
          }
          return Builder(builder: (context) {
            return (likedFlares.isEmpty)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Spacer(),
                      Center(
                        child: OptimisedText(
                          minWidth: _deviceWidth * 0.15,
                          maxWidth: _deviceWidth * 0.15,
                          minHeight: _deviceHeight * 0.15,
                          maxHeight: _deviceHeight * 0.15,
                          fit: BoxFit.scaleDown,
                          child: const Icon(customIcons.MyFlutterApp.spotlight,
                              color: Colors.black, size: 100),
                        ),
                      ),
                      Center(
                        child: OptimisedText(
                          minWidth: _deviceWidth * 0.50,
                          maxWidth: _deviceWidth * 0.50,
                          minHeight: _deviceHeight * 0.05,
                          maxHeight: _deviceHeight * 0.10,
                          fit: BoxFit.scaleDown,
                          child: const Text(
                            "Your likes are empty",
                            textAlign: TextAlign.center,
                            softWrap: false,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  )
                : Stack(
                    children: <Widget>[
                      RefreshIndicator(
                        backgroundColor: _primaryColor,
                        displacement: 2.0,
                        color: _accentColor,
                        onRefresh: () => _pullRefresh(
                            myUsername, clearLikedFlares, setLikedFlares),
                        child: Noglow(
                          child: GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                  bottom: 85.0, left: 5, right: 5),
                              controller: _scrollController,
                              itemCount: likedFlares.length + 1,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 110,
                                      mainAxisExtent: 150,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10),
                              itemBuilder: (ctx, index) {
                                if (index == likedFlares.length) {
                                  if (isLoading || isLastPage) return emptyBox;
                                } else {
                                  final coll = likedFlares[index];
                                  final currentID = coll.collectionID;
                                  final cinstance = coll.instance;
                                  final fInstance =
                                      cinstance.flares[0].instance;
                                  final flareID = fInstance.flareID;
                                  return MultiProvider(
                                      providers: [
                                        ChangeNotifierProvider.value(
                                            value: cinstance),
                                        ChangeNotifierProvider.value(
                                            value: fInstance),
                                      ],
                                      child: Bounce(
                                        onPressed: () {
                                          cinstance.pickFlare(0);
                                          final thisCollectionIndex =
                                              likedFlares.indexWhere(
                                                  (element) =>
                                                      element.collectionID ==
                                                          currentID &&
                                                      element.flares[0]
                                                              .flareID ==
                                                          flareID);
                                          CollectionFlareScreenArgs args =
                                              CollectionFlareScreenArgs(
                                                  collections: likedFlares,
                                                  index: thisCollectionIndex,
                                                  comeFromProfile: true);
                                          Navigator.pushNamed(
                                              context,
                                              RouteGenerator
                                                  .collectionFlareScreen,
                                              arguments: args);
                                        },
                                        duration:
                                            const Duration(milliseconds: 100),
                                        child: const FlareWidget(),
                                      ));
                                }
                                return emptyBox;
                              }),
                        ),
                      ),
                      if (selectedAnchorMode)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: MyFab(_scrollController),
                          ),
                        ),
                    ],
                  );
          });
        });
  }
}
