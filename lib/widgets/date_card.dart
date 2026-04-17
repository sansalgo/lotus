import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class DateCard extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateCard({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DateCard> createState() => _DateCardState();
}

class _DateCardState extends State<DateCard> {
  // Fixed epoch — all indices are days since this date.
  static final DateTime _epoch = DateTime(2020, 1, 1);
  // 16-year range: 2020-01-01 → 2035-12-31
  static const int _totalDays = 365 * 16 + 4;

  late FixedExtentScrollController _ctrl;

  /// Date reflected in the header — updates live as the user scrolls.
  late DateTime _displayed;

  // ── Index helpers ─────────────────────────────────────────────────────────

  int _indexOf(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.difference(_epoch).inDays.clamp(0, _totalDays - 1);
  }

  DateTime _dateAt(int index) => _epoch.add(Duration(days: index));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _displayed = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    _ctrl = FixedExtentScrollController(initialItem: _indexOf(_displayed));
  }

  @override
  void didUpdateWidget(DateCard old) {
    super.didUpdateWidget(old);
    final incoming = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    if (!_isSameDay(old.selectedDate, incoming) &&
        !_isSameDay(_displayed, incoming)) {
      setState(() => _displayed = incoming);
      if (_ctrl.hasClients) {
        _ctrl.animateToItem(
          _indexOf(incoming),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Name tables ───────────────────────────────────────────────────────────

  static const _dayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _dayAbbrs = [
    'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
  ];

  int _weekdayIndex(DateTime d) => d.weekday == 7 ? 6 : d.weekday - 1;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dayNames[_weekdayIndex(_displayed)],
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
                    _monthNames[_displayed.month - 1],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_displayed.year}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // ── Date strip ────────────────────────────────────────────────────
          // LayoutBuilder so itemExtent = availableWidth/7, giving exactly
          // 3 dates left | selected center | 3 dates right.
          LayoutBuilder(
            builder: (context, constraints) {
              final slotWidth = constraints.maxWidth / 7;
              return SizedBox(
                height: 54,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: ListWheelScrollView.useDelegate(
                    controller: _ctrl,
                    itemExtent: slotWidth,
                    perspective: 0.0001,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (i) {
                      HapticFeedback.selectionClick();
                      final date = _dateAt(i);
                      setState(() => _displayed = date);
                      widget.onDateChanged(date);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: _totalDays,
                      builder: (_, i) {
                        final date = _dateAt(i);
                        final isSelected = _isSameDay(date, _displayed);
                        return RotatedBox(
                          quarterTurns: 1,
                          child: GestureDetector(
                            // Tapping any date scrolls it to the center.
                            onTap: () => _ctrl.animateToItem(
                              i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                            child: Center(
                              child: _DayItem(
                                label: '${date.day}',
                                sublabel: _dayAbbrs[_weekdayIndex(date)],
                                isSelected: isSelected,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Day item — exact original style ──────────────────────────────────────────

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: baseTextStyle.copyWith(color: Colors.white)),
            const SizedBox(height: 2),
            Text(sublabel, style: subTextStyle),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: baseTextStyle),
        Text(sublabel, style: subTextStyle),
      ],
    );
  }
}
