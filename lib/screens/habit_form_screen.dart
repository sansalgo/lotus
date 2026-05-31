import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:drift/drift.dart' hide Column;
import '../theme/app_colors.dart';
import '../database/app_database.dart';
import '../utils/icon_mapper.dart';
import '../constants/all_icons.dart';
import '../widgets/circle_icon_button.dart';
import '../services/notification_service.dart';
import '../constants/habit_templates.dart';
import 'package:fuzzy/fuzzy.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? initialHabit;
  final HabitTemplate? template;

  const HabitFormScreen({super.key, this.initialHabit, this.template});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();

  String _selectedIcon = 'acorn';
  String _frequency = 'Every Day';
  String _repeat = '1 Times Per Day';

  // New state variables for custom frequency
  int _frequencyInterval = 1;
  String _frequencyUnit = 'days'; // days, weeks, months, years
  List<String> _selectedWeekDays = [];

  // Reminders
  List<String> _reminders = [];

  late AppDatabase _database;

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();

    final h = widget.initialHabit;
    if (h != null) {
      _nameController.text = h.name;
      _goalController.text = h.goal ?? '';
      _selectedIcon = h.iconName;
      _frequency = h.frequency;
      _repeat = h.repeat;
      _frequencyInterval = h.frequencyInterval;
      _frequencyUnit = h.frequencyUnit;
      _selectedWeekDays =
          h.frequencyDays?.split(',').where((s) => s.isNotEmpty).toList() ??
          [_getTodayAbbreviation()];
      _reminders =
          h.reminders?.split(',').where((s) => s.isNotEmpty).toList() ?? [];
    } else if (widget.template != null) {
      final t = widget.template!;
      _nameController.text = t.name;
      _goalController.text = t.goal;
      _selectedIcon = t.iconName;
      _selectedWeekDays = [_getTodayAbbreviation()];
      _reminders = [];
    } else {
      _selectedWeekDays = [_getTodayAbbreviation()];
      _reminders = [];
    }
  }

  String _getTodayAbbreviation() {
    const days = {
      1: 'MON',
      2: 'TUE',
      3: 'WED',
      4: 'THU',
      5: 'FRI',
      6: 'SAT',
      7: 'SUN',
    };
    return days[DateTime.now().weekday] ?? 'MON';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  /// Parses the numeric count from a repeat string like "3 Times Per Day".
  int get _repeatCount {
    final parts = _repeat.split(' ');
    return int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 1;
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final companion = HabitsCompanion(
        name: Value(_nameController.text),
        goal: Value(_goalController.text.isEmpty ? null : _goalController.text),
        iconName: Value(_selectedIcon),
        frequency: Value(_frequency),
        repeat: Value(_repeat),
        repeatCount: Value(_repeatCount),
        reminders: Value(_reminders.isEmpty ? null : _reminders.join(',')),
        frequencyInterval: Value(_frequencyInterval),
        frequencyUnit: Value(_frequencyUnit),
        frequencyDays: Value(
          _frequencyUnit == 'weeks' && _selectedWeekDays.isNotEmpty
              ? _selectedWeekDays.join(',')
              : null,
        ),
      );

      if (widget.initialHabit != null) {
        final habitId = widget.initialHabit!.id;
        await (_database.update(
          _database.habits,
        )..where((t) => t.id.equals(habitId))).write(companion);
        final updated = await (_database.select(
          _database.habits,
        )..where((t) => t.id.equals(habitId))).getSingle();
        try {
          await NotificationService.scheduleHabitReminders(updated);
        } catch (_) {}
      } else {
        final habitId = await _database
            .into(_database.habits)
            .insert(companion);
        final inserted = await (_database.select(
          _database.habits,
        )..where((t) => t.id.equals(habitId))).getSingle();
        try {
          await NotificationService.scheduleHabitReminders(inserted);
        } catch (_) {}
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Header
                  Row(
                    children: [
                      CircleIconButton(
                        icon: PhosphorIconsBold.arrowLeft,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.initialHabit != null ? 'Edit' : 'Create',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Name field
                  _buildSectionLabel('Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Morning Run',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppColors.chart2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Goal field
                  _buildSectionLabel('Goal'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _goalController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Stay consistent and build a healthier lifestyle',
                      hintMaxLines: 2,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppColors.chart2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Icon
                  _buildSectionLabel('Icon'),
                  const SizedBox(height: 8),
                  _buildSelectButton(
                    icon: _currentIconDisplay,
                    label: _iconToTitleCase(_selectedIcon),
                    onTap: _showIconPicker,
                  ),
                  const SizedBox(height: 20),
                  // Settings section
                  _buildSectionLabel('Settings'),
                  const SizedBox(height: 8),
                  _buildSettingRow(
                    label: 'Frequency',
                    value: _frequency,
                    onTap: () {
                      _showFrequencyPicker();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingRow(
                    label: 'Repeat',
                    value: _repeat,
                    onTap: () async {
                      final result = await _showRepeatPicker();
                      if (result != null) {
                        setState(() => _repeat = result);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingRow(
                    label: 'Reminders',
                    value: _reminders.isEmpty ? 'None' : _reminders.join(', '),
                    onTap: () {
                      _showRemindersPicker();
                    },
                  ),
                  const SizedBox(height: 32),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.initialHabit != null ? 'Save changes' : 'Submit',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSelectButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const PhosphorIcon(PhosphorIconsBold.caretRight, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.chart2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const PhosphorIcon(
              PhosphorIconsBold.caretRight,
              size: 14,
              color: AppColors.chart2,
            ),
          ],
        ),
      ),
    );
  }

  /// Converts a kebab-case icon name (e.g. "right-arrow") to Title Case ("Right Arrow").
  static String _iconToTitleCase(String name) {
    if (name.isEmpty) return name;
    return name
        .split('-')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Widget get _currentIconDisplay {
    try {
      final meta = AllIcons.all.firstWhere((i) => i.name == _selectedIcon);
      return PhosphorIcon(
        meta.styles['regular'] ?? meta.styles.values.first,
        size: 16,
      );
    } catch (_) {
      return PhosphorIcon(IconMapper.getIconFromName(_selectedIcon), size: 16);
    }
  }

  Future<void> _showIconPicker() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return _IconPickerDialog(initialIcon: _selectedIcon);
      },
    );

    if (result != null) {
      setState(() {
        _selectedIcon = result;
      });
    }
  }

  Future<void> _showFrequencyPicker() async {
    int tempInterval = _frequencyInterval;
    String tempUnit = _frequencyUnit.isNotEmpty
        ? '${_frequencyUnit[0].toUpperCase()}${_frequencyUnit.substring(1)}'
        : 'Days';
    Set<String> tempDays = Set.from(_selectedWeekDays);

    // Default to current day if empty and weeks selected
    if (tempUnit.toLowerCase() == 'weeks' && tempDays.isEmpty) {
      tempDays.add(_getTodayAbbreviation());
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppColors.border),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Frequency",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Set how often you want to perform this habit.",
                        style: TextStyle(color: AppColors.chart2, fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Interval Input
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: tempInterval.toString(),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: AppColors.chart2),
                                ),
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty) {
                                  tempInterval = int.tryParse(val) ?? 1;
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Unit Dropdown
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: tempUnit.toLowerCase(),
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                  ),
                                  items: ['days', 'weeks', 'months', 'years'].map((
                                    String value,
                                  ) {
                                    // Capitalize first letter for display
                                    final display =
                                        '${value[0].toUpperCase()}${value.substring(1)}';
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(display),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setModalState(() {
                                        tempUnit =
                                            '${newValue[0].toUpperCase()}${newValue.substring(1)}';
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (tempUnit.toLowerCase() == 'weeks') ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              [
                                'SUN',
                                'MON',
                                'TUE',
                                'WED',
                                'THU',
                                'FRI',
                                'SAT',
                              ].map((day) {
                                final isSelected = tempDays.contains(day);
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      if (isSelected) {
                                        if (tempDays.length > 1)
                                          tempDays.remove(day);
                                      } else {
                                        tempDays.add(day);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.white
                                            : AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              side: BorderSide(color: AppColors.border),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, {
                                'interval': tempInterval,
                                'unit': tempUnit.toLowerCase(),
                                'days': tempDays.toList(),
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppColors.white,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: const Text("Done"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _frequencyInterval = result['interval'];
        _frequencyUnit = result['unit'];
        _selectedWeekDays = result['days'];

        // Update display text
        String unitStr = _frequencyUnit;
        if (_frequencyInterval == 1) {
          if (_frequencyUnit == 'days')
            _frequency = 'Every Day';
          else
            _frequency = 'Every 1 $unitStr';
        } else {
          _frequency = 'Every $_frequencyInterval $unitStr';
        }

        if (_frequencyUnit == 'weeks' && _selectedWeekDays.isNotEmpty) {
          if (_frequencyInterval == 1) {
            _frequency = 'Weekly on ${_selectedWeekDays.length} days';
          } else {
            _frequency = 'Every $_frequencyInterval weeks';
          }
        }
      });
    }
  }

  Future<void> _showRemindersPicker() async {
    List<String> tempReminders = List.from(_reminders);

    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppColors.border),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reminders",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Add times when you'd like to be reminded to complete this habit.",
                        style: TextStyle(color: AppColors.chart2, fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...tempReminders.map((time) {
                            return GestureDetector(
                              onTap: () async {
                                final picked = await _showTimePicker(time);
                                if (picked != null) {
                                  setModalState(() {
                                    final index = tempReminders.indexOf(time);
                                    if (index != -1) {
                                      tempReminders[index] = picked;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 6,
                                  top: 8,
                                  bottom: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      time,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          tempReminders.remove(time);
                                        });
                                      },
                                      child: const PhosphorIcon(
                                        PhosphorIconsBold.x,
                                        size: 14,
                                        color: AppColors.chart2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          // Add button
                          if (tempReminders.isNotEmpty)
                            InkWell(
                              onTap: () async {
                                final picked = await _showTimePicker(null);
                                if (picked != null) {
                                  setModalState(() {
                                    tempReminders.add(picked);
                                  });
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                ),
                                alignment: Alignment.center,
                                child: const PhosphorIcon(
                                  PhosphorIconsBold.plus,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          if (tempReminders.isEmpty)
                            InkWell(
                              onTap: () async {
                                final picked = await _showTimePicker(null);
                                if (picked != null) {
                                  setModalState(() {
                                    tempReminders.add(picked);
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Add new reminder",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    PhosphorIcon(
                                      PhosphorIconsBold.plus,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              side: BorderSide(color: AppColors.border),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, tempReminders);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppColors.white,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: const Text("Done"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _reminders = result;
      });
    }
  }

  Future<String?> _showRepeatPicker() async {
    int tempTimes = 1;
    try {
      final parts = _repeat.split(' ');
      if (parts.isNotEmpty) {
        tempTimes = int.tryParse(parts[0]) ?? 1;
      }
    } catch (e) {
      tempTimes = 1;
    }

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppColors.border),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Repeat",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Set how many times you want to complete this habit per period.",
                        style: TextStyle(color: AppColors.chart2, fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: tempTimes.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: AppColors.chart2),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            tempTimes = int.tryParse(val) ?? 1;
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              side: BorderSide(color: AppColors.border),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, tempTimes);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppColors.white,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: const Text("Done"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      return '$result Times Per Day';
    }
    return null;
  }

  Future<String?> _showTimePicker([String? initial]) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (initial != null) {
      final parts = initial.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return null;
  }
}

class _IconPickerDialog extends StatefulWidget {
  final String initialIcon;
  const _IconPickerDialog({Key? key, required this.initialIcon})
    : super(key: key);

  @override
  State<_IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<_IconPickerDialog> {
  final TextEditingController _searchController = TextEditingController();

  static List<IconMetadata>? _cachedAllIcons;
  static Fuzzy<IconMetadata>? _cachedFuzzy;

  List<IconMetadata> _filteredIcons = [];
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.initialIcon;

    _cachedAllIcons ??= AllIcons.all;
    _filteredIcons = _cachedAllIcons!;

    _cachedFuzzy ??= Fuzzy<IconMetadata>(
      _cachedAllIcons!,
      options: FuzzyOptions(
        keys: [
          WeightedKey<IconMetadata>(
            name: 'name',
            getter: (IconMetadata i) => i.name,
            weight: 4,
          ),
          WeightedKey<IconMetadata>(
            name: 'tags',
            getter: (IconMetadata i) => i.tags.join(' '),
            weight: 1,
          ),
          WeightedKey<IconMetadata>(
            name: 'categories',
            getter: (IconMetadata i) => i.categories.join(' '),
            weight: 1,
          ),
        ],
        threshold: 0.2, // standard fuzzy tolerance
      ),
    );

    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text;
    if (query.isEmpty) {
      if (_filteredIcons.length != _cachedAllIcons!.length) {
        setState(() {
          _filteredIcons = _cachedAllIcons!;
        });
      }
    } else {
      final results = _cachedFuzzy!.search(query);
      setState(() {
        _filteredIcons = results.map((r) => r.item).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppColors.border),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Icon",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Choose an icon that best represents this habit.",
              style: TextStyle(color: AppColors.chart2, fontSize: 11),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Search...",
                isDense: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.search, color: Colors.grey, size: 16),
                ),
                prefixIconConstraints: const BoxConstraints(maxHeight: 24),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(color: AppColors.chart2, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _filteredIcons.length,
                  itemBuilder: (context, index) {
                    final iconMeta = _filteredIcons[index];
                    final isSelected = _selectedIcon == iconMeta.name;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconMeta.name;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(13)
                              : Colors.transparent,
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primary.withAlpha(76),
                                )
                              : Border.all(
                                  color: AppColors.primary.withAlpha(0),
                                ),
                        ),
                        child: PhosphorIcon(
                          iconMeta.styles['regular'] ??
                              iconMeta.styles.values.first,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: AppColors.border),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedIcon),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.white,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  child: const Text("Done"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
