import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemePreferences {
  static const PRIM_KEY = "primary";
  static const ACC_KEY = "accent";

  setPrimaryTheme(Color primary) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PRIM_KEY, primary.value.toString());
  }

  setSecondaryTheme(Color secondary) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(ACC_KEY, secondary.value.toString());
  }

  Future<List<Color>> getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var primaryColorString = sharedPreferences.getString(PRIM_KEY) ?? '4279592384';
    var secondaryColorString = sharedPreferences.getString(ACC_KEY) ?? '4294967040';
    var primaryValue = int.parse(primaryColorString);
    var secondaryValue = int.parse(secondaryColorString);
    var primaryColor = Color(primaryValue);
    var secondaryColor = Color(secondaryValue);
    return [primaryColor, secondaryColor];
  }
}
