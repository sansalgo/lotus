import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.size = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: appColors.border),
        ),
        child: PhosphorIcon(icon, size: size),
      ),
    );
  }
}
