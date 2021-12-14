import 'package:flutter/material.dart';

class AppBarIcon extends StatelessWidget {
  final dynamic icon;
  final dynamic onPressed;
  final String? hint;
  final Color? splashColor;
  final bool? isInAppBar;
  const AppBarIcon({
    required this.icon,
    required this.onPressed,
    required this.hint,
    required this.splashColor,
    this.isInAppBar,
  });
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 50.0,
        maxWidth: 45.0,
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: IconButton(
          splashColor: splashColor,
          tooltip: hint,
          icon: Center(
            child: (isInAppBar != null)
                ? icon
                : Icon(
                    icon,
                    color: Colors.black,
                    size: 30.0,
                  ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
