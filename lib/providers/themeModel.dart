import 'dart:io';

import 'package:flutter/material.dart';

import '../Locales/appLanguage.dart';
import '../Locales/ar_appLanguage.dart';
import '../Locales/en_appLanguage.dart';
import '../Locales/tr_appLanguage.dart';
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
  TextDirection _textDirection = TextDirection.ltr;
  AppLanguage _appLanguage = EN_Language();
  String _langCode = 'en';
  String _serverLangCode = 'en';
  String get selectedIconName => _likeName;
  String get themeIconPathInactive => _inactivelikePath;
  String get themeIconPathActive => _activelikePath;
  String get loginTheme => _themeType;
  String get langCode => _langCode;
  String get serverLangCode => _serverLangCode;
  bool get anchorMode => _anchorMode;
  bool get darkMode => _darkMode;
  bool get censorMode => _censorMode;
  Color get primary => _primaryColor;
  Color get accent => _accentColor;
  Color get likeColor => _likeColor;
  File? get inactiveLikeFile => _inactiveLikeFile;
  File? get activeLikeFile => _activeLikeFile;
  IconData get themeIcon => _likeIcon;
  TextDirection get textDirection => _textDirection;
  AppLanguage get appLanguage => _appLanguage;
  ThemeModel(BuildContext context) {
    getPreferences(context);
  }
  void handleLangCodeToClass(String paramlangCode) {
    switch (paramlangCode) {
      case 'en':
        _appLanguage = EN_Language();
        _serverLangCode = 'en';
        _langCode = 'EN';
        _textDirection = TextDirection.ltr;
        break;
      case 'ar':
        _appLanguage = AR_Language();
        _serverLangCode = 'ar';
        _langCode = 'ع';
        _textDirection = TextDirection.rtl;
        break;
      case 'tr':
        _appLanguage = TR_Language();
        _serverLangCode = 'tr';
        _langCode = 'TR';
        _textDirection = TextDirection.ltr;
        break;
      default:
        _appLanguage = EN_Language();
        _serverLangCode = 'en';
        _langCode = 'EN';
        _textDirection = TextDirection.ltr;
        break;
    }
  }

  void setLanguage(String newCode) {
    _preferences.setLanguage(newCode);
    handleLangCodeToClass(newCode);
    notifyListeners();
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

  getPreferences(BuildContext context) async {
    List<dynamic> colors = await _preferences.getTheme(context);
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
    var thislangCode = colors[10];
    handleLangCodeToClass(thislangCode);
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
