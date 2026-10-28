import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../viewmodels/add_savings_view_model.dart';

class AddSavingsScreen extends ConsumerWidget {
  const AddSavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addSavingsViewModelProvider);
    final viewModel = ref.read(addSavingsViewModelProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add savings')),
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 640,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.xxl,
            ),
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.add_rounded, size: 18),
                    label: Text('Add'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.remove_rounded, size: 18),
                    label: Text('Withdraw'),
                  ),
                ],
                selected: {form.isWithdrawal},
                onSelectionChanged: (selection) {
                  viewModel.setType(isWithdrawal: selection.first);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                form.isWithdrawal
                    ? 'How much are you taking out?'
                    : 'How much are you setting aside?',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                onChanged: viewModel.setAmount,
                style: theme.textTheme.headlineMedium,
                decoration: const InputDecoration(
                  labelText: 'Amount (MMK)',
                  prefixText: '$currencySymbol ',
                  hintText: '0',
                  helperText: 'Myanmar Kyat',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                maxLength: 200,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                onChanged: viewModel.setNote,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Monthly savings',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(context, ref, form.date),
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text('Date: ${formatExpenseDate(form.date)}'),
                ),
              ),
              if (form.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  form.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: form.isSaving
                    ? null
                    : () async {
                        final saved = await viewModel.submit();
                        if (!context.mounted) return;
                        if (saved) {
                          Navigator.of(context).pop();
                        }
                      },
                child: form.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(form.isWithdrawal ? 'Withdraw' : 'Add to savings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    DateTime currentDate,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate.isAfter(now) ? now : currentDate,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Savings date',
    );
    if (picked != null) {
      ref.read(addSavingsViewModelProvider.notifier).setDate(picked);
    }
  }
}
