import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF007AFF); // Apple Blue
  static const Color background = Colors.black;
  
  // Glassmorphism Colors
  static Color glassBackground = Colors.white.withValues(alpha: 0.1);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
  
  // Adaptive Background Colors (Default)
  static const List<Color> defaultGradient = [
    Color(0xFF1C1C1E),
    Color(0xFF000000),
  ];
}
