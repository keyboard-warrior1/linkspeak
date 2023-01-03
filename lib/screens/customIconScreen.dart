import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../general.dart';
import '../providers/themeModel.dart';
import '../widgets/auth/registrationDialog.dart';
import '../widgets/common/settingsBar.dart';

class CustomIconScreen extends StatefulWidget {
  const CustomIconScreen();
  @override
  _CustomIconScreenState createState() => _CustomIconScreenState();
}

class _CustomIconScreenState extends State<CustomIconScreen> {
  String currentInactivePath = '';
  String currentActivePath = '';
  @override
  void initState() {
    super.initState();
    currentInactivePath =
        Provider.of<ThemeModel>(context, listen: false).themeIconPathInactive;
    currentActivePath =
        Provider.of<ThemeModel>(context, listen: false).themeIconPathActive;
  }

  List<AssetEntity> activeAssets = [];
  List<AssetEntity> inActiveAssets = [];

  Future<void> _chooseActive(Color primaryColor, dynamic lang) async {
    const int _maxAssets = 1;
    final _english = lang.assetPickerDelegate;
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            maxAssets: _maxAssets,
            textDelegate: _english,
            selectedAssets: activeAssets,
            requestType: RequestType.image,
            themeColor: primaryColor));
    if (_result != null) {
      activeAssets = List<AssetEntity>.from(_result);
      final imageFile = await activeAssets[0].originFile;
      final path = imageFile!.absolute.path;
      currentActivePath = path;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _chooseInactive(Color primaryColor, dynamic lang) async {
    const int _maxAssets = 1;
    final _english = lang.assetPickerDelegate;
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
            maxAssets: _maxAssets,
            textDelegate: _english,
            selectedAssets: inActiveAssets,
            requestType: RequestType.image,
            themeColor: primaryColor));
    if (_result != null) {
      inActiveAssets = List<AssetEntity>.from(_result);
      final imageFile = await inActiveAssets[0].originFile;
      final path = imageFile!.absolute.path;
      currentInactivePath = path;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final selectedLikeColor = Provider.of<ThemeModel>(context).likeColor;
    final selectedIcon = Provider.of<ThemeModel>(context).themeIcon;
    _showDialog(IconData icon, Color iconColor, String title, String rule) {
      showDialog(
          context: context,
          builder: (_) => RegistrationDialog(
              icon: icon, iconColor: iconColor, title: title, rules: rule));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SettingsBar(lang.screens_customIcon1),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 15.0),
                            Text(lang.screens_customIcon2,
                                style: const TextStyle(
                                    fontSize: 20.0, color: Colors.black)),
                            const SizedBox(width: 15.0),
                            if (currentActivePath != '')
                              IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  onPressed: () =>
                                      _chooseActive(_primaryColor, lang),
                                  icon: Image.file(File(currentActivePath))),
                            if (currentActivePath == '')
                              IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  onPressed: () =>
                                      _chooseActive(_primaryColor, lang),
                                  icon: Icon(selectedIcon,
                                      color: selectedLikeColor, size: 32.0))
                          ]),
                      const SizedBox(height: 30.0),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 15.0),
                            Text(lang.screens_customIcon3,
                                style: const TextStyle(
                                    fontSize: 20.0, color: Colors.black)),
                            const SizedBox(width: 15.0),
                            if (currentInactivePath != '')
                              IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  onPressed: () =>
                                      _chooseInactive(_primaryColor, lang),
                                  icon: Image.file(File(currentInactivePath))),
                            if (currentInactivePath == '')
                              IconButton(
                                  onPressed: () =>
                                      _chooseInactive(_primaryColor, lang),
                                  icon: Icon(selectedIcon,
                                      color: Colors.grey.shade400, size: 32.0))
                          ]),
                      const SizedBox(height: 30.0),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 15.0),
                            ElevatedButton(
                                style: ButtonStyle(
                                    elevation:
                                        MaterialStateProperty.all<double?>(0.0),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color?>(
                                            _primaryColor),
                                    shadowColor:
                                        MaterialStateProperty.all<Color?>(
                                            Colors.transparent),
                                    overlayColor:
                                        MaterialStateProperty.all<Color?>(
                                            Colors.transparent)),
                                onPressed: () {
                                  if (currentActivePath != '' &&
                                      currentInactivePath != '') {
                                    Provider.of<ThemeModel>(context,
                                            listen: false)
                                        .setCustomIcons(currentInactivePath,
                                            currentActivePath);
                                    EasyLoading.showSuccess(
                                        lang.screens_customIcon4,
                                        duration: const Duration(seconds: 1),
                                        dismissOnTap: true);
                                  } else {
                                    _showDialog(
                                      Icons.info_outline,
                                      Colors.blue,
                                      lang.screens_customIcon5,
                                      lang.screens_customIcon6,
                                    );
                                  }
                                },
                                child: Text(lang.screens_customIcon7,
                                    style: TextStyle(color: _accentColor)))
                          ])
                    ]))));
  }
}
