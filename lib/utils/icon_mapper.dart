import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/all_icons.dart';

/// Utility to map icon names to IconData
class IconMapper {
  IconMapper._();

  static IconData getIconFromName(String iconName) {
    final fromAllIcons =
        AllIcons.regularIcons[iconName] ?? AllIcons.allFlatIconsAsMap[iconName];
    if (fromAllIcons != null) {
      return fromAllIcons;
    }

    return PhosphorIconsDuotone.circle;
  }
}
