import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/themeModel.dart';
import 'languagePicker.dart';

class LoginThemeChanger extends StatefulWidget {
  const LoginThemeChanger();

  @override
  State<LoginThemeChanger> createState() => _LoginThemeChangerState();
}

class _LoginThemeChangerState extends State<LoginThemeChanger> {
  String currentTheme = 'Mosaic';

  Widget buildContainer(
      String value, IconData icon, void Function(String) changeTheme) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final bool isChosen = value == currentTheme;
    return GestureDetector(
        onTap: () {
          if (!isChosen) {
            changeTheme(value);
            setState(() {
              currentTheme = value;
            });
          }
        },
        child: Container(
            height: 25.0,
            width: 25.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChosen ? _accentColor : Colors.transparent),
            child: Icon(icon, color: isChosen ? _primaryColor : Colors.white)));
  }

  @override
  void initState() {
    super.initState();
    final String loginTheme =
        Provider.of<ThemeModel>(context, listen: false).loginTheme;
    currentTheme = loginTheme;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final void Function(String) changeTheme =
        Provider.of<ThemeModel>(context, listen: false).setLoginTheme;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 200.0,
              height: 50.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: primaryColor),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buildContainer(
                        'Mosaic', Icons.auto_awesome_mosaic, changeTheme),
                    buildContainer('Rainy', Icons.water_drop, changeTheme),
                    buildContainer('None', Icons.remove_circle, changeTheme),
                    const LanguagePicker(false)
                  ]))
        ]);
  }
}
