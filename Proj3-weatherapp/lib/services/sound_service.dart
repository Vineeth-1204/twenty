import 'package:flutter/foundation.dart';

class SoundService {
  static bool _isPlaying = false;
  static String _activeTrack = "Coriolis Desert Wind";

  static bool get isPlaying => _isPlaying;
  static String get activeTrack => _activeTrack;

  static final List<String> soundTracks = [
    "Coriolis Desert Wind",
    "Caladan Monsoon Rain",
    "Spice Sand Drone & Hum",
    "Sietch Evening Ambient",
    "Shai-Hulud Deep Thumper",
  ];

  static void toggleSound() {
    _isPlaying = !_isPlaying;
  }

  static void selectTrack(String track) {
    _activeTrack = track;
    _isPlaying = true;
  }
}
