# Lotus — Habit Tracker

A minimalist habit tracker built with Flutter. Track daily, weekly, monthly, or custom-frequency habits with streak tracking, completion heatmaps, and local reminders.

## Features

- **Date-aware tracking** — navigate by date, mark habits complete for any day
- **Flexible frequency** — every N days / weeks / months / years, or specific weekdays
- **Multi-rep habits** — track habits that repeat multiple times per period
- **Statistics** — current streak, best streak, completion rate, total completions
- **Visual history** — monthly calendar heatmap and weekly bar chart per habit
- **Local reminders** — schedule multiple daily notification times per habit
- **Icon & color picker** — 700+ Phosphor icons with fuzzy search, 12 accent colors
- **Animated navigation** — smooth slide transitions, no external state management

## Tech Stack

| | |
|---|---|
| **UI** | Flutter, Material 3, Geist font |
| **Database** | Drift (SQLite ORM), schema v4 |
| **Icons** | Phosphor Flutter |
| **Notifications** | flutter_local_notifications + timezone |
| **Search** | fuzzy (icon picker) |

## Setup

```bash
# Install dependencies
flutter pub get

# Generate Drift database files (required)
flutter pub run build_runner build

# Run the app
flutter run
```

> After any changes to `lib/database/app_database.dart`, re-run `build_runner build`. Never edit `.g.dart` files manually.

## Project Structure

```
lib/
├── constants/       # Icon metadata
├── database/        # Drift schema & DAOs
├── models/          # HabitModel (plain Dart, copyWith)
├── routes/          # AnimatedRouter (AnimatedSwitcher + SlideTransition)
├── screens/         # HabitsScreen, HabitFormScreen, HabitDetailScreen
├── theme/           # AppTheme, AppColorScheme (ThemeExtension), app_colors.dart
├── utils/           # color_mapper.dart, icon_mapper.dart
└── widgets/         # Shared UI components
```
