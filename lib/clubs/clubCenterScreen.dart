import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/settingsBar.dart';

class ClubCenterScreen extends StatefulWidget {
  const ClubCenterScreen();

  @override
  _ClubCenterScreenState createState() => _ClubCenterScreenState();
}

class _ClubCenterScreenState extends State<ClubCenterScreen> {
  List<String> _myClubIDs = [];
  bool isLoading = false;
  bool isLastPage = false;
  final ScrollController _scrollController = ScrollController();
  late Future<void> _getMyClubs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> getMyClubs(String myUsername) async {
    final myClubsCollection = firestore
        .collection('Users')
        .doc(myUsername)
        .collection('My Clubs')
        .orderBy('date', descending: true)
        .limit(50);
    final getMyClubs = await myClubsCollection.get();
    final docs = getMyClubs.docs;
    if (docs.isEmpty) {
      return;
    } else {
      for (var doc in docs) {
        _myClubIDs.add(doc.id);
      }
      if (docs.length < 50) isLastPage = true;
      if (mounted) setState(() {});
      return;
    }
  }

  Future<void> getMoreClubs(String myUsername) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      final myClubsCollection =
          firestore.collection('Users').doc(myUsername).collection('My Clubs');
      final lastID = _myClubIDs.last;
      final lastDoc = await myClubsCollection.doc(lastID).get();
      final getMoreClubs = await myClubsCollection
          .orderBy('date', descending: true)
          .startAfterDocument(lastDoc)
          .limit(50)
          .get();
      final docs = getMoreClubs.docs;
      if (docs.isEmpty) {
        return;
      } else {
        for (var doc in docs) {
          _myClubIDs.add(doc.id);
        }
        isLoading = false;
        if (docs.length < 50) isLastPage = true;
        if (mounted) setState(() {});
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getMyClubs = getMyClubs(myUsername);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreClubs(myUsername);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
  }

  void addClub(String clubName) {
    _myClubIDs.insert(0, clubName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    final lang = General.language(context);
    return FutureBuilder(
      future: _getMyClubs,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SettingsBar(lang.clubs_center1),
                    const Spacer(),
                    const Center(
                      child: const CircularProgressIndicator(strokeWidth: 1.50),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SettingsBar(lang.clubs_center1),
                const Spacer(),
                Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      Text(
                        lang.clubs_center2,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 15.0),
                      TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              _primarySwatch,
                            ),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry?>(
                              const EdgeInsets.all(0.0),
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder?>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          onPressed: () => setState(() {
                                _getMyClubs = getMyClubs(myUsername);
                              }),
                          child: Center(
                              child: Text(lang.clubs_center3,
                                  style: TextStyle(
                                      color: _accentColor,
                                      fontWeight: FontWeight.bold))))
                    ])),
                const Spacer(),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            backgroundColor: _primarySwatch,
            child: Icon(
              Icons.add,
              color: _accentColor,
            ),
            onPressed: () {
              final CreateClubArgs args = CreateClubArgs(addClub);
              Navigator.pushNamed(context, RouteGenerator.createClubScreen,
                  arguments: args);
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: SizedBox(
              height: _deviceHeight,
              width: _deviceWidth,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SettingsBar(lang.clubs_center1),
                  if (_myClubIDs.isEmpty) const Spacer(),
                  if (_myClubIDs.isEmpty)
                    const Icon(
                      customIcons.MyFlutterApp.clubs,
                      color: Colors.grey,
                      size: 55.0,
                    ),
                  if (_myClubIDs.isEmpty)
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(lang.clubs_center4,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 25.0))
                        ]),
                  if (_myClubIDs.isEmpty) const Spacer(),
                  if (_myClubIDs.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _myClubIDs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _myClubIDs.length) {
                            if (isLoading) {
                              return Center(
                                child: SizedBox(
                                  height: 35.0,
                                  width: 35.0,
                                  child: Center(
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 1.50),
                                  ),
                                ),
                              );
                            }
                            if (isLastPage) {
                              return emptyBox;
                            }
                          } else {
                            return ListTile(
                              onTap: () {
                                final ClubScreenArgs args =
                                    ClubScreenArgs(_myClubIDs[index]);
                                Navigator.pushNamed(
                                    context, RouteGenerator.clubScreen,
                                    arguments: args);
                              },
                              title: Text(
                                _myClubIDs[index],
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }
                          return emptyBox;
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
