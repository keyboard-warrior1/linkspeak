import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screen_capture_event/screen_capture_event.dart';

import '../../general.dart';
import '../../providers/myProfileProvider.dart';

class BodyWrap extends StatefulWidget {
  final Widget child;
  const BodyWrap({required this.child});

  @override
  State<BodyWrap> createState() => _BodyWrapState();
}

class _BodyWrapState extends State<BodyWrap> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final _bodyKey = GlobalKey();
  late ScreenCaptureEvent? screenListener;
  bool hasPermission = false;
  Future<void> saveScreenshot() async {
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _now = DateTime.now();
    final imgID = _now.toString();
    final myUserScreenshots =
        firestore.doc('Users/$myUsername/Screenshots/$imgID');
    final myUser = firestore.collection('Users').doc(myUsername);
    RenderRepaintBoundary boundary =
        _bodyKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    final File fileImg = File('${directory.path}/$imgID.png');
    fileImg.writeAsBytesSync(List.from(pngBytes));
    final generatedFile = File(fileImg.absolute.path);
    final refURL = 'Screenshots/$myUsername/$imgID';
    storage.ref(refURL).putFile(generatedFile).then((_) async {
      var batch = firestore.batch();
      final options = SetOptions(merge: true);
      final String downloadUrl = await storage.ref(refURL).getDownloadURL();
      batch.set(myUserScreenshots, {'url': downloadUrl, 'date': _now}, options);
      batch.set(myUser, {'screenshots': FieldValue.increment(1)}, options);
      Map<String, dynamic> fields = {'screenshots': FieldValue.increment(1)};
      Map<String, dynamic> docFields = {'url': downloadUrl, 'date': _now};
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'screenshots',
          docID: '$imgID',
          docFields: docFields);
      return batch.commit();
    });
  }

  dynamic handler(String _) => saveScreenshot();
  void initScreenListener() {
    screenListener = ScreenCaptureEvent();
    screenListener!.addScreenShotListener(handler);
    screenListener!.watch();
    hasPermission = true;
  }

  @override
  void initState() {
    super.initState();
    Permission.storage.status.then((status) {
      if (status.isGranted) {
        initScreenListener();
      } else if (status.isLimited) {
        initScreenListener();
      } else {}
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (hasPermission) screenListener!.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(key: _bodyKey, child: widget.child);
}
