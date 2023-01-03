import 'package:flutter/material.dart';

class HistoryScrollProvider extends ChangeNotifier {
  final ScrollController _controller = ScrollController();
  ScrollController get controller => _controller;
  void disposeController() => _controller.dispose();
}
