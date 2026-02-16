/// Model class for Habit data
class HabitModel {
  final int? id;
  final String name;
  final String? goal;
  final String iconName;
  final String colorName;
  final String frequency;
  final String repeat;
  final String? reminderTime;
  final int frequencyInterval;
  final String frequencyUnit;
  final String? frequencyDays;
  final String? reminders; // Comma-separated list of times
  final DateTime? createdAt;

  HabitModel({
    this.id,
    required this.name,
    this.goal,
    required this.iconName,
    required this.colorName,
    required this.frequency,
    required this.repeat,
    this.reminderTime,
    this.frequencyInterval = 1,
    this.frequencyUnit = 'days',
    this.frequencyDays,
    this.reminders,
    this.createdAt,
  });

  HabitModel copyWith({
    int? id,
    String? name,
    String? goal,
    String? iconName,
    String? colorName,
    String? frequency,
    String? repeat,
    String? reminderTime,
    int? frequencyInterval,
    String? frequencyUnit,
    String? frequencyDays,
    String? reminders,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      iconName: iconName ?? this.iconName,
      colorName: colorName ?? this.colorName,
      frequency: frequency ?? this.frequency,
      repeat: repeat ?? this.repeat,
      reminderTime: reminderTime ?? this.reminderTime,
      frequencyInterval: frequencyInterval ?? this.frequencyInterval,
      frequencyUnit: frequencyUnit ?? this.frequencyUnit,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      reminders: reminders ?? this.reminders,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
