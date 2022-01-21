import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../providers/myProfileProvider.dart';
import '../screens/feedScreen.dart';
import '../widgets/load.dart';
import '../widgets/linkModeDialog.dart';
import '../my_flutter_app_icons.dart' as customIcons;

class LinkModeScreen extends StatefulWidget {
  const LinkModeScreen();

  @override
  _LinkModeScreenState createState() => _LinkModeScreenState();
}

class _LinkModeScreenState extends State<LinkModeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool showCode = false;
  bool modeEnabled = false;
  late Future<void> _getMode;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  void _showDialog(String username) {
    showDialog(context: context, builder: (_) => LinkModeDialog(username));
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

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final profileLink =
        Provider.of<MyProfile>(context, listen: false).addLinked;
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (isLoading) {
      } else {
        result = scanData;
        var thecode = result!.code;
        if ((thecode == myUsername)) {
        } else {
          controller.pauseCamera();
          link(thecode, myUsername, profileLink);
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
    if (isLoading) {
    } else {
      setState(() {
        isLoading = true;
      });
      _showIt(context);
      bool allowsLinks = false;
      final targetUser =
          await firestore.collection('Users').doc(username).get();
      final userLinks =
          firestore.collection('Users').doc(username).collection('Links');
      if (targetUser.data()!.containsKey('LinkModeEnabled')) {
        final actual = targetUser.get('LinkModeEnabled');
        allowsLinks = actual;
      }
      final myLinkDoc = await userLinks.doc(myUsername).get();
      if (!targetUser.exists) {
        Navigator.pop(context);
        EasyLoading.showError(
          "User not found",
          duration: const Duration(seconds: 3),
          dismissOnTap: true,
        );
        setState(() {
          isLoading = false;
        });
        controller!.resumeCamera();
      } else if (!allowsLinks) {
        Navigator.pop(context);
        EasyLoading.showError(
          "User has link mode disabled",
          duration: const Duration(seconds: 3),
          dismissOnTap: true,
        );
        setState(() {
          isLoading = false;
        });
        controller!.resumeCamera();
      } else if (myLinkDoc.exists) {
        Navigator.pop(context);
        EasyLoading.showSuccess(
          "Already linked",
          duration: const Duration(seconds: 2),
          dismissOnTap: true,
        );
        setState(() {
          isLoading = false;
        });
        controller!.resumeCamera();
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
          EasyLoading.showSuccess(
            'Linked',
            dismissOnTap: true,
            duration: const Duration(seconds: 2),
          );
          _showDialog(username);
          profileLink();
          setState(() {
            isLoading = false;
          });
          controller!.resumeCamera();
        }).catchError((_) {
          setState(() {
            isLoading = false;
          });
          controller!.resumeCamera();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FeedScreen.detector.stopListening();
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getMode = getMode(_myUsername);
  }

  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).primaryColor;
    final _accentColor = Theme.of(context).accentColor;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return WillPopScope(
      onWillPop: () async {
        controller?.dispose();
        FeedScreen.detector.startListening();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              _buildQrView(context),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    controller?.dispose();
                    FeedScreen.detector.startListening();
                    Navigator.pop(context);
                  },
                  splashColor: Colors.transparent,
                  icon: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: _accentColor)),
                    child: Icon(
                      customIcons.MyFlutterApp.curve_arrow,
                      color: _accentColor,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: AnimatedOpacity(
                  opacity: (showCode) ? 1.0 : 0.2,
                  duration: kThemeAnimationDuration,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showCode = !showCode;
                      });
                    },
                    child: Container(
                      height: 200.0,
                      width: 200.0,
                      margin: const EdgeInsets.all(10.0),
                      color: Colors.white,
                      child: Center(
                        child: QrImage(
                          data: _myUsername,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: FutureBuilder(
                      future: _getMode,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Enable link mode',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                  ),
                                ),
                                SizedBox(
                                  height: 25.0,
                                  width: 25.0,
                                  child: const CircularProgressIndicator(),
                                )
                              ],
                            ),
                          );
                        }
                        return SwitchListTile(
                          activeColor: _primaryColor,
                          value: modeEnabled,
                          onChanged: (_) async {
                            firestore.collection('Users').doc(_myUsername).set(
                              {'LinkModeEnabled': !modeEnabled},
                              SetOptions(merge: true),
                            );
                            setState(() {
                              modeEnabled = !modeEnabled;
                            });
                          },
                          title: Text(
                            'Enable link mode',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
