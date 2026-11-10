import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_spacing.dart';
import '../utils/date_filter.dart';

/// A horizontally scrolling strip of date-range filters for journal lists.
///
/// The strip offers Today, Last 7 days, Last 30 days, and a Custom range. The
/// custom chip opens a date-range picker and keeps the selected range visible
/// in its label.
class DateFilterStrip extends StatelessWidget {
  const DateFilterStrip({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final DateFilterSelection selectedFilter;
  final ValueChanged<DateFilterSelection> onChanged;

  static final DateFormat _shortDate = DateFormat('MMM d');

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateUtils.dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: selectedFilter.start(now),
        end: selectedFilter.end(now),
      ),
      helpText: 'Filter by date range',
      saveText: 'Apply',
    );

    if (!context.mounted || picked == null) return;
    onChanged(
      DateFilterSelection.custom(
        start: DateUtils.dateOnly(picked.start),
        end: DateUtils.dateOnly(picked.end),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final options = <DateFilterSelection>[
      const DateFilterSelection.today(),
      const DateFilterSelection.last7Days(),
      const DateFilterSelection.last30Days(),
      DateFilterSelection.custom(
        start: selectedFilter.start(now),
        end: selectedFilter.end(now),
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final option = options[index];
          final isCustom = option.preset == DateFilterPreset.custom;

          return _DateFilterChip(
            label: _labelFor(option, now),
            icon: isCustom ? Icons.calendar_today_outlined : null,
            selected: option.preset == selectedFilter.preset,
            onTap: () {
              if (isCustom) {
                _pickCustomRange(context);
              } else {
                onChanged(option);
              }
            },
          );
        },
      ),
    );
  }

  String _labelFor(DateFilterSelection option, DateTime now) {
    if (option.preset != DateFilterPreset.custom ||
        selectedFilter.preset != DateFilterPreset.custom) {
      return option.label;
    }

    final start = selectedFilter.start(now);
    final end = selectedFilter.end(now);
    if (_isSameDay(start, end)) return _shortDate.format(start);
    return '${_shortDate.format(start)} – ${_shortDate.format(end)}';
  }
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = selected ? colors.onPrimary : colors.onSurface;

    return Material(
      color: selected ? colors.primary : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outline, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                maxLines: 1,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
