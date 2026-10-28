import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_providers.dart';

class AddExpenseFormState {
  const AddExpenseFormState({
    this.amountText = '',
    this.note = '',
    this.categoryId,
    required this.date,
    this.editingId,
    this.isSaving = false,
    this.errorMessage,
  });

  final String amountText;
  final String note;
  final int? categoryId;
  final DateTime date;
  final int? editingId;
  final bool isSaving;
  final String? errorMessage;

  int? get amountCents => parseAmountToCents(amountText);

  bool get isEditing => editingId != null;

  bool get canSubmit => amountCents != null && categoryId != null && !isSaving;

  AddExpenseFormState copyWith({
    String? amountText,
    String? note,
    int? categoryId,
    DateTime? date,
    int? editingId,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddExpenseFormState(
      amountText: amountText ?? this.amountText,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      editingId: editingId ?? this.editingId,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AddExpenseViewModel extends Notifier<AddExpenseFormState> {
  AddExpenseViewModel(this.initialExpense);

  final Expense? initialExpense;

  @override
  AddExpenseFormState build() {
    final expense = initialExpense;
    if (expense == null) {
      return AddExpenseFormState(date: DateTime.now());
    }

    return AddExpenseFormState(
      amountText: formatCentsForInput(expense.amountCents),
      note: expense.note,
      categoryId: expense.category.id,
      date: expense.date,
      editingId: expense.id,
    );
  }

  void setAmount(String value) {
    state = state.copyWith(amountText: value, clearError: true);
  }

  void setNote(String value) {
    state = state.copyWith(note: value, clearError: true);
  }

  void selectCategory(int categoryId) {
    state = state.copyWith(categoryId: categoryId, clearError: true);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  /// Saves the expense. Returns `true` when the screen should close.
  Future<bool> submit() async {
    final amountCents = state.amountCents;
    final categoryId = state.categoryId;

    if (amountCents == null) {
      state = state.copyWith(errorMessage: 'Enter an amount like 1,500.');
      return false;
    }
    if (categoryId == null) {
      state = state.copyWith(errorMessage: 'Choose a category.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final editingId = state.editingId;
      if (editingId == null) {
        await ref.read(addExpenseUseCaseProvider)(
          amountCents: amountCents,
          categoryId: categoryId,
          note: state.note,
          date: state.date,
        );
      } else {
        await ref.read(updateExpenseUseCaseProvider)(
          id: editingId,
          amountCents: amountCents,
          categoryId: categoryId,
          note: state.note,
          date: state.date,
        );
      }
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(isSaving: false, errorMessage: failure.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: state.isEditing
            ? 'Could not update this expense.'
            : 'Could not save this expense.',
      );
      return false;
    }
  }
}

final addExpenseViewModelProvider = NotifierProvider.autoDispose
    .family<AddExpenseViewModel, AddExpenseFormState, Expense?>(
      AddExpenseViewModel.new,
    );
