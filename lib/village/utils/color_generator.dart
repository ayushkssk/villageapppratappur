import 'package:flutter/material.dart';

class ColorGenerator {
  static final Map<String, Color> _userColors = {};
  static final List<Color> _colorPalette = [
    const Color(0xFF33691E),  // Forest Green
    const Color(0xFF1B5E20),  // Dark Green
    const Color(0xFF2E7D32),  // Medium Green
    const Color(0xFF795548),  // Brown
    const Color(0xFF5D4037),  // Dark Brown
    const Color(0xFF4E342E),  // Darker Brown
    const Color(0xFF3E2723),  // Very Dark Brown
    const Color(0xFF4CAF50),  // Light Green
    const Color(0xFF388E3C),  // Medium Light Green
    const Color(0xFF8D6E63),  // Light Brown
  ];

  static Color getColorForUser(String userId) {
    if (_userColors.containsKey(userId)) {
      return _userColors[userId]!;
    }

    // Generate a consistent index based on userId
    final colorIndex = userId.hashCode.abs() % _colorPalette.length;
    final color = _colorPalette[colorIndex];
    
    _userColors[userId] = color;
    return color;
  }

  static void clearCache() {
    _userColors.clear();
  }
}
