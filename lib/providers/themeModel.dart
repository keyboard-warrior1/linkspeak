import 'dart:io';

import 'package:flutter/material.dart';

import '../my_flutter_app_icons.dart' as customIcons;
import '../theme_preference.dart';

class ThemeModel extends ChangeNotifier {
  String _likeName = 'Default';
  String _inactivelikePath = '';
  String _activelikePath = '';
  String _themeType = 'Mosaic';
  bool _anchorMode = true;
  bool _darkMode = false;
  bool _censorMode = true;
  Color _primaryColor = Colors.blue.shade800;
  Color _accentColor = Colors.yellowAccent;
  Color _likeColor = Colors.lightGreenAccent.shade400;
  File? _inactiveLikeFile;
  File? _activeLikeFile;
  IconData _likeIcon = customIcons.MyFlutterApp.upvote;
  ThemePreferences _preferences = ThemePreferences();
  String get selectedIconName => _likeName;
  String get themeIconPathInactive => _inactivelikePath;
  String get themeIconPathActive => _activelikePath;
  String get loginTheme => _themeType;
  bool get anchorMode => _anchorMode;
  bool get darkMode => _darkMode;
  bool get censorMode => _censorMode;
  Color get primary => _primaryColor;
  Color get accent => _accentColor;
  Color get likeColor => _likeColor;
  File? get inactiveLikeFile => _inactiveLikeFile;
  File? get activeLikeFile => _activeLikeFile;
  IconData get themeIcon => _likeIcon;
  ThemeModel() {
    getPreferences();
  }
  void setPrimaryColor(Color value) {
    _preferences.setPrimaryTheme(value);
    _primaryColor = value;
    notifyListeners();
  }

  void setAccentColor(Color value) {
    _preferences.setSecondaryTheme(value);
    _accentColor = value;
    notifyListeners();
  }

  void setLikeColor(Color value) {
    _preferences.setLikeTheme(value);
    _likeColor = value;
    notifyListeners();
  }

  void setAnchorMode() {
    if (_anchorMode) {
      _anchorMode = false;
      _preferences.setAnchorMode(false);
    } else {
      _anchorMode = true;
      _preferences.setAnchorMode(true);
    }
    notifyListeners();
  }

  void setDarkMode() {
    if (_darkMode) {
      _darkMode = false;
      _preferences.setDarkMode(false);
    } else {
      _darkMode = true;
      _preferences.setDarkMode(true);
    }
    notifyListeners();
  }

  void setLoginTheme(String type) {
    _preferences.setLoginTheme(type);
    _themeType = type;
    notifyListeners();
  }

  void setCensorMode() {
    if (_censorMode) {
      _censorMode = false;
      _preferences.setcensorNSFW(false);
    } else {
      _censorMode = true;
      _preferences.setcensorNSFW(true);
    }
    notifyListeners();
  }

  void setIcon(String iconName) {
    _preferences.setIcon(iconName);
    _likeName = iconName;
    switch (iconName) {
      case 'Default':
        _likeIcon = customIcons.MyFlutterApp.upvote;
        break;
      case 'Heart':
        _likeIcon = customIcons.MyFlutterApp.like;
        break;
      case 'Thumb':
        _likeIcon = customIcons.MyFlutterApp.thumbs_up;
        break;
      case 'Lightning':
        _likeIcon = customIcons.MyFlutterApp.lightning;
        break;
      case 'Smiley':
        _likeIcon = customIcons.MyFlutterApp.happy;
        break;
      case 'Sun':
        _likeIcon = customIcons.MyFlutterApp.sun;
        break;
      case 'Moon':
        _likeIcon = customIcons.MyFlutterApp.night;
        break;
      case 'Custom':
        break;
    }
    notifyListeners();
  }

  setCustomIcons(String inactivePath, String activePath) {
    _preferences.setIcon('Custom');
    _preferences.setIconPaths(inactivePath, activePath);
    _likeName = 'Custom';
    _inactivelikePath = inactivePath;
    _activelikePath = activePath;
    _inactiveLikeFile = File(inactivePath);
    _activeLikeFile = File(activePath);
    notifyListeners();
  }

  getPreferences() async {
    List<dynamic> colors = await _preferences.getTheme();
    _primaryColor = colors[0];
    _accentColor = colors[1];
    _likeColor = colors[5];
    _likeName = colors[2];
    _inactivelikePath = colors[3];
    if (_inactivelikePath != '') _inactiveLikeFile = File(_inactivelikePath);
    _activelikePath = colors[4];
    if (_activelikePath != '') _activeLikeFile = File(_activelikePath);
    _anchorMode = colors[6];
    _darkMode = colors[7];
    _censorMode = colors[8];
    _themeType = colors[9];
    switch (_likeName) {
      case 'Default':
        _likeIcon = customIcons.MyFlutterApp.upvote;
        break;
      case 'Heart':
        _likeIcon = customIcons.MyFlutterApp.like;
        break;
      case 'Thumb':
        _likeIcon = customIcons.MyFlutterApp.thumbs_up;
        break;
      case 'Lightning':
        _likeIcon = customIcons.MyFlutterApp.lightning;
        break;
      case 'Smiley':
        _likeIcon = customIcons.MyFlutterApp.happy;
        break;
      case 'Sun':
        _likeIcon = customIcons.MyFlutterApp.sun;
        break;
      case 'Moon':
        _likeIcon = customIcons.MyFlutterApp.night;
        break;
      case 'Custom':
        break;
    }
    notifyListeners();
  }
}
