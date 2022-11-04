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
import '../providers/flareCollectionHelper.dart';
import '../providers/fullFlareHelper.dart';
import '../providers/historyScrollProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../routes.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/myFab.dart';
import '../widgets/common/noglow.dart';
import 'flareWidget.dart';

class FlareHistory extends StatefulWidget {
  const FlareHistory();

  @override
  State<FlareHistory> createState() => _FlareHistoryState();
}

class _FlareHistoryState extends State<FlareHistory> {
  late final ScrollController _scrollController;
  late void Function() _disposeScrollController;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getFlareHistory;
  late String deletionUsername;
  bool isLoading = false;
  bool isLastPage = false;
  List<FlareCollectionModel> flareHistory = [];
  List<FlareCollectionModel> removedOnes = [];
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

  Future<void> getFlareHistory(String myUsername,
      void Function(List<FlareCollectionModel>) setFlareHistory) async {
    List<FlareCollectionModel> tempColls = [];
    final users = firestore.collection('Users');
    final flares = firestore.collection('Flares');
    final myUser = users.doc(myUsername);
    final myHistory = myUser.collection('Flare History');
    do {
      if (gottenIDs.isEmpty) {
        final getHistory =
            await myHistory.orderBy('date', descending: true).limit(50).get();
        final docs = getHistory.docs;
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
        final getLastDoc = await myHistory.doc(lastDoc).get();
        final next = await myHistory
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
        if (nextDocs.isEmpty) {
          isLastPage = true;
        }
      }
    } while (tempColls.length < 50 && !isLastPage);
    flareHistory.addAll(tempColls);
    setFlareHistory(flareHistory);
    setState(() {});
  }

  Future<void> getMoreFlares(String myUsername,
      void Function(List<FlareCollectionModel>) setFlareHistory) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<FlareCollectionModel> tempColls = [];
      final users = firestore.collection('Users');
      final flares = firestore.collection('Flares');
      final myUser = users.doc(myUsername);
      final myHistory = myUser.collection('Flare History');
      do {
        final lastDoc = gottenIDs.last.id;
        final getLastDoc = await myHistory.doc(lastDoc).get();
        final next = await myHistory
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
      } while (tempColls.length < 50 && !isLastPage);
      isLoading = false;
      flareHistory.addAll(tempColls);
      setFlareHistory(flareHistory);
      setState(() {});
    }
  }

  Future<void> deleteSingleViewed(String currentFlareID) async {
    var batch = firestore.batch();
    final _rightNow = DateTime.now();
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    final myUsername = _myProfile.getUsername;
    final id = '$myUsername-${_rightNow.toString()}';
    final users = firestore.collection('Users');
    final deleteds = firestore.collection('Deleted Flare Histories');
    final currentDeleteID = deleteds.doc(id);
    final myUser = users.doc(myUsername);
    final flareHistoryDeleted =
        myUser.collection('Flares Deleted History').doc(id);
    final myHistory = myUser.collection('Flare History').doc(currentFlareID);
    final doc = await myHistory.get();
    final poster = doc.get('poster');
    final cID = doc.get('collectionID');
    final fID = doc.get('flareID');
    final date = doc.get('date');
    final times = doc.get('times');
    final theIndex = flareHistory.indexWhere((element) =>
        element.collectionID == cID && element.flares[0].flareID == fID);
    final theElement = flareHistory[theIndex];
    removedOnes.add(theElement);
    final removedIndex = removedOnes.indexOf(theElement);
    flareHistory.remove(theIndex);
    setState(() {});
    batch.set(currentDeleteID, {'date': _rightNow, 'viewer': myUsername},
        SetOptions(merge: true));
    batch.set(currentDeleteID.collection('history').doc(fID), {
      'poster': poster,
      'collectionID': cID,
      'flareID': fID,
      'times': times,
      'date': date,
    });
    batch.set(flareHistoryDeleted, {'id': id, 'date': _rightNow},
        SetOptions(merge: true));
    batch.delete(myUser.collection('Flare History').doc(doc.id));
    return batch.commit().then((value) {}).catchError((_) {
      flareHistory.insert(theIndex, theElement);
      removedOnes.remove(removedIndex);
      setState(() {});
    });
  }

  Future<void> clearFlareHistory() async {
    final _rightNow = DateTime.now();
    MyProfile _myProfile = Provider.of<MyProfile>(context, listen: false);
    void Function() clearFlareHistory = _myProfile.clearFlareHistory;
    final myUsername = _myProfile.getUsername;
    final id = '$myUsername-${_rightNow.toString()}';
    final users = firestore.collection('Users');
    final deleteds = firestore.collection('Deleted Flare Histories');
    final currentDeleteID = deleteds.doc(id);
    final myUser = users.doc(myUsername);
    final flareHistoryDeleted =
        myUser.collection('Flares Deleted History').doc(id);
    final myHistory = myUser.collection('Flare History').get();
    currentDeleteID.set(
        {'date': _rightNow, 'viewer': myUsername}, SetOptions(merge: true));
    myHistory.then((snap) {
      for (DocumentSnapshot doc in snap.docs) {
        final poster = doc.get('poster');
        final cID = doc.get('collectionID');
        final fID = doc.get('flareID');
        final date = doc.get('date');
        final times = doc.get('times');
        currentDeleteID.collection('history').doc(fID).set({
          'poster': poster,
          'collectionID': cID,
          'flareID': fID,
          'times': times,
          'date': date,
        });
        myUser.collection('Flare History').doc(doc.id).delete();
      }
      flareHistoryDeleted
          .set({'id': id, 'date': _rightNow}, SetOptions(merge: true));
      setState(() {
        flareHistory.clear();
        gottenIDs.clear();
        isLastPage = false;
        clearFlareHistory();
      });
    });
  }

  Future<void> deleteNonExistant(List<String> _toDelete) async {
    final users = firestore.collection('Users');
    final myUser = users.doc(deletionUsername);
    final myHistory = myUser.collection('Flare History');
    if (_toDelete.isNotEmpty)
      for (var item in _toDelete) myHistory.doc(item).delete();
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return Center(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 150.0, maxWidth: 150.0),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text('Clear history',
                                softWrap: false,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                    fontFamily: 'Roboto',
                                    fontSize: 19.0,
                                    color: Colors.black)),
                            const Divider(
                                thickness: 1.0, indent: 0.0, endIndent: 0.0),
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () async {
                                        await clearFlareHistory();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Yes',
                                          style: TextStyle(color: Colors.red))),
                                  TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('No',
                                          style: TextStyle(color: Colors.red)))
                                ])
                          ]))));
        });
  }

  void _showModalBottomSheet(String flareID) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          topRight: Radius.circular(5.0))),
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    ListTile(
                        horizontalTitleGap: 5.0,
                        leading: const Icon(Icons.cancel, color: Colors.red),
                        title: const Text('Remove',
                            style: TextStyle(color: Colors.red)),
                        onTap: () async {
                          await deleteSingleViewed(flareID);
                          Navigator.pop(context);
                        })
                  ])));
        });
  }

  @override
  void initState() {
    super.initState();
    final myProfile = Provider.of<MyProfile>(context, listen: false);
    final scrollProvider =
        Provider.of<HistoryScrollProvider>(context, listen: false);
    final myUsername = myProfile.getUsername;
    deletionUsername = myUsername;
    final setFlareHistory = myProfile.setFlareHistory;
    _scrollController = scrollProvider.controller;
    _getFlareHistory = getFlareHistory(myUsername, setFlareHistory);
    _disposeScrollController = scrollProvider.disposeController;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreFlares(myUsername, setFlareHistory);
          }
        }
      }
    });
  }

  Future<void> _pullRefresh(
      String myUsername,
      void Function() clearFlareHistory,
      void Function(List<FlareCollectionModel>) setFlareHistory) async {
    isLastPage = false;
    flareHistory.clear();
    gottenIDs.clear();
    clearFlareHistory();
    setState(() {
      _getFlareHistory = getFlareHistory(myUsername, setFlareHistory);
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
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final bool selectedAnchorMode =
        Provider.of<ThemeModel>(context, listen: false).anchorMode;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final myProfile = Provider.of<MyProfile>(context, listen: false);
    final setFlareHistory = myProfile.setFlareHistory;
    final clearFlareHistory = myProfile.clearFlareHistory;
    final myUsername = myProfile.getUsername;
    const radius = const Radius.circular(10);
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    return FutureBuilder(
        future: _getFlareHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const FlareGridSkeleton();

          if (snapshot.hasError)
            return Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  const Text('An error has occured, please try again',
                      style: TextStyle(color: Colors.black, fontSize: 15.0)),
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
                            flareHistory.clear();
                            gottenIDs.clear();
                            clearFlareHistory();
                            setState(() {
                              _getFlareHistory =
                                  getFlareHistory(myUsername, setFlareHistory);
                            });
                          },
                          child: Center(
                              child: Text('Retry',
                                  style: TextStyle(
                                      color: _accentColor,
                                      fontWeight: FontWeight.bold)))))
                ]));

          return Builder(builder: (context) {
            return (flareHistory.isEmpty)
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
                                child: const Icon(Icons.history_rounded,
                                    color: Colors.black, size: 100))),
                        Center(
                            child: OptimisedText(
                                minWidth: _deviceWidth * 0.50,
                                maxWidth: _deviceWidth * 0.50,
                                minHeight: _deviceHeight * 0.05,
                                maxHeight: _deviceHeight * 0.10,
                                fit: BoxFit.scaleDown,
                                child: const Text("Your history is empty",
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 25.0)))),
                        const Spacer()
                      ])
                : Stack(children: <Widget>[
                    Noglow(
                        child: RefreshIndicator(
                            backgroundColor: _primaryColor,
                            displacement: 2.0,
                            color: _accentColor,
                            onRefresh: () => _pullRefresh(
                                myUsername, clearFlareHistory, setFlareHistory),
                            child: GridView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                    bottom: 85.0, left: 5, right: 5),
                                itemCount: flareHistory.length + 1,
                                controller: _scrollController,
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 110,
                                        mainAxisExtent: 150,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10),
                                itemBuilder: (ctx, index) {
                                  if (index == flareHistory.length) {
                                    if (isLoading || isLastPage)
                                      return emptyBox;
                                  } else {
                                    final coll = flareHistory[index];
                                    final currentID = coll.collectionID;
                                    final cinstance = coll.instance;
                                    final fInstance =
                                        cinstance.flares[0].instance;
                                    final flareID = fInstance.flareID;
                                    bool isRemoved = removedOnes.any(
                                        (element) =>
                                            element.collectionID == currentID &&
                                            element.flares[0].flareID ==
                                                flareID);
                                    return MultiProvider(
                                        providers: [
                                          ChangeNotifierProvider.value(
                                              value: cinstance),
                                          ChangeNotifierProvider.value(
                                              value: fInstance)
                                        ],
                                        child: Builder(builder: (context) {
                                          return Opacity(
                                              opacity: isRemoved ? 0 : 1,
                                              child: GestureDetector(
                                                  onLongPress: isRemoved
                                                      ? () {}
                                                      : () =>
                                                          _showModalBottomSheet(
                                                              flareID),
                                                  child: Bounce(
                                                      onPressed: isRemoved
                                                          ? () {}
                                                          : () {
                                                              cinstance
                                                                  .pickFlare(0);
                                                              final thisCollectionIndex = flareHistory.indexWhere((element) =>
                                                                  element.collectionID ==
                                                                      currentID &&
                                                                  element
                                                                          .flares[
                                                                              0]
                                                                          .flareID ==
                                                                      flareID);
                                                              CollectionFlareScreenArgs args =
                                                                  CollectionFlareScreenArgs(
                                                                      collections:
                                                                          flareHistory,
                                                                      index:
                                                                          thisCollectionIndex,
                                                                      comeFromProfile:
                                                                          true);
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  RouteGenerator
                                                                      .collectionFlareScreen,
                                                                  arguments:
                                                                      args);
                                                            },
                                                      duration: const Duration(
                                                          milliseconds: 100),
                                                      child:
                                                          const FlareWidget())));
                                        }));
                                  }
                                  return emptyBox;
                                }))),
                    Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                            height: 50,
                            width: 150,
                            margin: const EdgeInsets.only(top: 5),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                      child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white54,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: radius,
                                                  topRight: radius,
                                                  bottomLeft: radius,
                                                  bottomRight: radius)),
                                          child: TextButton(
                                              onPressed: () {
                                                _showDialog();
                                              },
                                              style: const ButtonStyle(
                                                  splashFactory:
                                                      NoSplash.splashFactory),
                                              child: const Center(
                                                  child: const Text(
                                                      'Clear history',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 23))))))
                                ]))),
                    if (selectedAnchorMode)
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 10.0),
                              child: MyFab(_scrollController)))
                  ]);
          });
        });
  }
}
