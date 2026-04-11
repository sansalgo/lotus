# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                        # Install dependencies
flutter pub run build_runner build     # Regenerate Drift database files (required after schema changes)
flutter run                            # Run the app
flutter analyze                        # Run linter
flutter test                           # Run tests
```

**Important:** Any changes to `lib/database/app_database.dart` require re-running `build_runner build` to regenerate `app_database.g.dart`. Never manually edit `.g.dart` files.

## Architecture

Lotus is a habit tracker. It uses **StatefulWidget + StreamBuilder** throughout — no external state management library (no Provider, Riverpod, Bloc, etc.).

### Data layer
- **Drift ORM** (`lib/database/app_database.dart`) — SQLite database at `{docsDir}/db.sqlite`, schema version 3. One table: `Habits`. Each screen creates its own `AppDatabase` instance in `initState` and closes it in `dispose`.
- **`HabitModel`** (`lib/models/habit_model.dart`) — plain Dart model with `copyWith`, used to shuttle data between UI and DB.

### Navigation
- **`AnimatedRouter`** (`lib/routes/`) — custom `StatefulWidget` that uses `AnimatedSwitcher` + `SlideTransition` (300 ms) instead of Navigator. Routes: `'/'` → `HabitsScreen`, `'/create'` → `CreateHabitScreen`.

### Theme
- **`AppTheme`** (`lib/theme/app_theme.dart`) — Material 3, Geist font, exposes a custom `AppColorScheme` via `ThemeExtension`. Access via `context.appColors`.
- 12 predefined habit colors defined in `lib/theme/app_colors.dart`; name→`Color` mapping lives in `lib/utils/color_mapper.dart`.

### Icons
- **Phosphor Flutter** icon library (700+ icons in 6 weight styles).
- Icon metadata lives in `lib/constants/all_icons.dart` (auto-generated list of name/`IconData` pairs).
- Name→`IconData` mapping: `lib/utils/icon_mapper.dart`.
- The icon picker in `CreateHabitScreen` uses the **fuzzy** package for search.

### Key packages
| Package | Purpose |
|---|---|
| `drift` | SQLite ORM with code generation |
| `sqlite3_flutter_libs` | Native SQLite binaries |
| `phosphor_flutter` | Icon library |
| `fuzzy` | Fuzzy search for icon picker |
| `path_provider` | Locate documents directory for DB file |
