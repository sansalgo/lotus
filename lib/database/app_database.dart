import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Habit table definition
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get goal => text().nullable()();
  TextColumn get iconName => text().withDefault(const Constant('bookOpen'))();
  TextColumn get colorName => text().withDefault(const Constant('Pink'))();
  TextColumn get frequency => text().withDefault(const Constant('Every Day'))();
  TextColumn get repeat =>
      text().withDefault(const Constant('1 Times Per Day'))();
  TextColumn get reminderTime => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Custom frequency columns
  IntColumn get frequencyInterval => integer().withDefault(const Constant(1))();
  TextColumn get frequencyUnit => text().withDefault(const Constant('days'))();
  TextColumn get frequencyDays =>
      text().nullable()(); // Comma-separated list for weeks
  TextColumn get reminders =>
      text().nullable()(); // Stores comma-separated list of times

  // Repeat count as integer (source of truth for completion tracking)
  IntColumn get repeatCount => integer().withDefault(const Constant(1))();
}

/// Tracks per-habit completion counts per period (day/week/month)
class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer()();
  DateTimeColumn get periodDate => dateTime()();
  IntColumn get completedReps => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Habits, HabitCompletions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(habits, habits.frequencyInterval);
        await m.addColumn(habits, habits.frequencyUnit);
        await m.addColumn(habits, habits.frequencyDays);
      }
      if (from < 3) {
        await m.addColumn(habits, habits.reminders);
      }
      if (from < 4) {
        await m.addColumn(habits, habits.repeatCount);
        // Migrate existing repeat strings like "3 Times Per Day" → 3
        await customStatement(
          'UPDATE habits SET repeat_count = CAST(repeat AS INTEGER) '
          'WHERE CAST(repeat AS INTEGER) >= 1',
        );
        await m.createTable(habitCompletions);
      }
    },
  );

  // ── Period helpers ───────────────────────────────────────────────────────

  /// Returns the start of the current tracking period for a habit.
  static DateTime getPeriodDate(Habit habit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final unit = habit.frequencyUnit;
    if (unit == 'weeks') {
      // Monday-based week start
      final daysFromMonday = now.weekday - 1;
      return today.subtract(Duration(days: daysFromMonday));
    } else if (unit == 'months') {
      return DateTime(now.year, now.month, 1);
    }
    return today;
  }

  // ── Completion queries ───────────────────────────────────────────────────

  /// Watch all completions (filtered in-code by period per habit).
  Stream<List<HabitCompletion>> watchAllCompletions() {
    return select(habitCompletions).watch();
  }

  /// Upsert or delete a completion record for a habit/period.
  Future<void> updateHabitCompletion(
    int habitId,
    DateTime periodDate,
    int newReps,
  ) async {
    final existing = await (select(habitCompletions)
          ..where(
            (c) =>
                c.habitId.equals(habitId) & c.periodDate.equals(periodDate),
          ))
        .getSingleOrNull();

    if (existing == null) {
      if (newReps > 0) {
        await into(habitCompletions).insert(
          HabitCompletionsCompanion(
            habitId: Value(habitId),
            periodDate: Value(periodDate),
            completedReps: Value(newReps),
          ),
        );
      }
    } else {
      if (newReps <= 0) {
        await (delete(habitCompletions)
              ..where((c) => c.id.equals(existing.id)))
            .go();
      } else {
        await (update(habitCompletions)
              ..where((c) => c.id.equals(existing.id)))
            .write(HabitCompletionsCompanion(completedReps: Value(newReps)));
      }
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
