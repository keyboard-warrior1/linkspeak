import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/miniProfile.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/myProfileProvider.dart';
import '../widgets/common/linkObject.dart';
import '../widgets/common/settingsBar.dart';

class BlockedUserScreen extends StatefulWidget {
  const BlockedUserScreen();

  @override
  _BlockedUserScreenState createState() => _BlockedUserScreenState();
}

class _BlockedUserScreenState extends State<BlockedUserScreen> {
  final _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<MiniProfile> blockedUsers = [];
  late Future<void> getBlocked;
  bool isLoading = false;
  bool isLastPage = false;

  Future<void> getMyBlocked(String myUsername) async {
    final users = firestore.collection('Users');
    final myBlocked =
        await users.doc(myUsername).collection('Blocked').limit(15).get();
    final myBlockedDocs = myBlocked.docs;
    if (myBlockedDocs.isNotEmpty) {
      for (var blocked in myBlockedDocs) {
        final MiniProfile mini = MiniProfile(username: blocked.id);
        blockedUsers.add(mini);
      }
    }

    if (myBlockedDocs.length < 15) {
      isLastPage = true;
    }
    setState(() {});
  }

  Future<void> getMoreBlocked(String myUsername) async {
    final users = firestore.collection('Users');
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      final myBlocked = users.doc(myUsername).collection('Blocked');
      final lastUsername = blockedUsers.last.username;
      final lastDoc = await myBlocked.doc(lastUsername).get();
      final getBlocked =
          await myBlocked.startAfterDocument(lastDoc).limit(15).get();
      final myBlockedDocs = getBlocked.docs;
      if (myBlockedDocs.isNotEmpty) {
        for (var blocked in myBlockedDocs) {
          final MiniProfile mini = MiniProfile(username: blocked.id);
          blockedUsers.add(mini);
        }
      }
      if (myBlockedDocs.length < 15) {
        isLastPage = true;
      }
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    getBlocked = getMyBlocked(_myUsername);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreBlocked(_myUsername);
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

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final ThemeData _theme = Theme.of(context);
    final Color _primarySwatch = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final MyProfile myProfile = Provider.of<MyProfile>(context);
    final int numOfBlockedUsers = myProfile.myNumOfBlocked;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: (numOfBlockedUsers == 0)
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            SettingsBar(lang.screens_blocked1),
                            if (numOfBlockedUsers == 0) const Spacer(),
                            if (numOfBlockedUsers == 0)
                              Icon(customIcons.MyFlutterApp.no_stopping,
                                  color: Colors.grey.shade300, size: 55.0),
                            if (numOfBlockedUsers == 0)
                              const SizedBox(height: 10.0),
                            if (numOfBlockedUsers == 0)
                              Text(lang.screens_blocked2,
                                  style: TextStyle(
                                      fontSize: 21.0,
                                      color: Colors.grey.shade400)),
                            if (numOfBlockedUsers == 0) const Spacer()
                          ])
                    : FutureBuilder(builder: (_, snapshot) {
                        if (snapshot.hasError) {
                          return SizedBox(
                              height: _deviceHeight,
                              width: _deviceWidth,
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SettingsBar(lang.screens_blocked1),
                                    const Spacer(),
                                    Center(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                          Text(lang.flares_profileFlares1,
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                          const SizedBox(width: 15.0),
                                          TextButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<Color?>(
                                                          _primarySwatch),
                                                  padding: MaterialStateProperty
                                                      .all<EdgeInsetsGeometry?>(
                                                          const EdgeInsets.all(
                                                              0.0)),
                                                  shape: MaterialStateProperty.all<
                                                          OutlinedBorder?>(
                                                      RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10.0)))),
                                              onPressed: () => setState(() {
                                                    getBlocked = getMyBlocked(
                                                        _myUsername);
                                                  }),
                                              child: Center(child: Text(lang.flares_profile2, style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold))))
                                        ])),
                                    const Spacer()
                                  ]));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                              height: _deviceHeight,
                              width: _deviceWidth,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SettingsBar(lang.screens_blocked1),
                                    const Spacer(),
                                    Center(
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 1.50)),
                                    const Spacer()
                                  ]));
                        }
                        return SizedBox(
                            height: _deviceHeight,
                            width: _deviceWidth,
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SettingsBar(lang.screens_blocked1),
                                  Expanded(
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          controller: _scrollController,
                                          itemCount: blockedUsers.length + 1,
                                          itemBuilder: (_, index) {
                                            if (index == blockedUsers.length) {
                                              if (isLoading) {
                                                return Center(
                                                    child: Container(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 10.0),
                                                        height: 35.0,
                                                        width: 35.0,
                                                        child: Center(
                                                            child:
                                                                const CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        1.50))));
                                              }
                                              if (isLastPage) {
                                                return emptyBox;
                                              }
                                            } else {
                                              final username =
                                                  blockedUsers[index].username;
                                              return LinkObject(
                                                  username: username);
                                            }
                                            return emptyBox;
                                          }))
                                ]));
                      }))));
  }
}
