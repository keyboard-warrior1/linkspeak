import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../my_flutter_app_icons.dart' as customIcon;

class Scanner extends StatefulWidget {
  const Scanner();

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool flashToggled = false;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

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
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      result = scanData;
      var thecode = result!.code;
      controller.pauseCamera();
      Future.delayed(
          const Duration(seconds: 1), () => controller.resumeCamera());
      if ((thecode == myUsername)) {
      } else {
        firestore.collection('Users').doc('$thecode').get().then((doc) async {
          if (doc.exists) {
            if (flashToggled) {
              await controller.toggleFlash();
              setState(() {
                flashToggled = false;
              });
            }
            final OtherProfileScreenArguments args =
                OtherProfileScreenArguments(otherProfileId: thecode);
            Navigator.pushNamed(
              context,
              (thecode == myUsername)
                  ? RouteGenerator.myProfileScreen
                  : RouteGenerator.posterProfileScreen,
              arguments: args,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).primaryColor;
    final _accentColor = Theme.of(context).accentColor;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildQrView(context),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () {
                  controller?.dispose();
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
                    customIcon.MyFlutterApp.curve_arrow,
                    color: _accentColor,
                  ),
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.7),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                    ),
                  ),
                  child: IconButton(
                    iconSize: 35.0,
                    color: Colors.transparent,
                    onPressed: () async {
                      await controller?.toggleFlash();
                      setState(() {
                        flashToggled = !flashToggled;
                      });
                    },
                    icon: Icon(
                      (!flashToggled)
                          ? Icons.flashlight_on
                          : Icons.flashlight_off,
                      color: _accentColor,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
