import 'package:flutter/material.dart';

class LanguageController extends ChangeNotifier {
  static final LanguageController _instance = LanguageController._internal();
  factory LanguageController() => _instance;
  LanguageController._internal();

  bool _isBengali = false; // ডিফল্ট ইংরেজি

  bool get isBengali => _isBengali;

  void toggleLanguage() {
    _isBengali = !_isBengali;
    notifyListeners();
  }

  String t(String en, String bn) {
    return _isBengali ? bn : en;
  }
}

// গ্লোবাল ইন্সট্যান্স
final lang = LanguageController();
