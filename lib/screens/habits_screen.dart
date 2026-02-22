import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/date_card.dart';
import '../widgets/habit_card.dart';
import '../widgets/circle_icon_button.dart';
import '../widgets/bottom_actions_bar.dart';
import '../database/app_database.dart';
import '../utils/icon_mapper.dart';
import '../utils/color_mapper.dart';

class HabitsScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCreate;

  const HabitsScreen({super.key, this.onNavigateToCreate});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
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
                  // Header row
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
                        onTap: widget.onNavigateToCreate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Date card
                  const DateCard(),
                  const SizedBox(height: 16),
                  // Habit cards from database
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: habits.length,
                          padding: const EdgeInsets.only(bottom: 100),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            return HabitCard(
                              icon: IconMapper.getIconFromName(habit.iconName),
                              title: habit.name,
                              subtitle: habit.goal ?? 'No goal set',
                              bgColor: ColorMapper.getColorFromName(
                                habit.colorName,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Add bottom padding to prevent content from being hidden behind the bar
                ],
              ),
            ),
            // Absolutely positioned bottom actions bar
            const BottomActionsBar(),
          ],
        ),
      ),
    );
  }
}
