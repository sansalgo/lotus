import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Utility to map icon names to IconData
class IconMapper {
  IconMapper._();

  static IconData getIconFromName(String iconName) {
    // Map common icon names to Phosphor icons
    switch (iconName.toLowerCase()) {
      case 'man walking':
      case 'personwalking':
      case 'walking':
        return PhosphorIconsDuotone.personSimpleWalk;
      case 'bookopen':
      case 'book':
      case 'reading':
        return PhosphorIconsDuotone.bookOpen;
      case 'monitorplay':
      case 'monitor':
      case 'programming':
        return PhosphorIconsDuotone.monitorPlay;
      case 'heart':
        return PhosphorIconsDuotone.heart;
      case 'star':
        return PhosphorIconsDuotone.star;
      case 'leaf':
        return PhosphorIconsDuotone.leaf;
      case 'fire':
        return PhosphorIconsDuotone.fire;
      case 'barbell':
      case 'gym':
        return PhosphorIconsDuotone.barbell;
      case 'music':
        return PhosphorIconsDuotone.musicNote;
      case 'pencil':
      case 'write':
        return PhosphorIconsDuotone.pencil;
      case 'meditation':
      case 'yoga':
        return PhosphorIconsDuotone.leaf;
      default:
        return PhosphorIconsDuotone.circle;
    }
  }
}

