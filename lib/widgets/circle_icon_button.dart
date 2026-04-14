import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: PhosphorIcon(icon, size: size),
      ),
    );
  }
}
