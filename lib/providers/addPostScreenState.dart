import 'package:flutter/foundation.dart';

class NewPostHelper with ChangeNotifier {
  dynamic _location = '';
  String _locationName = '';
  List<String> _formTopics = [];
  bool _hasSomeThingTyped = false;
  bool _containsSensitiveContent = false;

  List<String> get formTopics => _formTopics;
  dynamic get getLocation => _location;
  String get getLocationName => _locationName;
  bool get hasSomeThingTyped => _hasSomeThingTyped;
  bool get containsSensitive => _containsSensitiveContent;
  void changeLocation(dynamic newLocation) {
    _location = newLocation;
    notifyListeners();
  }

  void changeLocationName(String name) {
    _locationName = name;
    notifyListeners();
  }

  void changeSensitivity(bool value) {
    _containsSensitiveContent = value;
    notifyListeners();
  }

  void toggleSensitivity() {
    _containsSensitiveContent = !_containsSensitiveContent;
    notifyListeners();
  }

  void notEmpty() {
    _hasSomeThingTyped = true;
    notifyListeners();
  }

  void empty() {
    _hasSomeThingTyped = false;
    notifyListeners();
  }

  void addTopic(String topName) {
    _formTopics.insert(0, topName);
    notifyListeners();
  }

  void addMyTopics(List<String> myTopics) {
    _formTopics = [...myTopics];
    notifyListeners();
  }

  void removeTopic(int idx) {
    _formTopics.removeAt(idx);
    notifyListeners();
  }

  void clear() {
    _formTopics.clear();
    _hasSomeThingTyped = false;
    _containsSensitiveContent = false;
    _location = '';
    _locationName = '';
    notifyListeners();
  }
}
