import 'package:flutter/material.dart';

class DuneColors {
  // Primary Arrakis Palette
  static const Color spiceOrange = Color(0xFFFF6F00); // Deep glowing spice
  static const Color spiceAmber = Color(0xFFD84315);  // Burnt desert amber
  static const Color duneGold = Color(0xFFFFD54F);    // Sun-baked gold
  static const Color sandBase = Color(0xFF2C2219);    // Desert ground
  
  // Backgrounds & Glassmorphism
  static const Color darkBackground = Color(0xFF0F0C0A); // Obsidian desert night
  static const Color cardBackground = Color(0xFF1E1712); // Translucent sand card
  static const Color glassBorder = Color(0xFF3E2D20);    // Subtle spice edge
  
  // Fremen Accent Colors
  static const Color fremenBlue = Color(0xFF00E5FF); // Eyes of Ibad glowing blue
  static const Color waterCyan = Color(0xFF00B0FF);  // Caladan rain & moisture blue
  
  // Weather Severity / Threat Indicators
  static const Color stormRed = Color(0xFFFF1744);    // Coriolis Storm / Worm Sign
  static const Color warningYellow = Color(0xFFFFC400); // High Heat / Spice Surge
  static const Color calmGreen = Color(0xFF00E676);   // Safe passage / Cool Night

  // Gradients
  static const LinearGradient spiceGradient = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFD84315)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient waterGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF0077C2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient desertBackgroundGradient = LinearGradient(
    colors: [Color(0xFF120E0B), Color(0xFF070504)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
