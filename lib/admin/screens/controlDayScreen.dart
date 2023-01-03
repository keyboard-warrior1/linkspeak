import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../routes.dart';
import '../../widgets/common/settingsBar.dart';
import '../widgets/Misc/navigationTile.dart';

class ControlDayScreen extends StatefulWidget {
  final dynamic dayID;
  const ControlDayScreen(this.dayID);

  @override
  State<ControlDayScreen> createState() => _ControlDayScreenState();
}

class _ControlDayScreenState extends State<ControlDayScreen> {
  final firestore = FirebaseFirestore.instance;
  late Future<void> getDay;
  String todaysDetails = '';
  List<QueryDocumentSnapshot> allLogins = [];
  List<QueryDocumentSnapshot> logins = [];

  Future<void> _getDay() async {
    var theDoc =
        await firestore.doc('Control/Days/${widget.dayID}/Details').get();
    var textData = General.getDocData(theDoc);
    todaysDetails = textData;
    var _allLogins = await firestore
        .collection('Control/Days/${widget.dayID}/Details/Logins')
        .get();
    var allDocs = _allLogins.docs;
    allLogins = allDocs;
    var collection = await firestore
        .collection('Control/Days/${widget.dayID}/Details/Logins')
        .orderBy('begin', descending: false)
        .limit(1000)
        .get();
    var docs = collection.docs;
    logins.addAll(docs);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getDay = _getDay();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Scaffold(
        body: SafeArea(
            child: SizedBox(
                height: height,
                width: width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SettingsBar(widget.dayID),
                      Expanded(
                          child: FutureBuilder(
                              key: PageStorageKey(
                                  '${DateTime.now().toString()}'),
                              future: getDay,
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
                                  NavigationTile(
                                      handler: () {
                                        var args = ControlDailyLoginsArgs(
                                            widget.dayID, logins, allLogins);
                                        Navigator.pushNamed(context,
                                            RouteGenerator.controlDailyLogins,
                                            arguments: args);
                                      },
                                      icon: Icons.login,
                                      screenName: General.language(context)
                                          .admin_controlDayScreen1),
                                  NavigationTile(
                                      handler: () {
                                        var args =
                                            ControlDailyDetailsScreenArgs(
                                                todaysDetails, widget.dayID);
                                        Navigator.pushNamed(context,
                                            RouteGenerator.controlDailyDetails,
                                            arguments: args);
                                      },
                                      icon: Icons.details,
                                      screenName: General.language(context)
                                          .admin_controlDayScreen2),
                                ]));
                              }))
                    ]))));
  }
}
