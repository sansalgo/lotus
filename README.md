# Lotus - Habit Tracker

A Flutter habit tracking application with a clean, modern UI.

## Project Structure

```
lib/
├── database/          # Drift database setup
├── models/            # Data models
├── routes/            # Navigation and routing
├── screens/           # Screen widgets
├── theme/             # Theme configuration and colors
└── widgets/           # Reusable widgets
```

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Generate database files (required for Drift):
```bash
flutter pub run build_runner build
```

3. Run the app:
```bash
flutter run
```

## Features

- **Theme System**: Centralized color constants accessible via theme extensions
  - Border color: `#E5E5E5`
  - Primary color: `#000000`
  - Secondary color: `#737373`

- **Animated Navigation**: Smooth page transitions using `AnimatedSwitcher`

- **Database**: SQLite persistence using Drift

- **Clean Architecture**: Separated concerns with proper folder structure

## Color Constants

Colors are defined in `lib/theme/app_colors.dart` and accessible throughout the app via:

```dart
final appColors = context.appColors;
appColors.border
appColors.primary
appColors.secondary
```
