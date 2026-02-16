// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bookOpen'),
  );
  static const VerificationMeta _colorNameMeta = const VerificationMeta(
    'colorName',
  );
  @override
  late final GeneratedColumn<String> colorName = GeneratedColumn<String>(
    'color_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Pink'),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Every Day'),
  );
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1 Times Per Day'),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _frequencyIntervalMeta = const VerificationMeta(
    'frequencyInterval',
  );
  @override
  late final GeneratedColumn<int> frequencyInterval = GeneratedColumn<int>(
    'frequency_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _frequencyUnitMeta = const VerificationMeta(
    'frequencyUnit',
  );
  @override
  late final GeneratedColumn<String> frequencyUnit = GeneratedColumn<String>(
    'frequency_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('days'),
  );
  static const VerificationMeta _frequencyDaysMeta = const VerificationMeta(
    'frequencyDays',
  );
  @override
  late final GeneratedColumn<String> frequencyDays = GeneratedColumn<String>(
    'frequency_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindersMeta = const VerificationMeta(
    'reminders',
  );
  @override
  late final GeneratedColumn<String> reminders = GeneratedColumn<String>(
    'reminders',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    goal,
    iconName,
    colorName,
    frequency,
    repeat,
    reminderTime,
    createdAt,
    frequencyInterval,
    frequencyUnit,
    frequencyDays,
    reminders,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('color_name')) {
      context.handle(
        _colorNameMeta,
        colorName.isAcceptableOrUnknown(data['color_name']!, _colorNameMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('repeat')) {
      context.handle(
        _repeatMeta,
        repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('frequency_interval')) {
      context.handle(
        _frequencyIntervalMeta,
        frequencyInterval.isAcceptableOrUnknown(
          data['frequency_interval']!,
          _frequencyIntervalMeta,
        ),
      );
    }
    if (data.containsKey('frequency_unit')) {
      context.handle(
        _frequencyUnitMeta,
        frequencyUnit.isAcceptableOrUnknown(
          data['frequency_unit']!,
          _frequencyUnitMeta,
        ),
      );
    }
    if (data.containsKey('frequency_days')) {
      context.handle(
        _frequencyDaysMeta,
        frequencyDays.isAcceptableOrUnknown(
          data['frequency_days']!,
          _frequencyDaysMeta,
        ),
      );
    }
    if (data.containsKey('reminders')) {
      context.handle(
        _remindersMeta,
        reminders.isAcceptableOrUnknown(data['reminders']!, _remindersMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      ),
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      colorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_name'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      repeat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      frequencyInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency_interval'],
      )!,
      frequencyUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency_unit'],
      )!,
      frequencyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency_days'],
      ),
      reminders: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminders'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final String? goal;
  final String iconName;
  final String colorName;
  final String frequency;
  final String repeat;
  final String? reminderTime;
  final DateTime createdAt;
  final int frequencyInterval;
  final String frequencyUnit;
  final String? frequencyDays;
  final String? reminders;
  const Habit({
    required this.id,
    required this.name,
    this.goal,
    required this.iconName,
    required this.colorName,
    required this.frequency,
    required this.repeat,
    this.reminderTime,
    required this.createdAt,
    required this.frequencyInterval,
    required this.frequencyUnit,
    this.frequencyDays,
    this.reminders,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || goal != null) {
      map['goal'] = Variable<String>(goal);
    }
    map['icon_name'] = Variable<String>(iconName);
    map['color_name'] = Variable<String>(colorName);
    map['frequency'] = Variable<String>(frequency);
    map['repeat'] = Variable<String>(repeat);
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<String>(reminderTime);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['frequency_interval'] = Variable<int>(frequencyInterval);
    map['frequency_unit'] = Variable<String>(frequencyUnit);
    if (!nullToAbsent || frequencyDays != null) {
      map['frequency_days'] = Variable<String>(frequencyDays);
    }
    if (!nullToAbsent || reminders != null) {
      map['reminders'] = Variable<String>(reminders);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      goal: goal == null && nullToAbsent ? const Value.absent() : Value(goal),
      iconName: Value(iconName),
      colorName: Value(colorName),
      frequency: Value(frequency),
      repeat: Value(repeat),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      createdAt: Value(createdAt),
      frequencyInterval: Value(frequencyInterval),
      frequencyUnit: Value(frequencyUnit),
      frequencyDays: frequencyDays == null && nullToAbsent
          ? const Value.absent()
          : Value(frequencyDays),
      reminders: reminders == null && nullToAbsent
          ? const Value.absent()
          : Value(reminders),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      goal: serializer.fromJson<String?>(json['goal']),
      iconName: serializer.fromJson<String>(json['iconName']),
      colorName: serializer.fromJson<String>(json['colorName']),
      frequency: serializer.fromJson<String>(json['frequency']),
      repeat: serializer.fromJson<String>(json['repeat']),
      reminderTime: serializer.fromJson<String?>(json['reminderTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      frequencyInterval: serializer.fromJson<int>(json['frequencyInterval']),
      frequencyUnit: serializer.fromJson<String>(json['frequencyUnit']),
      frequencyDays: serializer.fromJson<String?>(json['frequencyDays']),
      reminders: serializer.fromJson<String?>(json['reminders']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'goal': serializer.toJson<String?>(goal),
      'iconName': serializer.toJson<String>(iconName),
      'colorName': serializer.toJson<String>(colorName),
      'frequency': serializer.toJson<String>(frequency),
      'repeat': serializer.toJson<String>(repeat),
      'reminderTime': serializer.toJson<String?>(reminderTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'frequencyInterval': serializer.toJson<int>(frequencyInterval),
      'frequencyUnit': serializer.toJson<String>(frequencyUnit),
      'frequencyDays': serializer.toJson<String?>(frequencyDays),
      'reminders': serializer.toJson<String?>(reminders),
    };
  }

  Habit copyWith({
    int? id,
    String? name,
    Value<String?> goal = const Value.absent(),
    String? iconName,
    String? colorName,
    String? frequency,
    String? repeat,
    Value<String?> reminderTime = const Value.absent(),
    DateTime? createdAt,
    int? frequencyInterval,
    String? frequencyUnit,
    Value<String?> frequencyDays = const Value.absent(),
    Value<String?> reminders = const Value.absent(),
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    goal: goal.present ? goal.value : this.goal,
    iconName: iconName ?? this.iconName,
    colorName: colorName ?? this.colorName,
    frequency: frequency ?? this.frequency,
    repeat: repeat ?? this.repeat,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    createdAt: createdAt ?? this.createdAt,
    frequencyInterval: frequencyInterval ?? this.frequencyInterval,
    frequencyUnit: frequencyUnit ?? this.frequencyUnit,
    frequencyDays: frequencyDays.present
        ? frequencyDays.value
        : this.frequencyDays,
    reminders: reminders.present ? reminders.value : this.reminders,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      goal: data.goal.present ? data.goal.value : this.goal,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      colorName: data.colorName.present ? data.colorName.value : this.colorName,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      frequencyInterval: data.frequencyInterval.present
          ? data.frequencyInterval.value
          : this.frequencyInterval,
      frequencyUnit: data.frequencyUnit.present
          ? data.frequencyUnit.value
          : this.frequencyUnit,
      frequencyDays: data.frequencyDays.present
          ? data.frequencyDays.value
          : this.frequencyDays,
      reminders: data.reminders.present ? data.reminders.value : this.reminders,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('goal: $goal, ')
          ..write('iconName: $iconName, ')
          ..write('colorName: $colorName, ')
          ..write('frequency: $frequency, ')
          ..write('repeat: $repeat, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('frequencyInterval: $frequencyInterval, ')
          ..write('frequencyUnit: $frequencyUnit, ')
          ..write('frequencyDays: $frequencyDays, ')
          ..write('reminders: $reminders')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    goal,
    iconName,
    colorName,
    frequency,
    repeat,
    reminderTime,
    createdAt,
    frequencyInterval,
    frequencyUnit,
    frequencyDays,
    reminders,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.goal == this.goal &&
          other.iconName == this.iconName &&
          other.colorName == this.colorName &&
          other.frequency == this.frequency &&
          other.repeat == this.repeat &&
          other.reminderTime == this.reminderTime &&
          other.createdAt == this.createdAt &&
          other.frequencyInterval == this.frequencyInterval &&
          other.frequencyUnit == this.frequencyUnit &&
          other.frequencyDays == this.frequencyDays &&
          other.reminders == this.reminders);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> goal;
  final Value<String> iconName;
  final Value<String> colorName;
  final Value<String> frequency;
  final Value<String> repeat;
  final Value<String?> reminderTime;
  final Value<DateTime> createdAt;
  final Value<int> frequencyInterval;
  final Value<String> frequencyUnit;
  final Value<String?> frequencyDays;
  final Value<String?> reminders;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.goal = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorName = const Value.absent(),
    this.frequency = const Value.absent(),
    this.repeat = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.frequencyInterval = const Value.absent(),
    this.frequencyUnit = const Value.absent(),
    this.frequencyDays = const Value.absent(),
    this.reminders = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.goal = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorName = const Value.absent(),
    this.frequency = const Value.absent(),
    this.repeat = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.frequencyInterval = const Value.absent(),
    this.frequencyUnit = const Value.absent(),
    this.frequencyDays = const Value.absent(),
    this.reminders = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? goal,
    Expression<String>? iconName,
    Expression<String>? colorName,
    Expression<String>? frequency,
    Expression<String>? repeat,
    Expression<String>? reminderTime,
    Expression<DateTime>? createdAt,
    Expression<int>? frequencyInterval,
    Expression<String>? frequencyUnit,
    Expression<String>? frequencyDays,
    Expression<String>? reminders,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (goal != null) 'goal': goal,
      if (iconName != null) 'icon_name': iconName,
      if (colorName != null) 'color_name': colorName,
      if (frequency != null) 'frequency': frequency,
      if (repeat != null) 'repeat': repeat,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (createdAt != null) 'created_at': createdAt,
      if (frequencyInterval != null) 'frequency_interval': frequencyInterval,
      if (frequencyUnit != null) 'frequency_unit': frequencyUnit,
      if (frequencyDays != null) 'frequency_days': frequencyDays,
      if (reminders != null) 'reminders': reminders,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? goal,
    Value<String>? iconName,
    Value<String>? colorName,
    Value<String>? frequency,
    Value<String>? repeat,
    Value<String?>? reminderTime,
    Value<DateTime>? createdAt,
    Value<int>? frequencyInterval,
    Value<String>? frequencyUnit,
    Value<String?>? frequencyDays,
    Value<String?>? reminders,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      iconName: iconName ?? this.iconName,
      colorName: colorName ?? this.colorName,
      frequency: frequency ?? this.frequency,
      repeat: repeat ?? this.repeat,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      frequencyInterval: frequencyInterval ?? this.frequencyInterval,
      frequencyUnit: frequencyUnit ?? this.frequencyUnit,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      reminders: reminders ?? this.reminders,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (colorName.present) {
      map['color_name'] = Variable<String>(colorName.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (frequencyInterval.present) {
      map['frequency_interval'] = Variable<int>(frequencyInterval.value);
    }
    if (frequencyUnit.present) {
      map['frequency_unit'] = Variable<String>(frequencyUnit.value);
    }
    if (frequencyDays.present) {
      map['frequency_days'] = Variable<String>(frequencyDays.value);
    }
    if (reminders.present) {
      map['reminders'] = Variable<String>(reminders.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('goal: $goal, ')
          ..write('iconName: $iconName, ')
          ..write('colorName: $colorName, ')
          ..write('frequency: $frequency, ')
          ..write('repeat: $repeat, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('frequencyInterval: $frequencyInterval, ')
          ..write('frequencyUnit: $frequencyUnit, ')
          ..write('frequencyDays: $frequencyDays, ')
          ..write('reminders: $reminders')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [habits];
}

typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> goal,
      Value<String> iconName,
      Value<String> colorName,
      Value<String> frequency,
      Value<String> repeat,
      Value<String?> reminderTime,
      Value<DateTime> createdAt,
      Value<int> frequencyInterval,
      Value<String> frequencyUnit,
      Value<String?> frequencyDays,
      Value<String?> reminders,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> goal,
      Value<String> iconName,
      Value<String> colorName,
      Value<String> frequency,
      Value<String> repeat,
      Value<String?> reminderTime,
      Value<DateTime> createdAt,
      Value<int> frequencyInterval,
      Value<String> frequencyUnit,
      Value<String?> frequencyDays,
      Value<String?> reminders,
    });

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorName => $composableBuilder(
    column: $table.colorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequencyInterval => $composableBuilder(
    column: $table.frequencyInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequencyUnit => $composableBuilder(
    column: $table.frequencyUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequencyDays => $composableBuilder(
    column: $table.frequencyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminders => $composableBuilder(
    column: $table.reminders,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorName => $composableBuilder(
    column: $table.colorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequencyInterval => $composableBuilder(
    column: $table.frequencyInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequencyUnit => $composableBuilder(
    column: $table.frequencyUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequencyDays => $composableBuilder(
    column: $table.frequencyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminders => $composableBuilder(
    column: $table.reminders,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get colorName =>
      $composableBuilder(column: $table.colorName, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get frequencyInterval => $composableBuilder(
    column: $table.frequencyInterval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequencyUnit => $composableBuilder(
    column: $table.frequencyUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequencyDays => $composableBuilder(
    column: $table.frequencyDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminders =>
      $composableBuilder(column: $table.reminders, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> goal = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> colorName = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String> repeat = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> frequencyInterval = const Value.absent(),
                Value<String> frequencyUnit = const Value.absent(),
                Value<String?> frequencyDays = const Value.absent(),
                Value<String?> reminders = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                goal: goal,
                iconName: iconName,
                colorName: colorName,
                frequency: frequency,
                repeat: repeat,
                reminderTime: reminderTime,
                createdAt: createdAt,
                frequencyInterval: frequencyInterval,
                frequencyUnit: frequencyUnit,
                frequencyDays: frequencyDays,
                reminders: reminders,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> goal = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> colorName = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String> repeat = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> frequencyInterval = const Value.absent(),
                Value<String> frequencyUnit = const Value.absent(),
                Value<String?> frequencyDays = const Value.absent(),
                Value<String?> reminders = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                goal: goal,
                iconName: iconName,
                colorName: colorName,
                frequency: frequency,
                repeat: repeat,
                reminderTime: reminderTime,
                createdAt: createdAt,
                frequencyInterval: frequencyInterval,
                frequencyUnit: frequencyUnit,
                frequencyDays: frequencyDays,
                reminders: reminders,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
}
