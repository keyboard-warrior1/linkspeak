// ignore_for_file: unused_local_variable, unused_field

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../general.dart';

class FeatureDocs extends StatefulWidget {
  const FeatureDocs();

  @override
  State<FeatureDocs> createState() => _FeatureDocsState();
}

class _FeatureDocsState extends State<FeatureDocs> {
  final storage = FirebaseStorage.instance;
  static var initialPrimaryPalette = primaryColorsPalette.take(19).toList();
  static var initialAccentPalette = accentColorsPalette.take(16).toList();
  static var _allColors = [...initialPrimaryPalette, ...initialAccentPalette];
  static var _allAlignments = [
    Alignment.bottomCenter,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.center,
    Alignment.centerLeft,
    Alignment.centerRight,
    Alignment.topCenter,
    Alignment.topLeft,
    Alignment.topRight
  ];
  final GlobalKey _globalLauncherKey = GlobalKey();
  final GlobalKey _globalBannerKey = GlobalKey();
  static const x412 =
      "https://firebasestorage.googleapis.com/v0/b/linkspeak-9817c.appspot.com/o/412x360.png?alt=media&token=495c63fb-fcc7-4b82-9a96-53855bd2e727";

  static const x360 =
      "https://firebasestorage.googleapis.com/v0/b/linkspeak-9817c.appspot.com/o/360x308.png?alt=media&token=a1389313-991a-4dfb-a577-ca07f0a6b496";

  static const x312 =
      "https://firebasestorage.googleapis.com/v0/b/linkspeak-9817c.appspot.com/o/312x260.png?alt=media&token=dedee0f4-79ef-4ae6-8a6b-29cadbd3a5fd";

  static const x212 =
      "https://firebasestorage.googleapis.com/v0/b/linkspeak-9817c.appspot.com/o/212x160.png?alt=media&token=4cc6589a-146b-4a3c-b04d-6e52b820d3fe";
  Widget buildLauncherColorTile() {
    _allAlignments.shuffle();
    _allAlignments.shuffle();
    final _random = Random();
    final _allColorsLength = _allColors.length;
    final _randomIndex = _random.nextInt(_allColorsLength);
    final _randomColor = _allColors[_randomIndex];
    final _randomMixIndex = _random.nextInt(_allColorsLength);
    final _randomAlignIndex = _random.nextInt(_allAlignments.length);
    final _randomEnd = _random.nextInt(_allAlignments.length);
    final _randomEnder = _allAlignments[_randomEnd];
    final _randomAlignment = _allAlignments[_randomAlignIndex];
    final _randomMixColor = _allColors[_randomMixIndex];
    return Container(
      height: 51.20,
      width: 51.20,
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: _randomAlignment,
      //     end: _randomEnder,
      //     tileMode: TileMode.clamp,
      //     colors: [
      //       _randomMixColor,
      //       _randomColor,
      //     ],
      //   ),
      // ),
      color: _randomColor,
    );
  }

  Widget buildBannerColorTile() {
    final _random = Random();
    final _allColorsLength = _allColors.length;
    final _randomIndex = _random.nextInt(_allColorsLength);
    final _randomColor = _allColors[_randomIndex];
    return Container(
      height: 10,
      width: 10.24,
      color: _randomColor,
    );
  }

  Widget buildBannerLogo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Text(
              'Linkspeak',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 160.0,
                fontFamily: 'JosefinSans',
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 10.75
                  ..color = Colors.black,
              ),
            ),
            const Text(
              'Linkspeak',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 160.0,
                fontFamily: 'JosefinSans',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildLauncherIcon() {
    // x412
    // x360
    // x312
    // x212
    return ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: 512.0, maxHeight: 512.0, minWidth: 512.0, maxWidth: 512.0),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Image.network(
              x412,
              fit: BoxFit.none,
              height: 500.0,
              width: 500.0,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget buildLauncher() {
    return RepaintBoundary(
      key: _globalLauncherKey,
      child: Container(
        height: 512.0,
        width: 512.0,
        margin: const EdgeInsets.all(20.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(75.0),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    for (var i = 0; i < 10; i++)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          for (var i = 0; i < 10; i++) buildLauncherColorTile()
                        ],
                      ),
                  ],
                ),
              ),
              Positioned.fill(
                child: buildLauncherIcon(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBanner() {
    return RepaintBoundary(
      key: _globalBannerKey,
      child: Container(
        width: 1024.0,
        height: 500.0,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  for (var i = 0; i < 50; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        for (var i = 0; i < 100; i++) buildBannerColorTile()
                      ],
                    ),
                ],
              ),
            ),
            buildBannerLogo(),
          ],
        ),
      ),
    );
  }

  Future<void> saveLauncher() async {
    RenderRepaintBoundary boundary = _globalLauncherKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    final File fileImg = File('${directory.path}/512x512.png');
    fileImg.writeAsBytesSync(List.from(pngBytes));
    final generatedFile = File(fileImg.absolute.path);
    storage.ref('mainLauncher.png').putFile(generatedFile).then((_) {
      print('LAUNCHER DONE');
    });
  }

  Future<void> saveBanner() async {
    RenderRepaintBoundary boundary = _globalBannerKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    final File fileImg = File('${directory.path}/1024x500.png');
    fileImg.writeAsBytesSync(List.from(pngBytes));
    final generatedFile = File(fileImg.absolute.path);
    storage.ref('banner.png').putFile(generatedFile).then((_) {
      print('BANNER DONE');
    });
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: _deviceHeight,
          width: _deviceWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 552.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    const SizedBox(width: 20),
                    buildLauncher(),
                    const SizedBox(width: 20),
                    buildBanner(),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              Container(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text('Randomize'),
                    ),
                    ElevatedButton(
                      onPressed: saveLauncher,
                      child: Text('save launcher'),
                    ),
                    ElevatedButton(
                      onPressed: saveBanner,
                      child: Text('save banner'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  // Widget buildListTile({
  //   required String screenName,
  //   required IconData icon,
  //   required String screenDescription,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Card(
  //       shadowColor: Colors.grey.shade300,
  //       color: Colors.white,
  //       margin: const EdgeInsets.all(
  //         .5,
  //       ),
  //       elevation: 9.0,
  //       child: ListTile(
  //         enabled: true,
  //         onTap: () {},
  //         enableFeedback: true,
  //         leading: Icon(icon),
  //         title: Text(
  //           screenName,
  //           style: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //  buildListTile(
  //                       screenName: 'Home',
  //                       icon: customIcons.MyFlutterApp.feed,
  //                       screenDescription: ''),
  //                   buildListTile(
  //                       screenName: 'Spotlights',
  //                       icon: customIcons.MyFlutterApp.spotlight,
  //                       screenDescription: ''),
  //                   buildListTile(
  //                       screenName: 'Clubs',
  //                       icon: customIcons.MyFlutterApp.clubs,
  //                       screenDescription: ''),
  //                   buildListTile(
  //                       screenName: 'Profile',
  //                       icon: Icons.person,
  //                       screenDescription: ''),
  //                   buildListTile(
  //                       screenName: 'Quick link',
  //                       icon: Icons.phonelink_ring_outlined,
  //                       screenDescription: ''),