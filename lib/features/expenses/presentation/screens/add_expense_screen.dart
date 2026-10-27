import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../viewmodels/add_expense_view_model.dart';

class AddExpenseScreen extends ConsumerWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addExpenseViewModelProvider);
    final viewModel = ref.read(addExpenseViewModelProvider.notifier);
    final categories = ref.watch(categoriesStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
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
              Text(
                'How much did you spend?',
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
                  labelText: 'Amount',
                  prefixText: r'$ ',
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              categories.when(
                loading: () => const InputDecorator(
                  decoration: InputDecoration(labelText: 'Category'),
                  child: Text('Loading categories…'),
                ),
                error: (_, _) => Text(
                  'Could not load categories. Try reopening this screen.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                data: (items) => DropdownButtonFormField<int>(
                  initialValue: form.categoryId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                  hint: const Text('Choose a category'),
                  items: [
                    for (final category in items)
                      DropdownMenuItem<int>(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(categoryIconFor(category.icon), size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Flexible(child: Text(category.name)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (id) {
                    if (id != null) viewModel.selectCategory(id);
                  },
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
                  hintText: 'Coffee with a friend',
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
                    : const Text('Save expense'),
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
      helpText: 'Expense date',
    );
    if (picked != null) {
      ref.read(addExpenseViewModelProvider.notifier).setDate(picked);
    }
  }
}
