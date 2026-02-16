import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:drift/drift.dart' hide Column;
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../database/app_database.dart';

class CreateHabitScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CreateHabitScreen({super.key, this.onBack});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();

  String _selectedIcon = 'Man Walking';
  String _selectedColor = 'Pink';
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
    _selectedWeekDays = [_getTodayAbbreviation()];
    _reminders = ['12:00']; // Example default or empty
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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final habit = HabitsCompanion(
        name: Value(_nameController.text),
        goal: Value(_goalController.text.isEmpty ? null : _goalController.text),
        iconName: Value(_selectedIcon),
        colorName: Value(_selectedColor),
        frequency: Value(_frequency), // Summary string
        repeat: Value(_repeat),
        reminders: Value(_reminders.isEmpty ? null : _reminders.join(',')),
        frequencyInterval: Value(_frequencyInterval),
        frequencyUnit: Value(_frequencyUnit),
        frequencyDays: Value(
          _frequencyUnit == 'weeks' && _selectedWeekDays.isNotEmpty
              ? _selectedWeekDays.join(',')
              : null,
        ),
      );

      await _database.into(_database.habits).insert(habit);

      if (mounted && widget.onBack != null) {
        widget.onBack!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
                      IconButton(
                        icon: const PhosphorIcon(PhosphorIconsBold.arrowLeft),
                        onPressed: widget.onBack,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 24,
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
                    decoration: InputDecoration(
                      hintText: 'John Doe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: appColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Goal field
                  _buildSectionLabel('Goal'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _goalController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add any additional comments',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: appColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Icon and Color row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('Icon'),
                            const SizedBox(height: 8),
                            _buildSelectButton(
                              icon: const PhosphorIcon(
                                PhosphorIconsDuotone.personSimpleWalk,
                                size: 20,
                              ),
                              label: _selectedIcon,
                              onTap: () {
                                // TODO: Show icon picker
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('Color'),
                            const SizedBox(height: 8),
                            _buildSelectButton(
                              icon: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _getColorFromName(_selectedColor),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              label: _selectedColor,
                              onTap: () {
                                // TODO: Show color picker
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Settings section
                  _buildSectionLabel('Settings'),
                  const SizedBox(height: 16),
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
                        backgroundColor: appColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
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
    final appColors = context.appColors;
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: appColors.primary,
      ),
    );
  }

  Widget _buildSelectButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final appColors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: appColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const PhosphorIcon(PhosphorIconsBold.caretRight, size: 16),
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
    final appColors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: appColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: appColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PhosphorIcon(
              PhosphorIconsBold.caretRight,
              size: 16,
              color: appColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'Pink':
        return const Color(0xFFFFC0CB);
      case 'Blue':
        return Colors.blue;
      case 'Green':
        return Colors.green;
      case 'Purple':
        return Colors.purple;
      case 'Orange':
        return Colors.orange;
      case 'Red':
        return Colors.red;
      default:
        return const Color(0xFFFFC0CB);
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
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Frequency",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Make changes to your schedule here. Click done when you're finished.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          // Interval Input
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: TextFormField(
                                initialValue: tempInterval.toString(),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  if (val.isNotEmpty) {
                                    tempInterval = int.tryParse(val) ?? 1;
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Unit Dropdown
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              alignment: Alignment.centerLeft,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: tempUnit.toLowerCase(),
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
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
                        const SizedBox(height: 24),
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
                                          ? Colors.black
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 12,
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
                              foregroundColor: Colors.black,
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reminders",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Make changes to your profile here. Click save when you're done.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 24),
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
                                  left: 12,
                                  right: 8,
                                  top: 6,
                                  bottom: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      time,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
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
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.black54,
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
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 40,
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                              ),
                            ),
                          // Add new reminder full button equivalent (optional, based on design I'll stick to chips + button interaction)
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
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 34,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      "Add new reminder",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.add,
                                      color: Colors.black87,
                                      size: 16,
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
                              foregroundColor: Colors.black,
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, tempReminders);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
    final options = [
      '1 Times Per Day',
      '2 Times Per Day',
      '3 Times Per Day',
      '4 Times Per Day',
    ];
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(option),
                onTap: () => Navigator.pop(context, option),
              );
            }).toList(),
          ),
        );
      },
    );
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
