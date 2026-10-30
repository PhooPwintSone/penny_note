import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../income/presentation/screens/income_categories_screen.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);
    final hasFinancialRecords =
        ref.watch(hasFinancialRecordsStreamProvider).value ?? true;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sm,
            AppSpacing.screenPadding,
            AppSpacing.xxl,
          ),
          children: [
            const SectionHeader(title: 'Appearance'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Choose how Penny Note looks. System follows your device.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                      ),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Currency'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.currency_exchange_rounded,
                      color: colors.primary,
                    ),
                    title: const Text('Base currency'),
                    subtitle: Text(
                      '${currency.name} (${currency.code}) · ${currency.symbol}',
                    ),
                    trailing: Icon(
                      hasFinancialRecords
                          ? Icons.lock_outline_rounded
                          : Icons.chevron_right_rounded,
                    ),
                    onTap: () => _openCurrencyPicker(
                      context,
                      ref,
                      currency,
                      hasFinancialRecords,
                    ),
                  ),
                  if (hasFinancialRecords) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Currency is locked because your journal already '
                              'contains transactions. Changing it would require '
                              'converting existing amounts.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Categories'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.category_outlined,
                      color: colors.primary,
                    ),
                    title: const Text('Expense categories'),
                    subtitle: const Text(
                      'Add, rename, change icons, or delete unused categories.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openCategories(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.payments_outlined,
                      color: colors.primary,
                    ),
                    title: const Text('Income categories'),
                    subtitle: const Text(
                      'Manage the categories used by your income entries.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openIncomeCategories(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'About'),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.tileRadius,
                          ),
                        ),
                        child: Icon(
                          Icons.savings_rounded,
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppConstants.tagline,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  const _AboutRow(label: 'Version', value: '1.0.0'),
                  const SizedBox(height: AppSpacing.sm),
                  _AboutRow(
                    label: 'Currency',
                    value: '${currency.name} (${currency.code})',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _AboutRow(label: 'Storage', value: 'On this device only'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openCategories(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const CategoriesScreen()));
}

void _openIncomeCategories(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const IncomeCategoriesScreen()),
  );
}

Future<void> _openCurrencyPicker(
  BuildContext context,
  WidgetRef ref,
  AppCurrency selected,
  bool hasFinancialRecords,
) async {
  if (hasFinancialRecords) {
    await _showCurrencyLockedDialog(context);
    return;
  }

  final chosen = await showModalBottomSheet<AppCurrency>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final colors = theme.colorScheme;

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            0,
            AppSpacing.screenPadding,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose currency', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'One currency applies to every account and transaction.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final currency in AppCurrency.values) ...[
                _CurrencyOption(
                  currency: currency,
                  selected: currency == selected,
                  onTap: () => Navigator.of(sheetContext).pop(currency),
                ),
                if (currency != AppCurrency.values.last)
                  const SizedBox(height: AppSpacing.xs),
              ],
            ],
          ),
        ),
      );
    },
  );

  if (chosen == null || chosen == selected) return;

  try {
    await ref.read(updateCurrencyUseCaseProvider)(chosen);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Currency changed to ${chosen.name} (${chosen.code}).'),
      ),
    );
  } on AppFailure catch (failure) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failure.message)));
  }
}

Future<void> _showCurrencyLockedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Currency is locked'),
      content: const Text(
        'Your journal already contains transactions. Changing the base '
        'currency now would require converting every existing amount. To '
        'protect your records, currency changes are disabled until a '
        'conversion process is available.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

class _CurrencyOption extends StatelessWidget {
  const _CurrencyOption({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  final AppCurrency currency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final titleColor = selected ? colors.onPrimaryContainer : colors.onSurface;
    final subtitleColor = selected
        ? colors.onPrimaryContainer.withValues(alpha: 0.8)
        : colors.onSurfaceVariant;

    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                ),
                child: Text(
                  currency.symbol,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: selected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currency.code} · ${currency.symbol}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
