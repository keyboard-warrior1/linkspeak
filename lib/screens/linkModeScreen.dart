import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../general.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/myProfileProvider.dart';
import '../widgets/auth/linkModeDialog.dart';
import '../widgets/common/load.dart';

enum ViewMode { normal, showSettings }

class LinkModeScreen extends StatefulWidget {
  const LinkModeScreen();

  @override
  _LinkModeScreenState createState() => _LinkModeScreenState();
}

class _LinkModeScreenState extends State<LinkModeScreen> {
  ViewMode view = ViewMode.normal;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool handicap = false;
  bool showCode = false;
  bool modeEnabled = false;
  bool scanForUsers = true;
  bool scanForClubs = false;
  bool flashToggled = false;
  late Future<void> _getMode;
  Barcode? result;
  MobileScannerController controller = MobileScannerController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  void _showDialog(String username, bool isClub) {
    showDialog(
        context: context, builder: (_) => LinkModeDialog(username, isClub));
  }

  void _showIt(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (_) {
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: const Load());
        });
  }

  void toggleHandicap(bool newH) => setState(() => handicap = newH);
  void removeHandicap() =>
      Future.delayed(const Duration(seconds: 3), () => toggleHandicap(false));
  void startLoading() => setState(() => isLoading = true);
  void stopLoading() => setState(() => isLoading = false);
  void _onDetect(Barcode code, MobileScannerArguments? _) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final profileLink =
        Provider.of<MyProfile>(context, listen: false).addLinked;
    final profileJoinClub =
        Provider.of<MyProfile>(context, listen: false).addClubs;
    if (isLoading || handicap) {
    } else {
      if (scanForUsers) {
        result = code;
        var thecode = result?.rawValue;
        if ((thecode == myUsername)) {
        } else {
          if (thecode != null) {
            link(thecode, myUsername, profileLink);
          }
        }
      }
      if (scanForClubs) {
        result = code;
        var thecode = result?.rawValue;
        if (thecode != null) {
          joinClub(thecode, myUsername, profileJoinClub);
        }
      }
    }
  }

  Future<void> getMode(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    final getMe = await myUser.get();
    if (getMe.data()!.containsKey('LinkModeEnabled')) {
      final value = getMe.get('LinkModeEnabled');
      modeEnabled = value;
      if (mounted) setState(() {});
    }
  }

  Future<void> link(
      String username, String myUsername, void Function() profileLink) async {
    final lang = General.language(context);
    if (isLoading || handicap) {
    } else {
      startLoading();
      _showIt(context);
      bool allowsLinks = false;
      final targetUser =
          await firestore.collection('Users').doc(username).get();
      final userLinks =
          firestore.collection('Users').doc(username).collection('Links');
      if (targetUser.exists) {
        if (targetUser.data()!.containsKey('LinkModeEnabled')) {
          final actual = targetUser.get('LinkModeEnabled');
          allowsLinks = actual;
        }
      }
      final myLinkDoc = await userLinks.doc(myUsername).get();
      if (!targetUser.exists) {
        Navigator.pop(context);
        toggleHandicap(true);
        EasyLoading.showError(lang.screens_linkMode1,
            duration: const Duration(seconds: 3), dismissOnTap: true);
        removeHandicap();
        stopLoading();
      } else if (!allowsLinks) {
        Navigator.pop(context);
        toggleHandicap(true);
        EasyLoading.showError(lang.screens_linkMode2,
            duration: const Duration(seconds: 3), dismissOnTap: true);
        removeHandicap();
        stopLoading();
      } else if (myLinkDoc.exists) {
        Navigator.pop(context);
        toggleHandicap(true);
        EasyLoading.showSuccess(lang.screens_linkMode3,
            duration: const Duration(seconds: 2), dismissOnTap: true);
        removeHandicap();
        stopLoading();
      } else {
        final DateTime _rightNow = DateTime.now();
        var batch = firestore.batch();
        final token = targetUser.get('fcm');
        final userLinksNotifs = firestore
            .collection('Users')
            .doc(username)
            .collection('NewLinksNotifs');
        final myLinked =
            firestore.collection('Users').doc(myUsername).collection('Linked');
        batch.set(userLinks.doc(myUsername), {'date': _rightNow});
        batch.set(myLinked.doc(username), {'date': _rightNow});
        if (targetUser.data()!.containsKey('AllowLinks')) {
          final allowLinks = targetUser.get('AllowLinks');
          if (allowLinks) {
            batch.set(userLinksNotifs.doc(myUsername), {
              'user': myUsername,
              'token': token,
              'date': _rightNow,
            });
            batch.update(firestore.collection('Users').doc(username),
                {'numOfNewLinksNotifs': FieldValue.increment(1)});
          }
        } else {
          batch.set(userLinksNotifs.doc(myUsername), {
            'user': myUsername,
            'token': token,
            'date': _rightNow,
          });
          batch.update(firestore.collection('Users').doc(username),
              {'numOfNewLinksNotifs': FieldValue.increment(1)});
        }
        batch.update(firestore.collection('Users').doc(username),
            {'numOfLinks': FieldValue.increment(1)});
        batch.update(firestore.collection('Users').doc(myUsername),
            {'numOfLinked': FieldValue.increment(1)});
        batch.commit().then((value) {
          Navigator.pop(context);
          toggleHandicap(true);
          EasyLoading.showSuccess(lang.screens_linkedNotif,
              dismissOnTap: true, duration: const Duration(seconds: 2));
          _showDialog(username, false);
          profileLink();
          removeHandicap();
          stopLoading();
        }).catchError((_) {
          stopLoading();
        });
      }
    }
  }

  Future<void> joinClub(String clubName, String myUsername,
      void Function() profileJoinClub) async {
    final lang = General.language(context);
    if (isLoading || handicap) {
    } else {
      startLoading();
      _showIt(context);
      bool allowsLinks = false;
      final targetUser =
          await firestore.collection('Clubs').doc(clubName).get();
      final userLinks =
          firestore.collection('Clubs').doc(clubName).collection('Members');
      if (targetUser.exists) {
        if (targetUser.data()!.containsKey('allowQuickJoin')) {
          final actual = targetUser.get('allowQuickJoin');
          allowsLinks = actual;
        }
      }
      final myLinkDoc = await userLinks.doc(myUsername).get();
      if (!targetUser.exists) {
        Navigator.pop(context);
        toggleHandicap(true);
        EasyLoading.showError(lang.screens_linkMode4,
            duration: const Duration(seconds: 3), dismissOnTap: true);
        removeHandicap();
        stopLoading();
      } else if (!allowsLinks) {
        Navigator.pop(context);
        EasyLoading.showError(lang.screens_linkMode5,
            duration: const Duration(seconds: 3), dismissOnTap: true);
        stopLoading();
      } else if (myLinkDoc.exists) {
        Navigator.pop(context);
        toggleHandicap(true);
        EasyLoading.showSuccess(lang.screens_linkMode6,
            duration: const Duration(seconds: 2), dismissOnTap: true);
        removeHandicap();
        stopLoading();
      } else {
        final DateTime _rightNow = DateTime.now();
        var batch = firestore.batch();
        final myLinked = firestore
            .collection('Users')
            .doc(myUsername)
            .collection('Joined Clubs');
        batch.set(userLinks.doc(myUsername), {'date': _rightNow});
        batch.set(myLinked.doc(clubName), {'date': _rightNow});
        batch.update(firestore.collection('Clubs').doc(clubName),
            {'numOfNewMembers': FieldValue.increment(1)});
        batch.update(firestore.collection('Clubs').doc(clubName),
            {'numOfMembers': FieldValue.increment(1)});
        batch.update(firestore.collection('Users').doc(myUsername),
            {'joinedClubs': FieldValue.increment(1)});
        batch.commit().then((value) {
          Navigator.pop(context);
          toggleHandicap(true);
          EasyLoading.showSuccess(lang.clubs_joinButton5,
              dismissOnTap: true, duration: const Duration(seconds: 2));
          _showDialog(clubName, true);
          profileJoinClub();
          removeHandicap();
          stopLoading();
        }).catchError((_) {
          stopLoading();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getMode = getMode(_myUsername);
    // controller.start();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return WillPopScope(
        onWillPop: () async {
          // controller.dispose();
          return true;
        },
        child: Scaffold(
            body: SafeArea(
                child: Stack(children: [
          MobileScanner(
              onDetect: _onDetect,
              allowDuplicates: true,
              controller: controller),
          Align(
              alignment: Alignment.topLeft,
              child: Container(
                  margin: const EdgeInsets.all(10),
                  child: IconButton(
                      onPressed: () {
                        // controller.dispose();
                        Navigator.pop(context);
                      },
                      splashColor: Colors.transparent,
                      icon: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                              color: _primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: _accentColor)),
                          child: Icon(customIcons.MyFlutterApp.curve_arrow,
                              color: _accentColor))))),
          Align(
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                  opacity: (showCode) ? 1.0 : 0.2,
                  duration: kThemeAnimationDuration,
                  child: GestureDetector(
                      onTap: () {
                        setState(() => showCode = !showCode);
                      },
                      child: Container(
                          height: 175.0,
                          width: 175.0,
                          margin: const EdgeInsets.all(10.0),
                          color: Colors.white,
                          child: Center(
                              child: QrImage(
                                  data: _myUsername,
                                  version: QrVersions.auto,
                                  size: 200.0)))))),
          Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                                topLeft: const Radius.circular(10.0),
                                topRight: const Radius.circular(10.0))),
                        child: IconButton(
                            iconSize: 35.0,
                            color: Colors.transparent,
                            onPressed: () =>
                                setState(() => view = ViewMode.showSettings),
                            icon: Icon(Icons.settings, color: _accentColor))),
                    const SizedBox(width: 25.0),
                    Container(
                        decoration: BoxDecoration(
                            color: _primaryColor
                                .withOpacity(flashToggled ? 1 : 0.7),
                            borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(10.0),
                                topRight: const Radius.circular(10.0))),
                        child: IconButton(
                            iconSize: 35.0,
                            color: Colors.transparent,
                            onPressed: () {
                              controller.toggleTorch();
                              setState(() => flashToggled = !flashToggled);
                            },
                            icon: Column(children: <Widget>[
                              Icon(
                                  (!flashToggled)
                                      ? Icons.flashlight_on
                                      : Icons.flashlight_off,
                                  color: _accentColor)
                            ])))
                  ])),
          Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                  height: view == ViewMode.normal ? 0 : 250.0,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(15.0),
                          topRight: const Radius.circular(15.0))),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: FutureBuilder(
                      future: _getMode,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasError)
                          return Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                          onPressed: () {
                                            setState(
                                                () => view = ViewMode.normal);
                                          },
                                          icon: Icon(Icons.arrow_back))
                                    ]),
                                Center(
                                    child: const SizedBox(
                                        height: 25.0,
                                        width: 25.0,
                                        child: Center(
                                            child:
                                                const CircularProgressIndicator(
                                                    strokeWidth: 1.50))))
                              ]);
                        return Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () {
                                          setState(
                                              () => view = ViewMode.normal);
                                        },
                                        icon: Icon(Icons.arrow_back))
                                  ]),
                              SwitchListTile(
                                  activeColor: _primaryColor,
                                  value: modeEnabled,
                                  onChanged: (_) async {
                                    firestore
                                        .collection('Users')
                                        .doc(_myUsername)
                                        .set(
                                      {'LinkModeEnabled': !modeEnabled},
                                      SetOptions(merge: true),
                                    );
                                    setState(() => modeEnabled = !modeEnabled);
                                  },
                                  title: Text(lang.screens_linkMode7,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0))),
                              SwitchListTile(
                                  activeColor: _primaryColor,
                                  value: scanForUsers,
                                  onChanged: (_) {
                                    if (scanForUsers) {
                                      scanForUsers = false;
                                      scanForClubs = true;
                                    } else {
                                      scanForUsers = true;
                                      scanForClubs = false;
                                    }
                                    setState(() {});
                                  },
                                  title: Text(lang.screens_linkMode8,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0))),
                              SwitchListTile(
                                  activeColor: _primaryColor,
                                  value: scanForClubs,
                                  onChanged: (_) {
                                    if (scanForClubs) {
                                      scanForUsers = true;
                                      scanForClubs = false;
                                    } else {
                                      scanForUsers = false;
                                      scanForClubs = true;
                                    }
                                    setState(() {});
                                  },
                                  title: Text(lang.screens_linkMode9,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15.0)))
                            ]);
                      })))
        ]))));
  }
}
