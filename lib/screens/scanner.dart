import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/screenArguments.dart';
import '../my_flutter_app_icons.dart' as customIcon;
import '../providers/myProfileProvider.dart';
import '../routes.dart';

class Scanner extends StatefulWidget {
  final dynamic isClub;
  const Scanner(this.isClub);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool flashToggled = false;
  bool handicap = false;
  Barcode? result;
  MobileScannerController controller = MobileScannerController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRscanner');
  void toggleHandicap(bool newH) => setState(() => handicap = newH);
  void removeHandicap() =>
      Future.delayed(const Duration(seconds: 2), () => toggleHandicap(false));
  void _onDetect(Barcode code, MobileScannerArguments? _) {
    if (!handicap) {
      final String myUsername =
          Provider.of<MyProfile>(context, listen: false).getUsername;
      // Future.delayed(const Duration(seconds: 1), () => controller.start());
      result = code;
      var thecode = result?.rawValue;
      if (thecode != null) {
        if (widget.isClub)
          firestore.collection('Clubs').doc('$thecode').get().then((doc) async {
            if (doc.exists) {
              final ClubScreenArgs args = ClubScreenArgs(thecode);
              Navigator.pushReplacementNamed(context, RouteGenerator.clubScreen,
                  arguments: args);
            } else {
              toggleHandicap(true);
              EasyLoading.showError('Club not found',
                  duration: const Duration(seconds: 1), dismissOnTap: true);
              removeHandicap();
            }
          });
        else
          firestore.collection('Users').doc('$thecode').get().then((doc) async {
            if (doc.exists) {
              final OtherProfileScreenArguments args =
                  OtherProfileScreenArguments(otherProfileId: thecode);
              Navigator.pushReplacementNamed(
                  context,
                  (thecode == myUsername)
                      ? RouteGenerator.myProfileScreen
                      : RouteGenerator.posterProfileScreen,
                  arguments: (thecode == myUsername) ? null : args);
            } else {
              toggleHandicap(true);
              EasyLoading.showError('User not found',
                  duration: const Duration(seconds: 1), dismissOnTap: true);
              removeHandicap();
            }
          });
      }
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   controller.start();
  // }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
        body: SafeArea(
            child: Stack(children: [
      MobileScanner(
          allowDuplicates: true, onDetect: _onDetect, controller: controller),
      Align(
          alignment: Alignment.topLeft,
          child: Container(
              margin: const EdgeInsets.all(10.0),
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
                      child: Icon(customIcon.MyFlutterApp.curve_arrow,
                          color: _accentColor))))),
      Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(flashToggled ? 1 : 0.7),
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
                  icon: Icon(
                      (!flashToggled)
                          ? Icons.flashlight_on
                          : Icons.flashlight_off,
                      color: _accentColor))))
    ])));
  }
}
