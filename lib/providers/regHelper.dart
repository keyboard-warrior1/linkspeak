import 'package:flutter/foundation.dart';

enum ShowFields { one, two, three }

class RegHelper with ChangeNotifier {
  bool _isLoading = false;
  ShowFields _showFields = ShowFields.one;
  bool _agreeToTerms = false;
  bool _obscurePass = true;
  bool _obscureRepeat = true;
  bool _isMale = true;
  bool _isFemale = false;
  bool _isOther = false;
  bool get isLoading => _isLoading;
  ShowFields get showFields => _showFields;
  bool get agreeToTerms => _agreeToTerms;
  bool get obscurePass => _obscurePass;
  bool get obscureRepeat => _obscureRepeat;
  bool get isMale => _isMale;
  bool get isFemale => _isFemale;
  bool get isOther => _isOther;
  void maleHandler() {
    _isMale = !_isMale;
    if (isFemale) {
      _isFemale = false;
    }
    if (isOther) {
      _isOther = false;
    }
    notifyListeners();
  }

  void femaleHandler() {
    _isFemale = !_isFemale;
    if (isMale) {
      _isMale = false;
    }
    if (isOther) {
      _isOther = false;
    }
    notifyListeners();
  }

  void otherHandler() {
    _isOther = !_isOther;
    if (isFemale) {
      _isFemale = false;
    }
    if (isMale) {
      _isMale = false;
    }
    notifyListeners();
  }

  void obscurePassword() {
    _obscurePass = !_obscurePass;
    notifyListeners();
  }

  void obscureRepeatPassword() {
    _obscureRepeat = !_obscureRepeat;
    notifyListeners();
  }

  void agreeterms() {
    _agreeToTerms = !_agreeToTerms;
    notifyListeners();
  }

  void showSecond() {
    _showFields = ShowFields.two;
    notifyListeners();
  }

  void showThird() {
    _showFields = ShowFields.three;
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
    _showFields = ShowFields.one;
    _agreeToTerms = false;
    _obscurePass = true;
    _obscureRepeat = true;
    _isMale = true;
    _isFemale = false;
    _isOther = false;
    notifyListeners();
  }
}
