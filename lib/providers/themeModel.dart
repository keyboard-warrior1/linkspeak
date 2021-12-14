//theme_model.dart
import 'package:flutter/material.dart';
import '../theme_preference.dart';

class ThemeModel extends ChangeNotifier {
  Color _primaryColor = Colors.blue.shade800;
  Color _accentColor = Colors.yellowAccent;
  ThemePreferences _preferences = ThemePreferences();
  Color get primary => _primaryColor;
  Color get accent => _accentColor;

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

  getPreferences() async {
    List<Color> colors = await _preferences.getTheme();
    _primaryColor = colors[0];
    _accentColor = colors[1];
    notifyListeners();
  }
}
