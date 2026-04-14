import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

class HabitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? bgColor;
  final int completedReps;
  final int totalReps;
  final bool isCompleted;
  final VoidCallback? onComplete;

  const HabitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.bgColor,
    this.completedReps = 0,
    this.totalReps = 1,
    this.isCompleted = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {

    return Opacity(
      opacity: isCompleted ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: bgColor ?? AppColors.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: bgColor != null ? Colors.black87 : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            // Completion button with circular progress ring
            _CompletionButton(
              completedReps: completedReps,
              totalReps: totalReps,
              isCompleted: isCompleted,
              progressColor: bgColor ?? AppColors.primary,
              onTap: onComplete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Completion button with progress ring ─────────────────────────────────────

class _CompletionButton extends StatelessWidget {
  final int completedReps;
  final int totalReps;
  final bool isCompleted;
  final Color progressColor;
  final VoidCallback? onTap;

  const _CompletionButton({
    required this.completedReps,
    required this.totalReps,
    required this.isCompleted,
    required this.progressColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalReps > 0 ? (completedReps / totalReps).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 38,
        height: 38,
        child: CustomPaint(
          painter: _ProgressRingPainter(
            progress: progress,
            ringColor: progressColor,
          ),
          child: Center(
            child: isCompleted
                ? PhosphorIcon(
                    PhosphorIconsBold.check,
                    size: 16,
                    color: Colors.black87,
                  )
                : const Icon(Icons.add, size: 18, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

// ── Custom painter ────────────────────────────────────────────────────────────

class _ProgressRingPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color ringColor;

  const _ProgressRingPainter({required this.progress, required this.ringColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2.5;
    const strokeWidth = 2.2;

    // Track (background ring)
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFE5E5E5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // start at 12 o'clock
        2 * math.pi * progress,
        false,
        Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.ringColor != ringColor;
}
