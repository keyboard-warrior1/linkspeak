import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../general.dart';
import '../../models/myCollectionModel.dart';
import '../../models/screenArguments.dart';
import '../../routes.dart';
import '../../widgets/common/settingsBar.dart';

class UserDailyCollectionScreen extends StatefulWidget {
  final dynamic dayID;
  final dynamic userID;
  const UserDailyCollectionScreen(this.dayID, this.userID);

  @override
  State<UserDailyCollectionScreen> createState() =>
      _UserDailyCollectionScreenState();
}

class _UserDailyCollectionScreenState extends State<UserDailyCollectionScreen> {
  var firestore = FirebaseFirestore.instance;
  Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> collections =
      {};
  List<MyCollectionModel> theCollections = [];
  late Future<void> getDailyCollections;
  Future<void> _getSingleCollection(String collectionName) async {
    var getCollection = await firestore
        .collection(
            'Control/Days/${widget.dayID}/Details/Logins/${widget.userID}/$collectionName')
        .get();
    var docs = getCollection.docs;
    if (docs.isNotEmpty) collections.addAll({collectionName: docs});
  }

  Future<void> _getDailyCollections() async {
    await _getSingleCollection('banned users');
    await _getSingleCollection('club members banned');
    await _getSingleCollection('club members unbanned');
    await _getSingleCollection('club joins');
    await _getSingleCollection('club leaves');
    await _getSingleCollection('viewed clubs');
    await _getSingleCollection('clubs');
    await _getSingleCollection('modifications clubs');
    await _getSingleCollection('club posts');
    await _getSingleCollection('flare comments');
    await _getSingleCollection('flare replies');
    await _getSingleCollection('flare likes');
    await _getSingleCollection('flare unlikes');
    await _getSingleCollection('muted');
    await _getSingleCollection('unmuted');
    await _getSingleCollection('flare comment likes');
    await _getSingleCollection('flare comment unlikes');
    await _getSingleCollection('shown flare comments');
    await _getSingleCollection('viewed flare comments');
    await _getSingleCollection('deleted flare comments');
    await _getSingleCollection('viewed flare profiles');
    await _getSingleCollection('flare reply likes');
    await _getSingleCollection('flare reply unlikes');
    await _getSingleCollection('deleted flare replies');
    await _getSingleCollection('shown flare replies');
    await _getSingleCollection('deleted flare');
    await _getSingleCollection('shown collections');
    await _getSingleCollection('shown flares');
    await _getSingleCollection('viewed flares');
    await _getSingleCollection('modifications additional');
    await _getSingleCollection('posts');
    await _getSingleCollection('viewed comments');
    await _getSingleCollection('modifications');
    await _getSingleCollection('viewed profiles');
    await _getSingleCollection('links accepted');
    await _getSingleCollection('links denied');
    await _getSingleCollection('post reports');
    await _getSingleCollection('profile reports');
    await _getSingleCollection('comment reports');
    await _getSingleCollection('reply reports');
    await _getSingleCollection('club reports');
    await _getSingleCollection('spotlight reports');
    await _getSingleCollection('prohibited clubs');
    await _getSingleCollection('users unbanned');
    await _getSingleCollection('users blocked');
    await _getSingleCollection('users unblocked');
    await _getSingleCollection('links removed');
    await _getSingleCollection('posts fav');
    await _getSingleCollection('posts unfav');
    await _getSingleCollection('posts hidden');
    await _getSingleCollection('deleted posts');
    await _getSingleCollection('deleted club posts');
    await _getSingleCollection('club comments');
    await _getSingleCollection('comments');
    await _getSingleCollection('club replies');
    await _getSingleCollection('replies');
    await _getSingleCollection('club comment likes');
    await _getSingleCollection('comment likes');
    await _getSingleCollection('club comment unlikes');
    await _getSingleCollection('comment unlikes');
    await _getSingleCollection('shown comments');
    await _getSingleCollection('deleted club comments');
    await _getSingleCollection('deleted comments');
    await _getSingleCollection('club post views');
    await _getSingleCollection('post views');
    await _getSingleCollection('reply likes');
    await _getSingleCollection('reply unlikes');
    await _getSingleCollection('deleted club replies');
    await _getSingleCollection('deleted replies');
    await _getSingleCollection('shown replies');
    await _getSingleCollection('screenshots');
    await _getSingleCollection('suggested clubs');
    await _getSingleCollection('suggested users');
    await _getSingleCollection('viewed places');
    await _getSingleCollection('club post unlikes');
    await _getSingleCollection('club post likes');
    await _getSingleCollection('post unlikes');
    await _getSingleCollection('post likes');
    await _getSingleCollection('shown posts');
    await _getSingleCollection('links');
    await _getSingleCollection('links unlinked');
    await _getSingleCollection('link requests');
    await _getSingleCollection('club post shares');
    await _getSingleCollection('post shares');
    await _getSingleCollection('flare shares');
    await _getSingleCollection('viewed topics');
    await _getSingleCollection('Sessions');
    collections.forEach(
        (key, value) => theCollections.add(MyCollectionModel(key, value)));
  }

  Widget buildTextButton(String id, dynamic docs) => TextButton(
      key: ValueKey<String>(id),
      onPressed: () {
        var args = UserDailyCollectionDocScreenArgs(
            widget.dayID, widget.userID, id, docs);
        Navigator.pushNamed(context, RouteGenerator.userDailyCollectionDocs,
            arguments: args);
      },
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Text(id)]));

  @override
  void initState() {
    super.initState();
    getDailyCollections = _getDailyCollections();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    String displayName = widget.userID;
    if (widget.userID.length > 15)
      displayName = '${widget.userID.substring(0, 15)}';
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
                      SettingsBar(
                          '$displayName ${widget.dayID} ${General.language(context).admin_userDailyCollections}'),
                      Expanded(
                          child: FutureBuilder(
                              future: getDailyCollections,
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: const <Widget>[
                                        const SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 1.50))
                                      ]);
                                return Expanded(
                                    child: ListView(children: <Widget>[
                                  ...theCollections
                                      .map((e) => buildTextButton(
                                          e.collectionName, e.docs))
                                      .toList()
                                ]));
                              }))
                    ]))));
  }
}
