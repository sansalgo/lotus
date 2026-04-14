import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/date_card.dart';
import '../widgets/habit_card.dart';
import '../widgets/circle_icon_button.dart';
import '../widgets/reps_picker_modal.dart';
import '../database/app_database.dart';
import '../utils/icon_mapper.dart';
import '../utils/color_mapper.dart';
import '../routes/slide_page_route.dart';
import 'habit_detail_screen.dart';
import 'habit_form_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late AppDatabase _database;

  /// All completion rows — filtered per-habit in code using the period date.
  List<HabitCompletion> _allCompletions = [];
  StreamSubscription<List<HabitCompletion>>? _completionSub;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    _completionSub = _database.watchAllCompletions().listen((completions) {
      if (mounted) setState(() => _allCompletions = completions);
    });
  }

  @override
  void dispose() {
    _completionSub?.cancel();
    _database.close();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _completedReps(Habit habit) {
    final period = AppDatabase.getPeriodDate(habit);
    return _allCompletions
            .where(
              (c) =>
                  c.habitId == habit.id && _isSamePeriod(c.periodDate, period),
            )
            .firstOrNull
            ?.completedReps ??
        0;
  }

  bool _isSamePeriod(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isCompleted(Habit habit) =>
      _completedReps(habit) >= habit.repeatCount;

  // ── Completion tap handler ────────────────────────────────────────────────

  Future<void> _handleCompleteTap(Habit habit) async {
    final period = AppDatabase.getPeriodDate(habit);
    final total = habit.repeatCount;
    final completed = _completedReps(habit);
    final alreadyDone = completed >= total;

    if (alreadyDone) {
      // Unclick: clear all completions for this period immediately.
      await _database.updateHabitCompletion(habit.id, period, 0);
      return;
    }

    if (total == 1) {
      // Single-rep: toggle directly.
      await _database.updateHabitCompletion(habit.id, period, 1);
      return;
    }

    // Multi-rep: show wheel picker.
    if (!mounted) return;
    final delta = await showRepsPickerModal(
      context,
      totalReps: total,
      completedReps: completed,
    );
    if (delta == null) return;

    final newCompleted = (completed + delta).clamp(0, total);
    await _database.updateHabitCompletion(habit.id, period, newCompleted);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Header
                  Row(
                    children: [
                      const Text(
                        'Habits',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      CircleIconButton(
                        icon: PhosphorIconsBold.plus,
                        size: 20,
                        onTap: () => Navigator.push(
                          context,
                          SlidePageRoute(page: const HabitFormScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const DateCard(),
                  const SizedBox(height: 16),
                  // Habit list
                  Expanded(
                    child: StreamBuilder<List<Habit>>(
                      stream: _database.select(_database.habits).watch(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final habits = snapshot.data ?? [];

                        if (habits.isEmpty) {
                          return _buildEmptyState();
                        }

                        final active =
                            habits.where((h) => !_isCompleted(h)).toList();
                        final completed =
                            habits.where((h) => _isCompleted(h)).toList();

                        return ListView(
                          padding: const EdgeInsets.only(bottom: 100),
                          children: [
                            // ── Active habits ──────────────────────────
                            ...List.generate(active.length, (i) {
                              final habit = active[i];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: i < active.length - 1 ? 10 : 0,
                                ),
                                child: _buildHabitCard(habit),
                              );
                            }),
                            // ── Completed section ──────────────────────
                            if (completed.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const _SectionHeader(label: 'Completed'),
                              const SizedBox(height: 10),
                              ...List.generate(completed.length, (i) {
                                final habit = completed[i];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i < completed.length - 1 ? 10 : 0,
                                  ),
                                  child: _buildHabitCard(habit),
                                );
                              }),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // const BottomActionsBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final completed = _completedReps(habit);
    final done = _isCompleted(habit);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlidePageRoute(page: HabitDetailScreen(habit: habit)),
      ),
      child: HabitCard(
        icon: IconMapper.getIconFromName(habit.iconName),
        title: habit.name,
        subtitle: habit.goal ?? 'No goal set',
        bgColor: ColorMapper.getColorFromName(habit.colorName),
        completedReps: completed,
        totalReps: habit.repeatCount,
        isCompleted: done,
        onComplete: () => _handleCompleteTap(habit),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIconsDuotone.circle,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create one',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black45,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(thickness: 1, color: Color(0xFFE5E5E5))),
      ],
    );
  }
}
