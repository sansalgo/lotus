import 'package:flutter/material.dart';

class ColorMapper {
  ColorMapper._();

  static const Map<String, Color> habitColors = {
    'Peach': Color(0xFFF9C7A1),
    'Lavender': Color(0xFFC0A2FB),
    'Pink': Color(0xFFF3969C),
    'Mint': Color(0xFF98E8BA),
    'Sky': Color(0xFF90D2F4),
    'Periwinkle': Color(0xFF98A6FE),
    'Lime': Color(0xFFD6F69D),
    'Sand': Color(0xFFF2D18D),
    'Green': Color(0xFF86EFB6),
    'Blue': Color(0xFF90D5F8),
    'Lilac': Color(0xFFA1A5FA),
    'Orange': Color(0xFFF8B48F),
  };

  static Color getColorFromName(String colorName) {
    if (habitColors.containsKey(colorName)) {
      return habitColors[colorName]!;
    }
    // Fallbacks for older values
    switch (colorName.toLowerCase()) {
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      default:
        return const Color(0xFFE0E0E0); // default light gray fallback
    }
  }
}
