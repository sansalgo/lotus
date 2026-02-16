import 'package:flutter/material.dart';
import '../screens/habits_screen.dart';
import '../screens/create_habit_screen.dart';

class AnimatedRouter extends StatefulWidget {
  const AnimatedRouter({super.key});

  @override
  State<AnimatedRouter> createState() => _AnimatedRouterState();
}

class _AnimatedRouterState extends State<AnimatedRouter> {
  String _currentRoute = '/';

  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  void _navigateBack() {
    setState(() {
      _currentRoute = '/';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _RouterDelegate(
      currentRoute: _currentRoute,
      onNavigateTo: _navigateTo,
      onNavigateBack: _navigateBack,
    );
  }
}

class _RouterDelegate extends StatelessWidget {
  final String currentRoute;
  final void Function(String) onNavigateTo;
  final void Function() onNavigateBack;

  const _RouterDelegate({
    required this.currentRoute,
    required this.onNavigateTo,
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
      case '/':
      default:
        currentScreen = HabitsScreen(
          onNavigateToCreate: () => onNavigateTo('/create'),
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

