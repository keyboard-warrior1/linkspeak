import 'package:flutter/foundation.dart';
import '../models/miniProfile.dart';

class LinkedToScreenProvider with ChangeNotifier {
  List<MiniProfile> _linkedTos = [];
  List<MiniProfile> get getLinked => _linkedTos;

  void setLinks(List<MiniProfile> linked) {
    _linkedTos = linked;
  }

  void moreLinked(List<MiniProfile> extra){
    _linkedTos.addAll(extra);
    notifyListeners();
  }
}
