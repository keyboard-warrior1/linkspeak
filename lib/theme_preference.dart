import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemePreferences {
  static const PRIM_KEY = "primary";
  static const ACC_KEY = "accent";
  static const LIKE_COLOR = "likeColor";
  static const LIKE_KEY = "like";
  static const ANCHOR_KEY = 'anchor';
  static const DARK_MODE = 'darkMode';
  static const INACTIVE_LIKE_PATH = 'inactiveLikePath';
  static const ACTIVE_LIKE_PATH = 'activeLikePath';
  setPrimaryTheme(Color primary) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PRIM_KEY, primary.value.toString());
  }

  setSecondaryTheme(Color secondary) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(ACC_KEY, secondary.value.toString());
  }

  setLikeTheme(Color likeColor) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(LIKE_COLOR, likeColor.value.toString());
  }

  setIcon(String iconType) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(LIKE_KEY, iconType);
  }

  setIconPaths(String inactivePath, String activePath) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(INACTIVE_LIKE_PATH, inactivePath);
    sharedPreferences.setString(ACTIVE_LIKE_PATH, activePath);
  }

  setAnchorMode(bool mode) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(ANCHOR_KEY, mode);
  }

  setDarkMode(bool mode) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(DARK_MODE, mode);
  }

  Future<List<dynamic>> getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var primaryColorString =
        sharedPreferences.getString(PRIM_KEY) ?? '4279592384';
    var secondaryColorString =
        sharedPreferences.getString(ACC_KEY) ?? '4294967040';
    var likeColorString =
        sharedPreferences.getString(LIKE_COLOR) ?? '4285988611';
    var likeIconString = sharedPreferences.getString(LIKE_KEY) ?? 'Default';
    var likeIconPathInactive = sharedPreferences.get(INACTIVE_LIKE_PATH) ?? '';
    var likeIconPathActive = sharedPreferences.get(ACTIVE_LIKE_PATH) ?? '';
    var anchorMode = sharedPreferences.getBool(ANCHOR_KEY) ?? true;
    var darkMode = sharedPreferences.getBool(DARK_MODE) ?? false;
    var primaryValue = int.parse(primaryColorString);
    var secondaryValue = int.parse(secondaryColorString);
    var likeValue = int.parse(likeColorString);
    var primaryColor = Color(primaryValue);
    var secondaryColor = Color(secondaryValue);
    var likeColor = Color(likeValue);
    return [
      primaryColor,
      secondaryColor,
      likeIconString,
      likeIconPathInactive,
      likeIconPathActive,
      likeColor,
      anchorMode,
      darkMode,
    ];
  }
}
