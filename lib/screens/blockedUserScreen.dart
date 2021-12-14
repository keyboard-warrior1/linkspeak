import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/miniProfile.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/linkObject.dart';
import '../widgets/settingsBar.dart';
import '../my_flutter_app_icons.dart' as customIcons;

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
  int iDStart = 0;
  int idEnd = 15;
  Future<void> getMyBlocked(List<String> blockedUserIDs) async {
    final users = firestore.collection('Users');
    final int length = blockedUserIDs.length;
    late List<String> sub;
    if (length >= idEnd) {
      sub = blockedUserIDs.sublist(iDStart, idEnd);
    } else {
      final int ind = blockedUserIDs.indexOf(blockedUserIDs.first);
      sub = blockedUserIDs.sublist(ind);
    }
    for (var blocked in sub) {
      final getUser = await users.doc(blocked).get();
      if (getUser.exists) {
        final avatar = getUser.get('Avatar');
        final MiniProfile mini = MiniProfile(username: blocked, imgUrl: avatar);
        blockedUsers.add(mini);
      } else {
        final MiniProfile mini = MiniProfile(username: blocked, imgUrl: '');
        blockedUsers.add(mini);
      }
    }
    iDStart += 10;
    idEnd += 10;
    if (blockedUsers.length >= length) {
      isLastPage = true;
    }
    setState(() {});
  }

  Future<void> getMoreBlocked(List<String> blockedUserIDs) async {
    final users = firestore.collection('Users');
    final int length = blockedUserIDs.length;
    late List<String> sub;
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      if (length >= idEnd) {
        sub = blockedUserIDs.sublist(iDStart, idEnd);
      } else {
        final int ind = blockedUsers.indexOf(blockedUsers.last);
        final String lastName = blockedUsers[ind].username;
        final idIndex = blockedUserIDs.indexOf(lastName);
        sub = blockedUserIDs.sublist(idIndex + 1);
      }
      for (var blocked in sub) {
        final getUser = await users.doc(blocked).get();
        if (getUser.exists) {
          final avatar = getUser.get('Avatar');
          final MiniProfile mini =
              MiniProfile(username: blocked, imgUrl: avatar);
          blockedUsers.add(mini);
        } else {
          final MiniProfile mini = MiniProfile(username: blocked, imgUrl: '');
          blockedUsers.add(mini);
        }
      }
      iDStart += 10;
      idEnd += 10;
      if (blockedUsers.length >= length) {
        isLastPage = true;
      }
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final List<String> _myBlocked =
        Provider.of<MyProfile>(context, listen: false).getBlockedIDs;
    getBlocked = getMyBlocked(_myBlocked);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreBlocked(_myBlocked);
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
    final ThemeData _theme = Theme.of(context);
    final Color _primarySwatch = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final MyProfile myProfile = Provider.of<MyProfile>(context);
    final int numOfBlockedUsers = myProfile.myNumOfBlocked;
    final List<String> _myBlocked =
        Provider.of<MyProfile>(context, listen: false).getBlockedIDs;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return Scaffold(
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
                    const SettingsBar('Blocked users'),
                    if (numOfBlockedUsers == 0) const Spacer(),
                    if (numOfBlockedUsers == 0)
                      Icon(
                        customIcons.MyFlutterApp.no_stopping,
                        color: Colors.grey.shade300,
                        size: 55.0,
                      ),
                    if (numOfBlockedUsers == 0) const SizedBox(height: 10.0),
                    if (numOfBlockedUsers == 0)
                      Text(
                        "No blocked users found",
                        style: TextStyle(
                            fontSize: 21.0, color: Colors.grey.shade400),
                      ),
                    if (numOfBlockedUsers == 0) const Spacer(),
                  ],
                )
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
                          const SettingsBar('Blocked users'),
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
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder?>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () => setState(() {
                                    getBlocked = getMyBlocked(_myBlocked);
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: _deviceHeight,
                      width: _deviceWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SettingsBar('Blocked users'),
                          const Spacer(),
                          Center(child: const CircularProgressIndicator()),
                          const Spacer(),
                        ],
                      ),
                    );
                  }
                  return SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SettingsBar('Blocked users'),
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
                                        margin:
                                            const EdgeInsets.only(bottom: 10.0),
                                        height: 35.0,
                                        width: 35.0,
                                        child: Center(
                                          child:
                                              const CircularProgressIndicator(),
                                        ),
                                      ),
                                    );
                                  }
                                  if (isLastPage) {
                                    return emptyBox;
                                  }
                                } else {
                                  final username = blockedUsers[index].username;
                                  final imgURL = blockedUsers[index].imgUrl;
                                  return LinkObject(
                                      imgUrl: imgURL, username: username);
                                }
                                return emptyBox;
                              }),
                        ),
                      ],
                    ),
                  );
                }),
        ),
      ),
    );
  }
}
