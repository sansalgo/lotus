import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../database/app_database.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../utils/color_mapper.dart';
import '../widgets/circle_icon_button.dart';
import '../routes/slide_page_route.dart';
import 'habit_form_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({
    super.key,
    required this.habit,
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

  // ── Data helpers ──────────────────────────────────────────────────────────

  Stream<List<HabitCompletion>> get _completionStream =>
      (_database.select(_database.habitCompletions)
            ..where((c) => c.habitId.equals(widget.habit.id)))
          .watch();

  List<String> get _chips {
    final count = widget.habit.repeatCount;
    return [
      widget.habit.frequency.toUpperCase(),
      '$count ${count == 1 ? 'REP' : 'REPS'}',
    ];
  }

  List<String> get _reminderTimes {
    if (widget.habit.reminders != null &&
        widget.habit.reminders!.isNotEmpty) {
      return widget.habit.reminders!
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
    }
    if (widget.habit.reminderTime != null &&
        widget.habit.reminderTime!.isNotEmpty) {
      return [widget.habit.reminderTime!];
    }
    return [];
  }

  bool _periodCompleted(HabitCompletion c) =>
      c.completedReps >= widget.habit.repeatCount;

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // ── Stat computations ─────────────────────────────────────────────────────

  int _streak(List<HabitCompletion> all) {
    final doneDays = all
        .where(_periodCompleted)
        .map((c) => _dayOnly(c.periodDate))
        .toSet();
    final today = _dayOnly(DateTime.now());
    int streak = 0;
    DateTime check = today;
    while (doneDays.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _bestStreak(List<HabitCompletion> all) {
    final dates = all
        .where(_periodCompleted)
        .map((c) => _dayOnly(c.periodDate))
        .toList()
      ..sort();
    if (dates.isEmpty) return 0;
    int best = 1, current = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else if (dates[i] != dates[i - 1]) {
        current = 1;
      }
    }
    return best;
  }

  int _finished(List<HabitCompletion> all) =>
      all.where(_periodCompleted).length;

  int _finishedThisWeek(List<HabitCompletion> all) {
    final now = DateTime.now();
    final weekStart = _dayOnly(now).subtract(Duration(days: now.weekday - 1));
    return all.where((c) {
      final d = _dayOnly(c.periodDate);
      return _periodCompleted(c) && !d.isBefore(weekStart);
    }).length;
  }

  /// Total periods from creation date to today (inclusive).
  int _totalPeriods() {
    final created = _dayOnly(widget.habit.createdAt);
    final today = _dayOnly(DateTime.now());
    return math.max(1, today.difference(created).inDays + 1);
  }

  String _completionRate(List<HabitCompletion> all) {
    final rate = (_finished(all) / _totalPeriods() * 100).round();
    return '$rate%';
  }

  /// completedReps for each of the 7 days of the current week (Mon index 0).
  List<double> _weekBarValues(List<HabitCompletion> all) {
    final now = DateTime.now();
    final weekStart = _dayOnly(now).subtract(Duration(days: now.weekday - 1));
    final total = widget.habit.repeatCount;
    return List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      final comp = all.where((c) => _dayOnly(c.periodDate) == day).firstOrNull;
      if (comp == null || total == 0) return 0.0;
      return (comp.completedReps / total).clamp(0.0, 1.0);
    });
  }

  double _avgReps(List<HabitCompletion> all) {
    if (all.isEmpty) return 0;
    final total = all.fold<int>(0, (s, c) => s + c.completedReps);
    return total / all.length;
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Habit',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Delete "${widget.habit.name}"? This cannot be undone.',
        ),
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
      await NotificationService.cancelHabitReminders(widget.habit.id);
      await (_database.delete(_database.habits)
            ..where((t) => t.id.equals(widget.habit.id)))
          .go();
      if (mounted) Navigator.pop(context);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
              child: StreamBuilder<List<HabitCompletion>>(
                stream: _completionStream,
                initialData: const [],
                builder: (context, snapshot) {
                  final completions = snapshot.data ?? [];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChips(),
                          const SizedBox(height: 20),
                          _buildStatCards(completions),
                          const SizedBox(height: 20),
                          _buildCalendar(completions),
                          const SizedBox(height: 24),
                          _buildStatistics(completions),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

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
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              CircleIconButton(
                icon: PhosphorIconsBold.pencilSimple,
                onTap: () => Navigator.push(
                  context,
                  SlidePageRoute(
                    page: HabitFormScreen(initialHabit: widget.habit),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleIconButton(
                icon: PhosphorIconsBold.trash,
                onTap: _deleteHabit,
              ),
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

  // ── Chips ─────────────────────────────────────────────────────────────────

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

  // ── Stat cards ────────────────────────────────────────────────────────────

  Widget _buildStatCards(List<HabitCompletion> completions) {
    final habitColor = ColorMapper.getColorFromName(widget.habit.colorName);
    final streak = _streak(completions);
    final best = _bestStreak(completions);
    final finished = _finished(completions);
    final thisWeek = _finishedThisWeek(completions);
    final total = _totalPeriods();

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
                value: '$streak',
                label: 'Streak',
                sub: 'Best: $best',
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: _buildStatItem(
                icon: PhosphorIconsBold.checkCircle,
                iconColor: habitColor,
                value: '$finished',
                label: 'Finished',
                sub: 'This week: $thisWeek',
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: _buildStatItem(
                icon: PhosphorIconsBold.chartBar,
                iconColor: habitColor,
                value: _completionRate(completions),
                label: 'Completion',
                sub: '$finished/$total done',
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  // ── Calendar ──────────────────────────────────────────────────────────────

  Widget _buildCalendar(List<HabitCompletion> completions) {
    final now = DateTime.now();
    final habitColor = ColorMapper.getColorFromName(widget.habit.colorName);

    // Set of days in current month that are fully completed
    final doneDays = completions
        .where(_periodCompleted)
        .map((c) => c.periodDate.day)
        .toSet();

    return Container(
      decoration: BoxDecoration(
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
          ..._buildCalendarRows(now, doneDays, habitColor),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarRows(
    DateTime now,
    Set<int> doneDays,
    Color habitColor,
  ) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday;
    // Mon=1..Sun=7 → Sun=0..Sat=6 offset
    final startOffset = firstWeekday == 7 ? 0 : firstWeekday;

    final rows = <Widget>[];
    int rowStart = 1 - startOffset;

    while (rowStart <= daysInMonth) {
      final cells = List.generate(7, (i) {
        final d = rowStart + i;
        if (d < 1 || d > daysInMonth) {
          return const SizedBox(width: 32, height: 32);
        }
        return _CalendarCell(
          day: d,
          isToday: d == now.day,
          isDone: doneDays.contains(d),
          habitColor: habitColor,
        );
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

  // ── Statistics ────────────────────────────────────────────────────────────

  Widget _buildStatistics(List<HabitCompletion> completions) {
    final now = DateTime.now();
    // Week runs Mon–Sun
    final weekStart = _dayOnly(now).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final avg = _avgReps(completions);

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
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${avg.toStringAsFixed(1)} reps',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'Avg. repeats',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBarChart(completions),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<HabitCompletion> completions) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const maxBarHeight = 56.0;
    final barValues = _weekBarValues(completions);
    final habitColor = ColorMapper.getColorFromName(widget.habit.colorName);
    final now = DateTime.now();
    // current day index in Mon-based week (0=Mon … 6=Sun)
    final todayIndex = now.weekday - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final barHeight = barValues[i] * maxBarHeight;
        final isEmpty = barHeight < 1;
        final isToday = i == todayIndex;
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday ? Colors.black87 : Colors.black45,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

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

// ── Private widgets ───────────────────────────────────────────────────────────

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
  final bool isDone;
  final Color habitColor;

  const _CalendarCell({
    required this.day,
    required this.isToday,
    required this.isDone,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    Color? bg;
    Color textColor = Colors.black87;

    if (isToday) {
      bg = AppColors.primary;
      textColor = Colors.white;
    } else if (isDone) {
      bg = habitColor.withValues(alpha: 0.25);
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: bg != null
          ? BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10))
          : null,
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 15,
          fontWeight:
              (isToday || isDone) ? FontWeight.w700 : FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
