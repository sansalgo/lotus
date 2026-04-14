import 'package:flutter/material.dart';
import 'package:lotus/theme/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BottomActionsBar extends StatelessWidget {
  const BottomActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(PhosphorIconsBold.leaf, size: 22),
              const SizedBox(width: 26),
              PhosphorIcon(PhosphorIconsBold.plusCircle, size: 24),
              const SizedBox(width: 26),
              PhosphorIcon(PhosphorIconsBold.star, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
