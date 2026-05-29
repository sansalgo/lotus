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
  final bool canComplete;

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
    this.canComplete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isCompleted ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: bgColor ?? AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                icon,
                size: 16,
                color: AppColors.primary,
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
                      fontSize: 14,
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
            if (canComplete)
              _CompletionButton(
                completedReps: completedReps,
                totalReps: totalReps,
                isCompleted: isCompleted,
                fillColor: bgColor ?? AppColors.primary,
                onTap: onComplete,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Completion button ─────────────────────────────────────────────────────────

const _kButtonSize = 36.0;
const _kIconSize   = 16.0;

class _CompletionButton extends StatelessWidget {
  final int completedReps;
  final int totalReps;
  final bool isCompleted;
  final Color fillColor;
  final VoidCallback? onTap;

  const _CompletionButton({
    required this.completedReps,
    required this.totalReps,
    required this.isCompleted,
    required this.fillColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalReps > 0 ? (completedReps / totalReps).clamp(0.0, 1.0) : 0.0;

    // How much of the centered icon (from its left edge) is inside the fill region.
    // Fill expands from the button left; icon is centered horizontally.
    const iconLeft = (_kButtonSize - _kIconSize) / 2; // 10 px from button left
    final fillEndX = _kButtonSize * progress;          // x where fill ends
    final iconFillFraction =
        ((fillEndX - iconLeft) / _kIconSize).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _kButtonSize,
        height: _kButtonSize,
        child: CustomPaint(
          painter: _FillPainter(
            progress: progress,
            isCompleted: isCompleted,
            fillColor: AppColors.primary,
          ),
          child: Center(
            child: isCompleted
                ? const PhosphorIcon(
                    PhosphorIconsBold.check,
                    size: 15,
                    color: Colors.white,
                  )
                : _SplitColorIcon(fillFraction: iconFillFraction),
          ),
        ),
      ),
    );
  }
}

// ── Split-color plus icon ─────────────────────────────────────────────────────

class _SplitColorIcon extends StatelessWidget {
  /// Fraction of the icon (from bottom) that sits inside the fill region.
  /// 0.0 → all dark.  1.0 → all white.
  final double fillFraction;

  const _SplitColorIcon({required this.fillFraction});

  static const _dark  = Color(0xFF171717);
  static const _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    if (fillFraction <= 0.0) {
      return const PhosphorIcon(PhosphorIconsBold.plus, size: _kIconSize, color: _dark);
    }
    if (fillFraction >= 1.0) {
      return const PhosphorIcon(PhosphorIconsBold.plus, size: _kIconSize, color: _white);
    }

    // Sharp vertical split: left of fill line → white, right → dark.
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [_white, _white, _dark, _dark],
        stops: [0.0, fillFraction, fillFraction, 1.0],
      ).createShader(bounds),
      child: const PhosphorIcon(
        PhosphorIconsBold.plus,
        size: _kIconSize,
        color: _white, // base color; overridden by the shader above
      ),
    );
  }
}

// ── Background fill painter ───────────────────────────────────────────────────

class _FillPainter extends CustomPainter {
  final double progress;  // 0.0 → 1.0
  final bool isCompleted;
  final Color fillColor;

  const _FillPainter({
    required this.progress,
    required this.isCompleted,
    required this.fillColor,
  });

  static const _strokeWidth = 1.0;
  static const _inset       = _strokeWidth / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _inset, _inset,
      size.width - _inset * 2,
      size.height - _inset * 2,
    );

    // 1. White base
    canvas.drawRect(rect, Paint()..color = Colors.white..style = PaintingStyle.fill);

    // 2. Fill expanding left to right
    if (progress > 0) {
      canvas.drawRect(
        Rect.fromLTWH(_inset, _inset, rect.width * progress, rect.height),
        Paint()
          ..color = isCompleted ? const Color(0xFF171717) : fillColor
          ..style = PaintingStyle.fill,
      );
    }

    // 3. Border on top
    canvas.drawRect(
      rect,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_FillPainter old) =>
      old.progress != progress ||
      old.isCompleted != isCompleted ||
      old.fillColor != fillColor;
}
