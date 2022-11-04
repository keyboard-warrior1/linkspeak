import 'package:flutter/foundation.dart';

import '../models/flareCollectionModel.dart';

class FlareTabProvider with ChangeNotifier {
  List<FlareCollectionModel> _collections = [];
  List<FlareCollectionModel> get collections => _collections;
  void setCollections(List<FlareCollectionModel> c) => _collections = c;
  void clearFlares() => _collections.clear();
}
