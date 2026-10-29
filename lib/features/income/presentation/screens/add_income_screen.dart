import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/income.dart';
import '../providers/income_category_providers.dart';
import '../viewmodels/add_income_view_model.dart';

class AddIncomeScreen extends ConsumerStatefulWidget {
  const AddIncomeScreen({super.key, this.income});

  /// When provided, the form edits this income entry instead of adding one.
  final Income? income;

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  bool get _isEditing => widget.income != null;

  AddIncomeViewModel get _viewModel =>
      ref.read(addIncomeViewModelProvider(widget.income).notifier);

  @override
  void initState() {
    super.initState();
    final income = widget.income;
    _amountController = TextEditingController(
      text: income == null ? '' : formatCentsForInput(income.amountCents),
    );
    _noteController = TextEditingController(text: income?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addIncomeViewModelProvider(widget.income));
    final viewModel = _viewModel;
    final categories = ref.watch(incomeCategoriesStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit income' : 'Add income')),
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
                _isEditing
                    ? 'Update the details of this income entry.'
                    : 'How much did you receive?',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _amountController,
                autofocus: !_isEditing,
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
              const SizedBox(height: AppSpacing.xl),
              categories.when(
                loading: () => const InputDecorator(
                  decoration: InputDecoration(labelText: 'Income category'),
                  child: Text('Loading categories…'),
                ),
                error: (_, _) => Text(
                  'Could not load income categories. '
                  'Try reopening this screen.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                data: (items) => DropdownButtonFormField<int>(
                  initialValue: form.categoryId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Income category',
                  ),
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
                controller: _noteController,
                maxLength: 200,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                onChanged: viewModel.setNote,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Monthly salary',
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
                    : Text(_isEditing ? 'Save changes' : 'Save income'),
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
      helpText: 'Income date',
    );
    if (picked != null) {
      ref
          .read(addIncomeViewModelProvider(widget.income).notifier)
          .setDate(picked);
    }
  }
}
