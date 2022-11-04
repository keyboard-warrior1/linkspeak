import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../routes.dart';
import '../../widgets/common/settingsBar.dart';
import '../widgets/Misc/navigationTile.dart';

class UserDailyScreen extends StatefulWidget {
  final dynamic dayID;
  final dynamic userID;
  const UserDailyScreen(this.dayID, this.userID);

  @override
  State<UserDailyScreen> createState() => _UserDailyScreenState();
}

class _UserDailyScreenState extends State<UserDailyScreen> {
  final firestore = FirebaseFirestore.instance;
  String dailyDetails = '';
  late Future<void> getUserDaily;
  Future<void> _getUserDaily() async {
    final theDoc = await firestore
        .doc('Control/Days/${widget.dayID}/Details/Logins/${widget.userID}')
        .get();
    String textData = General.getDocData(theDoc);
    dailyDetails = textData;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserDaily = _getUserDaily();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    var displayName = widget.userID;
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
                      SettingsBar('$displayName ${widget.dayID}'),
                      Expanded(
                          child: FutureBuilder(
                              future: getUserDaily,
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
                                        var args =
                                            UserDailyCollectionScreenArgs(
                                                widget.dayID, widget.userID);
                                        Navigator.pushNamed(context,
                                            RouteGenerator.userDailyCollections,
                                            arguments: args);
                                      },
                                      icon: Icons.data_array,
                                      screenName: 'Collections'),
                                  NavigationTile(
                                      handler: () {
                                        var args = UserDailyDetailsArgs(
                                            widget.userID,
                                            dailyDetails,
                                            widget.dayID);
                                        Navigator.pushNamed(context,
                                            RouteGenerator.userDailyDetails,
                                            arguments: args);
                                      },
                                      icon: Icons.details,
                                      screenName: 'Details'),
                                ]));
                              }))
                    ]))));
  }
}
