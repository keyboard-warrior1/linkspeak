import 'package:flutter/foundation.dart';

class LogHelper with ChangeNotifier {
  bool _isLoading = false;
  bool _obscureText = true;
  bool get isLoading => _isLoading;
  bool get obscureText => _obscureText;

  void obscurePass() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  void loading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _obscureText = true;
    notifyListeners();
  }
}
