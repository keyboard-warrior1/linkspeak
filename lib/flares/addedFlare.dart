import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AddedFlare extends StatelessWidget {
  final int currentIndex;
  final bool isLoading;
  final AssetEntity flareAsset;
  final Color gradientColor;
  final Color backgroundColor;
  const AddedFlare(
      {required this.currentIndex,
      required this.isLoading,
      required this.flareAsset,
      required this.gradientColor,
      required this.backgroundColor});
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

  Widget assetWidgetBuilder(AssetEntity asset) {
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
  Widget build(BuildContext context) => Container(
      height: 150.0,
      width: 110.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              tileMode: TileMode.clamp,
              colors: [gradientColor, backgroundColor])),
      margin: const EdgeInsets.only(right: 5.0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(children: <Widget>[
            Positioned.fill(child: assetWidgetBuilder(flareAsset))
          ])));
}
