import 'package:flutter/material.dart';

class AppStyles {
// App Bar Colors
  static const Color appBarBackground = Color(0xFF6B5E62);
  static const Color appBarForeground = Color(0xFFFFFFFF);
  static const Color appBarText = Color(0xFFEAFFFD);

// App Background Color
  static const Color appBackground = Color(0xFFEFEFF0);

// Bubble Colors
  static const Color bubbleBackground = Color(0xFFEAFFFD);
  static const Color bubbleIcon = Color(0xFF6B5E62);
  static const Color bubbleText = Color(0xFF6B5E62);
  static const Color bubbleShadow = Color(0xFF6B5E62);

  static const Color colorIcon = Color(0xFF6B5E62);
  static const Color colorInputBackground = Color(0xFFEAFFFD);
  static const Color colorInputText = Color(0xFF6B5E62);

  static const Color colorTileText = Color(0xFFEFEFF0);
  static const Color colorTileSubtitle = Color(0xFFEAFFFD);
  

  static AppBar getAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: appBarBackground,
      foregroundColor: appBarForeground,
      titleTextStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: appBarText),
    );
  }
}
