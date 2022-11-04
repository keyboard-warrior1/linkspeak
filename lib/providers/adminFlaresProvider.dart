import 'package:flutter/material.dart';

import '../models/flareCollectionModel.dart';

class AdminFlaresProvider extends ChangeNotifier {
  List<FlareCollectionModel> _collections = [];
  List<FlareCollectionModel> get collections => _collections;
  void setCollections(List<FlareCollectionModel> c) => _collections = c;
  void clearFlares() => _collections.clear();
}
