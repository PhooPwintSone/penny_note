import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/transfer.dart';
import '../viewmodels/savings_view_model.dart';
import 'add_savings_screen.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsState = ref.watch(savingsViewModelProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings')),
      body: savingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load your savings',
              message: error.toString(),
              action: TextButton(
                onPressed: () => ref.invalidate(savingsViewModelProvider),
                child: const Text('Try again'),
              ),
            ),
          ),
        ),
        data: (state) => ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              120,
            ),
            children: [
              _SavingsSummary(totalCents: state.totalCents, currency: currency),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Savings activity'),
              if (state.isEmpty)
                EmptyState(
                  icon: Icons.savings_outlined,
                  title: 'No savings yet',
                  message:
                      'Set money aside for later, or record a withdrawal '
                      'when you need it.',
                  action: FilledButton.tonalIcon(
                    onPressed: () => _openAddSavings(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add savings'),
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < state.transfers.length; i++) ...[
                        if (i > 0) const Divider(),
                        _SavingsTile(
                          transfer: state.transfers[i],
                          currency: currency,
                          onDelete: () => _confirmAndDelete(
                            context,
                            ref,
                            state.transfers[i].id,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSavings(context),
        tooltip: 'Add savings',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openAddSavings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddSavingsScreen()));
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete savings entry?'),
        content: const Text(
          'This entry will be removed from your savings history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(savingsViewModelProvider.notifier).deleteTransfer(id);
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }
}

class _SavingsSummary extends StatelessWidget {
  const _SavingsSummary({required this.totalCents, required this.currency});

  final int totalCents;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final onCard = colors.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total saved · ${currency.code}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onCard.withValues(alpha: 0.75),
                  ),
                ),
              ),
              Icon(
                Icons.savings_outlined,
                size: 20,
                color: onCard.withValues(alpha: 0.75),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCents(totalCents, currency),
              style: theme.textTheme.displaySmall?.copyWith(color: onCard),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Money you set aside stays on this device.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: onCard.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsTile extends StatelessWidget {
  const _SavingsTile({
    required this.transfer,
    required this.currency,
    required this.onDelete,
  });

  final Transfer transfer;
  final AppCurrency currency;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isWithdrawal = transfer.isWithdrawal;
    final amountColor = isWithdrawal
        ? context.pennyColors.expense
        : context.pennyColors.income;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            ),
            child: Icon(
              isWithdrawal
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              size: 22,
              color: amountColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWithdrawal ? 'Savings to Cash' : 'Cash to Savings',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transfer.note.isEmpty
                      ? formatExpenseDate(transfer.date)
                      : '${transfer.note} · ${formatExpenseDate(transfer.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${isWithdrawal ? '−' : '+'} '
            '${formatCents(transfer.amountCents, currency)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
          PopupMenuButton<_SavingsAction>(
            tooltip: 'Savings options',
            icon: Icon(Icons.more_vert_rounded, color: colors.onSurfaceVariant),
            onSelected: (action) {
              if (action == _SavingsAction.delete) onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _SavingsAction.delete,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _SavingsAction { delete }
