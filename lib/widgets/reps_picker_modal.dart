import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows the reps-picker dialog and returns the chosen delta (positive or
/// negative), or null if the user cancelled.
Future<int?> showRepsPickerModal(
  BuildContext context, {
  required int totalReps,
  required int completedReps,
}) {
  return showDialog<int>(
    context: context,
    barrierColor: Colors.black26,
    builder: (_) => _RepsPickerModal(
      totalReps: totalReps,
      completedReps: completedReps,
    ),
  );
}

// ── Modal widget ─────────────────────────────────────────────────────────────

class _RepsPickerModal extends StatefulWidget {
  final int totalReps;
  final int completedReps;

  const _RepsPickerModal({
    required this.totalReps,
    required this.completedReps,
  });

  @override
  State<_RepsPickerModal> createState() => _RepsPickerModalState();
}

class _RepsPickerModalState extends State<_RepsPickerModal> {
  late final List<int> _values;
  late int _selectedValue;
  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _values = _buildValues();
    // Default to +1 if available, otherwise first value
    _selectedValue = _values.contains(1) ? 1 : _values.first;
    _scrollController = FixedExtentScrollController(
      initialItem: _values.indexOf(_selectedValue),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// All integers from -completedReps to +(totalReps-completedReps), skip 0.
  List<int> _buildValues() {
    final remaining = widget.totalReps - widget.completedReps;
    return [
      for (int i = -widget.completedReps; i <= remaining; i++)
        if (i != 0) i,
    ];
  }

  void _nudge(int direction) {
    final current = _values.indexOf(_selectedValue);
    final next = current + direction;
    if (next < 0 || next >= _values.length) return;
    _scrollController.animateToItem(
      next,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.totalReps - widget.completedReps;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            // ── Picker row ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundButton(
                  icon: Icons.remove,
                  onTap: () => _nudge(-1),
                ),
                const SizedBox(width: 10),
                _WheelPicker(
                  values: _values,
                  controller: _scrollController,
                  selectedValue: _selectedValue,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedValue = v);
                  },
                ),
                const SizedBox(width: 10),
                _RoundButton(
                  icon: Icons.add,
                  onTap: () => _nudge(1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ── Action row ───────────────────────────────────────────────
            Row(
              children: [
                // Finish All
                _ActionButton(
                  label: 'Finish All',
                  onTap: () => Navigator.pop(context, remaining),
                  style: _ActionStyle.outlined,
                ),
                const Spacer(),
                // Cancel
                _ActionButton(
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                  style: _ActionStyle.text,
                ),
                const SizedBox(width: 6),
                // Finish N
                _ActionButton(
                  label: 'Finish $_selectedValue',
                  onTap: () => Navigator.pop(context, _selectedValue),
                  style: _ActionStyle.filled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Horizontal wheel picker ───────────────────────────────────────────────────

class _WheelPicker extends StatelessWidget {
  final List<int> values;
  final FixedExtentScrollController controller;
  final int selectedValue;
  final ValueChanged<int> onChanged;

  const _WheelPicker({
    required this.values,
    required this.controller,
    required this.selectedValue,
    required this.onChanged,
  });

  // Each slot is 56 px wide; dividers sit at the 1/3 and 2/3 marks.
  static const double _slotWidth = 56;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _slotWidth,
      width: _slotWidth * 3,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // ── Wheel ─────────────────────────────────────────────────
            RotatedBox(
              quarterTurns: 3, // scroll horizontally (LTR)
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: _slotWidth,
                perspective: 0.002,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) => onChanged(values[i]),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: values.length,
                  builder: (_, i) {
                    return RotatedBox(
                      quarterTurns: 1, // un-rotate text
                      child: Center(
                        child: Text(
                          '${values[i]}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // ── Left divider (between slot 0 and 1) ──────────────────
            Positioned(
              left: _slotWidth - 0.5,
              top: 10,
              bottom: 10,
              width: 1,
              child: Container(color: const Color(0xFFE5E5E5)),
            ),
            // ── Right divider (between slot 1 and 2) ─────────────────
            Positioned(
              left: _slotWidth * 2 - 0.5,
              top: 10,
              bottom: 10,
              width: 1,
              child: Container(color: const Color(0xFFE5E5E5)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

enum _ActionStyle { outlined, text, filled }

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final _ActionStyle style;

  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(10));
    const padding = EdgeInsets.symmetric(horizontal: 14, vertical: 10);
    const ts = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

    switch (style) {
      case _ActionStyle.outlined:
        return OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Color(0xFFE5E5E5)),
            shape: const RoundedRectangleBorder(borderRadius: radius),
            padding: padding,
            textStyle: ts,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(label),
        );
      case _ActionStyle.text:
        return TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black54,
            padding: padding,
            textStyle: ts,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(label),
        );
      case _ActionStyle.filled:
        return ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: radius),
            padding: padding,
            textStyle: ts,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            elevation: 0,
          ),
          child: Text(label),
        );
    }
  }
}
