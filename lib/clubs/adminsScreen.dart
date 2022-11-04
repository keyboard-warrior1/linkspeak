import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/screenArguments.dart';
import '../routes.dart';
import '../widgets/common/settingsBar.dart';
import 'adminItem.dart';

class AdminsScreen extends StatefulWidget {
  final dynamic isFounder;
  final dynamic clubName;
  const AdminsScreen({required this.isFounder, required this.clubName});

  @override
  _AdminsScreenState createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  List<String> _adminIDs = [];
  bool isLoading = false;
  bool isLastPage = false;
  final ScrollController _scrollController = ScrollController();
  late Future<void> _getAdmins;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> getAdmins() async {
    final clubAdmins = firestore
        .collection('Clubs')
        .doc(widget.clubName)
        .collection('Moderators');
    final getEm =
        await clubAdmins.orderBy('date', descending: true).limit(20).get();
    final docs = getEm.docs;
    if (docs.isNotEmpty) {
      for (var doc in docs) {
        _adminIDs.add(doc.id);
      }
      if (docs.length < 20) isLastPage = true;
      if (mounted) setState(() {});
      return;
    } else {
      return;
    }
  }

  Future<void> getMoreAdmins() async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      final clubAdmins = firestore
          .collection('Clubs')
          .doc(widget.clubName)
          .collection('Moderators');
      final lastAdmin = await clubAdmins.doc(_adminIDs.last).get();
      final getMore = await clubAdmins
          .orderBy('date', descending: true)
          .startAfterDocument(lastAdmin)
          .limit(20)
          .get();
      final docs = getMore.docs;
      if (docs.isNotEmpty) {
        for (var doc in docs) {
          _adminIDs.add(doc.id);
        }
        isLoading = false;
        if (docs.length < 20) isLastPage = true;
        if (mounted) setState(() {});
        return;
      } else {
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getAdmins = getAdmins();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreAdmins();
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

  void addAdmin(String id) {
    if (!_adminIDs.contains(id)) {
      _adminIDs.insert(0, id);
      setState(() {});
    }
  }

  void removeAdmin(String id) {
    if (_adminIDs.contains(id)) {
      _adminIDs.remove(id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: (widget.isFounder)
          ? FloatingActionButton(
              backgroundColor: _primarySwatch,
              child: Icon(
                Icons.add,
                color: _accentColor,
              ),
              onPressed: () {
                final AssignAdminScreenArgs args = AssignAdminScreenArgs(
                    clubName: widget.clubName,
                    addAdmin: addAdmin,
                    removeAdmin: removeAdmin);
                Navigator.pushNamed(context, RouteGenerator.assignAdminScreen,
                    arguments: args);
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: SizedBox(
          height: _deviceHeight,
          width: _deviceWidth,
          child: FutureBuilder(
            future: _getAdmins,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SettingsBar('Admins'),
                    const Spacer(),
                    const Center(
                      child: const CircularProgressIndicator(strokeWidth: 1.50),
                    ),
                    const Spacer(),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SettingsBar('Admins'),
                      const Spacer(),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'An unknown error has occured',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 15.0),
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color?>(
                                  _primarySwatch,
                                ),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry?>(
                                  const EdgeInsets.all(0.0),
                                ),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder?>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              onPressed: () => setState(() {
                                _getAdmins = getAdmins();
                              }),
                              child: Center(
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: _accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SettingsBar('Admins'),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _adminIDs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _adminIDs.length) {
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
                          return AdminItem(
                            key: UniqueKey(),
                            adminName: _adminIDs[index],
                            isFounder: widget.isFounder,
                            clubName: widget.clubName,
                            addAdmin: addAdmin,
                            removeAdmin: removeAdmin,
                          );
                        }
                        return emptyBox;
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
