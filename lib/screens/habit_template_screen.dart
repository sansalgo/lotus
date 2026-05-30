import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/habit_templates.dart';
import '../theme/app_colors.dart';
import '../utils/icon_mapper.dart';
import '../widgets/circle_icon_button.dart';
import '../routes/slide_page_route.dart';
import 'habit_form_screen.dart';

class HabitTemplateScreen extends StatelessWidget {
  const HabitTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: PhosphorIconsBold.arrowLeft,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'New Habit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CreateOwnButton(),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                itemCount: habitTemplateCategories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 28),
                itemBuilder: (context, i) =>
                    _CategorySection(category: habitTemplateCategories[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create your own ───────────────────────────────────────────────────────────

class _CreateOwnButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlidePageRoute(page: const HabitFormScreen()),
      ),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            PhosphorIcon(PhosphorIconsBold.plus, size: 14),
            SizedBox(width: 8),
            Text(
              'Create your own',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category section ──────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final HabitTemplateCategory category;

  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          category.description,
          style: const TextStyle(fontSize: 11, color: AppColors.chart2),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < category.templates.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, thickness: 1, color: AppColors.border),
                _TemplateRow(template: category.templates[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Template row ──────────────────────────────────────────────────────────────

class _TemplateRow extends StatelessWidget {
  final HabitTemplate template;

  const _TemplateRow({required this.template});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlidePageRoute(
          page: HabitFormScreen(template: template),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            PhosphorIcon(
              IconMapper.getIconFromName(template.iconName),
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    template.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.chart2,
                    ),
                  ),
                ],
              ),
            ),
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
}
