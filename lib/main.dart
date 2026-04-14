import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/habits_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.init();
  } catch (_) {
    // Notifications unavailable — app still works without them
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HabitsScreen(),
    );
  }
}
