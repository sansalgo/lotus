import 'package:flutter/material.dart' show Color;
import '../theme/app_colors.dart';

class ColorMapper {
  ColorMapper._();

  static const Map<String, Color> habitColors = {
    'Blush': Color(0xFFF5A8BC),
    'Salmon': Color(0xFFF5B8A0),
    'Amber': Color(0xFFF5D8A0),
    'Lemon': Color(0xFFF5F0A0),
    'Lime': Color(0xFFC8F0A0),
    'Mint': Color(0xFFA0F0C8),
    'Seafoam': Color(0xFFA0F0E8),
    'Sky': Color(0xFFA0D8F5),
    'Cornflower': Color(0xFFA0B8F5),
    'Lavender': Color(0xFFC0A0F5),
    'Orchid': Color(0xFFE0A0F5),
    'Rose': Color(0xFFF5A0DC),
  };

  static Color getColorFromName(String colorName) {
    return habitColors[colorName] ?? AppColors.border;
  }
}
