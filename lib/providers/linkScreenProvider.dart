import 'package:flutter/foundation.dart';

import '../models/miniProfile.dart';

class LinkScreenProvider with ChangeNotifier {
  List<MiniProfile> _links = [];
  List<MiniProfile> get getLinks => _links;
  void setLinks(List<MiniProfile> links) => _links = links;
  void moreLinks(List<MiniProfile> extra) {
    _links.addAll(extra);
    notifyListeners();
  }
}
