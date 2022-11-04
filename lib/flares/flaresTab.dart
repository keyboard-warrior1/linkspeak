import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../loading/flaresLoading.dart';
import '../models/flareCollectionModel.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/flareCollectionHelper.dart';
import '../providers/flareTabProvider.dart';
import '../providers/myProfileProvider.dart';
import '../screens/feedScreen.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/misc/suggestedWidget.dart';
import 'flareTabWidget.dart';

class FlaresTab extends StatefulWidget {
  const FlaresTab();
  @override
  _FlaresTabState createState() => _FlaresTabState();
}

class _FlaresTabState extends State<FlaresTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _controller = FeedScreen.spotlightScrollController;
  final firestore = FirebaseFirestore.instance;
  static const Widget _suggested = const SuggestedWidget(false, false, false);
  bool isLoading = false;
  bool isLastPage = false;
  List<FlareCollectionModel> feedFlares = [];
  List<String> linkedListString = [];
  late Future<void> getFlares;
  void initializeCollection({
    required String posterID,
    required String myUsername,
    required List<FlareCollectionModel> tempCollections,
    required String collectionID,
    required String collectionName,
    required bool isMyFlare,
    required bool isEmpty,
  }) async {
    if (!tempCollections
        .any((collection) => collection.collectionID == collectionID)) {
      final myMuted = await firestore
          .collection('Users')
          .doc(myUsername)
          .collection('Muted')
          .doc(posterID)
          .get();
      final hiddenDoc = await firestore
          .doc('Flares/$posterID/Hidden Collections/$collectionID')
          .get();
      final isMuted = myMuted.exists;
      final isHidden = hiddenDoc.exists;
      if (!isMuted && !isHidden) {
        final FlareCollectionHelper _instance = FlareCollectionHelper();
        final FlareCollectionModel model = FlareCollectionModel(
            posterID: posterID,
            collectionID: collectionID,
            collectionName: collectionName,
            flares: [],
            controller: _controller,
            instance: _instance,
            isEmpty: isEmpty);
        model.collectionSetter();
        if (isMyFlare)
          tempCollections.insert(0, model);
        else
          tempCollections.add(model);
      }
    }
  }

  Future<void> _getFlares(void Function(List<FlareCollectionModel>) setFlares,
      bool clearFlares, void Function() clear) async {
    List<FlareCollectionModel> tempFlares = [];
    if (clearFlares) {
      clear();
      linkedListString.clear();
      feedFlares.clear();
      isLastPage = false;
    }
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final usersCollection = firestore.collection('Users');
    final flaresCollection = firestore.collection('Flares');
    final myUser = usersCollection.doc(myUsername);
    final linked = myUser.collection('Linked');
    final myFprofile = await flaresCollection.doc(myUsername).get();
    void initMyCol(String colID, String title, bool isEmpty) {
      initializeCollection(
          posterID: myUsername,
          myUsername: myUsername,
          tempCollections: tempFlares,
          collectionID: colID,
          collectionName: title,
          isMyFlare: true,
          isEmpty: isEmpty);
    }

    if (myFprofile.exists) {
      if (myFprofile.data()!.containsKey('currentlyShowcasing')) {
        final title = myFprofile.get('currentlyShowcasing');
        final get = await flaresCollection
            .doc(myUsername)
            .collection('collections')
            .where('title', isEqualTo: title)
            .get();
        final t = get.docs;
        if (t.isNotEmpty) {
          for (var doc in t) {
            final colID = doc.id;
            final name = doc.get('title');
            initMyCol(colID, name, false);
          }
        }
      } else {
        initMyCol('', '', true);
      }
    } else {
      initMyCol('', '', true);
    }
    do {
      if (linkedListString.isEmpty) {
        final myLinked = linked.orderBy('date', descending: true).limit(20);
        final getMyLinked = await myLinked.get();
        final docs = getMyLinked.docs;
        if (docs.isNotEmpty) {
          for (var doc in docs) {
            final id = doc.id;
            linkedListString.add(id);
            final thisFlarer = flaresCollection.doc(id);
            final getThisFlarer = await thisFlarer.get();
            if (getThisFlarer.exists) {
              if (getThisFlarer.data()!.containsKey('currentlyShowcasing')) {
                final title = getThisFlarer.get('currentlyShowcasing');
                final col = await thisFlarer
                    .collection('collections')
                    .where('title', isEqualTo: title)
                    .get();
                final t = col.docs;
                if (t.isNotEmpty) {
                  for (var doc in t) {
                    final colID = doc.id;
                    final name = doc.get('title');
                    initializeCollection(
                        posterID: id,
                        myUsername: myUsername,
                        tempCollections: tempFlares,
                        collectionID: colID,
                        collectionName: name,
                        isMyFlare: false,
                        isEmpty: false);
                  }
                }
              }
            }
          }
          if (docs.length < 20) isLastPage = true;
        } else {
          return;
        }
      } else {
        final lastID = linkedListString.last;
        final getLast = await linked.doc(lastID).get();
        final myLinked = linked
            .orderBy('date', descending: true)
            .startAfterDocument(getLast)
            .limit(20);
        final getMyLinked = await myLinked.get();
        final docs = getMyLinked.docs;
        if (docs.isNotEmpty) {
          for (var doc in docs) {
            final id = doc.id;
            linkedListString.add(id);
            final thisFlarer = flaresCollection.doc(id);
            final getThisFlarer = await thisFlarer.get();
            if (getThisFlarer.exists) {
              if (getThisFlarer.data()!.containsKey('currentlyShowcasing')) {
                final title = getThisFlarer.get('currentlyShowcasing');
                final col = await thisFlarer
                    .collection('collections')
                    .where('title', isEqualTo: title)
                    .get();
                final t = col.docs;
                if (t.isNotEmpty) {
                  for (var doc in t) {
                    final colID = doc.id;
                    final name = doc.get('title');
                    initializeCollection(
                        posterID: id,
                        myUsername: myUsername,
                        tempCollections: tempFlares,
                        collectionID: colID,
                        collectionName: name,
                        isMyFlare: false,
                        isEmpty: false);
                  }
                }
              }
            }
          }
          if (docs.length < 20) isLastPage = true;
        } else {
          return;
        }
      }
    } while (tempFlares.length < 100 && !isLastPage);
    feedFlares.addAll(tempFlares);
    setFlares(feedFlares);
    if (mounted) setState(() {});
  }

  Future<void> _getMoreFlares(
      void Function(List<FlareCollectionModel>) setFlares) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<FlareCollectionModel> tempFlares = [];
      final myUsername =
          Provider.of<MyProfile>(context, listen: false).getUsername;
      final usersCollection = firestore.collection('Users');
      final flaresCollection = firestore.collection('Flares');
      final myUser = usersCollection.doc(myUsername);
      final linked = myUser.collection('Linked');
      do {
        final lastID = linkedListString.last;
        final getLast = await linked.doc(lastID).get();
        final myLinked = linked
            .orderBy('date', descending: true)
            .startAfterDocument(getLast)
            .limit(20);
        final getMyLinked = await myLinked.get();
        final docs = getMyLinked.docs;
        if (docs.isNotEmpty) {
          for (var doc in docs) {
            final id = doc.id;
            linkedListString.add(id);
            final thisFlarer = flaresCollection.doc(id);
            final getThisFlarer = await thisFlarer.get();
            if (getThisFlarer.exists) {
              if (getThisFlarer.data()!.containsKey('currentlyShowcasing')) {
                final title = getThisFlarer.get('currentlyShowcasing');
                final col = await thisFlarer
                    .collection('collections')
                    .where('title', isEqualTo: title)
                    .get();
                final t = col.docs;
                if (t.isNotEmpty) {
                  for (var doc in t) {
                    final colID = doc.id;
                    final name = doc.get('title');
                    initializeCollection(
                        posterID: id,
                        myUsername: myUsername,
                        tempCollections: tempFlares,
                        collectionID: colID,
                        collectionName: name,
                        isMyFlare: false,
                        isEmpty: false);
                  }
                }
              }
            }
          }
          if (docs.length < 20) isLastPage = true;
        } else {
          return;
        }
      } while (tempFlares.length < 100 && !isLastPage);
      feedFlares.addAll(tempFlares);
      setFlares(feedFlares);
      if (mounted) setState(() {});
    }
  }

  Future<void> _pullRefresh(void Function(List<FlareCollectionModel>) setFlares,
      void Function() clear) async {
    setState(() {
      getFlares = _getFlares(setFlares, true, clear);
    });
  }

  @override
  void initState() {
    super.initState();
    final void Function(List<FlareCollectionModel>) setFlares =
        Provider.of<FlareTabProvider>(context, listen: false).setCollections;
    final void Function() clearFlares =
        Provider.of<FlareTabProvider>(context, listen: false).clearFlares;
    getFlares = _getFlares(setFlares, false, clearFlares);
    _controller.addListener(() {
      if (mounted) {
        if (_controller.position.pixels ==
            _controller.position.maxScrollExtent) {
          if (!isLoading) {
            _getMoreFlares(setFlares);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    const ScrollPhysics _always = const AlwaysScrollableScrollPhysics();
    final void Function(List<FlareCollectionModel>) setFlares =
        Provider.of<FlareTabProvider>(context, listen: false).setCollections;
    final void Function() clearFlares =
        Provider.of<FlareTabProvider>(context, listen: false).clearFlares;
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    super.build(context);
    return Container(
        color: Colors.white,
        child: FutureBuilder(
            future: getFlares,
            key: PageStorageKey<String>('flareFeedFUTURE'),
            builder: (ctx, snapshot) {
              final _flares =
                  Provider.of<FlareTabProvider>(context).collections;
              if (snapshot.connectionState == ConnectionState.waiting)
                return const FlaresLoading();
              if (snapshot.hasError) {
                return SizedBox(
                  height: _deviceHeight,
                  width: _deviceWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'An error has occured',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            width: 100.0,
                            padding: const EdgeInsets.all(5.0),
                            child: TextButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry?>(
                                  const EdgeInsets.symmetric(
                                    vertical: 1.0,
                                    horizontal: 5.0,
                                  ),
                                ),
                                enableFeedback: false,
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder?>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all<Color?>(
                                        _primarySwatch),
                              ),
                              onPressed: () {
                                _pullRefresh(setFlares, clearFlares);
                              },
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 19.0,
                                  color: _accentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              if (feedFlares.isEmpty) {
                return SizedBox(
                  height: _deviceHeight,
                  width: _deviceWidth,
                  child: RefreshIndicator(
                    key: UniqueKey(),
                    backgroundColor: _primarySwatch,
                    displacement: 40.0,
                    color: _accentColor,
                    onRefresh: () => _pullRefresh(setFlares, clearFlares),
                    child: ListView(
                      children: <Widget>[
                        SizedBox(
                          height: _deviceHeight,
                          width: _deviceWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                      child: const Icon(
                                          customIcons.MyFlutterApp.spotlight,
                                          color: Colors.black,
                                          size: 55))),
                              Center(
                                child: OptimisedText(
                                  minWidth: _deviceWidth * 0.50,
                                  maxWidth: _deviceWidth * 0.50,
                                  minHeight: _deviceHeight * 0.05,
                                  maxHeight: _deviceHeight * 0.10,
                                  fit: BoxFit.scaleDown,
                                  child: const Text(
                                    "No Flares found",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 25.0,
                                    ),
                                  ),
                                ),
                              ),
                              _suggested,
                              const Spacer()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                  backgroundColor: _primarySwatch,
                  displacement: 2.0,
                  color: _accentColor,
                  onRefresh: () => _pullRefresh(setFlares, clearFlares),
                  child: ListView.separated(
                      key: PageStorageKey<String>('flareFeweedStore'),
                      padding: EdgeInsets.only(
                          top: _deviceHeight * 0.05, bottom: 85.0),
                      physics: _always,
                      controller: _controller,
                      itemCount: _flares.length + 1,
                      separatorBuilder: (ctx, index) {
                        // var remainder = index % 4;
                        // if (remainder == 0)
                        //   return Container(
                        //       margin: const EdgeInsets.symmetric(
                        //           vertical: 0.0, horizontal: 10.0),
                        //       child: const NativeAds());
                        if (index == 6) return _suggested;
                        return emptyBox;
                      },
                      itemBuilder: (context, index) {
                        if (index == _flares.length) {
                          if (isLoading) return emptyBox;
                          if (isLastPage) return emptyBox;
                        } else {
                          final currenCollection = _flares[index];
                          final instance = currenCollection.instance;
                          const _thisCollection = FlareTabWidget(true, false);
                          return ChangeNotifierProvider.value(
                              value: instance, child: _thisCollection);
                        }
                        return emptyBox;
                      }));
            }));
  }

  @override
  bool get wantKeepAlive => true;
}
