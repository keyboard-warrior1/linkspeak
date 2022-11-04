import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flares/flareTabWidget.dart';
import '../../loading/flaresLoading.dart';
import '../../models/flareCollectionModel.dart';
import '../../providers/adminFlaresProvider.dart';
import '../../providers/flareCollectionHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../widgets/common/settingsBar.dart';

class NewFlareScreen extends StatefulWidget {
  const NewFlareScreen();

  @override
  State<NewFlareScreen> createState() => _NewFlareScreenState();
}

class _NewFlareScreenState extends State<NewFlareScreen> {
  var firestore = FirebaseFirestore.instance;
  final ScrollController scrollController = ScrollController();
  List<FlareCollectionModel> adminFlares = [];
  bool isLoading = false;
  bool isLastPage = false;
  late Future<void> getFlares;
  void initializeCollection({
    required List<FlareCollectionModel> tempCollections,
    required String myUsername,
    required String posterID,
    required String collectionID,
    required String collectionName,
  }) {
    if (!tempCollections
        .any((collection) => collection.collectionID == collectionID)) {
      final FlareCollectionHelper _instance = FlareCollectionHelper();
      final FlareCollectionModel model = FlareCollectionModel(
          posterID: posterID,
          collectionID: collectionID,
          collectionName: collectionName,
          flares: [],
          controller: scrollController,
          instance: _instance,
          isEmpty: false);
      model.collectionSetter();
      tempCollections.add(model);
    }
  }

  Future<void> _getFlares(
      String myUsername,
      void Function(List<FlareCollectionModel>) setFlares,
      void Function() clearFlares,
      bool toBeCleared) async {
    List<FlareCollectionModel> tempCollections = [];
    var newFlares = await firestore
        .collection('New Flare Collections')
        .orderBy('date', descending: true)
        .limit(50)
        .get();
    var docs = newFlares.docs;
    for (var doc in docs) {
      String posterID = doc.get('poster');
      String collectionID = doc.get('collectionID');
      String collectionName = doc.get('collectionName');
      initializeCollection(
          tempCollections: tempCollections,
          myUsername: myUsername,
          posterID: posterID,
          collectionID: collectionID,
          collectionName: collectionName);
    }
    adminFlares.addAll(tempCollections);
    setFlares(adminFlares);
    if (docs.length < 50) isLastPage = true;
    if (mounted) setState(() {});
  }

  Future<void> _getMoreFlares(String myUsername,
      void Function(List<FlareCollectionModel>) setFlares) async {
    List<FlareCollectionModel> tempCollections = [];
    if (!isLoading) {
      var lastID = adminFlares.last.collectionID;
      var getLastDoc =
          await firestore.doc('New Flare Collections/$lastID').get();
      var getNext50 = await firestore
          .collection('collectionPath')
          .orderBy('date', descending: true)
          .startAfterDocument(getLastDoc)
          .limit(50)
          .get();
      var docs = getNext50.docs;
      for (var doc in docs) {
        String posterID = doc.get('poster');
        String collectionID = doc.get('collectionID');
        String collectionName = doc.get('collectionName');
        initializeCollection(
            tempCollections: tempCollections,
            myUsername: myUsername,
            posterID: posterID,
            collectionID: collectionID,
            collectionName: collectionName);
      }
      adminFlares.addAll(tempCollections);
      setFlares(adminFlares);
      if (docs.length < 50) isLastPage = true;
      if (mounted) setState(() {});
    }
  }

  Future<void> _pullRefresh(
      String myUsername,
      void Function(List<FlareCollectionModel>) setFlares,
      void Function() clear) async {
    setState(() {
      getFlares = _getFlares(myUsername, setFlares, clear, true);
      isLastPage = false;
    });
  }

  @override
  void initState() {
    super.initState();
    var myUsername = Provider.of<MyProfile>(context, listen: false).getUsername;
    var setFlares =
        Provider.of<AdminFlaresProvider>(context, listen: false).setCollections;
    getFlares = _getFlares(myUsername, setFlares, () {}, false);
    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (!isLoading && !isLastPage) {
            _getMoreFlares(myUsername, setFlares);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(() {});
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    var size = MediaQuery.of(context).size;
    var myUsername = Provider.of<MyProfile>(context, listen: false).getUsername;
    var helper = Provider.of<AdminFlaresProvider>(context, listen: false);
    var setFlares = helper.setCollections;
    var clearFlares = helper.clearFlares;
    var height = size.height;
    var width = size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: height,
                width: width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SettingsBar('New Flares'),
                      Expanded(
                          child: FutureBuilder(
                              future: getFlares,
                              builder: (ctx, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return const FlaresLoading();
                                return Builder(builder: (context) {
                                  var flareList =
                                      Provider.of<AdminFlaresProvider>(context)
                                          .collections;
                                  return RefreshIndicator(
                                    backgroundColor: _primarySwatch,
                                    displacement: 2.0,
                                    color: _accentColor,
                                    onRefresh: () => _pullRefresh(
                                        myUsername, setFlares, clearFlares),
                                    child: ListView.builder(
                                        controller: scrollController,
                                        itemCount: flareList.length,
                                        itemBuilder: (_, index) {
                                          var current = flareList[index];
                                          var instance = current.instance;
                                          return ChangeNotifierProvider.value(
                                              value: instance,
                                              child:
                                                  FlareTabWidget(false, true));
                                        }),
                                  );
                                });
                              }))
                    ]))));
  }
}
