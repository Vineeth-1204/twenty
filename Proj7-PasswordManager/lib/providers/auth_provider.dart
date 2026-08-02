import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/security_service.dart';
import '../services/storage_service.dart';

enum AuthState {
  loading,
  needsSetup,
  locked,
  authenticated,
  lockout,
}

class AuthProvider extends ChangeNotifier with WidgetsBindingObserver {
  AuthState _state = AuthState.loading;
  Uint8List? _masterKey;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  Timer? _lockoutTimer;
  Timer? _inactivityTimer;

  int _autoLockSeconds = 60; // Default 1 minute

  AuthState get state => _state;
  Uint8List? get masterKey => _masterKey;
  int get failedAttempts => _failedAttempts;
  DateTime? get lockoutUntil => _lockoutUntil;

  int get lockoutRemainingSeconds {
    if (_lockoutUntil == null) return 0;
    final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  AuthProvider() {
    WidgetsBinding.instance.addObserver(this);
    initAuthStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockoutTimer?.cancel();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused || lifecycleState == AppLifecycleState.detached) {
      if (_state == AuthState.authenticated) {
        lockVault();
      }
    }
  }

  void setAutoLockSeconds(int seconds) {
    _autoLockSeconds = seconds;
    _resetInactivityTimer();
  }

  void userActivityDetected() {
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_state == AuthState.authenticated && _autoLockSeconds > 0) {
      _inactivityTimer = Timer(Duration(seconds: _autoLockSeconds), () {
        lockVault();
      });
    }
  }

  Future<void> initAuthStatus() async {
    _state = AuthState.loading;
    notifyListeners();

    final isSetup = await StorageService.isSetupComplete();
    if (!isSetup) {
      _state = AuthState.needsSetup;
    } else {
      _state = AuthState.locked;
    }
    notifyListeners();
  }

  Future<bool> setupProfile(String pin) async {
    final salt = SecurityService.generateSalt();
    await StorageService.saveProfileSetup(pin: pin, salt: salt);
    _masterKey = SecurityService.deriveKey(pin, salt);
    _state = AuthState.authenticated;
    _failedAttempts = 0;
    _resetInactivityTimer();
    notifyListeners();
    return true;
  }

  Future<bool> authenticateWithPin(String pin) async {
    if (_state == AuthState.lockout) {
      if (lockoutRemainingSeconds > 0) {
        return false;
      } else {
        _state = AuthState.locked;
        _lockoutUntil = null;
      }
    }

    final isValid = await StorageService.verifyPin(pin);
    if (isValid) {
      final salt = await StorageService.getSalt();
      if (salt == null) return false;

      _masterKey = SecurityService.deriveKey(pin, salt);
      _failedAttempts = 0;
      _state = AuthState.authenticated;
      _resetInactivityTimer();
      notifyListeners();
      return true;
    } else {
      _failedAttempts++;
      if (_failedAttempts >= 5) {
        _triggerLockout(30); // 30 seconds lockout after 5 failed attempts
      } else {
        notifyListeners();
      }
      return false;
    }
  }

  void _triggerLockout(int seconds) {
    _state = AuthState.lockout;
    _lockoutUntil = DateTime.now().add(Duration(seconds: seconds));
    notifyListeners();

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (lockoutRemainingSeconds <= 0) {
        timer.cancel();
        _state = AuthState.locked;
        _failedAttempts = 0;
        _lockoutUntil = null;
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
  }

  void lockVault() {
    _masterKey = null;
    _inactivityTimer?.cancel();
    if (_state == AuthState.authenticated) {
      _state = AuthState.locked;
      notifyListeners();
    }
  }

  Future<void> changePin(String oldPin, String newPin) async {
    await StorageService.updatePin(oldPin, newPin);
    final salt = await StorageService.getSalt();
    if (salt != null) {
      _masterKey = SecurityService.deriveKey(newPin, salt);
    }
    notifyListeners();
  }

  Future<void> resetApp() async {
    _masterKey = null;
    _inactivityTimer?.cancel();
    await StorageService.wipeAllData();
    _state = AuthState.needsSetup;
    notifyListeners();
  }
}
