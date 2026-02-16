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

  // New columns for custom frequency
  IntColumn get frequencyInterval => integer().withDefault(const Constant(1))();
  TextColumn get frequencyUnit => text().withDefault(const Constant('days'))();
  TextColumn get frequencyDays =>
      text().nullable()(); // Comma-separated list for weeks
  TextColumn get reminders =>
      text().nullable()(); // NEW: Stores comma-separated list of times
}

@DriftDatabase(tables: [Habits])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

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
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
