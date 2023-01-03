import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../general.dart';

class CustomizeFlareScreen extends StatefulWidget {
  final dynamic backgroundColor;
  final dynamic gradientColor;
  final dynamic saveHandler;
  final dynamic asset;
  const CustomizeFlareScreen(
      {required this.backgroundColor,
      required this.gradientColor,
      required this.saveHandler,
      required this.asset});

  @override
  State<CustomizeFlareScreen> createState() => _CustomizeFlareScreenState();
}

class _CustomizeFlareScreenState extends State<CustomizeFlareScreen> {
  late Color stateBackgroundColor;
  late Color stateGradientColor;
  @override
  void initState() {
    super.initState();
    stateBackgroundColor = widget.backgroundColor;
    stateGradientColor = widget.gradientColor;
  }

  void changeStateBackground(Color newColor) =>
      setState(() => stateBackgroundColor = newColor);
  void changeStateGradient(Color newColor) =>
      setState(() => stateGradientColor = newColor);
  Widget buildColorTile(dynamic _allColors, bool isGradient) => GestureDetector(
      onTap: () => showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (_) => GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Material(
                  color: Colors.transparent,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OColorPicker(
                            selectedColor: isGradient
                                ? stateGradientColor
                                : stateBackgroundColor,
                            colors: _allColors,
                            onColorChange: (color) {
                              if (isGradient) {
                                if (color != stateBackgroundColor)
                                  changeStateGradient(color);
                              } else {
                                if (color != stateGradientColor)
                                  changeStateBackground(color);
                              }
                            })
                      ])))),
      child: Container(
          height: 40.0,
          width: 40.0,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(),
              color: isGradient ? stateGradientColor : stateBackgroundColor)));

  Widget _imageAssetWidget(AssetEntity asset) => Image(
      image: AssetEntityImageProvider(asset, isOriginal: false),
      fit: BoxFit.contain);

  Widget _videoAssetWidget(AssetEntity asset) => Stack(children: <Widget>[
        Positioned.fill(child: _imageAssetWidget(asset)),
        const ColoredBox(
            color: Colors.white38,
            child: Center(
                child: Icon(Icons.play_arrow, color: Colors.black, size: 24.0)))
      ]);

  Widget _assetWidgetBuilder(AssetEntity asset) {
    Widget? widget;
    switch (asset.type) {
      case AssetType.audio:
        break;
      case AssetType.video:
        widget = _videoAssetWidget(asset);
        break;
      case AssetType.image:
      case AssetType.other:
        widget = _imageAssetWidget(asset);
        break;
    }
    return widget!;
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    var initialPrimaryPalette = primaryColorsPalette.take(19).toList();
    var initialAccentPalette = accentColorsPalette.take(16).toList();
    var _allColors = [...initialPrimaryPalette, ...initialAccentPalette];
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    tileMode: TileMode.clamp,
                    colors: [stateGradientColor, stateBackgroundColor])),
            child: SafeArea(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: General.widthQuery(context),
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              decoration:
                                  const BoxDecoration(color: Colors.black),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(Icons.arrow_back,
                                            color: Colors.white)),
                                    buildColorTile(_allColors, false),
                                    buildColorTile(_allColors, true),
                                    const Spacer(),
                                    GestureDetector(
                                        onTap: () {
                                          widget.saveHandler(
                                              stateBackgroundColor,
                                              stateGradientColor);
                                          EasyLoading.showSuccess(
                                              lang.flares_customize1,
                                              dismissOnTap: true,
                                              duration:
                                                  const Duration(seconds: 1));
                                        },
                                        child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(lang.flares_customize2,
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontWeight:
                                                        FontWeight.bold))))
                                  ])),
                          Expanded(
                              child: Stack(children: <Widget>[
                            Align(
                                alignment: Alignment.center,
                                child: _assetWidgetBuilder(widget.asset))
                          ]))
                        ])))));
  }
}
