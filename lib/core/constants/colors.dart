import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF7FD957);
  
  // Standard Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color blue = Colors.blue;
  static const Color red = Colors.red;
  
  // Grey Variants
  static const Color grey50 = Color(0xFFFAFAFA); // Colors.grey[50]
  static const Color grey100 = Color(0xFFF5F5F5); // Colors.grey[100]
  static const Color grey200 = Color(0xFFEEEEEE); // Colors.grey[200] or Colors.grey.shade200
  static const Color grey300 = Color(0xFFE0E0E0); // Colors.grey[300] or Colors.grey.shade300
  static const Color grey400 = Color(0xFFBDBDBD); // Colors.grey[400] or Colors.grey.shade400
  static const Color grey500 = Color(0xFF9E9E9E); // Colors.grey[500] or Colors.grey.shade500
  static const Color grey600 = Color(0xFF757575); // Colors.grey[600] or Colors.grey.shade600
  static const Color grey700 = Color(0xFF616161); // Colors.grey[700] or Colors.grey.shade700
  static const Color grey800 = Color(0xFF424242); // Colors.grey[800] or Colors.grey.shade800
  static const Color grey900 = Color(0xFF212121); // Colors.grey[900] or Colors.grey.shade900
  
  // Blue Variants
  static const Color blue400 = Color(0xFF42A5F5); // Colors.blue.shade400
  
  // Red Variants
  static const Color red400 = Color(0xFFEF5350); // Colors.red.shade400
  
  // Yellow Variants
  static const Color yellow200 = Color(0xFFFFF59D); // Colors.yellow[200]
  static const Color yellow400 = Color(0xFFFFCA28); // Colors.yellow[400]
  static const Color yellow800 = Color(0xFFF9A825); // Colors.yellow[800]
  
  // Amber Variants
  static const Color amber400 = Color(0xFFFFCA28); // Colors.amber.shade400
  static const Color amber600 = Color(0xFFFFB300); // Colors.amber.shade600
  
  // Special Color Variants
  static const Color white70 = Color(0xB3FFFFFF); // Colors.white70
  static const Color black87 = Color(0xDE000000); // Colors.black87
  
  // Custom Color with Opacity
  static const Color primaryGreen85 = Color(0xD97FD957); // primaryGreen.withOpacity(0.85)
  static const Color primaryGreen30 = Color(0x4D7FD957); // primaryGreen.withOpacity(0.3)
  static const Color primaryGreen15 = Color(0x267FD957); // primaryGreen.withOpacity(0.15)
  static const Color primaryGreen35 = Color(0x597FD957); // primaryGreen.withOpacity(0.35)
  
  // Opacity variants
  static Color blackWithOpacity(double opacity) {
    final alpha = (opacity * 255).toInt();
    return Color(0xFF000000 + (alpha << 24));
  }
  
  static Color whiteWithOpacity(double opacity) {
    final alpha = (opacity * 255).toInt();
    return Color(0xFFFFFFFF + (alpha << 24));
  }
}