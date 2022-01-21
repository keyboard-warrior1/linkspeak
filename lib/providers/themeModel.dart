import 'package:flutter/material.dart';
import '../theme_preference.dart';
import '../my_flutter_app_icons.dart' as customIcons;

class ThemeModel extends ChangeNotifier {
  Color _primaryColor = Colors.blue.shade800;
  Color _accentColor = Colors.yellowAccent;
  Color _likeColor = Colors.lightGreenAccent.shade400;
  String _likeName = 'Default';
  String _inactivelikePath = '';
  String _activelikePath = '';
  IconData _likeIcon = customIcons.MyFlutterApp.upvote;
  bool _anchorMode = true;
  bool _darkMode = false;
  ThemePreferences _preferences = ThemePreferences();
  Color get primary => _primaryColor;
  Color get accent => _accentColor;
  Color get likeColor => _likeColor;
  IconData get themeIcon => _likeIcon;
  String get selectedIconName => _likeName;
  String get themeIconPathInactive => _inactivelikePath;
  String get themeIconPathActive => _activelikePath;
  bool get anchorMode => _anchorMode;
  bool get darkMode => _darkMode;
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

  setCustomIcons(String inactivePath, activePath) {
    _preferences.setIcon('Custom');
    _preferences.setIconPaths(inactivePath, activePath);
    _likeName = 'Custom';
    _inactivelikePath = inactivePath;
    _activelikePath = activePath;
    notifyListeners();
  }

  getPreferences() async {
    List<dynamic> colors = await _preferences.getTheme();
    _primaryColor = colors[0];
    _accentColor = colors[1];
    _likeColor = colors[5];
    _likeName = colors[2];
    _inactivelikePath = colors[3];
    _activelikePath = colors[4];
    _anchorMode = colors[6];
    _darkMode = colors[7];
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
