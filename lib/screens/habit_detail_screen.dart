import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/color_mapper.dart';
import '../widgets/circle_icon_button.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  final VoidCallback onBack;
  final VoidCallback? onEdit;

  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.onBack,
    this.onEdit,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late AppDatabase _database;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  List<String> get _chips {
    final chips = <String>[];

    chips.add(widget.habit.frequency.toUpperCase());

    final parts = widget.habit.repeat.split(' ');
    final count = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    if (count != null) {
      chips.add('$count ${count == 1 ? 'REP' : 'REPS'}');
    } else {
      chips.add(widget.habit.repeat.toUpperCase());
    }

    return chips;
  }

  List<String> get _reminderTimes {
    final times = <String>[];
    if (widget.habit.reminders != null && widget.habit.reminders!.isNotEmpty) {
      times.addAll(
        widget.habit.reminders!
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty),
      );
    } else if (widget.habit.reminderTime != null &&
        widget.habit.reminderTime!.isNotEmpty) {
      times.add(widget.habit.reminderTime!);
    }
    return times;
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Habit',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text('Delete "${widget.habit.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await (_database.delete(_database.habits)
            ..where((t) => t.id.equals(widget.habit.id)))
          .go();
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChips(),
                      const SizedBox(height: 20),
                      _buildStatCards(),
                      const SizedBox(height: 20),
                      _buildCalendar(),
                      const SizedBox(height: 24),
                      _buildStatistics(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleIconButton(
                icon: PhosphorIconsBold.arrowLeft,
                onTap: widget.onBack,
              ),
              const Spacer(),
              CircleIconButton(
                icon: PhosphorIconsBold.pencilSimple,
                onTap: widget.onEdit,
              ),
              const SizedBox(width: 8),
              _MoreMenuButton(onDelete: _deleteHabit),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.habit.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          ..._chips.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(label: c),
            ),
          ),
          if (_reminderTimes.isNotEmpty) _ReminderChip(times: _reminderTimes),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final habitColor = ColorMapper.getColorFromName(widget.habit.colorName);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: PhosphorIconsBold.flame,
                iconColor: habitColor,
                value: '0',
                label: 'Streak',
                sub: 'Best: 0',
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: _buildStatItem(
                icon: PhosphorIconsBold.checkCircle,
                iconColor: habitColor,
                value: '0',
                label: 'Finished',
                sub: 'This week: 0',
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: _buildStatItem(
                icon: PhosphorIconsBold.chartBar,
                iconColor: habitColor,
                value: '0%',
                label: 'Completion',
                sub: '0/0 done',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String sub,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PhosphorIcon(icon, size: 18, color: iconColor),
          // const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    return Container(
      decoration: BoxDecoration(
        // color: AppColors.lightGray,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '${_monthName(now.month)} ${now.year}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                .map(
                  (d) => SizedBox(
                    width: 32,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black45,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          ..._buildCalendarRows(now),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarRows(DateTime now) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday;
    // Dart weekday: Mon=1..Sat=6, Sun=7. Convert to Sun=0..Sat=6.
    final startOffset = firstWeekday == 7 ? 0 : firstWeekday;

    final rows = <Widget>[];
    int rowStart = 1 - startOffset;

    while (rowStart <= daysInMonth) {
      final cells = List.generate(7, (i) {
        final d = rowStart + i;
        if (d < 1 || d > daysInMonth) {
          return const SizedBox(width: 32, height: 32);
        }
        return _CalendarCell(day: d, isToday: d == now.day);
      });
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: cells,
          ),
        ),
      );
      rowStart += 7;
    }
    return rows;
  }

  Widget _buildStatistics() {
    final now = DateTime.now();
    final daysFromSunday = now.weekday == 7 ? 0 : now.weekday;
    final weekStart = now.subtract(Duration(days: daysFromSunday));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${_monthName(now.month)} ${now.year}',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_shortMonthName(weekStart.month)} ${weekStart.day}'
                        ' - ${_shortMonthName(weekEnd.month)} ${weekEnd.day}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${now.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '0.0 reps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Avg. repeats',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBarChart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const maxBarHeight = 56.0;
    // Placeholder values — no completion tracking yet
    const values = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    final habitColor = ColorMapper.getColorFromName(widget.habit.colorName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final barHeight = values[i] * maxBarHeight;
        final isEmpty = barHeight < 1;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 26,
              height: isEmpty ? 4 : barHeight,
              decoration: BoxDecoration(
                color: isEmpty ? Colors.black12 : habitColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              days[i],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
          ],
        );
      }),
    );
  }

  static String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }

  static String _shortMonthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _MoreMenuButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _MoreMenuButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 8,
      onSelected: (value) {
        if (value == 'delete') onDelete();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'archive',
          child: Text(
            'Pause & Archive',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).extension<AppColorScheme>()!.border,
          ),
        ),
        child: PhosphorIcon(PhosphorIconsBold.dotsThreeVertical, size: 18),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}


class _ReminderChip extends StatefulWidget {
  final List<String> times;

  const _ReminderChip({required this.times});

  @override
  State<_ReminderChip> createState() => _ReminderChipState();
}

class _ReminderChipState extends State<_ReminderChip> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasMore = widget.times.length > 2;
    final label = _expanded || !hasMore
        ? widget.times.join(', ')
        : '${widget.times.take(2).join(', ')} ...';

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'REM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            width: 1,
            height: 12,
            color: Colors.white.withValues(alpha: 0.35),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (!hasMore) return chip;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: chip,
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final int day;
  final bool isToday;

  const _CalendarCell({required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: isToday
          ?  BoxDecoration(
              color: AppColors.primary,
              // shape: BoxShape.circle,
              borderRadius: BorderRadius.circular(10)
            )
          : null,
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 15,
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          color: isToday ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
