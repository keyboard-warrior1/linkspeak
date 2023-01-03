import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../routes.dart';
import '../widgets/common/settingsBar.dart';
import 'banItem.dart';

class BannedMemberScreen extends StatefulWidget {
  final dynamic clubName;
  const BannedMemberScreen(this.clubName);

  @override
  _BannedMemberScreenState createState() => _BannedMemberScreenState();
}

class _BannedMemberScreenState extends State<BannedMemberScreen> {
  List<String> _bannedIDs = [];
  bool isLoading = false;
  bool isLastPage = false;
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getBannedMembers;
  Future<void> getBannedMembers() async {
    final clubBanned =
        firestore.collection('Clubs').doc(widget.clubName).collection('Banned');
    final getEm =
        await clubBanned.orderBy('date', descending: true).limit(20).get();
    final docs = getEm.docs;
    if (docs.isNotEmpty) {
      for (var doc in docs) {
        _bannedIDs.add(doc.id);
      }
      if (docs.length < 20) isLastPage = true;
      if (mounted) setState(() {});
      return;
    } else {
      return;
    }
  }

  Future<void> getMoreBanned() async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      final clubAdmins = firestore
          .collection('Clubs')
          .doc(widget.clubName)
          .collection('Banned');
      final lastAdmin = await clubAdmins.doc(_bannedIDs.last).get();
      final getMore = await clubAdmins
          .orderBy('date', descending: true)
          .startAfterDocument(lastAdmin)
          .limit(20)
          .get();
      final docs = getMore.docs;
      if (docs.isNotEmpty) {
        for (var doc in docs) {
          _bannedIDs.add(doc.id);
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
    _getBannedMembers = getBannedMembers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreBanned();
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

  void addBanned(String id) {
    if (!_bannedIDs.contains(id)) {
      _bannedIDs.insert(0, id);
      setState(() {});
    }
  }

  void removeBanned(String id) {
    if (_bannedIDs.contains(id)) {
      _bannedIDs.remove(id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    const Widget emptyBox = const SizedBox(width: 0, height: 0);
    final lang = General.language(context);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primarySwatch,
        child: Icon(
          Icons.add,
          color: _accentColor,
        ),
        onPressed: () {
          final BanMemberScreenArgs args = BanMemberScreenArgs(
              clubName: widget.clubName,
              addBanned: addBanned,
              removeBanned: removeBanned);
          Navigator.pushNamed(context, RouteGenerator.banMemberScreen,
              arguments: args);
        },
      ),
      body: SafeArea(
        child: SizedBox(
          height: _deviceHeight,
          width: _deviceWidth,
          child: FutureBuilder(
            future: _getBannedMembers,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SettingsBar(lang.clubs_banned1),
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
                      SettingsBar(lang.clubs_banned1),
                      const Spacer(),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              lang.clubs_banned2,
                              style: const TextStyle(color: Colors.grey),
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
                                _getBannedMembers = getBannedMembers();
                              }),
                              child: Center(
                                child: Text(
                                  lang.clubs_banned3,
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
                  SettingsBar(lang.clubs_banned1),
                  if (_bannedIDs.isEmpty) const Spacer(),
                  if (_bannedIDs.isEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.person,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  if (_bannedIDs.isEmpty) const SizedBox(height: 10.0),
                  if (_bannedIDs.isEmpty)
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(lang.clubs_banned4,
                              style: const TextStyle(color: Colors.grey))
                        ]),
                  if (_bannedIDs.isEmpty) const Spacer(),
                  if (_bannedIDs.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _bannedIDs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _bannedIDs.length) {
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
                            return BanItem(
                                key: UniqueKey(),
                                adminName: _bannedIDs[index],
                                clubName: widget.clubName,
                                addAdmin: addBanned,
                                removeAdmin: removeBanned);
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
