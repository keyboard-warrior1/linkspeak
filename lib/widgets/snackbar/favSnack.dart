import 'package:flutter/material.dart';

class FavSnack extends StatelessWidget {
  final bool fav;
  const FavSnack(this.fav);
  @override
  Widget build(BuildContext context) {
    final _accentColor = Theme.of(context).colorScheme.secondary;
    final Widget _icon = Icon((fav) ? Icons.star : Icons.star_border,
        color: _accentColor, size: 31.0);
    final Widget _snackBar = Container(
        height: 30.0,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _icon,
              _icon,
              _icon,
              _icon,
              _icon,
              _icon,
              _icon
            ]));
    return _snackBar;
  }
}
