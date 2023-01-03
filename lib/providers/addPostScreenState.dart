import 'package:flutter/foundation.dart';

class NewPostHelper with ChangeNotifier {
  String _locationName = '';
  dynamic _location = '';
  List<String> _formTopics = [];
  bool _hasSomeThingTyped = false;
  bool _containsSensitiveContent = false;
  bool _disabledComments = false;
  String get getLocationName => _locationName;
  dynamic get getLocation => _location;
  bool get hasSomeThingTyped => _hasSomeThingTyped;
  bool get containsSensitive => _containsSensitiveContent;
  bool get disabledComments => _disabledComments;
  List<String> get formTopics => _formTopics;
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

  void changeDisabledComments(bool value) {
    _disabledComments = value;
    notifyListeners();
  }

  void toggleDisabledComments() {
    _disabledComments = !_disabledComments;
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
    for (var topic in myTopics)
      if (!_formTopics.contains(topic)) _formTopics.add(topic);
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
    _disabledComments = false;
    notifyListeners();
  }
}
