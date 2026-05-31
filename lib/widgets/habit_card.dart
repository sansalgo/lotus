import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

class HabitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int completedReps;
  final int totalReps;
  final bool isCompleted;
  final VoidCallback? onComplete;
  final bool canComplete;

  const HabitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.completedReps = 0,
    this.totalReps = 1,
    this.isCompleted = false,
    this.onComplete,
    this.canComplete = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalReps > 0 ? (completedReps / totalReps).clamp(0.0, 1.0) : 0.0;

    return Opacity(
      opacity: isCompleted ? 0.55 : 1.0,
      child: CustomPaint(
        painter: _CardFillPainter(
          progress: progress,
          fillColor: AppColors.secondary,
          borderColor: AppColors.border,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  icon,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.chart2),
                    ),
                  ],
                ),
              ),
              if (canComplete)
                GestureDetector(
                  onTap: onComplete,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Center(
                      child: PhosphorIcon(
                        isCompleted ? PhosphorIconsBold.check : PhosphorIconsBold.plus,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card progress fill painter ────────────────────────────────────────────────

class _CardFillPainter extends CustomPainter {
  final double progress;
  final Color fillColor;
  final Color borderColor;

  const _CardFillPainter({
    required this.progress,
    required this.fillColor,
    required this.borderColor,
  });

  static const _strokeWidth = 1.0;
  static const _inset = _strokeWidth / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _inset, _inset,
      size.width - _inset * 2,
      size.height - _inset * 2,
    );

    canvas.drawRect(rect, Paint()..color = Colors.white..style = PaintingStyle.fill);

    if (progress > 0) {
      canvas.drawRect(
        Rect.fromLTWH(_inset, _inset, rect.width * progress, rect.height),
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawRect(
      rect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_CardFillPainter old) =>
      old.progress != progress ||
      old.fillColor != fillColor ||
      old.borderColor != borderColor;
}
