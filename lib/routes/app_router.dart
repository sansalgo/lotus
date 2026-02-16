import 'package:flutter/material.dart';
import '../screens/habits_screen.dart';
import '../screens/create_habit_screen.dart';

/// Route names
enum AppRoute {
  habits,
  createHabit,
}

/// Router class to manage navigation with AnimatedSwitcher
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;

    switch (routeName) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HabitsScreen());
      case '/create':
        return MaterialPageRoute(builder: (_) => const CreateHabitScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HabitsScreen());
    }
  }

  static void pushNamed(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static void pop() {
    navigatorKey.currentState?.pop();
  }
}

