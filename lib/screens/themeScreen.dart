import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'package:provider/provider.dart';

import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../general.dart';
import '../routes.dart';
import '../widgets/auth/languagePicker.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen();

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getPreference;
  bool showColors = true;




  Future<void> colorHandler(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    if (showColors) {
      setState(() {
        showColors = false;
      });
      return myUser.set({'showColors': false}, SetOptions(merge: true));
    } else {
      setState(() {
        showColors = true;
      });
      return myUser.set({'showColors': true}, SetOptions(merge: true));
    }
  }

  Future<void> getPreference(String myUsername) async {
    final myUser = firestore.collection('Users').doc(myUsername);
    final getMe = await myUser.get();
    if (getMe.data()!.containsKey('showColors')) {
      final value = getMe.get('showColors');
      showColors = value;
      if (mounted) setState(() {});
    }
  }

  DropdownMenuItem<String> buildLikeButtonItem(
          IconData icon,
          String value,
          String description,
          void Function(String) setIcon,
          Color selectedLikeColor) =>
      DropdownMenuItem<String>(
          value: value,
          onTap: () => setIcon(value),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: selectedLikeColor, size: 25.0)
              ]));

  @override
  void initState() {
    super.initState();
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getPreference = getPreference(_myUsername);
  }

  Widget buildContainer(String value, String currentTheme, IconData icon,
      void Function(String) changeTheme) {
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final bool isChosen = value == currentTheme;
    return GestureDetector(
      onTap: () {
        if (!isChosen) changeTheme(value);
      },
      child: Container(
        height: 25.0,
        width: 25.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChosen ? _accentColor : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isChosen ? _primaryColor : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final selectedPrimaryColor = Theme.of(context).colorScheme.primary;
    final selectedAccentColor = Theme.of(context).colorScheme.secondary;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final _themeListen = Provider.of<ThemeModel>(context);
    final _themeNoListen = Provider.of<ThemeModel>(context, listen: false);
    final setPrimary = _themeNoListen.setPrimaryColor;
    final setAccent = _themeNoListen.setAccentColor;
    final setLikeColor = _themeNoListen.setLikeColor;
    final changeAnchorMode = _themeNoListen.setAnchorMode;
    final changeCensorMode = _themeNoListen.setCensorMode;
    final changeTheme = _themeNoListen.setLoginTheme;
    // final changeDarkMode = _themeNoListen.setDarkMode;
    final setIcon = _themeNoListen.setIcon;
    final selectedIcon = _themeListen.selectedIconName;
    final selectedLikeColor = _themeListen.likeColor;
    final bool selectedAnchorMode = _themeListen.anchorMode;
    final bool selectedCensorMode = _themeListen.censorMode;
    // final bool selectedDarkMode = _themeListen.darkMode;
    final String currentTheme = _themeListen.loginTheme;
    var initialPrimaryPalette = primaryColorsPalette.take(19).toList();
    var initialAccentPalette = accentColorsPalette.take(16).toList();
    var _allColors = [...initialPrimaryPalette, ...initialAccentPalette];
    const _spacer = const SizedBox(height: 10);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SettingsBar(lang.screens_theme1),
              Expanded(
                child: Noglow(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15.0),
                          Text(lang.screens_theme2,
                              style: const TextStyle(
                                  fontSize: 17.0, color: Colors.black)),
                          const SizedBox(width: 15.0),
                          GestureDetector(
                            onTap: () => showDialog<void>(
                              barrierDismissible: true,
                              context: context,
                              builder: (_) => GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      OColorPicker(
                                        selectedColor: selectedPrimaryColor,
                                        colors: _allColors,
                                        onColorChange: (color) {
                                          if (color == Colors.black ||
                                              color == Colors.white ||
                                              color == selectedAccentColor) {
                                          } else {
                                            EasyLoading.show(
                                                status: lang.screens_theme3,
                                                dismissOnTap: true);
                                            var number = color.value;
                                            var accentNumber =
                                                selectedAccentColor.value;
                                            var likeNumber =
                                                selectedLikeColor.value;
                                            firestore
                                                .collection('Users')
                                                .doc(myUsername)
                                                .set({
                                              'PrimaryColor': number,
                                              'AccentColor': accentNumber,
                                              'LikeColor': likeNumber,
                                            }, SetOptions(merge: true)).then(
                                                    (value) {
                                              EasyLoading.dismiss();
                                              setPrimary(color);
                                              Navigator.of(context).pop();
                                            }).catchError((_) {
                                              EasyLoading.dismiss();
                                              setPrimary(color);
                                              Navigator.of(context).pop();
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(),
                                color: selectedPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _spacer,
                      _spacer,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15.0),
                          Text(lang.screens_theme4,
                              style: const TextStyle(
                                  fontSize: 17.0, color: Colors.black)),
                          const SizedBox(width: 16.0),
                          GestureDetector(
                            onTap: () => showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      OColorPicker(
                                        selectedColor: selectedAccentColor,
                                        colors: _allColors,
                                        onColorChange: (color) {
                                          if (color == Colors.black ||
                                              color == Colors.white ||
                                              color == selectedPrimaryColor) {
                                          } else {
                                            EasyLoading.show(
                                                status: lang.screens_theme3,
                                                dismissOnTap: true);
                                            var number = color.value;
                                            var primaryNumber =
                                                selectedPrimaryColor.value;
                                            var likeNumber =
                                                selectedLikeColor.value;
                                            firestore
                                                .collection('Users')
                                                .doc(myUsername)
                                                .set({
                                              'PrimaryColor': primaryNumber,
                                              'AccentColor': number,
                                              'LikeColor': likeNumber,
                                            }, SetOptions(merge: true)).then(
                                                    (_) {
                                              EasyLoading.dismiss();
                                              setAccent(color);
                                              Navigator.of(context).pop();
                                            }).catchError((_) {
                                              EasyLoading.dismiss();
                                              setAccent(color);
                                              Navigator.of(context).pop();
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(),
                                color: selectedAccentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _spacer,
                      _spacer,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15.0),
                          Text(lang.screens_theme5,
                              style: const TextStyle(
                                  fontSize: 17.0, color: Colors.black)),
                          const SizedBox(width: 16.0),
                          GestureDetector(
                            onTap: () => showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      OColorPicker(
                                        selectedColor: selectedLikeColor,
                                        colors: _allColors,
                                        onColorChange: (color) {
                                          if (color == Colors.black ||
                                              color == Colors.white) {
                                          } else {
                                            EasyLoading.show(
                                                status: lang.screens_theme3,
                                                dismissOnTap: true);
                                            var number = color.value;
                                            var primaryNumber =
                                                selectedPrimaryColor.value;
                                            var accentNumber =
                                                selectedAccentColor.value;
                                            firestore
                                                .collection('Users')
                                                .doc(myUsername)
                                                .set({
                                              'PrimaryColor': primaryNumber,
                                              'AccentColor': accentNumber,
                                              'LikeColor': number,
                                            }, SetOptions(merge: true)).then(
                                                    (_) {
                                              EasyLoading.dismiss();
                                              setLikeColor(color);
                                              Navigator.of(context).pop();
                                            }).catchError((_) {
                                              EasyLoading.dismiss();
                                              setLikeColor(color);
                                              Navigator.of(context).pop();
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(),
                                color: selectedLikeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _spacer,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15.0),
                          Text(lang.screens_theme6,
                              style: const TextStyle(
                                  fontSize: 17.0, color: Colors.black)),
                          DropdownButton(
                            key: UniqueKey(),
                            borderRadius: BorderRadius.circular(15.0),
                            onChanged: (_) => setState(() {}),
                            underline: Container(color: Colors.transparent),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.black),
                            value: selectedIcon,
                            items: [
                              buildLikeButtonItem(
                                  customIcons.MyFlutterApp.upvote,
                                  'Default',
                                  lang.screens_theme7,
                                  setIcon,
                                  selectedLikeColor),
                              buildLikeButtonItem(
                                  customIcons.MyFlutterApp.like,
                                  'Heart',
                                  lang.screens_theme8,
                                  setIcon,
                                  selectedLikeColor),
                              buildLikeButtonItem(
                                  customIcons.MyFlutterApp.thumbs_up,
                                  'Thumb',
                                  lang.screens_theme9,
                                  setIcon,
                                  selectedLikeColor),
                              buildLikeButtonItem(
                                  customIcons.MyFlutterApp.lightning,
                                  'Lightning',
                                  lang.screens_theme10,
                                  setIcon,
                                  selectedLikeColor),
                              buildLikeButtonItem(
                                  customIcons.MyFlutterApp.happy,
                                  'Smiley',
                                  lang.screens_theme11,
                                  setIcon,
                                  selectedLikeColor),
                              buildLikeButtonItem(
                                  customIcons.MyFlutterApp.sun,
                                  'Sun',
                                  lang.screens_theme12,
                                  setIcon,
                                  selectedLikeColor),
                              buildLikeButtonItem(
                                  customIcons.MyFlutterApp.night,
                                  'Moon',
                                  lang.screens_theme13,
                                  setIcon,
                                  selectedLikeColor),
                              DropdownMenuItem<String>(
                                value: 'Custom',
                                onTap: () {
                                  Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () => Navigator.pushNamed(
                                          context, RouteGenerator.customIcon));
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      lang.screens_theme14,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _spacer,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15.0),
                          Text(
                            lang.screens_theme15,
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Colors.black,
                            ),
                          ),
                          const LanguagePicker(true)
                        ],
                      ),
                      _spacer,
                      // SwitchListTile(
                      //   activeColor: selectedPrimaryColor,
                      //   value: selectedDarkMode,
                      //   onChanged: (_) {
                      //     changeDarkMode();
                      //   },
                      //   title:const Text(
                      //     'Dark mode',
                      //     style:const TextStyle(
                      //       color: Colors.black,
                      //       fontSize: 20.0,
                      //     ),
                      //   ),
                      // ),
                      // _spacer,
                      SwitchListTile(
                          activeColor: selectedPrimaryColor,
                          value: selectedAnchorMode,
                          onChanged: (_) {
                            changeAnchorMode();
                          },
                          title: Text(lang.screens_theme16,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17.0))),
                      _spacer,
                      SwitchListTile(
                          activeColor: selectedPrimaryColor,
                          value: selectedCensorMode,
                          onChanged: (_) {
                            changeCensorMode();
                          },
                          title: Text(lang.screens_theme17,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17.0))),
                      _spacer,
                      FutureBuilder(
                          future: _getPreference,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                snapshot.hasError) {
                              return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(lang.screens_theme18,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 17.0)),
                                        const SizedBox(
                                            height: 25.0,
                                            width: 25.0,
                                            child:
                                                const CircularProgressIndicator(
                                                    strokeWidth: 1.50))
                                      ]));
                            }
                            return SwitchListTile(
                                activeColor: selectedPrimaryColor,
                                value: showColors,
                                onChanged: (_) => colorHandler(myUsername),
                                title: Text(lang.screens_theme18,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 17.0)));
                          }),
                      _spacer,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15.0),
                          Text(lang.screens_theme19,
                              style: const TextStyle(
                                  fontSize: 17.0, color: Colors.black)),
                          Container(
                            width: 150.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: selectedPrimaryColor,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                buildContainer('Mosaic', currentTheme,
                                    Icons.auto_awesome_mosaic, changeTheme),
                                buildContainer('Rainy', currentTheme,
                                    Icons.water_drop, changeTheme),
                                buildContainer('None', currentTheme,
                                    Icons.remove_circle, changeTheme),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
