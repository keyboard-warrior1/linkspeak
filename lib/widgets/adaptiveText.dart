import 'package:flutter/material.dart';

class OptimisedText extends StatelessWidget {
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;
  final BoxFit fit;
  final Widget child;
  const OptimisedText({
    required this.minWidth,
    required this.maxWidth,
    required this.minHeight,
    required this.maxHeight,
    required this.fit,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      child: FittedBox(
        fit: fit,
        child: child,
      ),
    );
  }
}
