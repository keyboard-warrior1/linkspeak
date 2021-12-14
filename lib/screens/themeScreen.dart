import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:o_color_picker/o_color_picker.dart';
import '../providers/themeModel.dart';
import '../widgets/settingsBar.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen();
  @override
  Widget build(BuildContext context) {
    final setPrimary =
        Provider.of<ThemeModel>(context, listen: false).setPrimaryColor;
    final setAccent =
        Provider.of<ThemeModel>(context, listen: false).setAccentColor;
    final selectedPrimaryColor = Theme.of(context).primaryColor;
    final selectedAccentColor = Theme.of(context).accentColor;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SettingsBar('Themes'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 15.0),
                  Text(
                    'Primary      ',
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
                                colors: primaryColorsPalette,
                                onColorChange: (color) {
                                  if (color == Colors.black ||
                                      color == Colors.white) {
                                  } else {
                                    setPrimary(color);
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
                        color: Theme.of(context).primaryColor,
                      ),
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
                    'Accent       ',
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
                                colors: accentColorsPalette,
                                onColorChange: (color) {
                                  if (color == Colors.black ||
                                      color == Colors.white) {
                                  } else {
                                    setAccent(color);
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
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
