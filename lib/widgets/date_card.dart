import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

class DateCard extends StatelessWidget {
  const DateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dayAbbreviations = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    // Get current day name (abbreviated)
    final currentDayName = dayNames[now.weekday == 7 ? 6 : now.weekday - 1];
    final currentMonthName = monthNames[now.month - 1];
    final currentYear = now.year.toString();

    // Calculate the start of the week (Sunday)
    final daysFromSunday = now.weekday == 7 ? 0 : now.weekday;
    final startOfWeek = now.subtract(Duration(days: daysFromSunday));

    // Generate 7 days for the week
    final weekDays = List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      final dayOfMonth = date.day.toString();
      final weekdayIndex = date.weekday == 7 ? 6 : date.weekday - 1;
      final dayAbbr = dayAbbreviations[weekdayIndex];
      final isSelected =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      return _DayItem(
        label: dayOfMonth,
        sublabel: dayAbbr,
        isSelected: isSelected,
      );
    });

    final appColors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentDayName,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -2,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentMonthName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    currentYear,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Dates row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays,
          ),
        ],
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;

  const _DayItem({
    required this.label,
    required this.sublabel,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    final subTextStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.8,
      color: isSelected ? Colors.white70 : Colors.black54,
    );

    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: baseTextStyle.copyWith(color: Colors.white)),
            const SizedBox(height: 2),
            Text(sublabel, style: subTextStyle),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(label, style: baseTextStyle),
        Text(sublabel, style: subTextStyle),
      ],
    );
  }
}

