import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../providers/themeModel.dart';
import '../widgets/settingsBar.dart';
import '../widgets/registrationDialog.dart';
import '../my_flutter_app_icons.dart' as customIcons;

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

  Future<void> _chooseActive(Color primaryColor) async {
    const int _maxAssets = 1;
    final _english = EnglishTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(
      context,
      maxAssets: _maxAssets,
      textDelegate: _english,
      selectedAssets: activeAssets,
      requestType: RequestType.image,
      themeColor: primaryColor,
    );
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

  Future<void> _chooseInactive(Color primaryColor) async {
    const int _maxAssets = 1;
    final _english = EnglishTextDelegate();
    final List<AssetEntity>? _result = await AssetPicker.pickAssets(
      context,
      maxAssets: _maxAssets,
      textDelegate: _english,
      selectedAssets: inActiveAssets,
      requestType: RequestType.image,
      themeColor: primaryColor,
    );
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
    _showDialog(IconData icon, Color iconColor, String title, String rule) {
      showDialog(
        context: context,
        builder: (_) => RegistrationDialog(
          icon: icon,
          iconColor: iconColor,
          title: title,
          rules: rule,
        ),
      );
    }

    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final selectedLikeColor = Provider.of<ThemeModel>(context).likeColor;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SettingsBar('Custom icon'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 15.0),
                  Text(
                    'Active Icon   ',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  if (currentActivePath != '')
                    ImageIcon(
                      FileImage(
                        File(currentActivePath),
                      ),
                    ),
                  if (currentActivePath == '')
                    IconButton(
                      onPressed: () => _chooseActive(_primaryColor),
                      icon: Icon(
                        customIcons.MyFlutterApp.upvote,
                        color: selectedLikeColor,
                        size: 32.0,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 15.0),
                  Text(
                    'Inactive Icon',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  if (currentInactivePath != '')
                    ImageIcon(
                      FileImage(
                        File(currentInactivePath),
                      ),
                    ),
                  if (currentInactivePath == '')
                    IconButton(
                      onPressed: () => _chooseInactive(_primaryColor),
                      icon: Icon(
                        customIcons.MyFlutterApp.upvote,
                        color: Colors.grey.shade400,
                        size: 32.0,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 15.0),
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double?>(0.0),
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(_primaryColor),
                      shadowColor:
                          MaterialStateProperty.all<Color?>(Colors.transparent),
                      overlayColor:
                          MaterialStateProperty.all<Color?>(Colors.transparent),
                    ),
                    onPressed: () {
                      if (currentActivePath != '' &&
                          currentInactivePath != '') {
                        Provider.of<ThemeModel>(context, listen: false)
                            .setCustomIcons(
                                currentInactivePath, currentActivePath);
                        EasyLoading.showSuccess('Saved',
                            duration: const Duration(seconds: 1),
                            dismissOnTap: true);
                      } else {
                        _showDialog(
                          Icons.info_outline,
                          Colors.blue,
                          'Notice',
                          "Active and Inactive images must both be provided",
                        );
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: _accentColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
