import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../providers/fullFlareHelper.dart';

class Flare {
  final String poster;
  final String collectionID;
  final String collectionName;
  final String flareID;
  final FlareHelper instance;
  final bool isAdded;
  Color backgroundColor;
  Color gradientColor;
  final String path;
  final AssetEntity? asset;
  Flare(
      {required this.instance,
      required this.poster,
      required this.flareID,
      required this.collectionID,
      required this.collectionName,
      required this.backgroundColor,
      required this.gradientColor,
      required this.isAdded,
      required this.path,
      required this.asset});
  void changeBackground(Color c) => backgroundColor = c;
  void changeGradient(Color c) => gradientColor = c;
  void flareSetter() {
    instance.setposter(poster);
    instance.setCollectionName(collectionName);
    instance.setCollectionID(collectionID);
    instance.setFlareID(flareID);
  }
}
