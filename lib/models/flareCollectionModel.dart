import 'package:flutter/material.dart';

import '../models/flare.dart';
import '../providers/flareCollectionHelper.dart';

class FlareCollectionModel {
  final String posterID;
  final String collectionID;
  final String collectionName;
  final bool isEmpty;
  final List<Flare> flares;
  final FlareCollectionHelper instance;
  final ScrollController? controller;
  const FlareCollectionModel(
      {required this.posterID,
      required this.collectionID,
      required this.collectionName,
      required this.isEmpty,
      required this.flares,
      required this.controller,
      required this.instance});
  void collectionSetter() {
    instance.setPosterID(posterID);
    instance.setCollectionID(collectionID);
    instance.setCollectionName(collectionName);
    if (controller != null) instance.setScrollController(controller!);
    instance.setFlares(flares);
    instance.setIsEmpty(isEmpty);
  }
}
