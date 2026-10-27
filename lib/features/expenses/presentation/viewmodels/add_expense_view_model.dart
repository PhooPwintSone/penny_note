import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/money.dart';
import '../providers/expense_providers.dart';

class AddExpenseFormState {
  const AddExpenseFormState({
    this.amountText = '',
    this.note = '',
    this.categoryId,
    required this.date,
    this.isSaving = false,
    this.errorMessage,
  });

  final String amountText;
  final String note;
  final int? categoryId;
  final DateTime date;
  final bool isSaving;
  final String? errorMessage;

  int? get amountCents => parseAmountToCents(amountText);

  bool get canSubmit => amountCents != null && categoryId != null && !isSaving;

  AddExpenseFormState copyWith({
    String? amountText,
    String? note,
    int? categoryId,
    DateTime? date,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddExpenseFormState(
      amountText: amountText ?? this.amountText,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AddExpenseViewModel extends Notifier<AddExpenseFormState> {
  @override
  AddExpenseFormState build() {
    return AddExpenseFormState(date: DateTime.now());
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
      state = state.copyWith(errorMessage: 'Enter an amount like 12.50.');
      return false;
    }
    if (categoryId == null) {
      state = state.copyWith(errorMessage: 'Choose a category.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref.read(addExpenseUseCaseProvider)(
        amountCents: amountCents,
        categoryId: categoryId,
        note: state.note,
        date: state.date,
      );
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(isSaving: false, errorMessage: failure.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Could not save this expense.',
      );
      return false;
    }
  }
}

final addExpenseViewModelProvider =
    NotifierProvider.autoDispose<AddExpenseViewModel, AddExpenseFormState>(
      AddExpenseViewModel.new,
    );
