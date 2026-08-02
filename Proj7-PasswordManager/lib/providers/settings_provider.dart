import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  int _autoLockSeconds = 60; // 60s default
  int _clipboardClearSeconds = 30; // 30s default
  bool _preventScreenshots = true;

  ThemeMode get themeMode => _themeMode;
  int get autoLockSeconds => _autoLockSeconds;
  int get clipboardClearSeconds => _clipboardClearSeconds;
  bool get preventScreenshots => _preventScreenshots;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setAutoLockSeconds(int seconds) {
    _autoLockSeconds = seconds;
    notifyListeners();
  }

  void setClipboardClearSeconds(int seconds) {
    _clipboardClearSeconds = seconds;
    notifyListeners();
  }

  void togglePreventScreenshots(bool value) {
    _preventScreenshots = value;
    notifyListeners();
  }
}
