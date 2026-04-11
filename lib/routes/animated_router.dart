import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../screens/habits_screen.dart';
import '../screens/create_habit_screen.dart';
import '../screens/habit_detail_screen.dart';

class AnimatedRouter extends StatefulWidget {
  const AnimatedRouter({super.key});

  @override
  State<AnimatedRouter> createState() => _AnimatedRouterState();
}

class _AnimatedRouterState extends State<AnimatedRouter> {
  String _currentRoute = '/';
  Habit? _selectedHabit;

  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  void _navigateToHabit(Habit habit) {
    setState(() {
      _currentRoute = '/detail';
      _selectedHabit = habit;
    });
  }

  void _navigateToEdit() {
    setState(() {
      _currentRoute = '/edit';
    });
  }

  void _navigateBackToDetail() {
    setState(() {
      _currentRoute = '/detail';
    });
  }

  void _navigateBack() {
    setState(() {
      _currentRoute = '/';
      _selectedHabit = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _RouterDelegate(
      currentRoute: _currentRoute,
      selectedHabit: _selectedHabit,
      onNavigateTo: _navigateTo,
      onNavigateToHabit: _navigateToHabit,
      onNavigateToEdit: _navigateToEdit,
      onNavigateBackToDetail: _navigateBackToDetail,
      onNavigateBack: _navigateBack,
    );
  }
}

class _RouterDelegate extends StatelessWidget {
  final String currentRoute;
  final Habit? selectedHabit;
  final void Function(String) onNavigateTo;
  final void Function(Habit) onNavigateToHabit;
  final void Function() onNavigateToEdit;
  final void Function() onNavigateBackToDetail;
  final void Function() onNavigateBack;

  const _RouterDelegate({
    required this.currentRoute,
    required this.selectedHabit,
    required this.onNavigateTo,
    required this.onNavigateToHabit,
    required this.onNavigateToEdit,
    required this.onNavigateBackToDetail,
    required this.onNavigateBack,
  });

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    switch (currentRoute) {
      case '/create':
        currentScreen = CreateHabitScreen(
          onBack: onNavigateBack,
        );
        break;
      case '/detail':
        currentScreen = HabitDetailScreen(
          habit: selectedHabit!,
          onBack: onNavigateBack,
          onEdit: onNavigateToEdit,
        );
        break;
      case '/edit':
        currentScreen = CreateHabitScreen(
          initialHabit: selectedHabit,
          onBack: onNavigateBackToDetail,
          onSaved: onNavigateBack,
        );
        break;
      case '/':
      default:
        currentScreen = HabitsScreen(
          onNavigateToCreate: () => onNavigateTo('/create'),
          onNavigateToHabit: onNavigateToHabit,
        );
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      child: Container(
        key: ValueKey<String>(currentRoute),
        child: currentScreen,
      ),
    );
  }
}

