import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../loading/flaresLoading.dart';
import '../models/flareCollectionModel.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/flareCollectionHelper.dart';
import '../providers/flareProfileProvider.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/nestedScroller.dart';
import 'flareTabWidget.dart';

class ProfileFlares extends StatefulWidget {
  const ProfileFlares();

  @override
  State<ProfileFlares> createState() => _ProfileFlaresState();
}

class _ProfileFlaresState extends State<ProfileFlares>
    with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final ScrollController _collectionsScrollController;
  late final ScrollController _profileScrollController;
  late void Function() _disposeScrollController;
  List<FlareCollectionModel> _statecollections = [];
  late Future<void> getFlares;
  bool isLoading = false;
  bool isLastPage = false;
  void initializeCollection(
      {required bool isShowcase,
      required String posterID,
      required List<FlareCollectionModel> tempCollections,
      required String collectionID,
      required String collectionName}) {
    if (!tempCollections
        .any((collection) => collection.collectionID == collectionID)) {
      final FlareCollectionHelper _instance = FlareCollectionHelper();
      final FlareCollectionModel model = FlareCollectionModel(
          posterID: posterID,
          collectionID: collectionID,
          collectionName: collectionName,
          flares: [],
          controller: _collectionsScrollController,
          instance: _instance,
          isEmpty: false);
      model.collectionSetter();
      if (isShowcase)
        tempCollections.insert(0, model);
      else
        tempCollections.add(model);
    }
  }

  Future<void> _getFlares(String username, String myUsername,
      void Function(List<FlareCollectionModel>) setCollections) async {
    List<FlareCollectionModel> tempCollections = [];
    final bool isMyProfile = username == myUsername;
    final bool isManagement = myUsername.startsWith('Linkspeak');
    final flarers = firestore.collection('Flares');
    final thisUser = flarers.doc(username);
    final theseCollections = thisUser.collection('collections');
    final theseHiddens = thisUser.collection('Hidden Collections');
    final getUser = await thisUser.get();
    if (getUser.exists) {
      final data = getUser.data()!;
      String currentShowcase = '';
      if (data.containsKey('currentlyShowcasing')) {
        final actualShowcase = getUser.get('currentlyShowcasing');
        currentShowcase = actualShowcase;
        final showcaseCollection = await theseCollections
            .where('title', isEqualTo: currentShowcase)
            .get();
        final showcaseDocs = showcaseCollection.docs;
        for (var doc in showcaseDocs) {
          final collectionID = doc.id;
          final collectionName = doc.get('title');
          final getHidden = await theseHiddens.doc(collectionID).get();
          final isHidden = getHidden.exists;
          if (isHidden && !isMyProfile && !isManagement) {
          } else {
            initializeCollection(
                isShowcase: true,
                posterID: username,
                tempCollections: tempCollections,
                collectionID: collectionID,
                collectionName: collectionName);
          }
        }
        final allCollections = await theseCollections
            .orderBy('date', descending: true)
            .limit(15)
            .get();
        final allCollectionDocs = allCollections.docs;
        if (allCollectionDocs.isNotEmpty) {
          for (var collection in allCollectionDocs) {
            final collectionID = collection.id;
            final collectionName = collection.get('title');
            final getHidden = await theseHiddens.doc(collectionID).get();
            final isHidden = getHidden.exists;
            if (isHidden && !isMyProfile && !isManagement) {
            } else {
              initializeCollection(
                  isShowcase: false,
                  posterID: username,
                  tempCollections: tempCollections,
                  collectionID: collectionID,
                  collectionName: collectionName);
            }
          }
          _statecollections.addAll(tempCollections);
          setCollections(_statecollections);
        } else {
          return;
        }
      } else {
        return;
      }
    } else {
      return;
    }
  }

  Future<void> getMoreCollections(String username, String myUsername,
      void Function(List<FlareCollectionModel>) setCollections) async {
    if (isLoading) {
    } else {
      final bool isMyProfile = username == myUsername;
      final bool isManagement = myUsername.startsWith('Linkspeak');
      final flarers = firestore.collection('Flares');
      final thisUser = flarers.doc(username);
      final theseCollections = thisUser.collection('collections');
      final theseHiddens = thisUser.collection('Hidden Collections');
      isLoading = true;
      setState(() {});
      List<FlareCollectionModel> tempCollections = [];
      final lastCollection = _statecollections.last.collectionID;
      final lastCollectionDoc =
          await theseCollections.doc(lastCollection).get();
      final nextCols = await theseCollections
          .orderBy('date', descending: true)
          .startAfterDocument(lastCollectionDoc)
          .limit(15)
          .get();
      final docs = nextCols.docs;
      for (var doc in docs) {
        final collectionID = doc.id;
        final collectionName = doc.get('title');
        final getHidden = await theseHiddens.doc(collectionID).get();
        final isHidden = getHidden.exists;
        if (isHidden && !isMyProfile && !isManagement) {
        } else {
          initializeCollection(
              isShowcase: false,
              posterID: username,
              tempCollections: tempCollections,
              collectionID: collectionID,
              collectionName: collectionName);
        }
      }
      _statecollections.addAll(tempCollections);
      if (docs.length < 15) {
        isLastPage = true;
      }
      isLoading = false;
      setCollections(_statecollections);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final FlareProfile flareProfile =
        Provider.of<FlareProfile>(context, listen: false);
    final username = flareProfile.username;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final setCollections = flareProfile.setCollections;
    _collectionsScrollController = flareProfile.getCollectionsController;
    getFlares = _getFlares(username, myUsername, setCollections);
    _profileScrollController = flareProfile.getprofileScrollController;
    _disposeScrollController = flareProfile.disposeCollectionScrollController;
    _collectionsScrollController.addListener(() {
      if (_collectionsScrollController.position.pixels ==
          _collectionsScrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreCollections(username, myUsername, setCollections);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _collectionsScrollController.removeListener(() {});
    _disposeScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final Size _querySize = MediaQuery.of(context).size;
    final ThemeData _theme = Theme.of(context);
    final double _deviceHeight = _querySize.height;
    final double _deviceWidth = _querySize.width;
    final Color _primaryColor = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final flareProfile = Provider.of<FlareProfile>(context, listen: false);
    final username = flareProfile.username;
    final setCollections = flareProfile.setCollections;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final isMyProfile = username == myUsername;
    super.build(context);
    return FutureBuilder(
        future: getFlares,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const FlaresLoading();

          if (snapshot.hasError)
            return Container(
                color: Colors.white,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                            const Text('An unknown error has occured',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 15.0),
                            TextButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color?>(
                                        _primaryColor),
                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                        const EdgeInsets.all(0.0)),
                                    shape: MaterialStateProperty.all<OutlinedBorder?>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)))),
                                onPressed: () => setState(() {
                                      getFlares = _getFlares(
                                          username, myUsername, setCollections);
                                    }),
                                child: Center(
                                    child: Text('Retry',
                                        style: TextStyle(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold))))
                          ]))
                    ]));

          return Builder(builder: (context) {
            final List<FlareCollectionModel> _myCollections =
                Provider.of<FlareProfile>(context, listen: false).collections;
            return (_myCollections.isEmpty)
                ? Container(
                    color: Colors.white,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                OptimisedText(
                                    minWidth: _deviceWidth * 0.15,
                                    maxWidth: _deviceWidth * 0.15,
                                    minHeight: _deviceHeight * 0.15,
                                    maxHeight: _deviceHeight * 0.15,
                                    fit: BoxFit.scaleDown,
                                    child: const Icon(
                                        customIcons.MyFlutterApp.spotlight,
                                        color: Colors.black,
                                        size: 100)),
                                OptimisedText(
                                    minWidth: _deviceWidth * 0.50,
                                    maxWidth: _deviceWidth * 0.50,
                                    minHeight: _deviceHeight * 0.05,
                                    maxHeight: _deviceHeight * 0.10,
                                    fit: BoxFit.scaleDown,
                                    child: const Text('No flares released yet',
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 35.0))),
                                if (isMyProfile) const SizedBox(height: 20.0),
                                if (isMyProfile)
                                  Container(
                                      height: 55.0,
                                      width: 250.0,
                                      color: Colors.transparent,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                              elevation:
                                                  MaterialStateProperty.all<double?>(
                                                      0.0),
                                              shape: MaterialStateProperty.all<OutlinedBorder?>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0))),
                                              backgroundColor:
                                                  MaterialStateProperty.all<Color?>(
                                                      _primaryColor),
                                              shadowColor:
                                                  MaterialStateProperty.all<Color?>(_primaryColor)),
                                          onPressed: () => Navigator.pushNamed(context, RouteGenerator.newFlare),
                                          child: Center(child: Text('Release', style: TextStyle(color: _accentColor, fontSize: 30.0)))))
                              ])
                        ]))
                : Container(
                    color: Colors.white,
                    child: NestedScroller(
                        controller: _profileScrollController,
                        child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 85.0),
                            shrinkWrap: true,
                            itemCount: _myCollections.length + 1,
                            controller: _collectionsScrollController,
                            itemBuilder: (_, index) {
                              if (index == _myCollections.length) {
                                if (isLoading || isLastPage) return emptyBox;
                              } else {
                                final currenCollection = _myCollections[index];
                                final instance = currenCollection.instance;
                                const _thisCollection =
                                    FlareTabWidget(false, false);
                                return ChangeNotifierProvider.value(
                                    value: instance, child: _thisCollection);
                              }
                              return emptyBox;
                            })));
          });
        });
  }

  @override
  bool get wantKeepAlive => true;
}
