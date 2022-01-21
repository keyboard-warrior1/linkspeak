import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:o_color_picker/o_color_picker.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';
import '../widgets/settingsBar.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../routes.dart';

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
    Color selectedLikeColor,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      onTap: () => setIcon(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: selectedLikeColor,
            size: 25.0,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getPreference = getPreference(_myUsername);
  }

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final setPrimary =
        Provider.of<ThemeModel>(context, listen: false).setPrimaryColor;
    final setAccent =
        Provider.of<ThemeModel>(context, listen: false).setAccentColor;
    final setLikeColor =
        Provider.of<ThemeModel>(context, listen: false).setLikeColor;
    final changeAnchorMode =
        Provider.of<ThemeModel>(context, listen: false).setAnchorMode;
    final changeDarkMode =
        Provider.of<ThemeModel>(context, listen: false).setDarkMode;
    final setIcon = Provider.of<ThemeModel>(context, listen: false).setIcon;
    final selectedIcon = Provider.of<ThemeModel>(context).selectedIconName;
    final selectedLikeColor = Provider.of<ThemeModel>(context).likeColor;
    final selectedPrimaryColor = Theme.of(context).primaryColor;
    final selectedAccentColor = Theme.of(context).accentColor;
    final bool selectedAnchorMode = Provider.of<ThemeModel>(context).anchorMode;
    final bool selectedDarkMode = Provider.of<ThemeModel>(context).darkMode;
    var initialPrimaryPalette = primaryColorsPalette.take(19).toList();
    var initialAccentPalette = accentColorsPalette.take(16).toList();
    var _allColors = [...initialPrimaryPalette, ...initialAccentPalette];
    const _spacer = Spacer(flex: 1);
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SettingsBar('Theme'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 14.0),
                  Text(
                    'Primary color',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
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
                                        status: 'Painting', dismissOnTap: true);
                                    var number = color.value;
                                    var accentNumber =
                                        selectedAccentColor.value;
                                    firestore
                                        .collection('Users')
                                        .doc(myUsername)
                                        .set({
                                      'PrimaryColor': number,
                                      'AccentColor': accentNumber,
                                    }, SetOptions(merge: true)).then((value) {
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
                      height: 35.0,
                      width: 35.0,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 15.0),
                  Text(
                    'Accent color ',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 15.0),
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
                                        status: 'Painting', dismissOnTap: true);
                                    var number = color.value;
                                    var primaryNumber =
                                        selectedPrimaryColor.value;
                                    firestore
                                        .collection('Users')
                                        .doc(myUsername)
                                        .set({
                                      'PrimaryColor': primaryNumber,
                                      'AccentColor': number,
                                    }, SetOptions(merge: true)).then((_) {
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
                      height: 35.0,
                      width: 35.0,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 15.0),
                  Text(
                    'Like color      ',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 15.0),
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
                                    setLikeColor(color);
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    child: Container(
                      height: 35.0,
                      width: 35.0,
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
                  Text(
                    'Like button      ',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  DropdownButton(
                    key: UniqueKey(),
                    borderRadius: BorderRadius.circular(15.0),
                    onChanged: (_) => setState(() {}),
                    underline: Container(color: Colors.transparent),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                    value: selectedIcon,
                    items: [
                      buildLikeButtonItem(customIcons.MyFlutterApp.upvote,
                          'Default', 'Default', setIcon, selectedLikeColor),
                      buildLikeButtonItem(customIcons.MyFlutterApp.like,
                          'Heart', 'Heart', setIcon, selectedLikeColor),
                      buildLikeButtonItem(customIcons.MyFlutterApp.thumbs_up,
                          'Thumb', 'Thumbs up', setIcon, selectedLikeColor),
                      buildLikeButtonItem(customIcons.MyFlutterApp.lightning,
                          'Lightning', 'Zap', setIcon, selectedLikeColor),
                      buildLikeButtonItem(customIcons.MyFlutterApp.happy,
                          'Smiley', 'Smiley', setIcon, selectedLikeColor),
                      buildLikeButtonItem(customIcons.MyFlutterApp.sun, 'Sun',
                          'Sunny', setIcon, selectedLikeColor),
                      buildLikeButtonItem(customIcons.MyFlutterApp.night,
                          'Moon', 'Mystic', setIcon, selectedLikeColor),
                      // DropdownMenuItem<String>(
                      //   value: 'Custom',
                      //   onTap: () {
                      //     Future.delayed(
                      //         const Duration(milliseconds: 100),
                      //         () => Navigator.pushNamed(
                      //             context, RouteGenerator.customIcon));
                      //   },
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: <Widget>[
                      //       const Text(
                      //         'Custom icon..',
                      //         style: TextStyle(
                      //             color: Colors.black, fontSize: 15.0),
                      //       ),
                      //     ],
                      //   ),
                      // ),
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
                    'Language        ',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  DropdownButton(
                    borderRadius: BorderRadius.circular(15.0),
                    onChanged: (_) => setState(() {}),
                    underline: Container(color: Colors.transparent),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                    value: 'English',
                    items: [
                      DropdownMenuItem<String>(
                        value: 'English',
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'English',
                              style: TextStyle(
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
              // SwitchListTile(
              //   activeColor: selectedPrimaryColor,
              //   value: selectedDarkMode,
              //   onChanged: (_) {
              //     changeDarkMode();
              //   },
              //   title: Text(
              //     'Dark mode',
              //     style: TextStyle(
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
                title: Text(
                  'Show anchor',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
              _spacer,
              FutureBuilder(
                future: _getPreference,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Show colors to other users',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                            width: 25.0,
                            child: const CircularProgressIndicator(),
                          )
                        ],
                      ),
                    );
                  }
                  return SwitchListTile(
                    activeColor: selectedPrimaryColor,
                    value: showColors,
                    onChanged: (_) => colorHandler(myUsername),
                    title: Text(
                      'Show colors to other users',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(flex: 20),
            ],
          ),
        ),
      ),
    );
  }
}
